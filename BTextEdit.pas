unit BTextEdit;

interface

//Lets build an editor     for those who love and use Pascal      sdex32 :)

{TODO
  test
  change tab size recalc #8
  viewmode copy enable
  viewmode with cursor move
  calback getclipboard sertoclipboard
  wrap view mode
  find / replace ?? replace callback ??  find in viewmode
}


type  BTEditor2 = class
         private
            atxt          :pointer;
            atxt_length   :longword;
            atxt_capacity :longword;

            aLines        :longword;
            aPageXsize    :longword;
            aPageYsize    :longword;
            aCursorPosX   :longword;
            aCursorPosY   :longword;
            aCursorOffset :longword;
            aPageXshift   :longword; // start from 1
            aPageYshift   :longword; // start from 1

            aTabSize      :longword;

            aTrimEnd      :boolean;
            aInsertMode   :boolean;
            aViewMode     :boolean;
            aAutoIdent    :boolean;
            aAutoMoveRow  :boolean;


            function    _Delete(stOfs,ssz:longword):string;
            function    _Copy(stOfs,ssz:longword):string;
            procedure   _Paste(stOfs:longword; const txt:string);

            procedure   _NeedCapacity(add_size:longword);
            procedure   _MakePlace(stOfs,ssz:longword);
            function    _GetLines:longword;
            procedure   _SetCursorPosition(mode,rx,ry:longint);
            procedure   _SetPoitionByOffset(ofs:longword);
            procedure   _Put(key:char);
            procedure   _Del(bs0_del1:longword);
            procedure   _GetLineOffsets(var BeginOfs,EndOffset:longword; ry:longint);
         public
            constructor Create;
            destructor  Destroy; override;
            procedure   Reset;

            procedure   SetPageSize(Cols,Rows :longword);
            procedure   SetCursorPos(Xpos,Ypos :longword);
            procedure   GetCursorPos(var Xpos,Ypos :longword);
            procedure   GetSelectionCursorPos(var X1pos,Y1pos, X2pos,Y2pos :longword);

            procedure   SetAsText(const value:string);
            function    GetAsText:string;

            procedure   Edit(Key_action:char);

            function    GetDisplay:string;
            function    GetDisplayEx(Xstart,Ystart,Columns,Rows,Flags:longword):string;


            property    LinesCount :longword read aLines;
            property    PageYStart :longword read aPageYshift;
            property    PageXStart :longword read aPageXshift;
            property    PageRows :longword read aPageYSize; //todo write
            property    PageColumns :longword read aPageXSize;
            property    CursorX :longword read aCursorPosX;
            property    CursorY :longword read aCursorPosY;
            property    Text :string read GetAsText write SetAsText;
            property    InsertMode :boolean read aInsertMode write aInsertMode;  // Insert or Overwrite mode
            property    AutoIdent :boolean read aAutoIdent write aAutoIdent;     // After new line start from prev line text start
//            property    AutoTabJump :boolean read aTabJump write aTabJump;       // Jump from tab to tab/text useful for python editing
//            property    TabSize :longword read aTabSize write _SetTabSize;       // tab equl to number of chars
            property    ViewMode :boolean read aViewMode write aViewMode;        // View or Edit mode
            property    AutoMoveRow :boolean read aAutoMoveRow write aAutoMoveRow; // Like notepad/visualC editor
//            property    DisableEditing :boolean read aDisableEditing write aDisableEditing; // Anather type of view mode with copy
//            property    PageStartOfs :longword read aPageStartOfs;
//            property    PageEndOfs :longword read aPageStartOfs;
//            property    TextLengthBytes :longword read aTxt_Length;


      end;




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
            aTabSize :longword;
            aTabSizeAdd :longword;
            aUndoIdx :longword;
            aUndoCnt :longword;
            aPageStartOfs :longword;
            aPageEndOfs :longword;
            aLastX :longint;
            aSearchResult :longint;
            aUserParam :longword;

            aMarkOneDelimiters :string;
            aSearchTxt :string;
            aReplaceTxt :string;
            aCopyBuff :string;
            aLineBeginChars :string;

            aInsertMode :boolean;
            aViewMode :boolean;
            aAutoIdent :boolean;
            aUse1310 :boolean;
            aMarkOn :boolean;
            aDisableEditing :boolean;
            aSearchCasesense :boolean;
            aSearchDown :boolean;
            aReplaceAll :boolean;
            aTrimEnd :boolean;
            aTabJump :boolean;
            aAutoMoveRow :boolean;
            aAddUndoBlock :boolean;

            aUndoBuffer :array[0..31] of string;
            aUndoPos :array[0..31] of longword;
            aUndoLen :array[0..31] of longword;
            aUndoOp  :array[0..31] of byte;

            procedure   _AddUndo(OP,aPos,aLen:longword; const Txt:string);
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
            procedure   Reset;

            procedure   SetAsText(const value:string);
            function    GetAsText:string;

            procedure   Edit(Key_action:char);

            procedure   GetPosFromScreenCord(Cx,Cy:longword; var Xpos,Ypos:longword);
            procedure   SetScreenCordFromPos(Xpos,Ypos:longword; var Cx,Cy:longword);
            procedure   SetPosition(X,Y:longint);
            procedure   GetPosition(var X,Y:longint);

            function    DeleteBlock(x1,y1,x2,y2:longword):string; //0,0 is current pos  TODO is that true
            function    CopyBlock(x1,y1,x2,y2:longword):string;
            procedure   PutBlock(X,Y:longword; const Txt:string);

            procedure   SetMarkArea(X1,Y1,X2,Y2:longword);
            procedure   GetMarkArea(var X1,Y1,X2,Y2:longword);
            procedure   ClearMarkArea;

            procedure   Cut;
            procedure   Copy;
            procedure   Paste;
            procedure   Find(const Txt:string; UpDown:boolean; CaseSense:boolean);
            procedure   Replace(const Txt,NewTxt:string; UpDown:boolean; CaseSense:boolean);
            procedure   ReplaceEx(const Txt,NewTxt:string; UpDown:boolean; CaseSense:boolean; CallBack,UserParam:pointer);
            procedure   Undo;

            procedure   DoCursorUp;
            procedure   DoCursorDown;
            procedure   DoCursorLeft;
            procedure   DoCursorRight;
            procedure   DoPageUp;
            procedure   DoPageDown;
            procedure   DoToLineBegin;
            procedure   DoToLineEnd;
            procedure   DoToTextBegin;
            procedure   DoToTextEnd;
            procedure   DoBackSpace;
            procedure   DoDeleteChar;
            procedure   DoSwitchInsertMode;
            procedure   DoMarkAll;
            procedure   DoUndo;
            procedure   DoTab;
            procedure   DoEnter;
            procedure   DoBeginMark;
            procedure   DoEndMark;
            procedure   DoUnmark;
            procedure   DoMarkWord;
            procedure   DoFind;
            procedure   DoReplace;
            procedure   DoMouseWheelUp;
            procedure   DoMouseWheelDown;
            procedure   DoCut; // same as above
            procedure   DoCopy;
            procedure   DoPast;

            function    GetDisplay:string;
            function    GetDisplayEx(Xstart,Ystart,Columns,Rows,Flags:longword):string;


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

const undo_put = 1;
      undo_del = 2;

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
   aViewMode := false;
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
   aAddUndoBlock := false;
   _NeedCapacity(1);
   atxt_length := 0; // make it again zero start from empty text
   aCopyBuff := '';
   aMarkOneDelimiters := '.,<>/?\|''";;][}{=+-_)(*&^%$#@!`~ '+#13#10#8#9#0;
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
   DoUnmark;
   aCopyBuff := '';
   aUndoIdx := 0;
   aUndoCnt := 0;
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
procedure   BTEditor._AddUndo(OP,aPos,aLen:longword; const Txt:string);
var i:longword;
begin
   if not aAddUndoBlock then
   begin
      i := aUndoIdx and $1F {31};
      aUndoBuffer[i] := Txt;
      aUndoPos[i] := aPos;
      aUndoLen[i] := aLen;
      aUndoOp[i] := Op;
      inc(aUndoIdx);
      inc(aUndoCnt);
      if aUndoCnt = 33 then aUndoCnt := 32;
   end;
end;

//------------------------------------------------------------------------------
procedure   BTEditor.Undo;
var s:string;
    x,y:longint;
begin
   if aUndoCnt > 0 then
   begin
      DoUnmark;
      s := aCopyBuff;
      aAddUndoBlock := true;
      dec(aUndoIdx);
      aBofs := aUndoPos[aUndoIdx];
      _OfsToPos(aBofs,x,y);
      aEofs := aBofs + aUndoLen[aUndoIdx] - 1;
      if aUndoOp[aUndoIdx] = undo_del then
      begin
         _Delete;
      end;
      if aUndoOp[aUndoIdx] = undo_put then
      begin
         _Paste(aUndoBuffer[aUndoIdx]);
      end;
      dec(aUndoCnt);
      aAddUndoBlock := false;
      aCopyBuff := s;
      SetPosition(x,y);
   end;
end;

//------------------------------------------------------------------------------
procedure   BTEditor._MarkWord;
var p:PTch_arr;
    x,xp,xb,xe:longint;
    c:char;
begin
   p := aTxt;
   x := longint(aS_ofs) + aXpos - 1;
   // go left
   c := p[x];
   if Pos(c,#13#10#32#8#9) = 0 then // not on blank
   begin
      xb := 0;
      xe := 0;
      if Pos(c,aMarkOneDelimiters) = 0 then // You are not on delimiter
      begin
         //go left
         xp := aXpos;
         repeat
           c := p[x-xb];
           dec(xp);
           inc(xb);
         until (xp = 0) or ( Pos(c,aMarkOneDelimiters) <> 0);
         dec(xb);
         if (xp <> 0) then dec(xb);

         //go right
         repeat
           c := p[x+xe];
           inc(xe);
         until (c = #13) or ( Pos(c,aMarkOneDelimiters) <> 0) or ((x+xe) >= atxt_length);
         if (x+xe) < atxt_length then dec(xe);
      end else begin
         //On Delimitrer
         xe := 1;
      end;
      aMarkBXpos := aXpos-xb;
      aMarkBYPos := aYpos;
      aMarkEXpos := aXpos+xe;
      aMarkEYpos := aYpos;
      aMarkON := false;
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
var i,x,t,j,d:integer;
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

   d := 1;
   p[x]:= Key; // !!WARNING !! do not send #13 if not in insert mode :(
   i := x;
   if Key = #13 then      // I have the test in .Edit()  :)
   begin
      inc(x);
      _MakePlace(x,1);
      p[x]:= #10;
      inc(d);
   end;
   _AddUndo(undo_del,x,d,'');
end;

//------------------------------------------------------------------------------
procedure   BTEditor._Del(bs0_del1:longword);
var p:PTch_arr;
    i,t,j,d:integer;
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
   d := 0;
   if (aXpos = 0) and (p[aBofs] = #10) then // back space test for #10
   begin
      if aBofs > 0 then
      begin
         d := 1;
         dec(aBofs); //dec to pos for #13
      end;
   end;
   aEofs := aBofs +d; // one char del

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
   _Delete;
//   _AddUndo(undo,aXpos,aYpos,_Delete); // send Delete result to undo buf
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

   if aMarkBXpos <> 0 then // ve have marked area
   begin
      if key_action >= #32 then // eny put char
      begin
         Cut;
      end else begin
         //Commands
         if (key_action = #24) then Cut; //Paste - in that case del marked //TODO if content
         if not aMarkOn then // marked process is finished
         begin
            if not ((key_action = #7{DEL}) or (key_action = #23{COPY}) or
                    (key_action = #28{Mouse wheel}) or (key_action = #29{Mouse wheel})
                   ) then  ClearMarkArea;
         end;
      end;
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
            Undo;
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
   SetAsText(GetAsText); // readjust tab size in whole doc
   //TODO preserve position
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
         _AddUndo(undo_put,aBOfs,length(Result),Result); // send Delete result to undo buf
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
      if cCount > 0 then
      begin
         if aBofs + cCount > atxt_Length then cCount := atxt_Length - aBofs;
         SetLength(Result,cCount);
         b := cCount*sizeof(char);
         S := pointer(longword(atxt) + aBofs*sizeof(char));
         D := @Result[1];
         Move(S^,D^,b);
         //stay at same pos
         _AddUndo(undo_del,aBOfs,length(Result),''); // send Delete result to undo buf
      end;
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
//      ClearMarkArea;
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
procedure   BTEditor.Find(const Txt:string; UpDown:boolean; CaseSense:boolean);
begin

end;

//------------------------------------------------------------------------------
procedure   BTEditor.Replace(const Txt,NewTxt:string; UpDown:boolean; CaseSense:boolean);
begin

end;

//------------------------------------------------------------------------------
procedure   BTEditor.ReplaceEx(const Txt,NewTxt:string; UpDown:boolean; CaseSense:boolean; CallBack,UserParam:pointer);
begin

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
procedure   BTEditor.DoCursorUp;
begin
   Edit(#1);
end;
//------------------------------------------------------------------------------
procedure   BTEditor.DoCursorDown;
begin
   Edit(#2);
end;
//------------------------------------------------------------------------------
procedure   BTEditor.DoCursorLeft;
begin
   Edit(#3);
end;
//------------------------------------------------------------------------------
procedure   BTEditor.DoCursorRight;
begin
   Edit(#4);
end;
//------------------------------------------------------------------------------
procedure   BTEditor.DoPageUp;
begin
   Edit(#5);
end;
//------------------------------------------------------------------------------
procedure   BTEditor.DoPageDown;
begin
   Edit(#6);
end;
//------------------------------------------------------------------------------
procedure   BTEditor.DoDeleteChar;
begin
   Edit(#7);
end;
//------------------------------------------------------------------------------
procedure   BTEditor.DoBackSpace;
begin
   Edit(#8);
end;
//------------------------------------------------------------------------------
procedure   BTEditor.DoTab;
begin
   Edit(#9);
end;
// #10 reserved
//------------------------------------------------------------------------------
procedure   BTEditor.DoToLineBegin;
begin
   Edit(#11);
end;
//------------------------------------------------------------------------------
procedure   BTEditor.DoToLineEnd;
begin
   Edit(#12);
end;
//------------------------------------------------------------------------------
procedure   BTEditor.DoEnter;
begin
   Edit(#13);
end;
//------------------------------------------------------------------------------
procedure   BTEditor.DoToTextBegin;
begin
   Edit(#14);
end;
//------------------------------------------------------------------------------
procedure   BTEditor.DoToTextEnd;
begin
   Edit(#15);
end;
//------------------------------------------------------------------------------
procedure   BTEditor.DoSwitchInsertMode;
begin
   Edit(#16);
end;
//------------------------------------------------------------------------------
procedure   BTEditor.DoUndo;
begin
   Edit(#17);
end;
//------------------------------------------------------------------------------
procedure   BTEditor.DoBeginMark;
begin
   Edit(#18);
end;
//------------------------------------------------------------------------------
procedure   BTEditor.DoEndMark;
begin
   Edit(#19);
end;
//------------------------------------------------------------------------------
procedure   BTEditor.DoMarkAll;
begin
   Edit(#20);
end;
//------------------------------------------------------------------------------
procedure   BTEditor.DoUnmark;
begin
   Edit(#21);
end;
//------------------------------------------------------------------------------
procedure   BTEditor.DoCut;
begin
   Edit(#22);
end;
//------------------------------------------------------------------------------
procedure   BTEditor.DoCopy;
begin
   Edit(#23);
end;
//------------------------------------------------------------------------------
procedure   BTEditor.DoPast;
begin
   Edit(#24);
end;
//------------------------------------------------------------------------------
procedure   BTEditor.DoMarkWord;
begin
   Edit(#25);
end;
//------------------------------------------------------------------------------
procedure   BTEditor.DoFind;
begin
   Edit(#26);
end;
//------------------------------------------------------------------------------
procedure   BTEditor.DoReplace;
begin
   Edit(#27);
end;
//------------------------------------------------------------------------------
procedure   BTEditor.DoMouseWheelUp;
begin
   Edit(#28);
end;
//------------------------------------------------------------------------------
procedure   BTEditor.DoMouseWheelDown;
begin
   Edit(#29);
end;






const
   dBeginDoc  = longint($80000001);
   dEndDoc    = longint($7FFFFFFF);
   dPageUp    = longint($80000000);
   dPageDown  = longint($7FFFFFFE);

   dir_BeginDoc  = $00000001;
   dir_EndDoc    = $00000002;
   dir_BeginLine = $00000004;
   dir_EndLine   = $00000008;
   dir_PageUp    = $00000010;
   dir_PageDown  = $00000020;
   dir_up        = $00000100;
   dir_down      = $00000200;
   dir_left      = $00000400;
   dir_right     = $00000800;



//------------------------------------------------------------------------------
constructor BTEditor2.Create;
begin
{
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
   acurX := 1;
   acurY := 1;
   aLines := 0;
   aTabSize := 3;
   aTabSizeAdd := 2; // aTabSize-1
   aInsertMode := true;
   aAutoIdent := true;
   aViewMode := false;
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
   aAddUndoBlock := false;

   aCopyBuff := '';
   aMarkOneDelimiters := '.,<>/?\|''";;][}{=+-_)(*&^%$#@!`~ '+#13#10#8#9#0;

 }
   aPageXSize := 55;
   aPageYSize := 25;

   aTabSize := 3;

   aTrimEnd := true;
   aInsertMode := true;
   aAutoIdent := true;
   aViewMode := false;
   aAutoMoveRow := false;


   atxt_length := 0;
   atxt_Capacity :=0;
   atxt := nil;

   _NeedCapacity(1);
   Reset;
end;

//------------------------------------------------------------------------------
destructor  BTEditor2.Destroy;
begin
   if atxt <> nil then ReallocMem(atxt,0); //free
   atxt := nil;
   inherited;
end;


//------------------------------------------------------------------------------
procedure   BTEditor2.Reset;
begin
   atxt_length := 0;
   aLines := 0;
   aCursorPosX := 1;
   aCursorPosY := 1;
   aPageXshift := 1;
   aPageYshift := 1;
end;

//------------------------------------------------------------------------------
const chunk_size = 32768;
procedure   BTEditor2._NeedCapacity(add_size:longword);
var nz :longword;
begin
   nz := atxt_Length + add_size;
   if nz > atxt_Capacity then
   begin
      atxt_capacity := ((nz div chunk_size) + 1) * chunk_size;
      ReallocMem(atxt, atxt_Capacity*sizeof(Char));
   end;
   atxt_Length := nz;
end;

//------------------------------------------------------------------------------
procedure   BTEditor2._MakePlace(stOfs,ssz:longword);
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
function    BTEditor2._GetLines:longword;
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
procedure   BTEditor2._SetCursorPosition(mode,rx,ry:longint);
var i,t,x:longint;
    op,oc,np:longword;
    lb:boolean;

   procedure UpDown(ud:longint);
   begin
      if ud <> 0 then
      begin
      np := aPageYshift + longword(longint(aCursorPosY) + ud) - 1;
      if longint(np) < 1 then np := 1;
      if np > aLines then np := aLines;
      if np < aPageYshift  then aPageYshift := np;
      if np >= (aPageYshift + aPageYSize) then aPageYshift := (np - aPageYSize) + 1;
      aCursorPosY := np - aPageYshift + 1;
      end;
   end;

   procedure LeftRight(lr:longint);
   begin
      if lr <> 0 then
      begin
      i := longint(aCursorPosX) + lr;
      if i <= 0 then // going outside the screen (left)
      begin
         if aPageXshift > 1 then
         begin
            np := longword(abs(i))+1;
            if np < aPageXshift then aPageXshift := aPageXshift - np
                                else aPageXshift := 1;
         end else begin
            lb := true;
         end;
         aCursorPosX := 1;
      end else begin
         if i > aPageXsize then // outside
         begin
            aPageXshift := aPageXshift + (longword(i) - aPageXsize);
            aCursorPosX := aPageXsize;
         end else begin
            aCursorPosX := longword(i); // inside the screen
         end;
      end;
      end;
   end;

begin

   if mode <> 0 then
   begin
      if (mode and dir_BeginDoc) <> 0 then
      begin
         aPageYshift := 1; // force begin doc
         aCursorPosY := 1;
         aPageXshift := 1;
         aCursorPosX := 1;
      end;
      if (mode and dir_EndDoc) <> 0 then
      begin
         if aLines > aPageYsize then
         begin
            aCursorPosY := aPageYsize;
            aPageYshift := aLines - aCursorPosY + 1;
         end else begin
            aPageYshift := 1;
            aCursorPosY := aLines;
         end;
         aPageXshift := 1;
         aCursorPosX := 1;
      end;
      if (mode and dir_BeginLine) <> 0 then
      begin
         aPageXshift := 1; // force begin Line
         aCursorPosX := 1;
      end;
      if (mode and dir_EndLine) <> 0 then
      begin
         // force end line
         _GetLineOffsets(op,np,0);
         op := np - op + 1;
         if op < aPageXshift then
         begin
            aPageXshift := op;
            aCursorPosX := 1;
         end else begin
            if op > (aPageXshift + aPageXsize) then
            begin
               aPageXshift := op - aPageXsize + 1;
               aCursorPosX := aPageXsize - 1;
            end else begin
               aCursorPosX := op - aPageXshift + 1;
            end;
         end;
      end;
      if (mode and dir_PageUp) <> 0 then
      begin
         i := longint(aPageYshift) - longint(aPageYsize);
         if i < 0 then
         begin
            i := 1;
            aCursorPosY := 1;
         end;
         aPageYshift := longword(i);
      end;
      if (mode and dir_PageDown) <> 0 then
      begin
         i := longint(aPageYshift) + longint(aPageYsize);
         if i >= longint(aLines) then
         begin
            if (i + aCursorPosY) > aLines then aCursorPosY := aLines - aPageYshift + 1;
            i := aPageYshift;
         end;
         aPageYshift := longword(i);
      end;
      if (mode and dir_Up) <> 0 then
      begin
         UpDown(-1);
      end;
      if (mode and dir_Down) <> 0 then
      begin
         UpDown(1);
      end;
      if (mode and dir_Left) <> 0 then
      begin
         LeftRight(-1);
      end;
      if (mode and dir_Right) <> 0 then
      begin
         LeftRight(1);
      end;
   end else begin
      LeftRight(rx);
      UpDown(ry);
   end;

   if aAutoMoveRow  then
   begin
      _GetLineOffsets(op,oc,0);
      x := oc - op + 1;
      if (aCursorPosX+aPageXshift -1) > x  then // outside the end
      begin
         aCursorPosX := x - aPageXshift + 1;
      end;
   end;

end;


//------------------------------------------------------------------------------
procedure   BTEditor2._SetPoitionByOffset(ofs:longword);
var  p:PTch_arr;
     i,x,y:longword;
begin
   p := aTxt;
   x := 0;
   y := 1;
   for i := 0 to aTxt_length - 1 do
   begin
      if p[i] = #13 then
      begin
         inc(y);
         x := 0;
      end else begin
         inc(x);
      end;
      if i = ofs then break;
   end;
   if x <> 0 then
   begin
      // tesy y is on the screen
      if (aPageYShift <= y) and ((aPageYShift+aPageYSize) > y ) then
      begin // inside
         aCursorPosY := y - aPageYShift + 1;
      end else begin
         aPageYShift := y;
         aCursorPosY := 1;
      end;
      if (aPageXShift <= X) and ((aPageXShift+aPageXSize) > x ) then
      begin // inside
         aCursorPosX := X - aPageXShift + 1;
      end else begin
         aPageXShift := X;
         aCursorPosX := 1;
      end;
   end;
end;

//------------------------------------------------------------------------------
procedure   BTEditor2.SetPageSize(Cols,Rows :longword);
begin
   if Cols = 0 then Cols := 1;
   if Rows = 0 then Rows := 1;
   aPageXSize := Cols;
   aPageYSize := Rows;
end;

//------------------------------------------------------------------------------
procedure   BTEditor2.SetCursorPos(Xpos,Ypos :longword);
begin
   _SetCursorPosition(0,longint(Xpos) - longint(aCursorPosX), longint(Ypos) - longint(aCursorPosY));
end;

//------------------------------------------------------------------------------
procedure   BTEditor2.GetCursorPos(var Xpos,Ypos :longword);
begin
   Xpos := aCursorPosX;
   Ypos := aCursorPosY;
end;

//------------------------------------------------------------------------------
procedure   BTEditor2.GetSelectionCursorPos(var X1pos,Y1pos, X2pos,Y2pos :longword);
begin  // if zero no selection
   //TODO
end;

//------------------------------------------------------------------------------
procedure   BTEditor2.SetAsText(const value:string);
var sz,b,c,m:longword;
    S,D:pointer;
    St:string;
    cc:char;
begin
   try
      Reset;
      sz := length(value);
      S := @value[1];
      if sz > 0 then
      begin
         b := 1;  // #13#10 -> #13
         c := 0;
         repeat
            if value[b] = #10 then inc(c);
            inc(b);
         until b > sz;
         if c > 0 then
         begin
            SetLength(St,sz-c);
            b := 1;
            m := 1;
            repeat
               cc := value[b];
               if cc <> #10 then
               begin
                  St[m] := cc;
                  inc(m);
               end;
               inc(b);
            until b > sz;
            S := @St[1];
            sz := sz - c;
         end;
      end;
      _NeedCapacity(sz);
      b := sz*sizeof(char);
      D := atxt;
      if b <> 0 then Move(S^,D^,b);
      aTxt_length := sz;
      aLines := _GetLines;
      _SetCursorPosition(dir_BeginDoc or dir_BeginLine,0,0); // goto 1,1
   except
      aTxt_length := 0;
   end;
end;


//------------------------------------------------------------------------------
function    BTEditor2.GetAsText:string;
var b,i,t,sz,w:longword;
    ST:string;
    c:char;
    p:PTch_arr;
begin
   Result := '';
   try
      if atxt_Length > 0 then
      begin
         sz := _GetLines + aTxt_length; // place to add #10
         SetLength(ST,sz);
         p := aTxt;
         i := 1;
         for b := 0 to aTxt_length - 1 do
         begin
            c := p[b];
            if c = #8 then continue; // remove tab dump space
            if c = #13 then
            begin
               if aTrimEnd then
               begin
                  if b > 0 then
                  begin
                     t := b - 1;
                     w :=0;
                     while((p[t]=#32) or (p[t]=#9) or (p[t]=#8)) and (t>0) do
                     begin
                        if p[t] <> #8 then inc(w); // space to
                        dec(t);
                     end;
                     if w <> 0 then i := i - w;
                  end;
               end;
               ST[i] := #13;
               inc(i);
               ST[i] := #10;
               inc(i);
               continue;
            end;
            ST[i] := c;
            inc(i);
         end;
         SetLength(ST,i-1);
         Result := ST;
      end;
   except
      Result := '';
   end;
end;



//------------------------------------------------------------------------------
procedure   BTEditor2._GetLineOffsets(var BeginOfs,EndOffset:longword; ry:longint);
var i,j:longword;
    Ypos:longint;
    p:PTch_arr;
begin
   BeginOfs := 0;
   EndOffset := 0;
   if aTxt_Length > 0 then
   begin
      Ypos := longint(aCursorPosY) + longint(aPageYshift) - 1 + ry;
      if Ypos <= 0 then
      begin
         BeginOfs := 0;
         EndOffset := 0;
         Exit;
      end;
      p := aTxt;
      i := 0;
      j := 1; // line num
      repeat
         if j = Ypos then break;
         if p[i] = #13 then
         begin
            inc(j);
            if i < aTxt_Length then BeginOfs := i + 1;
         end;
         inc(i);
      until i = aTxt_Length;
      EndOffset := BeginOfs;
      while (p[EndOffset] <> #13) and (EndOffset < aTxt_length) do inc(EndOffset);
   end;
end;


//------------------------------------------------------------------------------
function    BTEditor2._Delete(stOfs,ssz:longword):string;
var b,o,m:longword;
    S,D,P:pointer;
begin
   Result := '';
//   if aDisableEditing then Exit;
   try
      Result := '';
      if ssz > 0 then
      begin
         if stOfs + ssz > atxt_Length then ssz := atxt_Length - ssz;
         // delete
         m := (aTxt_Length - ssz)*sizeof(char);
         b := ssz*sizeof(char);
         o := stOfs*sizeof(char);
         S := pointer(longword(atxt) + o + b);
         D := pointer(longword(atxt) + o);
         SetLength(Result,ssz);
         P:=@Result[1];
         Move(D^,P^,b);
         Move(S^,D^,m);
         // Fill blanks in the end
         S := pointer(longword(atxt) + (atxt_Length*sizeof(char)) - b);
         FillChar(S^,b,0);
         dec(atxt_Length,ssz);
//         _AddUndo(undo_put,aBOfs,length(Result),Result); // send Delete result to undo buf
      end;
   except
      Result := '';
   end;
end;

//------------------------------------------------------------------------------
function    BTEditor2._Copy(stOfs,ssz:longword):string;
var b:longword;
    S,D:pointer;
    cCount :longword;
begin
   try
      Result := '';
      if ssz > 0 then
      begin
         if stOfs + ssz > atxt_Length then ssz := atxt_Length - stOfs;
         SetLength(Result,cCount);
         b := ssz*sizeof(char);
         S := pointer(longword(atxt) + stOfs*sizeof(char));
         D := @Result[1];
         Move(S^,D^,b);
         //stay at same pos
//         _AddUndo(undo_del,stOfs,length(Result),''); // send Delete result to undo buf
      end;
   except
      Result := '';
   end;
end;

//------------------------------------------------------------------------------
procedure   BTEditor2._Paste(stOfs:longword; const txt:string);
var j:longword;
    S,D:pointer;
begin
//   if aDisableEditing then Exit;
   try
      j := length(Txt);
      if j > 0 then
      begin
         if aInsertMode then _MakePlace(stOfs,j)
                        else if stOfs + j > atxt_Length then _MakePlace(stOfs,atxt_Length - (stOfs + j)+1);
         S := @Txt[1];
         D := pointer(longword(atxt) + stOfs*sizeof(char));
         Move(S^,D^,j*sizeof(char));
      end;
   except

   end;
end;

//------------------------------------------------------------------------------
procedure   BTEditor2._Del(bs0_del1:longword);
var p:PTch_arr;
    i,t,j,d,x:integer;
    bo,eo:longword;
    bb:boolean;
begin
   if aViewMode then Exit;
//   if aDisableEditing then Exit;
   _GetLineOffsets(bo,eo,0);
   p := aTxt;
   bs0_del1 := bs0_del1 and 1;
   x := (aCursorPosX + aPageXshift - 1) - 2 + longint(bs0_del1); // start from zero
   t := bo+x;
   if t < 0 then Exit; //outside
   if t > eo then
   begin
      j := t - eo; // size 6= end desire 9    678 on 9= 6
      _MakePlace(eo,j); // make place
      for d := 1 to j do  p[eo + d - 1]:= #32;
   end;
   _Delete(t,1);
   self._SetPoitionByOffset(t);
//   if bs0_del1 = 0 then
//   begin
//      bb := aAutoMoveRow;
//      aAutoMoveRow := true;
//      _SetCursorPosition(0,-1, 0);
//      aAutoMoveRow := bb;
//   end;

 (*
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
   d := 0;
   if (aXpos = 0) and (p[aBofs] = #10) then // back space test for #10
   begin
      if aBofs > 0 then
      begin
         d := 1;
         dec(aBofs); //dec to pos for #13
      end;
   end;
   aEofs := aBofs +d; // one char del

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
   _Delete;
//   _AddUndo(undo,aXpos,aYpos,_Delete); // send Delete result to undo buf
*)
end;

//------------------------------------------------------------------------------
procedure   BTEditor2._Put(key:char);
var i,x,t,j,d:integer;
    p:PTch_arr;
    bo,eo:longword;
begin
   // Regular char put on (Xpos,Ypos)
   _GetLineOffsets(bo,eo,0);
   p := aTxt;
   x := (aCursorPosX + aPageXshift - 1) - 1; // start from zero
   t := bo+x;
//???   _RemoveTab(x,false);
   d := 1;
   if t > eo then //eo point #13
   begin
      i := t - eo;
      d := i+1;
      _MakePlace(eo,d);
      for j := 0 to i do p[eo+j] := #32;
      p[t+1] := #13;
   end else begin
      if aInsertMode then _MakePlace(t,1);
   end;
   if (not aInsertMode) and (p[t] = #13) then
   begin
      inc(d);
      _MakePlace(t,1);
      p[t+1] := #13;
   end;
   p[t] := Key;

//   _AddUndo(undo_del,x,d,'');
end;



//------------------------------------------------------------------------------
procedure   BTEditor2.Edit(Key_action:char);
var i,j:integer;

   procedure PutChar;
   var ii,x,y:longint;
       LineChars:string;
       p:PTch_arr;
       c:char;
       o,bo,eo:longword;
   begin
      x := 0;
      if Key_action = #13 then
      begin
         if aAutoIdent and aInsertMode then
         begin
            _GetLineOffsets(bo,eo,0);
            LineChars := '';
            p := aTxt;
            for o := bo to eo do
            begin
               c := p[o];
               if (c <> #32) and (c <> #9) and (c <> #8) then break;
               if (c <> #8) then LineChars := LineChars + c;
            end;
         end;
         if aInsertMode then
         begin
            _put(Key_action);
            inc(aLines);
         end;
         _SetCursorPosition(0,0,1); // begin line new line
         _SetCursorPosition(dir_BeginLine,0,0);
         if aAutoIdent and aInsertMode then
         begin
            if Length(LineChars) > 0  then
            begin
               for ii := 1 to length(LineChars) do
               begin
                  _Put(LineChars[ii]);
                  //inc(aCursorPosX);
                  _SetCursorPosition(0,1,0);
               end;
            end;
         end;
      end else begin
         if not aViewMode then
         begin
            inc(x);
            _put(Key_action);
            if Key_action = #9 then
            begin
               if aTabSize > 0 then for ii := 1 to aTabSize - 1 do
               begin
                  _put(#8);
                  inc(x);
               end;
            end;
         end;
         _SetCursorPosition(0,x,0);
      end;
   end;


begin

   if key_action < #32 then
   begin
      // Editors logic
      case Key_action of
         //#0 reserved
         #1: _SetCursorPosition(dir_Up,       0,0); // Up
         #2: _SetCursorPosition(dir_Down,     0,0); // Down
         #3: _SetCursorPosition(dir_Left,     0,0); // Left
         #4: _SetCursorPosition(dir_Right,    0,0); // Right
         #5: _SetCursorPosition(dir_PageUp,   0,0); // PageUp
         #6: _SetCursorPosition(dir_PageDown, 0,0); // PageDown
         #7: _Del(1); // Delete (char) or (mark del)
         #8: _Del(0); // Back space
         #9: PutChar; // Tab
         //#10 reserved
         #11: _SetCursorPosition(dir_BeginLine, 0,0); //Home
         #12: _SetCursorPosition(dir_EndLine,   0,0); // End
         #13: PutChar;
         #14: _SetCursorPosition(dir_BeginDoc,  0,0); // ctrl home = begin doc
         #15: _SetCursorPosition(dir_EndDoc,    0,0); // ctrl end = end doc
         #16: aInsertMode := not aInsertMode; // insert
{
         #17: Undo // undo
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
         //#30 reserved
         //#31 reserved
 }


      end;
   end else begin
      PutChar;
   end;
end;

//------------------------------------------------------------------------------
function    BTEditor2.GetDisplay:string;
begin
   Result := GetDisplayEx(aPageXshift,aPageYshift,aPageXSize,aPageYSize,0);
end;

//------------------------------------------------------------------------------
function    BTEditor2.GetDisplayEx(Xstart,Ystart,Columns,Rows,Flags:longword):string;
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
//v2      tb := 0;
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
//v2            if i < sz then if p[i] = #10 then inc(i);
            if NewLineNextChar then Result := true;
            break;
         end;
         inc(i);
      until i > sz;
      if i > sz then Result := true;
//v2  inc(i);
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
//v2      tb := 0;
      repeat
         c := p[i];

//v2         if tb <> 0 then // tab replacer
//v2         begin
//v2            dec(i);
//v2            C := #32;
//v2            dec(tb);
//v2         end;
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
//v2            if i < sz then if p[i+1] = #10 then inc(i);
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
//      aPageEndOfs := i - 1;
      if cr > 1 then Result := Result + PutEnd; //#13#10;
   end;

end;



end.
