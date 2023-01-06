unit BTree;

interface

type
      BTreeNode = record
         Data   :longword;
         DataExt:longword;
         Left   :longword;
         Right  :longword;
         TrcFlag:Longword;
         TrcPapa:Longword;
      end;
      BTTreeNodeArr = array [0..0] of BTreeNode;

      BTTree = class
         private
            aTree       :^BTTreeNodeArr;
            aTreeSize   :longint;
            aTreeCap    :longint;
            aTreeInitCap:longint;
            aTreeExtCap :longint;
            aTraceFunc  :pointer;
            aTraceFuncParm :longword;
            function    _inc:longint;
         public
            constructor Create(init_capacity,extend_capacity:longint);
            destructor  Destroy; override;
            procedure   Reset;
            function    NewNode(Data,DataExt:longword):longint;
            function    AddNode_L(Parent:longint; Data,DataExt:longword; OverRideIt:boolean = false):longint;
            function    AddNode_R(Parent:longint; Data,DataExt:longword; OverRideIt:boolean = false):longint;
            procedure   Link_L(Parent,Child:longint);
            procedure   Link_R(Parent,Child:longint);
            procedure   SetTraceFunction(p:pointer; userParam:longword);
            procedure   TraceLR(root:longint = 1);
            procedure   TraceRL(root:longint = 1);
            property    TreeSize:longint read aTreeSize;
      end;

      BTTree_TraceFunction    = procedure(userParam,Data,DataExt:longword); stdcall;



implementation

//------------------------------------------------------------------------------
constructor BTTree.Create(init_capacity,extend_capacity:longint);
begin
   aTree := nil;
   aTraceFunc := nil;
   aTreeCap := 0;
   aTreeInitCap := init_capacity;
   aTreeExtCap := extend_capacity;
   Reset;
end;

//------------------------------------------------------------------------------
destructor  BTTree.Destroy;
begin
   if aTree <> nil then ReallocMem(aTree,0);
   inherited;
end;

//------------------------------------------------------------------------------
procedure   BTTree.Reset;
begin
   aTreeSize := 0;
end;

//------------------------------------------------------------------------------
function    BTTree._inc:longint;
var i:longint;
begin
   if (aTreeSize + 1) > aTreeCap then
   begin
      if aTreeCap = 0  then i := aTreeInitCap else i := aTreeExtCap;
      inc(aTreeCap,i*sizeof(BTreeNode));
      ReallocMem(aTree,aTreeCap);
   end;
   if aTree <> nil then inc(aTreeSize) // get new id
                   else aTreeSize := -1;
   Result := aTreeSize;
end;


//------------------------------------------------------------------------------
function    BTTree.NewNode(Data,DataExt:longword):longint;
begin
   Result := _inc;
   if Result > 0  then
   begin
      aTree[Result].Data := Data;
      aTree[Result].DataExt := DataExt;
      aTree[Result].Left := 0;
      aTree[Result].Right := 0;
   end;
end;

//------------------------------------------------------------------------------
function    BTTree.AddNode_L(Parent:longint; Data,DataExt:longword; OverRideIt:boolean = false):longint;
begin
   Result := -1;
   if (Parent > 0) and (Parent <= aTreeSize) then
   begin
      if not OverRideIt then if aTree[Parent].Left <> 0 then Exit;
      Result := NewNode(Data,DataExt);
      if Result <> -1 then aTree[Parent].Left := Result;
   end;
end;

//------------------------------------------------------------------------------
function    BTTree.AddNode_R(Parent:longint; Data,DataExt:longword; OverRideIt:boolean = false):longint;
begin
   Result := -1;
   if (Parent > 0) and (Parent <= aTreeSize) then
   begin
      if not OverRideIt then if aTree[Parent].Right <> 0 then Exit;
      Result := NewNode(Data,DataExt);
      if Result <> -1 then aTree[Parent].Right := Result;
   end;
end;

//------------------------------------------------------------------------------
procedure   BTTree.SetTraceFunction(p:pointer; userParam:longword);
begin
   aTraceFunc := p;
   aTraceFuncParm := userParam;
end;

//------------------------------------------------------------------------------
procedure   BTTree.TraceLR(root:longint = 1);
var fn:BTTree_TraceFunction;
    i:longword;
begin
   if (aTreeSize <> 0) and (aTraceFunc <> nil) and (root <= aTreeSize) then
   begin
      for i := 1 to aTreeSize do
      begin
         aTree[i].TrcFlag := 0;
         aTree[i].TrcPapa := 0;
      end;

      fn := aTraceFunc;
      while true do // without recursion
      begin
         if aTree[root].TrcFlag = 0 then  fn(aTraceFuncParm, aTree[root].Data, aTree[root].DataExt);
         i := root;
         root := aTree[i].Left;
         if (root <> 0) and ((aTree[i].TrcFlag and 1) = 0) then
         begin
            aTree[i].TrcFlag := aTree[i].TrcFlag or 1;
            aTree[root].TrcPapa := i;
            continue;
         end;
         root := aTree[i].Right;
         if (root <> 0) and ((aTree[i].TrcFlag and 2) = 0) then
         begin
            aTree[i].TrcFlag := aTree[i].TrcFlag or 2;
            aTree[root].TrcPapa := i;
            continue;
         end;
         root := aTree[i].TrcPapa;
         if root = 0 then Exit;
      end;
   end;
end;

//------------------------------------------------------------------------------
procedure   BTTree.TraceRL(root:longint = 1);
var fn:BTTree_TraceFunction;
    i:longword;
begin
   if (aTreeSize <> 0) and (aTraceFunc <> nil) and (root <= aTreeSize) then
   begin
      for i := 1 to aTreeSize do
      begin
         aTree[i].TrcFlag := 0;
         aTree[i].TrcPapa := 0;
      end;

      fn := aTraceFunc;
      while true do // without recursion
      begin
         if aTree[root].TrcFlag = 0 then  fn(aTraceFuncParm, aTree[root].Data, aTree[root].DataExt);
         i := root;
         root := aTree[i].Right;
         if (root <> 0) and ((aTree[i].TrcFlag and 2) = 0) then
         begin
            aTree[i].TrcFlag := aTree[i].TrcFlag or 2;
            aTree[root].TrcPapa := i;
            continue;
         end;
         root := aTree[i].Left;
         if (root <> 0) and ((aTree[i].TrcFlag and 1) = 0) then
         begin
            aTree[i].TrcFlag := aTree[i].TrcFlag or 1;
            aTree[root].TrcPapa := i;
            continue;
         end;
         root := aTree[i].TrcPapa;
         if root = 0 then Exit;
      end;
   end;
end;

//------------------------------------------------------------------------------
procedure   BTTree.Link_L(Parent,Child:longint);
begin
   if (Parent > 0) and (Parent <= aTreeSize) then aTree[Parent].Left := child;
end;

//------------------------------------------------------------------------------
procedure   BTTree.Link_R(Parent,Child:longint);
begin
   if (Parent > 0) and (Parent <= aTreeSize) then aTree[Parent].Right := child;
end;




end.
