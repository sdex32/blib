unit BIdents;

interface

uses  BStack;


const
      MAX_IDENT_SIZE = 32;


type  BTIdent_data = record
         Name      :string[MAX_IDENT_SIZE];
         Name_hash :longword;
         Typ       :longword;
         Base      :longword;
         Data      :longword;
         Complex   :string[MAX_IDENT_SIZE];
         res_A     :longword;
         res_B     :longword;
         res_C     :longword;
         res_D     :longword;
      end;
      PBTIdent_data = ^BTIdent_data;

      BTIdents_CallBack_FreeFunc = procedure(item:PBTIdent_data); stdcall;

      BTIdents = class
         private
            aIdentsList :pointer;
            aIdentsPos  :longword;
            aIdentsSize :longword;
            aStack      :BTStack;
            aCallBack   :pointer;
            function    _Find(Name:string):longint;
            procedure   _Free(sindx:longword);
         public
            constructor Create(cb_free_func:pointer);
            destructor  Destroy; override;
            function    Put(Name:string; var Ident:BTIdent_data; DubIfAfterMark:boolean = true):longint;
            function    Get(Name:string; var Ident:BTIdent_data):boolean;
            function    GetByIndx(indx:longint; var Ident:BTIdent_data):boolean;
            procedure   Mark;
            procedure   DeleteToMark;
            procedure   Reset;
      end;


implementation

uses BHash;

type BTIdentsArr = array[0..0] of BTIdent_data;
     PBTIdentsArr = ^BTIdentsArr;

//------------------------------------------------------------------------------
constructor BTIdents.Create(cb_free_func:pointer);
begin
   aCallBack := cb_free_func;
   aIdentsList := nil;
   aIdentsPos := 0;
   aIdentsSize := 0;
   aStack := BTStack.Create(32);
end;

//------------------------------------------------------------------------------
destructor  BTIdents.Destroy;
begin
   _Free(1);
   aStack.Free;
   if aIdentsList <> nil then ReallocMem(aIdentsList,0);
   inherited;
end;

//------------------------------------------------------------------------------
procedure   BTIdents.Reset;
begin
   _Free(1); // free all from begining
   aStack.Reset;
   aIdentsPos := 0;
end;

//------------------------------------------------------------------------------
function    BTIdents.Put(Name:string; var Ident:BTIdent_data; DubIfAfterMark:boolean = true):longint;
var p:pointer;
begin
   Result := 0; // fail memory error
   // Dub  Mark res not
   //  T    T    T   F  - dont check name
   //  T    F    F   T
   //  F    T    F   T
   //  F    F    F   T
   if not ((aStack.StackPos <> 0) and DubIfAfterMark ) then
   begin
      if _Find(Name) <> 0 then // already exist
      begin
         Result := -1;
         Exit;
      end;
   end;

   inc(aIdentsPos);  // create new one
   if aIdentsPos > aIdentsSize then  // if no place realloc it
   begin
      inc(aIdentsSize,128);
      ReallocMem(aIdentsList,aIdentsSize*sizeof(BTIdent_data));
   end;
   if aIdentsList <> nil then
   begin
      p := pointer(longword(aIdentsList) + (aIdentsPos-1)*sizeof(BTIdent_data));
      Move(Ident,p^,sizeof(BTIdent_data));
      Ident.Name := ShortString(Name);   //todo if large than MAX_IDENT_SIZE
      Ident.Name_hash := FNV1aHash(AnsiString(Name));
      Result := aIdentsPos;
   end else aIdentsPos := 0;
end;

//------------------------------------------------------------------------------
function    BTIdents._Find(Name:string):longint;
var i:longint;
    w:longword;
    p:PBTIdentsArr;
begin
   Result := 0; // not found
   if (aIdentsList <> nil) and (aIdentsPos > 0) then
   begin
      p := aIdentsList;
      w := FNV1aHash(AnsiString(Name));
      for i := aIdentsPos - 1 downto 0 do // from locals to globals
      begin
         if p[i].Name_hash = w then
         begin
            if p[i].Name = ShortString(Name) then
            begin
               Result := i + 1;
               break;
            end;
         end;
      end;
   end;
end;

//------------------------------------------------------------------------------
function    BTIdents.Get(Name:string; var Ident:BTIdent_data):boolean;
begin
   Result := GetByIndx(_Find(Name),Ident);
end;

//------------------------------------------------------------------------------
function    BTIdents.GetByIndx(indx:longint; var Ident:BTIdent_data):boolean;
var p:PBTIdentsArr;
    pn:pointer;
begin
   Result := false;
   if (aIdentsList <> nil) and (aIdentsPos > 0) then
   begin
      p := aIdentsList;
      pn := @p[indx-1];
      Move(pn^,Ident,sizeof(BTIdent_data));
      Result := true;
   end;
end;

//------------------------------------------------------------------------------
procedure   BTIdents.Mark;
begin
   // Warning no error test todo
   aStack.Push(aIdentsPos);
end;

//------------------------------------------------------------------------------
procedure   BTIdents.DeleteToMark;
begin
   if aStack.Pop(aIdentsPos) then _Free(aIdentsPos + 1);
end;


//------------------------------------------------------------------------------
procedure   BTIdents._Free(sindx:longword);
var prc:BTIdents_CallBack_FreeFunc;
    p:pointer;
    i:longword;
begin
   if (aCallBack <> nil) and (aIdentsList <> nil) and (aIdentsPos > 0) and (sindx <= aIdentsPos) then
   begin
      prc := aCallBack;
      dec(sindx);
      for i := sindx to aIdentsPos - 1 do
      begin
         p := pointer(longword(aIdentsList) + (i)*sizeof(BTIdent_Data));
         prc(p);
      end;
   end;
end;



end.
