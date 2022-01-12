unit BExecute;

interface

//todo filter not working

function GetEnviromentVar(Input: String): string;
function ProcessExists(const exeFileName,Filter: string; Flags:longword; var FCnt:longword): Boolean;
function ExecuteFile( const Filename, Parameters: string;
                    eoHide, eoWait, eoConsole:boolean;
                    const EnvVar,InputPipeStr :ansistring; var OutputPipeStr :ansistring): Integer;
function ExecuteFileHWC( const Filename, Parameters: string): Integer;
function ExecuteFileW( const Filename, Parameters: string; aWait:boolean=true) : Integer;
function RunAsAdmin(const Handle: longword; const Path, Params: ansistring): Boolean;

// note envvar format =>   aa=bb#0cc=dd#0#0


implementation

{$IFDEF FPC }
uses Windows,ShellAPI,BFileTools,jwaTlhelp32,BStrTools,jwaPSApi;
{$ELSE}
uses Windows,ShellAPI,BFileTools,Tlhelp32,BStrTools,PSApi;
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

 type
    TUnicodeString = record
      Length: ShortInt;
      MaxLength: ShortInt;
      Buffer: PWideChar;
    end;
    TProcessBasicInformation = record
      ExitStatus: DWord;
      PEBBaseAddress: Pointer;
      AffinityMask: DWord;
      BasePriority: DWord;
      UniqueProcessID: Word;
      ParentProcessID: DWord;
    end;

  function GetPEBAddress(inhandle: THandle): pointer;
    type
      NTQIP = procedure(ProcessHandle: THandle;
                        ProcessInformationClass: DWord;
                        ProcessInformation: Pointer;
                        ProcessInformationLength: DWord;
                        ReturnLength: Pointer); stdcall;
    var
      pbi: TProcessBasicInformation;
      MyHandle: THandle;
      myFunc: NTQIP;
    begin
      MyHandle := LoadLibrary('NTDLL.DLL');
      if MyHandle <> 0 then
        begin
          myFunc := NTQIP(GetProcAddress(myHandle, 'NtQueryInformationProcess'));
          if @myfunc <> nil then
            MyFunc(inhandle, 0, @pbi, sizeof(pbi), nil);
        end;
      FreeLibrary(Myhandle);
      Result := pbi.PEBBaseAddress;
    end;

 function getcommandline(myproc:Cardinal{inproc: THandle}): string;
    var
//      myproc: THandle;
      rtlUserProcAddress: Pointer;
      PMBAddress: Pointer;
      command_line: TUnicodeString;
      command_line_contents: WideString;
      outr: SIZE_T;
    begin
//      myproc := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ,
//                        false, inproc);
      PMBAddress := GetPEBAddress(myproc);
      ReadProcessMemory(myproc, Pointer(Longint(PMBAddress) + $10),
            @rtlUserProcAddress, sizeof(Pointer), outr);
      ReadProcessMemory(myproc, Pointer(Longint(rtlUserProcAddress) + $40),
            @command_line, sizeof(command_line), outr);

      SetLength(Command_Line_Contents, command_line.length);
      ReadProcessMemory(myproc, command_Line.Buffer, @command_Line_contents[1],
               command_line.length, outr);
//      CloseHandle(myproc);

      Result := WideCharLenToString(PWideChar(command_Line_Contents),
                           command_line.length div 2);
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

function ProcessExists(const exeFileName,Filter: string; Flags:longword; var FCnt:longword): Boolean;
var
  ContinueLoop,done: boolean;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
  res :integer;
  er:boolean;
  hh,a,i:longword;
  s:string;
  aExeFileName,aFilter:string;
  lmod :array[0..2] of longword;
begin
   Fcnt := 0;
   aExeFileName := UpperCase(ExtractFile(exeFileName)); // get only exe file name
   aFilter := UpperCase(Trim(Filter));

   FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
   FProcessEntry32.dwSize := SizeOf(FProcessEntry32);
   ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);
   Result := False; //not fpound


   while Integer(ContinueLoop) <> 0 do
   begin
      if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) = aExeFileName)
       or(UpperCase(FProcessEntry32.szExeFile) = aExeFileName)) then
      begin
         SetLength(s,2048);

         hh := OpenProcess(PROCESS_QUERY_INFORMATION or
                           PROCESS_VM_READ
                           { PROCESS_ALL_ACCESS }
                           ,false,FProcessEntry32.th32ProcessID);
          _GetDebugPriv;
         // module ziro is exe
         a := 0;
         er := EnumProcessModules(hh,@lmod[0],2,a);
         i := 512;
         a := GetModuleFileNameEx(hh,lmod[0],pchar(@s[1]),i);
         s[i] := #0;

         if  (Flags and $00000002) <> 0 then s := s + GetCommandLine(hh);
         if  (Flags and $00000004) <> 0 then s := GetCommandLine(hh);
         if  (Flags and $00000008) =  0 then s := UpperCase(s);

         res := 1;
         if length(aFilter) <> 0 then res := Pos(aFilter,s);
         if res <> 0 then
         begin

//       procPID := FProcessEntry32.th32ProcessID;
            done := true;
            if  (Flags and $80000000) <> 0 then
            begin
               Res := Integer(TerminateProcess(OpenProcess(
                              PROCESS_TERMINATE, BOOL(0),
                              FProcessEntry32.th32ProcessID), 0));
               if Res = 0  then done := false;
            end;
            Result := done;
            inc(Fcnt);
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
