unit BCodeTree;

interface

uses BTree,BStack;

{ first LEFT then RIGHT
  if A=5 then func(b,5) else while(a) do a=a+4
  B=5

 NOP L                                                      R
     IF L     R                                             NOP L       R
        = L R THENELSE L                     R                  SET L R TERM
          A 5          CALL L        R       LOOP L R               5 B
                            PARM L R FUNC         A SET L       R
                                 B PARM L R             ADD L R A
                                        5 TERM              4 A




}
const TNID_TERM           =   0;
      TNID_Nop            =   1;
      TNID_SetValue       =   2;
      TNID_If             =   3;
      TNID_ThenElse       =   4;
      TNID_CALL           =   5;
      TNID_PARM           =   6;
      TNID_LOOP           =   7;
      TNID_GOTO           =   8;
      TNID_FOR            =   9;
      TNID_FORPARM        =   10;
//todo case

      TNID_ADD            = $80;
      TNID_SUB            = $81;
      TNID_MUL            = $82;
      TNID_DIV            = $83;
      TNID_MOD            = $84;
      TNID_NEG            = $85;
      TNID_NOT            = $86;
      TNID_AND            = $87;
      TNID_OR             = $88;
      TNID_XOR            = $89;
      TNID_EQ             = $8A;
      TNID_GR             = $8B;
      TNID_LT             = $8C;
      TNID_NOTEQ          = $8D;
      TNID_GREQ           = $8E;
      TNID_LTEQ           = $8F;


type  BTCodeTree = class
         private
            aTree       :BTTree;
            aStack      :BTStack;
            aPutPoint   :longint;
         public
            constructor Create;
            destructor  Destroy; override;
            procedure   Reset;
            function    _Begin:longint;
            function    _End(Left,Right:boolean):boolean; // link the new tree to de old node
            function    Add_L(Node:longword):boolean;
            function    Add_R(Node:longword):boolean;
            property    PutPoint:longint read aPutPoint;

      end;


implementation


type  BTASTreeNode = record
         Left   :longword;
         Right  :longword;
         NodeID :longword;
         Data   :longword;
      end;
      BTAStreeNodeArray = array of BTAStreeNode;


      BTASTree = class
         private
            aTree       :BTASTreeNodeArray;
            aCount      :longword;
            aCapacity   :longword;
            aCurrent    :longword;
            aCurStack   :array [1..256] of longword;
            aFlinStack  :array [1..256] of longword; // Block first line
            aStackPos   :longword;
            function    _add:longword;
         public
            constructor Create;
            destructor  Destroy; override;
            procedure   Reset;
            function    BeginBlock:longword;
            function    EndBlock:longword;
            function    NextLine:longword;

      end;

//------------------------------------------------------------------------------
constructor BTASTree.Create;
begin
   aCapacity := 0;
   Reset;
end;

//------------------------------------------------------------------------------
destructor  BTASTree.Destroy;
begin
   Reset;
   inherited;
end;

//------------------------------------------------------------------------------
procedure   BTASTree.Reset;
begin
   SetLength(aTree,0);
   aCount := 0;
   aStackPos := 0;
   aCurrent := 0;
   _add; // to skip ZERO element
end;

//------------------------------------------------------------------------------
function    BTASTree._add:longword;
begin
   inc(aCount);
   if aCount > aCapacity then
   begin
      inc(aCapacity,32);
      SetLength(aTree, aCapacity);  // realloc
   end;
   Result := aCount - 1;
end;

//------------------------------------------------------------------------------
function    BTASTree.BeginBlock:longword;
begin
   if aStackPos < 256 then
   begin
      inc(aStackPos);
   end;
   aCurStack[aStackPos] := aCurrent;
   Result := NextLine;
   aFlinStack[aStackPos] := Result;
end;

//------------------------------------------------------------------------------
function    BTASTree.EndBlock:longword;
begin
  Result := 0;
  if aStackPos > 0  then
   begin
      aCurrent := aCurStack[aStackPos];
      Result := aFlinStack[aStackPos];
      dec(aStackPos);
   end;
end;

//------------------------------------------------------------------------------
function    BTASTree.NextLine:longword;
begin
   Result := _add;
   if aCurrent <> 0 then
   begin
      aTree[aCurrent].Right := Result;
   end;
   aCurrent := Result;
   aTree[Result].Left := 0;
   aTree[Result].Right := 0;
   aTree[Result].NodeID := TNID_NOP;
   aTree[Result].Data := 0;
end;









//------------------------------------------------------------------------------
constructor BTCodeTree.Create;
begin
   aTree := BTTree.Create(16384,16384);
   aStack := BTStack.Create(1024);
   Reset;
end;

//------------------------------------------------------------------------------
destructor  BTCodeTree.Destroy;
begin
   aTree.Free;
   aStack.Free;
   inherited;
end;

//------------------------------------------------------------------------------
procedure   BTCodeTree.Reset;
begin
   aTree.Reset;
   aStack.Reset;
   aPutPoint := aTree.NewNode(TNID_Nop,0);
end;

//------------------------------------------------------------------------------
function    BTCodeTree._Begin:longint; // Create new tree
begin
   Result := -1;
   if aPutPoint > 0 then
   begin
      if aStack.push(aPutPoint) then
      begin
         aPutPoint := aTree.NewNode(TNID_Nop,0);
         if aStack.Read then // read from cur pos;
         begin
            aStack.Data.reg_B := aPutPoint; // begining of new block
            if aStack.Write then Result := aPutpoint; //ok
         end;
      end;
   end;
end;

//------------------------------------------------------------------------------
function    BTCodeTree._End(Left,Right:boolean):boolean; // link the new tree to de old node
var SubTree:longint;
begin
   Result := false;
   if aPutPoint > 0 then
   begin
      if aStack.Pop(longword(aPutPoint),longword(SubTree)) then
      begin
         if Left then aTree.Link_L(aPutPoint,SubTree);
         if Right then aTree.Link_R(aPutPoint,SubTree);
         if Left <> Right then Result := True;
      end;
   end;
end;

//------------------------------------------------------------------------------
function    BTCodeTree.Add_L(Node:longword):boolean;
var i:longint;
begin
   if aPutPoint > 0 then
   begin
      i := aTree.NewNode(Node,0);
      aTree.Link_L(aPutPoint,i);
      aPutPoint := i;
   end;
end;

//------------------------------------------------------------------------------
function    BTCodeTree.Add_R(Node:longword):boolean;
var i:longint;
begin
   if aPutPoint > 0 then
   begin
      i := aTree.NewNode(Node,0);
      aTree.Link_R(aPutPoint,i);
      aPutPoint := i;
   end;
end;


end.
