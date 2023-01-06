program wdog;

{$APPTYPE CONSOLE}

uses
  BService in 'BService.pas',
  BExecute in 'BExecute.pas',
  BFileTools in 'BFileTools.pas',
  BRegistry in 'BRegistry.pas',
  BIniFile in 'BIniFile.pas',
  BStrTools in 'BStrTools.pas';
//  BLogFile in 'BLogFile.pas';

const service_name:AnsiString = 'P1_aware';
//const registry_key:string = '.DEFAULT\Software\BeWatchDogP1';

//warning HKEY_LOCAL_MACHINE because service run on different user
// HKEY_LOCAL_MACHINE delete windows 10 no write permision use HKEY_USERS !!! :)
// i will use INI file work perfect :)
//<<< important >>> must be with the same name as exe

{ -- ini file example
[WatchDog]
Count=1
Dog1=h:\boc\internet\web_server\tiny.exe
Dog1p=c:\root
}





function get_inifile(var DogsCount:longword):string;
var ss,ss2:string;
    a:ansistring;
begin

   Result := '';
   ss := GetMyFileName;
   ss2 := ExtractFilePath(ss) + ExtractFileName(ss)+'.ini';
   if FileExist(ss2) then
   begin
      if FileLoad(ss2,a) then
      begin
         Result := string(a);
         Ini_RawReadKey(Result,'WatchDog','Count','0',ss);
         DogsCount := ToVal(ss);
      end;
   end;
end;


procedure ServiceTask;
var j,k:longword;
    ss,ss2,r:String;
    a,b:ansistring;
//    Log:BTLogFile;
begin
//Log := BTLogFile.create('d:\log.log');
//log.Log('inside',0);
   r := Get_inifile(k);
//log.Log('count '+ss,k);
   if k > 0 then
   begin
      for j :=1 to k do
      begin
         Ini_RawReadKey(r,'WatchDog','Dog'+ToStr(j),'NOP',ss);
         Ini_RawReadKey(r,'WatchDog','Dog'+ToStr(j)+'p','NOP',ss2);
//log.Log('dog '+ss +' <> '+ss2,k);
         if ss <> 'NOP' then
         begin
//log.Log('test process' +ss,0);
            if not ProcessExists(ss,'',false) then
            begin
//log.log('Exec',k);
               ExecuteFile(ss,ss2,true,false,false,'',a,b);
            end;
         end;
      end;
   end;
//Log.Free;
end;




procedure OnStop;
var j,k:longword;
    ss,r:String;
begin
   r := Get_inifile(k);
   if k > 0 then
   begin
      for j :=1 to k do
      begin
         Ini_RawReadKey(r,'WatchDog','Dog'+ToStr(j),'NOP',ss);
         ProcessExists(ss,'',true);
      end;
   end;
end;


procedure OnInstall;
var   i:longword;
      s:string;
begin
   if (paramcount = 1)  then
   begin
      s := get_inifile(i);
      if i = 0 then
      begin
         Writeln('Need init file');
         Halt;
      end;
   end;
end;

procedure OnUninstall;
begin
//   Reg_DeleteAll(HKEY_USERS,registry_key);
end;



begin
   // service
   Execute_Service(@Service_name,@ServiceTask,2000,
    @OnInstall,@OnUninstall,nil,@OnStop);
end.
