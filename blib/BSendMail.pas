unit BSendMail;

interface



function SendMail(const sm_MailServerIP,sm_From,sm_To,sm_Subject,sm_Message,sm_AttFileName:string; sm_AttData:pointer; sm_AttSize:longword):longint;



implementation

uses BSocket, BBase64;

const bound:ansistring = 'deadbeef3574';

function SendMail(const sm_MailServerIP,sm_From,sm_To,sm_Subject,sm_Message,sm_AttFileName:string; sm_AttData:pointer; sm_AttSize:longword):longint;
var Net:BTSocketClient;
    s,sb:Ansistring;
    ii,jj:longword;
    p,p1:pointer;

    function _ECode:longword;
    var s:string;
        i,j:longword;
    begin
       Result := 0;
       i := length(Net.GetResult);
       s := '000';
       if i > 3 then
       begin
          for j:= 1 to 3 do s[j] := char(Net.GetResult[j]);
          val(s,Result,i);
       end;
    end;

    procedure _SendRecv(const a:ansistring);
    begin
       Net.Send(@a[1],length(a));
       Net.Receive(0);
    end;

begin
   Result := -1;
   Net := BTSocketClient.Create;
   Net.ReceiveTimeout := 60000; // first pause of server is big
   if Net.Connect(sm_MailServerIP,25)  = 0 then     // 25, 587
   begin
      Net.Receive(0);
      if _ECode = 220 then
      begin
         _SendRecv('HELO amailsender.net' + #13#10);
         if _ECode = 235 then
         begin
            _SendRecv('AUTH LOGIN'+#13#10);
            if _ECode = 234 then
            begin
               _SendRecv(BCodeBase64('password')+#13#10);
               if _ECode = 220 then
               begin
                   // ok
               end
            end;
         end;

         if _ECode = 250 then
         begin
            _SendRecv('MAIL FROM: <'+ansistring(sm_From)+'>' + #13#10);
            if _ECode = 250 then
            begin
               _SendRecv('RCPT TO: <'+ansistring(sm_To)+'>' + #13#10);
               if _ECode = 250 then
               begin
                  _SendRecv('DATA' + #13#10);
                  if _ECode = 354 then
                  begin
                     s := 'Subject: '+ansistring(sm_Subject)+#13#10
                        + 'From: '+ansistring(sm_From)+ #13#10
                        + 'To: '+ansistring(sm_To)+ #13#10;

                     if (sm_AttFileName  <> '') and (sm_AttSize <> 0) then
                     begin  // message with attachment (only 1 attachment :( use zip)
                        s := s + 'MIME-Version: 1.0' + #13#10
                           + 'Content-Type: multipart/mixed; boundary="' + bound +'"'+#13#10
                           + #13#10 + '--' + bound + #13#10
                           + 'Content-Type: text/plain' + #13#10
                           + 'Content-Transfer-Encoding: 7bit'+#13#10
                           + #13#10 + ansistring(sm_Message)+ #13#10
                           + '--' + bound + #13#10;

                        sb := '';
                        ii := Pos('.', sm_AttFileName);// + PathDelim + DriveDelim, FileName);
                        if (ii > 0) and (sm_AttFileName[ii] = '.') then  sb := Copy(sm_AttFileName, ii + 1, 3);

                        s := s +'Content-Type: ' + sb + '; name="' + sm_AttFileName + '"'+#13#10
                           + 'Content-Transfer-Encoding: base64'+#13#10
                           + 'Content-Disposition: attachment; filename="' + sm_AttFileName + '"'#13#10#13#10;

                        setlength(sb,57);
                        jj := 1;
                        ii := 57; //mime string size
                        p := @sb[1];
                        while ii = 57 do
                        begin
                           jj := jj + 57;
                           if jj > sm_AttSize then ii := 58 - (jj - sm_AttSize);
                           if ii <> 0 then
                           begin
                              p1 :=pointer(longword(sm_AttData) + jj - 58);
                              if ii < 57 then
                              begin
                                 setlength(sb,ii);
                                 p := @sb[1];                                 
                              end;
                              Move(p1^,p^,ii);
                              if ii < 57 then sb[ii+1]:=#0;
                              s := s + BCodeBase64(sb) + #13#10;
                           end;
                        end;
                        s := s + #13#10 + '--' + bound + '--' +#13#10;
                     end else begin
                        // Only message
                        s := s + ansistring(sm_Message)+ #13#10;
                     end;


                     s := s +'.'+#13#10;
                     _SendRecv(s);
                     if _ECode = 250 then
                     begin
                        _SendRecv('QUIT' + #13#10);
                        if _ECode = 221 then
                        begin
                           Result := 0; //OK
                        end;
                     end;
                  end;
               end;
            end;
         end;
      end;
      Net.Disconnect;
   end else Result := -2;
   Net.Free;
end;


end.
