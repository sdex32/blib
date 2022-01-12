unit BTextEdit;

interface

//Lets build an editor     for those who love and use Pascal      sdex32 :)

{TODO
  remove space after text and before #13#10
  TAB -9 to 32
  undo
  Mark
  test
  change tab size recalc #8
  mark one word double click
  viewmode copy enable
  viewmode with cursor move
  calback getclipboard sertoclipboard
  wrap view mode
  find / replace ?? replace callback ??  find in viewmode
  replace marced if type char or Past !!!!!
}


type  BTEditor = class
         private
            atxt :pointer;
            atxt_length :longword;
            atxt_capacity :longword;
            aLines :longint;
            aS_ofs, aBofs,aEofs :longword;
            aCurX :longint; // on screen cord
            aCurY :longint;
            aXpos :longint; // on text cord
            aYpos :longint;
            aPageXsize :longint;
            aPageYsize :longint;
            aPageStart :longint;
            aPageXshift :longint;
            aMarkBXpos :longint;
            aMarkBYpos :longint;
            aMarkEXpos :longint;
            aMarkEYpos :longint;
            aMarkOn    :boolean;
            aInsertMode :boolean;
            aViewMode :boolean;
            aAutoIdent :boolean;
            aUse1310 :boolean;
            aTabSize :longword;
            aTabSizeAdd :longword;
            aUndoBuffer :array[0..31] of string;
            aUndoIdx :longword;
            aUndoCnt :longword;
            aPageStartOfs :longword;
            aPageEndOfs :longword;
            aCopyBuff :string;
            aLineBeginChars :string;
            aTrimEnd:boolean;
            aLastX:longint;
            aTabJump:boolean;
            aAutoMoveRow:boolean;
            aDisableEditing :boolean;

            aSearchTxt:string;
            aReplaceTxt:string;
            aSearchCasesense:boolean;
            aSearchDown:boolean;
            aReplaceAll:boolean;
            aSearchResult:longint;
            aMarkOneDelimiters:string;
            aUserParam:longword;


            procedure   _AddUndo(OP,X,Y:longword; const Txt:string);
            procedure   _NeedCapacity(add_size:longword);
            procedure   _SetPosX(value:longint);
            procedure   _SetPosY(value:longint);
            procedure   _MakePlace(stOfs,ssz:longword);
            function    _GetLines:longword;
            function    _GetStartOfs(Y:longword):longword;
            function    _GetLineEnd(sOfs:longword):longword;
            function    _GetLineBegin(sOfs:longword):longword;
            procedure   _Put(key:char);
            procedure   _Del(bs0_del1:longword);
            function    _Delete:string;
            function    _Copy:string;
            procedure   _Paste(const txt:string);
            function    _CordToPos(x,y:longint):longword;
            procedure   _OfsToPos(o:longword; var X,Y:longint);
            function    _RemoveTab(X:longint; del:boolean):longword;
            procedure   _SetTabSize(value:longword);
            procedure   _MarkWord;
            procedure   _Find;
            procedure   _Replace;
            procedure   _NormalizeStr(var S_in,S_out:string);
         public
            constructor Create;
            destructor  Destroy; override;
            procedure   SetPageSize(Cols,Rows :longword);

            procedure   Edit(Key_action:char);

            procedure   GetPosFromScreenCord(Cx,Cy:longword; var Xpos,Ypos:longword);
            procedure   SetScreenCordFromPos(Xpos,Ypos:longword; var Cx,Cy:longword);
            procedure   SetPosition(X,Y:longint);
            procedure   GetPosition(var X,Y:longint);

            function    DeleteBlock(x1,y1,x2,y2:longword):string; //0,0 is current pos
            function    CopyBlock(x1,y1,x2,y2:longword):string;
            procedure   PutBlock(X,Y:longword; const Txt:string);

            procedure   SetMarkArea(X1,Y1,X2,Y2:longword);
            procedure   GetMarkArea(var X1,Y1,X2,Y2:longword);
            procedure   ClearMarkArea;
            procedure   Cut;
            procedure   Copy;
            procedure   Paste;
            procedure   Reset;

            procedure   CursorUp;
            procedure   CursorDown;
            procedure   CursorLeft;
            procedure   CursorRight;
            procedure   PageUp;
            procedure   PageDown;
            procedure   ToLineBegin;
            procedure   ToLineEnd;
            procedure   ToTextBegin;
            procedure   ToTextEnd;
            procedure   BackSpace;
            procedure   DeleteChar;
            procedure   SwitchInsertMode;
            procedure   MarkAll;
            procedure   Undo;

            function    GetDisplay:string;
            function    GetDisplayEx(Xstart,Ystart,Columns,Rows,Flags:longword):string;

            procedure   SetAsText(const value:string);
            function    GetAsText:string;

            property    GetLines :longint read aLines;
            property    PageYStart :longint read aPageStart;
            property    PageXStart :longint read aPageXshift;
            property    PageRows :longint read aPageYSize; //todo write
            property    PageColumns :longint read aPageXSize;
            property    CursorX :longint read aCurX;
            property    CursorY :longint read aCurY;
            property    Xpos :longint read aXpos write _SetPosX;
            property    Ypos :longint read aYpos write _SetPosY;
            property    Text :string read GetAsText write SetAsText;
            property    InsertMode :boolean read aInsertMode write aInsertMode;  // Insert or Overwrite mode
            property    AutoIdent :boolean read aAutoIdent write aAutoIdent;     // After new line start from prev line text start
            property    AutoTabJump :boolean read aTabJump write aTabJump;       // Jump from tab to tab/text useful for python editing
            property    TabSize :longword read aTabSize write _SetTabSize;       // tab equl to number of chars
            property    ViewMode :boolean read aViewMode write aViewMode;        // View or Edit mode
            property    AutoMoveRow :boolean read aAutoMoveRow write aAutoMoveRow; // Like notepad/visualC editor
            property    DisableEditing :boolean read aDisableEditing write aDisableEditing; // Anather type of view mode with copy
            property    PageStartOfs :longword read aPageStartOfs;
            property    PageEndOfs :longword read aPageStartOfs;
            property    TextLengthBytes :longword read aTxt_Length;
      end;


implementation

type Tch_arr = array [0..0] of char;
     PTch_arr = ^Tch_arr;

//------------------------------------------------------------------------------
constructor BTEditor.Create;
begin
   atxt_length := 0;
   atxt_Capacity :=0;
   atxt := nil;
   aS_ofs := 0;
   aBofs := 0;
   aEofs := 0;
   aXpos := 1; //text starts from 1,1 first row first column
   aYpos := 1;
   aPageStart := 1;
   aPageXshift := 1;
   aPageYSize := 25;
   aPageXSize := 80;
   acurX := 1;
   acurY := 1;
   aLines := 0;
   aTabSize := 3;
   aTabSizeAdd := 2; // aTabSize-1
   aInsertMode := true;
   aAutoIdent := true;
   aViewMode := true;
   aMarkOn := false;
   aMarkBXpos := 0;
   aMarkBYpos := 0;
   aUse1310 := true;
   aUndoIdx := 0;
   aUndoCnt := 0;
   aTrimEnd := true;
   aTabJump := false;
   aAutoMoveRow := false;
   aDisableEditing := false;
   _NeedCapacity(1);
   atxt_length := 0; // make it again zero start from empty text
   aMarkOneDelimiters := ' '+#13#10;
end;

//------------------------------------------------------------------------------
destructor  BTEditor.Destroy;
begin
   if atxt <> nil then ReallocMem(atxt,0); //free
   inherited;
end;

//------------------------------------------------------------------------------
procedure   BTEditor.Reset;
begin
   aTxt_Length := 0; // delete text
   aLines := 0;
   SetPosition(1,1);
end;

//------------------------------------------------------------------------------
procedure   BTEditor.SetPageSize(Cols,Rows :longword);
begin
   if Cols = 0 then Cols := 1;
   if Rows = 0 then Rows := 1;
   aPageXSize := Cols;
   aPageYSize := Rows;
end;

//------------------------------------------------------------------------------
procedure   BTEditor._NeedCapacity(add_size:longword);
var sz,i :longword;
begin
   if atxt_Length + add_size > atxt_Capacity then
   begin
      for i := 0 to 14 do //15-8162 14-16k 13-32k 12-64K block round
      begin
         sz := $10000000 shr i;
         if ((sz shr 1) and add_size) <> 0 then break;
      end;
      inc(atxt_Capacity,sz);
      ReallocMem(atxt, atxt_Capacity*sizeof(Char));
   end;
   inc(atxt_Length,add_size);
end;

//------------------------------------------------------------------------------
procedure   BTEditor._MakePlace(stOfs,ssz:longword);
var S,D:pointer;
    b:longword;
begin
   if ssz > 0 then
   begin
      _NeedCapacity(ssz);
      b := (atxt_Length - stOfs)*sizeof(char); // bytes
      S := pointer(longword(atxt) + stOfs*sizeof(char));
      D := pointer(longword(S) + ssz*sizeof(char));
      Move(S^,D^,b);
   end;
end;


//------------------------------------------------------------------------------
function    BTEditor._GetLines:longword;
var i:longword;
    p:PTch_arr;
begin
   Result := 0;
   if aTxt_Length > 0 then
   begin
      Result := 1;
      p := aTxt;
      i := 0;
      repeat
         if p[i] = #13 then inc(Result);
         inc(i);
      until i = aTxt_Length;
   end;
end;

//------------------------------------------------------------------------------
procedure   BTEditor._OfsToPos(o:longword; var X,Y:longint);
var i:longword;
    p:PTch_arr;
begin
   X := 0;
   Y := 1;
   if (aTxt_Length > 0) and (o < aTxt_Length) then
   begin
      p := aTxt;
      i := 0;
      repeat
         inc(x);
         if o = i then Break;
         if p[i] = #13 then
         begin
           inc(i); // #10
           inc(Y);
           x := 0;
         end;
         inc(i);
      until i >= aTxt_Length;
   end;
end;

//------------------------------------------------------------------------------
function    BTEditor._GetStartOfs(Y:longword):longword;
var i,j:longword;
    p:PTch_arr;
begin
   Result := 0;
   if aTxt_Length > 0 then
   begin
      p := aTxt;
      i := 0;
      j := 1;
      repeat
         if j = y then break;
         if p[i] = #13 then
         begin
            inc(j);
            inc(i); // bypass 13
            if i >= aTxt_Length then break;
            if p[i] = #10 then inc(i);
            Result := i;
            continue
         end;
         inc(Result);
         inc(i);
      until i >= aTxt_Length;
   end;
   if Result > aTxt_Length then Result := 0;
end;

//------------------------------------------------------------------------------
function    BTEditor._GetLineEnd(sOfs:longword):longword;
var p:PTch_arr;
begin
   Result := sOfs;
   while Result < aTxt_Length do
   begin
      p := aTxt;
      if p[Result] = #13 then break;
      inc(Result);
   end;
end;

//------------------------------------------------------------------------------
function    BTEditor._GetLineBegin(sOfs:longword):longword;
var p:PTch_arr;
    c:char;
begin
   Result := sOfs;
   aLineBeginChars := '';
   while Result < aTxt_Length do
   begin
      p := aTxt;
      c := p[Result];
      if (c <> #32) and (c <> #9) and (c <> #8) then break;
      if (c <> #8) then aLineBeginChars := aLineBeginChars + c;
      inc(Result);
   end;
end;

//------------------------------------------------------------------------------
procedure   BTEditor._AddUndo(OP,X,Y:longword; const Txt:string);
begin
   aUndoBuffer[aUndoIdx and $1F {31}] :=
      char(op) +
      char(X and $FF) + char((X shr 8) and $FF) + char((X shr 16) and $FF) + char((X shr 24) and $FF)+
      char(Y and $FF) + char((Y shr 8) and $FF) + char((Y shr 16) and $FF) + char((Y shr 24) and $FF)+
      Txt;
   inc(aUndoIdx);
   inc(aUndoCnt);
   if aUndoCnt = 33 then aUndoCnt := 32;
end;

//------------------------------------------------------------------------------
procedure   BTEditor._MarkWord;
var p:PTch_arr;
    x,xp:longint;
    c:char;
begin
   p := aTxt;
   x := longint(aS_ofs) + aXpos - 1;
   xp := aXpos;
   // go left
   c := p[x];
   if Pos(c,aMarkOneDelimiters) = 0 then // You are not on delimiter
   begin
//      repeat
         c := p[x];

//      until ;
   end;




end;

//------------------------------------------------------------------------------
function    BTEditor._RemoveTab(X:longint; del:boolean):longword;
var p:PTch_arr;
    i:longint;
begin
   Result := 0;
   if aTxt_Length > 0 then
   begin
      p := aTxt;
      if p[x] = #8 then
      begin
         repeat
            dec(x);
         until p[x] <> #8;
      end;
      if p[x] = #9 then
      begin
         aBofs := x;
         aEofs := longword(x) + aTabSizeAdd;
         for i := 0 to aTabSizeAdd do p[x + i] := #32;
         if aTabJump and del then
         begin
            _Delete;
            Result := aTabSize;
         end;
      end;
   end;
end;


//------------------------------------------------------------------------------
procedure   BTEditor._Put(key:char);
var i,x,t,j:integer;
    p:PTch_arr;
begin
   if aDisableEditing then Exit;

   // array   H e l l o
   // Offset  0 1 2 3 4 5 6 7 8 9
   // Xpos    1 2 3 4 5 6 7 8 9 10
   //  lets put on Xpos = 6
   //  t = 5 offset of the first char after end
   //  i = 5 chars till end of line
   //  x = offset where to put new char
   //  Xpos > i   6>5 so I put out side the text
   if aViewMode then Exit;

   // Regular char put on (Xpos,Ypos)
   p := aTxt;
   t := _GetLineEnd(aS_Ofs);  // offset of end char
   i := t - longint(aS_ofs);  // chars till end of line
   x := longint(aS_ofs) + aXpos - 1; // put offset
   _RemoveTab(x,false);
   if longint(aXpos) > i  then
   begin
      i := longint(aXpos) - i; // char to fill blanks
      if not aInsertMode then  inc(i); // make place for one char
      _MakePlace(t,i); // make place
      for j := 1 to i do  p[t + j - 1]:= #32;
   end else begin
      if aInsertMode then _MakePlace(x,1);
   end;

   p[x]:= Key; // !!WARNING !! do not send #13 if not in insert mode :(
   if Key = #13 then      // I have the test in .Edit()  :)
   begin
      inc(x);
      _MakePlace(x,1);
      p[x]:= #10;
   end;
end;

//------------------------------------------------------------------------------
procedure   BTEditor._Del(bs0_del1:longword);
var p:PTch_arr;
    i,t,j:integer;
begin
   if aDisableEditing then Exit;
   //    H e l l o
   //ofs 0 1 2 3 4
   //pos 1 2 3 4 5   Xpos = 4
   //bs    sBofs = 2
   //del   sBofs = 3
   if aViewMode then Exit;
   p := aTxt;
   bs0_del1 := bs0_del1 and 1;

   i := _GetLineEnd(aS_Ofs) - aS_ofs + 1;
   if aXpos > i then // after the end of line
   begin
      t := aXpos - i; // size 6= end desire 9    678 on 9= 6
      i := i + aS_ofs - 1 ;
      _MakePlace(i,t); // make place
      for j := 1 to t do  p[i + j - 1]:= #32;
   end;

   i := longint(aS_ofs) + longint(aXpos) - 2 + longint(bs0_del1);  // Offset of del char
   if i < 0 then Exit; // bs not poosible on first char
   if bs0_del1 = 0 then dec(aXpos);  // if BS move position
   if _RemoveTab(i{aS_ofs + aXpos -1},true) <> 0 then
   begin
      dec(aXpos,aTabSizeAdd);
      _AddUndo(0,aXpos,aYpos,#9); // tab was deleted  //todo is this the place
      Exit;
   end;
   aBofs := i;
   if (aXpos = 0) and (p[aBofs] = #10) then // back space test for #10
   begin
      if aBofs > 0 then dec(aBofs); //dec to pos for #13
   end;
   aEofs := aBofs; // one char del

   if p[aBofs] = #13 then
   begin
      if (aEofs+1) < aTxt_Length then
      begin
         if p[aEofs+1] = #10 then inc(aEofs);
      end;
      Dec(aYpos);
      if aYpos = 0 then aYpos := 1;
      aS_Ofs := _GetStartOfs(aYpos);
      aXpos := _GetLineEnd(aS_Ofs) - aS_ofs + 1;
   end;
   _AddUndo(0,aXpos,aYpos,_Delete); // send Delete result to undo buf
end;

//------------------------------------------------------------------------------
procedure   BTEditor.Edit(Key_action:char);
var i,j:integer;


   procedure PutChar;
   var ii:longint;
   begin
      _put(Key_action);
      Inc(aXpos);
      if Key_action = #9 then
      begin
         if aTabSizeAdd > 0 then for ii := 1 to aTabSizeAdd do
         begin
            _put(#8);
            inc(aXpos);
         end;
      end;
   end;

   procedure __CursorUp;
   begin
      dec(aCurY);
      if aCurY = 0 then
      begin
         if aPageStart > 1 then dec(aPageStart);
         aCurY := 1;
         end;
      aYpos := aPageStart + aCurY - 1;
   end;

   procedure  __EndLine;
   begin
      aXpos := _GetLineEnd(aS_Ofs) - aS_ofs + 1;
      i := (aXpos - aPageXshift + 1); //relative X to 1..80  =  CurX
      if i >= 0 then
      begin
         if i > aPageXSize then
         begin
            aPageXshift := aXpos - aPageXsize + 1; {81 - 80 = 1 + 1 = 2}
         end;
      end else begin
         aPageXshift := aXpos;
      end;
      aCurX := aXpos - aPageXshift + 1;
   end;

   procedure __CursorDown;
   begin
      inc(aCurY);
      if aCurY = aPageYsize + 1 then // scroll
      begin
         inc(aPageStart);
         if aPageStart > aLines then aPageStart := aLines;
         aCurY := aPageYsize;
         if (aPageStart + aCurY - 1) > aLines then dec(aPageStart);
      end;
      aYpos := aPageStart + aCurY - 1;
      if aYpos > aLines then
      begin
         aYpos := aLines;
         aCurY := aYpos - aPageStart + 1;
      end;
   end;

begin
   if not aMarkOn then
   begin
     if not ((key_action = #22) or (key_action = #23)) then  ClearMarkArea;
   end;

   aLastX := aXpos;
   if key_action < #32 then
   begin
      // Editors logic
      case Key_action of
         #1: begin // Up
            if aViewMode then
            begin
               dec(aPageStart);
               if aPageStart = 0 then aPageStart := 1;
            end else begin
               __CursorUp;
            end;
         end;
         #2: begin // Down
            if aViewMode then
            begin
               inc(aPageStart);
               if aPageStart > aLines then aPageStart := aLines;
               if aPageStart = 0 then aPageStart := 1;
            end else begin
               __CursorDown;
            end;
         end;
         #3: begin // Left
            if aViewMode then
            begin
               dec(aPageXshift);
               if aPageXshift = 0 then aPageXshift := 1;
            end else begin
               dec(aCurX);
               if aCurX = 0 then
               begin
                  if aPageXshift > 1 then dec(aPageXshift);
                  aCurX := 1;
                  if aAutoMoveRow then
                  begin
                     if aYpos <> 1 then
                     begin
                        __CursorUp;
                        aS_Ofs := _GetStartOfs(aYpos);
                        __EndLine;
                     end;
                  end;
               end;
               aXpos := aPageXshift + aCurX - 1;
            end;
         end;
         #4: begin // Right
            if aViewMode then
            begin
               inc(aPageXshift);
               //put some limit
               if aPageXshift > 32000 then aPageXshift := 32000;
            end else begin
               inc(aCurX);
               if aCurX = aPageXsize + 1 then
               begin
                  inc(aPageXshift);
                  aCurX := aPageXsize;
               end;
               aXpos := aPageXshift + aCurX - 1;
               if aAutoMoveRow then
               begin
                  i := _GetLineEnd(aS_Ofs) - aS_ofs + 1;
                  if aXpos > i then
                  begin
                     if aYpos < aLines then
                     begin
                        aXpos := 1;
                        aPageXshift := 1;
                        __CursorDown;
                     end;
                  end;
               end;
            end;
         end;
         #5: begin // PageUp
            if aViewMode then
            begin
               dec(aPageStart,aPageYsize);
               if aPageStart <= 0 then aPageStart := 1;
            end else begin
               dec(aPageStart,aPageYsize);
               if aPageStart <= 0 then
               begin
                  aPageStart := 1;
                  aYpos := 1;
                  aCurY := 1;
               end else begin
                  dec(aYpos,aPageYsize);
               end;
            end;
         end;
         #6: begin // PageDown
            if aViewMode then
            begin
               inc(aPageStart,aPageYsize);
               if aPageStart >= aLines then aPageStart := aLines-1;
            end else begin
               i := aPageStart + aPageYsize;
               if i <= aLines then
               begin
                  aPageStart := i;
                  inc(aYpos,aPageYSize);
               end;
            end;
         end;
         #7: begin // Delete (char) or (mark del)
            if not aViewMode then
            begin
               if aMarkBXpos <> 0 then Cut
                                  else _Del(1);
            end;
         end;
         #8: begin // Back space
            if not aViewMode then _Del(0);
         end;
         #9: begin // Tab
            if not aViewMode then PutChar;
         end;
         //#10 reserved
         #11: begin // Home
            if aViewMode then
            begin
               aPageXshift := 1;
            end else begin
               aCurX := 1;
               aPageXshift := 1;
               aXpos := 1;
            end;
         end;
         #12: begin // End
            if aViewMode then
            begin
               aPageXshift := _GetLineEnd(_GetStartOfs(aPageStart));
            end else begin
               __EndLine;
            end;
         end;
         #13: begin // New line
            if not aViewMode then
            begin
               if aInsertMode then _Put(#13);
               aXpos := 1;
               if aInsertMode then inc(aYpos);
               aLines := _GetLines;
               if aAutoIdent then
               begin
                  i := _GetLineBegin(aS_ofs) - aS_ofs;
                  if i > 0 then
                  begin
                     aS_Ofs := _GetStartOfs(aYpos);
                     for j := 1 to length(aLineBeginChars) do
                     begin
                        Key_action := aLineBeginChars[j];
                        PutChar;
                     end;
                  end;
                  aXpos := i + 1;
               end;
            end;
         end;
         #14: begin // ctrl home = begin doc
            if aViewMode then
            begin
               aPageStart := 1;
               aPageXshift := 1;
            end else begin
               aCurX := 1;
               aCurY := 1;
               aPageStart := 1;
               aPageXshift := 1;
               aXpos := 1;
               aYpos := 1;
            end;
         end;
         #15: begin // ctrl end = end doc
            if aViewMode then
            begin
               aPageStart := aLines;
               aPageXshift := 1;
            end else begin
               if aLines > (aPageStart + aPageYSize - 1) then
               begin
                  aPageStart := aLines - (aPageYsize div 5); //set 20 % of PageYsize;
               end else begin
                  aPageStart := 1;
               end;
               aYpos := aLines;
               aXpos := 1;
               aPageXshift := 1;
               aCurX := 1;
               aCurY := aYpos - aPageStart + 1;
            end;
         end;
         #16: begin // insert
            aInsertMode := not aInsertMode;
         end;
         #17: begin // undo
         end;
         #18: begin // mark begin
            aMarkBXpos := aXpos;
            aMarkBYpos := aYpos;
            aMarkEXpos := aXpos;
            aMarkEYpos := aYpos;
            aMarkON := true;
         end;
         #19: begin // mark end
            aMarkEXpos := aXpos;
            aMarkEYpos := aYpos;
            aMarkON := false;
         end;
         #20: begin // mark all
            aMarkBXPos := 1;
            aMarkBYPos := 1;
            aMarkEYpos := aLines;
            aS_Ofs := _GetStartOfs(aLines);
            aMarkEXpos := _GetLineEnd(aS_Ofs) - aS_ofs + 1;
            aMarkON := false;
         end;
         #21: begin // unmark
            ClearMarkArea;
         end;
         #22: begin // Cut(mark)
            Cut;
         end;
         #23: begin // Copy(mark)
            Copy;
         end;
         #24: begin // Past(mark)
            Paste;
         end;
         #25: begin //double click select word until delimiter
            _MarkWord;
         end;
         #26: begin // Find
            _Find;
         end;
         #27: begin // Replace
            _Replace;
         end;
         #28: begin // mouse wheel up;
            if aPageStart > 1 then
            begin
               dec(aYpos);
               dec(aPageStart);
            end;
         end;
         #29: begin // mouse wheel down;
            if aPageStart + aPageYsize <= aLines then
            begin
               inc(aPageStart);
               inc(aYpos);
            end;
         end;
      end;
   end else begin
      if not aViewMode then PutChar;
   end;
   //Adjust Pos & calc Cursor Position
   SetPosition(aXpos,aYpos); // fill aS_ofs  default without cursor

end;



//------------------------------------------------------------------------------
procedure   BTEditor.SetPosition(X,Y:longint);
var p:PTch_arr;
    i:longint;
begin
   if aViewMode then
   begin //for view mode
      if X < 1 then X := 1;
      if X > 32000 then X := 32000;
      if Y < 1 then Y := 1;
      if Y > aLines then Y := aLines;
//      aPageStart := Y;
//      aPageXshift := X;
      aCurX := 0;  // no cursor in view mode
      aCurY := 0;
   end else begin
      // X limit clipper
      if X < 1 then X := 1;
      // screen limits
      if (X - aPageXshift + 1) > aPageXSize then // calc relative Xpos to X in 1..80
      begin
          aPageXshift := X - aPageXsize + 1; {81 - 80 = 1 + 1 = 2}
      end;
      // screen limits
      if Y > aLines then Y := aLines; //!!! can put zero
      // Y limit cliper
      if Y < 1 then Y := 1;
      if Y < aPageStart  then aPageStart := Y;
      if Y >= (aPageStart + aPageYSize) then aPageStart := (Y - aPageYSize) + 1;


      aYpos := Y;
      aXpos := X;

      aS_Ofs := _GetStartOfs(aYpos);
      if aAutoMoveRow  then
      begin
         i := _GetLineEnd(aS_Ofs) - aS_ofs + 1;
         if aXpos > i then
         begin
            aXpos := i;
            if (aXpos - aPageXshift + 1) > aPageXSize then
            begin
               aPageXshift := aXpos - aPageXsize + 1; {81 - 80 = 1 + 1 = 2}
            end;
            if (aXpos - aPageXshift + 1) <= 0 then
            begin
               aPageXshift := aXpos;
            end;
         end;
      end;

      aLines := _GetLines;

      aCurX := aXpos - aPageXshift + 1;
      aCurY := aYpos - aPageStart + 1;

      // tab corrector TabJump
      if aTabJump then
      begin
         p := aTxt;
         x := longint(aS_Ofs) + Xpos -1;
         if p[x] = #8 then // jump left to test for tab
         begin
            repeat
               if aLastX > aXpos then dec(X)
                                 else inc(x);
            until p[X] <> #8;
            x := x - longint(aS_Ofs) +1;
//            aCurX := X - aPageXshift + 1;
            aXpos := X;
         end;
      end;

      if aMarkON then
      begin
         aMarkEXpos := aXpos;
         aMarkEYpos := aYpos;
      end;

      aCurX := aXpos - aPageXshift + 1;
      aCurY := aYpos - aPageStart + 1;

   end;
end;

//------------------------------------------------------------------------------
procedure   BTEditor._SetTabSize(value:longword);
begin
   if value = 0  then value := 3; //default
   if value > 80 then value  := 80; //stupid
   aTabSize := value;
   aTabSizeAdd := value -1 ;
   //todo readjust tab size in whole dok
end;

//------------------------------------------------------------------------------
procedure   _AdjustOfs(var B,E:longword);
var C:longword;
begin
   if B > E then begin C:=B; B:=E; E:=C; end;
end;

//------------------------------------------------------------------------------
function    BTEditor._Delete:string;
var b,o,m:longword;
    S,D,P:pointer;
    cCount :longword;
begin
   if aDisableEditing then Exit;
   try
      Result := '';
      _AdjustOfs(aBofs,aEofs);
      cCount := aEofs - aBofs;
      if cCount > 0 then
      begin
         if aBofs + cCount > atxt_Length then cCount := atxt_Length - aBOfs;
         // delete
         m := (aTxt_Length - cCount)*sizeof(char);
         b := cCount*sizeof(char);
         o := aBofs*sizeof(char);
         S := pointer(longword(atxt) + o + b);
         D := pointer(longword(atxt) + o);
         SetLength(Result,cCount);
         P:=@Result[1];
         Move(D^,P^,b);
         Move(S^,D^,m);
         // Fill blanks in the end
         S := pointer(longword(atxt) + (atxt_Length*sizeof(char)) - b);
         FillChar(S^,b,0);
         //stay at same pos
         dec(atxt_Length,cCount);
      end;
   except
      Result := '';
   end;
end;

//------------------------------------------------------------------------------
function    BTEditor._Copy:string;
var b:longword;
    S,D:pointer;
    cCount :longword;
begin
   try
      Result := '';
      _AdjustOfs(aBofs,aEofs);
      cCount := aEofs - aBofs;
      if aBofs + cCount > atxt_Length then cCount := atxt_Length - aBofs;
      SetLength(Result,cCount);
      b := cCount*sizeof(char);
      S := pointer(longword(atxt) + aBofs*sizeof(char));
      D := @Result[1];
      Move(S^,D^,b);
      //stay at same pos
   except
      Result := '';
   end;
end;

//------------------------------------------------------------------------------
procedure   BTEditor._Paste(const txt:string);
var j,m:longword;
    S,D:pointer;
begin
   if aDisableEditing then Exit;
   try
      j := length(Txt);
      if j > 0 then
      begin
         m := aBofs;
         if aInsertMode then _MakePlace(aBofs,j)
                        else if aBofs + j > atxt_Length then _MakePlace(aBofs,atxt_Length - (aBofs + j)+1);
         S := @Txt[1];
         D := pointer(longword(atxt) + aBofs*sizeof(char));
         Move(S^,D^,j*sizeof(char));
         aEofs := m + j;
      end;
   except

   end;
end;

//------------------------------------------------------------------------------
function    BTEditor._CordToPos(x,y:longint):longword;
var xe:longint;
begin
   if (x = 0) and (y = 0) then
   begin
      x := aXpos;
      y := aYpos;
   end;
   if y = 0 then y := 1;
   if y > aLines then y := aLines;
   Result := _GetStartOfs(y);
   xe := _GetLineEnd(Result);
   if x > xe then x := xe;
   Result := Result + longword(x-1); //-1 pos to ofs    zero start ofs
end;

//------------------------------------------------------------------------------
function    BTEditor.DeleteBlock(x1,y1,x2,y2:longword):string;
begin
   aBofs := _CordToPos(x1,y1);
   aEofs := _CordToPos(x2,y2);
   Result := _Delete;
end;

//------------------------------------------------------------------------------
function    BTEditor.CopyBlock(x1,y1,x2,y2:longword):string;
begin
   aBofs := _CordToPos(x1,y1);
   aEofs := _CordToPos(x2,y2);
   Result := _Copy;
end;

//------------------------------------------------------------------------------
procedure   BTEditor.PutBlock(X,Y:longword; const Txt:string);
begin
   aBofs := _CordToPos(x,y);
   _Paste(Txt);
end;


//------------------------------------------------------------------------------
procedure   BTEditor._SetPosX(value:longint);
begin
   SetPosition(Value,aCurY);
end;

//------------------------------------------------------------------------------
procedure   BTEditor._SetPosY(value:longint);
begin
   SetPosition(aCurX,Value);
end;

//------------------------------------------------------------------------------
procedure   BTEditor.GetPosition(var X,Y:longint);
begin
   X := aXpos;
   Y := aYpos;
end;

//------------------------------------------------------------------------------
procedure   BTEditor.SetMarkArea(X1,Y1,X2,Y2:longword);
begin
   aMarkBXpos := X1;
   aMarkBYpos := Y1;
   aMarkEXpos := X2;
   aMarkEYpos := Y2;
end;

//------------------------------------------------------------------------------
procedure   BTEditor.GetMarkArea(var X1,Y1,X2,Y2:longword);
var A:longword;
begin
   X1 := aMarkBXpos;
   Y1 := aMarkBYpos;
   X2 := aMarkEXpos;
   Y2 := aMarkEYpos;
   if Y1 > Y2 then
   begin
      A := Y1; Y1 := Y2; Y2 := A;
      A := X1; X1 := X2; X2 := A;
   end;
   if (Y1 = Y2) and (X1 > X2) then
   begin
      A := X1; X1 := X2; X2 := A;
   end;
end;

//------------------------------------------------------------------------------
procedure   BTEditor.ClearMarkArea;
begin
   aMarkBXpos := 0;
   aMarkBYpos := 0;
   aMarkOn := false;
end;

//------------------------------------------------------------------------------
procedure   BTEditor.Cut;
begin
   if aDisableEditing then Exit;
   if aMarkBXpos <> 0 then
   begin
      aCopyBuff := DeleteBlock(aMarkBXpos, aMarkBYpos, aMarkEXpos, aMarkEYPos);
      ClearMarkArea;
      _OfsToPos(aBofs,aXpos,aYpos);
      SetPosition(aXpos,aYpos); //adjust all need
   end;
end;

//------------------------------------------------------------------------------
procedure   BTEditor.Copy;
begin
   if aMarkBXpos <> 0 then
   begin
      aCopyBuff := CopyBlock(aMarkBXpos, aMarkBYpos, aMarkEXpos, aMarkEYPos);
      ClearMarkArea;
   end;
end;

//------------------------------------------------------------------------------
procedure   BTEditor.Paste;
begin
   if aDisableEditing then Exit;
   if length(aCopyBuff) > 0 then
   begin
      PutBlock(aXpos,aYpos,aCopyBuff);
      _OfsToPos(aEofs,aXpos,aYpos);
      SetPosition(aXpos,aYpos); //adjust all need
   end;
end;

//------------------------------------------------------------------------------
procedure   BTEditor.GetPosFromScreenCord(Cx,Cy:longword; var Xpos,Ypos:longword);
begin
   aLastX := 10000;  // before tab 0= after tab
   if Cx = 0 then Cx := 1; // clip
   if Cy = 0 then Cy := 1;
   if Cx > aPageXsize then Cx := aPageXsize;
   if Cy > aPageYsize then Cy := aPageYSize;

   Xpos := Cx + aPageXshift - 1;
   Ypos := Cy + aPageStart - 1;
end;

//------------------------------------------------------------------------------
procedure   BTEditor.SetScreenCordFromPos(Xpos,Ypos:longword; var Cx,Cy:longword);
begin
   if Ypos = 0  then Ypos := 1;
   if Ypos < aPageStart then
   begin
      Cy := 1;
      Cx := 1;
      Exit;
   end else begin
      if Ypos > (aPageStart + aPageYSize -1) then
      begin
         Cy := aPageYsize;
         Cx := aPageXsize;
         Exit;
      end else begin // inside page
         Cy := Ypos - aPageStart + 1;
      end;
   end;
   if Xpos = 0  then Xpos := 1;
   if Xpos < aPageXshift then
   begin
      Cx := 1;
   end else begin
      if Ypos > (aPageXshift + aPageXSize -1) then
      begin
         Cx := aPageXsize;
      end else begin // inside page
         Cx := Xpos - aPageXshift + 1;
      end;
   end;
end;

//------------------------------------------------------------------------------
procedure   BTEditor.SetAsText(const value:string);
var sz,b,c,m:longword;
    S,D:pointer;
    St:string;
    cc:char;
begin
   try
      aTxt_Length := 0;
      sz := length(value);
      S := @value[1];
      if sz > 0 then
      begin
         //test for missed #10
         b := 1;
         c := 0;
         repeat
            if value[b] = #13 then
            begin
               if (b+1) <= sz then
               begin
                  if value[b+1] <> #10 then
                  begin
                     inc(c); // count missed #10;
                  end;
               end;
            end;
            inc(b);
         until b > sz;
         if c > 0 then
         begin
            // add missed #10
            SetLength(St,sz+c);
            b := 1;
            m := 1;
            repeat
               cc := value[b];
               if cc = #13 then
               begin
                  St[m] := cc;
                  if (b+1) <= sz then
                  begin
                     if value[b+1] <> #10 then
                     begin
                        inc(m);
                        St[m] := #10;
                     end;
                  end;
               end else St[m] := cc;
               inc(m);
               inc(b);
            until b > sz;

            S := @St[1];
            sz := sz + c;
         end;
      end;
      _NeedCapacity(sz);
      b := sz*sizeof(char);
      D := atxt;
      if b <> 0 then Move(S^,D^,b);
      aTxt_length := sz;
      aLines := _GetLines;
      setPosition(1,1);
   except
      aTxt_length := 0;
   end;
end;



//------------------------------------------------------------------------------
procedure   BTEditor._NormalizeStr(var S_in,S_out:string);
var t,w,i,j,b:longword;
    c : char;
begin
   b := length(S_in);
   if b = 0 then
   begin
      S_out := '';
   end else begin
      j := 1;
      for i := 1 to b do
      begin
         c := S_in[i];
         if c = #8 then continue;
//flag         if c = #10 then continue;
         if c = #13 then
         begin
            if aTrimEnd then
            begin
               t := i - 1;
               if t > 0 then
               begin
                  w:=0;
                  while((S_in[t]=#32) or (S_in[t]=#9) or (S_in[t]=#8)) and (t>0) do
                  begin
                     if S_in[t] <> #8 then inc(w); // space to
                     dec(t);
                  end;
                  if w <> 0 then j := j - w;
               end;
            end;
         end;
         S_in[j] := c;
         inc(j);
      end;
      SetLength(S_out,j);
      for i:= 1 to j do S_out[j] := S_in[i]; // copy only normalized
   end;
end;

//------------------------------------------------------------------------------
function    BTEditor.GetAsText:string;
var b:longword;
    S,D:pointer;
    ST:string;
begin
   Result := '';
   try
      if atxt_Length > 0 then
      begin
         SetLength(ST,atxt_Length);
         b := atxt_Length*sizeof(char);
         S := atxt;
         D := @ST[1];
         Move(S^,D^,b);
         _NormalizeStr(ST,Result);
      end;
   except
      Result := '';
   end;
end;

//------------------------------------------------------------------------------
procedure   BTEditor._Replace;
begin

end;

//------------------------------------------------------------------------------
procedure   BTEditor._Find;
var  p :PTch_arr;
     i,m,j,k,l,X,Y :longint;
     c:char;
begin
   aSearchResult := 100; // not found
   if aTxt_Length > 0 then
   begin
      l := 0;
      j := Length(aSearchTxt);
      if j> 0 then
      begin
         i := _GetStartOfs(aYpos) + aXpos - 1; // start from current pos
         if aSearchDown then inc(i) else dec(i); //move a little bit
         if i < 0 then exit;
         if  i > (aTxt_length-j) then Exit;

         p := aTxt;
         repeat
            c := p[i];
            if c = aSearchTxt[1] then
            begin
               m := 0;
               for k := 0 to j-1 do if p[i+k] = aSearchTxt[k+1] then inc(m) else break;
               if m = j then
               begin // found
                  l := i;
                  break;
               end;
               if aSearchDown then inc(i) else dec(i);
            end;
         until (i <= 0) or (i > (aTxt_length-j)) or (l=1);
      end;
      if l <> 0 then
      begin
         _OfsToPos(L,X,Y);
         SetPosition(X,Y);
         aSearchResult := 0; //Ok found
      end;
   end;
end;


//------------------------------------------------------------------------------
function    BTEditor.GetDisplay:string;
begin
   Result := GetDisplayEx(aPageXshift,aPageStart,aPageXSize,aPageYSize,0);
end;

//------------------------------------------------------------------------------
function    BTEditor.GetDisplayEx(Xstart,Ystart,Columns,Rows,Flags:longword):string;
var sz,i,yy,xx,ls,tb,cr,lastxx:longword;
    c:char;
    p :PTch_arr;


   function PutEnd:string;
   var j,m:longint;
   begin
      Result := '';
      if (Flags and 1) <> 0 then
      begin
         if xx < Columns then
         begin
            j := Columns - lastxx;
            SetLength(Result,j);
            for m := 1 to j do Result[m] := #32;
         end;
      end;
      if (Flags and 2) = 0 then Result := Result + #13#10;
      lastxx:=0;
   end;

   function NewLineNextChar:boolean;
   begin
      Result := false;
      xx := 0;
      inc(yy); // new line
      ls := 0;
      tb := 0;
      inc(i); //next char
      if i > sz then Result := true;
   end;

   function ByPassToNewLine:boolean;
   begin
      Result := false;
      inc(Ystart); // next row requare
      Dec(Rows);
      if Rows = 0 then Result := true;; // no need to scan any more
//      LineTxt := LineTxt + #13#10; // prepare for next row
      // scan to new line
      repeat
         if p[i] = #13 then
         begin
            if i < sz then if p[i] = #10 then inc(i);
            if NewLineNextChar then Result := true;
            break;
         end;
         inc(i);
      until i > sz;
      if i > sz then Result := true;
      inc(i);
   end;

begin
   if Rows = 0 then Rows := 1;
   p:= atxt;
   cr := Rows;
   sz := atxt_Length;
   Result := '';
   if (sz > 0) and ((Xstart and $FFFFFF)>0) and (Ystart>0) and (Columns > 0) then
   begin
      yy := 1;
      xx := 0;
      ls := 0;
      i := 0;
      tb := 0;
      repeat
         c := p[i];

         if tb <> 0 then // tab replacer
         begin
            dec(i);
            C := #32;
            dec(tb);
         end;
         inc(xx);
         if c = #8 then c := #32; //tab blanks
         if c = #9 then //tab
         begin
           //todo flag set to 32
    //        tb := aTabSize - 1;
//            inc(i);
//            continue;
         end;
         if c = #13 then  //new line indicator
         begin
            if yy = Ystart then // line finish before LineSize;
            begin
               if ByPassToNewLine then break;
//               if (ls = 0) and ((Xstart and $80000000) <> 0) then AddOffset;
               Result := Result + PutEnd; //#13#10; // prepare for next row
               continue;
            end;
            if i < sz then if p[i+1] = #10 then inc(i);
            if NewLineNextChar then break;
            continue;
         end;
         lastxx := xx;
         if (yy = Ystart) and (xx >= Xstart) then // need line
         begin
  //          if (ls = 0) and ((Xstart and $80000000) <> 0) then AddOffset;
            Result := Result + c;
            inc(ls);
            if ls = Columns then
            begin
               if ByPassToNewLine then break;    // exit rows done
               Result := Result + PutEnd; //#13#10; // prepare for next row
               continue;
            end;
         end;
         inc(i);
      until i >= sz;
      aPageEndOfs := i - 1;
      if cr > 1 then Result := Result + PutEnd; //#13#10;
   end;

end;

// V E R B S
//------------------------------------------------------------------------------
procedure   BTEditor.CursorUp;
begin
   Edit(#1);
end;
//------------------------------------------------------------------------------
procedure   BTEditor.CursorDown;
begin
   Edit(#2);
end;
//------------------------------------------------------------------------------
procedure   BTEditor.CursorLeft;
begin
   Edit(#3);
end;
//------------------------------------------------------------------------------
procedure   BTEditor.CursorRight;
begin
   Edit(#4);
end;
//------------------------------------------------------------------------------
procedure   BTEditor.PageUp;
begin
   Edit(#5);
end;
//------------------------------------------------------------------------------
procedure   BTEditor.PageDown;
begin
   Edit(#6);
end;
//------------------------------------------------------------------------------
procedure   BTEditor.ToLineBegin;
begin
   Edit(#11);
end;
//------------------------------------------------------------------------------
procedure   BTEditor.ToLineEnd;
begin
   Edit(#12);
end;
//------------------------------------------------------------------------------
procedure   BTEditor.ToTextBegin;
begin
   Edit(#14);
end;
//------------------------------------------------------------------------------
procedure   BTEditor.ToTextEnd;
begin
   Edit(#15);
end;
//------------------------------------------------------------------------------
procedure   BTEditor.BackSpace;
begin
   Edit(#8);
end;
//------------------------------------------------------------------------------
procedure   BTEditor.DeleteChar;
begin
   Edit(#7);
end;
//------------------------------------------------------------------------------
procedure   BTEditor.SwitchInsertMode;
begin
   Edit(#16);
end;
//------------------------------------------------------------------------------
procedure   BTEditor.MarkAll;
begin
   Edit(#20);
end;
//------------------------------------------------------------------------------
procedure   BTEditor.Undo;
begin
   Edit(#17);
end;







//------------------------------------------------------------------------------
procedure EDIT_Colorize(const txt:string; var Formated_txt:string; schema:pointer);
var sz,i,f:longword;
    c:char;
    s:string;
begin
   sz := length(txt);
   SetLength(Formated_txt,sz);
   i := 1;
   f := 0; //format per char
   s := '';
   repeat
      c := txt[i];
      s := s + c;


      Formated_txt[i] := char(f);
      inc(i);
   until i < sz;

end;



end.
