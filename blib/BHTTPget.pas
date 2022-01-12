unit BHTTPget;

interface

{$IFNDEF FPC }
{$IFDEF RELEASE}
{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([]) }
{$ENDIF}
{$ENDIF}


function HTTP_Get(const URL :ansistring; var RES :ansistring) :longint;
// HTTP_Post can be used as RESTful call
function HTTP_Post(const URL :ansistring; var RES :ansistring) :longint;


implementation

uses BSocket,BStrTools;


//------------------------------------------------------------------------------
const http:ansistring='http://';



function _Sender(GP:longword; const URL:ansistring; var RES:ansistring) :longint;
var Socket :BTSocketClient;
    DataToSend :ansistring;
    Host,Temp :ansistring;
    i,k :longint;
    j :longint;
    p :pointer;
    c :ansichar;
    Port:longword;
    s:string;
begin
   Result := -1; // fail
   Port := 80;
   Socket := BTSocketClient.Create;
   Host := '';
   j := length(URL);
   Temp := '';
   for i := 1 to j do // trim
   begin
      c := URL[i];
      if c in [#1..#32] then continue;
      if c = '\' then c:='/';
      Temp := Temp + c;
   end;
   j := length(Temp);
   if j > 1 then
   begin
      k:=0;
      if j > 7 then for i := 1 to 7 do // test for http in front
      begin
         if http[i] = Temp[i] then inc(k);
      end;
      if k <> 7 then Temp := http + Temp; // add http in front if need
      j := length(Temp);
      for i := 8 to j do // get host
      begin
         c := Temp[i];
         if c= '/' then break;
         Host := Host + c;
      end;

      // prepare send string
      if GP = 0 then DataToSend := 'GET '
                else DataToSend := 'POST ';

      DataToSend := DataToSend  + Temp + ' HTTP/1.1' + #13#10 +
                    'Host: ' + Host + #13#10 +
//                    'Accept: *.*' + #13#10  +
                    'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' + #13#10  +
                    'Connection: keep-alive' + #13#10  +
                    'User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64)' + #13#10#13#10;
      if GP = 1 then
      begin
         j := length(RES);
         if j < 1 then Exit; //nothing to send
         str(j,temp);
         j := length(DataToSend);
         if pos('<?xml',string(RES)) <> 0 then host := 'text/xml'
                                          else host := 'text/txt';
         // skil last #13#10
         DataToSend[j-1] := 'C';
         DataToSend[j]   := 'o';
         DataToSend := DataToSend + 'ntent-Type: '+host+#13#10 +
                                    'Content-Length: '+ temp+#13#10+ RES + #13#10#13#10;
      end;

      j := pos(':',string(Host));
      if j <> 0 then
      begin
         Temp := Copy(Host,j+1,length(Host) - j);
         Host := Copy(Host,1,j-1);
         val(string(Temp),Port,j);
      end;

      Res := '';

      if Socket.Connect(string(Host),Port) = 0  then
      begin
         j := length(DataToSend);
         p := @DataToSend[1];
         Socket.Send(p,j);


         if Socket.Receive(0) = 0 then
         begin
            if Socket.GetReadSize > 0 then
            begin
               Temp := Socket.GetResult;
               s := string(Temp);
               i := 0;
               if Pos('200 OK',s) <> 0 then i := 1;
//               if Pos('302 Found',string(Temp)) <> 0 then i := 1;
               if i = 1 then // have result
               begin
                  Result := -3;
                  j := Pos(#13#10#13#10,s); // Get the end of http header
                  if j <> 0 then
                  begin
                     s := LowerCase(MidStr(s,1,j));
                     i := Pos('content-length',s);
                     s := MidStr(s,i+14,j-i+14+1);
                     s := ParseStr(s,0,#13);
                     s := ParseStr(s,1,':');
                     i := ToVal(s);
                     inc(j,4);
                     if i = length(Temp) - j + 1 then // ok
                     begin







                     SetLength(Res,i);
                     Res := Copy(Temp, j, i);
//                     Res := Host;
//todo content len and length(host) test
                     Result := 0; //Ok

                     end;
                  end;
               end else begin
                  Result := -2;
               end;
            end;
         end;
         Socket.Disconnect;
      end;
   end;
   Socket.Free;
end;


function HTTP_Post(const URL :ansistring; var RES :ansistring) :longint;
begin
   Result := _Sender(1,URL,RES);
end;


function HTTP_Get(const URL :ansistring; var RES :ansistring) :longint;
begin
   Result := _Sender(0,URL,RES);
end;

end.
