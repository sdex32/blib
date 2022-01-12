unit BShortcut;

interface

//example
//  CreateLink(Desktopdir + '\' + LinkName + '.lnk', program_path, '');
Function CreateShortcut(const Link,Pgm,Parm:string):boolean;

implementation



type
   TUUID=record d1:integer; d2,d3:word; d4:array[0..7] of byte end;


const
   CLSID_ShellLink : TUUID = (D1:$00021401; D2:$0000; D3:$0000; D4:($C0,$00,$00,$00,$00,$00,$00,$46));
   IID_IShellLink  : TUUID = (D1:$000214EE; D2:$0000; D3:$0000; D4:($C0,$00,$00,$00,$00,$00,$00,$46));
   IID_IPersistFile: TUUID = (D1:$0000010B; D2:$0000; D3:$0000; D4:($C0,$00,$00,$00,$00,$00,$00,$46));

type
   IUnknown=^PUnknown;
   PUnknown=^TUnknown;
   TUnknown=record
      QueryInterface:function(Self:pointer; Const ID:TUUID; Var Instance):integer; stdcall;
      AddRef        :function(Self:pointer):integer; stdcall;
      Release       :function(Self:pointer):integer; stdcall;
   end;

   IPersist=^PPersist;
   PPersist=^TPersist;
   TPersist=record
      // IUnknow
      Unknown:TUnknown;
      // IPersist
      GetClassID:function(var ID: TUUID):integer; stdcall;
   end;

   IPersistFile=^PPersistFile;
   PPersistFile=^TPersistFile;
   TPersistFile=record
     // IPersist
     Persist:TPersist;
     // IPersistFile
     IsDirty      :pointer;
     Load         :pointer;
     Save         :function(Self:pointer; FileName:PWideChar; Remember:boolean):integer; stdcall;
     SaveCompleted:pointer;
     GetCurFile   :pointer;
   end;

   IShellLink=^PShellLink;
   PShellLink=^TShellLink;
   TShellLink=record
      // IUnknow
      Unknown:TUnknown;
      // IShellLink
      GetPath                                 :pointer;
      GetIDList,SetIDList                     :pointer;
      GetDescription,SetDescription           :pointer;
      GetWorkingDirectory,SetWorkingDirectory :pointer;
      GetArguments                            :pointer;
      SetArguments                            :function(Self:pointer; Args:PAnsiChar):integer; stdcall;
      GetHotKey,SetHotKey                     :pointer;
      GetShowCmd,SetShowCmd                   :pointer;
      GetIconLocation,SetIconLocation         :pointer;
      SetRelativePath                         :pointer;
      Resolve                                 :pointer;
      SetPath                                 :function(Self:pointer; Path:PAnsiChar):integer; stdcall;
   end;


function CoCreateInstance(const clsid: TUUID; unkOuter,dwClsContext: Longint; const iid: TUUID; var pv): integer; stdcall; external 'ole32.dll' name 'CoCreateInstance';
function CoInitialize(pvReserved:integer):integer; stdcall; external 'ole32.dll';
procedure CoUninitialize; stdcall; external 'ole32.dll';


Function CreateShortcut(const Link,Pgm,Parm:string):boolean;
var Lnk:IShellLink;
    PF :IPersistFile;
    WC :array[0..255] of WideChar;
    pg,pa:ansistring;
begin
   CoInitialize(0);
   Result:=False;
   if CoCreateInstance(CLSID_ShellLink, 0, 1, IID_IShellLink, Lnk)=0 then
   begin
      pg := ansistring(Pgm);
      pa := ansistring(Parm);
      Lnk^^.SetPath(lnk,pansichar(Pg));
      Lnk^^.SetArguments(lnk,pansichar(Pa));
      if Lnk^^.Unknown.QueryInterface(lnk,IID_IPersistFile,PF)=0 then
      begin
         PF^^.Save(pf,StringToWideChar(Link,WC,SizeOf(WC) div 2),TRUE);
         PF^^.Persist.Unknown.Release(pf);
         Result:=True;
      end;
      Lnk^^.Unknown.Release(lnk);
   end;
   CoUninitialize;
 end;


end.
