program BeWDog;

{$APPTYPE CONSOLE}

uses
  BService in 'BService.pas',
  BFileTools in 'BFileTools.pas',
  BRegistry in 'BRegistry.pas',
  BIniFile in 'BIniFile.pas',
  BStrTools in 'BStrTools.pas',
  BExecute in 'BExecute.pas';

const service_name:AnsiString = 'i3KalmarServer';

//warning HKEY_LOCAL_MACHINE because service run on different user
//?? is that true

procedure ServiceTask;
var j,k:longword;
    ss,ss2:string;
    ds:AnsiString;
begin
//BDebug('acc.log','inside',0);
   Reg_ReadKeyDW(HKEY_LOCAL_MACHINE,'Software\BeWatchDog','Count',k);
//BDebug('acc.log','count',k);
   if k > 0 then
   begin
      for j :=1 to k do
      begin
         Reg_ReadKey(HKEY_LOCAL_MACHINE,'Software\BeWatchDog','Dog'+ToStr(j),ss);
         Reg_ReadKey(HKEY_LOCAL_MACHINE,'Software\BeWatchDog','Dog'+ToStr(j)+'p',ss2);
//BDebug('acc.log','Call',k);
         if not ProcessExists(ss,'',false) then
         begin
//BDebug('acc.log','Exec',k);
            ExecuteFile(ss,ss2,true,false,true,'','',ds);
         end;
      end;
   end;
end;




procedure OnStop;
var j,k:longword;
    ss:String;
begin
   Reg_ReadKeyDW(HKEY_LOCAL_MACHINE,'Software\BeWatchDog','Count',k);
   if k > 0 then
   begin
      for j :=1 to k do
      begin
         Reg_ReadKey(HKEY_LOCAL_MACHINE,'Software\BeWatchDog','Dog'+ToStr(j),ss);
         ProcessExists(ss,'',true);
      end;
   end;
end;


procedure OnInstall;
var   i,WatchCount:longword;
      s:string;
begin
   if (paramcount = 2)  then
   begin
      // load int file
      if FileExist(paramstr(2)) then
      begin
      Ini_ReadKeyDW(paramstr(2),'WatchDog','Count',0,WatchCount);
      Reg_WriteKeyDW(HKEY_LOCAL_MACHINE,'Software\BeWatchDog','Count',WatchCount);
         if WatchCount > 0  then
         begin
            for i := 1 to WatchCount do
            begin
               Ini_ReadKey(paramstr(2),'WatchDog','Dog'+ToStr(i),'NOP',s);
               if s <> 'NOP' then
               begin
                  Reg_WriteKey(HKEY_LOCAL_MACHINE,'Software\BeWatchDog','Dog'+ToStr(i),s);
                  Ini_ReadKey(paramstr(2),'WatchDog','Dog'+ToStr(i)+'_parm','',s);
                  Reg_WriteKey(HKEY_LOCAL_MACHINE,'Software\BeWatchDog','Dog'+ToStr(i)+'p',s);
                  Writeln('Installed OK');
               end;
            end;
         end;
      end else begin
         Writeln('Need init file');
         Halt;
      end;
   end else begin
      Writeln('Need init file');
      Halt;
   end;
end;

procedure OnUninstall;
begin
   Reg_DeleteAll(HKEY_LOCAL_MACHINE,'Software\BeWatchDog');
   Writeln('UnInstalled OK');
end;



begin
   // service
   Execute_Service(@Service_name,@ServiceTask,2000,
    @OnInstall,@OnUninstall,nil,@OnStop);
end.
