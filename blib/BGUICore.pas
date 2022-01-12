unit BGUICore;

interface

uses windows;

const
      DRF_GETCXPOS         = 1;
      DRF_GETCYPOS         = 2;
      DRF_GETCXLNG         = 3;
      DRF_GETCYLNG         = 4;

      BGUI_MASTER_EVENT_KEY           = 1  ; //Keyboard event from windows
      BGUI_MASTER_EVENT_MOUSE         = 2  ; //
      BGUI_MASTER_EVENT_RESIZE        = 3  ; //
      BGUI_MASTER_EVENT_REPAINT       = 4  ; //

      W_NOP               = 0  ;
      W_ABORT             = 1  ; //Fast exit kernel (abort system)
      W_HALT              = 2  ; //Close all windows & exit kernel
      W_RUN               = 3  ; //When no signal, kernel send this
      W_TIMER             = 4  ; //If requiest for this signal, send
      W_PAUSE             = 5  ; //Activate screen saver, if set
      W_SKEY              = 6  ; //Message from keyboard
      W_SMOUSE            = 7  ; //Message from mouse
      W_REPAINT           = 8  ; //Kernel must repain area
      W_SHOW              = 9  ;
      W_HIDE              = 10 ;
      W_RESTORE           = 11 ;
      W_MAXIMIZE          = 12 ;
      W_MINIMIZE          = 13 ;
      W_RESIZEWIN         = 14 ;
      W_SETPOS            = 15 ;

      W_PAINT             = 17 ;
      W_RESIZE            = 18 ;
      W_KEY               = 19 ;
      W_MOUSE             = 20 ;

      SW_SHOW             = 0;
      SW_HIDE             = 1;
      SW_MINIMIZE         = 2;
      SW_MAXIMIZE         = 3;
      SW_RESTORE          = 4;

      (*
#define       WM_NOP              0     /* Did I use this ... ? :-)         */
#define       WM_ABORT            1     /* Fast exit kernel (abort system)  */
#define       WM_HALT             2     /* Close all windows & exit kernel  */
#define       WM_RUN              3     /* When no signal, kernel send this */
#define       WM_TIMER            4     /* If requiest for this signal, send*/
#define       WM_PAUSE            5     /* Activate screen saver, if set    */
#define       WM_KEY              6     /* Initial message from keyboard    */
#define       WM_MOUSE            7     /* Initial message from mouse       */
#define       WM_CREATE           8     /* Msg to kernel to create new win  */
#define       WM_KILL             9     /* Close given window               */
#define       WM_INIT             10    /* Signal (in begin) to init some.. */
#define       WM_QUIT             11    /* Signal (in end) to free some..   */
#define       WM_ACTIVE           12    /* Your window now is active        */
#define       WM_DEACTIVE         13    /* Your window lost activity        */
#define       WM_LINK             14    /* Msg to kernel to link window     */
#define       WM_UNLINK           15    /* Msg to kernel to detach window   */

#define       WM_PAINT            17    /* To user to pain own ...          */
#define       WM_MOVE             18    /* Kernel move win to given pos..   */
#define       WM_SIZE             19    /* Kernel resize win to given size..*/
#define       WM_DRAW             20    /* Kernel to refresh window frame   */
#define       WM_REDRAW 	  21	/* Kernel must repaint frame	    */
#define       WM_FOCUS            22    /* Change focus to anader window    */
#define       WM_ONWINDOW         23    /* Kernel pop window ... system :-) */
#define       WM_MINIMIZE         25    /* Kernel minimize given window     */
#define       WM_RESTORE          26    /* Kernel restore from min win..    */
#define       WM_COMMAND          27    /* This you know ... :(             */
#define       WM_KEYBRD           28    /* To user keyboard value           */
#define       WM_MOUSEMOVE        29    /* To user mouse move to pos ...    */
#define       WM_MOUSERBPRESS     30    /* .. mouse right button pressed    */
#define       WM_MOUSELBPRESS     31    /* .. mouse left button pressed     */
#define       WM_MOUSEMBPRESS     32    /* .. mouse middle button pressed   */
#define       WM_MOUSERBREL       33    /* .. mouse right button release    */
#define       WM_MOUSELBREL       34    /* .. mouse left button release     */
#define       WM_MOUSEMBREL       35    /* .. mouse middle button release   */
#define       WM_MOUSERDOUBLE     36    /* .. mouse right button pr. double */
#define       WM_MOUSELDOUBLE     37    /* .. mouse left button pr. double  */
#define       WM_MOUSEMDOUBLE     38    /* .. mouse middle button pr. double*/
#define       WM_GETFOCUS	  39	/* The area is now under the focus  */
#define       WM_LOSEFOCUS        40    /* The area lose focus              */
#define       WM_ENABLE 	  41	/* Show window			    */
#define       WM_DISABLE	  42	/* Hide window			    */
#define       WM_FRAME		  43	/* Change frame active flag	    */
#define       WM_ICON		  44	/* Kernel must rapain one area ..   */
#define       WM_ALLICONS	  45	/* Kernel must rapaint all areas .. */
#define       WM_SCROLL 	  46	/* Some scroll bar was moved ..     */
#define       WM_USER		  47	/* From this point user can def own.*/

        *)



      { WINDOW CORE FLAGS }
      FW_VISIBLE                 = $00000001;
      FW_ENABLED                 = $00000002;
      FW_MINMAXFORM              = $00000004;

      WCF_FOCUSSTOP              = $00000002;

      WCF_RECIVEKEY              = $00000004;
      WCF_ENABLE                 = $00000008;
      WCF_CLIENTDRAW             = $00000010;
      WCF_NEEDTIMER              = $00000020;
      WCF_SHOW                   = $00000040;

      { WINDOW CORE LONG }
      WCL_XPOS                   = 1;
      WCL_YPOS                   = 2;
      WCL_XLNG                   = 3;
      WCL_YLNG                   = 4;
      WCL_PROC                   = 5;
      WCL_DRAW                   = 6;
      WCL_FLAGS                  = 7;

      { WINDOW CORE TEXT }
      WCT_TEXT                   = 1;




type  BTGUI_WndProc = function(WinHand,Msg,Parm1,Parm2:longword):longint; stdcall;


      PBTGUI_Object = ^BTGUI_Object;
      BTGUI_Object = record
         Magic       :longword;
         Next        :pointer;
         Lock        :longword;
         Id          :longword;
         ChildItems  :pointer;

         Flags       :longword;
         Style       :longword;

         Proc        :pointer;
         Draw        :pointer;

         Xpos        :longint;
         Ypos        :longint;
         Xlng        :longint;
         Ylng        :longint;
         CXpos       :longint; //Client rectangle
         CYpos       :longint;
         CXlng       :longint;
         CYlng       :longint;

         rXpos       :longint;
         rYpos       :longint;
         rXlng       :longint;
         rYlng       :longint;
         rCXpos      :longint; //Client rectangle
         rCYpos      :longint;
         rCXlng      :longint;
         rCYlng      :longint;


         UserData    :longword;
         EData       :pointer;

         Prop        :string;
         Txt         :string;
         Txt2        :string;
      end;


var   BGUI_core : record
         Magic              :longword;
         MainThreadHandle   :longword;
         MainThreadID       :longword;
         MainThreadFunc     :pointer;
         MainThreadRun      :longword;
         ObjectsList        :pointer;
         MasterCallBack     :pointer;
         MasterCallBackParm :longword;
         Msg_Tail           :pointer;
         Msg_Tail_begin     :longword;
         Msg_Tail_end       :longword;
         ScreenXlng         :longword;
         ScreenYlng         :longword;
         OnFocusWindow      :longword;
         MouseXpos          :longint;
         MouseYpos          :longint;
         CritSec            :_RTL_CRITICAL_SECTION;
      end;



function  BGUI_CreateGUIcontext :longword; stdcall;
function  BGUI_DestroyGUIcontext :longword; stdcall;
function  BGUI_SetMasterEvent(TheEvent, TheParm1, TheParm2 :longword) :longword; stdcall;
function  BGUI_SetMasterCallBack(TheCallback :pointer; TheUserData :longword)  :longword; stdcall;

function  BGUI_PostMessage(TheObj, TheMsg, TheParm1, TheParm2 :longword) :longword; stdcall;
function  BGUI_SendMessage(TheObj, TheMsg, TheParm1, TheParm2 :longword) :longword; stdcall;

function  BGUI_CretaeWindow(class_wndproc,class_drawproc:longword; const WinText:string; Flags,Style:longword; Xpos,Ypos:longint; Xlng,Ylng,Parent,Param:longword) :longword; stdcall;
procedure BGUI_DestroyWindow(WinHand:longword); stdcall;

procedure BGUI_SetProp(WinHand:longword; PropName:string; PropValue :longword); stdcall;
function  BGUI_GetProp(WinHand:longword; PropName:string; PropValue :longword) :longword; stdcall;
procedure BGUI_RemoveProp(WinHand:longword; PropName:string) stdcall;

procedure BGUI_SetWindowText(WinHand :longword; const Txt:string); stdcall;
function  BGUI_GetWindowText(WinHand :longword):string; stdcall;
procedure BGUI_SetWindowData(WinHand :longword; const Txt:string); stdcall;
function  BGUI_GetWindowData(WinHand :longword):string; stdcall;

procedure BGUI_ShowWindowEx(WinHand,mode:longword); stdcall;
procedure BGUI_CloseWindow(WinHand:longword); stdcall;
procedure BGUI_ShowWindow(WinHand:longword); stdcall;
procedure BGUI_HideWindow(WinHand:longword); stdcall;
procedure BGUI_MinimizeWindow(WinHand:longword); stdcall;
procedure BGUI_MaximizeWindow(WinHand:longword); stdcall;
procedure BGUI_RestoreWindow(WinHand:longword); stdcall;

procedure BGUI_GetWindowSize(WinHand :longword; var Xlng,Ylng:longword); stdcall;
procedure BGUI_SetWinodwSize(WinHand,Xlng,Ylng:longword); stdcall;
procedure BGUI_AdjustWinowSize(WinHand,WantClientXlng,WantClientYlng:longword); stdcall;
procedure BGUI_GetClientRect(WinHand :longword; var Xpos,Ypos,Xlng,Ylng:longword); stdcall;
procedure BGUI_SetWindowPos(WinHand :longword; Xpos,Ypos:longint); stdcall;
procedure BGUI_GetWinodwPos(WinHand :longword; var Xpos,Ypos:longint); stdcall;

procedure BGUI_SetWindowLong(WinHand,ParId,ParValue:longword); stdcall;
function  BGUI_GetWinodwLong(WinHand,ParId:longword):longword; stdcall;

function  BGUI_GetParent(WinHand:longword):longword; stdcall;
procedure BGUI_SetParent(WinHand,TheParent:longword); stdcall;

function  BGUI_GetSystemMetrics(WinHand,MetrId:longword):longword; stdcall;

procedure BGUI_SetTimer(WinHand,Id,Flags,Milisec:longword); stdcall;

//function  BGUI_FindWindow
//function  BGUI_EnumWindows(winID_root,indx:longword):longword;
//procedure BGUI_BringWindowToTop()
//BGUI_SetAlive
//BGUI_SetEnable
//BGUI_SetVisible
//BGUI_SetData
//BGUI_SetChecket
//BGUI_SetState
//BGUI_SetExecuter
//BringToFront
//SendToBack
//SetTabOrder
//refresh or invalidate


implementation

uses BStrTools;


const BGUI_CTXMAGIC = $43EA5EFD;
      BGUI_OBJMAGIC = $7E53CE9A;

      BGUI_MsgTailSize = 128;

type  BGUI_Message = record
         Obj :longword;
         Msg :longword;
         P1  :longword;
         P2  :longword;
      end;
      BGUI_MSGTail = array [1..BGUI_MsgTailSize] of BGUI_Message;
      PBGUI_MSGTail = ^BGUI_MSGTail;

//------------------------------------------------------------------------------
function _GoodObject(hand:longword; var Obj:PBTGUI_Object):boolean;
begin
   try
      if Hand = 0 then
      begin
         Obj := nil;
         Result := false;
         Exit;
      end;
      Obj := PBTGUI_Object(hand);
      if Obj.Magic = BGUI_OBJMAGIC then
      begin
         if Obj.Lock <> 0 then
         begin
            // wait;
            while Obj.lock <> 0 do
            begin
               if (GetTickCount - Obj.Lock) > 2000 then break;  // time out re-lock it again
               sleep(5);
            end;
         end;
         Obj.lock := GetTickCount;
         Result := True;
      end else Result := false;
   except
      Result := false;
   end;
end;


function _Combine2val(a,b:longint):longword;
begin
   Result := ((longword(a) and $FFFF) shl 16) or (longword(b) and $FFFF);
end;

//------------------------------------------------------------------------------
function _BGUI_MainThread(a:longword):longint; stdcall;
var aObj,aMsg,aP1,aP2:longword;
begin
   Result :=0;
   try
      while BGUI_Core.MainThreadRun <> 0 do
      begin

         while BGUI_Core.Msg_Tail_begin <> BGUI_Core.Msg_Tail_end do
         begin
            EnterCriticalSection(BGUI_Core.CritSec);
            with PBGUI_MSGTail(BGUI_Core.MSG_Tail)[BGUI_Core.MSG_tail_begin] do
            begin
               aObj := Obj;
               aMsg := Msg;
               aP1  := p1;
               aP2  := p2;
            end;
            inc(BGUI_Core.MSG_tail_begin);
            if BGUI_Core.MSG_tail_begin > BGUI_MsgTailSize then BGUI_Core.MSG_tail_begin := 1;
            LeaveCriticalSection(BGUI_Core.CritSec);
            BGUI_SendMessage(aObj,aMsg,aP1,ap2); // ----- B U T C H E R ------
         end;

         sleep(10); // some pause
      end;
   except
   end;
end;

//------------------------------------------------------------------------------
function BGUI_CreateGUIcontext :longword; stdcall;
begin
   Result := 0; //error

   //initialise context
   BGUI_Core.Magic := BGUI_CTXmagic;
   BGUI_Core.ObjectsList := nil;
   BGUI_Core.MasterCallBack := nil;
   BGUI_Core.MasterCallBackParm := 0;
   BGUI_Core.Msg_Tail_begin := 1;
   BGUI_Core.Msg_Tail_end := 1;
   BGUI_Core.Msg_Tail := nil;
   ReallocMem(BGUI_Core.Msg_Tail,BGUI_MsgTailSize*sizeof(BGUI_Message));
   if BGUI_Core.Msg_Tail = nil then Exit;

   InitializeCriticalSection(BGUI_Core.CritSec);
   InitializeCriticalSectionandSpinCount(BGUI_Core.CritSec,2);
   BGUI_Core.MainThreadRun := 1;
   BGUI_Core.MainThreadFunc := @_BGUI_MainThread;
   BGUI_Core.MainThreadHandle := CreateThread(nil,0,BGUI_Core.MainThreadFunc,nil,0,BGUI_Core.MainThreadID);
   if BGUI_Core.MainThreadHandle = 0 then
   begin
      ReallocMem(BGUI_Core.Msg_Tail,0);
      Exit;
   end;
   Result := 1; //ok
end;

//------------------------------------------------------------------------------
function BGUI_DestroyGUIcontext :longword; stdcall;
begin
   Result := 0;
   if BGUI_Core.Magic = BGUI_CTXMAGIC then
   begin
      BGUI_Core.MainThreadRun := 0; // set signal to terminate
      sleep(500);
      TerminateThread(BGUI_Core.MainThreadHandle,0);
      CloseHandle(BGUI_Core.MainThreadHandle);
      DeleteCriticalSection(BGUI_Core.CritSec);
      ReallocMem(BGUI_Core.Msg_Tail,0); // free memory
      Result := 1;
   end;
end;

//------------------------------------------------------------------------------
function BGUI_SetMasterEvent(TheEvent, TheParm1, TheParm2 :longword) :longword; stdcall;
begin
   Result := 0; //error
   if BGUI_Core.Magic = BGUI_CTXMAGIC then
   begin
      case TheEvent of
         BGUI_MASTER_EVENT_KEY : begin

         end;
         BGUI_MASTER_EVENT_MOUSE : begin

         end;
         BGUI_MASTER_EVENT_RESIZE : begin
            BGUI_Core.ScreenXlng := TheParm1;
            BGUI_Core.ScreenYlng := TheParm2;
            Result := BGUI_PostMessage(0,W_REPAINT,0,0); // repaint all
         end;
         BGUI_MASTER_EVENT_REPAINT : begin
            // repaint all  Parm1 = Xpos(Hi)Ypos(Lo)  Parm2 = Xlng(Hi)Ypos(Lo)
            Result := BGUI_PostMessage(0,W_REPAINT,TheParm1,TheParm2);
         end;
      end;
   end;
end;

//------------------------------------------------------------------------------
function BGUI_SetMasterCallBack(TheCallback :pointer; TheUserData :longword)  :longword; stdcall;
begin
   Result := 0; //error
   if BGUI_Core.Magic = BGUI_CTXMAGIC then
   begin
      BGUI_Core.MasterCallBackParm := TheUserData;
      BGUI_Core.MasterCallBack := TheCallBack;
      Result := 1;
   end;
end;

//------------------------------------------------------------------------------
function BGUI_PostMessage(TheObj, TheMsg, TheParm1, TheParm2 :longword) :longword; stdcall;
begin
   Result := 0; //error
   if BGUI_Core.Magic = BGUI_CTXMAGIC then
   begin
      EnterCriticalSection(BGUI_Core.CritSec);
      with PBGUI_MSGTail(BGUI_Core.MSG_Tail)[BGUI_Core.MSG_tail_end] do
      begin
         Obj := TheObj;
         Msg := TheMsg;
         P1  := TheParm1;
         P1  := TheParm2;
      end;
      inc(BGUI_Core.Msg_Tail_end);
      if BGUI_Core.Msg_Tail_end > BGUI_MsgTailSize  then BGUI_Core.Msg_Tail_end := 1;
      if BGUI_Core.Msg_Tail_end = BGUI_Core.Msg_Tail_begin then
      begin // Message overload
         dec(BGUI_Core.Msg_Tail_end);
         if BGUI_Core.Msg_Tail_end = 0 then BGUI_Core.Msg_Tail_end := BGUI_MsgTailSize;
      end;
      LeaveCriticalSection(BGUI_Core.CritSec);
      Result := 1; //Ok
   end;
end;

//------------------------------------------------------------------------------
type  TRepaintObjRect = record
          Obj,Xpos,Ypos,Xlng,Ylng:longword;
      end;
      TArrayRepaintObjRect = array of TRepaintObjRect;


procedure _ClipByScreen(var X,Y,Xl,YL:longint);
begin
   if X < 0 then X := 0;
   if Y < 0 then Y := 0;
   if (X + XL) > longint(BGUI_Core.ScreenXlng) then XL := longint(BGUI_Core.ScreenXlng) - X;
   if (Y + YL) > longint(BGUI_Core.ScreenYlng) then YL := longint(BGUI_Core.ScreenYlng) - Y;
end;

function _OverlapedRect(Xa,Ya,XLa,YLa:longint; var Xb,Yb,Xlb,YLb:longint):boolean;
var xae,yae,xbe,ybe:longint;
begin
   Result := true;         // Clip B by clip region A

   _ClipByScreen(Xa,Ya,XLa,YLa);

   xae := Xa + XLa-1;
   yae := Ya + YLa-1;
   xbe := Xb + XLb-1;
   ybe := Yb + YLb-1;

   if  xb  < xa  then xb  := xa;
   if  xbe > xae then xbe := xae;
   if (xae-xb)<0 then Result := false;
   if  yb  < ya  then yb  := ya;
   if  ybe > yae then ybe := yae;
   if (xae-xb)<0 then Result := false;
   Xlb := xbe - xb +1;
   Ylb := ybe - yb +1;
end;


procedure _SplitOverlapedRect(Xp,Yp,Xl,Yl:longint; var CurRect,ObjCount:longword; var DynArr:TArrayRepaintObjRect);
var i,x,y,xt,yt,xe,ye,Xpe,Ype,ny,nyl:longint;
    o,j:longword;
begin
   i := 0; // count of splits
   // this is  rectangle for test   //    top       xxxxxxxx
   x := DynArr[CurRect].Xpos;       //          ------+-------+----
   y := DynArr[CurRect].Ypos;       //    left      xx|xxxxx  |     right
   xt := DynArr[CurRect].Xlng;      //          ------+-------+----
   yt := DynArr[CurRect].Ylng;      //    bottom    xxxxxxxx
   xe := x + xt - 1;
   ye := y + yt - 1;
   Xpe := Xp + XL - 1;
   Ype := Yp + YL - 1;
   o := DynArr[CurRect].Obj;
   j := CurRect;
   // fast overlaping test see bellow
   if (X <= Xpe) and (Xe >= Xp) then // ve over;aping by X
   begin
      // Test for top
      if (Yp > y) and (Yp <= ye) then  //
      begin                            //
         //first reuse                 //   Y   Yp -no top
         //inc(ObjCount);              //   |   Yp  (Yp>y)
         inc(i);                       //   |
         //SetLength(DynArr,ObjCount); //   | X Xt    Y   (Yp-Y)
         DynArr[j].Xpos := X;          //   |
         DynArr[j].Ypos := Y;          //   |
         DynArr[j].Xlng := Xt;         //   Ye  Yp  (Yp<=Ye)
         DynArr[j].Ylng := Yp - Y;     //       Yp -notp
         DynArr[j].Obj := o;
      end;
      // Test for Bottom
      if (Ype >= y) and (Ype < ye) then
      begin
         if i <> 0 then
         begin
            inc(ObjCount);               //       Ype - no bottom
            SetLength(DynArr,ObjCount);  //   Y   Ype (Ype >= y)
            j := ObjCount;               //   |
         end;                            //   |
         inc(i);                         //   |  X Xt    Ype + 1  (Ye-Ype)
         DynArr[j].Xpos := X;            //   |
         DynArr[j].Ypos := Ype + 1;      //   |   Ype  (Ype < Ye)
         DynArr[j].Xlng := Xt;           //   Ye  Ype - no bottom
         DynArr[j].Ylng := Ye - YPe;     //
         DynArr[j].Obj := o;
      end;
      // Test for left right
      if (Y <= Ype) and (Ye >= Yp) then
      begin
         //adjust left/right by Y an Ye clipped by Yp and Ype
         if (Y < Yp) then ny := Yp
                     else ny := Y;
         if (Ye > Ype) then nyl := Ype
                       else nyl := Ye;
         nyl := nyl - ny + 1;

         // Test for left
         if (Xp > X) and (Xp <= Xe) then    //
         begin                              //   X-------------------Xe
            if i <> 0 then                  //   Xp - no left
            begin                           //    Xp ( Xp > X)
               inc(ObjCount);               //                       Xp (Xp<=Xe
               SetLength(DynArr,ObjCount);  //                        Xp - no left
               j := ObjCount;               //
            end;                            //
            inc(i);                         //
            DynArr[j].Xpos := X;            //
            DynArr[j].Ypos := ny;           //
            DynArr[j].Xlng := Xp - X;       //
            DynArr[j].Ylng := nyl;          //
            DynArr[j].Obj := o;
         end;
         // Test for Right
         if (Xpe >= X) and (Xpe < Xe) then  //
         begin                              //   X-------------------Xe
            if i <> 0 then                  //  Xpe - no right       |
            begin                           //  |Xpe ( Xpe >= X)     ||
               inc(ObjCount);               //   |                   Xpe (Xpe<Xe
               SetLength(DynArr,ObjCount);  //                       |Xpe - no right
               j := ObjCount;               //                        |
            end;                            //
            inc(i);                         //
            DynArr[j].Xpos := Xpe + 1;      //
            DynArr[j].Ypos := ny;           //
            DynArr[j].Xlng := Xe - Xpe;     //
            DynArr[j].Ylng := nyl;          //
            DynArr[j].Obj := o;
         end;

         if i = 0 then // We have Obj bigerr that in list
         begin
            DynArr[j].Xlng := 0; // dont draw
            DynArr[j].Ylng := 0;
         end;

      end;
   end;
end;

function _GetOverlapedObject(Xp,Yp,Xl,Yl:longint; TheObj :longword; var X,Y,tX,tY:longint):boolean;
var Xpe,Ype,xe,ye:longint;
    b:PBTGUI_Object;
begin
   try
      b := pointer(TheObj);

      Xpe := Xp + Xl - 1;
      Ype := Yp + Yl - 1;
      x := b.Xpos;
      y := b.Ypos;
      xe := b.Xlng;
      ye := b.Ylng;
      _ClipByScreen(x,y,xe,ye);
      xe := x + xe - 1;
      ye := y + ye - 1;
     // fast overlaped test
      //               Y <= Ype    Ye => Yp    same for X
      //  1 Y
      //    |  Yp         Y           Y
      //    |  Ype
      //    Ye
      //
      //  2    Yp
      //    Y  |          Y           Y
      //    Ye |
      //       Ype
      //
      //  3    Yp
      //    Y  |          Y           Y
      //    |  Ype
      //    Ye
      //
      //  4 Y
      //    |  Yp         Y           Y
      //    Ye |
      //       Ype
      //
      //  5    Yp
      //       Ype        N           Y
      //    Y
      //    Ye
      //
      //  6 Y
      //    Ye            Y           N
      //       Yp
      //       Ype
      //
      //
      // clip object by Xp yP Xpe YPE
//      if (oxe <= xp) and (ox >= xpe) then //  over;aping by X
//      begin
//      if (oye <= yp) and (oy >= ype) then //  over;aping by Y
//      begin

      // optimized version
      Result := true;
      if  X < xp  then X  := xp;
      if xe > xpe then xe := xpe;
      if (longint(xe)-longint(X))<0 then Result := false;
      if  Y < yp  then Y  := yp;
      if ye > ype then ye := ype;
      if (longint(ye)-longint(Y))<0 then Result := false;
      tX := xe - X + 1;
      tY := ye - Y + 1;
   except
      Result := false;
   end;
end;


procedure _GetRepaintObjectsRec(m: longword; Xp,Yp:longint; Xl,Yl, TheObj :longword; var ObjCount:longword; var DynArr:TArrayRepaintObjRect);
var b:PBTGUI_Object;
    X,Y,tX,tY,w:longint;
    i,ii:longword;
begin

   try
      b := pointer(TheObj);
      repeat
         if (b.Flags and FW_VISIBLE) <> 0 then
         begin

            if _GetOverlapedObject(Xp,Yp,Xl,Yl,TheObj,X,Y,tX,tY) then
            begin
               // now I have an area and I must test is it overlaped existing pain areas
               if ObjCount > 0 then
               begin
                  w := ObjCount;
                  for i := 1 to w do
                  begin
                     ii := i; // cant pass as var
                     _SplitOverlapedRect(X,Y,tX,tY,ii,ObjCount,DynArr);
                  end;
               end;

               inc(ObjCount);
               SetLength(DynArr,ObjCount);
               DynArr[ObjCount].Obj := TheObj;
               DynArr[ObjCount].Xpos := X;
               DynArr[ObjCount].Ypos := Y;
               DynArr[ObjCount].Xlng := tX;
               DynArr[ObjCount].Ylng := tY; // this is the area for Paint  on top

               i := longword(b.ChildItems);
               if i <> 0 then // recursivlely for childens
               begin
                  _GetRepaintObjectsRec(0, Xp,Yp,Xl,Yl,i,ObjCount,DynArr); // recurve all childrens
               end;
            end;

         b := b.Next;
         end;
      until (b = nil) or (m <> 0); // if m <> 0 stop on this object
   except
       ObjCount := 0; // is not possible but
   end;
end;

procedure _GetRepaintObjects(m:longword; Xp,Yp,Xl,Yl:longint; TheObj :longword; var ObjCount:longword; var DynArr:TArrayRepaintObjRect);
begin
   _ClipByScreen(Xp,Yp,Xl,YL);
   if (XL>0) and (YL>0) then
   begin
      _GetRepaintObjectsRec(m{mode}, Xp,Yp,Xl,Yl,TheObj,ObjCount,DynArr); //Recursive call
   end;
end;

procedure _SendMsgRec(TheObj, TheMsg, TheParm1, TheParm2 :longword);
var b:PBTGUI_Object;
    r:longint;
    i :longword;
    WinPrc :BTGUI_WndProc;
begin

   try
      b := pointer(TheObj);
      repeat

         WinPrc := b.Proc;
         r := WinPrc(TheObj,TheMsg,TheParm1,TheParm2);
         if r = 1 then Exit; // stop

         i := longword(b.ChildItems);
         if i <> 0 then // recursivlely for childens
         begin
            _SendMsgRec(TheObj,TheMsg,TheParm1,TheParm2); // recurve all childrens
         end;

         b := b.Next;
      until (b = nil) ; // if m <> 0 stop on this object
   except
      //
   end;
end;


//------------------------------------------------------------------------------
function BGUI_SendMessage(TheObj, TheMsg, TheParm1, TheParm2 :longword) :longword; stdcall;
var b:PBTGUI_Object;
    x,tx,y,ty:longint;
    i,w,m:longword;
    a:TArrayRepaintObjRect;
begin
                 // --------------------------
                 // ----- B U T C H E R ------
                 // --------------------------

   Result := 0; //fail
   if BGUI_Core.Magic = BGUI_CTXMAGIC then
   begin
      if not _GoodObject(TheOBj,b) then b := nil;
              //TODO dead lock     we have EXit !!!!

      case TheMsg of
         { system messages }
         W_NOP : begin

         end;
         W_ABORT : begin//     = 1  ; //Fast exit kernel (abort system)

         end;
         W_HALT : begin//      = 2  ; //Close all windows & exit kernel

         end;
         W_RUN : begin//       = 3  ; //When no signal, kernel send this

         end;
         W_TIMER : begin//     = 4  ; //If requiest for this signal, send

         end;
         W_PAUSE : begin//     = 5  ; //Activate screen saver, if set

         end;
         W_SKEY : begin//       = 6  ; //Message from keyboard
            // get focuse window and send event
            //w := on focus
            _SendMsgRec(w,W_KEY,TheParm1,TheParm2);
         end;
         W_SMOUSE : begin//     = 7  ; //Message from mouse
            // get focuse window and send event
            //w := on focus
            BGUI_Core.MouseXpos := longint((TheParm1 shr 16) and $FFFF);
            BGUI_Core.Mouseypos := longint( TheParm1         and $FFFF);

            _SendMsgRec(w,W_MOUSE,TheParm1,TheParm2);
            //todo test mouse window and send on mouse mouse enter mouse leave
            // test recursivle for obj to set click if click
         end;
         W_REPAINT : begin//   = 8  ; //Kernel must repain area
            // rules to senf W_PAINT
               // REPAINT MODE LIST
               //  TheObj X  Y  Xl Yl
               //1.   0    V  V  V  V    - upadet all from bottom to top
               //2.  Obj   V  V  V  V    - only this obj and all childs
               //3.  Obj   0  0  0  0    - take from Obj and rule 2
               //
               //
            x  := longint((TheParm1 shr 16) and $FFFF); // Xpos int
            y  := longint( TheParm1         and $FFFF); // Ypos
            tx := longint((TheParm2 shr 16) and $FFFF); // Xlng unsigned
            ty := longint( TheParm2         and $FFFF); // Ylng
            if (tx=0) or (ty=0) then // rule 3
            begin
               if b <> nil then
               begin
                  x := b.Xpos;
                  y := b.Ypos;
                  tx := b.Xlng;
                  ty := b.Ylng;
               end else Exit;
            end;

            //clip by screan is inside the _getRepaintObject
            i := TheObj;
            m := i; // <> 0 obj + childrens
            if b = nil then
            begin
               i := longword(BGUI_Core.ObjectsList); //Must start from first
               m := 0; //recurse all bottom -> top
            end;
            w := 0;
            _GetRepaintObjects(m,x,y,tx,ty,i,w,a);
            if w > 0 then
            begin
               //TODO what if W > tail !!!!!!!!!!!!!!!!!!!!!!!!!
               for i:= 1 to w do
               begin
                  if (a[i].Xlng + a[i].Ylng) <> 0 then
                  begin
                     BGUI_PostMessage(a[i].Obj, W_PAINT, _Combine2val(a[i].Xpos,a[i].Xpos), _Combine2val(a[i].Xlng,a[i].Xlng));
                  end;
               end;
            end;
         end;
         W_SHOW : begin//      = 9  ;
            if b = nil then Exit; // not good window
            b.Flags := b.Flags and (not FW_VISIBLE);
            BGUI_PostMessage(0,W_REPAINT,_Combine2val(b.Xpos,b.Ypos),_Combine2val(b.Xlng,b.Ylng)); // restore screen
         end;
         W_HIDE : begin//      = 10 ;
            if b = nil then Exit; // not good window
            b.Flags := b.Flags and (not FW_VISIBLE);
            BGUI_PostMessage(0,W_REPAINT,_Combine2val(b.Xpos,b.Ypos),_Combine2val(b.Xlng,b.Ylng)); // restore screen
         end;
         W_RESTORE : begin//   = 11 ;
            if b = nil then Exit; // not good window
            if (b.Flags and FW_MINMAXFORM) = 0 then Exit; // nothing to restore
            b.Xpos := b.rXpos;
            b.Ypos := b.rYpos;
            b.Xlng := b.rXlng;
            b.Ylng := b.rYlng;
            b.CXpos := b.rCXpos;
            b.CYpos := b.rCYpos;
            b.CXlng := b.rCXlng;
            b.CYlng := b.rCYlng;
            b.Flags := b.Flags and (not FW_MINMAXFORM);
            BGUI_PostMessage(TheObj,W_REPAINT,0,0);
         end;
         W_MAXIMIZE : begin//  = 12 ;

         end;
         W_MINIMIZE : begin//  = 13 ;

         end;
         W_RESIZEWIN : begin// = 14 ;

         end;
         W_SETPOS : begin//    = 15 ;
            if b = nil then Exit; // not good window
            tx := b.Xpos;
            ty := b.Ypos;
            x := longint(TheParm1);
            y := longint(TheParm2);
            b.Xpos := x;
            b.Ypos := y;
            // paint the new one
            w  := _Combine2val(b.Xlng,b.Ylng);
            BGUI_PostMessage(TheObj,W_REPAINT,0,0);
            // test for overlaping
            if _OverlapedRect(x,y,b.Xlng,b.Ylng,tx,ty,b.Xlng,b.Ylng) then
            begin


            end else begin
               BGUI_PostMessage(0,W_REPAINT,_Combine2val(tx,ty),w); // restore old screen in div pos
            end;
         end;

         else begin
            { all other messages }
            if b = nil then TheObj := longword(BGUI_Core.ObjectsList); // broeadcast to all from bottom to top
            _SendMsgRec(TheObj,TheMsg,TheParm1,TheParm2);
         end;
      end;
      //todo dead loop
      if b <> nil then b.Lock := 0;
   end;
end;

//------------------------------------------------------------------------------
function BGUI_CretaeWindow(class_wndproc,class_drawproc:longword; const WinText:string; Flags,Style:longword; Xpos,Ypos:longint; Xlng,Ylng,Parent,Param:longword) :longword; stdcall;
var b,n:PBTGUI_Object;
begin
   Result := 0; //fail
   if BGUI_Core.Magic = BGUI_CTXMAGIC then
   begin
      // Test parrent
      // cretae new object
      n := nil;
      ReallocMem(n, Sizeof(BTGUI_Object));
      if n = nil then Exit;

      n.Magic := BGUI_OBJMAGIC;
      n.Next := nil;
      n.Lock := 0;
      n.Id := 0; //todo
      n.ChildItems := nil;
      n.Flags := Flags;
      n.Style := Style;
      n.Proc := pointer(class_wndproc); //todo test for nul
      n.Draw := pointer(class_drawproc);
      n.Xpos := Xpos;
      n.Ypos := Ypos;
      n.Xlng := Xlng;
      n.Ylng := Ylng;
      n.CXpos := 0; //todo
      n.CYpos := 0; //todo
      n.CXlng := 0; //todo
      n.CYlng := 0; //todo
      n.rXpos := 0;
      n.rYpos := 0;
      n.rXlng := 0;
      n.rYlng := 0;
      n.rCXpos := 0;
      n.rCYpos := 0;
      n.rCXlng := 0;
      n.rCYlng := 0;

      //Link ------------------------------------------
      if Parent <> 0 then
      begin
         b := pointer(Parent);
         if b.Magic <> BGUI_OBJMAGIC then Exit;
         b := b.ChildItems;
         if b = nil then
         begin
            b.ChildItems := n;
         end else begin
            while b.Next <> nil do b:= b.Next;
            b.Next := n;
         end;
      end else begin
         b := BGUI_Core.ObjectsList;
         if b = nil then
         begin
            BGUI_Core.ObjectsList := n;
         end else begin
            while b.Next <> nil do b:= b.Next;
            b.Next := n;
         end;
      end;







      Result := longword(n);
   end;
end;

//------------------------------------------------------------------------------
procedure BGUI_DestroyWindow(WinHand:longword); stdcall;
var a:PBTGUI_Object;
begin

    a.Magic := 0; // if exist in meory after delete
end;


//------------------------------------------------------------------------------
procedure BGUI_SetProp(WinHand:longword; PropName:string; PropValue :longword); stdcall;
var a:PBTGUI_Object;
    i:longint;
    s:string;
begin
   if _GoodObject(WinHand,a) then
   begin
      s := char(byte( PropValue and $ff))         + char(byte((PropValue shr 8) and $ff))
         + char(byte((PropValue shr 16) and $ff)) + char(byte((PropValue shr 24) and $ff));
      PropName := #13+UpperCase(PropName)+#13;
      i := Pos(PropName,a.Prop);
      if i = 0 then
      begin
         a.Prop := a.Prop + PropName + s +#13; // set up new
      end else begin
         // update
         inc(i,length(PropName));
         if (i + 4) < length(a.Prop) then
         begin
            a.Prop[i]   := s[1];
            a.Prop[i+1] := s[2];
            a.Prop[i+2] := s[3];
            a.Prop[i+3] := s[4];
         end;
      end;
      a.Lock := 0;
   end;
end;

//------------------------------------------------------------------------------
function BGUI_GetProp(WinHand:longword; PropName:string; PropValue :longword) :longword; stdcall;
var a:PBTGUI_Object;
    i:longint;
begin
   Result := 0;
   if _GoodObject(WinHand,a) then
   begin
      PropName := #13+UpperCase(PropName)+#13;
      i := Pos(PropName,a.Prop);
      if i <> 0 then
      begin
         inc(i,length(PropName));
         if (i + 4) < length(a.Prop) then
         begin
            Result := longword(byte(a.Prop[i]))
                  or (longword(byte(a.Prop[i+1])) shl 8)
                  or (longword(byte(a.Prop[i+2])) shl 16)
                  or (longword(byte(a.Prop[i+3])) shl 24);
         end;
      end;
      a.Lock := 0;
   end;
end;

//------------------------------------------------------------------------------
procedure BGUI_RemoveProp(WinHand:longword; PropName:string) stdcall;
var a:PBTGUI_Object;
    i,k,n:longint;
    s:string;
begin
   if _GoodObject(WinHand,a) then
   begin
      PropName := #13+UpperCase(PropName)+#13;
      i := Pos(PropName,a.Prop);
      if i <> 0 then
      begin
         k := length(PropName)+ 7; //#13 .... #13 a b c d #13
         n := length(a.Prop);
         SetLength(s,n - k);
         if i <> 1 then Move(a.Prop[1],s[1],i - 1);
         Move(a.Prop[i+k],s[i],(n-(i+k))+1);
         a.Prop := s;
      end;
      a.Lock := 0;
   end;
end;

//------------------------------------------------------------------------------
procedure BGUI_SetWindowText(WinHand :longword; const Txt:string); stdcall;
var a:PBTGUI_Object;
begin
   if _GoodObject(WinHand,a) then
   begin
      a.Txt := txt; // This may be title so do refresh
      BGUI_PostMessage(WinHand,W_REPAINT,0,0); //0.0 = all
      a.Lock := 0;
   end;
end;

//------------------------------------------------------------------------------
function  BGUI_GetWindowText(WinHand :longword):string; stdcall;
var a:PBTGUI_Object;
begin
   if _GoodObject(WinHand,a) then
   begin
      Result := a.Txt;
      a.Lock := 0;
   end;

end;

//------------------------------------------------------------------------------
procedure BGUI_SetWindowData(WinHand :longword; const Txt:string); stdcall;
var a:PBTGUI_Object;
begin
   if _GoodObject(WinHand,a) then
   begin

      a.Lock := 0;
   end;

end;

//------------------------------------------------------------------------------
function  BGUI_GetWindowData(WinHand :longword):string; stdcall;
var a:PBTGUI_Object;
begin
   if _GoodObject(WinHand,a) then
   begin
      Result := a.Txt2;
      a.Lock := 0;
   end;

end;



//------------------------------------------------------------------------------
procedure BGUI_ShowWindowEx(WinHand,mode:longword); stdcall;
var a:PBTGUI_Object;
begin
   if _GoodObject(WinHand,a) then
   begin
      case mode of
         SW_SHOW : begin

         end;
         SW_HIDE : begin

         end;
         SW_MINIMIZE : begin

         end;
         SW_MAXIMIZE : begin

         end;
         SW_RESTORE : begin

         end;
      end;
      a.Lock := 0;
   end;

end;

//------------------------------------------------------------------------------
procedure BGUI_CloseWindow(WinHand:longword); stdcall;
begin
   BGUI_ShowWindowEx(WinHand,SW_HIDE);
end;

//------------------------------------------------------------------------------
procedure BGUI_ShowWindow(WinHand:longword); stdcall;
begin
   BGUI_ShowWindowEx(WinHand,SW_SHOW);
end;

//------------------------------------------------------------------------------
procedure BGUI_HideWindow(WinHand:longword); stdcall;
begin
   CloseWindow(WinHand);
end;

//------------------------------------------------------------------------------
procedure BGUI_MinimizeWindow(WinHand:longword); stdcall;
begin
   BGUI_ShowWindowEx(WinHand,SW_MINIMIZE);
end;

//------------------------------------------------------------------------------
procedure BGUI_MaximizeWindow(WinHand:longword); stdcall;
begin
   BGUI_ShowWindowEx(WinHand,SW_MAXIMIZE);
end;

//------------------------------------------------------------------------------
procedure BGUI_RestoreWindow(WinHand:longword); stdcall;
begin
   BGUI_ShowWindowEx(WinHand,SW_RESTORE);
end;


//------------------------------------------------------------------------------
procedure BGUI_GetWindowSize(WinHand :longword; var Xlng,Ylng:longword); stdcall;
var a:PBTGUI_Object;
begin
   if _GoodObject(WinHand,a) then
   begin
      Xlng := a.Xlng;
      Ylng := a.Ylng;
      a.Lock := 0;
   end;

end;

//------------------------------------------------------------------------------
procedure BGUI_SetWinodwSize(WinHand,Xlng,Ylng:longword); stdcall;
var a:PBTGUI_Object;
begin
   if _GoodObject(WinHand,a) then
   begin
      BGUI_PostMessage(WinHand,W_RESIZEWIN,Xlng,Ylng);
      a.Lock := 0;
   end;
end;

//------------------------------------------------------------------------------
procedure BGUI_AdjustWinowSize(WinHand,WantClientXlng,WantClientYlng:longword); stdcall;
var a:PBTGUI_Object;
begin
   if _GoodObject(WinHand,a) then
   begin

      a.Lock := 0;
   end;

end;

//------------------------------------------------------------------------------
procedure BGUI_GetClientRect(WinHand :longword; var Xpos,Ypos,Xlng,Ylng:longword); stdcall;
var a:PBTGUI_Object;
begin
   if _GoodObject(WinHand,a) then
   begin
      Xpos := a.Xpos;
      Ypos := a.Ypos;
      Xlng := a.Xlng;
      Ylng := a.Ylng;
      a.Lock := 0;
   end;

end;

//------------------------------------------------------------------------------
procedure BGUI_SetWindowPos(WinHand :longword; Xpos,Ypos:longint); stdcall;
var a:PBTGUI_Object;
begin
   if _GoodObject(WinHand,a) then
   begin
      BGUI_PostMessage(WinHand,W_SETPOS,longword(Xpos),longword(Ypos));
      a.Lock := 0;
   end;

end;

//------------------------------------------------------------------------------
procedure BGUI_GetWinodwPos(WinHand :longword; var Xpos,Ypos:longint); stdcall;
var a:PBTGUI_Object;
begin
   if _GoodObject(WinHand,a) then
   begin
      Xpos := a.Xpos;
      Ypos := a.Ypos;
      a.Lock := 0;
   end;

end;

//------------------------------------------------------------------------------
procedure BGUI_SetWindowLong(WinHand,ParId,ParValue:longword); stdcall;
var a:PBTGUI_Object;
begin
   if _GoodObject(WinHand,a) then
   begin

      a.Lock := 0;
   end;

end;

//------------------------------------------------------------------------------
function  BGUI_GetWinodwLong(WinHand,ParId:longword):longword; stdcall;
var a:PBTGUI_Object;
begin
   Result := 0;
   if _GoodObject(WinHand,a) then
   begin

      a.Lock := 0;
   end;

end;

//------------------------------------------------------------------------------
function  BGUI_GetParent(WinHand:longword):longword; stdcall;
var a:PBTGUI_Object;
begin
   Result := 0;
   if _GoodObject(WinHand,a) then
   begin

      a.Lock := 0;
   end;

end;

//------------------------------------------------------------------------------
procedure BGUI_SetParent(WinHand,TheParent:longword); stdcall;
var a:PBTGUI_Object;
begin
   if _GoodObject(WinHand,a) then
   begin

      a.Lock := 0;
   end;

end;

//------------------------------------------------------------------------------
function  BGUI_GetSystemMetrics(WinHand,MetrId:longword):longword; stdcall;
begin
   Result := 0;
end;

//------------------------------------------------------------------------------
procedure BGUI_SetTimer(WinHand,Id,Flags,Milisec:longword); stdcall;
var a:PBTGUI_Object;
begin
   if _GoodObject(WinHand,a) then
   begin

      a.Lock := 0;
   end;

end;

          (*
//------------------------------------------------------------------------------
procedure   BTGUIcore.SetWinEnable(winID:longword; Enable:boolean);
var a:longword;
begin
   a := GetWinLongParm(winID, WCL_FLAGS);
   if Enable then a := a or WCF_ENABLE
             else a := a and ( not WCF_ENABLE);
   SetWinLongParm(winID, WCL_FLAGS, a);
   self.SendMessage(winID,W_REPAINT,0,0);
end;

//------------------------------------------------------------------------------
procedure   BTGUIcore.GetWinEnable(winID:longword; var Enable:boolean);
begin
   if (GetWinLongParm(winID, WCL_FLAGS) and WCF_ENABLE)<>0 then Enable := true
                                                           else Enable := false;
end;

//------------------------------------------------------------------------------
procedure   BTGUIcore.ShowWin(winID:longword);
begin
   SetWinLongParm(winID, WCL_FLAGS, GetWinLongParm(winID, WCL_FLAGS) or WCF_SHOW);
   self.SendMessage(winID,W_REPAINT,0,0);
end;

//------------------------------------------------------------------------------
procedure   BTGUIcore.HideWin(winID:longword);
begin
   SetWinLongParm(winID, WCL_FLAGS, GetWinLongParm(winID, WCL_FLAGS) and (not WCF_SHOW));
   self.SendMessage(winID,W_REPAINT,0,0);
end;

//------------------------------------------------------------------------------
function    BTGUIcore.ScanWindows(winID_root,indx:longword):longword;
var p:PBTGUI_Object;
    i,r:longword;
begin
   // note if winID_root = 0 scan windows
   //                   <> 0 scan root items
   //      if indx = 0 retrun count
   //         index <> 0 return .ID
   i := 0;
   r := 0;
   if winID_root = 0 then p := PBTGUI_Object(WindowsList)
                     else p := PBTGUI_Object(_FindWindowByID(winID_Root)).Items;
   while p <> nil do
   begin
      inc(i);
      if i = indx then begin r := p.ID; break; end;
      p := p.Next;
   end;
   if indx = 0 then Result := i  //count
               else Result := r; //ID
end;

    *)



end.
