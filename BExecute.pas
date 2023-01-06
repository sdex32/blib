unit BExecute;

interface

//todo filter not working

function GetEnviromentVar(Input: String): string;
function ProcessExists(const exeFileName,Filter: string; Flags:longword; var FCnt:longword; var Ferr:longint): Boolean;
function ExecuteFile( const Filename, Parameters: string;
                    eoHide, eoWait, eoConsole:boolean;
                    const EnvVar,InputPipeStr :ansistring; var OutputPipeStr :ansistring): Integer;
function ExecuteFileHWC( const Filename, Parameters: string): Integer;
function ExecuteFileW( const Filename, Parameters: string; aWait:boolean=true) : Integer;
function RunAsAdmin(const Handle: longword; const Path, Params: ansistring): Boolean;
function IsUserAdmin: Boolean;

// note envvar format =>   aa=bb#0cc=dd#0#0


implementation

{$IFDEF FPC }
uses Windows,ShellAPI,BFileTools,jwaTlhelp32,BStrTools{,unit1_log},jwaPSApi;
{$ELSE}
uses Windows,ShellAPI,BFileTools,Tlhelp32,BStrTools{,unit1_log},PSApi;
{$ENDIF}

function GetEnvA(lpName: LPCSTR; lpBuffer: LPSTR; nSize: DWORD): DWORD; stdcall; external kernel32 name 'GetEnvironmentVariableA';

function GetEnviromentVar(Input: String): string;  //-- get enviroment variable
var
  OutputSize: integer;
  so:Ansistring;
  pc:pansichar;
begin
  result := '';
  OutputSize := 1;
  SetLength(so, OutputSize);
  // Get buffer size to hold environment variable plus null terminator

  OutputSize := GetEnvA(pansichar(@Input[1]), pansichar(@so[1]), OutputSize);
  if OutputSize > 0 then
  begin
     SetLength(so, OutputSize + 1);
    // Get environment variable
    if GetEnvA(pansichar(@Input[1]), pansichar(@so[1]), OutputSize) > 0 then
    begin
       so[OutputSize] := #0;
       pc := @so[1]; // fake delphi to read to zero of the string
       result := string(pc);
    end;
  end;
end;

//-------------------------------Process Exists

type PROCESS_BASIC_INFORMATION_WOW64 = record
        ExitStatus:longword;
        PebBaseAddress:int64;
        AffinityMask:int64;
        BasePriority:longword;
        UniqueProcdessId:int64;
        Inh0eritedFromUniqueProcessId:int64;
     end;

     PROCESS_BASIC_INFORMATION = record
        PebBaseAddress:pointer;
        //TODO

     end;

     NtQueryInformatioProcess = function(ProcessHandle: THandle;
                                          ProcessInformationClass: DWord;
                                          ProcessInformation: Pointer;
                                          ProcessInformationLength: DWord;
                                          ReturnLength: Pointer):longint; stdcall;

     NtWow64ReadVirtualMemory64 = function(ProcessHandle: THandle;
                                             BaseAddress:int64;
                                             Buffsre:pointer;
                                             Size:int64;
                                             NumberOfBytesREad:longword):longint; stdcall;
    TUnicodeStringWow64 = record
      Length: ShortInt;
      MaxLength: ShortInt;
      Buffer: int64;
    end;

const
    PROCESSOR_ARCHITECTURE_AMD64 = 9;

function GetProcCmdLine(h:NativeUint; var fres:longint):string;
var si:_SYSTEM_INFO;
    wow :longbool;
    ProcessParameterOffset:longword;
    CommandLineOffset:longword;
    pebSize, ppSize :nativeUint;
    peb, pp :pointer;
    pbi :PROCESS_BASIC_INFORMATION_WOW64;
    pbin :PROCESS_BASIC_INFORMATION;
    query :NtQueryInformatioProcess;
    read :NtWow64REadVirtualMemory64;
//    i:int64;
    ip:^int64;
    sw:^TUnicodeStringWow64;
    err:dword;
    CmdLine:pwidechar;
//    CmdLn:widestring;
    outr:nativeUInt;
    p:pointer;
    Fer :longint;
begin
   Fer := -1; //fail
   Result := '';
{$IFDEF FPC }
   GetNativeSystemInfo(@si);
{$ELSE}
   GetNativeSystemInfo(si);
{$ENDIF}
   IsWow64Process(GetCurrentProcess,@wow);

   if si.wProcessorArchitecture = PROCESSOR_ARCHITECTURE_AMD64 then
   begin
     ProcessParameterOffset := $20;
     CommandLineOffset := $70;
   end else begin
     ProcessParameterOffset := $10;
     CommandLineOffset := $40;
   end;

   pebSize := ProcessParameterOffset + 8;
   peb := nil;
   ReallocMem(peb,pebSize);
   if peb <> nil then
   begin

      ppSize := CommandLineOffset + 16;
      pp := nil;
      ReallocMem(pp,ppSize);
      if pp <> nil then
      begin


         if wow then
         begin
            // we are running 32bit process in 64 OS
            query := GetProcAddress(GetModuleHandle('ntdll.dll'),'NtWow64QueryInformationProcess64');
            err := query(h,0,@pbi,sizeof(pbi),nil);
            if err = 0 then
            begin
               read :=  GetProcAddress(GetModuleHandle('ntdll.dll'),'NtWow64ReadVirtualMemory64');
               err := read(h,pbi.PebBaseAddress, peb, pebSize, 0);
               if err = 0 then
               begin
                  ip := pointer(longword(peb)+ProcessParameterOffset);
                  err := read(h,ip^, pp, ppSize, 0);
                  if err = 0 then
                  begin
                     sw := pointer(longword(pp)+CommandLineOffset);
                     CmdLine := nil;
                     if sw.Length > 0 then
                     begin
                        ReallocMem(CmdLine,sw.Length);
                        err := read(h,sw.Buffer,CmdLine,sw.Length,0);
                        if err = 0 then
                        begin
                           Result := string(CmdLine);
                           SetLength(Result,sw.Length div 2); //chars from wide string to remove artefacts
                           Fer := 0;
                        end;
                        ReallocMem(CmdLine,0);
                     end;
                  end;
               end;
            end;
         end else begin
            // 32 bit process on 32 bit OS or 64 bit app on 64 bit OS
            query := GetProcAddress(GetModuleHandle('ntdll.dll'),'NtQueryInformationProcess');
            err := query(h,0,@pbin,sizeof(pbin),nil);
            if err = 0 then
            begin
               if ReadProcessMemory(h,pbin.PebBaseAddress,peb,pebSize,outr) then
               begin
                  p := pointer(nativeUInt(peb)+ProcessParameterOffset);
                  if ReadProcessMemory(h,p,pp,ppSize,outr) then
                  begin
                     sw := pointer(nativeUint(pp)+CommandLineOffset);
                     CmdLine := nil;
                     ReallocMem(CmdLine,sw.Length);
                     if ReadProcessMemory(h,pointer(sw.Buffer),CmdLine,sw.Length,outr) then
                     begin
                        Result := string(CmdLine);
                        SetLength(Result,sw.Length div 2); //chars from wide string
                        Fer := 0;
                     end;
                     ReallocMem(CmdLine,0);
                  end;
               end;
            end;
         end;
         ReallocMem(pp,0);
      end;
      ReallocMem(peb,0);
   end;
   Fres := Fres + Fer; //Add error
end;







procedure _getDebugPriv;
var
   hToken: THandle;
   sedebugnameValue: TLargeInteger;
   tkp: TTokenPrivileges;
   oldtkp:TTokenPrivileges;
   Len: DWORD;
begin
   OpenProcessToken(GetCurrentProcess, TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, hToken);
   try
      if not LookupPrivilegeValue(nil, 'SeDebugPrivilege', sedebugnameValue) then Exit;
      tkp.PrivilegeCount := 1;
      tkp.Privileges[0].Luid := sedebugnameValue;
      tkp.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
//      if not AdjustTokenPrivileges(hToken, False, tkp, sizeof(tkp), nil, Len) then Exit;
      if not AdjustTokenPrivileges(hToken, False, tkp, sizeof(tkp), oldtkp, Len) then Exit;  //fpc
   finally
      CloseHandle(hToken);
   end;
end;

//var er:boolean;

function ProcessExists(const exeFileName,Filter: string; Flags:longword; var FCnt:longword; var Ferr:longint): Boolean;
var
  ContinueLoop,done: boolean;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
  res :integer;
//  er:boolean;
  hh,a,i:longword;
  s:string;
  aExeFileName,aFilter:string;
//  lmod :array[0..2] of HModule;
begin
   Ferr := 0;
   Fcnt := 0;
   aExeFileName := UpperCase(ExtractFile(exeFileName)); // get only exe file name
   if  (Flags and $00000008) =  0 then aFilter := UpperCase(Trim(Filter))
                                  else aFilter := trim(Filter);

   FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
   FProcessEntry32.dwSize := SizeOf(FProcessEntry32);
   ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);
   Result := False; //not fpound

   while Integer(ContinueLoop) <> 0 do
   begin
//debugstr := debugstr + 'find '+ansistring(string(FProcessEntry32.szExeFile))+' |';
      if ((UpperCase(ExtractFileName(string(FProcessEntry32.szExeFile))) = aExeFileName)
      or(UpperCase(string(FProcessEntry32.szExeFile)) = aExeFileName)) then
      begin
//debugstr := debugstr + 'gotit |';
         if  (Flags and $00000010) <> 0 then inc(Fcnt);  // Count all with this name


         hh := OpenProcess(PROCESS_QUERY_INFORMATION or
                           PROCESS_VM_READ
                           { PROCESS_ALL_ACCESS }
                           ,false,FProcessEntry32.th32ProcessID);
          _GetDebugPriv;
         // module ziro is exe
//         a := 0;
//         er := EnumProcessModules(hh,@lmod[0],sizeof(lmod),a);
         SetLength(s,2048);
         i := 512;
         a := GetModuleFileNameEx(hh,0,pchar(@s[1]),i);
//         a := GetModuleFileNameEx(hh,lmod[0],pchar(@s[1]),i);
         SetLength(s,a);
//debugstr := debugstr + 'get module '+ansistring(string(s))+' |';

         if  (Flags and $00000002) <> 0 then s := s + GetProcCmdLine(hh,Ferr);
         if  (Flags and $00000004) <> 0 then s := GetProcCmdLine(hh,Ferr);
         if  (Flags and $00000008) =  0 then s := UpperCase(s);
//debugstr := debugstr + 'get cmd '+ansistring(string(s))+' |';
         res := 1;
         if length(aFilter) <> 0 then res := Pos(aFilter,s);

         if (res <> 0) and (Ferr = 0) then
         begin
//debugstr := debugstr + 'done request '+ansistring(string(aFilter))+' |';
//       procPID := FProcessEntry32.th32ProcessID;
            done := true;
            if  (Flags and $80000000) <> 0 then
            begin
               Res := Integer(TerminateProcess(OpenProcess(
                              PROCESS_TERMINATE, BOOL(0),
                              FProcessEntry32.th32ProcessID), 0));
               if Res = 0  then done := false;
            end;
//debugstr := debugstr + 'start |';
            Result := done;
            if  (Flags and $00000010) =  0 then if length(aFilter) <> 0 then inc(Fcnt);  // Count only filtered
            if  (Flags and $00000001) <> 0 then
            begin
               CloseHandle(hh);
               break;
            end;
         end;
         CloseHandle(hh);
      end;
      ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
   end;
   CloseHandle(FSnapshotHandle);
end;



function ExecuteFile(const Filename, Parameters: string;
                    eoHide, eoWait, eoConsole:boolean;
                    const EnvVar,InputPipeStr:ansistring; var OutputPipeStr :ansistring): Integer;
var b:boolean;
    s:ansistring;
    p:pointer;
    SI: TStartupInfoA;
    PI: TProcessInformation;
    Security: TSecurityAttributes;
    si_r,si_w,so_r,so_w:Thandle;
    aEnvPC:pansichar;
    aPathPC:pansichar;
    aPath:ansistring;
    i,j:longword;
    Apprunning:longword;

    procedure ClosePipes;
    begin
       if si_r <> 0 then CloseHandle(si_r);
       if si_w <> 0 then CloseHandle(si_w);
       if so_r <> 0 then CloseHandle(so_r);
       if so_w <> 0 then CloseHandle(so_w);
    end;

begin
   Result := 0; //ok
   OutputPipeStr  := '';
   si_r := 0; si_w := 0;
   so_r := 0; so_w := 0;
   FillChar(SI, SizeOf(SI), 0);

   try
   FillChar(Security, SizeOf(Security), 0); // security
   with Security do
   begin
      nLength := SizeOf(TSecurityAttributes);
      lpSecurityDescriptor := nil;
      bInheritHandle := True;
   end;

   if eoConsole and (length(InputPipeStr) > 0) then
   begin
      if not CreatePipe(si_r, si_w, @Security, 0) then
      begin
         Result := -1;
         Exit;
      end;
   end;
   if eoConsole then
   begin
      if not CreatePipe(so_r, so_w, @Security, 0) then
      begin
         Result := -1;
         Exit;
      end;
   end;

   if length(EnvVar) <> 0 then aEnvPC := @EnvVar[1] else aEnvPC := nil;
   aPath := ansistring(ExtractFilePath(FileName));
   if length(aPath) <> 0  then aPathPC := @aPath[1] else aPathPC := nil;

//   if si_w <> 0 then SetHandleInformation(si_w, HANDLE_FLAG_INHERIT, 0);
//   if so_r <> 0 then SetHandleInformation(so_r, HANDLE_FLAG_INHERIT, 0);



   SI.CB := SizeOf(SI);
   SI.dwFlags := STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW;
   if si_r = 0 then SI.hStdInput := GetStdHandle(STD_INPUT_HANDLE)
               else SI.hStdInput := si_r;
   SI.hStdOutput := so_w;
   SI.hStdError := so_w;

   if eoHide then SI.wShowWindow := SW_HIDE
             else SI.wShowWindow := SW_SHOWNORMAL;


   s := ansistring(FileName) + ' ' + ansistring(Parameters)+#0;

   b := CreateProcessA(
      nil,                     // pointer to name of executable module
      PansiChar(@s[1]),            // pointer to command line string
      @Security,               // pointer to process security attributes
      @Security,               // pointer to thread security attributes
      True,                    // handle inheritance flag
      CREATE_SUSPENDED,        // creation flags
      aEnvPC,                  // pointer to new environment block
      aPathPC,                 // pointer to current directory name
      SI,                      // pointer to STARTUPINFO
      PI                       // pointer to PROCESS_INFORMATION
   );

   if b then
   begin
      if eoConsole then
      begin
         if WaitForInputIdle(PI.hProcess, 0) = WAIT_TIMEOUT then
         begin // GUI application error
            TerminateProcess(PI.hProcess, 0);
            CloseHandle(PI.hThread);
            CloseHandle(PI.hProcess);
            b := False;
         end;
      end;
   end;

   if not b then
   begin
      ClosePipes;
      Result := -1; //err
      Exit;
   end;

   if eoConsole then
   begin
      j := length(InputPipeStr);
      if j > 0 then
      begin
         p := @InputPipeStr[1];
         b := WriteFile(si_w,p^,j,i,nil);
         if b or (i<>j) then
         begin
            ClosePipes;
            CloseHandle(PI.hThread);
            CloseHandle(PI.hProcess);
            Result := -1; //err
            Exit;
         end;
      end;
   end;

   ResumeThread(PI.hThread);

   if eoWait then
   begin
      repeat
         Apprunning := WaitForSingleObject(PI.hProcess,100) ;
  //        Application.ProcessMessages;
      until (Apprunning <> WAIT_TIMEOUT) ;
   end;
   //if eoWait then WaitForSingleObject(PI.hProcess, INFINITE);

   CloseHandle(so_w); so_w := 0;
   if (eoConsole) and (eoWait) then
   begin
      SetLength(s,512);
      p := @s[1];
      aPathPC:= @s[1]; // fake delphi to copy to ziro end str :)
      repeat
         i := 0;
         b := ReadFile(so_r, p^, 256, i, nil);
         s[i] := #0;
         if i <> 0 then OutputPipeStr := OutputPipeStr + aPathPC;
      until (not b) or (i=0);
   end;

   ClosePipes;
   if eoWait then
   begin
      CloseHandle(PI.hThread);
      CloseHandle(PI.hProcess);
   end;
   except
      ClosePipes;
      CloseHandle(PI.hThread);
      CloseHandle(PI.hProcess);
      Result := -2;
   end;
end;

function ExecuteFileHWC( const Filename, Parameters: string) : Integer;
var d:ansistring;
begin
   Result := ExecuteFile(FileName,Parameters,True,True,True,'','',d);
end;

function ExecuteFileW( const Filename, Parameters: string; aWait:boolean=true) : Integer;
var d:ansistring;
begin
   Result := ExecuteFile(FileName,Parameters,False,aWait,False,'','',d);
end;



function RunAsAdmin(const Handle: longword; const Path, Params: ansistring): Boolean;
var
  sei: TShellExecuteInfoA;
begin
  FillChar(sei, SizeOf(sei), 0);
  sei.cbSize := SizeOf(sei);
  sei.Wnd := Handle;
  sei.fMask := SEE_MASK_FLAG_DDEWAIT or SEE_MASK_FLAG_NO_UI;
  sei.lpVerb := 'runas';
  sei.lpFile := PAnsiChar(Path);
  sei.lpParameters := PAnsiChar(Params);
  sei.nShow := SW_SHOWNORMAL;
  Result := ShellExecuteExA(@sei);
end;




function CheckTokenMembership(TokenHandle: THandle; SIdToCheck: PSID; var IsMember: BOOL): BOOL; StdCall; External 'AdvApi32.dll';

const
  SECURITY_NT_AUTHORITY: SID_IDENTIFIER_AUTHORITY =
    (Value: (0,0,0,0,0,5)); // ntifs
  SECURITY_BUILTIN_DOMAIN_RID: DWORD = $00000020;
  DOMAIN_ALIAS_RID_ADMINS: DWORD = $00000220;

function IsUserAdmin: Boolean;
var
  b: BOOL; //boolean; :( did not work with boolean ?!@??!@? :(
  AdministratorsGroup: PSID;
begin
  {
    This function returns true if you are currently running with admin privileges.
    In Vista and later, if you are non-elevated, this function will return false
    (you are not running with administrative privileges).
    If you *are* running elevated, then IsUserAdmin will return true, as you are
    running with admin privileges.

    Windows provides this similar function in Shell32.IsUserAnAdmin.
    But the function is deprecated, and this code is lifted
    from the docs for CheckTokenMembership:
      http://msdn.microsoft.com/en-us/library/aa376389.aspx
  }

  {
    Routine Description: This routine returns TRUE if the callers
    process is a member of the Administrators local group. Caller is NOT
    expected to be impersonating anyone and is expected to be able to
    open its own process and process token.
      Arguments: None.
      Return Value:
        TRUE - Caller has Administrators local group.
        FALSE - Caller does not have Administrators local group.
  }
   b := BOOL(AllocateAndInitializeSid(
      SECURITY_NT_AUTHORITY,
      2, //2 sub-authorities
      SECURITY_BUILTIN_DOMAIN_RID,  //sub-authority 0
      DOMAIN_ALIAS_RID_ADMINS,      //sub-authority 1
      0, 0, 0, 0, 0, 0,             //sub-authorities 2-7 not passed
      AdministratorsGroup));
   if (b) then
   begin
     if not CheckTokenMembership(0, AdministratorsGroup, b) then  b := False;
     FreeSid(AdministratorsGroup);
   end;

   Result := boolean(b);
end;

(*

var
  ShellExecuteInfo: TShellExecuteInfo;
  ExitCode: DWORD;
begin
  Result := -1;

  ZeroMemory(@ShellExecuteInfo, SizeOf(ShellExecuteInfo));
  ShellExecuteInfo.cbSize := SizeOf(TShellExecuteInfo);
  ShellExecuteInfo.Wnd := Handle;
  ShellExecuteInfo.fMask := SEE_MASK_NOCLOSEPROCESS ;

  ShellExecuteInfo.lpFile := PChar(Filename);


  if Paramaters <> '' then
    ShellExecuteInfo.lpParameters := PChar(Paramaters);

  // Show or hide the window
  if eoHide then
    ShellExecuteInfo.nShow := SW_HIDE
  else
    ShellExecuteInfo.nShow := SW_SHOWNORMAL;

  if ShellExecuteEx(@ShellExecuteInfo) then
    Result := 0;

  if (Result = 0) and (eoWait) then
  begin
    GetExitCodeProcess(ShellExecuteInfo.hProcess, ExitCode);

    while (ExitCode = STILL_ACTIVE) do
    begin
      sleep(50);

      GetExitCodeProcess(ShellExecuteInfo.hProcess, ExitCode);
    end;

    Result := ExitCode;
  end;
end;
*)

(*
function WinExecAndWait32(Path: PChar; Visibility: Word;
  Timeout : DWORD): integer;
var
  WaitResult : integer;
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
 //iResult : integer;
begin
  FillChar(StartupInfo, SizeOf(TStartupInfo), 0);
  with StartupInfo do
  begin
    cb := SizeOf(TStartupInfo);
    dwFlags := STARTF_USESHOWWINDOW or STARTF_FORCEONFEEDBACK;
	{ you could pass sw_show or sw_hide as parameter: }
    wShowWindow := visibility;
  end;
  if CreateProcess(nil,path,nil, nil, False,
		NORMAL_PRIORITY_CLASS, nil, nil,
		StartupInfo, ProcessInfo) then
  begin
    WaitResult := WaitForSingleObject(ProcessInfo.hProcess, timeout);
    { timeout is in miliseconds or INFINITE if
	  you want to wait forever }
    result := WaitResult;
  end
  else
  { error occurs during CreateProcess see help for details }
    result:=GetLastError;
end;
*)
end.
