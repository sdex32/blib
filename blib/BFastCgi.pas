unit BFastCgi;

interface   // Fast CGI server

uses BCgi; // only fro BTCGI_data

type
   FastCGI_exe_proc = function(var parstr :BTCGI_Data; userData :pointer ):longint; stdcall;


procedure FastCGI_Execute(ListenPort :longword; wait :boolean;  call_back :FastCGI_exe_proc; userdata :pointer);
procedure FastCGI_Stop;



implementation

uses  Windows,BSocket;


const
      FCGI_BEGIN_REQUEST      = 1;  {head + BeginRequestBody}
      FCGI_ABORT_REQUEST      = 2;
      FCGI_END_REQUEST        = 3;
      FCGI_PARAMS             = 4;
      FCGI_STDIN              = 5;
      FCGI_STDOUT             = 6;
      FCGI_STDERR             = 7;
      FCGI_DATA               = 8;
      FCGI_GET_VALUES         = 9;
      FCGI_GET_VALUES_RESULT  =10;
      FCGI_UNKNOWN_TYPE       =11;


type
      TFC_struct = packed record
         b1 : byte;
         b2 : byte;
         b3 : byte;
         b4 : byte;
         b5 : byte;
         b6 : byte;
         b7 : byte;
         b8 : byte;
      end;
      PTFC_struct = ^TFC_struct;
      TByteArray = array [0..7] of byte;
      PTByteArray = ^TByteArray;
(*
// (Header)            (BeginRequestBody)    flags component of FCGI_BeginRequestBody
 1. version             1. roleB1              FCGI_KEEP_CONN  1
 2. type                2. roleB0
 3. requestIdB1         3. flags             role component of FCGI_BeginRequestBody
 4. requestIdB0                                FCGI_RESPONDER  1
 5. contentLengthB1                            FCGI_AUTHORIZER 2
 6. contentLengthB0                            FCGI_FILTER     3
 7. paddingLength
 8. reserved

{FCGI_BEGIN_REQUEST,   1, {FCGI_RESPONDER, 0}}
{FCGI_PARAMS,          1, "\013\002SERVER_PORT80\013\016SERVER_ADDR199.170.183.42 ... "}
{FCGI_PARAMS,          1, ""}
{FCGI_STDIN,           1, ""}

    {FCGI_STDOUT,      1, "Content-type: text/html\r\n\r\n<html>\n<head> ... "}
    {FCGI_STDOUT,      1, ""}
    {FCGI_END_REQUEST, 1, {0, FCGI_REQUEST_COMPLETE}}


  (EndRequestBody)
  1.appStatusB3;
  2.appStatusB2;
  3.appStatusB1;
  4.appStatusB0;
  5.protocolStatus;

protocolStatus component of FCGI_EndRequestBody
FCGI_REQUEST_COMPLETE 0
FCGI_CANT_MPX_CONN    1
FCGI_OVERLOADED       2
FCGI_UNKNOWN_ROLE     3

*)
      TFC_Session = record
         working   : boolean;
         param     : ansistring;
         stdin     : ansistring;
         CGID      : BTCGI_Data;
      end;




var FCServer :BTSocketServer;
    FC_call_back :FastCGI_exe_proc;
    FC_userdata :pointer;
    FC_Wait :boolean;
    FC_Sessions :array [1..8] of TFC_Session;


function FC_callback(param:ansistring; userparam:longword; var srv:BTSocketSession):ansistring; stdcall;
var fcs :PTFC_struct;
    ba :PTByteArray;
    pp,ss,ds :pointer;
    pc :pchar;
    done :boolean;
    plen,ppos,sid,i,pl,dl,j,tl :longword;
    s,s1:string;
    a,ae,res:ansistring;
begin
   Result := ''; // Response
   pp := @param[1];
   plen := length(param);
   if plen > 8 then
   begin
      // parse param for fast cgi structure
      done := false;
      ppos := 0;
      repeat
         fcs := pointer(longword(pp) + ppos);
         inc(ppos,8);

         case fcs.b2 of { struct type }
            FCGI_BEGIN_REQUEST : begin
               sid := (fcs.b3 shl 8) or fcs.b4; { requestIDBx }
               // server must control sessions
               if FC_Sessions[sid].working = false then
               begin
                  res := ''; { uses for sdtin and stout }
                  FC_Sessions[sid].working := true;
                  FC_Sessions[sid].param := '';
                  FC_Sessions[sid].stdin := '';

                  FC_Sessions[sid].CGID.AUTH_TYPE := '';
                  FC_Sessions[sid].CGID.CONTENT_TYPE := '';
                  FC_Sessions[sid].CGID.CONTENT_LENGTH := '';
                  FC_Sessions[sid].CGID.GATEWAY_INTERFACE := '';
                  FC_Sessions[sid].CGID.PATH_INFO := '';
                  FC_Sessions[sid].CGID.PATH_TRANSLATED := '';
                  FC_Sessions[sid].CGID.REMOTE_ADDR := '';
                  FC_Sessions[sid].CGID.REMOTE_HOST := '';
                  FC_Sessions[sid].CGID.REMOTE_IDENT := '';
                  FC_Sessions[sid].CGID.REMOTE_USER := '';
                  FC_Sessions[sid].CGID.REQUEST_METHOD := '';
                  FC_Sessions[sid].CGID.SCRIPT_NAME := '';
                  FC_Sessions[sid].CGID.SERVER_NAME := '';
                  FC_Sessions[sid].CGID.SERVER_PORT := '';
                  FC_Sessions[sid].CGID.SERVER_PROTOCOL := '';
                  FC_Sessions[sid].CGID.SERVER_SOFTWARE := '';
                  FC_Sessions[sid].CGID.HTTP_ACCEPT := '';
                  FC_Sessions[sid].CGID.HTTP_USER_AGENT := '';
                  FC_Sessions[sid].CGID.HTTP_REFERER := '';
                  FC_Sessions[sid].CGID.HTTP_COOKIE := '';

                  FC_Sessions[sid].CGID.RESPONSE := '';

                  // Header + BeginRequestBody
                  fcs := pointer(longword(pp) + ppos);
                  inc(ppos,8);
                  i := (fcs.b1 shl 8) or fcs.b2; { role }

                  srv.sMode := 1; {close con}
                  if fcs.b3 = 1 then { flags = FCGI_KEEP_CONN }
                  begin
                     srv.sMode := 0; {keep con}
                  end;
                  // role must be
                  if i <> 1 then // <> FCGI_RESPONDER
                  begin
                    //todo
                  end;


               end else begin
                  // error unfinished session
                  done := true;
               end;
               //padding ??? fock it in this block
            end;
            FCGI_ABORT_REQUEST : begin
               sid := (fcs.b3 shl 8) or fcs.b4; { requestIDBx }
               FC_Sessions[sid].working := false;
               done := true;
            end;
//            FCGI_END_REQUEST   : begin
//               // I am sending this
//            end;
            FCGI_PARAMS        : begin
               sid := (fcs.b3 shl 8) or fcs.b4; { requestIDBx }
               if FC_Sessions[sid].working = true then
               begin
                  tl := (fcs.b5 shl 8) or fcs.b6; { length }
                  if tl > 0  then
                  begin
                     tl := ppos + tl; // find end pos of scanning
                     // add
                     repeat
                        ba := pointer(longword(pp) + ppos);
                        j := 0;
                        // read parameter len
                        if (ba[j] and $80) <> 0 then // 4 byte
                        begin
                           pl := (longword(ba[j] and $7F) shl 24)
                              or (longword(ba[j+1])       shl 16)
                              or (longword(ba[j+2])       shl 8)
                              or  longword(ba[j+3]);
                           inc(j,4);
                        end else begin
                           pl := longword(ba[j]);
                           inc(j);
                        end;
                        // read value len
                        if (ba[j] and $80) <> 0 then // 4 byte
                        begin
                           dl := (longword(ba[j] and $7F) shl 24)
                              or (longword(ba[j+1])       shl 16)
                              or (longword(ba[j+2])       shl 8)
                              or  longword(ba[j+3]);
                           inc(j,4);
                        end else begin
                           dl := longword(ba[j]);
                           inc(j);
                        end;
                        inc(ppos,j);
                        pc := pointer(longword(pp) + ppos);
                        s := '';
                     //todo use move
                        for i := 1 to pl do
                        begin
                           s := s + pc^;
                           inc(pc);
                        end;
                        s1 := '';
                        for i := 1 to dl do
                        begin
                           s1 := s1 + pc^;
                           inc(pc);
                        end;
                        inc(ppos,pl+dl);
                        if s = 'AUTH_TYPE'         then FC_Sessions[sid].CGID.AUTH_TYPE := s1;
                        if s = 'CONTENT_TYPE'      then FC_Sessions[sid].CGID.CONTENT_TYPE := s1;
                        if s = 'CONTENT_LENGTH'    then FC_Sessions[sid].CGID.CONTENT_LENGTH := s1;
                        if s = 'GATEWAY_INTERFACE' then FC_Sessions[sid].CGID.GATEWAY_INTERFACE := s1;
                        if s = 'PATH_INFO'         then FC_Sessions[sid].CGID.PATH_INFO := s1;
                        if s = 'PATH_TRANSLATED'   then FC_Sessions[sid].CGID.PATH_TRANSLATED := s1;
                        if s = 'REMOTE_ADDR'       then FC_Sessions[sid].CGID.REMOTE_ADDR := s1;
                        if s = 'REMOTE_HOST'       then FC_Sessions[sid].CGID.REMOTE_HOST := s1;
                        if s = 'REMOTE_IDENT'      then FC_Sessions[sid].CGID.REMOTE_IDENT := s1;
                        if s = 'REMOTE_USER'       then FC_Sessions[sid].CGID.REMOTE_USER := s1;
                        if s = 'REQUEST_METHOD'    then FC_Sessions[sid].CGID.REQUEST_METHOD := s1;
                        if s = 'SCRIPT_NAME'       then FC_Sessions[sid].CGID.SCRIPT_NAME := s1;
                        if s = 'SERVER_NAME'       then FC_Sessions[sid].CGID.SERVER_NAME := s1;
                        if s = 'SERVER_PORT'       then FC_Sessions[sid].CGID.SERVER_PORT := s1;
                        if s = 'SERVER_PROTOCOL'   then FC_Sessions[sid].CGID.SERVER_PROTOCOL := s1;
                        if s = 'SERVER_SOFTWARE'   then FC_Sessions[sid].CGID.SERVER_SOFTWARE := s1;
                        if s = 'HTTP_ACCEPT'       then FC_Sessions[sid].CGID.HTTP_ACCEPT := s1;
                        if s = 'HTTP_USER_AGENT'   then FC_Sessions[sid].CGID.HTTP_USER_AGENT := s1;
                        if s = 'HTTP_REFERER'      then FC_Sessions[sid].CGID.HTTP_REFERER := s1;
                        if s = 'HTTP_COOKIE'       then FC_Sessions[sid].CGID.HTTP_COOKIE := s1;
                        if s = 'QUERY_STRING'      then FC_Sessions[sid].CGID.QUERY_STRING := res;
                     until ppos >= tl;
                //  end else begin
                //     // dont care for param end with zero length
                  end;
                  if fcs.b7 <> 0 then inc(ppos, fcs.b7); {padding}
               end;
            end;
            FCGI_STDIN         : begin
               sid := (fcs.b3 shl 8) or fcs.b4; { requestIDBx }
               if FC_Sessions[sid].working = true then
               begin
                  i := (fcs.b5 shl 8) or fcs.b6; { length }
                  if i > 0  then
                  begin
                     // add
                     SetLength(a,i);
                     ds := @a[1]; {dest}
                     ss := pp;
                     Move(ss^,ds^,i);
                     res := res + a; { acumulate }
                     inc(ppos, i); // to next record
                     if fcs.b7 <> 0 then inc(ppos, fcs.b7); {padding}
                  end else begin
                     // prepare result this is last message
                     i := length(res);
                     if i > 0 then
                     begin { I have stdin }
                        str(i,a);
                        FC_Sessions[sid].CGID.CONTENT_LENGTH := a;
                        FC_Sessions[sid].CGID.QUERY_STRING := res;
                     end;

                     FC_Sessions[sid].CGID.RES_CONTENT_TYPE := 'TEXT/HTML';
                     i := FC_call_back(FC_Sessions[sid].CGID, FC_userdata);
                     if i <> 0 then 
                     begin
//todo                     if i <> 0 then _ErrorHTML(CGI_Data,'user proc :)');
                     end;

                     a := 'CONTENT-TYPE: ' + FC_Sessions[sid].CGID.RES_CONTENT_TYPE+ #13#10;
                     res := a + #13#10 + FC_Sessions[sid].CGID.RESPONSE +#13#10;

                    //debug
//                     Res := 'Content-type: text/html'#13#10#13#10
//                          +'<HTML><HEAD><TITLE>B-CGI program interface</TITLE></HEAD>'
//                          + '<BODY>Hi first FCGI</BODY></HTML>';


                     a  := #1#6#0#0#0#0#0#0; // 3,4 = sid STDOUT begin
                                             // 5,6 = response size
                     a[3]  := char(fcs.b3);
                     a[4]  := char(fcs.b4);

                     i := length(Res);
                     pl := 0; { end marker }
                     tl := 0; { cut offset }
                     ss := @res[1]; {source}
                     repeat
                        dl := 0; { padding  -  round to 8 }
                        j := $FFFF;
                        if i < j then
                        begin
                           j := i; pl := 1;
                           dl := 8 - (j and 7);
                        end ;
                        SetLength(ae,j);
                        ss := pointer(longword(ss) + tl);
                        tl := tl + j;
                        ds := @ae[1]; {dest}
                        Move(ss^,ds^,j);
                        a[5] := char(j shr 8);
                        a[6] := char(j and $FF);
                        a[7] := char(dl);
                        if dl <> 0 then
                        begin
                           for j := 1 to dl do ae := ae + #0;

                        end;
                        Result := Result + a + ae;

                     until pl <> 0;

                     ae := #1#6#0#0#0#0#0#0  // 3,4 = sid    STDout end
                         + #1#3#0#0#0#0#0#0  // 11,12 = sid  END request
                         + #0#0#0#0#0#0#0#0; // status b3,b2,b1,b0
                                             // prot status = FCGI_REQUEST_COMPLETE 0
                                             // (3 reserved)
                     ae[3]  := char(fcs.b3);
                     ae[4]  := char(fcs.b4);
                     ae[11] := char(fcs.b3);
                     ae[12] := char(fcs.b4);

                     Result := Result + ae;
                     done := true;
                     FC_Sessions[sid].working := false; // the end free session
                     //Finish
                  end;
               end;
            end;
            FCGI_DATA          : begin
               //???????????????
               done := true; // unsuported
            end;
            FCGI_GET_VALUES    : begin
               //???????????????
               done := true; // unsuported
            end;
            else begin
                done := true; // unsuported
            end;
         end; // case

      until done or (ppos >= plen);


   end;
end;


procedure FastCGI_Execute(ListenPort :longword; wait :boolean; call_back :FastCGI_exe_proc; userdata :pointer);
var i :longword;
begin
   for i := 1 to 8 do FC_Sessions[i].working := false;
   if not assigned(call_back) then Exit;

   FC_call_back := call_back;
   FC_userdata := userdata;
   FCServer := BTSocketServer.Create;
   if FCServer.Connect('0.0.0.0',ListenPort) = 0 then
   begin
      FCServer.SetListener(@FC_callback, 0, false);
      FC_Wait := wait;
      if wait then
      begin // loop here
         repeat
            sleep(10);
         until (not FC_Wait);
      end;
   end;
end;

procedure FastCGI_Stop;
begin
   if assigned(FCServer) then
   begin
      FC_Wait := false;
      sleep(50);
      FCServer.free;
      FCServer := nil;
   end;
   
end;




begin
  FCServer := nil;
end.
