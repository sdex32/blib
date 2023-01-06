unit BFireBirdSqlSetup;

interface

var FBSQLserver_instance :longword; // static for all instace of dll in memory

function  FireBirdSQL_Setup(const BinPath,DSNname,Usr,Pwd,DataBaseFile:string; var EnginePath:string):longint;
function  FireBirdSQL_Setup_Install_Srv(const EnginePath:string) :longint;
function  FireBirdSQL_Setup_Uninstall_Srv(const EnginePath:string) :longint;
function  FireBirdSQL_Setup_StartEngine(const EnginePath:string):longint;
procedure FireBirdSQL_Setup_StopEngine(EnginePath:string);
function  FireBirdSQL_Setup_Ping(const aDSN,aUSR,aPWD:string):boolean;


implementation

uses BRegistry,BFileTools,BExecute,BTinyODBC;


//------------------------------------------------------------------------------
function  FireBirdSQL_Setup(const BinPath,DSNname,Usr,Pwd,DataBaseFile:string; var EnginePath:string):longint;
var KeyPath:string;
    OdbcDrvPath,ClientPath:string;
begin
   Result := 0;

   // Test is there FireBird instaled in the system
   EnginePath := BinPath + '\instsvc.exe';
   OdbcDrvPath := BinPath + '\OdbcFb.dll';
   ClientPath := BinPath + '\fbclient.dll';
   if FileExist(EnginePath) then
   begin
      if not FileExist(OdbcDrvPath) then Result := -2
   end else Result := -2;

   if Result <> 0 then Exit;

   // Create ODBC DSN
   //[HKEY_CURRENT_USER\Software\ODBC\ODBC.INI\KalmarSQL]
   KeyPath := 'Software\ODBC\ODBC.INI\'+DSNname;
   //"Driver"="e:\\fire\\bin\\OdbcFb.dll"
   if not Reg_WriteKey(HKEY_CURRENT_USER,KeyPath,'Driver',ODBCDrvPath) then Result := -1;
   //"Setup"="e:\\fire\\bin\\OdbcFb.dll"
   if not Reg_WriteKey(HKEY_CURRENT_USER,KeyPath,'Setup',ODBCDrvPath) then Result := -1;
   //"Description"="Fire bird test"
   if not Reg_WriteKey(HKEY_CURRENT_USER,KeyPath,'Description','i3Kalmar database') then Result := -1;
   //"DSN"="fbdb"
   if not Reg_WriteKey(HKEY_CURRENT_USER,KeyPath,'DSN',DSNname) then Result := -1;
   //"Client"="e:\\fire\\bin\\fbclient.dll"
   if not Reg_WriteKey(HKEY_CURRENT_USER,KeyPath,'Client',ClientPath) then Result := -1;
   //"CharSet"="UNICODE_FSS"
   if not Reg_WriteKey(HKEY_CURRENT_USER,KeyPath,'CharSet','UNICODE_FSS') then Result := -1;
   //"Dialect"="3"
   if not Reg_WriteKey(HKEY_CURRENT_USER,KeyPath,'Dialect','3') then Result := -1;
   //"User"="SYSDBA"
   if not Reg_WriteKey(HKEY_CURRENT_USER,KeyPath,'User',usr) then Result := -1;
   //"Password"="masterkey"
   if not Reg_WriteKey(HKEY_CURRENT_USER,KeyPath,'Password',pwd) then Result := -1;
   //"DBname"="e:\\fire\\data\\Kalmar.fdb"
   //"DBname"="10.252.10.14/3050:e:\\help.fdb"
   if not Reg_WriteKey(HKEY_CURRENT_USER,KeyPath,'DBname',DatabaseFile) then Result := -1;

   //[HKEY_CURRENT_USER\Software\ODBC\ODBC.INI\ODBC Data Sources]
   //"KalmarSQL"="KalmarSQL"
   KeyPath := 'Software\ODBC\ODBC.INI\ODBC Data Sources';
   if not Reg_WriteKey(HKEY_CURRENT_USER,KeyPath,DSNname,DSNname) then Result := -1;
end;

//------------------------------------------------------------------------------
function    FireBirdSQL_Setup_Install_Srv(const EnginePath:string) :longint;
var s:ansistring;
begin
   Result := 0;
   if ExecuteFile(EnginePath,'-auto -superserver -guardian -z -n',true,true,true,'','',s) <> 0 then Result := -3;
end;

//------------------------------------------------------------------------------
function    FireBirdSQL_Setup_Uninstall_Srv(const EnginePath:string) :longint;
var s:ansistring;
begin
   Result := 0;
   ExecuteFile(EnginePath,'remove -z -n',true,true,true,'','',s);
end;

//------------------------------------------------------------------------------
function    FireBirdSQL_Setup_StartEngine(const EnginePath:string):longint;
var s:ansistring;
begin
   Result := 0;
   if ExecuteFile(EnginePath,'start -n',true,true,true,'','',s) <> 0 then Result := -3;
   if Result = 0 then inc(FBSQLserver_instance);
end;

//------------------------------------------------------------------------------
procedure   FireBirdSQL_Setup_StopEngine(EnginePath:string);
var s:ansistring;
begin
   if length(EnginePath) > 1 then
   begin
     if FBSQLserver_instance <> 0 then dec(FBSQLserver_instance);
     if FBSQLserver_instance = 0 then
     begin
        ExecuteFile(EnginePath,'stop -n',true,true,true,'','',s);
     end;
   end;
end;

//------------------------------------------------------------------------------
function    FireBirdSQL_Setup_Ping(const aDSN,aUSR,aPWD:string):boolean;
var o:BTTinyODBC;
begin
   Result := false; // fail
   o := BTTinyODBC.Create;
   o.Open(aDSN,aUSR,aPWD);
   if o.SqlCode = 0 then
   begin
      o.Execute('select count(*) from pbcatcol');
      if o.SqlCode = 0 then Result := true;
      o.Close;
   end;
   o.Free;
end;


begin
  FBSQLserver_instance := 0;
end.
