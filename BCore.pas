unit BCore;

interface

function IfThen(a:boolean; t:byte; f:byte):byte; overload; inline;
function IfThen(a:boolean; t:word; f:word):word; overload; inline;
function IfThen(a:boolean; t:longword; f:longword):longword; overload; inline;
function IfThen(a:boolean; t:longint; f:longint):longint; overload; inline;
function IfThen(a:boolean; t:single; f:single):single; overload; inline;
function IfThen(a:boolean; t:real; f:real):real; overload; inline;
function IfThen(a:boolean; t:double; f:double):double; overload; inline;
function IfThen(a:boolean; t:widestring; f:widestring):widestring; overload; inline;
function IfThen(a:boolean; t:ansistring; f:ansistring):ansistring; overload; inline;
function IfThen(a:boolean; t:widechar; f:widechar):widechar; overload; inline;
function IfThen(a:boolean; t:ansichar; f:ansichar):ansichar; overload; inline;
function IfThen(a:boolean; t:pointer; f:pointer):pointer; overload; inline;
function IfThen(a:boolean; t:int64; f:int64):int64; overload; inline;

type
//      PPointerList = ^TPointerList;
//      TPointerList = array of Pointer;

      BTList = class
         private
            aCount:longword;
            aCapacity:longword;
            aData:pointer;
            procedure _AddItem;
            function  _GetItem(i:longword):pointer;
            procedure _SetItem(i:longword; value:pointer);
         public
            constructor Create;
            destructor  Destroy; override;
            procedure   Add(P:pointer);
            property    Count:longword read aCount;
            property    Items[i:longword]:pointer read _GetItem write _SetItem; default;
      end;


implementation

function IfThen(a:boolean; t:byte; f:byte):byte;
begin
   if a then Result := t else Result := f;
end;

function IfThen(a:boolean; t:word; f:word):word;
begin
   if a then Result := t else Result := f;
end;

function IfThen(a:boolean; t:longword; f:longword):longword;
begin
   if a then Result := t else Result := f;
end;

function IfThen(a:boolean; t:longint; f:longint):longint;
begin
   if a then Result := t else Result := f;
end;

function IfThen(a:boolean; t:single; f:single):single;
begin
   if a then Result := t else Result := f;
end;

function IfThen(a:boolean; t:real; f:real):real;
begin
   if a then Result := t else Result := f;
end;

function IfThen(a:boolean; t:double; f:double):double;
begin
   if a then Result := t else Result := f;
end;

function IfThen(a:boolean; t:widestring; f:widestring):widestring;
begin
   if a then Result := t else Result := f;
end;

function IfThen(a:boolean; t:ansistring; f:ansistring):ansistring;
begin
   if a then Result := t else Result := f;
end;

function IfThen(a:boolean; t:widechar; f:widechar):widechar;
begin
   if a then Result := t else Result := f;
end;

function IfThen(a:boolean; t:ansichar; f:ansichar):ansichar;
begin
   if a then Result := t else Result := f;
end;

function IfThen(a:boolean; t:pointer; f:pointer):pointer;
begin
   if a then Result := t else Result := f;
end;

function IfThen(a:boolean; t:int64; f:int64):int64;
begin
   if a then Result := t else Result := f;
end;

constructor BTList.Create;
begin
   aCount := 0;
   aCapacity := 0;
   aData := nil;
end;

destructor  BTList.Destroy;
begin
//   SetLength(aData,0);
   if aData <> nil then ReallocMem(aData,0);

   inherited;
end;

procedure   BTList._AddItem;
begin
   inc(aCount);
   if aCount > aCapacity then
//   begin
//     inc(aCapacity,1024);
//     SetLength(aData,aCapacity);
//
//   end;

   inc(aCapacity,1024);
   ReallocMem(aData,aCapacity*sizeof(pointer));
end;

procedure   BTList.Add(P:pointer);
var a:pointer;
begin
   _AddItem;
//   aData[Count-1] := P;
   if aData <> nil then
   begin
      a := pointer(NativeUint(aData) + (aCount - 1)*sizeof(pointer));
      pointer(a^) := P; // save
   end;
end;

function    BTList._GetItem(i:longword):pointer;
var a:pointer;
begin
   Result := nil;
   if (aData <> nil) and (i < aCount) then
   begin
      a := pointer(NativeUint(aData) + (i)*sizeof(pointer));
      Result := pointer(a^); //Get
   end;
end;

procedure   BTList._SetItem(i:longword; value:pointer);
var a:pointer;
begin
   if (aData <> nil) and (i < aCount) then
   begin
      a := pointer(NativeUint(aData) + (i)*sizeof(pointer));
      pointer(a^) := value; // Set
   end;
end;




end.
