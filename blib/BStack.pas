unit BStack;

interface

type  BTStack_Item = record
         reg_A :longword;
         reg_B :longword;
         reg_C :longword;
         reg_D :longword; {4x4 = 16bytes}
      end;
      BTStackArr = array [0..0] of BTStack_Item;
      PBTStackArr = ^BTStackArr;

      BTStack = class
         private
            aStackSize  :longword;
            aStack      :PBTStackArr;
            aStackPos   :longword;
            aStackExpSize :longword;
         public
            Data        :BTStack_Item;
            constructor Create(ExpSize:longword);
            destructor  Destroy; override;
            function    Push:boolean; overload;
            function    Pop:boolean; overload;
            function    Push(dat:longword):boolean; overload;
            function    Pop( var dat:longword):boolean; overload;
            function    Push(dat,datExt:longword):boolean; overload;
            function    Pop( var dat,datExt:longword):boolean; overload;
            function    Read:boolean;
            function    Write:boolean;
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
end;

//------------------------------------------------------------------------------
destructor  BTStack.Destroy;
begin
   if aStack <> nil then ReallocMem(aStack,0);
   inherited;
end;

//------------------------------------------------------------------------------
function    BTStack.Push:boolean;
begin
   Result := false;
   inc(aStackPos);
   if aStackPos > aStackSize then
   begin
      inc(aStackSize,aStackExpSize+1);
      ReallocMem(aStack,aStackSize*sizeof(BTStack_Item));
      aStack[0].reg_C := 0;
      aStack[0].reg_D := 0;
   end;
   if aStack <> nil then
   begin
      aStack[aStackPos].reg_A := Data.reg_A;
      aStack[aStackPos].reg_B := Data.reg_B;
      aStack[aStackPos].reg_C := Data.reg_C;
      aStack[aStackPos].reg_D := Data.reg_D;
      aStack[0].reg_A := aStackPos;
      aStack[0].reg_B := aSTackSize;
//      p := pointer(longword(aStack) + (aStackPos-1)*sizeof(BTStack_Item));
//      Move(Data,p^,sizeof(BTStack_Item));
      Result := true;
   end else aStackPos:=0;
end;

//------------------------------------------------------------------------------
function    BTStack.Read:boolean;
begin
   Result := false;
   if (aStack <> nil) and (aStackPos > 0) then
   begin
      Data.reg_A := aStack[aStackPos].reg_A;
      Data.reg_B := aStack[aStackPos].reg_B;
      Data.reg_C := aStack[aStackPos].reg_C;
      Data.reg_D := aStack[aStackPos].reg_D;
      aStack[0].reg_A := aStackPos;
      aStack[0].reg_B := aSTackSize;
//      p := pointer(longword(aStack) + (aStackPos-1)*sizeof(BTStack_Item));
//      Move(p^,Data,sizeof(BTStack_Item));
      Result := true;
   end;
end;

//------------------------------------------------------------------------------
function    BTStack.Write:boolean;
begin
   Result := false;
   if (aStack <> nil) and (aStackPos > 0) then
   begin
      aStack[aStackPos].reg_A := Data.reg_A;
      aStack[aStackPos].reg_B := Data.reg_B;
      aStack[aStackPos].reg_C := Data.reg_C;
      aStack[aStackPos].reg_D := Data.reg_D;
      aStack[0].reg_A := aStackPos;
      aStack[0].reg_B := aSTackSize;
//      p := pointer(longword(aStack) + (aStackPos-1)*sizeof(BTStack_Item));
//      Move(p^,Data,sizeof(BTStack_Item));
      Result := true;
   end;
end;


//------------------------------------------------------------------------------
function    BTStack.Pop:boolean;
begin
   Result := Read;
   if Result then
   begin
      if aStackPos > 0 then dec(aStackPos);
      if aStackPos = 0 then Result := false; // end marker
   end;
end;

//------------------------------------------------------------------------------
procedure   BTStack.Reset;
begin
   FillChar(Data,sizeof(BTStack_Item),0);
   aStackPos := 0;
end;

//------------------------------------------------------------------------------
function    BTStack.Push(dat:longword):boolean;
begin
   Data.reg_A := dat;
   Result := push;
end;

//------------------------------------------------------------------------------
function    BTStack.Pop( var dat:longword):boolean;
begin
   Result := Pop;
   if Result then dat := Data.reg_A;
end;

//------------------------------------------------------------------------------
function    BTStack.Push(dat,datExt:longword):boolean;
begin
   Data.reg_A := dat;
   Data.reg_B := datExt;
   Result := push;
end;

//------------------------------------------------------------------------------
function    BTStack.Pop( var dat,datExt:longword):boolean;
begin
   Result := Pop;
   if Result then
   begin
      dat := Data.reg_A;
      datExt := Data.reg_B;
   end;
end;


end.
