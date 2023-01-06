unit BList;

interface

type
      BTList = class
      private
         aCount      :longint;
         aCapacity   :longword;
         aList       :pointer;
         procedure   _Grow;
		     function    _GoodIndex(index:longint):boolean;
      public
         constructor Create;
         destructor  Destroy; override;
         procedure   Clear;
         function    Add(item :longword) :longint;
         procedure   Insert(index :longint; item :longword);
         procedure   Move(CurIndex, NewIndex :longint);
         procedure   Delete(index :longint);
         procedure   Swap(index1, index2 :longint);
         function    Get(index :longint) :longword;
         procedure   Put(index :longint; item :longword);
         function    Find(item :longword; start_index :longint = 0): longint;


         property    Count:longint read aCount;
         property    items[i:longint]:longword read Get write Put;
      end;

implementation

//------------------------------------------------------------------------------
constructor BTList.Create;
begin
   aCount := 0;
   aCapacity := 0;
   aList := nil;
end;

//------------------------------------------------------------------------------
destructor  BTList.Destroy;
begin
   if aCapacity > 0 then ReallocMem(aList, 0);
   inherited;
end;

//------------------------------------------------------------------------------
procedure   BTList._Grow;
begin
   aCapacity := aCapacity + 128;
   ReallocMem(aList, aCapacity * SizeOf(longword));
   if aList = nil then aCount := 0;
end;

//------------------------------------------------------------------------------
procedure   BTList.Clear;
begin
   aCount := 0;
end;

//------------------------------------------------------------------------------
function    BTList.Add(item:longword):longint;
var r:longint;
    p:pointer;
begin
   r := aCount;
   inc(r);
   if r > longint(aCapacity) then _Grow;
   if aList <> nil then
   begin
      try
	     p := pointer(longword(aList)+longword(r-1)*sizeof(longword));
       longword(p^) := item;
	     aCount := r;
	  except
	     r := -1;
	  end;
   end else begin
      r := -1;
   end;
   Result := r;
end;

//------------------------------------------------------------------------------
function    BTList._GoodIndex(index:longint):boolean;
begin
   if (aList <> nil) and (index >=0) and (index < aCount) then Result := true else Result := false;
end;

//------------------------------------------------------------------------------
procedure   BTList.Delete(index: longint);
var s,d:pointer;
begin
   if _GoodIndex(index) then
   begin
      Dec(aCount);
      if index < aCount then // is not last
      begin
 	     d := pointer(longword(aList)+longword(index)*sizeof(longword));  // destination  index
         s := pointer(longword(d)+sizeof(longword)); 		      // source       index + 1
         System.Move(s^, d^,  (aCount - index) * SizeOf(longword));
      end;
   end;
end;

//------------------------------------------------------------------------------
procedure   BTList.Swap(index1, index2: longint);
var  item: longword;
     p1,p2: pointer;
begin
   if _GoodIndex(index1) and _GoodIndex(index2) then
   begin
      p1 := pointer(longword(aList)+longword(index1)*sizeof(longword));
      p2 := pointer(longword(aList)+longword(index2)*sizeof(longword));
      item := longword(p1^);
      longword(p1^) := longword(p2^);
      longword(p2^) := item;
   end;
end;

//------------------------------------------------------------------------------
function    BTList.Get(Index: longint): longword;
var p:pointer;
begin
   Result := 0;
   if _GoodIndex(index) then
   begin
      p := pointer(longword(aList)+longword(index)*sizeof(longword));
      Result := longword(p^);
   end;
end;

//------------------------------------------------------------------------------
procedure   BTList.Put(index :longint; item: longword);
var p:pointer;
begin
   if _GoodIndex(index) then
   begin
      p := pointer(longword(aList)+longword(index)*sizeof(longword));
      longword(p^) := item;
   end;
end;

//------------------------------------------------------------------------------
function    BTList.Find(item: longword; start_index:longint = 0): longint;
var i :longint;
    p:pointer;
begin
   Result := -1;
   if _GoodIndex(start_index) and (aCount > 0) then
   begin
      p := aList;
      for i := 0 to aCount - 1 do
      begin
         if longword(p^) = item then begin Result := i; Exit; end;
	     p := pointer(longword(p)+sizeof(longword)); //next
	  end;
   end;
end;

//------------------------------------------------------------------------------
procedure   BTList.Insert(index :longint; item: longword);
var r:longword;
    s,d:pointer;
begin
   if _GoodIndex(index) then
   begin
      r := aCount;
      inc(r);
      if r > aCapacity then _Grow;
      if aList <> nil then
      begin
	       s := pointer(longword(aList)+longword(index)*sizeof(longword));  // source  index
         d := pointer(longword(s)+sizeof(longword)); 		      // dest    index + 1
         System.Move(s^, d^, (aCount - Index) * SizeOf(longword));
         longword(s^) := item;
         aCount := r;
      end;
   end;
end;

//------------------------------------------------------------------------------
procedure   BTList.Move(CurIndex, NewIndex: longint);
var Item: longword;
begin
   if CurIndex <> NewIndex then
   begin
      if CurIndex >= aCount then Exit;
      if NewIndex >= aCount then Exit;
      Item := Get(CurIndex);
      Delete(CurIndex);
      Insert(NewIndex, Item);
  end;
end;



 (*
type
      _PBTListType = ^_BTListType;
      _BTListType = array [1..1] of longword;
      BTListCompareProc = function (Item1, Item2: longword): Integer;



      BTList = class
      private
         aError     : longword;
         aCount     : longword;
         aCapacity  : longword;
         aList      : ^_BTListType;
         procedure  Grow;
      public
         constructor Create;
         destructor  Destroy; override;
         procedure   Clear;
         function    Add(item:longword):longword;
         procedure   Insert(index, item: longword);
         procedure   Move(CurIndex, NewIndex: longword);
         procedure   Delete(index: longword);
         procedure   Swap(index1, index2: longword);
         function    Get(index: longword): longword;
         procedure   Put(index,item: longword);
         function    Find(item: longword): longword;
         procedure   Sort(Compare: BTListCompareProc);
         procedure   SortDes;
         procedure   SortAsc;
         property    Count:longword read aCount;
         property    Error:longword read aError;
         property    items[i:longword]:longword read Get write Put;
      end;

implementation

//------------------------------------------------------------------------------
constructor BTList.Create;
begin
   aCount := 0;
   aCapacity := 0;
   aList := nil;
end;

//------------------------------------------------------------------------------
destructor  BTList.Destroy;
begin
   if aCapacity > 0 then ReallocMem(aList, 0);
   inherited;
end;

//------------------------------------------------------------------------------
procedure   BTList.Grow;
begin
   aError := 0;
   aCapacity := aCapacity + 128;
   ReallocMem(aList, aCapacity * SizeOf(longword));
   if aList = nil then aError := 1;
end;

//------------------------------------------------------------------------------
procedure   BTList.Clear;
begin
   aCount := 0;
end;

//------------------------------------------------------------------------------
function    BTList.Add(item:longword):longword;
var r:longword;
begin
   r := aCount;
   inc(r);
   if r > aCapacity then Grow;
   if aError = 0 then
   begin
     aCount := r;
     aList^[aCount] := item;
   end else begin
     r := 0;
   end;
   Add := r;
end;

//------------------------------------------------------------------------------
procedure   BTList.Delete(index: longword);
begin
   if index > aCount then Exit;
   Dec(aCount);
   if index < aCount then // is not last
   begin
      System.Move(aList^[index + 1], aList^[index],(aCount - index) * SizeOf(longword));
   end;
end;

//------------------------------------------------------------------------------
procedure   BTList.Swap(index1, index2: longword);
var  item: longword;
begin
   if index1 > aCount then Exit;
   if index1 > aCount then Exit;
   Item := aList^[Index1];
   aList^[Index1] := aList^[Index2];
   aList^[Index2] := Item;
end;

//------------------------------------------------------------------------------
function    BTList.Get(Index: longword): longword;
begin
   if Index > aCount then Get := 0
                     else Get := aList^[Index];
end;

//------------------------------------------------------------------------------
procedure   BTList.Put(index,item: longword);
begin
   if Index <= aCount then aList^[index] := Item;
end;

//------------------------------------------------------------------------------
function    BTList.Find(item: longword): longword;
var r,i :longword;
begin
   R := 0;
   for i:= 1 to aCount do
   begin
      if aList[i] = item then R := i;
   end;
   Find := R;
end;

//------------------------------------------------------------------------------
procedure   BTList.Insert(index, item: longword);
var r:longword;
begin
   if index > aCount then Exit;
   r := aCount;
   inc(r);
   if r > aCapacity then Grow;
   if aError  = 0 then
   begin
      if Index < aCount then
      begin
         aCount := r;
         System.Move(aList^[Index], aList^[Index + 1],(aCount - Index) * SizeOf(longword));
         aList^[Index] := Item;
      end;
   end;
end;

//------------------------------------------------------------------------------
procedure   BTList.Move(CurIndex, NewIndex: longword);
var Item: longword;
begin
   if CurIndex <> NewIndex then
   begin
      if CurIndex >= aCount then Exit;
      if NewIndex >= aCount then Exit;
      Item := Get(CurIndex);
      Delete(CurIndex);
      Insert(NewIndex, Item);
  end;
end;

//------------------------------------------------------------------------------
procedure QuickSort(SortList: _PBTListType; L, R: Integer;  SCompare: BTListCompareProc);
var
  I, J: Integer;
  P, T: longword;
begin
  repeat
    I := L;
    J := R;
    P := SortList^[(L + R) shr 1];
    repeat
      while SCompare(SortList^[I], P) < 0 do
        Inc(I);
      while SCompare(SortList^[J], P) > 0 do
        Dec(J);
      if I <= J then
      begin
        T := SortList^[I];
        SortList^[I] := SortList^[J];
        SortList^[J] := T;
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if L < J then
      QuickSort(SortList, L, J, SCompare);
    L := I;
  until I >= R;
end;

function _Des(Item1, Item2: longword): Integer;
begin
    Result := 0;
end;


//------------------------------------------------------------------------------
procedure   BTList.Sort(Compare: BTListCompareProc);
begin
   if aCount > 0 then QuickSort(@aList, 0, aCount - 1, Compare);
end;

//------------------------------------------------------------------------------
procedure   BTList.SortDes;
begin

end;

//------------------------------------------------------------------------------
procedure   BTList.SortAsc;
begin

end;

*)
end.
