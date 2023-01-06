unit BStack;

interface

type  BTStackArr = array [0..0] of longword;
      PBTStackArr = ^BTStackArr;

      BTStack = class
         private
            aStackSize  :longword;
            aStack      :PBTStackArr;
            aStackPos   :longword;
            aStackExpSize :longword;
         public
            constructor Create(ExpSize:longword);
            destructor  Destroy; override;
            function    Push(dat:longword):boolean;
            function    Pop( var dat:longword):boolean;
            procedure   Reset;
            property    Stack:PBTStackArr read aStack;
            property    StackPos:longword read aStackPos;
      end;



implementation

//------------------------------------------------------------------------------
constructor BTStack.Create(ExpSize:longword);
begin
   aStack := nil;
   Reset;
   aStackSize := 0;
   aStackExpSize := 1024;
end;

//------------------------------------------------------------------------------
destructor  BTStack.Destroy;
begin
   if aStack <> nil then ReallocMem(aStack,0);
   inherited;
end;

//------------------------------------------------------------------------------
procedure   BTStack.Reset;
begin
   aStackPos := 0;
end;

//------------------------------------------------------------------------------
function    BTStack.Push(dat:longword):boolean;
begin
   Result := false;
   if (aStackPos + 1) > aStackSize then
   begin
      inc(aStackSize,aStackExpSize);
      ReallocMem(aStack,aStackSize*sizeof(longword));
   end;
   if aStack <> nil then
   begin
      inc(aStackPos);
      aStack[aStackPos]:= Dat;
      Result := true;
   end else aStackPos:=0;
end;

//------------------------------------------------------------------------------
function    BTStack.Pop( var dat:longword):boolean;
begin
   Result := false;
   if aStack <> nil then
   begin
      if aStackPos > 0 then
      begin
         dat := aStack[aStackPos];
         dec(aStackPos);
         Result := true;
      end;
   end;
end;



end.
