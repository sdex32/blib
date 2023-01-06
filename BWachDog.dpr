program BWachDog;

{$APPTYPE CONSOLE}
{$IFDEF FPC}
{$MODE DELPHI}
{$ENDIF}



uses
  BService in 'E:\copy_old_disk_d\zwork\win32\blib\BService.pas',
  BIniFile in 'E:\copy_old_disk_d\zwork\win32\blib\BIniFile.pas',
  BFileTools in 'E:\copy_old_disk_d\zwork\win32\blib\BFileTools.pas',
  BStrTools in 'E:\copy_old_disk_d\zwork\win32\blib\BStrTools.pas',
  BExecute in 'E:\copy_old_disk_d\zwork\win32\blib\BExecute.pas';

const service_name:AnsiString = 'BeWachDog';



procedure _Process(work_mode_srv:boolean);
var fn:string;
    sa,d:ansistring;
    sini:string;
    s,sp,sf,sc:string;
    i,j,f:longword;
    start:boolean;
begin
   fn := ExtractFilePath(GetMyFileName) + ExtractFileName(GetMyFileName) + '.ini';
   if FileExist(fn) then
   begin
      if FileLoad(fn,sa) then
      begin
         sini := string(sa);
         if Ini_RawReadKey(sini,'WachDog','Cnt','nop',s) then
         begin
            i := ToVal(s);
            if i > 0 then
            begin
               for j := 1 to i do
               begin
                  Ini_RawReadKey(sini,'WachDog','Proc'+ToStr(j),'nop',s);
                  Ini_RawReadKey(sini,'WachDog','Proc'+ToStr(j)+'p','nop',sp);
                  Ini_RawReadKey(sini,'WachDog','Proc'+ToStr(j)+'f','nop',sf);
                  Ini_RawReadKey(sini,'WachDog','Proc'+ToStr(j)+'c','nop',sc);
                  if sp = 'nop' then sp := '';
                  if sf = 'nop' then sf := '';
                  if sc = 'nop' then sc := '';
                  if s <> 'nop' then
                  begin
                     if work_mode_srv then
                     begin

                        start := true;
                        // test for exist
                        if sf = 'PE' then // param exist
                        begin
                           if ProcessExists(s,sp,$4,f) then start := false;
                        end else begin
                           if sf = 'CN' then
                           begin

                           end else begin
                              if ProcessExists(s,'',0,f) then start := false;
                           end;
                        end;
                        // start if need
                        if start then
                        begin
                           sa :='';
                           d := '';
                           ExecuteFile(s,sp,True,false,false,'',sa,d);
                        end;
                     end else begin
                        // kill all
                        ProcessExists(s,'',$80000000,f); //Kill
                     end;
                  end;
               end;
            end;
         end;
      end;
   end;
end;


procedure ServiceTask;
begin
   _Process(true);
end;

procedure OnStop;
begin
   _Process(false); // kill al childs on stop
end;


procedure OnInstall;
var fn:string;
    sa:ansistring;
begin
   fn := ExtractFilePath(GetMyFileName) + ExtractFileName(GetMyFileName) + '.ini';
   if not FileExist(fn) then
   begin
      writeln('Configuration ini file is missed, we create demo one and you have to fill it');
      sa := '[WachDog]'+#13#10+'Cnt=1'+#13#10+'Proc1=notepad.exe';
      FileSave(fn,sa);
   end;
end;




begin


  // service                                   2sec   Insatll    Uninstall   Start  Stup
  Execute_Service(@Service_name, @ServiceTask, 2000, @OnInstall, nil,        nil  , @OnStop);

end.
