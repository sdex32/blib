unit BRegistry;

interface

const
  HKEY_CLASSES_ROOT     = $80000000;
  HKEY_CURRENT_USER     = $80000001;
  HKEY_LOCAL_MACHINE    = $80000002;
  HKEY_USERS            = $80000003;
  HKEY_PERFORMANCE_DATA = $80000004;
  HKEY_CURRENT_CONFIG   = $80000005;

function Reg_WriteKey(root:longword; const KeyPath,KeyName,Data:string):boolean;
function Reg_ReadKey(root:longword; const KeyPath,KeyName:string; var Data:string):boolean;
function Reg_WriteKeyDW(root:longword; const KeyPath,KeyName:string; Data:longword):boolean;
function Reg_ReadKeyDW(root:longword; const KeyPath,KeyName:string; var Data:longword):boolean;
function Reg_DeleteAll(root:longword; const KeyPath:string):boolean;
function Reg_DeleteKey(root:longword; const KeyPath,KeyName:string):boolean;

implementation
uses windows,BStrTools;

//------------------------------------------------------------------------------
function _OpenCreate(root:longword; const KeyPath:string; mode:longword):HKEY;
var hk:HKEY;
    st:longint;
begin
   st := RegOpenKeyEx(root,@KeyPath[1],0,KEY_READ or KEY_WRITE  or KEY_WOW64_64KEY,hk);      // KEY_ALL_ACCESS
   if ({(st = ERROR_NOT_MATCH) or }(st = ERROR_FILE_NOT_FOUND)) then
   begin // not exist create
      if mode = KEY_WRITE then
      begin
         st := RegCreateKeyEx(root,@KeyPath[1],0,Nil,REG_OPTION_NON_VOLATILE,KEY_READ or KEY_WRITE or KEY_WOW64_64KEY,nil,hk,nil);
          if st <> ERROR_SUCCESS then hk := 0;
      end else hk := 0;
   end;
   _OpenCreate := hk;
end;

//------------------------------------------------------------------------------
function Reg_WriteKey(root:longword; const KeyPath,KeyName,Data:string):boolean;
var hk:HKEY;
    st:longint;
    ada,kn:ansistring;
begin
   ada := ansistring(Data + #0);
   kn := ansistring(KeyName + #0);
   Result := false;

//   RegOpenKeyEx(root,@KeyPath[1],0,KEY_WRITE  or KEY_WOW64_64KEY ,hk);
//   st := RegOpenKeyEx(root,@KeyPath[1],0,KEY_WRITE or KEY_READ or KEY_WOW64_64KEY,hk);
   hk := _OpenCreate(root,KeyPath,KEY_WRITE);
   if hk = 0 then Exit;
   st := RegSetValueExA(hk,@KN[1],0,REG_SZ,@ada[1],length(ada));
   if st = 0 then Result := true; //OK
   RegCloseKey(hk);
end;

//------------------------------------------------------------------------------
function Reg_ReadKey(root:longword; const KeyPath,KeyName:string; var Data:string):boolean;
var hk:HKEY;
    st:longint;
    tp,ss:longword;
    ada,kn:ansistring;
begin
   kn := ansistring(KeyName+#0);
   Data := '';
   Result := false;
   RegOpenKeyEx(root,@KeyPath[1],0,KEY_READ or KEY_WOW64_64KEY,hk);    // need 6464 to read HLM
//   hk := _OpenCreate(root,KeyPath,KEY_READ);
   if hk = 0 then Exit;
   // key exist so read it
   tp := REG_SZ;
   ss := 0;
   st := RegQueryValueEx(hk,@KeyName[1],nil,@tp,nil,@ss);
   data := '';
   if st = 0 then
   begin
      SetLength(ada,ss);
      st := RegQueryValueExA(hk,@KN[1],nil,@tp,@ada[1],@ss);
      if st = 0 then
      begin
         if ada[ss]=#0 then SetLength(ada,ss-1);
         Data := string(ada);
         Result := true; //OK
      end;
   end;
   RegCloseKey(hk);
//   Data := string(aData);
end;

//------------------------------------------------------------------------------
function Reg_WriteKeyDW(root:longword; const KeyPath,KeyName:string; Data:longword):boolean;
var hk:HKEY;
    st:longint;
    kn:ansistring;
begin
   kn := ansistring(KeyName+#0);
   Result := false;
//   st := RegOpenKeyEx(root,@KeyPath[1],0,KEY_ALL_ACCESS or KEY_WRITE or KEY_WOW64_64KEY ,hk);
   hk := _OpenCreate(root,KeyPath,KEY_WRITE);
   if hk = 0 then Exit;
   st := RegSetValueExA(hk,@KN[1],0,REG_DWORD,@DATA,4);
   if st = 0 then Result := true; //OK
   RegCloseKey(hk);
end;

//------------------------------------------------------------------------------
function Reg_ReadKeyDW(root:longword; const KeyPath,KeyName:string; var Data:longword):boolean;
var s:string;
begin
  //����
  Data := 0;
  Result := Reg_ReadKey(root,KeyPath,KeyName,s);  //its ansi
  if Result then
  begin
     if length(s)= 3 then s := s + #0; //:( this is cutted in readKey
     Data := StrToDw(ansistring(s));
  end;
end;

//------------------------------------------------------------------------------
function Reg_DeleteAll(root:longword; const KeyPath:string):boolean;
var a:ansistring;
begin
   Result := false;
   a := ansistring(KeyPath+#0);
   if RegDeleteKeyA(root,@a[1]) = 0 then Result := true;
end;

//------------------------------------------------------------------------------
function Reg_DeleteKey(root:longword; const KeyPath,KeyName:string):boolean;
var hk:HKEY;
st :longint;
begin
   Result := false;
   RegOpenKeyEx(root,@KeyPath[1],0,KEY_WRITE  or KEY_WOW64_64KEY,hk);
//   hk := _OpenCreate(root,KeyPath,KEY_READ);
   if hk = 0 then Exit;
   // key exist so read it
   st := RegDeleteKey(hk,@KeyName[1]);
   if st = 0 then Result := true;
   RegCloseKey(hk);
end;


end.
