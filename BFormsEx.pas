{

   ToDo
   - ImageList
        style
        remove coloroff proprty BackGrouns ??
   - ToolBar
        delete
        resize
        style (flat)
        enable style and other
        add controls combo and other (3 state buttons )
        separator
        text
   - Tab page
        all
   - Tree View
        all
   - UpDown Button
   - RTF  Rich Edit Control


}
unit BFormsEx;
{$APPTYPE GUI }



/// if FPC is not defined DELPHI usage
{$IFDEF FPC }
{$MODE DELPHI }

{*********** CODE GENRATION ****************}
{$DEBUGINFO OFF }
{$ASMMODE INTEL }
{ $ STACKFRAMES OFF } // after version 1.0.10 this is auto
{$GOTO ON }
{$S- } {** stop stack check ** }
{$INLINE ON }
{$MACRO ON }
{$SMARTLINK ON }
{$TYPEINFO ON }

{*********** OUTPUT MESSAGES ***************}
{$HINTS ON }
{$NOTES ON }
{$WARNINGS ON }
{$ENDIF}

interface
uses BForms,BCanvas,
     windows {$IFDEF FPC};{$ELSE},messages;{$ENDIF}

type
      BTProgressBar = class(BTControl)
      private
       aMin         : dword;
       aMax         : dword;
       aPos         : dword;
       aVer         : boolean;
       aSmt         : boolean;
       procedure    SetPBpos(value:dword);
       procedure    SetPBminpos(value:dword);
       procedure    SetPBmaxpos(value:dword);
       procedure    SetPBver(value:boolean);
       procedure    SetPBsmooth(value:boolean);
       procedure    SetPBcolor(value:dword);
       procedure    SetPBbkcolor(value:dword);
       procedure    SetPBstepv(value:dword);
       procedure    RecreateWnd;
      public
       constructor  Create(Par:BTWindow); override;
       destructor   Destroy; override;
       procedure    Step;
       property     Position    :dword read aPos write SetPBpos;
       property     MinPosition :dword read aMin write SetPBminpos;
       property     MaxPosition :dword read aMax write SetPBmaxpos;
       property     Vertical    :boolean read aVer write SetPBver;
       property     Smooth      :boolean read aSmt write SetPBSmooth;
       property     Color       :dword write SetPBcolor;
       property     BkColor     :dword write SetPBbkcolor;
       property     StepValue   :dword write SetPBstepv;
      end;



      BTPaintBox = class(BTControl)
      private
       aFrame : boolean;
       aBpp    : dword;
       aBitMap : BTBitmap;
       function  PaintBoxWndProc(a,m,w,l:dword):dword;
       procedure SetBpp(value:dword);
       procedure SetFrame(value:boolean);
      public
       FrameColor   : dword;
       Canvas       : BTCanvas;
       OnMouse      : BTobjectProc2;
       OnMouseDown  : BTobjectProc4;
       OnMouseUp    : BTobjectProc4;
       constructor  Create(Par:BTWindow); override;
       destructor   Destroy; override;
       property     Bpp : dword read aBpp write SetBpp;
       property     Surface : BTBitMap read aBitMap;
       property     Frame : boolean read aFrame write SetFrame;
      end;



      BTToolTip = class(BTControl)
      private
       procedure    SetTTcolor(value:dword);
       procedure    SetTTbkcolor(value:dword);
      public
       constructor  Create(Par:BTWindow); override;
       destructor   Destroy; override;
       procedure    AddTip(ctl:BTControl; TipText:string);
       procedure    DelTip(ctl:BTControl);
       property     Color       :dword write SetTTcolor;
       property     BkColor     :dword write SetTTbkcolor;
      end;



      BTImageList = class
      private
       aXlng        :dword;
       aYlng        :dword;
       aTransparent :boolean;
       aDrawStyle   :dword;
       aHandle      :dword;
       function     GetCount:dword;
       function     GetColorOff:dword;
       procedure    SetColorOff(value:dword);
       procedure    SetTrans(value:boolean);
      public
       constructor  Create(Xlng,Ylng:dword);
       destructor   Destroy; override;
       procedure    Clear;
       procedure    Delete(indx:dword);
       function     AddIcon(ico:HICON):longint;
       function     AddIconFromFile(name:string):longint;
       function     AddBitmap(bmp_handle, xp,yp, colorOff:dword):longint;
       function     AddBitmapFromFile(name:string;  xp,yp, colorOff:dword):longint;
       function     Load(bmp_handle, colorOff:dword):longint;
       function     LoadFromFile(name:string;  colorOff:dword):longint;
       procedure    Draw(H_DC:dword; X,Y:longint; indx:dword); overload;
       procedure    Draw(can:BTCanvas; X,Y:longint; indx:dword); overload;
       property     Handle : dword  read aHandle;
       property     Count : dword read GetCount;
       property     ColorOff : dword read GetColorOff write SetColorOFF;
       property     Transparent : boolean read aTransparent write setTrans;
       property     Xlng : dword read aXlng;
       property     Ylng : dword read aYlng;
      end;



      BTToolBarItem = class;

      BTToolBar = class(BTControl)
      private
       ItemList     : BTToolBarItem;
       procedure    SetImageList(value:BTImageList);
       function     ToolBarWndProc(a,m,w,l:dword):dword;
       procedure    ToolBarOnClick;
      public
       constructor  Create(Par:BTWindow); override;
       destructor   Destroy; override;
       property     ImageList : BTImageList write SetImageList;
      end;



      BTToolBarItem = class
      private
       aParent : BTToolBar;
       Next    : BTToolBarItem;
      public
       Tip          :string;
       OnClick      :BTObjectProc ;
       constructor  Create(Par:BTToolBar);
       destructor   Destroy; override;
       procedure    Add(Name:string; img_indx:dword);
      end;







implementation


(*  C O M C T L 32

#if (_WIN32_IE >= 0x0300)
typedef struct tagINITCOMMONCONTROLSEX {
    DWORD dwSize;             // size of this structure
    DWORD dwICC;              // flags indicating which classes to be initialized
} INITCOMMONCONTROLSEX, *LPINITCOMMONCONTROLSEX;
#define ICC_LISTVIEW_CLASSES 0x00000001 // listview, header
#define ICC_TREEVIEW_CLASSES 0x00000002 // treeview, tooltips
#define ICC_BAR_CLASSES      0x00000004 // toolbar, statusbar, trackbar, tooltips
#define ICC_TAB_CLASSES      0x00000008 // tab, tooltips
#define ICC_UPDOWN_CLASS     0x00000010 // updown
#define ICC_PROGRESS_CLASS   0x00000020 // progress
#define ICC_HOTKEY_CLASS     0x00000040 // hotkey
#define ICC_ANIMATE_CLASS    0x00000080 // animate
#define ICC_WIN95_CLASSES    0x000000FF
#define ICC_DATE_CLASSES     0x00000100 // month picker, date picker, time picker, updown
#define ICC_USEREX_CLASSES   0x00000200 // comboex
#define ICC_COOL_CLASSES     0x00000400 // rebar (coolbar) control
#if (_WIN32_IE >= 0x0400)
#define ICC_INTERNET_CLASSES 0x00000800
#define ICC_PAGESCROLLER_CLASS 0x00001000   // page scroller
#define ICC_NATIVEFNTCTL_CLASS 0x00002000   // native font control
#endif
WINCOMMCTRLAPI BOOL WINAPI InitCommonControlsEx(LPINITCOMMONCONTROLSEX);
#endif      // _WIN32_IE >= 0x0300

#define ODT_HEADER              100
#define ODT_TAB                 101
#define ODT_LISTVIEW            102

#if (_WIN32_IE >= 0x0300)
#define PBS_SMOOTH              0x01
#define PBS_VERTICAL            0x04
#endif

#define PBM_SETRANGE            (WM_USER+1)
#define PBM_SETPOS              (WM_USER+2)
#define PBM_DELTAPOS            (WM_USER+3)
#define PBM_SETSTEP             (WM_USER+4)
#define PBM_STEPIT              (WM_USER+5)
#if (_WIN32_IE >= 0x0300)
#define PBM_SETRANGE32          (WM_USER+6)  // lParam = high, wParam = low
typedef struct
{
   int iLow;
   int iHigh;
} PBRANGE, *PPBRANGE;
#define PBM_GETRANGE            (WM_USER+7)  // wParam = return (TRUE ? low : high). lParam = PPBRANGE or NULL
#define PBM_GETPOS              (WM_USER+8)
#if (_WIN32_IE >= 0x0400)
#define PBM_SETBARCOLOR         (WM_USER+9)		// lParam = bar color
#endif      // _WIN32_IE >= 0x0400
#define PBM_SETBKCOLOR          CCM_SETBKCOLOR  // lParam = bkColor
#endif      // _WIN32_IE >= 0x0300

#endif  // NOPROGRESS
*)

const  { Progres Bar }
    ICC_PROGRESS_CLASS = $20;
    PBS_SMOOTH    = 1;
    PBS_VERTICAL  = 4;
    PBM_SETRANGE  = WM_USER + 1;
    PBM_SETPOS    = WM_USER + 2;
    PBM_SETBARCOLOR = WM_USER + 9;
    PBM_SETBKCOLOR = $2000 + 1;
    PBM_STEPIT    = WM_USER + 5;
    PBM_SETSTEP   = WM_USER + 4;

    ICC_TAB_CLASSES   = $8 ; // tab, tooltips
    TTS_ALWAYSTIP     = $01;
    TTS_NOPREFIX      = $02;
    TTF_SUBCLASS      = $0010 ;
    TTF_IDISHWND      = $0001 ; // no need of rectange

    TTM_ADDTOOL       = WM_USER + 4; // + 50 for UNICODE;
    TTM_DELTOOL       = WM_USER + 5; // + 51 for UNICODE;
    TTM_SETTIPBKCOLOR   =  WM_USER + 19;
    TTM_SETTIPTEXTCOLOR =  WM_USER + 20;

    //tool bar
    TB_BUTTONSTRUCTSIZE  = WM_USER + 30;
    TB_ADDBUTTONS        = WM_USER + 20; //+68 unicode
    TB_SETIMAGELIST      = WM_USER + 48;


  TBSTATE_CHECKED         = $01;
  TBSTATE_PRESSED         = $02;
  TBSTATE_ENABLED         = $04;
  TBSTATE_HIDDEN          = $08;
  TBSTATE_INDETERMINATE   = $10;
  TBSTATE_WRAP            = $20;
  TBSTATE_ELLIPSES        = $40;
  TBSTATE_MARKED          = $80;

  TBSTYLE_BUTTON          = $00;
  TBSTYLE_SEP             = $01;
  TBSTYLE_CHECK           = $02;
  TBSTYLE_GROUP           = $04;
  TBSTYLE_CHECKGROUP      = TBSTYLE_GROUP or TBSTYLE_CHECK;
  TBSTYLE_DROPDOWN        = $08;
  TBSTYLE_AUTOSIZE        = $0010; // automatically calculate the cx of the button
  TBSTYLE_NOPREFIX        = $0020; // if this button should not have accel prefix

  TBSTYLE_TOOLTIPS        = $0100;
  TBSTYLE_WRAPABLE        = $0200;
  TBSTYLE_ALTDRAG         = $0400;
  TBSTYLE_FLAT            = $0800;
  TBSTYLE_LIST            = $1000;
  TBSTYLE_CUSTOMERASE     = $2000;
  TBSTYLE_REGISTERDROP    = $4000;
  TBSTYLE_TRANSPARENT     = $8000;
  TBSTYLE_EX_DRAWDDARROWS = $00000001;

  TTN_FIRST               = 0-520;
  TTN_NEEDTEXT            = TTN_FIRST - 0;


type

     PToolTipText =^ToolTipText;  // ToolBar tool Tip
     ToolTipText = record
        hdr: TNMHdr;
        lpszText: PAnsiChar;
        szText: array[0..79] of AnsiChar;
        hinst: HINST;
        uFlags: UINT;
        lParam: LPARAM;
     end;


     PINITCOMMONCONTROLSEX = ^TINITCOMMONCONTROLSEX;
     TINITCOMMONCONTROLSEX = record
       dwSize : dword;
       dwICC  : dword;
     end;

     PTTOOLINFO = ^TTOOLINFO;
     TTOOLINFO = record
       cbSize  : dword;
       uFlags  : dword;
       aHWND   : dword;
       uId     : dword;
       aRECT   : RECT;
       hinst   : dword;
       lpszText : pointer;
       alParam  : LPARAM;
     end;

     TBBUTTON = packed record
       iBitmap: Integer;
       idCommand: Integer;
       fsState: Byte;
       fsStyle: Byte;
       bReserved: array[1..2] of Byte;
       dwData: Longint;
       iString: Integer;
     end;



procedure InitCommonControls; stdcall; external 'comctl32.dll';
//function InitCommonControlsEx(var aa:TINITCOMMONCONTROLSEX):boolean; stdcall; external 'comctl32.dll';

function ImageList_Create(CX, CY: Integer; Flags: UINT; Initial, Grow: Integer): dword; stdcall; external 'comctl32.dll';
function ImageList_Destroy(ImageList: dword): Bool; stdcall;  external 'comctl32.dll';
function ImageList_GetImageCount(ImageList: dword): Integer; stdcall;   external 'comctl32.dll';
function ImageList_SetBkColor(ImageList: dword; ClrBk: TColorRef): TColorRef; stdcall;   external 'comctl32.dll';
function ImageList_GetBkColor(ImageList: dword): TColorRef; stdcall;   external 'comctl32.dll';
function ImageList_ReplaceIcon(ImageList: dword; Index: Integer; Icon: HIcon): Integer; stdcall;   external 'comctl32.dll';
function ImageList_Draw(ImageList: dword; Index: Integer; Dest: HDC; X, Y: Integer; Style: UINT): Bool; stdcall;   external 'comctl32.dll';
function ImageList_Remove(ImageList: dword; Index: Integer): Bool; stdcall;   external 'comctl32.dll';
function ImageList_AddMasked(ImageList: dword; Image: HBitmap; Mask: TColorRef): Integer; stdcall;    external 'comctl32.dll';
//function ImageList_Add(ImageList: dword; Image, Mask: HBitmap): Integer; stdcall;    external 'comctl32.dll';




const
  ILC_MASK                = $0001;
  ILC_COLOR               = $0000;
  ILC_COLORDDB            = $00FE;
  ILC_COLOR4              = $0004;
  ILC_COLOR8              = $0008;
  ILC_COLOR16             = $0010;
  ILC_COLOR24             = $0018;
  ILC_COLOR32             = $0020;
  ILC_PALETTE             = $0800;

  ILD_NORMAL              = $0000;
  ILD_TRANSPARENT         = $0001;
  ILD_MASK                = $0010;
  ILD_IMAGE               = $0020;
  ILD_ROP                 = $0040;
  ILD_BLEND25             = $0002;
  ILD_BLEND50             = $0004;
  ILD_OVERLAYMASK         = $0F00;





{******************************************************************************}

constructor BTProgressBar.Create(par:BTWindow);
begin
  inherited;
  aSmt := false;
  aVer := false;
  ClassName := 'msctls_progress32';
  ClassType := 1;
  SUBClass  := 0;
  aMin := 0;
  aMax := 100;
  aPos := 0;
  RecreateWnd;
end;

Destructor BTProgressBar.Destroy;
begin
  inherited;
end;

procedure  BTProgressBar.RecreateWnd;
begin
   if Handle <> 0 then
   begin
      SendMessage(Handle,WM_Close,0,0);
      //windows.DestroyWindow(aHandle);
   end;
   GetHandle;
   SendMessage( Handle, PBM_SETRANGE , 0, ((aMax and $FFFF) shl 16) or (aMin and $FFFF) );
   SetPBpos(aPos);
end;

procedure  BTProgressBar.Step;
begin
   SendMessage( Handle, PBM_STEPIT , 0, 0 );
end;

procedure  BTProgressBar.SetPBpos(value:dword);
begin
   aPos := value;
   SendMessage( Handle, PBM_SETPOS , aPos, 0 );
end;

procedure  BTProgressBar.SetPBminpos(value:dword);
begin
   aMin := Value;
   SendMessage( Handle, PBM_SETRANGE , 0, ((aMax and $FFFF) shl 16) or (aMin and $FFFF) );
end;

procedure  BTProgressBar.SetPBmaxpos(value:dword);
begin
   aMax := Value;
   SendMessage( Handle, PBM_SETRANGE , 0, ((aMax and $FFFF) shl 16) or (aMin and $FFFF) );
end;

procedure  BTProgressBar.SetPBstepv(value:dword);
begin
   SendMessage( Handle, PBM_SETSTEP , value, value );
end;

procedure  BTProgressBar.SetPBsmooth(value:boolean);
var mor : dword;
begin
   aSmt := value;
   mor := 0;
   if aSmt then mor := PBS_SMOOTH;
   SubClass := SubClass and (not dword( PBS_SMOOTH )) or mor;
   RecreateWnd;
end;

procedure  BTProgressBar.SetPBver(value:boolean);
var mor : dword;
begin
   aVer := value;
   mor := 0;
   if aVer then mor := PBS_VERTICAL;
   SubClass := SubClass and (not dword( PBS_VERTICAL )) or mor;
   RecreateWnd;
end;

procedure  BTProgressBar.SetPBcolor(value:dword);
begin
   SendMessage( Handle, PBM_SETBARCOLOR , 0, value );
end;

procedure  BTProgressBar.SetPBbkcolor(value:dword);
begin
   SendMessage( Handle, PBM_SETBKCOLOR, 0, value );
end;





{******************************************************************************}

constructor  BTPaintBox.Create(Par:BTWindow);
begin
   inherited;
   OnMouse     := nil;
   OnMouseDown := nil;
   OnMouseUp   := nil;

   FrameColor := 0;
   aFrame := false;
   aBitMap := BTBitmap.Create;
   aBpp := 24; // to be competible with 98
   aBitmap.Init(1,1,24,nil);
   Canvas := aBitmap.Canvas;
   ClassName := 'button'; //'static';
   ClassType := 1;
   SUBClass  := BS_OWNERDRAW; //SS_LEFT;
   OnOther := PaintBoxWndProc;
   GetHandle;
end;

destructor   BTPaintBox.Destroy;
begin
   aBitMap.Free;
   inherited;
end;

function     BTPaintBox.PaintBoxWndProc(a,m,w,l:dword):dword;
var res:dword;
    pdc:dword;
    ps:PAINTSTRUCT;
    x,y,mb:dword;
    pen:HPEN;
begin
   res := 0;
   case m of
      WM_ERASEBKGND: res := 1;
      WM_PAINT: begin
         pdc := BeginPaint(a,ps);
         x := aBitMap.Xlng + 1;
         y := aBitMap.Ylng + 1;
         if aFrame then
         begin
            pen := createPen(ps_SOLID,0,FrameColor);
            SelectObject(pdc,pen);
            windows.movetoex(pdc,0,0,nil);
            windows.LineTo(pdc,x,0);
            windows.LineTo(pdc,x,y);
            windows.LineTo(pdc,0,y);
            windows.LineTo(pdc,0,0);
            BitBlt(pdc,1,1,aBitMap.Xlng,aBitMap.Ylng,aBitMap.GetDC,0,0,SRCCOPY);
            aBitMap.ReleaseDC;
            DeleteObject(pen);
         end else begin
            BitBlt(pdc,0,0,aBitMap.Xlng,aBitMap.Ylng,aBitMap.GetDC,0,0,SRCCOPY);
            aBitMap.ReleaseDC;
         end;
         EndPaint(a,ps);
      end;
      WM_SIZE: begin
         x := dword(l and $FFFF);
         y := dword(l shr 16);
         if aFrame then
         begin
           dec(x,2);
           dec(y,2);
         end;
         aBitMap.Xlng := x;
         aBitMap.Ylng := y;
      end;
      WM_MOUSEMOVE:   begin
         if Assigned(OnMouse) then
            OnMouse(dword(l and $FFFF), dword(l shr 16));
      end;
      WM_RBUTTONDOWN,
      WM_LBUTTONDOWN: begin
         mb := 0;
         if (M and WM_LBUTTONDOWN) > 0 then mb := mb or 1;
         if (M and WM_RBUTTONDOWN) > 0 then mb := mb or 2;
         if Assigned(OnMouseDown) then
            OnMouseDown(dword(l and $FFFF),dword(l shr 16), mb, KBDstatus);
      end;
      WM_RBUTTONUP,
      WM_LBUTTONUP:  begin
         mb := 0;
         if (M and WM_LBUTTONDOWN) > 0 then mb := mb or 1;
         if (M and WM_RBUTTONDOWN) > 0 then mb := mb or 2;
         if Assigned(OnMouseUp) then
            OnMouseUp(dword(l and $FFFF),dword(l shr 16), mb, KBDstatus);
      end;
   end;
   PaintBoxWndProc := res;
end;

procedure    BTPaintBox.SetBpp(value:dword);
begin
   aBpp := value;
   aBitMap.Bpp := value;
end;

procedure    BTPaintBox.SetFrame(value:boolean);
var x,y:dword;
begin
   if aFrame = value then Exit;
   aFrame := value;
   x := aBitMap.Xlng;
   y := aBitmap.Ylng;
   if aFrame then
   begin
     dec(x,2);  dec(y,2);
   end else begin
     inc(x,2);  inc(y,2);
   end;
   aBitMap.Xlng := x;
   aBitmap.Ylng := y;
end;




{******************************************************************************}

constructor BTToolTip.Create(par:BTWindow);
begin
  inherited;
  ClassName := 'tooltips_class32';
  ClassType := $80000000 or $40000000; // force anly SUBclass use and ID skip
  SUBClass  := TTS_ALWAYSTIP or TTS_NOPREFIX or ws_POPUP;

  GetHandle;
end;

destructor BTToolTip.Destroy;
begin
  inherited;
end;

procedure  BTToolTip.AddTip(ctl:BTControl; TipText:string);
var ti :TTOOLINFO;
    aTipText     :string;
begin
   aTipText := TipText + #0;
      ti.cbSize   := sizeof ( TTOOLINFO ) ;
      ti.hinst    := GetModuleHandle(nil) ;
      ti.ahwnd    := ctl.handle;
      ti.uId      := ctl.handle; //ID;  ignore  by TTF_IDISHWND
      ti.lpszText := @aTipText[1];
  //    ti.arect    := rc ; ignore
      ti.uFlags   := TTF_SUBCLASS or TTF_IDISHWND;  // tool tip control handles own messages
      ti.alParam  := 0;
   // Registers a tool with a ToolTip control.
   SendMessage( handle, TTM_ADDTOOL, 0, dword(@ti));
end;

procedure  BTToolTip.SetTTcolor(value:dword);
begin
   SendMessage( Handle, TTM_SETTIPTEXTCOLOR , value, 0 );
end;

procedure  BTToolTip.SetTTbkcolor(value:dword);
begin
   SendMessage( Handle, TTM_SETTIPBKCOLOR ,  value, 0 );
end;

procedure  BTToolTip.DelTip(ctl:BTControl);
var ti :TTOOLINFO;
begin
      ti.cbSize   := sizeof ( TTOOLINFO ) ;
      ti.hinst    := GetModuleHandle(nil) ;
      ti.ahwnd    := ctl.handle;
      ti.uId      := ctl.handle; //ID;  ignore  by TTF_IDISHWND
      ti.uFlags   := TTF_SUBCLASS or TTF_IDISHWND;  // tool tip control handles own messages
      ti.lpszText := nil;
  //    ti.arect    := rc ; ignore
      ti.alParam  := 0;
   SendMessage( handle, TTM_DELTOOL, 0, dword(@ti));

end;


{******************************************************************************}

constructor  BTImageList.Create(Xlng,Ylng:dword);
begin
   aXlng := Xlng;
   aYlng := Ylng;
   aTRansparent := true;
   aDrawStyle := ILD_TRANSPARENT;
   aHandle := ImageList_Create(Xlng,Ylng,ILC_MASK or ILC_COLOR24,1,1);
end;

destructor   BTImageList.Destroy;
begin
   ImageList_Destroy(aHandle);
   inherited;
end;

function    BTImageList.GetCount:dword;
begin
   GetCount := ImageList_GetImageCount(aHandle);
end;

function    BTImageList.GetColorOff:dword;
begin
   GetColorOff := ImageList_GetBkColor(aHandle);
end;

procedure   BTImageList.SetColorOff(value:dword);
begin
   ImageList_SetBkColor(aHandle, value);
end;

procedure   BTImageList.Clear;
begin
  ImageList_Remove(aHandle, -1);
end;

procedure   BTImageList.Delete(indx:dword);
begin
   ImageList_Remove(aHandle,indx);
end;

procedure   BTImageList.Draw(H_DC:dword; X,Y:longint; indx:dword);
begin
   ImageList_Draw(aHandle, indx, H_DC, X, Y, aDrawStyle);
end;

procedure   BTImageList.Draw(can:BTCanvas; X,Y:longint; indx:dword);
begin
   if assigned(can) then ImageList_Draw(aHandle, indx, can.Handle, X, Y, aDrawStyle);
end;

procedure   BTImageList.SetTrans(value:boolean);
begin
   aTransparent := value;
   aDrawStyle := aDrawStyle and ( not ( ILD_TRANSPARENT or ILD_NORMAL));
   if value then aDrawStyle := aDrawStyle or ILD_TRANSPARENT
            else aDrawStyle := aDrawStyle or ILD_NORMAL;
end;

function     BTImageList.AddIcon(ico:HICON):longint;
begin
   AddIcon := ImageList_ReplaceIcon(aHandle, -1, ico);
end;


function     BTImageList.AddIconFromFile(name:string):longint;
var d:dword;
    res:Longint;
begin
   res := -1;
   d := LoadImage(hInstance,Pchar(Name),IMAGE_ICON,0,0,LR_DEFAULTSIZE or LR_CREATEDIBSECTION);
   if d = 0 then d := LoadImage(0,Pchar(Name),IMAGE_ICON,0,0,LR_DEFAULTSIZE or LR_LOADFROMFILE or LR_CREATEDIBSECTION);
   if d <> 0 then
   begin
      res := AddIcon(HICON(d));
      DeleteObject(d);
   end;
   AddIconFromFile := res;
end;


function     BTImageList.Load(bmp_handle, colorOff:dword):longint;
begin
   Load := ImageList_AddMasked(aHandle, bmp_handle, ColorOff);
end;


function     BTImageList.LoadFromFile(name:string; colorOff:dword):longint;
var d:dword;
    res:Longint;
begin
   res := -1;
   d := LoadImage(hInstance,Pchar(name),IMAGE_BITMAP,0,0,LR_DEFAULTSIZE or LR_CREATEDIBSECTION);
   if d = 0 then d := LoadImage(0,Pchar(name),IMAGE_BITMAP,0,0,LR_DEFAULTSIZE or LR_LOADFROMFILE or LR_CREATEDIBSECTION);
   if d <> 0 then
   begin
      res := Load(d, ColorOff);
      DeleteObject(d);
   end;
   LoadFromFile := res;
end;


function     BTImageList.AddBitmap(bmp_handle, xp,yp, colorOff:dword):longint;
var dc,dcddb,sdc:dword;
    res:longint;
    ddb:HBITMAP;

begin
   res := -1;
   if bmp_handle <> 0 then
   begin
         sdc := GetDC(0); // screen dc to create DDB

         dc := CreateCompatibleDC(0);  // Source
         SelectObject(dc,bmp_handle);

         dcddb := CreateCompatibleDC(0);  // Destination Place DDB
         ddb := CreateCompatibleBitmap(sdc, aXlng, aYlng);
         SelectObject(dcddb,ddb);

         BitBlt(dcddb,0,0,aXlng,aYlng,dc,xp,yp,SRCCopy);
         DeleteDc(dcddb);
         DeleteDc(dc);
         ReleaseDC(0,sdc);

         res := ImageList_AddMasked(aHandle, ddb, ColorOff);

         DeleteObject(ddb);
   end;
   AddBitmap := res;
end;

function     BTImageList.AddBitmapFromFile(name:string;  xp,yp, colorOff:dword):longint;
var res:longint;
    d:dword;
begin
   res := -1;
   d := LoadImage(hInstance,Pchar(name),IMAGE_BITMAP,0,0,LR_DEFAULTSIZE or LR_CREATEDIBSECTION);
   if d = 0 then d := LoadImage(0,Pchar(name),IMAGE_BITMAP,0,0,LR_DEFAULTSIZE or LR_LOADFROMFILE or LR_CREATEDIBSECTION);
   if d <> 0 then
   begin
      res := AddBitmap(d,xp,yp,colorOff);
      DeleteObject(d);
   end;
   AddBitmapFromFile := res;
end;




{******************************************************************************}

constructor  BTToolBar.Create(Par:BTWindow);
begin
  inherited;
  ItemList:= nil;
  ClassName := 'ToolbarWindow32';
  ClassType := 1;
  SUBClass  := TBSTYLE_TOOLTIPS or   TBSTYLE_CUSTOMERASE ;
  GetHandle;
  SendMessage(Handle, TB_BUTTONSTRUCTSIZE, sizeof(TBBUTTON), 0);
  OnOther := ToolBarWndProc;
  OnClick := ToolBarOnClick;
end;


{ WARNING   do not FREE ToolBar before ITEMS !!!!!!!!! :( }

destructor   BTToolBar.Destroy;
begin
   // if ItemList is not empty del all from list
   ItemList := nil;
   inherited;
end;


procedure    BTToolBar.ToolBarOnClick;
var I:BTToolBar;
    C,D:BTToolBarItem;
    dd:dword;
begin
   I := BTToolBar(GetProp(CurMessage.LParam,'xctl'));
   if assigned(I) then
   begin
      dd := CurMessage.WParam shr 16 ; { Hi order wird notification }
      if dd = BN_CLICKED then
      begin
         dd := CurMessage.WParam and $FFFF;
         D := nil;
         C := I.ItemList;
         while C <> nil do
         begin
            if (dword(C) and $FFFF) = dd then begin D:=C; break; end;
            C := C.Next;
         end;
         if D <> nil then if Assigned(D.OnClick) then D.OnClick;
      end;
   end;
end;

function     BTToolBar.ToolBarWndProc(a,m,w,l:dword):dword;
var res:dword;
    p : PChar;
    pnmh : PNMHdr;
    pttt : PToolTipText;
    tbi : BTToolBarItem;
begin
   res := 0;
   case m of
     WM_NOTIFY :
     begin
        pnmh := PNMHdr(l);
        if pnmh^.code = TTN_NeedText then
        begin
           pttt := PToolTipText(l);
           tbi := BTToolBarItem(pttt^.hdr.idFrom);
           p := pchar(tbi.Tip);
           pttt^.lpszText:=p;
        end;
     end;
   end;
   ToolBarWndProc := res;
end;

procedure    BTToolBar.SetImageList(value:BTImageList);
begin
  SendMessage(Handle, TB_SETIMAGELIST,0,value.Handle);
end;

{******************************************************************************}

constructor  BTToolBarItem.Create(Par:BTToolBar);
begin
   Tip := '';
   aParent := Par;
   OnClick := nil;
   Next := nil;
end;

destructor   BTToolBarItem.Destroy;
var  C : BTToolBarItem;
begin
   // Unlink from parent list
   if assigned(aParent) then
   begin
      C := aParent.ItemList;
      if C = Self then
      begin
         aParent.ItemList := C.Next;
      end else begin
         while (C.Next <> self) do C := C.Next;
         if assigned(C) then C.Next := self.Next;
      end;
   end;
   inherited;
end;

procedure    BTToolBarItem.Add(Name:string; img_indx:dword);
var  tb : TBBUTTON;
     C : BTToolBarItem;
begin
   // Link in parent list
   C := aParent.ItemList;
   if C = nil then
   begin
     aParent.ItemList := self;
   end else begin
     while (C.Next <> nil) do C := C.Next;
     C.Next := self;
   end;

   Name := Name + #0;
   tb.iBitmap   := img_indx; //iBitmap ;         // standard bitmap index value
   tb.idCommand := dword(self);       // identifier
   tb.fsState   := TBSTATE_ENABLED ; // the button accepts user input
   tb.fsStyle   := TBSTYLE_BUTTON; // standard button
   tb.dwData    := 0;                // application-defined value
   tb.iString   := dword(@Name[1]) ;      // button text
   SendMessage(aParent.Handle, TB_ADDBUTTONS, 1, dword(@tb) );
end;



begin
  InitCommonControls;
end.
