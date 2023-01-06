{todo
  IMPORTANT multi delimiter as one
}
unit BStrings;

// version 2

interface

uses windows;



type
     BTStrings = class
     private
        aSearchRow   : longint;
        aDelimiter   : char;
        aData        :array of string;
        aDataVal     :array of longword;
        aCapacity    :longint;
        aUnique      :boolean;
        aAddLastDelimiter : boolean;
     public
        constructor  Create;
        destructor   Destroy; override;
        procedure    Clear;
        function     GetText:string;
        procedure    SetText(value:string);
        function     Add(const s:string; value:longword=0):longint;
        procedure    Insert(in_pos:longint; const s:string; value:longword=0);
        function     Get(i:longint):string;
        procedure    Put(i:longint; const s:string);
        function     GetValue(i:longint):longword;
        procedure    PutValue(i:longint; v:longword);
        procedure    Delete(i:longint);
        procedure    Copy(old_i,new_i:longint);
        procedure    Swap(i,j:longint);
        function     Search(s:string; StartPos:longint=0; Case_Sense:boolean = true):longint;
        procedure    Sort(lo_to_hi:boolean=true; sort_by_value:boolean = false);
        function     Find(const s:string):longint; //Unique first find
        function     FindValue(v:longword):longint;
        property     Unique:boolean read aUnique write aUnique; // in unique mode value is used as dublicate value
        property     Count:longint read aCapacity;
        property     Text:string read GetText write SetText;
        property     Delimiter:char read aDelimiter write aDelimiter;
        property     AddLastDelimiter:boolean read aAddLastDelimiter write aAddLastDelimiter;
        property     Strings[i:longint]:string read Get write Put;
        property     Values[i:longint]:longword read GetValue write PutValue;
     end;




implementation

uses BStrTools;

//------------------------------------------------------------------------------
constructor  BTStrings.Create;
begin
   aCapacity := 0;
   aSearchRow := 0;
   aDelimiter := #32;
   aAddLastDelimiter := false;
   aUnique := false;
end;

//------------------------------------------------------------------------------
destructor   BTStrings.Destroy;
begin
   Clear;
   inherited;
end;

//------------------------------------------------------------------------------
procedure    BTStrings.Clear;
begin
   SetLength(aData,0);    // clear memory
   SetLength(aDataVal,0);
   aCapacity := 0;
end;

//------------------------------------------------------------------------------
function     BTStrings.Add(const s:string; value:longword=0):longint;
var p:longint;
begin
   if aUnique then
   begin
      value := 1; // in unique mode value is used as dublicate value
      p := Find(s);
      if p >= 0 then
      begin
         inc(aDataVal[p]);
         Result := p;
         Exit;
      end;
   end;

   SetLength(aData,aCapacity + 1);
   SetLength(aDataVal,aCapacity + 1);
   aData[aCapacity] := s;
   aDataVal[aCapacity] := value;
   Result := aCapacity;
   inc(aCapacity);
end;

//------------------------------------------------------------------------------
procedure    BTStrings.Insert(in_pos:longint; const s:string; value:longword=0);
var i,p:longint;
begin
   if aUnique then
   begin
      value := 1;
      p := Find(s);
      if p >= 0 then
      begin
         inc(aDataVal[p]);
         Exit;
      end;
   end;

   if (in_pos >= 0) and (aCapacity > 0) and (in_pos < aCapacity) then
   begin
      SetLength(aData,aCapacity + 1);
      SetLength(aDataVal,aCapacity + 1);
      for i := aCapacity downto in_pos do
      begin
         aData[i+1] := aData[i];
         aDataVal[i+1] := aDataVal[i];
      end;
      aData[in_pos] := s;
      aDataVal[in_pos] := value;
      inc(aCapacity);
   end;
end;

//------------------------------------------------------------------------------
procedure    BTStrings.Delete(i:longint);
var j:longint;
begin
   if (i >= 0) and (aCapacity > 0)  and (i < aCapacity) then
   begin
      for j := i to aCapacity - 1 do
      begin
         aData[j] := aData[j+1];
      end;
      dec(aCapacity);
      SetLength(aData,aCapacity);
   end;
end;

//------------------------------------------------------------------------------
procedure    BTStrings.Copy(old_i,new_i:longint);
begin
   if (aCapacity > 0) then
     if (old_i >= 0) and (old_i < aCapacity) then
        if (new_i >= 0) and (new_i < aCapacity) then aData[new_i] := aData[old_i];
end;

//------------------------------------------------------------------------------
function     BTStrings.GetText:string;
var i,j:longint;
begin
   Result := '';
   j := aCapacity - 1;
   if aCapacity > 0 then
   begin
      for i := 0 to j do
      begin
         Result := Result + aData[i];
         if (i = j) and ( not aAddLastDelimiter) then break;
         Result := Result + aDelimiter;
      end;
   end;
end;

//------------------------------------------------------------------------------
procedure    BTStrings.SetText(value:string);
var s,sb:string;
    i,j:longint;
begin
   Clear;
   s := value;
   j:=length(value);
   sb := '';
   i := 1;
   while (i <=j ) do
   begin
      if value[i] = Delimiter then
      begin
         Add(Sb);
         Sb := '';
         if Delimiter = #13 then
            if i + 1 <= j  then
               if value[i+1] = #10 then inc(i);
      end else Sb := Sb + value[i];
      inc(i);
   end;
end;

//------------------------------------------------------------------------------
function     BTStrings.Get(i:longint):string;
begin
   if (i >= 0) and (aCapacity > 0) and (i < aCapacity) then Result := aData[i]
                                                       else Result := '';
end;

//------------------------------------------------------------------------------
procedure    BTStrings.Put(i:longint; const s:string);
begin
   if (i >= 0) and (aCapacity > 0) and (i < aCapacity) then aData[i] := s;
end;

//------------------------------------------------------------------------------
function     BTStrings.GetValue(i:longint):longword;
begin
   if (i >= 0) and (aCapacity > 0) and (i < aCapacity) then Result := aDataVal[i]
                                                       else Result := 0;
end;

//------------------------------------------------------------------------------
procedure    BTStrings.PutValue(i:longint; v:longword);
begin
   if (i >= 0) and (aCapacity > 0) and (i < aCapacity) then aDataVal[i] := v;
end;

//------------------------------------------------------------------------------
function     BTStrings.Find(const s:string):longint;
var i:longint;
begin
   Result := -1;
   if aCapacity > 0 then
   begin
      for i := 0 to aCapacity -1 do
      begin
         if aData[i] = s then
         begin
            Result := i;
            break
         end;
      end;
   end;
end;

//------------------------------------------------------------------------------
function     BTStrings.FindValue(v:longword):longint;
var i:longint;
begin
   Result := -1;
   if aCapacity > 0 then
   begin
      for i := 0 to aCapacity -1 do
      begin
         if aDataVal[i] = v then
         begin
            Result := i;
            break
         end;
      end;
   end;
end;

//------------------------------------------------------------------------------
procedure    BTStrings.Swap(i,j:longint);
var s:string;
    v:longword;
begin
   if (aCapacity > 0)
   and (i >= 0) and (i < aCapacity)
   and (j >= 0) and (j < aCapacity) and ( i <> j ) then
   begin
      s := aData[i];  aData[i] := aData[j];  aData[j] := s;
      v := aDataVal[i];  aDataVal[i] := aDataVal[j];  aDataVal[j] := v;
   end;
end;

//------------------------------------------------------------------------------
function     BTStrings.Search(s:string; StartPos:longint=0; Case_Sense:boolean = true):longint; // case sensitive
var i : longint;
    St:string;
begin
   Result := -1;
   if not Case_Sense then S := UpperCase(S);
   if aCapacity > 0 then
   begin
      if (StartPos < 0) or (StartPos >= aCapacity) then Exit;

      for i := 0 to aCapacity -1 do
      begin
         St := aData[i];
         if not Case_Sense then St := UpperCase(St);
         if St = s then
         begin
            Result := i;
            break
         end;
      end;
   end;
end;

//------------------------------------------------------------------------------
procedure    BTStrings.Sort(lo_to_hi:boolean=true; sort_by_value:boolean = false);
var i,j:longint;
    buble:boolean;
    s:string;
    v:longword;
begin
   if aCapacity > 1 then
   begin  // buble sort :( no time
      for j := 0 to aCapacity -2 do
      for i := 0 to aCapacity -2 - j do
      begin
         buble := false;
         if sort_by_value then
         begin
            if lo_to_hi then
            begin
               if aDataVal[i] > aDataVal[i+1] then buble := true;
            end else begin
               if aDataVal[i] < aDataVal[i+1] then buble := true;
            end;
         end else begin
            if lo_to_hi then
            begin
               if aData[i] > aData[i+1] then buble := true;
            end else begin
               if aData[i] < aData[i+1] then buble := true;
            end;
         end;

         if buble then
         begin
            s := aData[i];  aData[i] := aData[i+1];  aData[i+1] := s;
            v := aDataVal[i];  aDataVal[i] := aDataVal[i+1];  aDataVal[i+1] := v;
         end
      end;
   end;
end;


end.
