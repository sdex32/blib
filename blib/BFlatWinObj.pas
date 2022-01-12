unit BFlatWinObj;

interface

//todo !!! memory release all gets

const BFlatWinEvent_onIdle     = 0;
      BFlatWinEvent_onMouse    = 1;
      BFlatWinEvent_onClick    = 2;
      BFlatWinEvent_onKey      = 3;
      BFlatWinEvent_onTimer    = 4;
      BFlatWinEvent_onQuit     = 5;
      BFlatWinEvent_onPaint    = 6;
      BFlatWinEvent_onActive   = 7;
      BFlatWinEvent_onDeActive = 8;
      BFlatWinEvent_onSize     = 9;
      BFlatWinEvent_onCommand  = 10;
      BFlatWinEvent_onCreate   = 11;
      BFlatWinEvent_onOther    = 12;


type  BTFlatWinObj = class
         private
            aEvent      :array[0..12] of procedure(UserParm:longword);
            aUserParm   :array[0..12] of longword;
            aLastError  :longint;
            aPapa       :longword;
            ah_wnd      :longword;
            aWinDC      :longword;
            aBackGr     :longword;
            aBrush      :Longword;
            acmd_h      :longword;
            acmd_m      :longword;
            acmd_w      :longword;
            acmd_d      :longword;
            auTimer     :longword;
            aCursor     :longword;
            amsd_Buttons :longword;           // mouse button status
            amsd_Xpos   :longword;           // mouse Xpos
            amsd_Ypos   :longword;           // mouse Ypos
            amsd_Xdiff  :longint;         // mouse X diff
            amsd_Ydiff  :longint;         // mouse Y diff
            akbdBegin   :longword;           // local teil begin pointer
            akbdEnd     :longword;           // local teil end pointer
            akbdBuff    :array [0..32] of word;  // local keyboard tail
            akeyscanmap :array [0..128] of byte; // scan code map
            akeyhitc    :byte;            // marker scan code is hit
            aActive     :boolean;
            aFinish     :boolean;
            aStandAlone :boolean;
         //   aClass      :longword; //?????????? todo
            function    _DoCtrl(CtrlType:string; CtrlFlag,CtrlID:longword; Xpos,Ypos,Xlng,Ylng:longword;
                                CtrlName: string; CallbK,UserParm:longword):longword;
         public

            constructor Create(parent:longword);
            destructor  Destroy; override;

            procedure   FlushMessages;

            procedure   SetWindowEvent(Eventnum,Eventptr,UserParam:longword);
            procedure   SetWindowCaption(Caption:pchar);
            procedure   SetWindowCursor(Cursor:longword);
            procedure   SetWindowPosition(Xpos,Ypos:longint);
            procedure   GetWindowPosition(var Xpos,Ypos:longint);
            procedure   SetWindowSize(Xlng,Ylng:longint);
            procedure   SetWindowClientSize(Width,Height:longint);
            procedure   GetWindowClientSize(var Width,Height:longint);
            procedure   SetWindowMaximaze(how:longword);
            procedure   SetWindowBorder(Border:longword);
            procedure   SetWindowIcon(Icon:longword);
            procedure   SetWindowBackground(BK:longword);
            function    GetScreenXlng:longword;
            function    GetScreenYlng:longword;
            function    GetScreenBPP:longword;
            procedure   RePaintWindow;

            function    Mouse_GetXpos:longword;
            function    Mouse_GetYpos:longword;
            function    Mouse_GetButtons:longword;
            procedure   Mouse_Get(var Buttons,Xpos,Ypos:longword);
            procedure   Mouse_GetDiff(var Xdif,Ydif:longint);
            procedure   Mouse_SetPosition(Xpos,Ypos:longword);

            function    TestKey(akey:longword):boolean;
            function    KeyPressed:boolean;
            function    GetKey:longword;
            procedure   FlushKeys;
            function    WaitKeyGet:longword;
            procedure   WaitKey;
            function    KeyHit(VK:longword):longword;

            function    BeginTimer(Time_delay:longword):longword;
            procedure   WaitTimer(The_timer:longword);
            procedure   Delay(Delay_time:longword);

            procedure   GDI_DrawPicBuffer(Xpos,Ypos,Xlng,Ylng,Bpp,SXlng,SYlng,SrcPtr:longword);

   //         function    ScrollBar(Xpos,Ypos,Xlng,Ylng,Min,Max,Pos,HV:longint; BtnProc:proc; IntPtr:ptrtoint):longword;

            function    AddImage(Xpos,Ypos,Xlng,Ylng:longword; FileName: string; BtnProc:pointer; UserParam:longword):longword;
            function    AddButton(Xpos,Ypos,Xlng,Ylng:longword; BtnName: string; BtnProc:pointer; UserParam:longword):longword;
            function    AddLabel(Xpos,Ypos,Xlng,Ylng:longword; BtnName: string):longword;
            function    AddCheckBox(Xpos,Ypos,Xlng,Ylng:longword; BtnName: string; BoolPtr:pointer; InitValue:boolean):longword;
            function    AddEditBox(Xpos,Ypos,Xlng,Ylng:longword; aText:pointer):longword;
            function    AddScrollBar(Xpos,Ypos,Xlng,Ylng,Min,Max,Pos,HV:longint; BtnProc:pointer; UserParam:longword; IntPtr:pointer):longword;
            function    AddListBox(Xpos,Ypos,Xlng,Ylng:longword; Items: string; BtnProc:pointer; UserParam:longword):longword;
//ComboBox
//Memo
//Radio

            procedure   Control_SetText(Hand:longword; NewText: string);
            procedure   Control_Enabled(Hand:longword; Enabled:boolean);
            procedure   Control_SetCheckBox(Hand:longword; Checked:boolean);

            property    GetWindowHandle:longword read ah_wnd;
            property    GetWindowDC:longword read aWinDC;
            property    GetLastError:longint read aLastError;
      end;


implementation

uses  windows,messages,shellapi;

{_______________________________________________________________________________

+–––––––––––––––––––––––––––––––––+
|             /-\                 |          B  U  T  C  H  E  R
|           XX| |XXXXXXXXXXX      |WW
|             | |                 |WW
|   H     \\ /   \ //             |WW
|   HH     \       /              |WW
|   HHHHHHHHHHH__/                |WW
|   HHHHHHHHHHHH                  |WW
| HHHHHHHHHHHHHHHHH               |WW
+–––––––––––––––––––––––––––––––––+WW
       WWWWWWWWWWWWWWWWWWWWWWWWWWWWWW


}

function _WindowProc(aWindow: HWnd; AMessage: UINT; WParm : WPARAM;
                    LParm: LPARAM): LRESULT; stdcall;
var
    obj : BTFlatWinObj;
    res : LRESULT;
    i:longword;
    X,Y:longint;
    ps : paintstruct;
    pr : procedure(a:longword);
    bo : ^boolean;
    ip : ^longint;
    apt,id,prm:longword;
    Scroll : TSCROLLINFO;
    s:string;
    so:^string;

begin
   res := 0;

   Obj := BTFlatWinObj(GetProp(aWindow,'FlatWObj'));
   if assigned(Obj) then
   begin

   OBJ.acmd_h := aWindow;
   OBJ.acmd_m := aMessage;
   OBJ.acmd_w := wParm;
   OBJ.acmd_d := lParm;

   OBJ.aEvent[BFlatWinEvent_OnOther](OBJ.aUserParm[BFlatWinEvent_OnOther]);

   case aMessage of
   WM_COMMAND:
      begin
         id := wParm and $FF;
         apt := 0;
         if lParm <> 0 then apt := GetProp(lParm,'fw_cbf1');
         if apt <> 0 then
         begin
            prm := GetProp(lParm,'fw_cbf1u');
            case id of
              1: begin//Button///////////////////////////////////
                    pr := pointer(apt);
                    pr(prm); //call procedure of button
                 end;
              3: begin//CheckBox/////////////////////////////////
                    bo := pointer(apt);
                    if (SendMessage(lParm, BM_GETCHECK, 0, 0) = BST_CHECKED )
                    then bo^ := true else bo^ := false;
                 end;
              4: begin//EditBox//////////////////////////////////
                    so := pointer(apt);
                    case HiWord(WParm) of
                       en_change:
                       begin
                          i:=GetWindowTextLength(lParm);
                          SetLength(s,i+1);
                          GetWindowText(lParm,@s[1],i+1);
                          string(so^) := string(@s[1]);
                       end;
                    end;
                 end;
            end;
         end;
         if id <> 4 then SetFocus(Obj.ah_Wnd);

      end;

   WM_ACTIVATE:
      begin
         if (wParm = WA_ACTIVE) or (wParm = WA_CLICKACTIVE) then
         begin
//todo            if m_bServerRunning then WaveOutRestart(m_hWaveOut);
            Obj.aActive := true;
//todo            AfterActive := 1;
//todo            SetWinCursor(aCursor);
            OBJ.aEvent[BFlatWinEvent_OnActive](OBJ.aUserParm[BFlatWinEvent_OnActive]);
         end ;
         if wParm = WA_INACTIVE then
         begin
//todo            if m_bServerRunning then WaveOutPause(m_hWaveOut);
            Obj.aActive := false;
            OBJ.aEvent[BFlatWinEvent_OnDeActive](OBJ.aUserParm[BFlatWinEvent_OnDeActive]);
         end;
      end;


   WM_CREATE:
      begin
         { make some initialization }
         OBJ.aEvent[BFlatWinEvent_onCreate](OBJ.aUserParm[BFlatWinEvent_onCreate]);
         Obj.auTimer := SetTimer(Obj.ah_wnd,1,62,nil); {// 1/16 from second  }
         SetFocus(Obj.ah_wnd);
      end;

   WM_SYSCOMMAND:
      begin
         if wparm = SC_CLOSE then
         begin
           PostMessage(Obj.ah_wnd,WM_CLOSE,0,0);
           res := 1;
         end;
      end;

   WM_CLOSE:  { begin the end story }
      begin
         OBJ.aEvent[BFlatWinEvent_onQuit](OBJ.aUserParm[BFlatWinEvent_onQuit]);
         ReleaseDC(Obj.ah_wnd,Obj.aWinDC);
         KillTimer(Obj.ah_wnd,Obj.auTimer);
         if OBj.aStandAlone then DestroyWindow(Obj.ah_Wnd) { this will cal WM_DESTROY }
                            else begin
                                   CloseWindow(OBj.ah_wnd);
                                   SetFocus(Obj.aPapa);
                                 end;
         Obj.ah_wnd := 0;
       //  res := 1;
      end;

   WM_DESTROY: { This the last message }
      begin
         if OBj.aStandAlone then
         begin
         PostQuitMessage(0); { send to close WM_QUIT}
         end;
         //res := 1;
      end;

   {// Turn off the cursor since this is a full-screen app }
   WM_SETCURSOR:
      begin
        if LOWORD(lParm) = HTCLIENT then
         begin
            Obj.SetWindowCursor(Obj.aCursor);
            res := 1;
         end;
      end;


   WM_TIMER:
      begin
         if wParm = 1 then  // Initialize timer
         begin
            OBJ.aEvent[BFlatWinEvent_onTimer](OBJ.aUserParm[BFlatWinEvent_onTimer]);
            //BUG???
            // if still true time out
         end;
      end;

   WM_PAINT:
      begin
         // NORMAL
         i:=Obj.aWinDC;
         Obj.aWinDC:=BeginPaint(Obj.ah_Wnd,ps);
         OBJ.aEvent[BFlatWinEvent_onPaint](OBJ.aUserParm[BFlatWinEvent_onPaint]);
         EndPaint(Obj.ah_Wnd,ps);
         Obj.aWinDC := i;
      end;

   WM_ERASEBKGND:
      begin
         if Obj.aBackGr = 1 then Res := 1 // I handle that to stop flicking;
      end;

   WM_SIZE:
      begin
         OBJ.aEvent[BFlatWinEvent_onSize](OBJ.aUserParm[BFlatWinEvent_onSize]);
      end;


{///////////  used messages }

   {-=* MOUSE *=-}

   WM_MOUSEMOVE:
      begin
         {//fwKeys = wParam;       // key flags }
 //        Obj.amsd_Buttons := 0;
         if (wParm and MK_LBUTTON) > 0 then Obj.amsd_Buttons := Obj.amsd_Buttons or 1;
         if (wParm and MK_RBUTTON) > 0 then Obj.amsd_Buttons := Obj.amsd_Buttons or 2;
         X := longword(lParm and $FFFF);  { horizontal position of }
         Y := longword(lParm shr 16);     { vertical }
         Obj.amsd_Xdiff := longint(X) - longint(Obj.amsd_Xpos);
         Obj.amsd_Ydiff := longint(Y) - longint(Obj.amsd_Ypos);
         Obj.amsd_Xpos := X;
         Obj.amsd_Ypos := Y;
           { onMouse trap }

         OBJ.aEvent[BFlatWinEvent_onMouse](OBJ.aUserParm[BFlatWinEvent_onMouse]);
 //       Res := 1;
      end;
   WM_LBUTTONDOWN:
      begin
         Obj.amsd_Buttons  := Obj.amsd_Buttons or 1;
         OBJ.aEvent[BFlatWinEvent_onClick](OBJ.aUserParm[BFlatWinEvent_onClick]);
//         Res := 1;
      end;
   WM_LBUTTONUP:
      begin
         Obj.amsd_Buttons  := Obj.amsd_Buttons and 2;
         OBJ.aEvent[BFlatWinEvent_onClick](OBJ.aUserParm[BFlatWinEvent_onClick]);
//         Res := 1;
      end;
   WM_RBUTTONDOWN:
      begin
         Obj.amsd_Buttons := Obj.amsd_Buttons or 2;
         OBJ.aEvent[BFlatWinEvent_onClick](OBJ.aUserParm[BFlatWinEvent_onClick]);
//         Res := 1;
      end;
   WM_RBUTTONUP:
      begin
         Obj.amsd_Buttons := Obj.amsd_Buttons and 1;
         OBJ.aEvent[BFlatWinEvent_onClick](OBJ.aUserParm[BFlatWinEvent_onClick]);
//         Res := 1;
      end;

   // WM_LBUTTONDBLCLK
   // WM_RBUTTONDBLCLK

   {-=* KEY *=-}

   WM_SYSKEYDOWN:
       begin
//todo            alt_key:=true;
       end;

   WM_KEYDOWN:
      begin
           {// input key value in KBD tail}
           i := ( Obj.akbdbegin + 1 ) and 31;
           if  i <> Obj.akbdend then
           begin
              Obj.akbdbuff[Obj.akbdbegin] := wParm;
              Obj.akbdbegin := i;
           end;
           { onKeyboard; }
         Obj.akeyscanmap[(lParm shr 16) and $7F ] := 1;
         Obj.akeyhitc := 1;
           { onKey trap }
         OBJ.aEvent[BFlatWinEvent_onKey](OBJ.aUserParm[BFlatWinEvent_onKey]);
//         Res := 1;
      end;
   WM_KEYUP:
      begin
//todo        case wParam of
//todo           VK_CONTROL: ctrl_key:=false;
//todo           VK_SHIFT  : shift_key:=false;
//todo        end;

        Obj.akeyscanmap[(lParm shr 16) and $7F ] := 0;
        Obj.akeyhitc := 0;
//        Res := 1;
      end;

   WM_VSCROLL,
   WM_HSCROLL:
      begin
         if lParm <> 0 then
         begin
           //MessageBox(0,'ascxasc,','ascsa',mb_ok);
            Scroll.cbSize := sizeof(Scroll);
            Scroll.fMask := SIF_POS or SIF_RANGE;

            GetScrollInfo(lParm,SB_CTL,Scroll);

            y :=(Scroll.nMax - Scroll.nMin + 1) div 10;
            x := Scroll.nPos;
       //  MessageBox(0,pchar(tostr(x)),'ascsa',mb_ok);
            case loWord(wParm) of
             SB_LINEUP: begin
                           dec(x);
                           if x < longint(Scroll.nMin) then x := Scroll.nMin;
                        end;
             SB_LINEDOWN: begin
                           inc(x);
                           if x > longint(Scroll.nMax) then x := Scroll.nMax;
                        end;
             SB_PAGEUP: begin
                           x := x - y;
                           if x < longint(Scroll.nMin) then x := Scroll.nMin;
                        end;
             SB_PAGEDOWN: begin
                           x := x + y;
                           if x > longint(Scroll.nMax) then x := Scroll.nMax;
                        end;
             SB_THUMBTRACK: x := HiWord(wParm);
            end; // case
//         MessageBox(0,pchar(tostr(x)),'aaaa',mb_ok);
            SetScrollPos(lParm,SB_CTL,x,true);
            if GetProp(lParm,'fw_cbf2') <> 0 then
            begin
               ip := pointer(GetProp(lParm,'fw_cbf2'));
               ip^ := x;
            end;
            if GetProp(lParm,'fw_cbf1') <> 0 then
            begin
               pr := pointer(GetProp(lParm,'fw_cbf1'));
               prm := GetProp(lParm,'fw_cbf1u');
               pr(prm);
            end;
         end; // Scroll <> nil
      end;

   end; { case }
   end; { obj }

   if res = 0 then res := DefWindowProc(aWindow, AMessage, WParm, LParm);
   _WindowProc := res;
end;


procedure   BTFlatWinObj.FlushMessages;
var
   LoopMe : boolean;
   aMSG   : MSG;
Begin
   if not aStandAlone then Exit;

   if aFinish then exit;

   { Stay in this loop while not active or minimized }
   while (not aActive) and GetMessage(aMSG,0,0,0) do

   begin
      If aMSG.Message = WM_Quit then
      begin
         aFinish := true;
      end;
      TranslateMessage(aMSG);
      DispatchMessage (aMSG);
   end;

   if aFinish then  ExitProcess(0);
   LoopMe := true;

   While LoopMe do
   begin
      if PeekMessage(aMSG,0,0,0,PM_REMOVE or PM_NOYIELD) then
      begin
         If aMSG.Message = WM_Quit then
         begin
             LoopMe := false;
             aFinish := true;
         end;
         TranslateMessage(aMSG);
         DispatchMessage (aMSG);
      end else begin
         { IDLE }
         LoopMe := false;
      end;
   end;
   if aFinish then  ExitProcess(0);
End;




////////////////////////////////////////////////////////////////////////////////


procedure nopProc(a:longword); begin end;

//------------------------------------------------------------------------------
constructor BTFlatWinObj.Create(parent:longword);
var
   wc : WNDCLASS;
//   fwc : WNDCLASS;
   h :longword;
   stl :longword;
begin
   aLastError := -1; // frail create win

   aStandAlone := false;
   if parent  = 0 then aStandAlone := true;
   aPapa := parent;

   aBackGr := 0;
   aBrush := 0;
   aActive := true;
   aFinish := false;

   amsd_buttons := 0;
   amsd_Xpos := 0;
   amsd_Ypos := 0;
   amsd_Xdiff := 0;
   amsd_Ydiff := 0;

   akbdBegin := 0;
   akbdEnd := 0;
   for h := 0 to 128 do akeyscanmap[h] := 0;
   akeyhitc := 0;

   for h:= 0 to 12 do
   begin
      aEvent[h] := @nopProc;
      aUserParm[h] := 0;
   end;

   h := GetModuleHandle(nil); {system.MainInstance; } {hInst; }
   if not GetClassInfo(h,'wincore127o',wc) then // new class
   begin
      wc.style := CS_HREDRAW or CS_VREDRAW or CS_OWNDC;
      wc.lpfnWndProc := @_WindowProc;
      wc.cbClsExtra := 0;
      wc.cbWndExtra := 0;
      wc.hInstance := h;
      wc.hIcon := LoadIcon(0, 'MAINICON');
      wc.hCursor := LoadCursor(0, IDC_ARROW);
      wc.hbrBackground := COLOR_BTNFACE + 1;
      wc.lpszMenuName := nil;
      wc.lpszClassName := 'wincore127o';
      h := RegisterClass(wc);
   end else h := 1;

   if h <> 0 then
   begin
     // aClass := longword(wc);
      //WS_BORDER or WS_POPUP or WS_VISIBLE,
      if parent <> 0  then stl := WS_CHILD
                      else stl := 0;

      ah_Wnd := CreateWindow('wincore127o','WndSys',
                           WS_POPUP or WS_VISIBLE or WS_CAPTION or WS_SYSMENU or WS_BORDER or stl,
                           -1,
                           -1,
                           100, // some size
                           100,
                           parent,     //?? dasnt work
                           0,
                           wc.hInstance,
                           nil);

      if ah_Wnd <> 0 then
      begin
         setProp(ah_Wnd,'FlatWObj',longword(self));
         SetParent(ah_wnd,parent);


         UpdateWindow(ah_Wnd);
         ShowWindow(ah_Wnd, SW_SHOW);
         SetFocus(ah_Wnd);
         FlushMessages;
         aWinDC := GetDC(ah_Wnd);
         aCursor := 1;
       { set up GDI }
         aLastError := 0; { OK }
      end;
   end;
end;

destructor  BTFlatWinObj.Destroy;
var
  aMSG : MSG;
begin
   if ah_Wnd <> 0 then
   begin
      PostMessage(ah_wnd,WM_CLOSE,0,0);
      if aStandAlone then
      begin
         while GetMessage(amsg,0, 0, 0) do
         begin
            TranslateMessage(amsg);
            DispatchMessage(amsg);
         end;
      end else Sleep(10);
      ah_Wnd := 0;
   end;
   inherited;
end;

//------------------------------------------------------------------------------
procedure   BTFlatWinObj.SetWindowEvent(Eventnum,Eventptr,UserParam:longword);
var p :pointer;
begin
   if (EventNum >=0) and (Eventnum <= 12) then
   begin
      if Eventptr = 0 then p := @nopProc
                      else p := pointer(Eventptr);
      aEvent[EventNum] := p;
      aUserParm[EventNum] := UserParam;
   end;
end;

//------------------------------------------------------------------------------
procedure   BTFlatWinObj.SetWindowCaption(Caption:pchar);
begin
   if ah_wnd <> 0 then SetWindowText(ah_wnd,pchar(Caption));
end;

//------------------------------------------------------------------------------
procedure   BTFlatWinObj.SetWindowPosition(Xpos,Ypos:longint);
var r:TRECT;
    xl,yl:longint;
begin
   if ah_wnd <> 0 then
   begin
      GetWindowRect(ah_wnd, r);
//todo + 1 in size ??????????
      xl := r.right - r.left;
      yl := r.bottom - r.top;

      //center
      if aPapa <> 0 then
      begin
         Windows.GetClientRect(aPapa, r);
         if (Xpos = -1) then Xpos := (r.Right - xl) div 2;
         if (Ypos = -1) then Ypos := (r.Bottom - yl) div 2;
      end else begin
         if (Xpos = -1) then Xpos := (GetSystemMetrics(SM_CXSCREEN) - xl) div 2;
         if (Ypos = -1) then Ypos := (GetSystemMetrics(SM_CYSCREEN) - yl) div 2;
      end;

      MoveWindow(ah_wnd, Xpos, Ypos, xl, yl, TRUE);
   end;
end;

//------------------------------------------------------------------------------
procedure   BTFlatWinObj.GetWindowPosition(var Xpos,Ypos:longint);
var r:TRECT;
begin
   Xpos := 0;
   Ypos := 0;
   if ah_wnd <> 0 then
   begin
      GetWindowRect(ah_wnd, r);
      if aPapa <> 0 then MapWindowPoints(HWND_DESKTOP,aPapa,r,2);
      Xpos := r.Left;
      Ypos := r.Top;
   end;
end;


//------------------------------------------------------------------------------
procedure   BTFlatWinObj.SetWindowSize(Xlng,Ylng:longint);
var r:TRECT;
begin
   if ah_wnd <> 0 then
   begin
      GetWindowRect(ah_wnd, r);
      MoveWindow(ah_wnd, r.Left, r.Top, Xlng, Ylng, TRUE);
   end;
end;

//------------------------------------------------------------------------------
procedure   BTFlatWinObj.SetWindowClientSize(Width,Height:longint);
var rectWindow ,rectClient:trect;
begin
  if ah_wnd <> 0 then begin
     Windows.GetWindowRect(ah_wnd, rectWindow );
     Windows.GetClientRect(ah_wnd, rectClient);
     Width := ((rectWindow.Right  - rectWindow .Left) - rectClient.Right) + longint(Width);
     Height:= ((rectWindow.Bottom - rectWindow .Top)  - rectClient.Bottom) + longint(Height);
     SetWindowPos(ah_wnd, 0, 0, 0, Width, Height, SWP_NOZORDER or SWP_NOMOVE);
  end;
end;

//------------------------------------------------------------------------------
procedure   BTFlatWinObj.GetWindowClientSize(var Width,Height:longint);
var rectClient:trect;
begin
  Width := 0;
  Height := 0;
  if ah_wnd <> 0 then begin
     Windows.GetClientRect(ah_wnd, rectClient);
     Width := rectClient.Right;
     Height := rectClient.Bottom;
  end;
end;

//------------------------------------------------------------------------------
procedure   BTFlatWinObj.SetWindowCursor(Cursor:longword);
begin
   aCursor := Cursor;
   if Cursor = 0 then SetCursor(0);
   if Cursor = 1 then SetCursor(LoadCursor(0,IDC_ARROW));
   if Cursor = 2 then SetCursor(LoadCursor(0,MAKEINTRESOURCE(32649))); {IDC_HAND}{win95 not working }
   if Cursor = 3 then SetCursor(LoadCursor(0,IDC_WAIT));
   if Cursor = 4 then SetCursor(LoadCursor(0,IDC_CROSS));
   if Cursor = 5 then SetCursor(LoadCursor(0,IDC_IBEAM));
//   LoadCursor(0,IDC_SIZEALL)
   if Cursor > 1024 then SetCursor(Cursor);
end;

//------------------------------------------------------------------------------
procedure   BTFlatWinObj.SetWindowMaximaze(how:longword);
begin
   if ah_wnd <> 0 then
   begin
      if how = 1 then ShowWindow(ah_Wnd, SW_SHOWMAXIMIZED);
      if how = 0 then ShowWindow(ah_Wnd, SW_SHOWMINIMIZED);
      if how = 2 then ShowWindow(ah_Wnd, SW_SHOWDEFAULT);
   end;
end;


//------------------------------------------------------------------------------
procedure   BTFlatWinObj.SetWindowBorder(Border:longword);
var st:dword;
begin
   if ah_wnd <> 0 then
   begin
      st   := GetWindowLong(ah_wnd, GWL_STYLE);

      st := st and (not (WS_POPUP or WS_CAPTION or WS_BORDER
                    or WS_THICKFRAME or WS_DLGFRAME or DS_MODALFRAME or WS_MINIMIZEBOX or WS_MAXIMIZEBOX));
      case Border of
      0: { None } st := st or WS_POPUP;
      1: { Single } st := st or (WS_CAPTION or WS_BORDER);
      2: { Sizeble } st := st or (WS_CAPTION or WS_THICKFRAME or WS_MINIMIZEBOX or WS_MAXIMIZEBOX);
      end;

      SetWindowLong(ah_wnd,GWL_STYLE, st);
      { now update changes to border }
      SetWindowPos(ah_wnd,0,0,0,0,0,
           SWP_NOMOVE or SWP_NOSIZE or SWP_NOZORDER or SWP_FRAMECHANGED);
   end;
end;

//------------------------------------------------------------------------------
procedure   BTFlatWinObj.SetWindowIcon(Icon:longword);
var a,i:longword;
begin
   a := 0;
   if ah_wnd  <> 0 then
   begin
      // if Icon = 0 then None
      if Icon = 1 then a := LoadIcon(0,IDI_APPLICATION);
      if Icon = 2 then a := LoadIcon(0,IDI_HAND);
      if Icon = 3 then a := LoadIcon(0,IDI_EXCLAMATION);
      if Icon = 4 then a := LoadIcon(0,IDI_QUESTION);
      if Icon = 5 then a := LoadIcon(0,IDI_ASTERISK);
      if (Icon > 6) and (Icon < 1024) then
      begin
         i := ExtractIcon(0,'shell32.dll',dword(-1));
         a := Icon - 6;
         if a > i then a := 0;
         a := ExtractIcon(0,'shell32.dll',a);
      end;

      if Icon > 1024 then a := Icon;
      SetClassLong(ah_wnd,GCL_HICON,a);
   end;
end;

//------------------------------------------------------------------------------
procedure   BTFlatWinObj.SetWindowBackground(BK:longword);
var a:dword;
begin
   a := 0;
   aBackGr := 0;
   if ah_wnd <> 0 then
   begin
      if (bk and $FF000000) <> 0 then
      begin
         bk := bk and $FF;
         if bk = 0 then begin a := 0;  aBackGr := 1; end;
         if bk = 1  then a := COLOR_BTNFACE + 1;
         if bk = 2  then a := GetStockObject(BLACK_BRUSH);
         if bk = 3  then a := GetStockObject(WHITE_BRUSH);
      end else begin
         // this is rgb
         if aBrush <> 0 then DeleteObject(aBrush);
         a := CreateSolidBrush(bk); { bk = rgb color }
         aBrush := a;
      end;
      SetClassLong(ah_wnd,GCL_HBRBACKGROUND,a);
      InvalidateRect(ah_wnd,nil,true);
   end;
end;

//------------------------------------------------------------------------------
function    BTFlatWinObj.GetScreenXlng:longword;
begin
   GetScreenXlng := GetSystemMetrics(SM_CXSCREEN);
end;

//------------------------------------------------------------------------------
function    BTFlatWinObj.GetScreenYlng:dword;
begin
   GetScreenYlng := GetSystemMetrics(SM_CYSCREEN);
end;

//------------------------------------------------------------------------------
function    BTFlatWinObj.GetScreenBPP:longword;
var dc,r:dword;
begin
   r := 0;
   dc := CreateCompatibleDC(0);
   if dc <> 0 then
   begin
      r := GetDeviceCaps(dc,BITSPIXEL);
      DeleteDC(dc);
   end;
   GetScreenBPP := r;
end;

//------------------------------------------------------------------------------
procedure   BTFlatWinObj.RePaintWindow;
begin
   InvalidateRect(ah_wnd,nil,false);
end;

//------------------------------------------------------------------------------
procedure   BTFlatWinObj.GDI_DrawPicBuffer(Xpos,Ypos,Xlng,Ylng,Bpp,SXlng,SYlng,SrcPtr:longword);
Var bisize,i : longword;
    pbitmapinfo : array[0..2048] of byte; // sizeof(BITMAPINFOHEADER)+512  { 512 for 256 di colors word }
begin
   if ah_wnd = 0 then Exit;

   if (Bpp=32) or (bpp=24) or (bpp=16) or (bpp=15) or (bpp=8) or (bpp=1) then
   begin

   bisize:=sizeof(BITMAPINFOHEADER);
   fillchar(pbitmapinfo, bisize+512, 0);

   with BITMAPINFO((@pbitmapinfo)^) do
   begin {BitmapInfoHeader 16Bit}
      bmiHeader.biSize        :=bisize;
      bmiHeader.biWidth       := SXlng;
      bmiHeader.biHeight      := -SYlng;
      bmiHeader.biPlanes      := 1;
      bmiHeader.biBitCount    := bpp;

      if bpp > 16 then
      begin
         bmiHeader.biCompression :=BI_BITFIELDS;
      end else begin
         if bpp = 8 then
         begin
            bmiHeader.biCompression :=BI_RGB;
            bmiHeader.biSizeImage   :=sxlng*sylng;
            bmiHeader.biclrused     :=256;
         end else begin
             //todo

         end;
      end;


      if bpp <= 8 then
      begin
         if bpp = 8 then
         begin
           for i := 0 to 255 do word(pointer(longword(@pbitmapinfo)+ bisize + i*2)^) := i;

         end else begin

         end;
      end else begin
         if bpp = 15 then
         begin
            longword(pointer(longword(@pbitmapinfo)+ bisize + 0)^) := $7C00;       {Bit-Positions R G B 15Bit }
            longword(pointer(longword(@pbitmapinfo)+ bisize + 0)^) := $03E0;
            longword(pointer(longword(@pbitmapinfo)+ bisize + 0)^) := $001F;
         end;
         if bpp = 16 then
         begin
            longword(pointer(longword(@pbitmapinfo)+ bisize + 0)^) := $F800;       {Bit-Positions R G B 16Bit }
            longword(pointer(longword(@pbitmapinfo)+ bisize + 4)^) := $07E0;
            longword(pointer(longword(@pbitmapinfo)+ bisize + 8)^) := $001F;
         end;
         if bpp > 16 then
         begin
            longword(pointer(longword(@pbitmapinfo)+ bisize + 0)^) := $FF0000;     {Bit-Positions R G B 24/32Bit }
            longword(pointer(longword(@pbitmapinfo)+ bisize + 4)^) := $00FF00;     // work faster
            longword(pointer(longword(@pbitmapinfo)+ bisize + 8)^) := $0000FF;
         end;
         StretchDiBits(aWindc, xpos,ypos,xlng,ylng, 0,0,sxlng,sylng,
                         pointer( srcptr), bitmapinfo((@pbitmapinfo)^),
                         DIB_RGB_COLORS, SRCCOPY);
      end;

   end;
   end;
end;


//------------------------------------------------------------------------------
//<< M O U S E  >>
function    BTFlatWinObj.Mouse_GetXpos:longword;
begin
   FlushMessages;
   Mouse_GetXpos := amsd_Xpos;
end;

function    BTFlatWinObj.Mouse_GetYpos:longword;
begin
   FlushMessages;
   Mouse_GetYpos := amsd_Ypos;
end;


function    BTFlatWinObj.Mouse_GetButtons:longword;
begin
   FlushMessages;
   Mouse_GetButtons := amsd_Buttons;
end;

procedure   BTFlatWinObj.Mouse_Get(var Buttons,Xpos,Ypos:longword);
begin
   FlushMessages;
   Buttons := amsd_Buttons;
   Xpos := amsd_Xpos;
   Ypos := amsd_Ypos;
end;

procedure   BTFlatWinObj.Mouse_GetDiff(var Xdif,Ydif:longint);
begin
   FlushMessages;
   Xdif := amsd_Xdiff;
   Ydif := amsd_Ydiff;
//   amsd_Xdiff := 0; { after get clear }
//   amsd_Ydiff := 0;
end;

procedure   BTFlatWinObj.Mouse_SetPosition(Xpos,Ypos:longword);
begin
   SetCursorPos(Xpos, Ypos);
end;

//------------------------------------------------------------------------------
//<< K E Y B O A R D >>
function    BTFlatWinObj.TestKey(akey:longword):boolean;
begin
  FlushMessages;
   TestKey := akeyscanmap[akey and $7F] <> 0;
end;


function    BTFlatWinObj.KeyPressed:boolean;
begin
   FlushMessages;
   KeyPressed := akbdBegin <> akbdEnd;
end;


function    BTFlatWinObj.GetKey:longword;
var w:longword;
begin
   FlushMessages;
   w:=0;
   if akbdBegin <> akbdEnd then
   begin
      w:=longword(akbdBuff[akbdEnd]);
      akbdEnd := (akbdEnd + 1) and 31;
   end;
   GetKey := w;
end;


procedure   BTFlatWinObj.FlushKeys;
var i:integer;
begin
   for i := 0 to 128 do akeyscanmap[i] := 0;
   akeyhitc := 0;
   akbdBegin := 0;
   akbdEnd := 0;
end;

function    BTFlatWinObj.WaitKeyGet:longword;
begin
   repeat until KeyPressed;
   WaitKeyGet := GetKey;
end;


procedure   BTFlatWinObj.WaitKey;
begin
   WaitKeyGet;
end;




/// Asinhron read state
(*
Symbolic constant name Value
(hexadecimal) Mouse or keyboard equivalent
VK_LBUTTON        01   Left mouse button
VK_RBUTTON        02   Right mouse button
VK_CANCEL         03   Control-break processing
VK_MBUTTON        04   Middle mouse button (three-button mouse)
VK_XBUTTON1       05   Windows 2000/XP: X1 mouse button
VK_XBUTTON2       06   Windows 2000/XP: X2 mouse button
—                 07   Undefined
VK_BACK           08   BACKSPACE key
VK_TAB            09   TAB key
—               0A–0B  Reserved
VK_CLEAR          0C   CLEAR key
VK_RETURN         0D   ENTER key
—               0E–0F  Undefined
VK_SHIFT          10   SHIFT key
VK_CONTROL        11   CTRL key
VK_MENU           12   ALT key
VK_PAUSE          13   PAUSE key
VK_CAPITAL        14   CAPS LOCK key
-                 -    kanji kodes
—                 1A   Undefined
VK_ESCAPE         1B   ESC key               1
VK_CONVERT        1C   IME convert
VK_NONCONVERT     1D   IME nonconvert
VK_ACCEPT         1E   IME accept
VK_MODECHANGE     1F   IME mode change request
VK_SPACE          20   SPACEBAR
VK_PRIOR          21   PAGE UP key
VK_NEXT           22   PAGE DOWN key
VK_END            23   END key
VK_HOME           24   HOME key
VK_LEFT           25   LEFT ARROW key        75
VK_UP             26   UP ARROW key          72(dec) scan code
VK_RIGHT          27   RIGHT ARROW key       77
VK_DOWN           28   DOWN ARROW key        80
VK_SELECT         29   SELECT key
VK_PRINT          2A   PRINT key
VK_EXECUTE        2B   EXECUTE key
VK_SNAPSHOT       2C   PRINT SCREEN key
VK_INSERT         2D   INS key
VK_DELETE         2E   DEL key
VK_HELP           2F   HELP key
 30 - 0 key ... 39 - 9 key
—  3A–40 Undefined
 41 - A key ... 5A - Z key
VK_LWIN           5B   Left Windows key (Microsoft® Natural® keyboard)
VK_RWIN           5C   Right Windows key (Natural keyboard)
VK_APPS           5D   Applications key (Natural keyboard)
—                 5E   Reserved
VK_SLEEP          5F   Computer Sleep key
VK_NUMPAD0        60   Numeric keypad 0 key
VK_NUMPAD1        61   Numeric keypad 1 key
VK_NUMPAD2        62   Numeric keypad 2 key
VK_NUMPAD3        63   Numeric keypad 3 key
VK_NUMPAD4        64   Numeric keypad 4 key
VK_NUMPAD5        65   Numeric keypad 5 key
VK_NUMPAD6        66   Numeric keypad 6 key
VK_NUMPAD7        67   Numeric keypad 7 key
VK_NUMPAD8        68   Numeric keypad 8 key
VK_NUMPAD9        69   Numeric keypad 9 key
VK_MULTIPLY       6A   Multiply key
VK_ADD            6B   Add key
VK_SEPARATOR      6C   Separator key
VK_SUBTRACT       6D   Subtract key
VK_DECIMAL        6E   Decimal key
VK_DIVIDE         6F   Divide key
VK_F1             70   F1 key
VK_F2             71   F2 key
VK_F3             72   F3 key
VK_F4             73   F4 key
VK_F5             74   F5 key
VK_F6             75   F6 key
VK_F7             76   F7 key
VK_F8             77   F8 key
VK_F9             78   F9 key
VK_F10            79   F10 key
VK_F11            7A   F11 key
VK_F12            7B   F12 key
VK_F13            7C - F13 key ...  VK_F24 87H - F24 key
—  88–8F Unassigned
VK_NUMLOCK        90   NUM LOCK key
VK_SCROLL         91   SCROLL LOCK key
                92–96  OEM specific
—               97–9F  Unassigned
VK_LSHIFT         A0   Left SHIFT key
VK_RSHIFT         A1   Right SHIFT key
VK_LCONTROL       A2   Left CONTROL key
VK_RCONTROL       A3   Right CONTROL key
VK_LMENU          A4   Left MENU key
VK_RMENU          A5   Right MENU key
*)

{use VkKeyScan('w') for letters}
function    BTFlatWinObj.KeyHit(VK:longword):longword;
begin
//  FlushMessages;
   KeyHit := longword((GetAsyncKeyState(VK) and 1) = 1);
end;



//------------------------------------------------------------------------------
function    BTFlatWinObj.BeginTimer(Time_delay:longword):longword;
begin
   BeginTimer := GetTickCount + Time_delay;
end;

procedure   BTFlatWinObj.WaitTimer(The_timer:longword);
begin
   while GetTickCount < The_timer do // T = 0; was
   begin
//   FlushMessages;
   end;
end;

procedure   BTFlatWinObj.Delay(Delay_time:longword);
begin
   WaitTimer( BeginTimer(Delay_time));
end;


////////////////////////////////////////////////////////////////////////////////

procedure   BTFlatWinObj.Control_SetText(Hand:longword; NewText: string);
begin
   NewText := NewText + #0;
   SetWindowText(Hand,pchar(NewText));
   InvalidateRect(ah_Wnd,nil,true);
   UpdateWindow(ah_Wnd);
end;

//------------------------------------------------------------------------------
procedure   BTFlatWinObj.Control_Enabled(Hand:longword; Enabled:boolean);
begin
   EnableWindow(Hand,Enabled);
end;

//------------------------------------------------------------------------------
procedure   BTFlatWinObj.Control_SetCheckBox(Hand:longword; Checked:boolean);
var s:longword;
begin
   s:=BST_CHECKED;
   if Checked = false then s := BST_UNCHECKED;
   SendMessage(Hand,BM_SETCHECK,s,0);
end;

//------------------------------------------------------------------------------
function    BTFlatWinObj._DoCtrl(CtrlType:string; CtrlFlag,CtrlID:longword; Xpos,Ypos,Xlng,Ylng:longword;
                                 CtrlName: string; CallbK,UserParm:longword):longword;
var res:longword;
begin
   res :=0;
   if ah_wnd  <> 0  then
   begin
      CtrlType := CtrlType + #0;
      CtrlName := CtrlName + #0;
      res := CreateWindowEx(0,
                      PCHAR(CtrlType),
                      PCHAR(CtrlName),
                      WS_CHILD or WS_VISIBLE or CtrlFlag,
                      Xpos, Ypos,
                      Xlng, Ylng,
                      ah_wnd,
                      hmenu(CtrlID),
                      0,nil);
      if res <> 0 then
      begin
         if CallBk <> 0 then SetProp(res,'fw_cbf1',CallBk);  // set call back value
         SetProp(res,'fw_cbf1u',UserParm);
         SetFocus(ah_wnd);
      end;
   end;
   _DoCtrl := res;
end;

//------------------------------------------------------------------------------
function    BTFlatWinObj.AddButton(Xpos,Ypos,Xlng,Ylng:longword; BtnName: string; BtnProc:pointer; UserParam:longword):longword;
begin
   AddButton := _DoCtrl('Button',BS_PUSHBUTTON,1,Xpos,Ypos,Xlng,Ylng,BtnName,longword(BtnProc),UserParam);
end;

//------------------------------------------------------------------------------
function    BTFlatWinObj.AddLabel(Xpos,Ypos,Xlng,Ylng:longword; BtnName: string):longword;
begin
   AddLabel := _DoCtrl('Static',SS_LEFT,2,Xpos,Ypos,Xlng,Ylng,BtnName,0,0);
end;

//------------------------------------------------------------------------------
function    BTFlatWinObj.AddCheckBox(Xpos,Ypos,Xlng,Ylng:longword; BtnName: string; BoolPtr:pointer; InitValue:boolean):longword;
var res:longword;
begin
   res := _DoCtrl('Button',BS_AUTOCHECKBOX,3,Xpos,Ypos,Xlng,Ylng,BtnName,longword(BoolPtr),0);
   if res <> 0 then
   begin
     if InitValue then SendMessage(res,BM_SETCHECK,BST_CHECKED,0);
     if BoolPtr <> nil then boolean(BoolPtr^) := InitValue;
   end;
   AddCheckBox := res;
end;

//------------------------------------------------------------------------------
function    BTFlatWinObj.AddEditBox(Xpos,Ypos,Xlng,Ylng:longword; aText:pointer):longword;
var Txt:string;
begin
   Txt := string(aText^);
   AddEditBox := _DoCtrl('edit',WS_CHILD or ES_AUTOHSCROLL or ES_LEFT or WS_BORDER,4,Xpos,Ypos,Xlng,Ylng,Txt,longword(aText),0);
end;

//------------------------------------------------------------------------------
function    BTFlatWinObj.AddImage(Xpos,Ypos,Xlng,Ylng:longword; FileName: string; BtnProc:pointer; UserParam:longword):longword;
var h,a:longword;
begin
   FileName:=FileName+#0;
//   a := _DoCtrl('Static',SS_BITMAP,1,Xpos,Ypos,Xlng,Ylng,'',longword(BtnProc));
   a := _DoCtrl('Button',BS_BITMAP,1,Xpos,Ypos,Xlng,Ylng,'',longword(BtnProc),UserParam);
      h:=LoadImage(0,@FileName[1],IMAGE_BITMAP,Xlng,Ylng,LR_LOADFROMFILE or LR_LOADTRANSPARENT or LR_LOADMAP3DCOLORS);
//   SendMessage(a,STM_SETIMAGE,IMAGE_BITMAP,h);
   SendMessage(a,BM_SETIMAGE,IMAGE_BITMAP,h);
   DeleteObject(h);
   AddImage := a;
end;

//------------------------------------------------------------------------------
function    BTFlatWinObj.AddScrollBar(Xpos,Ypos,Xlng,Ylng,Min,Max,Pos,HV:longint; BtnProc:pointer; UserParam:longword; IntPtr:pointer):longword;
var a:longword;
    HVt:longword;
    ip : ^longint;
begin
   HVt := SBS_VERT;
   if Pos < Min then Pos := Min;
   if Pos > Max Then Pos := Max;

   if HV = 1 then HVt := SBS_HORZ;
   a := _DoCtrl('scrollbar',HVt or WS_BORDER,5,Xpos,Ypos,Xlng,Ylng,'',longword(BtnProc),UserParam);
   if a <> 0 then
   begin
     SetProp(a,'fw_cbf2',dword(IntPtr));
     SetScrollRange(a,SB_CTL,Min,Max,true);
     SetScrollPos(a,SB_CTL,Pos,True);
     ip := IntPtr;
     ip^ := Pos;
   end;
   AddScrollBar := a;
end;

//------------------------------------------------------------------------------
function    BTFlatWinObj.AddListBox(Xpos,Ypos,Xlng,Ylng:longword; Items: string; BtnProc:pointer; UserParam:longword):longword;
var s:string;
    a:longword;
begin
   a := _DoCtrl('listbox',LBS_NOTIFY,1,Xpos,Ypos,Xlng,Ylng,'',longword(BtnProc),UserParam);
   s := '111';
   SendMessage(a, LB_ADDSTRING, 0 ,longword(@s[1]));
   s := '222';
   SendMessage(a, LB_ADDSTRING, 0 ,longword(@s[1]));

   AddListBox := a;
end;



end.
