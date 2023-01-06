unit NBFlatWin;

interface

function  EnterWindows:longint;
procedure LeaveWindows;

procedure SetWindowCaption(Caption:pchar);
procedure SetWindowPosition(Xpos,Ypos:longint);
procedure SetWindowSize(Xlng,Ylng:longint);
procedure SetWindowClientSize(Width,Height:longint);
procedure GetWindowClientSize(var Width,Height:longint);
procedure SetWindowMaximaze(how:longword);
procedure SetWindowBorder(Border:longword);
procedure SetWindowCursor(Cursor:longword);
procedure SetWindowIcon(Icon:longword);
procedure SetWindowBackground(BK:longword);
function  GetScreenXlng:longword;
function  GetScreenYlng:longword;
function  GetScreenBPP:longword;
procedure RePaintWindow;
function  GetWindowDC:longword;
function  GetWindowHandle:longword;
procedure SetWindowEvent(Eventnum,Eventptr:longword);

function  Mouse_GetXpos:longword;
function  Mouse_GetYpos:longword;
function  Mouse_GetButtons:longword;
procedure Mouse_Get(var Buttons,Xpos,Ypos:longword);
procedure Mouse_GetDiff(var Xdif,Ydif:longint);
procedure Mouse_SetPosition(Xpos,Ypos:longword);
function  TestKey(akey:longword):boolean;
function  KeyPressed:boolean;
function  GetKey:word;
procedure FlushKeys;
function  WaitKeyGet:word;
procedure WaitKey;
function  KeyHit(VK:longword):longword;

procedure GDI_DrawPicBuffer(Xpos,Ypos,Xlng,Ylng,Bpp,SXlng,SYlng,SrcPtr:longword);


implementation

uses windows,messages,shellapi;

var  EnterW     :longint;
     h_Wnd      :longword;
     Win_DC     :longword;
     AppActive  :boolean;            // if TRUE app is active
     uTimer     :longword;           // Handle to system timer
     aCursor    :longword;           // cursor type
     aBackGr    :longword;           // WM_BACKGROUND to stop flashing
     aBrush     :longword;           // Background brush
     Finish     :boolean;            // marker to finish program



     iostr:Record                    // main io structure KBD & Mouse
       msd_Buttons :longword;        // mouse button status
       msd_Xpos    :longword;        // mouse Xpos
       msd_Ypos    :longword;        // mouse Ypos
       msd_Xdiff   :longint;         // mouse X diff
       msd_Ydiff   :longint;         // mouse Y diff
       kbdBegin    :longword;        // local teil begin pointer
       kbdEnd      :longword;        // local teil end pointer
       kbdBuff     :array [0..32] of word;  // local keyboard tail
       keyscanmap  :array [0..128] of byte; // scan code map
       keyhitc     :byte;            // marker scan code is hit
     end;

                                     // Event CallBacks
     OnIdle     :procedure; stdcall; // on Idle
     OnMouse    :procedure; stdcall; // on Mouse
     OnClick    :procedure; stdcall; // on Mouse click
     OnKey      :procedure; stdcall; // on Key down
     OnTimer    :procedure; stdcall; // on Timer
     OnQuit     :procedure; stdcall; // on Quit
     OnPaint    :procedure; stdcall; // on Paint
     OnActive   :procedure; stdcall; // on App Active
     OnDeActive :procedure; stdcall; // on App UnActive
     OnSize     :procedure; stdcall; // on Window resize
     OnCommand  :procedure; stdcall; // on wm_Command
     OnCreate   :procedure; stdcall; // on Create
     OnOther    :procedure; stdcall; // on Other event bypass all messages


//------------------------------------------------------------------------------
procedure SetWindowCaption(Caption:pchar);
begin
   if EnterW <> 0 then SetWindowText(h_wnd,pchar(Caption));
end;

//------------------------------------------------------------------------------
procedure SetWindowPosition(Xpos,Ypos:longint);
var r:TRECT;
    xl,yl:longint;
begin
   if EnterW <> 0 then
   begin
      GetWindowRect(h_Wnd, r);
//todo + 1 in size ??????????
      xl := r.right - r.left;
      yl := r.bottom - r.top;

      if (Xpos = -1) and (Ypos = -1) then
      begin
         Xpos := (GetSystemMetrics(SM_CXSCREEN) - xl) div 2;
         Ypos := (GetSystemMetrics(SM_CYSCREEN) - yl) div 2;
      end;
      MoveWindow(h_Wnd, Xpos, Ypos, xl, yl, TRUE);
   end;
end;

//------------------------------------------------------------------------------
procedure SetWindowSize(Xlng,Ylng:longint);
var r:TRECT;
begin
   if EnterW <> 0 then
   begin
      GetWindowRect(h_Wnd, r);
      MoveWindow(h_Wnd, r.Left, r.Top, Xlng, Ylng, TRUE);
   end;
end;

//------------------------------------------------------------------------------
procedure SetWindowClientSize(Width,Height:longint);
var rectWindow ,rectClient:trect;
begin
  if EnterW <> 0 then begin
     Windows.GetWindowRect(h_Wnd, rectWindow );
     Windows.GetClientRect(h_Wnd, rectClient);
     Width := ((rectWindow.Right  - rectWindow .Left) - rectClient.Right) + longint(Width);
     Height:= ((rectWindow.Bottom - rectWindow .Top)  - rectClient.Bottom) + longint(Height);
     SetWindowPos(h_Wnd, 0, 0, 0, Width, Height, SWP_NOZORDER or SWP_NOMOVE);
  end;
end;

//------------------------------------------------------------------------------
procedure GetWindowClientSize(var Width,Height:longint);
var rectClient:trect;
begin
  Width := 0;
  Height := 0;
  if EnterW <> 0 then begin
     Windows.GetClientRect(h_Wnd, rectClient);
     Width := rectClient.Right;
     Height := rectClient.Bottom;
  end;
end;

//------------------------------------------------------------------------------
procedure SetWindowMaximaze(how:longword);
begin
   if EnterW <> 0 then
      if how = 1 then ShowWindow(h_Wnd, SW_SHOWMAXIMIZED);
      if how = 0 then ShowWindow(h_Wnd, SW_SHOWMINIMIZED);
      if how = 2 then ShowWindow(h_Wnd, SW_SHOWDEFAULT);      
end;

//------------------------------------------------------------------------------
procedure SetWindowBorder(Border:longword);
var st:dword;
begin
   if EnterW <> 0 then
   begin
      st   := GetWindowLong(h_Wnd, GWL_STYLE);

      st := st and (not (WS_POPUP or WS_CAPTION or WS_BORDER
                    or WS_THICKFRAME or WS_DLGFRAME or DS_MODALFRAME or WS_MINIMIZEBOX or WS_MAXIMIZEBOX));
      case Border of
      0: { None } st := st or WS_POPUP;
      1: { Single } st := st or (WS_CAPTION or WS_BORDER);
      2: { Sizeble } st := st or (WS_CAPTION or WS_THICKFRAME or WS_MINIMIZEBOX or WS_MAXIMIZEBOX);
      end;

      SetWindowLong(h_Wnd,GWL_STYLE, st);
      { now update changes to border }
      SetWindowPos(h_Wnd,0,0,0,0,0,
           SWP_NOMOVE or SWP_NOSIZE or SWP_NOZORDER or SWP_FRAMECHANGED);
   end;
end;


//------------------------------------------------------------------------------
procedure SetWindowCursor(Cursor:longword);
begin
   aCursor := Cursor;
   if Cursor = 0 then SetCursor(0);
   if Cursor = 1 then SetCursor(LoadCursor(0,IDC_ARROW));
   if Cursor = 2 then SetCursor(LoadCursor(0,MAKEINTRESOURCE(32649))); {IDC_HAND}{win95 not working }
   if Cursor = 3 then SetCursor(LoadCursor(0,IDC_WAIT));
   if Cursor = 4 then SetCursor(LoadCursor(0,IDC_CROSS));
   if Cursor = 5 then SetCursor(LoadCursor(0,IDC_IBEAM));
   if Cursor > 1024 then SetCursor(Cursor);
end;

//------------------------------------------------------------------------------
procedure SetWindowIcon(Icon:longword);
var a,i:longword;
begin
   a := 0;
   if EnterW  <> 0 then
   begin
      // if Icon = 0 then None
      if Icon = 1 then a := LoadIcon(0,IDI_APPLICATION);
      if Icon = 2 then a := LoadIcon(0,IDI_HAND);
      if Icon = 3 then a := LoadIcon(0,IDI_EXCLAMATION);
      if Icon = 4 then a := LoadIcon(0,IDI_QUESTION);
      if Icon = 5 then a := LoadIcon(0,IDI_ASTERISK);
      if (Icon > 6) and (Icon < 1024) then
      begin
         i := ExtractIcon(0,'shell32.dll',dword(-1)); // get count
         a := Icon - 6;
         if a > i then a := 0;
         a := ExtractIcon(0,'shell32.dll',a);
      end;

      if Icon > 1024 then a := Icon;
      if a <> 0 then
      begin
         //SetClassLong(h_Wnd,GCL_HICON,a);
         SendMessage(h_Wnd,WM_SETICON,ICON_BIG,a);
         SendMessage(h_Wnd,WM_SETICON,ICON_SMALL,a);
      end;
   end;
end;

//------------------------------------------------------------------------------
procedure SetWindowBackground(BK:longword);
var a:longword;
begin
   a := 0;
   aBackGr := 0;
   if EnterW <> 0 then
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
      SetClassLong(h_Wnd,GCL_HBRBACKGROUND,a);
      InvalidateRect(h_Wnd,nil,true);
   end;
end;

//------------------------------------------------------------------------------
function  GetScreenXlng:longword;
begin
   GetScreenXlng := GetSystemMetrics(SM_CXSCREEN);
end;

//------------------------------------------------------------------------------
function  GetScreenYlng:longword;
begin
   GetScreenYlng := GetSystemMetrics(SM_CYSCREEN);
end;

//------------------------------------------------------------------------------
function  GetScreenBPP:longword;
var dc,r:longword;
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
procedure RePaintWindow;
begin
   if EnterW <> 0 then InvalidateRect(h_wnd,nil,false);
end;

//------------------------------------------------------------------------------
function  GetWindowDC:longword;
begin
  GetWindowDC := Win_DC;
end;

//------------------------------------------------------------------------------
function  GetWindowHandle:longword;
begin
   GetWindowHandle := h_Wnd;
end;


//------------------------------------------------------------------------------
procedure FlushMessages;
var
   LoopMe : boolean;
   aMSG   : MSG;
Begin

   if Finish then exit;

   { Stay in this loop while not active or minimized }
   while (not AppActive) and GetMessage(aMSG,0,0,0) do

   begin
      If aMSG.Message = WM_Quit then
      begin
         Finish := true;
      end;
      TranslateMessage(aMSG);
      DispatchMessage (aMSG);
   end;

   if Finish then  ExitProcess(0);
   LoopMe := true;

   While LoopMe do
   begin
      if PeekMessage(aMSG,0,0,0,PM_REMOVE or PM_NOYIELD) then
      begin
         If aMSG.Message = WM_Quit then
         begin
             LoopMe := false;
             Finish := true;
         end;
         TranslateMessage(aMSG);
         DispatchMessage (aMSG);
      end else begin
         { IDLE }
         LoopMe := false;
      end;
   end;
   if Finish then  ExitProcess(0);
End;


//------------------------------------------------------------------------------
function _WindowProc(aWindow: HWnd; AMessage: UINT; WParam : WPARAM;
                    LParam: LPARAM): LRESULT; stdcall;
var
    res : LRESULT;
    i:longword;
    X,Y:longint;
    ps : paintstruct;
begin
   res := 0;
   OnOther;

   case aMessage of
   WM_ACTIVATE:
      begin
         if (wParam = WA_ACTIVE) or (wParam = WA_CLICKACTIVE) then
         begin
            AppActive := true;
            OnActive;
         end ;
         if wParam = WA_INACTIVE then
         begin
            AppActive := false;
            OnDeActive;
         end;
      end;

   WM_CREATE:
      begin
         h_wnd := awindow;  { set it only for this call }
         onCreate;
         uTimer := SetTimer(h_wnd,1,62,nil); {// 1/16 from second  }
         SetFocus(h_wnd);
      end;

   WM_SYSCOMMAND:
      begin
         if wparam = SC_CLOSE then
         begin
           PostMessage(h_wnd,WM_CLOSE,0,0);
           res := 1;
         end;
      end;

   WM_CLOSE:  { begin the end story }
      begin
         DestroyWindow(h_Wnd); { this will cal WM_DESTROY }
         res := 1;
      end;

   WM_DESTROY: { This the last message }
      begin
         onQuit;
         // release resources
         KillTimer(h_wnd,uTimer);
         ReleaseDC(h_Wnd,Win_DC);
         if aBrush <> 0 then DeleteObject(aBrush);
         PostQuitMessage(0); { send to close WM_QUIT}
         res := 1;
      end;

   {// Turn off the cursor since this is a full-screen app }
   WM_SETCURSOR:
      begin
        if LOWORD(lParam) = HTCLIENT then
         begin
            SetWindowCursor(aCursor);
            res := 1;
         end;
      end;


   WM_TIMER:
      begin
         if wParam = 1 then  // Initialize timer
         begin
            OnTimer;  //BUG
            // if still true time out
         end;
      end;

   WM_PAINT:
      begin
         // NORMAL
         i := Win_DC;
         Win_DC:=BeginPaint(h_Wnd,ps);
         OnPaint;
         EndPaint(h_Wnd,ps);
         Win_DC := i;
      end;

   WM_ERASEBKGND:
      begin
         if aBackGr = 1 then Res := 1 // I handle that to stop flicking;
      end;

   WM_SIZE:
      begin
         OnSize;
      end;

   {-=* MOUSE *=-}

   WM_MOUSEMOVE:
      begin
         {//fwKeys = wParam;       // key flags }

         if (wParam and MK_LBUTTON) > 0 then iostr.msd_Buttons := iostr.msd_Buttons or 1;
         if (wParam and MK_RBUTTON) > 0 then iostr.msd_Buttons := iostr.msd_Buttons or 2;
         X := dword(lParam and $FFFF);  { horizontal position of }
         Y := dword(lParam shr 16);     { vertical }
         iostr.msd_Xdiff := longint(X) - longint(iostr.msd_Xpos);
         iostr.msd_Ydiff := longint(Y) - longint(iostr.msd_Ypos);
         iostr.msd_Xpos := X;
         iostr.msd_Ypos := Y;
           { onMouse trap }
         onMouse;
//         Res := 1;
      end;
   WM_LBUTTONDOWN:
      begin
         OnClick;
         iostr.msd_Buttons  := iostr.msd_Buttons or 1;
//         Res := 1;
      end;
   WM_LBUTTONUP:
      begin
         iostr.msd_Buttons  := iostr.msd_Buttons and 2;
//         Res := 1;
      end;
   WM_RBUTTONDOWN:
      begin
         iostr.msd_Buttons := iostr.msd_Buttons or 2;
//         Res := 1;
      end;
   WM_RBUTTONUP:
      begin
         iostr.msd_Buttons := iostr.msd_Buttons and 1;
//         Res := 1;
      end;

   {-=* KEY *=-}

   WM_SYSKEYDOWN:
       begin
//todo            alt_key:=true;
       end;

   WM_KEYDOWN:
      begin
           {// input key value in KBD tail}
           i := ( iostr.kbdbegin + 1 ) and 31;
           if  i <> iostr.kbdend then
           begin
              iostr.kbdbuff[iostr.kbdbegin] := wParam;
              iostr.kbdbegin := i;
           end;
           { onKeyboard; }
         iostr.keyscanmap[(lParam shr 16) and $7F ] := 1;
         iostr.keyhitc := 1;
           { onKey trap }
         OnKey;
//         Res := 1;
      end;
   WM_KEYUP:
      begin
//todo        case wParam of
//todo           VK_CONTROL: ctrl_key:=false;
//todo           VK_SHIFT  : shift_key:=false;
//todo        end;

        iostr.keyscanmap[(lParam shr 16) and $7F ] := 0;
        iostr.keyhitc := 0;
//        Res := 1;
      end;




   end; { case }

    if res = 0 then res := DefWindowProc(aWindow, aMessage, WParam, LParam);
    _WindowProc := res;
end;

//------------------------------------------------------------------------------
procedure nopProc; stdcall;
begin
end;

//------------------------------------------------------------------------------
function EnterWindows:longint;
var    wc : WNDCLASS;
       i : integer;
begin
   h_Wnd := 0;
   Win_DC := 0;
   EnterW := 0;
   aBackGr := 0;
   Finish := false;
   aBrush := 0;
   AppActive := true;

   iostr.kbdBegin := 0;
   iostr.kbdEnd := 0;
   for i := 0 to 128 do iostr.keyscanmap[i] := 0;
   iostr.keyhitc := 0;

   iostr.msd_buttons := 0;
   iostr.msd_Xpos := 0;
   iostr.msd_Ypos := 0;
   iostr.msd_Xdiff := 0;
   iostr.msd_Ydiff := 0;

   //prepare to start windows
   wc.style := CS_HREDRAW or CS_VREDRAW or CS_OWNDC;
   wc.lpfnWndProc := @_WindowProc;
   wc.cbClsExtra := 0;
   wc.cbWndExtra := 0;
   wc.hInstance := GetModuleHandle(nil); {system.MainInstance; } {hInst; }
   wc.hIcon := LoadIcon(0, 'MAINICON');
   wc.hCursor := LoadCursor(0, IDC_ARROW);
   wc.hbrBackground := COLOR_BTNFACE + 1;
   wc.lpszMenuName := nil;
   wc.lpszClassName := 'wincore127';
   if RegisterClass(wc) <> 0 then
   begin
   {// Create a window }

      h_Wnd := CreateWindow('wincore127','Window',
                           WS_POPUP or WS_VISIBLE or WS_CAPTION or WS_SYSMENU or WS_BORDER,
                           -1,
                           -1,
                           100,
                           100,
                           0,
                           0,
                           0,
                           nil);

      if h_Wnd <> 0 then
      begin
         ShowWindow(h_Wnd, SW_SHOW);
         UpdateWindow(h_Wnd);
         SetFocus(h_Wnd);
         aCursor := 1;
         FlushMessages;
         Win_Dc := GetDC(h_Wnd);
         EnterW := 1; { OK }
      end;
   end;

   EnterWindows := h_Wnd;
end;

//------------------------------------------------------------------------------
Procedure LeaveWindows;
var
  aMSG : MSG;
begin
   if EnterW = 1 then
   begin
      ReleaseDC(h_Wnd,Win_DC);
      PostMessage(h_wnd,WM_CLOSE,0,0);
      while GetMessage(amsg,0, 0, 0) do
      begin
         TranslateMessage(amsg);
         DispatchMessage(amsg);
      end;
      EnterW := 0;
   end;
end;

//------------------------------------------------------------------------------
procedure SetWindowEvent(Eventnum,Eventptr:longword);
begin
   if Eventnum = 0 then
     if Eventptr = 0 then onIdle  := @nopProc else onIdle  := pointer(Eventptr);
   if Eventnum = 1 then
     if Eventptr = 0 then onMouse := @nopProc else onMouse := pointer(Eventptr);
   if Eventnum = 2 then
     if Eventptr = 0 then onKey   := @nopProc else onKey   := pointer(Eventptr);
   if Eventnum = 3 then
     if Eventptr = 0 then onTimer := @nopProc else onTimer := pointer(Eventptr);
   if Eventnum = 4 then
     if Eventptr = 0 then onQuit  := @nopProc else onQuit  := pointer(Eventptr);
   if Eventnum = 5 then
     if Eventptr = 0 then onPaint := @nopProc else onPaint := pointer(Eventptr);
   if Eventnum = 6 then
     if Eventptr = 0 then onClick := @nopProc else onClick := pointer(Eventptr);
   if Eventnum = 7 then
     if Eventptr = 0 then onActive := @nopProc else onActive := pointer(Eventptr);
   if Eventnum = 8 then
     if Eventptr = 0 then onDeActive := @nopProc else onDeActive := pointer(Eventptr);
   if Eventnum = 9 then
     if Eventptr = 0 then onCommand := @nopProc else onCommand := pointer(Eventptr);
   if Eventnum = 10 then
     if Eventptr = 0 then onCreate := @nopProc else onCreate := pointer(Eventptr);
   if Eventnum = 11 then
     if Eventptr = 0 then onSize := @nopProc else onSize := pointer(Eventptr);
   if Eventnum = 12 then
     if Eventptr = 0 then onOther := @nopProc else onOther := pointer(Eventptr);
end;



//------------------------------------------------------------------------------
function  Mouse_GetXpos:longword;
begin
   FlushMessages;
   Mouse_GetXpos := iostr.msd_Xpos;
end;

//------------------------------------------------------------------------------
function  Mouse_GetYpos:longword;
begin
   FlushMessages;
   Mouse_GetYpos := iostr.msd_Ypos;
end;

//------------------------------------------------------------------------------
function  Mouse_GetButtons:longword;
begin
   FlushMessages;
   Mouse_GetButtons := iostr.msd_Buttons;
end;

//------------------------------------------------------------------------------
procedure Mouse_Get(var Buttons,Xpos,Ypos:longword);
begin
   FlushMessages;
   Buttons := iostr.msd_Buttons;
   Xpos := iostr.msd_Xpos;
   Ypos := iostr.msd_Ypos;
end;

//------------------------------------------------------------------------------
procedure Mouse_GetDiff(var Xdif,Ydif:longint);
begin
   FlushMessages;
   Xdif := iostr.msd_Xdiff;
   Ydif := iostr.msd_Ydiff;
   iostr.msd_Xdiff := 0; { after get clear }
   iostr.msd_Ydiff := 0;
end;

//------------------------------------------------------------------------------
procedure Mouse_SetPosition(Xpos,Ypos:longword);
begin
   SetCursorPos(Xpos, Ypos);
end;

//------------------------------------------------------------------------------
function TestKey(akey:longword):boolean;
begin
   FlushMessages;
   TestKey := iostr.keyscanmap[akey and $7F] <> 0;
end;

//------------------------------------------------------------------------------
function KeyPressed:boolean;
begin
   FlushMessages;
   KeyPressed := iostr.kbdBegin <> iostr.kbdEnd;
end;

//------------------------------------------------------------------------------
function GetKey:word;
var w:word;
begin
   FlushMessages;
   w:=0;
   if iostr.kbdBegin <> iostr.kbdEnd then
   begin
      w:=iostr.kbdBuff[iostr.kbdEnd];
      iostr.kbdEnd := (iostr.kbdEnd + 1) and 31;
   end;
   GetKey := w;
end;

//------------------------------------------------------------------------------
procedure FlushKeys;
var i:integer;
begin
   for i := 0 to 128 do iostr.keyscanmap[i] := 0;
   iostr.keyhitc := 0;
   iostr.kbdBegin := 0;
   iostr.kbdEnd := 0;
end;

//------------------------------------------------------------------------------
function  WaitKeyGet:word;
begin
   repeat until KeyPressed;
   WaitKeyGet := GetKey;
end;

//------------------------------------------------------------------------------
procedure WaitKey;
begin
   WaitKeyGet;
end;

//------------------------------------------------------------------------------
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
function KeyHit(VK:longword):longword;
begin
  FlushMessages;
  KeyHit := dword((GetAsyncKeyState(VK) and 1) = 1);
end;

procedure GDI_DrawPicBuffer(Xpos,Ypos,Xlng,Ylng,Bpp,SXlng,SYlng,SrcPtr:longword);
Var bisize,i : longword;
    pbitmapinfo : array[0..2048] of byte; // sizeof(BITMAPINFOHEADER)+512  { 512 for 256 di colors word }
begin
   if EnterW= 0 then Exit;

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
         StretchDiBits(Win_dc, xpos,ypos,xlng,ylng, 0,0,sxlng,sylng,
                         pointer( srcptr), bitmapinfo((@pbitmapinfo)^),
                         DIB_RGB_COLORS, SRCCOPY);
      end;


   end;
   end;
end;


Initialization
   EnterW := 0;

   // INIT call back functions
   OnIdle := @nopProc;
   OnMouse := @nopProc;
   OnKey := @nopProc;
   OnTimer := @nopProc;
   OnQuit := @nopProc;
   OnPaint := @nopProc;
   OnClick := @nopProc;
   OnActive := @nopProc;
   OnDeActive := @nopProc;
   OnCommand := @nopProc;
   OnCreate := @nopProc;
   OnOther := @nopProc;
   OnSize := @nopProc;


end.
