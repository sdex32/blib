unit BWebSocketSrvExt;

interface

uses BHTTPServer, BSocket, BStrTools, BBase64, BSHA1hash;


function WebSocketExt(data :BTHTTP_Data; UserParm :longword; var srv:BTSocketSession) :ansistring; stdcall;




implementation

//------------------------------------------------------------------------------
function ws_callback(param:ansistring; userparam:longword; var srv:BTSocketSession):ansistring; stdcall;
var  w,opc:longword;
     last:boolean;
     mask:boolean;
     Payload:longword;
begin
   last := false;
   mask := false;

   if (w and 1) <> 0  then last := true; // last block
   opc := (w and $F0) shr 4; // opcode
   if (w and $100) <> 0 then mask := true;
   Payload := (w and $FE00) shr 9;


end;

//------------------------------------------------------------------------------
function WebSocketExt(data :BTHTTP_Data; UserParm :longword; var srv:BTSocketSession) :ansistring; stdcall;
var key:ansistring;
begin
   Result := '';
   if length(data.upgr) > 1 then
   begin
      if UpperCase(data.upgr) = 'WEBSOCKET' then
      begin
         if UpperCase(data.conn) = 'UPGRADE' then
         begin // I have request to open WebSocket
            key := data.wskey + '258EAFA5-E914-47DA-95CA-C5AB0DC85B11';
            key := SHA1hash(@key[1],length(key));
            Result := 'HTTP/1.1 101 Switching Protocols' + #13#10
                    + 'Upgrade: websocket' + #13#10
                    + 'Connection: Upgrade' + #13#10
                    + 'Sec-WebSocket-Accept:'+ BCodeBase64(Key)
                    + #13#10#13#10;
            srv.Callback := @ws_callback; // change callback
            srv.sMode := 0; // dont close connection
            Result := 'WS_SET'; // set marker to HTTP Server
         end;
      end;
   end;
end;

end.
