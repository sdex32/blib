unit BComPort;

interface

uses Windows,Messages;

type  BTComPort = class
         private
            res:string;
            rescnt :longword;
            aCallBack:pointer;
            aUserData:NativeUInt;
            aTermChar:char;
            aConnected :boolean;
            Response :byte;
            aPort :NativeUint;
            dcb : TDCB;
            tms : TCOMMTIMEOUTS;
            thr : longword;
            ThreadRunning : boolean;
            NotExit : boolean;
            BytesRead:longword;
            function    PortHandle:longint;
            procedure   ProcessData(Arr:pointer; Total:longword);
         public
            constructor Create;
            destructor  Destroy; override;
            function    Open(ComPort:string; BaudRate, DataBits, Parity, StopBits:longword):longint;
            procedure   SetHandler(TermChar:longword; CallBack:Pointer; UserData:NativeUInt);
            function    Send(data:string):boolean;
            procedure   Close;
            property    Connected :boolean read aConnected;
            property    Received :string read res;
      end;

      BTComPortCallBack = procedure(aCom:BTComPort; UserData:NativeUInt); stdcall;

function EnumComPorts(var Res:string):longint;

implementation



uses ActiveX;

const ARRAY_SIZE = 512;
      ACK				 = $06;
      NACK			 = $15;

type bytearr = array [0..0] of byte;

(*
procedure b_debug(a:string; w:longint); stdcall; export;
var f:file of byte;
    s,s1,s2,s3,s4,s5:string;
    w1,i:longword;
    b:byte;
    ttt:TDateTime;
    td,tm,ty:longint;
   SystemTime: TSystemTime;
//   cs : _RTL_CRITICAL_SECTION;
begin
//   If Exist('bdebug.log') = false then
//   begin
//      assign(f,'bdebug.log');
//      rewrite(f);
//      b := 13;
//      write(f,b);
//      b := 10;
//      write(f,b);
//      system.Close(f);
//   end;
   system.assign(f,'bdebug.log');
   system.reset(f);
   system.seek(f,system.fileSize(F));
   s3 := a;
   str(w,s1);
   s:= s3+' | '+s1+#13#10;
   for i :=1 to length(s) do
   begin
      b := byte(s[i]);
      system.write(f,b);
   end;
//   writeln(f,s);
   system.close(f);
//   LeaveCriticalSection(cs);
end;
*)

//------------------------------------------------------------------------------
constructor BTComPort.Create;
begin
   thr := 0;
   aCallback := nil;
   rescnt := 0;
   aConnected := false;
   SetLength(res,4096);
   rescnt :=0;
   ThreadRunning := false;
   NotExit := false;
   aPort := INVALID_HANDLE_VALUE;
end;

//------------------------------------------------------------------------------
destructor  BTComPort.Destroy;
begin
   Close;
   inherited;
end;


function    ReaderThread(a:longword):longint; stdcall;
begin
   Result := BTComPort(a).PortHandle;
end;

//------------------------------------------------------------------------------
function    BTComPort.Open(ComPort:string; BaudRate, DataBits, Parity, StopBits:longword):longint;
var erb:boolean;
    d:longword;
    Ticks:longword;
begin
   Result := -32000;
   if aConnected then Close;


   aConnected := false;

   ComPort := '\\.\'+ComPort;
	 aPort := CreateFile(@ComPort[1],
						GENERIC_READ or GENERIC_WRITE,
						0,
						nil,
						OPEN_EXISTING,
						FILE_ATTRIBUTE_NORMAL, // | FILE_FLAG_OVERLAPPED,
						0);

	 if (aPort = INVALID_HANDLE_VALUE) then
   begin
//b_debug('cant open file',0);
      Exit;
   end else begin

//!!!!! ne moje da se polzwa ako ne e izpolzwan wrusta 0 !!!!!
//      if GetCommModemStatus(aPort, wd) then
//      begin
//         if (wd and $30)= 0 then
//         begin
////b_debug('modem status',0);
//            CloseHandle(aPort);
//            Result := -32001;
//            Exit;
//         end;
//      end;

      SetupComm(aPort,4096,1200); //from c com

      erb := GetCommState(aPort, dcb);
      if erb = false then // (!erb)
      begin
         CloseHandle(aPort);
//b_debug('get state',0);
         Result := -32002;
         Exit;
      end;
   end;

   dcb.DCBlength := sizeof(DCB);

//         dcb.XonLim := 1024 div 4;
//         dcb.XoffLim := 1024 div 4;
//         dcb.Flags := 8213; //1; //  dcb_Binary           = $00000001;
//       // dcb.EofChar := #65;

// fBinary           = $00000001;
// fParity           = $00000002;
// fOutxCtsFlow      = $00000004;
// fOutxDsrFlow      = $00000008;

// fDtrControl       = $00000030;  // 2 bits
// fDsrSensitivity   = $00000040;
// fTXContinueOnXoff = $00000080;

// fOutX             = $00000100;
// fInX              = $00000200;
// fErroChar         = $00000400;
// fNull             = $00000800;

// fRtsControl       = $00003000; // 2 bit
// fAbortOnError     = $00004000;

   dcb.BaudRate := BaudRate; //9600; //Boud_Rate;
   dcb.ByteSize := DataBits;
   dcb.Parity := Parity;  // 0-N 1-O 2-E 3-M 4-S
   if Stopbits > 2 then StopBits := 0;
   dcb.StopBits := Stopbits;

   dcb.Flags := dcb.Flags or (DTR_CONTROL_ENABLE shl 4) or (RTS_CONTROL_ENABLE shl 12);

   erb := SetCommState(aPort, dcb);
   if erb = false then
   begin
//b_debug('set state',0);
      CloseHandle(aPort);
      Result := -32003;
      Exit;
   end else begin

      tms.ReadIntervalTimeout  := 1;  //$FFFFFFFF; //50;
      tms.ReadTotalTimeoutMultiplier := 0; //10;
      tms.ReadTotalTimeoutConstant := 1; //0; //50;
      tms.WriteTotalTimeoutMultiplier := 0; //100; //10;
      tms.WriteTotalTimeoutConstant := 500; //1000; //50;

      erb := SetCommTimeouts(aPort, tms);
      if erb = false then
      begin
//b_debug('set time',0);
         CloseHandle(aPort);
         Result := -32004;
         Exit;
      end;

      NotExit := TRUE;
      ThreadRunning := False;;

      thr := CreateThread(nil,0,@ReaderThread,self,0,d);

      Ticks := GetTickCount() + 1000;

 	    while ( not ThreadRunning) and (Ticks > GetTickCount ) do Sleep(1);

   end;

//b_debug('OK init',0);
   aConnected := true;
   Result := 0;
end;

//------------------------------------------------------------------------------
procedure   BTComPort.Close;
var Ticks:longword;
begin
   try
   aConnected := false;
   if aPort <> INVALID_HANDLE_VALUE then
   begin
      NotExit := false; // force exit;
   		Ticks := GetTickCount() + 1000;

      while (ThreadRunning and (Ticks > GetTickCount())) do	Sleep(1);

		  if (ThreadRunning) then TerminateThread(thr, 0);

  		CloseHandle(aPort);
      thr := 0;
	  	aPort := INVALID_HANDLE_VALUE;
   end;
   except
      thr := 0;
	  	aPort := INVALID_HANDLE_VALUE;
   end;
end;


//------------------------------------------------------------------------------
function    BTComPort.PortHandle:longint;
var ReadWait:boolean;
    Error :longword;
    arr:array[0..ARRAY_SIZE] of byte;
begin
//b_debug('thread begin',0);
	 ReadWait := FALSE;

	 CoInitialize(nil);

   Result := GetLastError();
	 if (Result <> ERROR_SUCCESS) then
   begin
//		CString Out;
//		Out.Format(_T("PANIC %u, %x"), Result, Result);
   end;

//	TRACE(_T("\nThread for SubNet %u has started"), SubNetwork);

	 SetCommMask(aPort, EV_ERR or EV_RXCHAR or EV_CTS);

   ThreadRunning := TRUE;
//b_debug('setmask',0);
	 while (NotExit) do
   begin
		  if ( not ReadWait) then
		  begin
			   if (ReadFile(aPort, arr, ARRAY_SIZE, BytesRead, nil)) then  //&OsReader))
         begin
//b_debug('Process data',BytesRead);
    				ProcessData(@Arr, BytesRead);
         end else begin
  				  Error := GetLastError();
            if (Error <> ERROR_IO_PENDING) then 	  // read not delayed?
            begin
//					LPVOID lpMsgBuf;
//					FormatMessage(
//						FORMAT_MESSAGE_ALLOCATE_BUFFER |
//						FORMAT_MESSAGE_FROM_SYSTEM |
//						FORMAT_MESSAGE_IGNORE_INSERTS,
//						NULL,
//						Error,
//						0, // Default language
//						(LPTSTR) &lpMsgBuf,
//						0,
//						NULL
//					);
//					// Process any inserts in lpMsgBuf.
//					// ...
//					// Display the string.
//					TRACE(_T("\n%s reports: %s - Port closed..."), PortName, (LPCTSTR)lpMsgBuf);
//b_debug('No exit',0);

//todo kakwo prawa pri tazi greshka
				    	NotExit := FALSE;
					    break;
           end;
				end;
		 end;
  end;
//b_debug('Thread bye bye',0);
	ThreadRunning := FALSE;
	CoUninitialize();
end;

//------------------------------------------------------------------------------
procedure  BTComPort.ProcessData(Arr:pointer; Total:longword);
var i:longword;
    TheArr : ^bytearr;
    cb:BTComPortCallBack;
begin

   TheArr :=  Arr;

   if Total > 0 then
   begin
//b_debug('Total ',Total);
	 for i:= 0 to Total -1 do
	 begin
//b_debug('char = '+char(TheArr[i]),TheArr[i]);
	   if (TheArr[i] = ACK) or (TheArr[i] = NACK) or (TheArr[i] = byte(aTermchar)) then
     begin
//b_debug('Response ',Total);
         Response := TheArr[i];
         rescnt := 0;
         if aCallBack <> nil then
         begin
            cb := aCallback;
            cb(self,aUserData);
         end;
     end;
     if (TheArr[i] > 32) or (TheArr[i]=13) or (TheArr[i]=10) then
     begin
        inc(rescnt);
        if longint(rescnt) < length(res) then  Res[rescnt] := char(TheArr[i]);
     end;
   end;

   end;
end;

//------------------------------------------------------------------------------
procedure   BTComPort.SetHandler(TermChar:longword; CallBack:Pointer; UserData:NativeUint);
begin
   aTermChar := char(TermChar);
   aCallBack := Callback;
   aUserData := UserData;
end;

//------------------------------------------------------------------------------
function    BTComPort.Send(data:string):boolean;
var sa:ansistring;
    j,k:longword;
    p:pointer;
begin
   Result := false; //fail
   if aConnected then
   begin
      sa := ansistring(data);
      j := length(sa);
      if j > 0 then
      begin
         p := @sa[1];
         writeFile(aPort,p^,j,k,nil);
         if k = j then Result := true;
      end;
   end;
end;

//------------------------------------------------------------------------------
function EnumComPorts(var Res:string):longint;
var
  KeyHandle: HKEY;
  ErrCode, Index: Integer;
  ValueName, Data: string;
  ValueLen, DataLen, ValueType: DWORD;
begin
  Res := '';
  Result := -1;
  ErrCode := RegOpenKeyEx(
    HKEY_LOCAL_MACHINE,
    'HARDWARE\DEVICEMAP\SERIALCOMM',
    0,
    KEY_READ,
    KeyHandle);

  if ErrCode <> ERROR_SUCCESS then Exit;


  try
    Index := 0;
    repeat
      ValueLen := 256;
      DataLen := 256;
      SetLength(ValueName, ValueLen);
      SetLength(Data, DataLen);
      ErrCode := RegEnumValue(
        KeyHandle,
        Index,
        PChar(ValueName),
{$IFDEF DELPHI_4_OR_HIGHER}
        Cardinal(ValueLen),
{$ELSE}
        ValueLen,
{$ENDIF}
        nil,
        @ValueType,
        PByte(PChar(Data)),
        @DataLen);

      if ErrCode = ERROR_SUCCESS then
      begin
        SetLength(Data, DataLen - 1);
        Res := Res + Data + '|';
        Inc(Index);
      end
      else
        if ErrCode <> ERROR_NO_MORE_ITEMS then Exit;

    until (ErrCode <> ERROR_SUCCESS) ;

  except
    Res := '';
  end;

  Result := 0;
end;




end.
