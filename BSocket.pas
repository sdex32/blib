unit BSocket;
interface

//TODO time out in receive not includet
{$IFNDEF FPC }
{$IFDEF RELEASE}
{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([]) }
{$ENDIF}
{$ENDIF}



uses winsock,windows;
//,BLogFile;

const
   MAX_SERVERSESSIONS = 128;

type
      _BTWSAconnect = class
         private
            aErr :longint;
            aWSA :TWSAData;
            aSock :TSocket;
            aServer :TSockAddr;
            aHostEnt :PHostEnt;
            aWSAon :longword;
            aMode :longword;
            aIp :string;
            aPort :longword;
            aReadBuffer :pointer;
            aSize :longword;
            aTimeout :longword;
            aResult :ansistring;

            procedure  _Reconnect;
         public
            constructor Create; virtual;
            destructor Destroy; override;
            function   Connect( ip_or_name :string; iPort :longword) :longint; virtual;
            procedure  Disconnect;
            function   Send (p :pointer; len :longword) :longint;
            function   Receive (BytesToRead :longword) :longint;
            function   SendReceive (p :pointer; len, BytesToRead :longword) :longint;
            property   GetlastError :longint read aErr;
            property   GetResult :ansistring read aResult;
            property   GetReadPTR :pointer read aReadbuffer;
            property   GetReadSize :longword read aSize;
            property   ReceiveTimeout :longword read aTimeout write aTimeout;
      end;


      BTSocketClient = class(_BTWSAconnect)
         private
//            aReadBuffer :pointer;
//            aSize :longword;
//            aTimeout :longword;
//            aResult :ansistring;
         public
            constructor Create; override;
            destructor Destroy; override;

//            property   GetResult :ansistring read aResult;
//            property   GetReadPTR :pointer read aReadbuffer;
//            property   GetReadSize :longword read aSize;
//            property   ReceiveTimeout :longword read aTimeout write aTimeout;
      end;


//      BTServerCallBack = function ( param :ansistring; userparam :longword; srv :BTSocketServer ) :ansistring; stdcall;
      BTSocketSession  = record
         ServerClass :pointer;
         hThread :longword;
         nSocket :longword;
         sMode :longword;
         sPerm :longword;
         RemoteAdr : string; //array [1..32] of ansichar;
         Callback :pointer;
         Callbackparm :longword;
         Reserved :longword;
      end;

      BTSocketServer = class(_BTWSAconnect)
         private
            aSMode :longword;    //
            aSTimeout :longword;
            aThread :longword;
            aCallback :pointer;
            aCallBackData :longword;
            aLeave :boolean;
            aSession:array [1..MAX_SERVERSESSIONS] of BTSocketSession;
            aTail :boolean;
            aTailBegin :longword;
            aTailEnd :longword;
         public
            constructor Create; override;
            destructor Destroy; override;
            function   Connect( ip_or_name :string; iPort :longword) :longint; override;
            procedure  SetListener( callback :pointer; callback_data :longword; tailbuf:boolean);
            property   SessionTimeout :longword read aSTimeout write aSTimeout;
            property   SessionDefMode :longword read aSMode write aSMode;
      end;

      BTServerCallBack = function ( const request :ansistring; var response :ansistring; userparam :longword; var srv :BTSocketSession ) :longint; stdcall;



implementation

const
   SD_RECEIVE     = 0; // some problem in fpc
   SD_SEND        = 1;
   SD_BOTH        = 2;


type BArray = array [0..0] of byte;

////////////////////////////////////////////////////////////////////////////////
//  C L I E N T ////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

//------------------------------------------------------------------------------
constructor _BTWSAconnect.Create;
begin
   aErr := 0;
   aWSAon := 0;

   aResult := '';
   aReadBuffer := @aResult[1];
   aSize := 0;
   aTimeout := 30000; // in miliseconds

   if WSAStartup(makeword(1,1){was 2},aWSA) <> 0 then aErr := -1;
   if aErr = 0 then aWSAon := 1;
end;

//------------------------------------------------------------------------------
destructor _BTWSAconnect.Destroy;
begin
   Disconnect;
   if aWSAon <> 0 then
   begin
      WSACleanup;
   end;
   inherited;
end;

//------------------------------------------------------------------------------
procedure  _BTWSAconnect._Reconnect;
begin
   self.Disconnect;
   self.Connect(aIp,aPort);
end;

//------------------------------------------------------------------------------
function   _BTWSAconnect.Connect( ip_or_name :string; iPort :longword) :longint;
var i,j:longint;
    aReadBuff :pointer; // for ansi string  TODO to optimize with ansistring
    aBuff:array[0..255] of byte;
begin
   aIp := ip_or_name;
   aPort := iPort;
   aErr := 0;

   areadBuff := @aBuff[0];
   if aWSAon = 1 then
   begin
      aSock := socket(PF_INET{was AF_INET},SOCK_STREAM,6);  //IPPROTO_IP = 0   IPPROTO_TCP = 6
      if aSock = INVALID_SOCKET then
      begin
         aErr := -2
      end else begin
         FillChar(aServer,SizeOf(aServer),0);

         aServer.sin_family := AF_INET;
         aServer.sin_port := htons(iPort);

         j := length(ip_or_name);
         for i := 0 to j - 1 do BArray(aReadBuff^)[i] := byte(ip_or_name[i+1]);
         BArray(aReadBuff^)[j] := 0;

         aHostEnt := gethostbyname(aReadBuff);
         if aHostEnt <> nil then
         begin
            with aHostEnt^ do
            begin
               aServer.sin_addr.S_un_b.s_b1 := h_addr^[0];
               aServer.sin_addr.S_un_b.s_b2 := h_addr^[1];
               aServer.sin_addr.S_un_b.s_b3 := h_addr^[2];
               aServer.sin_addr.S_un_b.s_b4 := h_addr^[3];
            end;
         end;

         if aMode = 0 then
         begin // client
            if winsock.Connect( aSock, aServer, SizeOf(aServer) ) = 0 then
            begin
               aWSAon := 2;
            end else begin
               aErr := -3;
            end;
         end else begin
            //server
            if winsock.Bind( aSock, aServer, SizeOf(aServer) ) = 0 then
            begin
               aWSAon := 2;
            end else begin
               aErr := -3;
            end;
         end;
      end;
   end;
   Result := aErr;
end;

//------------------------------------------------------------------------------
procedure  _BTWSAconnect.Disconnect;
begin
   if aWSAon = 2 then
   begin
      aWSAon := 1;
      shutdown(aSock, SD_BOTH);
      //if aSock <> INVALID_SOCKET then
      CloseSocket(aSock);
   end;
end;

//------------------------------------------------------------------------------
function   _BTWSAconnect.Send (p :pointer; len :longword) :longint;
var pas,t:longint;
begin
   aErr := -4;
   if aWSAon = 2 then
   begin
      if len > 0 then
      begin
         for pas := 0 to 1 do ///???? why I do this
         begin
            repeat
               t := winsock.Send(aSock, p^, len, 0); // send 8bit
               if (t > 0) and (longint(len) > t) then
               begin
                  p := pointer(longword(p)+longword(t));
                  dec(len,t);
               end;
            until (longint(len) = t) or (t < 0);
            if (t > 0) and (longint(len)= t) then aErr := 0;
            if (t <= 0) and (pas = 0) then
            begin
               _Reconnect; // Thid I need that  //TODO
               sleep(25);
               continue;
            end;
            if aErr = 0 then break;
         end;
      end;
   end else aErr := -15;
   Result := aErr;
end;

//------------------------------------------------------------------------------
function   _BTWSAconnect.Receive(BytesToRead:longword) :longint;
var t:longword;
    p :pointer;
    data:ansistring;
    err,e:longint;
    buf:array[0..8192] of byte;
begin
   aErr := 0;
   aResult := '';
   aSize := 0;
   if aWSAon = 2 then
   begin
      aResult := '';
      err := 0;
      repeat
//         t := 8192;
         e := recv(aSock,buf,8192,0);  // return byte recived
         if e < 0 then err := WSAGetLastError; // if <> 0 Error
         if e > 0 then
         begin // fill buffer
            SetLength(data,e);
            inc(aSize,e);
            p := @data[1];
            Move(buf,p^,e);
            aResult := aResult + data; // let delphi finish the realocation
            if e = 8192 then
            begin
               t :=0;
               if ioctlsocket(aSock, FIONREAD, integer(t)) = 0 then
               begin
                  if t <> 0 then Continue;  // more dtat to read;
               end;
            end;
            e := 0; //break
         end;
      until e <= 0; //if error < 0   = 0 finish
      aErr := err;
   end;
      (*


//      dn := 0;
//      for pas := 0 to 1 do
//      begin
         aResult := '';
         aSize := 0;
         t := 0;
         jc := GetTickCount;
         while (GetTickCount - jc) < aTimeout do
         begin
            if ioctlsocket(aSock, FIONREAD, integer(t)) <> 0 then
            begin
//               sleep(25);
//               jc := GetTickCount;
//               if pas = 0 then continue;
               aErr := -6;
               break;
            end;
            if (aSize <> 0) and (t = 0) then
            begin
//               dn := 1; //done
              break; // meaby the end
            end;
            if t <> 0 then
            begin
               j := aSize;
               aSize := aSize + t;
               SetLength(aResult,aSize);
               p := pointer(longword(@aResult[1]) + j);
               ic := recv(aSock, p^, t, 0);
               if ic = 0 then break ; //no more
               if longint(ic) = -1 then // disconect while read
               begin
//                  sleep(25);
//                  jc := GetTickCount;
//                  if pas = 0 then continue;
                  aErr := -6;
                  aSize := 0;
                  break;
               end;
            end;
            sleep(50);
         end;
//         if dn <> 0 then break;
//      end;
   end else aErr := -15;
   *)
   aReadBuffer := @aResult[1];
   Result := aErr;
end;

//------------------------------------------------------------------------------
function   _BTWSAconnect.SendReceive (p :pointer; len, BytesToRead :longword) :longint;
begin
   Result := Send(p,len);
   if Result = 0 then  Result := Receive(BytesToRead);
end;

//------------------------------------------------------------------------------
constructor BTSocketClient.Create;
begin
   inherited;
   aMode := 0;
//   aResult := '';
//   aReadBuffer := @aResult[1];
//   aSize := 0;
//   aTimeout := 30000; // in miliseconds
end;

//------------------------------------------------------------------------------
destructor BTSocketClient.Destroy;
begin
   Disconnect;
   inherited;
end;




////////////////////////////////////////////////////////////////////////////////
// S E R V E R /////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

function SessionManager(parm:longword):longint; stdcall;
var //srv:BTSocketServer;
    ses:^BTSocketSession;
    err,e,t,i:longint;
    res_data,request,data :ansistring;
    runer :BTServerCallBack;
    p:pointer;
    buf:array[0..8192] of byte;
begin
   Result := 0;
   ses := pointer(parm);
   if assigned(ses) then
   begin
      ses.sMode := 0;
      repeat
        //srv := BTSocketServer(ses^.ServerClass);
//   bDebug('d:\bdebug.log','Session begin',ses^.nSocket);
         request := '';
         err := 0;
         repeat
            e := recv(ses^.nSocket,buf,8192,0);  // return byte recived if time out return =0
            if e <= 0 then
            begin
               err := WSAGetLastError; // if <> 0 Error
               break; // err = 0 if timeout
            end;
            if e > 0 then
            begin // fill buffer
               SetLength(data,e);
               p := @data[1];
               Move(buf,p^,e);
               request := request + data; // let delphi finish the realocation
               if e = 8192 then
               begin
                  t :=0;
                  if ioctlsocket(ses^.nSocket, FIONREAD, integer(t)) = 0 then
                  begin
                     if t <> 0 then Continue;  // more data to read;
                  end;
               end;
               break;
            end;
         until e < 0; //if error < 0   = 0 finish
//   bDebug('d:\bdebug.log','Session read finish',ses^.nSocket);


         if (err = 0) and (e > 0) then
         begin // I have reques         res_data := '';
            if ses^.Callback <> nil then
            begin
               runer := BTServerCallBack(ses^.Callback);
               res_data := '';
               e := runer(request,res_data,ses^.CallBackParm,ses^); // execute
               if e = 0 then // noerr
               begin
                  i := length(res_data);
                  e := 1;
                  if i > 0 then
                  begin
                     repeat
                        p := @res_data[e];
                        t := winsock.Send(ses^.nSocket, p^, i, 0); // send 8bit
                        if (t > 0) and (i > t) then
                        begin
                           inc(e,t);
                           dec(i,t);
                        end;
                     until (i = t) or (t<0);
                     if t < 0 then
                     begin
                      //error
                     end;
                  end;
               end;  //TODO error
            end;
         end else begin
            break;   //Time out disconnect
         end;
//   bDebug('d:\bdebug.log','Session write finish',ses^.nSocket);

      until (ses^.sMode and 1 )= 0;  // if not keep alive



//      shutdown(ses.nSocket, SD_RECEIVE) ;//SD_BOTH); SD_SEND
      shutdown(ses^.nSocket, SD_BOTH);
{
      data :='AB';
      p := @data[1];
      repeat
         t := recv(ses.nSocket,p^,1,0);
      until (t <= 0);
}
      CloseSocket(ses^.nSocket);
      ses^.hThread := 0; //free thread
   end;
end;


function ServerRunner(parm:longword):longint; stdcall;
var srv:BTSocketServer;
    nSock :longword;
    nServer :TSockAddr;
//    nSAdr :TSockAddr;
    i,t:longword;
    p:pointer;
    hTreadID:longword;
begin
   Result := 0;
   srv := BTSocketServer(parm);
   if assigned(srv) then
   begin
      repeat  // MAIN SERVER LOOP
         sleep(25);
         if (srv.aWSAon = 2) and (srv.aErr = 0) then
         begin // ready bindet
            i := SizeOf(nServer);
            nSock := accept(srv.aSock, @nServer, @i );
            if nSock > 0 then
            begin
//               t := sizeof(TSockAddr);
//               getpeername(nSock,nSAdr,longint(t));
//               pc := inet_ntoa(nSAdr.sin_addr);
               t := 0;
               if srv.aTail then
               begin
                  // Use tail session methode    //TODO


               end else begin
                  //Use thread session methode
                  for i := 1 to MAX_SERVERSESSIONS do
                  begin
                     if srv.aSession[i].hThread = 0 then
                     begin
                        srv.aSession[i].nSocket := nSock;
                        srv.aSession[i].sPerm := 1;//1;      //TODO
                        srv.aSession[i].Callback := srv.aCallback;
                        srv.aSession[i].CallbackParm := srv.aCallbackData;
                        //TODO srv.aSession[i].RemoteAdr := nServer.sin_addr;
                        t := i;
                        break;
                     end;
                  end;
                  if t<>0 then
                  begin
//                bDebug('d:\bdebug.log','Create new session',nSock);
                     p := pointer(longword(@srv.aSession[1])  + (t-1)*sizeof(BTSocketSession));
                     hTreadID := 0;
                     srv.aSession[t].hThread := CreateThread(nil,0,@SessionManager,p,0,hTreadID);
                  end else begin
                     ////todo no free session
                  end;
               end;
            end;
         end;
      until srv.aLeave;
   end;
end;

//------------------------------------------------------------------------------
constructor BTSocketServer.Create;
var i:longword;
begin
   aTail := false;
   aLeave := false;
   aSTimeout := 30000;
   aSMode := 0;
   aTailBegin := 1;
   aTailEnd := 1;
   for i  := 0 to MAX_SERVERSESSIONS do
   begin
      aSession[i].ServerClass := self;
      aSession[i].hThread := 0;
   end;
   inherited
end;

//------------------------------------------------------------------------------
destructor BTSocketServer.Destroy;
var i:longword;
begin
   Disconnect;
   for i  := 0 to MAX_SERVERSESSIONS do
   begin
      if aSession[i].hThread <> 0 then
      begin
         shutdown(aSession[i].nSocket, SD_BOTH);
         CloseSocket(aSession[i].nSocket);
         TerminateThread(aSession[i].hThread,0);
      end;
   end;
   if aThread <> 0 then TerminateThread(aThread,0);
   inherited;
end;

//------------------------------------------------------------------------------
function   BTSocketServer.Connect( ip_or_name :string; iPort :longword) :longint;
var  aTreadID:longword;
begin
   aMode := 1;
   aErr := inherited Connect(ip_or_name,iPort);
   if aWSAon = 2 then
   begin
      aCallBack := nil;
      aCallbackData := 0;
      aTailBegin := 1;
      aTailEnd := 1;
      aThread := CreateThread(nil,0,@ServerRunner,self,0,aTreadID);
      if listen(aSock,100) < 0 then //error
      begin
         aErr := -11;
      end;
   end;
   Result := aErr;
end;

//------------------------------------------------------------------------------
procedure  BTSocketServer.SetListener (callback :pointer; callback_data :longword;  tailbuf:boolean);
begin
   aCallBack := callback;
   aCallBackData := callback_data;
   aTail := tailbuf;
   aTailBegin := 1;
   aTailEnd := 1;
end;



end.
