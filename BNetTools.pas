unit BNetTools;

interface

Function Net_GetNameIPAddress(Name:string) :string;
Function Net_GetLocalIPAddress :string;
Function Net_Ping(adr:string):boolean;
Function IsPortFree(port:longword):boolean;



implementation

uses WinSock,Windows;

type
  pu_long = ^u_long;

//------------------------------------------------------------------------------
Function IsPortFree(port:longword):boolean;
var  wsdata :WSAData;
     client : sockaddr_in;
     sock   : Integer;
begin
   Result := false;
   if WSAStartup($2, wsdata) = 0 then
   begin
      client.sin_family      := AF_INET;
      client.sin_port        := htons(Port);
      client.sin_addr.s_addr := inet_addr(PAnsiChar('127.0.0.1'));
      sock  :=socket(AF_INET, SOCK_STREAM, 0);
      Result:=not (connect(sock,client,SizeOf(client))=0);
      // if return 0 we have connection to port to port is used by other prog
   end;
   WSACleanup;
end;


//------------------------------------------------------------------------------
Function Net_GetNameIPAddress(Name:string) :string;
var
  varTWSAData : TWSAData;
  varPHostEnt : PHostEnt;
  varTInAddr : TInAddr;
  namebuf :ansistring;
begin
  NameBuf := ansistring(Name);
  Result := '';
  If WSAStartup($101,varTWSAData) = 0 Then
  begin
    varPHostEnt := gethostbyname(@namebuf[1]);
    varTInAddr.S_addr := u_long(pu_long(varPHostEnt^.h_addr_list^)^);
    Result := string(inet_ntoa(varTInAddr));
  end;
  WSACleanup;
end;

//------------------------------------------------------------------------------
Function Net_GetLocalIPAddress:string;
var
  varTWSAData : TWSAData;
  namebuf : Array[0..255] of AnsiChar;
  s:string;
begin
  s := 'localhost';
  If WSAStartup($101,varTWSAData) = 0 Then
  begin
    gethostname(namebuf,sizeof(namebuf));
    s := string(namebuf);
  end;
  WSACleanup;
  Result := Net_GetNameIPAddress(s);
end;

//------------------------------------------------------------------------------
type
   TIcmpCreateFile = function: THandle; stdcall;// external 'icmp.dll';
   TIcmpCloseHandle = function(icmpHandle : THandle) : boolean; stdcall; //external 'icmp.dll';
   TIcmpSendEcho = function(IcmpHandle : THandle; DestinationAddress : TInAddr;
                      RequestData : Pointer; RequestSize : Smallint;
                      RequestOptions : pointer;
                      ReplyBuffer : Pointer;
                      ReplySize : DWORD;
                      Timeout : DWORD) : DWORD; stdcall; //external 'icmp.dll';



Function Net_Ping(adr:string):boolean;
var
   varTWSAData : TWSAData;
   Handle : THandle;
   InAddr : TInAddr;
   varPHostEnt : PHostEnt;
   DW : DWORD;
   rep : array[1..128] of byte;
   aadr:ansistring;
   module:longword;
   IcmpCreateFile  : TIcmpCreateFile;  // fpc need type
   IcmpCloseHandle : TIcmpCloseHandle;
   IcmpSendEcho    : TIcmpSendEcho;

begin
   result := false;
   DW := 0;

   module := LoadLibrary('icmp.dll');
   if module <> 0 then
   begin
      IcmpCreateFile  := TIcmpCreateFile(GetProcAddress(module, 'IcmpCreateFile'));
      IcmpCloseHandle := TIcmpCloseHandle(GetProcAddress(module, 'IcmpCloseHandle'));
      IcmpSendEcho    := TIcmpSendEcho(GetProcAddress(module, 'IcmpSendEcho'));

      If WSAStartup($101,varTWSAData) = 0 Then
      begin
         Handle := IcmpCreateFile();
         if Handle = INVALID_HANDLE_VALUE then  Exit;
         aadr:=ansistring(adr)+#0;
         varPHostEnt := gethostbyname(@aadr[1]);
         if varPHostEnt <> nil then
         begin
            InAddr.S_addr := u_long(pu_long(varPHostEnt^.h_addr_list^)^);
            DW := IcmpSendEcho(Handle, InAddr, nil, 0, nil, @rep, 128, 1000);
            // DW is number of responses
            //if DW = 0 then ww := GetLastError;

         end;
         IcmpCloseHandle(Handle);
      end;
      FreeLibrary(module);
   end;
   Result := (DW <> 0);
   WSACleanup;
end;


end.
