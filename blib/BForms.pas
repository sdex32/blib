{///////////////////////////////////////////////////////////////////////////////

!!!!!! on paint canvas kill parent use handle  then restore 
TODO :(
    objects
        Menu
        OwnButton
        BTImage

     add DefaultHeight to EditBox ListBox ComboBox   1 row size
     !!! Preserve left right up down arrow keys for edit control


     Edit Box border AND events   ??/
     ClassType ??

     ?? UpdateWIndows update other controls ?????


     on Mouse move  in control wndproc 
     3dframe of controls ?? :(
     MDI ???

     BigParent da se mahne

    Forms Open Parented inside  
    Flat did not work corect !!!!!!!!!!

    ComboBOx flashing ???? something with transparent :(
    on create control if parent is control ????

    obidinenie na MW_PAINT i WM_ERASEBK

    MDI ??? dali raboti
    MDI (podredba na prozorcite tile,cascade ..)

    ScrollWindowEx() function
    BringWindowToTop() function

    attach picture resize


    only one default
    default by focus
    aCTRL w=in BTWindow da se mahne  MOJE I OSTANE
    tab focus control set on active


    RegionWindow

  project start on 15.03.2004
  last touch       19.03.2005
///////////////////////////////////////////////////////////////////////////////}

(*
    -----===  S I M P L E   E X A M P L E  ===-----


(Project1.dpr or pas  source code . . . . . . . . . . . .)
uses BForms,Unit1;

begin
  BApplication.CreateForm(TForm1, Form1);
  BApplication.Run;
end.

(The Unit1.pas source code . . . . . . . . . . . . . . . .)
unit Unit1;

interface

uses
  BForms,BCanvas,windows;

type
  TForm1 = class(BTForm)
  private
    { Private declarations }
  public
    btn:BTButton;
    Constructor Create(Par:BTWindow); override;
    Destructor Destroy; override;
    Procedure  OnBtnClick;
  end;

var
  Form1: TForm1;

implementation

Constructor TForm1.Create;
begin
   inherited;  { in the begining of the constructor }
   GetHandle(nil);
   Load(10,10,500,300,'Hello');
   btn := BtButton.Create(self);
   btn.Load(10,10,50,24,'Button 1');
   btn.OnClick := OnBtnClick;
end;

Destructor TForm1.Destroy;
begin
   btn.Free;
   inherited;  {in the end of the destructor }
end;

Procedure  TForm1.OnBtnClick;
begin
   messagebox(0,'CLICK!!!!','From button',mb_ok);
end;





 *)




unit BForms;
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
uses BCanvas,
     windows {$IFDEF FPC};{$ELSE},messages,shellapi;{$ENDIF}


Type
{$IFNDEF FPC}
      RECT = TRECT; // for DELPHI
{$ENDIF}

      BTBorderIcons = set of (biSys,biMax,biMin);
      BTBorder = (bsSizeable,bsNone,bsSingle,bsDialog,bsToolWindow,bsSizeToolWin);
      BTMode = (emNormal,emNumber,emLoCase,emUpCase,emPassword);
      BTWindowState = (wsNormal,wsMinimized,wsMaximized);
      BTPresetCursor = (pcNone,pcArrow,pcHand,pcWait,pcCross,pcIBeam,pcMove);
      BTPresetIcon = (piNone,piApp,piError,piWarning,piQuestion,piAsterisk);
      BTScrollBarDirection = (sbdVertical, sbdHorizontal);
      BTTextAlignment = (taLeft, taCenter, taRight);
      BTAnchors = set of (waLeft,waTop,waRight,waBottom);
      BTAlign = (alNone,alLeft,alTop,alRight,alBottom,alCLient);

      BTForm = class;



      BTCursor = class
      private
        hAndMaskBitmap,hXorMaskBitmap:HBITMAP;
        aVisible : boolean;
        aHandle : dword;
        aPreset : BTPresetCursor;
        procedure CsetHandle(value:dword);
        procedure CsetPreset(value:BTPresetCursor);
      public
        Parent : dword;
        property Handle : dword read aHandle write CSetHandle;
        property Preset : BTPresetCursor read aPreset write CSetPreset;
        constructor Create;
        destructor  Destroy; override;
        procedure   LoadFromFile(name:string);
        procedure   SetFromBitmap(bmp:BTBitmap; xHotSpot,yHotSpot:longint);
        procedure   SetFromBitmapFile(name:string; ColorOff:dword; xHotSpot,yHotSpot:longint);        
      end;


      BTIcon = class
      private
        aHandle : dword;
        aPreset : BTPresetIcon;
        procedure CsetHandle(value:dword);
        procedure CsetPreset(value:BTPresetIcon);
      public
        Parent : dword;
        property  Handle : dword read aHandle write CSetHandle;
        property  Preset : BTPresetIcon read aPreset write CSetPreset;
        constructor Create;
        destructor  Destroy; override;
        procedure   LoadFromFile(name:string);
        procedure   Shell32Preset(value:dword; name:pchar);
      end;


      BTObjectProc  = procedure of object;
      BTObjectProc1 = procedure(a:dword) of object;
      BTObjectProc2 = procedure(a,b:dword) of object;
      BTObjectProc3 = procedure(a,b,c:dword) of object;
      BTObjectProc4 = procedure(a,b,c,d:dword) of object;
      BTObjectFunction = function(a,b,c,d:dword):dword of object;




      BTSubMenu = class
      private
        aHandle :dword;
        aItems  :dword;
      public
        property    Handle : dword read aHandle write aHandle;
        constructor Create;
        destructor  Destroy; override;
        function    AddItem(name:string):dword;
//        procedure   AddSeparator;
//        procedure   SetItemOnClick(id:dword; p:Pointer);
//        function    GetItemEnabled(id:dword):boolean;
//        procedure   SetItemEnabled(id:dword; En:boolean);
//        function    GetItemChecked(id:dword):boolean;
//        procedure   SetItemChecked(id:dword; Ch:boolean);
//        function    GetItemVisible(id:dword):boolean;
//        procedure   SetItemVisible(id:dword; Vi:boolean);
//        function    GetItemText(id:dword):string;
//        procedure   SetItemText(id:dword; Tx:string);
//        procedure   SetItemPicture(id:dword; Pic:dword);
      end;

      BTMenuItem = class
      private
         aCaption    : string;
         aHandle     : dword;
         aEnabled    : Boolean;
         aChecked    : Boolean;
         aVisible    : Boolean;


//
//         aDefault    : Boolean;
//         aRadioItem  : Boolean;
//         aGroupIndex : Byte;
//         aBreak      : TMenuBreak;
//         aCommand    : Word;
//         aHelpContext: Integer;
//         aHint       : string;
//         aItems      : TList;
//         aShortCut   : TShortCut;
//         aParent     : TWOLMenuItem;

//        procedure SetCaption(value:string);
//        procedure SetEnabled(value:boolean);
      public
//        property    Caption : String read aCaption write setCaption;
//        property    Enabled : boolean read aEnabled write setEnabled;
        constructor Create;
        destructor  Destroy; override;

      end;

      BTMenu = class
      private
        aHandle :dword;
        aItems  :dword;
      public
        property    Handle : dword read aHandle write aHandle;
        constructor Create;
        destructor  Destroy; override;
        procedure   AddItem(name:string);
        procedure   AddSubMenu(sname:string; smenu:BTSubMenu);
      end;


      BTWindow = class
      private
        aAlign     : BTAlign;
        aAnchors   : BTAnchors;
        aClientXlng : longint;
        aClientYlng : longint;
        aBrush    : BTBrush;
        aPen      : BTPen;
        aCTRL     : boolean;
        awdc      : dword;
        aParent   : BTForm;
//        aPhandle  : dword;
        aHandle   : dword;
        aCaption  : string;
        aXpos     : longint;
        aYpos     : longint;
        aXlng     : longint;
        aYlng     : longint;
        aVisible  : boolean;
        aEnabled  : boolean;
        aBorder   : BTBorder;
        aFlat     : boolean;
        function  GetXpos:longint;
        function  GetYpos:longint;
        function  GetXlng:longint;
        function  GetYlng:longint;
        procedure SetXpos(value:longint);
        procedure SetYpos(value:longint);
        procedure SetXlng(value:longint);
        procedure SetYlng(value:longint);
        procedure SetVisible(value:boolean);
        procedure SetEnabled(value:boolean);
        procedure SetCaption(value:string);
        procedure SetHandle(value:dword);
        procedure SetBkColor(value:dword);
        procedure SetColor(value:dword);
        procedure SetBorder(value:BTBorder);
        procedure SetClientXlng(value:dword);
        procedure SetClientYlng(value:dword);
        function  GetClientXlng:dword;
        function  GetClientYlng:dword;
        procedure SetFlat(value:boolean);
        procedure SetAlign(value:BTAlign);
        procedure SetAnchors(value:BTAnchors);
        procedure WinFontChange(a:BTFont);
      public
        OnOther             : BTObjectFunction;      
        ClassType           : dword;
        OnPaint             : BTobjectProc3;
        NextChild           : BTWindow;
        Childs              : BTWindow;
        Cursor              : BTCursor;
        Icon                : BTIcon;
        Font                : BTFont;
        Canvas              : BTcanvas;
        Tab                 : dword; { Tab order }

        property  Align     : BTAlign   read aAlign write SetAlign;
        property  Anchors   : BTAnchors read aAnchors write SetAnchors;

        property  BkColor   : dword     write SetBkColor;
        property  Color     : dword     write SetColor;
        property  Control   : boolean   read aCTRL write aCTRL;
        property  Handle    : dword     read aHandle write SetHandle;
        property  Parent    : BTForm    read aParent write aParent;
        property  Xpos      : longint   read GetXpos write SetXpos;
        property  Ypos      : longint   read GetYpos write SetYpos;
        property  Xlng      : longint   read GetXlng write SetXlng;
        property  Ylng      : longint   read GetYlng write SetYlng;
        property  Border    : BTborder   read aBorder write SetBorder;
        property  ClientXlng: dword     read GetClientXlng write SetClientXlng;
        property  ClientYlng: dword     read GetClientYlng write SetClientYlng;

        property  Visible   : boolean   read aVisible write SetVisible;
        property  Enabled   : boolean   read aEnabled write SetEnabled;
        property  Caption   : string    read aCaption write SetCaption;
        property  Flat      : boolean   read aFlat write SetFlat;  // 3d

        constructor Create(Par:BTWindow); virtual;
        destructor  Destroy; override;
        procedure   Show;
        procedure   Hide;
        Procedure   Resize(nXlng,nYlng:longint);
        Procedure   SetPosition(nXpos,nYpos:longint);
        procedure   Load(Xp,Yp,Xl,Yl: dword; Cap:string);
        procedure   UpdateWindow;
        procedure   SetFocus;
        procedure   SetStyle(EX,AndMask,OrMask:dword);
        procedure   Redraw(xdc:dword; Xpos,Ypos,Xlng,Ylng:longint; dmode:dword);
        procedure   SetWinClipping(ChildClip,SubClip:Boolean);
        procedure   BringToFront;
        procedure   BringToBack;        
      end;


      BTControl = class(BTWindow)
      private
         Xcor        : longint;
         Ycor        : longint;
         BigParent   : BTForm;
         aTransparent: boolean;
//         NextControl : BTControl;
         DefByFocus  : dword;
         procedure    SetTransparent(Value:boolean);
      public
         ClassName   : string;
         SubClass    : dword;
         ID          : dword;
         OnClick     : BTobjectProc;
         constructor Create(Par:BTWindow); override;
         destructor  Destroy; override;
         procedure   GetHandle;
      end;


      BTButton = class(BTControl)
      private
       aDefault : boolean;
       procedure SetDefault(value:boolean);
      public
       property    Default : boolean read aDefault write SetDefault;
       constructor Create(Par:BTWindow); override;
       destructor  Destroy; override;
      end;


      BTLabel = class(BTControl)
      private
       aAlignment  :BTTextAlignment;
       procedure    SetAlignment(value:BTTextAlignment);
      public
       constructor  Create(Par:BTWindow); override;
       destructor   Destroy; override;
       property     Alignment   :BTTextAlignment read aAlignment write SetAlignment;
       property     Transparent :boolean read aTransparent write SetTransparent;
      end;


      BTCheckBox = class(BTControl)
      private
       procedure    setCBstate(value:boolean);
       function     getCBstate:boolean;
      public
       property     Checked :boolean read getCBstate write setCBstate;
       constructor  Create(Par:BTWindow); override;
       destructor   Destroy; override;
       property     Transparent :boolean read aTransparent write SetTransparent;
      end;


      BTRadioButton = class(BTControl)
      private
       procedure    setCBstate(value:boolean);
       function     getCBstate:boolean;
      public
       property     Checked :boolean read getCBstate write setCBstate;
       constructor  Create(Par:BTWindow); override;
       destructor   Destroy; override;
       property     Transparent :boolean read aTransparent write SetTransparent;
      end;


      BTGroupBox = class(BTControl)
      private
      public
       constructor  Create(Par:BTWindow); override;
       destructor   Destroy; override;
      end;


      BTComboBox = class(BTControl)
      private
       aSorted :Boolean;
       aEdit :Boolean;
       aVScroll : boolean;
       aHScroll : boolean;
       procedure SetSorted(value:boolean);
       procedure SetCanEdit(value:boolean);
       procedure Set_VSC(value:boolean);
       procedure Set_HSC(value:boolean);
       function  GetCount: dword;
       procedure SetSelect(I:dword);
       function  GetSelect:dword;
      public
       OnChange     : BTobjectProc;
       constructor  Create(Par:BTWindow); override;
       destructor   Destroy; override;
       function     Add(S: string): Integer;
       procedure    Clear;
       procedure    Delete(Index: Integer);
       procedure    Insert(Index: Integer; S: string);
       procedure    Put(Index: Integer; S: string);
       function     Get(Index: Integer): string;
       property     AllowEdit : boolean read aEdit write SetCanEdit;
       property     Sorted : boolean read aSorted write SetSorted;
       property     VScroll : boolean read aVScroll write Set_VSC;
       property     HScroll : boolean read aHScroll write Set_HSC;
       property     Count : dword read GetCount;
       property     Items[i:longint]:string read Get write Put;
       property     Select:dword read GetSelect write SetSelect;
      end;


      BTEditBox = class(BTControl)
      private
       aMultiLine   :boolean;
       aEditMode    :BTEditMode;
       aAlignment   :BTTextAlignment;
       procedure    SetMulLine(value:boolean);
       procedure    RecreateWnd;
       procedure    SetEditMode(value:BTEditMode);
       procedure    SetAlignment(value:BTTextAlignment);
      public
       OnChange     : BTobjectProc;
       OnEnter      : BTobjectProc;
       PassWordChar :char;
       constructor  Create(Par:BTWindow); override;
       destructor   Destroy; override;
       property     MultiLine : boolean read aMultiLine write SetMulLine;
       property     EditMode : BTEditMode read aEditMode write SetEditMode;
       property     Alignment :BTTextAlignment read aAlignment write SetAlignment;
      end;



      BTListBox = class(BTControl)
      private
      public
       constructor  Create(Par:BTWindow); override;
       destructor   Destroy; override;
       function     Add(S: string): Integer;       
      end;


      BTScrollBar = class(BTControl)
      private
       aVisible    :boolean;
       aAttached   :boolean;
       aAtcHandle  :dword;
       aAuto       :boolean;
       aDir        :BTScrollBarDirection;
       aMin        :dword;
       aMax        :dword;
       aPos        :dword;
       procedure   SetSBpos(value:dword);
       procedure   SetSBminpos(value:dword);
       procedure   SetSBmaxpos(value:dword);
       procedure   SetDirection(value:BTScrollBarDirection);
       procedure   SetVisible(value:boolean);
      public
       OnLineUp    :BTObjectProc ;
       OnLineDown  :BTObjectProc ;
       OnPageUp    :BTObjectProc ;
       OnPageDown  :BTObjectProc ;
       OnMovePos   :BTObjectProc1 ;
       OnChange    :BTObjectProc1 ;
//       property    OnClick     :pointer write SetOnClick;
       property    Position    :dword read aPos write SetSBpos;
       property    MinPosition :dword read aMin write SetSBminpos;
       property    MaxPosition :dword read aMax write SetSBmaxpos;
       property    Direction   :BTScrollBarDirection read aDir write SetDirection;
       property    AutoMode    :boolean read aAuto write aAuto;
       property    Attached    :boolean read aAttached;
       property    Visible     :boolean read aVisible write SetVisible;
       constructor Create(Par:BTWindow); override;
       destructor  Destroy; override;
       procedure   AttachToWindow(wHandle:dword; scdir:BTScrollBarDirection);
      end;



      BTTimer = class
      private
       aName        : string;
       aID          : dword;
       aFormHandle  : dword;
       aHandle      : dword;
       aTime        : dword;
       procedure    SetInterval(value:dword);
      public
       OnTimer      : BTobjectProc;
       Enabled      : Boolean;
       property     Handle : dword read aHandle;
       property     Time : dword read aTime write SetInterval; { in 1/1000 Sec}
       constructor  Create(Par:BTWindow);
       destructor   Destroy; override;
       procedure    StartTimer;
       procedure    StopTimer;
      end;


      BTForm = class(BTWindow )
      private
       aBicons      : BTBorderIcons;
       aWstate      : BTWindowState;
       aBitmap      : BTBitmap;
       aBitMapMode  : dword;

       procedure    SetBorderIcons(value:BTBorderIcons);
       procedure    SetWindowState(value:BTWindowState);
       procedure    SetNewMenu(value:BTMenu);
      public

      // Events
       OnKey        : BTObjectProc3;
       OnMouse      : BTobjectProc2;
       OnMouseDown  : BTobjectProc4;
       OnMouseUp    : BTobjectProc4;
       OnClick      : BTobjectProc3;
       OnDBLClick   : BTobjectProc3;
       OnActivate   : BTobjectProc;
       OnDeactivate : BTobjectProc;
       OnCreate     : BTobjectProc;
       OnDestroy    : BTobjectProc;
       OnSize       : BTobjectProc2;

       HScroll      : BTScrollBar;
       VScroll      : BTScrollBar;

//       Controls     : BTControl;

       property     Menu        :BTmenu                     write SetNewMenu;
       property     BorderIcons :BTBorderIcons read aBicons write SetBorderIcons;
       property     WindowState :BTWindowState read aWstate write SetWindowState;

       constructor  Create(Par:BTWindow);  override;
       destructor   Destroy; override;
       procedure    GetHandle(fParent:BTForm);
       procedure    Close;
       procedure    CreateForm(Par:BTForm);
       procedure    CreateFormIndirect(parentHandle:dword);
       procedure    ShowModal;
       procedure    ShowInside;
       procedure    AttachPicture(b:BTBitmap; mode:dword);
      end;


      BTFormClass = class of BTWindow;

      BTApplication = class
      private
        aBreak      : boolean;
        aMainForm   : BTForm;
      public
        Cursor      : BTCursor;
        OnIdle      : procedure;
        Constructor Create;
        Destructor  Destroy; override;
        Procedure   Run;
        Procedure   Runner;
        Procedure   ProcessMessages;
        Procedure   Terminate;
        Function    ForceMainForm(frm:BTForm):BTForm;
        Procedure   CreateForm(InstanceClass: BTFormClass; var Reference);
      end;


function  DefaultHeight(Font:BTFont; rows:dword):dword;

procedure SetStandAloneMode(mode:dword);

procedure debug(a:string; w:dword);


var
   BApplication : BTApplication;
   CurMessage   : MSG;
   KBDstatus    : dword;
   //           ...|...|...|...|...|...|...|...|
   // Shift     -------------------------------1  $1
   // Ctrl      ------------------------------1-  $2
   // Alt       -----------------------------1--  $4
   // LCtrl     ----------------------------1---  $8
   // RCtrl     ---------------------------1----  $10
   // LShift    --------------------------1-----  $20
   // RShift    -------------------------1------  $40
   //


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
implementation



var
   FormName   : dword;
   FatherForm : BTForm;
   ModalOn    : dword;
   StandAloneMode : dword;



function  DefaultHeight(Font:BTFont; rows:dword):dword;
var rs:dword;
begin
   if assigned(Font) then
   begin
   end else begin
     rs := 16;
   end;
   DefaultHeight := rows * rs;
end;

procedure SetStandAloneMode(mode:dword);
begin
 StandAloneMode := mode;
end;



// B U T C H E R    t o o l s

procedure KBDevent(aMessage,aWParam,aLParam:dword);
begin
  case aMessage of
     WM_KEYDOWN:
        begin
                    case awParam of
                       VK_MENU     : KBDstatus := KBDstatus or $4;  // alt keybrd
                       VK_CONTROL  : KBDstatus := KBDstatus or $2; // ctrl
                       VK_SHIFT    : KBDstatus := KBDstatus or $1; // shift
                       VK_LCONTROL : KBDstatus := KBDstatus or $8;
                       VK_RCONTROL : KBDstatus := KBDstatus or $10;
                       VK_LSHIFT   : KBDstatus := KBDstatus or $20;
                       VK_RSHIFT   : KBDstatus := KBDstatus or $20;
                    end;
        end;
    WM_KEYUP:
       begin
                    case awParam of
                       VK_MENU   :KBDstatus := KBDstatus and ( not $4);
                       VK_CONTROL: KBDstatus := KBDstatus and ( not $2); // ctrl
                       VK_SHIFT  : KBDstatus := KBDstatus and ( not $1); // shift
                       VK_LCONTROL : KBDstatus := KBDstatus and ( not $8);
                       VK_RCONTROL : KBDstatus := KBDstatus and ( not $10);
                       VK_LSHIFT   : KBDstatus := KBDstatus and ( not $20);
                       VK_RSHIFT   : KBDstatus := KBDstatus and ( not $20);

                    end;
        end;

  end;
end;

procedure RemoveObjects(OBJ:BTForm; a_dc:dword);
var I:BTwindow;
    XP:dword;
begin
   if OBJ = nil then Exit;
   if OBJ.Control = false then
   begin
      I := BTForm(OBJ).Childs;
      xp := 1;
      while (I<>nil) do begin
         // For transparent controls
//neraboti         if ((I.ClassType and 2) <> 0 ) and I.aTransparent then xp := 0;
         if (I.ClassType and 4) <> 0 then xp := 0; //force not to calc
//         if (I.ClassType and 2) and BTCheckBox(I).Transparent then xp := 0;
//         if (I.ClassType and 2) and BTRadioButton(I).Transparent then xp := 0;

         if BTControl(I).aTransparent then xp := 0;
         if not I.Visible then xp := 0;

         if xp = 1 then
             ExcludeClipRect(a_dc, I.Xpos , I.Ypos ,
                                   I.Xpos + I.Xlng,
                                   I.Ypos + I.Ylng);
         I:=I.NextChild;
         xp := 1;
      end;
   end;
end;



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



function Butcher(Obj:BTForm; aWindow,aMessage,aWParam,aLParam:dword):dword;
var res,mb,dd : dword;
    I,ctl,K,D,Mi,Ma:BTWindow;
    pr:procedure;
    pdc:hdc;
    ps : paintstruct;
    grRect,re :RECT;
    h_wnd :HWND;
    wdc :HDC;
    ClipRGN :HRGN;
    xp,yp,xl,yl,xc,yc:longint;
    xr,yr:real;
    Scroll:BTScrollBar;
    old : dword;
    pf:BTForm;
    tim :BTTimer;
    s:string;
begin
  res := 0;
//debug('BUTCHER',aMessage);
  if aWindow = Obj.Handle then
  begin
    CurMessage.hwnd := aWindow;
    CurMessage.message := aMessage;
    CurMessage.wParam := awParam;
    CurMessage.lParam := alParam;   

    case aMessage of

    {---------------------------------------------------------------------}
    WM_CTLCOLORDLG,
    WM_CTLCOLORMSGBOX,
    WM_CTLCOLOR,
    WM_CTLCOLORBTN,
    WM_CTLCOLOREDIT,
    WM_CTLCOLORLISTBOX,
    WM_CTLCOLORSCROLLBAR,
    WM_CTLCOLORSTATIC:
       begin
        // cal Def Proc to set Default colors
        dd := DefWindowProc(aWindow, aMessage, aWParam, aLParam);
        I := BTControl(GetProp(aLParam,'xctl'));
 //do same       I := Obj.Childs;
 //       while (I <> nil) do
 //       begin
 //         if I.handle = aLParam then Break;
 //         I := I.NextChild;
 //       end;
        if I <> nil then
        begin
          setTextColor(awParam,I.aPen.Color);
          if I.aBrush.Style = bbsClear then SetBkMode(aWParam, TRANSPARENT);
          if I.aBrush.Handle <> 0 then
          begin
             setBkColor(awParam,I.aBrush.Color);
             dd := I.aBrush.Handle;
          end;
        end;
        res := dd;

//22        ctl := nil;
//22        repeat
//22           if (I^.cid <> 0) and (I^.chnd = aLParam ) then ctl := I;
//22           I := I^.Next;
//22        until I = nil;
//22        if ctl <> nil then
//22        begin
//22             if ctl^.Color <> 1 then setTextColor(awParam,ctl^.Color);
//22             if ctl^.BColor <> 1 then begin
//22                                        setBkColor(awParam,ctl^.BColor);
//22                                        dd := ctl^.BColorBR;
//22                                      end;
//22        end;
//        res := dd;
      end;

    {---------------------------------------------------------------------}
    WM_USER: // notification
       begin
//        if awParam = 1 then Obj.SetWindowBrush(aLParam);
        if (awParam = 4) or    // 4 back tab
           (awParam = 6) or    // 6 tab order send from control
           (awParam = 5) then  // 5 default key
        begin
          if aLParam = 0 then old := 0
                         else old := BTcontrol(aLParam).Tab;
          ctl := OBJ.Childs;
          xp := 2000000;       yp := 2000000;
          xl := 0;             yl := 0;
          K := nil;  I := nil;  D := nil;  Mi := nil;  Ma := Nil;
          while (ctl<> nil) do
          begin
             if ctl.Tab <> 0 then
             begin
                // 1. Find Min in tab order
                if ctl.Tab < yp then begin yp := ctl.Tab; Mi := Ctl;  end;
                // 2. Find Max in tab order
                if ctl.Tab > yl then begin yl := ctl.Tab; Ma := Ctl;  end;
                // 3. (next) Min bider
                if ctl.Tab > old then
                begin
                   if ctl.Tab < xp then begin xp := ctl.Tab; D := Ctl;  end;
                end;
                // 4. (previus) Max less
                if ctl.Tab < old then
                begin
                   if ctl.Tab > xl then begin xl := ctl.Tab; K := Ctl;  end;
                end;
             end;
             //3. Get default
             if ctl.ClassType = 1 then
             begin
//               if ctl.DefByFocus = 1 then D := ctl;
             end;
             ctl := ctl.NextChild;
          end;
          // Corector NEXT            X -> MIn
          if D = nil then D := Mi;
          // Corector PREV     MAx <- X
          if K = nil then K := Ma;

          // Set Focus
          if awParam = 4 then
          begin // Back Tab (Prev)
             if K <> nil then
             begin
                windows.SetFocus(K.Handle);
                K.UpdateWindow;
             end;
          end;
          if awParam = 6 then
          begin // Tab (Next)
             if D <> nil then
             begin
                windows.SetFocus(D.Handle);
                D.UpdateWindow;
             end;
          end;



          if I = nil then I := K;
//          if awParam = 6 then if I <> nil then
//          begin
//             windows.SetFocus(I.Handle);
//             if I.ClassType = 1 then
//             begin
//                BTButton(I).Default := true;
//                I.UpdateWindow;
//             end else begin
//
//             end;
//          end;
//          if (awParam = 5) and (D <> nil) then if assigned(D.OnClick) then D.OnClick;
        end;
       end;

    {---------------------------------------------------------------------}
    WM_COMMAND:
       begin
          I := BTControl(GetProp(aLParam,'xctl'));
          if I <> NIL then
          begin
             dd := aWParam shr 16 ; { Hi order wird notification }
             case dd of
//todo                0: begin end; { menu}
//todo                1: begin end; { accelerator }
                BN_CLICKED : if Assigned(BTControl(I).OnClick) then BTControl(I).OnClick;
//todo            BN_DBLCLK :  BTControl(I).OnDblClick; { BS_NOTIFY must be set }
                CBN_SELCHANGE : begin
                      if I.ClassName = 'combobox' then if Assigned(BTComboBox(I).OnChange) then BTComboBox(I).OnChange;
                  end;
             end;
          end else begin
             I := obj.Childs;
             while (I <> nil) do
             begin
                if BTControl(I).ID = (aWParam and $FF) then Break;
                I := I.NextChild;
             end;
             if I <> nil then if Assigned(BTControl(I).OnClick) then BTControl(I).OnClick;
          end;
       end; // end WM_Command

    // EVENTS //
//    WM_SYSKEYDOWN: KBDstatus := KBDstatus or $4;  // alt keybrd

//    WM_SYSKEYUP:   KBDstatus := KBDstatus and ( not $4);
     {---------------------------------------------------------------------}
     WM_KEYDOWN:
        begin
            KBDevent(aMessage,awParam,alParam);
                    case awParam of
//                       VK_MENU     : KBDstatus := KBDstatus or $4;  // alt keybrd
//                       VK_CONTROL  : KBDstatus := KBDstatus or $2; // ctrl
//                       VK_SHIFT    : KBDstatus := KBDstatus or $1; // shift
//                       VK_LCONTROL : KBDstatus := KBDstatus or $8;
//                       VK_RCONTROL : KBDstatus := KBDstatus or $10;
//                       VK_LSHIFT   : KBDstatus := KBDstatus or $20;
//                       VK_RSHIFT   : KBDstatus := KBDstatus or $20;


                       VK_TAB    : Begin
                                    if OBJ.Childs <> nil then
                                    begin
                                      if (KBDstatus and 1) = 0
                                       then PostMessage(OBJ.handle,WM_USER,6,0)
                                       else PostMessage(OBJ.handle,WM_USER,4,0);
                                      res := 1;
                                    end;
                                   end;
                       VK_RETURN : begin // look for default key
                                    if OBJ.Childs <> nil then
                                    begin
                                      PostMessage(OBJ.Handle,WM_USER,5,0);
                                      res :=1;
                                    end;
                                   end;
                    end;
                    if (Assigned(obj.OnKey) and (res = 0)) then
                       obj.OnKey(awParam,(alParam shr 16) and $7F,KBDstatus);
       end;

    {---------------------------------------------------------------------}
    WM_KEYUP:
       begin
            KBDevent(aMessage,awParam,alParam);
//                    case awParam of
//                       VK_MENU   :KBDstatus := KBDstatus and ( not $4);
//                       VK_CONTROL: KBDstatus := KBDstatus and ( not $2); // ctrl
//                       VK_SHIFT  : KBDstatus := KBDstatus and ( not $1); // shift
//                       VK_LCONTROL : KBDstatus := KBDstatus and ( not $8);
//                       VK_RCONTROL : KBDstatus := KBDstatus and ( not $10);
//                       VK_LSHIFT   : KBDstatus := KBDstatus and ( not $20);
//                       VK_RSHIFT   : KBDstatus := KBDstatus and ( not $20);
//
//                    end;
                 end;

    {---------------------------------------------------------------------}
    WM_MOUSEMOVE: if Assigned(obj.OnMouse) then
                     obj.OnMouse(dword(alParam and $FFFF), dword(alParam shr 16));

    {---------------------------------------------------------------------}
    WM_RBUTTONDOWN,
    WM_LBUTTONDOWN: begin
                      mb := 0;
                      if (awParam and MK_LBUTTON) > 0 then mb := mb or 1;
                      if (awParam and MK_RBUTTON) > 0 then mb := mb or 2;
                      if Assigned(obj.OnClick) then
                               obj.OnClick(dword(alParam and $FFFF),
                                           dword(alParam shr 16), mb);
                      mb := 0;
                      if (aMessage and WM_LBUTTONDOWN) > 0 then mb := mb or 1;
                      if (aMessage and WM_RBUTTONDOWN) > 0 then mb := mb or 2;
                      if Assigned(obj.OnMouseDown) then
                               obj.OnMouseDown(dword(alParam and $FFFF),
                                               dword(alParam shr 16), mb, KBDstatus);
                    end;

    {---------------------------------------------------------------------}
    WM_RBUTTONUP,
    WM_LBUTTONUP:   begin
                      mb := 0;
                      if (aMessage and WM_LBUTTONDOWN) > 0 then mb := mb or 1;
                      if (aMessage and WM_RBUTTONDOWN) > 0 then mb := mb or 2;
                      if Assigned(obj.OnMouseUp) then
                               obj.OnMouseUp(dword(alParam and $FFFF),
                                               dword(alParam shr 16), mb, KBDstatus);
                    end;

    {---------------------------------------------------------------------}
    WM_LBUTTONDBLCLK,
    WM_RBUTTONDBLCLK: begin
                      mb := 0;
                      if (awParam and MK_LBUTTON) > 0 then mb := mb or 1;
                      if (awParam and MK_RBUTTON) > 0 then mb := mb or 2;
                      if Assigned(obj.OnDBLClick) then
                               obj.OnDBLClick(dword(alParam and $FFFF),
                                              dword(alParam shr 16), mb);
                    end;

    {---------------------------------------------------------------------}
    WM_ACTIVATE:  begin
                    if (awParam = WA_ACTIVE) or (awParam = WA_CLICKACTIVE) then
                    begin
                      if Assigned(obj.OnActivate) then obj.OnActivate;
                      // SetDefault
//                      ctl := OBJ.Controls;
//                      I := nil;
//                      while (ctl <> nil) do
//                      begin
//                        ctl.DefByFocus := 0;
//                        if ctl.classType = 1 then
//                        begin // button
//                           if I = nil then I := ctl;
//                        end;
//                        ctl := ctl.NextControl;
//                      end;
//                      if I <> nil then BTButton(I).SetDefault(true);
                    end;
                    if awParam = WA_INACTIVE then
                    begin
                      if Assigned(obj.OnDeActivate) then obj.OnDeActivate
                    end;
                  end;

    {---------------------------------------------------------------------}
    WM_ERASEBKGND: begin
                      if obj.aBitMap <> nil then res := 1
                      else begin
                         RemoveObjects(OBJ,awParam);
                         obj.Redraw(awParam,0,0,0,0,$1);
                         res := 1;
//                       //  wdc := windows.SaveDC(awParam);
//                         RemoveObjects(OBJ,awParam);
//
//                         Windows.GetClientRect(OBJ.Handle, grRect);
//                         Windows.FillRect(awParam, grRect, OBJ.aBrush.Handle);
//
//                         res := OBJ.aBrush.Handle;
//                       //  RestoreDC(awParam, wdc);
                      end;
                   end;

    {---------------------------------------------------------------------}
    WM_PAINT: begin
                h_wnd := obj.handle;
                wdc := obj.canvas.handle;
                if obj.aBitMap <> nil then
                begin
                   if GetUpdateRect(h_wnd,grRect,TRUE) then   // WASS FalsE
                   begin
                      with grRect do
                      begin
                         ClipRGN := 0;
                         GetClipRgn(wdc,CLipRGN);
                         SelectClipRgn(wdc,0);

                         pdc := BeginPaint(h_wnd,Ps);
                         RemoveObjects(OBJ,pdc);
                         if Assigned(obj.OnPaint) then obj.OnPaint(0,0,0);
//todo                         if (obj.aBitMap.bpp = 8) and (obj.aBitMap.GDIpal <> 0) then
//                         begin
//                            Old := SelectPalette(pdc,obj.aBitMap.GDIpal,False);
//                            RealizePalette(pdc);
//                         end;
                         if obj.aBitMapMode = 2 then
                         begin
                            // stretch
                            GetClientRect(obj.aHandle,re);
                            xr := 1.0;
                            yr := 1.0;
//                            if re.right <> 0 then xr := real(obj.aBitMap.Xlng - 1) / real(re.right);
//                            if re.bottom <> 0 then yr := real(obj.aBitMap.Ylng - 1) / real(re.bottom);

                            if re.right <> 0 then xr := (obj.aBitMap.Xlng - 1) / re.right;
                            if re.bottom <> 0 then yr := (obj.aBitMap.Ylng - 1) / re.bottom;
                            xp := round(left * xr);
                            yp := round(top * yr);
                            xl := round((right-left+1) * xr);
                            yl := round((bottom-top+1) * yr);
                            StretchBlt(pdc,left,top,right-left+1,bottom-top+1,
                                       obj.aBitMap.GetDC,xp,yp,xl,yl,SRCCOPY);
                            obj.aBitMap.ReleaseDC;
                         end else begin
                            // normal
                            BitBlt(pdc,left,top,right-left+1,bottom-top+1,
                                   obj.aBitMap.GetDC,left,top,SRCCOPY);
                            obj.aBitMap.ReleaseDC;
                         end;
//todo                         if (obj.aBitMap.bpp = 8) and (obj.aBitMap.GDIpal <> 0) then
//                         begin
//                           SelectPalette(pdc,old,False);
//                         end;
                         EndPaint(h_wnd,Ps);
                         SelectClipRgn(wdc,ClipRgn);
                      end;
                   end;
                end else begin
                    // normal draw of client area
                    pdc:=BeginPaint(obj.handle,ps);
                    RemoveObjects(OBJ,pdc);
//                    obj.Canvas.Handle := pdc;
                    obj.Redraw(pdc,0,0,0,0,$2);
//                    if Assigned(obj.OnPaint) then obj.OnPaint(pdc,0,0);
                    EndPaint(obj.handle,ps);
                end;
              end;

    {---------------------------------------------------------------------}
    WM_DESTROY: if Assigned(obj.OnDestroy) then obj.OnDestroy;

    {---------------------------------------------------------------------}
    WM_TIMER:
       begin
          str(awParam,s);
          s := 'tmr' + s;
          tim := BTTimer(GetProp(OBJ.Handle,pchar(s)));
          if Assigned(tim) then
             if Assigned(tim.OnTimer) then
                if tim.Enabled then tim.OnTimer;
       end;
    {---------------------------------------------------------------------}
    WM_SIZE:
      begin
        // CLIENT AREA
         Xp := dword(alParam and $FFFF); // in client size
         Yp := dword(alParam shr 16);
         Xl := Xp;
         Yl := Yp;
         old  := 0;
         if (Xp+Yp)>0 then
         begin
            old := 1;
            if Assigned(obj.OnSize) then obj.OnSize(Xp,Yp);
            if (obj.aBitMap <> nil) and (obj.aBitMapMode = 1) then
            begin
               obj.aBitMap.Xlng := xp; //re.right;
               obj.aBitMap.Ylng := yp; //re.bottom;
               InvalidateRect(obj.aHandle,nil,false);
            end;
            xl := OBJ.aClientXlng;
            yl := OBJ.aClientYlng;
            OBJ.aClientXlng := xp;
            OBJ.aClientYlng := yp;
         end;

         // ALIGN & ANCHORS
         if awParam <> SIZEICONIC then
         begin
            ctl := OBJ.Childs;
            xc := xl - xp; { diference }
            yc := yl - yp;
            while (ctl <> nil) do
            begin
               xp := ctl.Xpos;
               yp := ctl.Ypos;
               xl := ctl.Xlng;
               yl := ctl.Ylng;
               dd := 0;


               if (alLeft = ctl.Align) then
               begin
                  xp := 0;               yp := 0;
                  {original}             yl := OBJ.ClientYlng;
                  dd := 1;
               end;
               if (alTop = ctl.Align) then
               begin
                  xp := 0;                     yp := 0;
                  xl := OBJ.ClientXlng;        {original}
                  dd := 1;
               end;
               if (alRight = ctl.Align) then
               begin
                  xp := OBJ.ClientXlng - xl;   yp := 0;
                  {original}                   yl := OBJ.ClientYlng;
                  dd := 1;
               end;
               if (alBottom = ctl.Align) then
               begin
                  xp := 0;                     yp := OBJ.ClientYlng - yl;
                  xl := OBJ.ClientXlng;        {original}
                  dd := 1;
               end;
               if (alClient = ctl.Align) then
               begin
                  xp := 0;                     yp := 0;
                  xl := OBJ.ClientXlng;        yl := OBJ.ClientYlng;
                  dd := 1;
               end;

               if old = 1 then  // I have real move
               begin
                  if (waRight in ctl.Anchors) then
                  begin
                     if (waLeft in ctl.Anchors) then   xl := xl - xc
                                                else   xp := xp - xc;
                     dd := 1;
                  end;
                  if (waBottom in ctl.Anchors) then
                  begin
                     if (waTop in ctl.Anchors) then   yl := yl - yc
                                               else   yp := yp - yc;
                     dd := 1;
                  end;
               end;

               if dd = 1 then
               begin
                 ctl.SetPosition(xp,yp);
                 ctl.Resize(xl,yl);
               end;
               ctl := ctl.NextChild;
            end;
         end;

         // do something else
         xp := 1;
         case aWParam of
            SIZENORMAL     : obj.aWState:=wsNormal;
            SIZEICONIC     : begin obj.aWState:=wsMinimized; xp := 0; end;
            SIZEFULLSCREEN : obj.aWState:=wsMaximized;
         end;
         if ModalOn = obj.Handle then
         begin
            pf := obj.Parent;
            while(pf <> nil) do
            begin
              if xp = 1 then pf.Show
                        else pf.Hide;
              pf := pf.Parent;
            end;
         end;
//         res := 1;
      end;

    {---------------------------------------------------------------------}
    WM_SETCURSOR :
      begin
         if LOWORD(alParam) = HTCLIENT then
         begin
            SetCursor(obj.Cursor.Handle);
            res := 1;
         end;
      end;

    {---------------------------------------------------------------------}
    WM_VSCROLL,
    WM_HSCROLL:
      begin
       Scroll := nil;
        if alParam <> 0 then
        begin
           Scroll := BTScrollBar(GetProp(alParam,'xctl'));
        end else begin
           if aMessage = WM_VSCROLL then Scroll := Obj.VScroll;
           if aMessage = WM_HSCROLL then Scroll := Obj.HScroll;
        end;

        if Scroll <> nil then
        begin
           if Scroll.AutoMode = false then
           begin
              case loWord(awParam) of
               SB_LINEUP: if Assigned(Scroll.OnLineUp) then Scroll.OnLineUp;
               SB_LINEDOWN: if Assigned(Scroll.OnLineDown) then Scroll.OnLineDown;
               SB_PAGEUP: if Assigned(Scroll.OnPageUp) then Scroll.OnPageUp;
               SB_PAGEDOWN:  if Assigned(Scroll.OnPageUp) then Scroll.OnPageDown;
               SB_THUMBTRACK: begin
                      if Assigned(Scroll.OnMovePos) then Scroll.OnMovePos(HiWord(awParam));
                      Scroll.Position := HiWord(awParam);
                            end;
               end; // case
           end else begin
              yp :=(Scroll.MaxPosition - Scroll.MinPosition + 1) div 10;
              xp := Scroll.Position;
              case loWord(awParam) of
               SB_LINEUP: begin
                             dec(xp);
                             if longint(xp) < longint(Scroll.MinPosition) then
                                          xp := Scroll.MinPosition;
                          end;
               SB_LINEDOWN: begin
                             inc(xp);
                             if longint(xp) > longint(Scroll.MaxPosition) then
                                          xp := Scroll.MaxPosition;
                          end;
               SB_PAGEUP: begin
                             xp := xp - yp;
                             if longint(xp) < longint(Scroll.MinPosition) then
                                          xp := Scroll.MinPosition;
                          end;
               SB_PAGEDOWN: begin
                             xp := xp + yp;
                             if longint(xp) > longint(Scroll.MaxPosition) then
                                          xp := Scroll.MaxPosition;
                          end;
               SB_THUMBTRACK: xp := HiWord(awParam);
               end; // case
               Scroll.Position := xp;
               if Assigned(Scroll.OnChange) then Scroll.OnChange(xp);
           end;
        end; // Scroll <> nil
      end;
    end; // BIG CASE
    if Assigned(obj.OnOther) then res := obj.OnOther(aWindow,aMessage,awParam,alParam);
  end;
  Butcher := res;
end;

function Form_WindowProc(aWindow: HWnd; AMessage: UINT; WParam : WPARAM;
                         LParam: LPARAM): LRESULT; stdcall;
var
   Obj:BTForm;
   res:dword;
begin
   Form_WindowProc := 0;
   res := 0;
   Obj := BTForm(GetProp(aWindow,'form'));
   if Obj <> nil then res := Butcher(OBJ,aWindow,aMessage,wParam,LParam);
   if res = 0 then begin
      case aMessage of
      WM_CLOSE :
         begin
           DestroyWindow(aWindow);
           Exit;
         end;
      WM_DESTROY :
         begin
           if ModalOn <> 0 then
           begin
              PostQuitMessage(0); // stop modal
           end else begin
              if StandAloneMode = 1 then
              begin
                  if FatherForm.handle = aWindow then PostQuitMessage(0);
              end;
              OBJ.Free;
           end;
           Exit;
         end;
      end;
      Form_WindowProc := DefWindowProc(aWindow, AMessage, WParam, LParam);
   end else begin
      Form_WindowProc := res;
   end;
end;



procedure debug(a:string; w:dword);
var f:text;
    s,s1:string;
begin
{   str(w,s1);
   assign(f,'debug.log');
//   reset(f);
   append(f);
   s:=a+'/'+s1;
   writeln(f,s);
   close(f); }
end;


const  {From Borland style write}
//  Breaks    : array[TMenuBreak] of Longint = (MFT_STRING, MFT_MENUBREAK, MFT_MENUBARBREAK);
  Checks    : array[Boolean]    of Longint = (MFS_UNCHECKED, MFS_CHECKED);
  Defaults  : array[Boolean]    of Longint = (0, MFS_DEFAULT);
  Enables   : array[Boolean]    of Longint = (MFS_DISABLED or MFS_GRAYED, MFS_ENABLED);
  Radios    : array[Boolean]    of Longint = (MFT_STRING, MFT_RADIOCHECK);
  Separators: array[Boolean]    of Longint = (MFT_STRING, MFT_SEPARATOR);



procedure AppendMenuWin(Item:BTMenuItem);
var
  ItemInfo :TMenuItemInfo;
  szCaption:string;
begin
    if Item = nil then Exit;
    if Item.aVisible then begin
       with Item do begin
         szCaption              :=aCaption;
         ItemInfo.cbSize        :=SizeOf(TMenuItemInfo);
         ItemInfo.fMask         :=MIIM_CHECKMARKS or MIIM_DATA or MIIM_ID or MIIM_STATE or MIIM_SUBMENU or MIIM_TYPE;
//         ItemInfo.fType         :=Radios[aRadioItem];// or Breaks[aBreak] or Separators[aCaption = '-'];
         ItemInfo.fState        :=Checks[aChecked] or Enables[aEnabled] ;//or Defaults[aDefault];
//         ItemInfo.wID           :=Command;
         ItemInfo.hSubMenu      :=0;
         ItemInfo.hbmpChecked   :=0;
         ItemInfo.hbmpUnchecked :=0;
         ItemInfo.dwTypeData    :=PChar(szCaption);
//         if Item.GetCount > 0 then ItemInfo.hSubMenu:=GetHandle;
//         if Item.aParent <> nil then
//            InsertMenuItem(Item.FParent.Handle, -1, True, ItemInfo);
       end;
    end;
end;

constructor BTMenuItem.Create;
begin
  aHandle := 0;
end;

destructor  BTMenuItem.Destroy;
begin
  inherited;
end;




constructor BTSubMenu.Create;
begin
  aHandle := 0;
end;

destructor  BTSubMenu.Destroy;
begin
  inherited;
end;

function  BTSubMenu.AddItem(name:string):dword;
var res : dword;
begin
  res := 0;
  // name = E&xit use & -
  if aHandle <> 0 then  aHandle := windows.CreatePopupMenu();
  if aHandle <> 0 then  AppendMenu(aHandle,MF_STRING,1,pchar(name));
  AddItem := res;
end;







constructor BTMenu.Create;
begin
  aHandle := 0;
end;

destructor BTMenu.Destroy;
begin
  inherited;
end;

procedure  BTMenu.AddItem(name:string);
begin
end;

procedure  BTMenu.AddSubMenu(sname:string; smenu:BTSubMenu);
begin
end;










constructor BTCursor.Create;
begin
 hAndMaskBitmap := 0;
 hXorMaskBitmap := 0;
 aVisible := true;
 aHandle := 0;
 aPreset := pcNone;
 Parent := 0;
end;

destructor BTCursor.Destroy;
begin
  CSetHandle(0); // clear resorce
  inherited;
end;

procedure BTCursor.CSetHandle(value:dword);
begin
 if aHandle = 1 then aHandle := 0;
 if aPreset = pcNone then
    if aHandle <> 0 then
    begin
       DestroyCursor(aHandle);
       if hAndMaskBitmap <> 0 then DeleteObject(hAndMaskBitmap);
       if hXorMaskBitmap <> 0 then DeleteObject(hXorMaskBitmap);
       hAndMaskBitmap := 0;
       hXorMaskBitmap := 0;
    end;
 aHandle := value;
 if Parent = 0 then  SetCursor(aHandle);
end;

procedure BTCursor.CSetPreset(value:BTPresetCursor);
var a : dword;
begin
 aPreset := value;
  a := 1;
  case value of
   pcNone  : a := 1;
   pcArrow : a := LoadCursor(0,IDC_ARROW);
   pcHand  : a := LoadCursor(0,MAKEINTRESOURCE(32649)); {IDC_HAND}{win95 not working }
   pcWait  : a := LoadCursor(0,IDC_WAIT);
   pcCross : a := LoadCursor(0,IDC_CROSS);
   pcIBeam : a := LoadCursor(0,IDC_IBEAM);
   pcMove  : a := LoadCursor(0,IDC_SIZEALL);
 end;
 CSetHandle(a);
end;

procedure BTCursor.LoadFromFile(name:string);
var d:dword;
begin
  d := LoadImage(hInstance,Pchar(name),IMAGE_CURSOR,0,0,LR_DEFAULTSIZE or LR_CREATEDIBSECTION);
  if d = 0 then d := LoadImage(0,Pchar(name),IMAGE_CURSOR,0,0,LR_DEFAULTSIZE or LR_LOADFROMFILE);
  if d <> 0 then CSetHandle(d);
end;


procedure   BTCursor.SetFromBitmap(bmp:BTBitmap; xHotSpot,yHotSpot:longint);
var NewHandle : dword;
    h_DC,h_AndMaskDC,h_XorMaskDC : HDC;
    hOldAndMaskBitmap,hOldXorMaskBitmap:HBITMAP;
    MainBitPixel:dword;
    X,Y:longint;
    icon_info:ICONINFO;
begin


   h_DC					:= GetDC(0);
	 h_AndMaskDC  := CreateCompatibleDC(h_DC);
	 h_XorMaskDC	:= CreateCompatibleDC(h_DC);

 //TODO to delete bitmaps
   hAndMaskBitmap	:= CreateCompatibleBitmap(h_DC,bmp.Xlng,bmp.Ylng);
//   hAndMaskBitmap	:= CreateBitmap(bmp.Xlng,bmp.Ylng,1,1,nil); nil mono bitmap for alpha corsor
   hXorMaskBitmap	:= CreateCompatibleBitmap(h_DC,bmp.Xlng,bmp.Ylng);

	 hOldAndMaskBitmap	:= SelectObject(h_AndMaskDC,hAndMaskBitmap);
	 hOldXorMaskBitmap	:= SelectObject(h_XorMaskDC,hXorMaskBitmap);

   for x:=0 to bmp.Xlng - 1 do
	 begin
      for y:=0 to bmp.Ylng - 1 do
      begin
         MainBitPixel := GetPixel(bmp.GetDC,x,y);
         if MainBitPixel = bmp.ColorOff then
         begin
            SetPixel(h_AndMaskDC,x,y,RGB(255,255,255));
            SetPixel(h_XorMaskDC,x,y,RGB(0,0,0));
         end else begin
            SetPixel(h_AndMaskDC,x,y,RGB(0,0,0));
            SetPixel(h_XorMaskDC,x,y,MainBitPixel);
         end;
      end;
   end;
   bmp.ReleaseDC;

   SelectObject(h_AndMaskDC,hOldAndMaskBitmap);
   SelectObject(h_XorMaskDC,hOldXorMaskBitmap);

   DeleteDC(h_XorMaskDC);
   DeleteDC(h_AndMaskDC);

   ReleaseDC(0,h_DC);

bitblt(h_dc,0,400,32,32,h_xorMaskDc,0,0,srccopy);

   icon_info.fIcon := false;
   icon_info.xHotspot := xHotspot;
   icon_info.yHotspot := yHotspot;
   icon_info.hbmMask := hAndMaskBitmap;
   icon_info.hbmColor := hXorMaskBitmap; // for alpha V5 dib  


   NewHandle := CreateIconIndirect(icon_info);

   if NewHandle <> 0 then
   begin
      self.CsetHandle(NewHandle);
   end;
end;


procedure   BTCursor.SetFromBitmapFile(name:string; ColorOff:dword; xHotSpot,yHotSpot:longint);
var bmp:BTBitmap;
begin
   bmp:= BTBitmap.Create;
   bmp.LoadFromFile(pchar(name));
   if bmp.Handle <> 0 then
   begin
      bmp.Transparent := true;
      bmp.ColorOff := ColorOff;
      SetFromBitmap(bmp,xHotSpot,yHotSpot);
   end;
   bmp.Free;
end;



constructor BTIcon.Create;
begin
 aHandle := 0;
 aPreset := piNone;
 Parent := 0;
end;

destructor BTIcon.Destroy;
begin
  inherited;
end;

procedure BTIcon.CSetHandle(value:dword);
begin
 if aHandle = 1 then aHandle := 0;
 if aPreset = piNone then if aHandle <> 0 then DestroyIcon(aHandle);
 aHandle := value;
 if Parent <> 0 then SendMessage(Parent, WM_SETICON, 1, aHandle);
//
// begin
//   //todo
// end else begin
//   // for window by class redefinition
//   SetClassLong(Parent,GCL_HICON,aHandle);
// end;
end;

//NOTE index start from 0...X
procedure BTIcon.Shell32Preset(value:dword; name:pchar);
var a,h: dword;
    p:pchar;
    s:string;
begin
  p := name;
  s := 'shell32.dll'+#0;
  if p = nil then p := pchar(@s[1]);
  a := ExtractIcon(0,p,dword(-1));
  if value > a then value := 0;
  h := ExtractIcon(0,p, value);
  if h <> 0 then  CSetHandle(h);
end;


procedure BTIcon.CSetPreset(value:BTPresetIcon);
var a : dword;
begin
 aPreset := value;
  a := 1;
  case value of
   piNone      : a := 1;
   piApp       : a := LoadIcon(0,IDI_APPLICATION);
   piError     : a := LoadIcon(0,IDI_HAND);
   piWarning   : a := LoadIcon(0,IDI_EXCLAMATION);
   piQuestion  : a := LoadIcon(0,IDI_QUESTION);
   piAsterisk  : a := LoadIcon(0,IDI_ASTERISK);
 end;
 CSetHandle(a);
end;

procedure BTIcon.LoadFromFile(name:string);
var d:dword;
begin
  d := LoadImage(0,Pchar(name),IMAGE_ICON,0,0,LR_DEFAULTSIZE or LR_LOADFROMFILE);
  if d <> 0 then CSetHandle(d);
end;


constructor BTWindow.Create;
begin
  NextChild    := nil;
  Childs       := nil;
  OnPaint      := nil;   // procedure(w,d,p:dword);
  OnOther      := nil;   // function(a,m,w,l:dword):dword;

  Tab  := 0;
  ClassType := 0;
  aFlat := false;
  aBorder := bsSizeable;
  aXpos := 0;
  aYpos := 0;
  aXlng := 0;
  aYlng := 0;
  aClientXlng := 0;
  aClientYlng := 0;
  awdc := 0;
  aCTRL := false;
  aHandle := 0;
  aParent := nil;
//  aPhandle := 0;
  aCaption := '';
  aVisible := true;
  aEnabled := true;
  aAlign := alNone;
  aAnchors := [waTop,waLeft];

  aBrush := BTBrush.Create;
  aPen := BTPen.Create;
  Cursor := BTCursor.Create;
  Cursor.Preset := pcArrow;
  Icon := BTIcon.Create;
  Font := BTFont.Create;
  Font.OnChange := WinFontChange;  
  Canvas := BTCanvas.Create;

  aBrush.Color := GetSysColor(COLOR_BTNFACE);
  aPen.Color := 0;

end;


function PropEnumProc(WND:dword; STR:PCHAR; DATA:dword):boolean; stdcall;
var T:BTTimer;
begin
  if (str[0] = 't') and (str[1] = 'm') then
  begin
    T := BTTimer(data);
    T.Free;
  end;
  PropEnumProc := true;
end;


destructor BTWindow.Destroy;
begin
  //Release Attached objects like timer
  EnumProps(aHandle,@PropEnumProc);
  aBrush.Destroy;
  aPen.Destroy;
  Cursor.Destroy;
  Icon.Destroy;
  Canvas.Destroy;
  if awdc <> 0 then ReleaseDC(aHandle,awdc);
  inherited Destroy;
end;


// dmode 0000 = 0011
// dmode 0001 ($1) - Erase BackGround
// dmode 0010 ($2) - Do Paint
// dmode 0100 ($4) - Add To Clip Rgn
procedure  BTWindow.Redraw(xdc:dword; Xpos,Ypos,Xlng,Ylng:longint; dmode:dword);
var Re:Trect;
    mdc:boolean;
    wdc:dword;
    region:HRGN;
begin
   mdc := false;
   if  xdc = 0 then begin xdc := windows.GetDC(Handle); mdc := true; end;
   if  xdc = 0 then Exit;

   if  (Xpos+Ypos+Xlng+Ylng) = 0 then
   begin
      GetClientRect(Handle,re);
      Xpos := re.Left;
      Ypos := re.Top;
      Xlng := re.Right - Xpos;
      Ylng := re.Bottom - Ypos;
   end else begin
      re.Left := Xpos;
      re.Top := Ypos;
      re.Right := Xpos + Xlng;
      re.Bottom := Ypos + Ylng;
   end;

   if dmode = 0 then dmode := 3;
   wdc := Windows.SaveDC(xdc);
   if (dmode and 4) <> 0 then
   begin

      RemoveObjects(BTForm(self),xdc);
      SetViewportOrgEx(xdc,Xpos * (-1), Ypos * (-1),nil);


   //   region := CreateRectRgn(Xpos,Ypos,Xpos+Xlng,Ypos+Ylng);
//      SelectClipRgn(xdc,region);
   //   ExtSelectClipRgn(xdc,region,RGN_OR);
//      deleteObject(region);
   end;

   // Erase BackGround
   if (dmode and 1) <> 0 then windows.FillRect(xdc,re,aBrush.Handle);
   // Draw Area
   if (dmode and 2) <> 0 then  if Assigned(OnPaint) then
   begin
      Canvas.Handle := xdc;
      OnPaint(xdc,0,0);
   end;

   if mdc then windows.ReleaseDC(Handle,xdc);
   windows.RestoreDC(xdc,wdc);
end;



Procedure BTWindow.SetHandle(value:dword);
begin
 if value = 0 then Exit;
 aHandle := value;
// aBrush.Parent := value;
// aPen.Parent := value;
 Cursor.Parent := value;
 Icon.Parent := value;

// Canvas.Handle := GetDC(value); this will be auto get in first canvas call
 Canvas.Parent := value;
end;

// object notification
procedure BTWindow.WinFontChange(a:BTFont);
begin
  if aHandle <> 0 then SendMessage(aHandle,WM_SetFont, a.Handle ,1);
end;

procedure BTWindow.SetAlign(value:BTAlign);
begin
   aAlign := value;
   postmessage(parent.Handle,WM_SIZE,0,0);
end;

procedure BTWindow.SetAnchors(value:BTAnchors);
begin
   aAnchors := value;
end;


Procedure BTWindow.SetBkColor(value:dword);
begin
 aBrush.color := value;
// if Control then UpdateWindow;
// Resize(aXlng,aYlng);
 UpdateWindow;
end;

Procedure BTWindow.SetColor(value:dword);
begin
 aPen.color := value;
// if Control then UpdateWindow;
 UpdateWindow;
end;

Procedure BTWindow.SetPosition(nXpos,nYpos:longint);
//var r:RECT;
begin
  if aHandle = 0 then Exit;
  aXpos := nXpos;
  aYpos := nYpos;
//  GetWindowRect(aHandle,r);
//  MoveWindow(aHandle, aXpos, aYpos, r.right - r.left + 1, r.bottom - r.top + 1, TRUE);
  MoveWindow(aHandle, aXpos ,aYpos, aXlng, aYlng, TRUE);
//  MoveWindow(aHandle, aXpos, aYpos, r.right - r.left, r.bottom - r.top, TRUE);
end;

Procedure BTWindow.Resize(nXlng,nYlng:longint);
//var r:RECT;
begin
  if aHandle = 0 then Exit;
  aXlng := nXlng;
  aYlng := nYlng;
//  GetWindowRect(aHandle,r);
  // this will broke xpos ypos of window
  MoveWindow(aHandle, aXpos ,aYpos, aXlng, aYlng, TRUE);
//  MoveWindow(aHandle, r.left ,r.Top, aXlng, aYlng, false);
//  SetPosition(aXpos,aYpos);
end;

procedure BTWindow.SetXpos(value:longint);
begin
//  if aXpos = value then Exit;
  aXpos := value;
  SetPosition(aXpos,aYpos);
end;

procedure BTWindow.SetYpos(value:longint);
begin
//  if aYpos = value then Exit;
  aYpos := value;
  SetPosition(aXpos,aYpos);
end;

procedure BTWindow.SetXlng(value:longint);
begin
//  if aXlng = value then Exit;
  aXlng := value;
  Resize(aXlng,aYlng);
end;

procedure BTWindow.SetYlng(value:longint);
begin
//  if aYlng = value then Exit;
  aYlng := value;
  Resize(aXlng,aYlng);
end;


function BTWindow.GetXpos:longint;
var r:rect;
begin
  if Control = false then
  begin
     GetWindowRect(aHandle,r);
     aXpos := r.Left;
  end;
  GetXpos := aXpos;
end;

function BTWindow.GetYpos:longint;
var r:rect;
begin
  if Control = false then
  begin
     GetWindowRect(aHandle,r);
     aYpos := r.top;
  end;
  GetYpos := aYpos;
end;

function BTWindow.GetXlng:longint;
var r:rect;
begin
  if Control = false then
  begin
     GetWindowRect(aHandle,r);
     aXlng := r.right - r.left +1;
  end;
  GetXlng := aXlng;
end;

function BTWindow.GetYlng:longint;
var r:rect;
begin
  if Control = false then
  begin
     GetWindowRect(aHandle,r);
     aYlng := r.bottom - r.top +1;
  end;
  GetYlng := aYlng;
end;

procedure BTWindow.SetVisible(value:boolean);
var d:dword;
begin
  if aHandle = 0 then Exit;
  if aVisible = value then Exit;
  aVisible := value;
  d := SWP_NOMOVE or SWP_NOSIZE or SWP_NOZORDER or SWP_NOACTIVATE;
  if value then d := d or SWP_SHOWWINDOW
           else d := d or SWP_HIDEWINDOW;
  SetWindowPos(aHandle, 0, 0, 0, 0, 0, d);
  UpdateWindow;

{
  d := GeBTWindow Long(aHandle,GWL_STYLE);
  if d <> 0 then
  begin
    aVisible := value;
    if value then   d := d or  WS_VISIBLE
             else   d := d and (not WS_VISIBLE);
    SeBTWindow Long(aHandle,GWL_STYLE,d);
    if aPhandle <>0 then
    begin
      InvalidateRect(aPhandle,nil,true);
      windows.UpdateWindow(aPhandle);
    end;
  end;
 }
end;

procedure BTWindow.SetEnabled(value:boolean);
begin
  if aHandle =0 then Exit;
  aEnabled := value;
  EnableWindow(aHandle,value);
end;

procedure BTWindow.SetCaption(value:string);
begin
  if aHandle =0 then Exit;
  aCaption := value;
  SetWindowText(aHandle,pchar(aCaption));
  UpdateWindow;
//  if aPhandle <>0 then
//  begin
//    InvalidateRect(aPhandle,nil,true);
//    windows.UpdateWindow(aPhandle);
//  end;
end;

procedure BTWindow.Show;
begin
  if aHandle = 0 then Exit;
  SetVisible(true);
//  ShowWindow(aHandle, SW_SHOW);
//  windows.UpdateWindow(aHandle);
//  aVisible := true;
//  windows.SetFocus(aHandle);
end;

procedure BTWindow.Hide;
begin
  if aHandle = 0 then Exit;
  SetVisible(false);
//  aVisible := false;
//  ShowWindow(aHandle, SW_HIDE);
//  UpdateWindow;
end;

procedure BTWindow.Load(Xp,Yp,Xl,Yl: dword; Cap:string);
begin
  Caption := Cap;
  SetPosition(Xp,Yp);
  Resize(Xl,Yl);
//  Xpos := Xp;
//  Ypos := Yp;
//  Xlng := Xl;
//  Ylng := Yl;
end;

procedure BTWindow.UpdateWindow;
var R:TRect;
begin
  if aHandle = 0 then Exit;
  InvalidateRgn(aHandle,0,TRUE); 
  exit;

  if Not Control then
  begin
    InvalidateRect(aHandle,nil,TRUE); // true to forse ERASEBKGR in Begin Paint
//    windows.UpdateWindow(aHandle);
  end else begin
    R.Left   := Xpos;
    R.Top    := Ypos;
    R.Right  := Xpos + Xlng;
    R.Bottom := Ypos + Ylng;
    if assigned(Parent) then
    begin
      InvalidateRect(Parent.Handle, @R, True);
//      windows.UpdateWindow(Parent.Handle);
    end;
  end;
//  if Parent <> nil then
//  begin
//      InvalidateRect(Parent.Handle,nil,true);
//      windows.UpdateWindow(Parent.Handle);
//  end;
end;

procedure BTWindow.BringToFront;
begin
   if aHandle <> 0 then SetWindowPos(aHandle,HWND_TOP,0,0,0,0,SWP_NOSIZE or SWP_NOMOVE or SWP_NOACTIVATE );
end;

procedure BTWindow.BringToBack;
begin
   if aHandle <> 0 then SetWindowPos(aHandle,HWND_BOTTOM,0,0,0,0,SWP_NOSIZE or SWP_NOMOVE or SWP_NOACTIVATE );
end;

procedure BTWindow.SetStyle(EX,AndMask,OrMask:dword);
var Stl:integer;
begin
  if aHandle <> 0 then
  begin
     stl := GWL_STYLE;
     if EX = 1 then stl := GWL_EXSTYLE;
     SetWindowLong(aHandle, stl,
                  ((GetWindowLong(aHandle, stl) and AndMask) or OrMask) );
  end;
end;


procedure BTWindow.SetBorder(value:BTBorder);
var   dand,edand:dword;
      dor,edor:dword;
     //WM:HMENU;
begin
  if Self.aHandle = 0 then Exit;
  if aBorder = value then Exit;
  aBorder := value;

 if aCTRL = false then
 begin

//  d := GetWindowLong(aHandle,GWL_STYLE);
//  ed := GetWindowLong(aHandle,GWL_EXSTYLE);
//
//  d := d and (not (WS_POPUP or WS_CAPTION or WS_BORDER
//                   or WS_THICKFRAME or WS_DLGFRAME or DS_MODALFRAME));
//
//  ed := ed and (not (WS_EX_TOOLWINDOW or WS_EX_DLGMODALFRAME or WS_EX_WINDOWEDGE));
//
//  case value of
//       bsNone        : begin
//                         d := d or WS_POPUP;
//                       end;
//       bsSingle,
//       bsToolWindow  : begin
//                         d := d or (WS_CAPTION or WS_BORDER);
//                         if value = bsToolWindow then
//                            ed:= ed or WS_EX_TOOLWINDOW;
//                       end;
//       bsSizeable,
//       bsSizeToolWin : begin
//                         d := d or (WS_CAPTION or WS_THICKFRAME);
//                         if value = bsSizeToolWin then
//                            ed := ed or WS_EX_TOOLWINDOW;
//                       end;
//       bsDialog      : begin
//                         d := d and (not (WS_MINIMIZEBOX or WS_MAXIMIZEBOX));
//                         d := d or (WS_POPUP or WS_CAPTION or WS_DLGFRAME or DS_MODALFRAME);
//                         ed := ed or (WS_EX_DLGMODALFRAME or WS_EX_WINDOWEDGE);
//
////                         WM:=GetSystemMenu(FHandle, False);
////                         DeleteMenu(WM, SC_TASKLIST, MF_BYCOMMAND);
////                         DeleteMenu(WM, SC_MAXIMIZE, MF_BYCOMMAND);
////                         DeleteMenu(WM, SC_MINIMIZE, MF_BYCOMMAND);
////                         DeleteMenu(WM, SC_SIZE,     MF_BYCOMMAND);
////                         DeleteMenu(WM, SC_RESTORE,  MF_BYCOMMAND);
////
////                        // FBorderIcons:=[bisystemmenu];
//
//                       end;
//  end;
//  SetWindowLong(aHandle,GWL_STYLE,d);
//  SetWindowLong(aHandle,GWL_EXSTYLE,ed);

    dand := (not (WS_POPUP or WS_CAPTION or WS_BORDER
                  or WS_THICKFRAME or WS_DLGFRAME or DS_MODALFRAME));

    edand := dword(not (WS_EX_TOOLWINDOW or WS_EX_DLGMODALFRAME or WS_EX_WINDOWEDGE));
    dor := 0;
    edor := 0;

    case value of
       bsNone        : begin
                         dor := WS_POPUP;
                       end;
       bsSingle,
       bsToolWindow  : begin
                         dor := (WS_CAPTION or WS_BORDER);
                         if value = bsToolWindow then
                            edor := WS_EX_TOOLWINDOW;
                       end;
       bsSizeable,
       bsSizeToolWin : begin
                         dor :=  (WS_CAPTION or WS_THICKFRAME);
                         if value = bsSizeToolWin then
                            edor := WS_EX_TOOLWINDOW;
                       end;
       bsDialog      : begin
                         dand := dand and (not (WS_MINIMIZEBOX or WS_MAXIMIZEBOX));
                         dor := (WS_POPUP or WS_CAPTION or WS_DLGFRAME or DS_MODALFRAME);
                         edor := (WS_EX_DLGMODALFRAME or WS_EX_WINDOWEDGE);

////                         WM:=GetSystemMenu(FHandle, False);
////                         DeleteMenu(WM, SC_TASKLIST, MF_BYCOMMAND);
////                         DeleteMenu(WM, SC_MAXIMIZE, MF_BYCOMMAND);
////                         DeleteMenu(WM, SC_MINIMIZE, MF_BYCOMMAND);
////                         DeleteMenu(WM, SC_SIZE,     MF_BYCOMMAND);
////                         DeleteMenu(WM, SC_RESTORE,  MF_BYCOMMAND);
////
////                        // FBorderIcons:=[bisystemmenu];
//
                       end;

    end;
    SetStyle(0,dand,dor); //STYLE
    SetStyle(1,edand, edor);  //EXSTYLE

  if Visible then SetWindowPos(aHandle,0,0,0,0,0,
           SWP_NOMOVE or SWP_NOSIZE or SWP_NOZORDER or SWP_FRAMECHANGED);
 end else begin
  // for buttons
//  d := GetWindowLong(aHandle,GWL_STYLE);
//  d := d and (not WS_BORDER);
//  if value <> bsNone then d := d or WS_BORDER;
//  SetWindowLong(aHandle,GWL_STYLE,d);
   dor := 0;
   dand := dword(not WS_BORDER);
   if value <> bsNone then dor := WS_BORDER;
   SetStyle(0,dand,dor); //STYLE

  if Visible then SetWindowPos(aHandle,0,0,0,0,0,
           SWP_NOMOVE or SWP_NOSIZE or SWP_NOZORDER or SWP_FRAMECHANGED);

 end;
end;

procedure SetClientDim(handle,width,Height:dword);
var rectWindow ,rectClient:rect;
begin
  if Handle <> 0 then begin
     Windows.GetWindowRect(Handle, rectWindow );
     Windows.GetClientRect(Handle, rectClient);
     Width := ((rectWindow.Right  - rectWindow .Left) - rectClient.Right) + longint(Width);
     Height:= ((rectWindow.Bottom - rectWindow .Top)  - rectClient.Bottom) + longint(Height);
     SetWindowPos(Handle, 0, 0, 0, Width, Height, SWP_NOZORDER or SWP_NOMOVE);
  end;
end;


procedure BTWindow.SetClientXlng(value:dword);
begin
  aClientXlng := value;
  if Control = false then SetClientDim(aHandle, value, GetClientYlng);
end;

procedure BTWindow.SetClientYlng(value:dword);
begin
  aClientYlng := value;
  if Control = false then SetClientDim(aHandle, GetClientXlng, value);
end;

function BTWindow.GetClientXlng:dword;
var r:rect;
begin
  r.right := aClientXlng;
  if Control = false then if aClientXlng = 0 then  GetClientRect(aHandle,r);
  GetClientXlng := r.right;
end;

function BTWindow.GetClientYlng:dword;
var r:rect;
begin
  r.bottom := aClientYlng;
  if Control = false then if aClientYlng  = 0 then  GetClientRect(aHandle,r);
  GetClientYlng := r.bottom;
end;

procedure BTWindow.SetFlat(value:boolean);
var dand,dor:dword;
    Edand,edor:dword;
begin
 if value = aFlat then Exit;
 if aHandle = 0 then Exit;
 // to do is there frame test
  aFlat := value;


  if aCTRL = false then
  begin
//     d := GetWindowLong(aHandle,GWL_STYLE);
//     ed := GetWindowLong(aHandle,GWL_EXSTYLE);
//     if aFlat then begin
////       d  := d and (not WS_BORDER);
//       ed := ed  and (not WS_EX_CLIENTEDGE);
//     end else begin
////       d := d or WS_BORDER;
//       ed := ed or WS_EX_CLIENTEDGE;
//     end;
//     SetWindowLong(aHandle,GWL_STYLE,d);
//     SetWindowLong(aHandle,GWL_EXSTYLE,ed);
     edand := dword(not 0); edor := 0;
     if aFlat then  edand := dword(not WS_EX_CLIENTEDGE)
              else  edor  :=      WS_EX_CLIENTEDGE;
     SetStyle(1,edand,edor);

  end else begin
//     d := GetWindowLong(Handle,GWL_STYLE);
//     if d <> 0 then
//     begin
//      d := d and (not BS_FLAT);
//      if value = true then d := d or BS_FLAT;
//      SetWindowLong(aHandle,GWL_STYLE,d);
//    end;
     dand := dword(not BS_FLAT);
     dor := 0;
     if value = true then dor := BS_FLAT;
     SetStyle(0,dand,dor);

  end;
  UpdateWindow;
end;

procedure BTWindow.SetFocus;
begin
  if aHandle <> 0 then windows.SetFocus(aHandle);
end;


procedure BTWindow.SetWinClipping(ChildClip,SubClip:Boolean);
var dand,dor:dword;
begin
 dand := dword( not (WS_CLIPSIBLINGS or WS_CLIPCHILDREN));
 dor := 0;
 if ChildClip then dor := WS_CLIPCHILDREN;
 if SubClip then dor  := WS_CLIPSIBLINGS;
 SetStyle(0,dand,dor);
end;



{******************************************************************************}



function ctl_defProc(aWindow: HWnd; AMessage: UINT; WParam : WPARAM;
                         LParam: LPARAM): LRESULT; stdcall;
var obj:dword;
    ctl,I:BTControl;
    done :dword;
    res : LRESULT;
    pdc:HDC;
    ps:PAINTSTRUCT;
    re:Trect;
    brush:HBRUSH;
    bypasskey:dword;
begin

   res := 0;
   Obj := GetProp(aWindow,'xwndp');
   Ctl := BTControl(GetProp(aWindow,'xctl'));
   done := 0;
   if obj <> 0 then
   begin
     if ctl <> nil then
     begin
         bypasskey := 0;
         if (ctl.ClassType and $20000000) <> 0 then bypasskey := 1;
         if Assigned(ctl.OnOther) then res := ctl.OnOther(aWindow,aMessage,wParam,lParam);
         if res <> 0 then done := 1;
         case aMessage of
            WM_ERASEBKGND: begin
               if ctl.aTransparent = true then
               begin
                  ctl.Parent.Redraw(wParam,ctl.Xpos,ctl.Ypos,ctl.Xlng,ctl.Ylng,$7);
////        re.Left := ctl.Xpos;
////        re.Top := ctl.Ypos;
////        re.Right := ctl.Xpos+ctl.Xlng;
////        re.Bottom := ctl.Ypos+ctl.Ylng;
////          brush :=  CreateSolidBrush(rgb(0,255,0));
////        FillRect(wParam,re,Brush);
//        done := 1;
               end;
            end;
            WM_PAINT:
            begin
//              pdc := BeginPaint(aWindow,ps);
///        re.Left := ctl.Xpos;
///       re.Top := ctl.Ypos;
///       re.Right := ctl.Xpos+ctl.Xlng;
///       re.Bottom := ctl.Ypos+ctl.Ylng;
///          brush :=  CreateSolidBrush(rgb(0,255,0));
///        FillRect(pdc,re,Brush);


//              ctl.Redraw(pdc,ctl.Xpos,ctl.Ypos,ctl.Xlng,ctl.Ylng,$2);
//               I := Ctl.BigParent.Controls;
//               while (I<>nil) do
//               begin
//                  if dword(I) = dword(ctl) then break;
//
//                  //PostMessage(I.Handle,WM_PAINT,0,0);
//                  I := I.NextControl;
//              end;
//              ps.hdc := pdc;
//              ps.
//              EndPaint(aWindow,ps);

            end;
            WM_KEYDOWN:
               begin
                  KBDevent(aMessage,wParam,lParam);
                  case wparam of
                    VK_TAB   :begin
                                 if ( KBDstatus and $1 ) <> 0
                                   then PostMessage(Ctl.Parent.Handle,WM_USER,4,dword(ctl))
                                   else PostMessage(Ctl.Parent.Handle,WM_USER,6,dword(ctl));
                                 done := 1;
                              end;
                    VK_RIGHT,
                    VK_DOWN  :begin
                                 if Bypasskey = 0 then
                                 begin
                                   PostMessage(Ctl.Parent.Handle,WM_USER,6,dword(ctl));
                                   done := 1;
                                 end;
                              end;
                    VK_LEFT,
                    VK_UP    :begin
                                if Bypasskey = 0 then
                                begin
                                 PostMessage(Ctl.Parent.Handle,WM_USER,4,dword(ctl));
                                 done := 1;
                                end;
                              end;
                    VK_RETURN :begin
                                 PostMessage(Ctl.Parent.Handle,WM_USER,5,dword(ctl));
                                 done := 1;
                              end;

                  end;
               end;
            WM_KEYUP,WM_CHAR:
               begin
                  KBDevent(aMessage,wParam,lParam);
                  if wparam = VK_TAB then
                  begin
                     done := 1;
                  end;
               end;
            WM_SETCURSOR :
               begin
                  SetCursor(ctl.Cursor.Handle);
                  done := 1
               end;
         end;
     end;
     if done = 0 then  res := CallWindowProc(pointer(Obj), aWindow, AMessage, WParam, LParam);
   end else  res := DefWindowProc(aWindow, AMessage, WParam, LParam);
   ctl_defProc := res;
end;



constructor BTControl.Create(Par:BTWindow);
begin
   inherited;
   Xcor := 0;
   Ycor := 0;
   aTransparent := false;
   Parent := BTForm(Par);
   BigParent := Parent;
   if assigned(parent) then
   begin
      if Parent.Control then
      begin
        repeat
           Xcor := Xcor + BigParent.Xpos;
           Ycor := Ycor + BigParent.Ypos;
           BigParent := BigParent.Parent;
        until (BigParent = nil) or (BigParent.Control = false);
      end;
   end;
   ClassName := '';
   SubClass := 0;
   OnClick := nil;
   DefByFocus := 0;
//   Cursor.Preset := pcArrow;     // set in windows
//   aBrush.Handle := GetSysColorBrush(COLOR_BTNFACE);  // set in windows
   Tab := 0;
   id := 0;
end;


destructor  BTControl.Destroy;
var ctr,I:BTWindow;
begin
   RemoveProp(aHandle,'xwndp');
   RemoveProp(aHandle,'xctl');
   // unlink control from parent list
   if Assigned(BigParent) then
   begin
      ctr := BigParent.Childs;
      I := nil;
      while (ctr <> nil) do
      begin
         if ctr.NextChild = self then I := ctr;
         ctr := ctr.NextChild;
      end;
      if I <> nil then
      begin
         I.NextChild := self.NextChild;
      end else begin
         if self = BigParent.Childs then BigParent.Childs := self.NextChild;
      end;
   end;
   inherited;
end;


procedure   BTControl.GetHandle;
var dd:dword;
    a:BTwindow;
    x,y,xl,yl:longint;
begin
   if not assigned(Parent) then exit;

     x:=0; y:=0;      xl:=0; yl:=0;

     ID := getProp(BigParent.handle,'ctrlid');
     if aHandle = 0 then
     begin
        // Get New ID
        RemoveProp(BigParent.handle,'ctrlid');
        inc(ID);
        SetProp(BigParent.handle,'ctrlid',ID);
        // Link to list in window
        a := BigParent.Childs;
        BigParent.Childs := self;
        self.NextChild := a;
     end else begin
        x := Xpos;
        y := Ypos;
        xl := Xlng;
        yl := Ylng;
     end;


      if (ClassType and $80000000) = 0 then
         SubClass :=  WS_CHILD or WS_VISIBLE  or WS_TABSTOP or SubClass or WS_CLIPSIBLINGS ; // or WS_CLIPCHILDREN
      if (ClassType and $40000000) <> 0 then ID := 0; // skip ID

      Handle := CreateWindowEx(0,
                   Pchar(ClassName),
                   '',
                   SubClass,
                   x, y,
                   xl, yl,
                   Parent.Handle,
                   ID,
                   0, //GetModuleHandle(0)
                   nil);
      windows.SetFocus(Parent.Handle);
      BringWindowToTop(Handle);
   //   if Parent.Control then ClassType := ClassType or 4;
   //  SetWindowOrgEx(Handle,Xpos,Ypos,nil);

      dd := GetWindowLong(Handle,GWL_WNDPROC);
      if dd <> 0 then
      begin
         SetProp(Handle,'xctl',dword(self));
         SetProp(Handle,'xwndp',dd);
         SetWindowLong(Handle,GWL_WNDPROC,dword(@ctl_defproc));
      end else begin
          // Error
      end;


      Control := true; // mark this window as control
end;


Procedure BTControl.SetTransparent(value:boolean);
begin
  if value = aTransparent then Exit;
  aTransparent := value;
  if aTransparent then
  begin
     aBrush.Style := bbsClear;
     SetWinClipping(true,false);
  end else begin
     aBrush.Style := bbsSolid;
     SetWinClipping(true,TRUE);
  end;
end;


{******************************************************************************}

constructor BTButton.Create(par:BTWindow);
begin
  inherited;
  aDefault := false;
  ClassName := 'button';
  ClassType := 1;
  SUBClass  := BS_PUSHBUTTON;
  GetHandle;
end;

Destructor BTButton.Destroy;
begin
  inherited Destroy;
end;

procedure  BTButton.SetDefault(value:boolean);
var dand,dor:dword;
    I:BTControl;
begin
  if value = aDefault then Exit;
  aDefault := value;
  dand := dword(not ( BS_DEFPUSHBUTTON or BS_PUSHBUTTON));
  if aDefault then dor := BS_DEFPUSHBUTTON
              else dor := BS_PUSHBUTTON;
  SetStyle(0,dand,dor);
end;


{******************************************************************************}


constructor BTLabel.Create(par:BTWindow);
begin
  inherited;
   aAlignment := taLeft;
  ClassName := 'static';
  ClassType := 2;
  SUBClass  := SS_LEFT;
  GetHandle;
end;


Destructor BTLabel.Destroy;
begin
  inherited;
end;

Procedure BTLabel.SetAlignment(value:BTTextAlignment);
var d:dword;
begin
  if Handle = 0 then Exit;
  if aAlignment = value then exit;
  aAlignment := value;
  d := GetWindowLong(aHandle,GWL_STYLE);
  d := d and (not (SS_LEFT or SS_CENTER or SS_RIGHT));
  if value = taLeft   then d := d or SS_LEFT;
  if value = taCenter then d := d or SS_CENTER;
  if value = taRight  then d := d or SS_RIGHT;
  SetWindowLong(aHandle,GWL_STYLE,d);
  UpdateWindow;
end;




{******************************************************************************}


constructor BTCheckBox.Create(par:BTWindow);
begin
  inherited;
  ClassName := 'button';
  ClassType := 2;
  SUBClass  := BS_AUTOCHECKBOX  or WS_TABSTOP;
  GetHandle;
end;


Destructor BTCheckBox.Destroy;
begin
  inherited;
end;


procedure BTCheckBox.setCBstate(value:boolean);
var s:dword;
begin
 s:=BST_CHECKED;
 if value = false then s := BST_UNCHECKED;
 SendMessage(handle,BM_SETCHECK,s,0);
end;

function BTCheckBox.getCBstate:boolean;
begin
  if (SendMessage(handle, BM_GETCHECK, 0, 0) = BST_CHECKED ) then getCBstate := true
                                                             else getCBstate := false;
end;


{******************************************************************************}


constructor BTRadioButton.Create(par:BTWindow);
begin
  inherited;
  ClassName := 'button';
  ClassType := 2;
  SUBClass  := BS_AUTORADIOBUTTON or WS_TABSTOP;
  GetHandle;
end;


Destructor BTRadioButton.Destroy;
begin
  inherited;
end;


procedure BTRadioButton.setCBstate(value:boolean);
var s:dword;
begin
 s:=BST_CHECKED;
 if value = false then s := BST_UNCHECKED;
 SendMessage(handle,BM_SETCHECK,s,0);
end;

function BTRadioButton.getCBstate:boolean;
begin
  if (SendMessage(handle, BM_GETCHECK, 0, 0) = BST_CHECKED ) then getCBstate := true
                                                             else getCBstate := false;
end;



{******************************************************************************}

constructor BTGroupBox.Create(par:BTWindow);
begin
  inherited;
  aTransparent := true;  // The Groupbox is transparent by default
  ClassName := 'button';
  ClassType := 2;
  SUBClass  := BS_GROUPBOX;
  GetHandle;
end;



Destructor BTGroupBox.Destroy;
begin
  inherited;
end;




{******************************************************************************}


constructor BTComboBox.Create(par:BTWindow);
begin
  inherited;
  aSorted := false;
  aEdit := true;
  aVScroll := true;
  aHScroll := false;
  ClassName := 'combobox';
  ClassType := 6;
  SUBClass  := CBS_DROPDOWN or CBS_AUTOHSCROLL or WS_TABSTOP or WS_VSCROLL;
  GetHandle;
end;

Destructor BTComboBox.Destroy;
begin
  inherited Destroy;
end;

procedure BTComboBox.SetSorted(value:boolean);
var mand,mor:dword;
begin
   aSorted := value;
   mand := dword(not (CBS_SORT));
   mor  := CBS_SORT;
   if not Value then mor := 0;
   SetStyle(0,mand,mor);
end;

procedure BTComboBox.SetCanEdit(value:boolean);
var mand,mor:dword;
begin
   aEdit := value;
   mand := dword(not (CBS_DROPDOWN or CBS_DROPDOWNLIST));
   mor  := CBS_DROPDOWNLIST;
   if Value then mor := CBS_DROPDOWN;
   SetStyle(0,mand,mor);
end;

procedure BTComboBox.Set_VSC(value:boolean);
var mand,mor:dword;
begin
   aVScroll := value;
   mand := dword(not (WS_VSCROLL));
   mor  := WS_VSCROLL;
   if not Value then mor := 0;
   SetStyle(0,mand,mor);
end;

procedure BTComboBox.Set_HSC(value:boolean);
var mand,mor:dword;
begin
   aHScroll := value;
   mand := dword(not (WS_HSCROLL));
   mor  := WS_VSCROLL;
   if not Value then mor := 0;
   SetStyle(0,mand,mor);
end;

function  BTComboBox.Add(S: string): Integer;
begin
  Result := SendMessage(aHandle, CB_ADDSTRING, 0, Longint(PChar(S))) + 1;
end;

procedure BTComboBox.Clear;
begin
  SendMessage(aHandle, CB_RESETCONTENT, 0, 0);
end;

procedure BTComboBox.Delete(Index: Integer);
begin
  if index > 0 then SendMessage(aHandle, CB_DELETESTRING, Index - 1, 0);
end;

procedure BTComboBox.Insert(Index: Integer; S: string);
begin
  if Index > 0 then SendMessage(aHandle, CB_INSERTSTRING, Index - 1, Longint(PChar(S)));
end;

procedure BTComboBox.Put(Index: Integer; S: string);
var oldIndex:Integer;
begin
  Delete(Index);
  Insert(Index,S);
end;

function  BTComboBox.Get(Index: Integer): string;
var Len,i  : dword;
    xText: array[1..4096] of Char;
    s :string;
begin
   s := '';
   if index = 0 then s := self.Caption;
   if Index > 0 then
   begin
       Len := SendMessage(aHandle, CB_GETLBTEXTlen, Index, 0);
       SendMessage(aHandle, CB_GETLBTEXT, Index, Longint(@xText));
       for i:= 1 to Len do s := s + xText[i];
   end;
   Get := '';
end;


function  BTComboBox.GetCount: dword;
begin
  Result:=SendMessage(aHandle, CB_GETCOUNT, 0, 0);
end;

procedure BTComboBox.SetSelect(I:dword);
begin
   if i = 0 then self.Caption := ''
            else SendMessage(aHandle, CB_SETCURSEL , i-1, 0);
end;

function  BTComboBox.GetSelect:dword;
begin
  Result := SendMessage(aHandle, CB_GETCURSEL, 0, 0) + 1;
end;





{******************************************************************************}

constructor BTEditBox.Create(par:BTWindow);
begin
  inherited;
  OnChange := nil;
  OnEnter  := nil;

  aAlignment := taLeft;
  PassWordChar :='*';
  aMultiLine := false;
  aEditMode := emNormal;
  ClassName := 'edit';
  ClassType := $20000000;
  SUBClass  := ES_AUTOHSCROLL or ES_LEFT or WS_BORDER;
  BKColor := rgb(255,255,255);
  Color := 0;
  RecreateWnd;
end;


Destructor BTEditBox.Destroy;
begin
  inherited;
end;


procedure  BTEditBox.RecreateWnd;
begin
   if Handle <> 0 then
   begin
      SendMessage(Handle,WM_Close,0,0);
      //windows.DestroyWindow(aHandle);
   end;
   GetHandle;
end;


procedure BTEditBox.SetMulLine(value:boolean);
var dand,dor:dword;
    S:string;
begin
   aMultiLine := value;
   SUBClass := SubClass and (not ( ES_MULTILINE or ES_WANTRETURN or ES_AUTOVSCROLL or ES_AUTOHSCROLL or WS_VSCROLL or WS_HSCROLL));
   if aMultiLine then  SUBClass  := SUBClass or (ES_MULTILINE or ES_WANTRETURN or ES_AUTOVSCROLL or ES_AUTOHSCROLL or WS_VSCROLL or WS_HSCROLL)
                 else  SUBClass  := SUBClass or ES_AUTOHSCROLL;
   s := Caption;
   RecreateWnd;
   Caption := s;
end;


procedure  BTEditBox.SetEditMode(value:BTEditMode);
begin
   if aEditMode = value then Exit;
   aEditMode := value;
   SendMessage(Handle, EM_SETPASSWORDCHAR, 0, 0 );
   case aEditMode of
     emNormal : SetStyle(0,not(dword(ES_UPPERCASE or ES_LOWERCASE or ES_NUMBER)) , 0 );
     emNumber : SetStyle(0,not(dword(ES_UPPERCASE or ES_LOWERCASE)), ES_NUMBER);
     emUpCase : SetStyle(0,not(dword(ES_NUMBER or ES_LOWERCASE)), ES_UPPERCASE);
     emLoCase : SetStyle(0,not(dword(ES_NUMBER or ES_UPPERCASE)), ES_LOWERCASE);
     emPassword : begin
         SetStyle(0,not(dword(ES_UPPERCASE or ES_LOWERCASE or ES_NUMBER)) , 0 );
         SendMessage(Handle, EM_SETPASSWORDCHAR, dword(PassWordChar), 0 );
     end;
   end;
end;

Procedure BTEditBox.SetAlignment(value:BTTextAlignment);
var s:string;
begin
  if aAlignment = value then exit;
  aAlignment := value;
  SUBClass := SubClass and (not ( ES_LEFT or ES_CENTER or ES_RIGHT));
  case aAlignment of
   taLeft : SUBClass  := SUBClass or ES_LEFT;
   taRight : SUBClass  := SUBClass or ES_RIGHT;
   taCenter : SUBClass  := SUBClass or ES_CENTER;
  end;
  s := Caption;
  RecreateWnd;
  Caption := s;
end;



{******************************************************************************}


constructor BTListBox.Create(par:BTWindow);
begin
  inherited;
  ClassName := 'listbox';
  ClassType := 1;
  SUBClass  := LBS_NOTIFY; // or WS_BORDER;
  BKColor := rgb(255,255,255);
  Color := 0;
  GetHandle;
end;


Destructor BTListBox.Destroy;
begin
  inherited;
end;

function  BTListBox.Add(S: string): Integer;
begin
   s := s + #0;
   Add := SendMessage(Handle, LB_ADDSTRING, 0 ,dword(@s[1]));
end;


{******************************************************************************}

constructor BTScrollBar.Create(par:BTWindow);
begin
  inherited;
  ClassName := 'scrollbar';
  SUBClass  := SBS_VERT or WS_TABSTOP;

  aDir := sbdVertical;
  aPos := 0;
  aMin := 0;
  aMax := 255; // the max is 65535
  aAuto := false;
  aAttached := false;
  aAtcHandle := 0;
  OnLineUp    := nil;
  OnLineDown  := nil;
  OnPageUp    := nil;
  OnPageDown  := nil;
  OnMovePos   := nil;
  OnChange    := nil;

  if par <> nil then
  begin
     GetHandle;

     SetScrollRange(Handle,SB_CTL,aMin,aMax,True);
     SetScrollPos(Handle,SB_CTL,0,True);
//  aVisible := true;
  end;
end;


Destructor BTScrollBar.Destroy;
begin
  inherited;
end;



procedure BTScrollBar.SetSBpos(value:dword);
begin
  if aAttached then
  begin
     aPos := value;
     if  aDir = sbdVertical then SetScrollPos(aAtcHandle,SB_VERT,value,True);
     if  aDir = sbdHorizontal then SetScrollPos(aAtcHandle,SB_HORZ,value,True);
  end else begin
     if aHandle = 0 then Exit;
     aPos := value;
     SetScrollPos(Handle,SB_CTL,value,True);
  end;
end;

procedure BTScrollBar.SetSBminpos(value:dword);
begin
  if aAttached then
  begin
     aMin := value;
     if  aDir = sbdVertical then SetScrollRange(aAtcHandle,SB_VERT,aMin,aMax,True);
     if  aDir = sbdHorizontal then SetScrollRange(aAtcHandle,SB_HORZ,aMin,aMax,True);
  end else begin
     if aHandle = 0 then Exit;
     aMin := value;
     SetScrollRange(Handle,SB_CTL,aMin,aMax,True);
  end;
end;


procedure BTScrollBar.SetSBmaxpos(value:dword);
begin
  if aAttached then
  begin
     aMax := value;
     if  aDir = sbdVertical then SetScrollRange(aAtcHandle,SB_VERT,aMin,aMax,True);
     if  aDir = sbdHorizontal then SetScrollRange(aAtcHandle,SB_HORZ,aMin,aMax,True);
  end else begin
     if aHandle = 0 then Exit;
     aMax := value;
     SetScrollRange(Handle,SB_CTL,aMin,aMax,True)
  end;
end;


procedure BTScrollBar.SetDirection(value:BTScrollBarDirection);
var dand, dor:dword;
begin
  if aAttached = false then
  begin
    if aDir = value then Exit;
    if Handle = 0 then Exit;
    aDir := value;
    dand := dword(not SBS_VERT or SBS_HORZ);
    if aDir = sbdVertical then dor := SBS_VERT;
    if aDir = sbdHorizontal then dor :=  SBS_HORZ;
    SetStyle(0,dand,dor);
    UpdateWindow;
  end;
end;

procedure BTScrollBar.AttachToWindow(wHandle:dword; scdir:BTScrollBarDirection);
begin
  if wHandle = 0 then Exit;
  aAttached := true;
  aDir := scdir;
  aAtcHandle := wHandle;
  if  aDir = sbdVertical then SetScrollRange(aAtcHandle,SB_VERT,aMin,aMax,True);
  if  aDir = sbdHorizontal then SetScrollRange(aAtcHandle,SB_HORZ,aMin,aMax,True);
  // up script auto show them
  SetVisible(false);
end;

procedure BTScrollBar.SetVisible(value:boolean);
var d:dword;
begin
  if aAttached then
  begin
     d := GetWindowLong(aAtcHandle,GWL_STYLE);
     if d <> 0 then
     begin
        aVisible := value;
        if  aDir = sbdVertical then
        begin
           d := d and (not WS_VSCROLL);
           if value then d := d or WS_VSCROLL;
        end;
        if  aDir = sbdHorizontal then
        begin
           d := d and (not WS_HSCROLL);
           if value then d := d or WS_HSCROLL;
        end;
        SetWindowLong(aAtcHandle,GWL_STYLE,d);
        SetWindowPos(aAtcHandle,0,0,0,0,0,
           SWP_NOMOVE or SWP_NOSIZE or SWP_NOZORDER or SWP_FRAMECHANGED);
        //InvalidateRect(aPhandle,nil,true);
//        windows.UpdateWindow(aPhandle);
     end;
  end else begin
     aVisible := value;
     Inherited SetVisible(value);
  end;
end;


///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
///
///  F O R M S
///
///


constructor BTForm.Create;
begin
  inherited;
  aFlat := true;
  aBitmap      := nil;
  aBitMapMode  := 0;


  OnKey        := nil;   // procedure(a,b,c:dword);
  OnMouse      := nil;   // procedure(x,y:dword);
  OnMouseDown  := nil;   // procedure(x,y,b:dword);
  OnMouseUp    := nil;   // procedure(x,y,b:dword);
  OnClick      := nil;   // procedure(x,y,b:dword);
  OnDBLClick   := nil;   // procedure(x,y,b:dword);
  OnActivate   := nil;   // procedure;
  OnDeactivate := nil;   // procedure;
  OnCreate     := nil;   // procedure;
  OnDestroy    := nil;   // procedure;
  OnSize       := nil;   // procedure(x,y:dword);

  HScroll  := BTScrollBar.Create(nil); // with nil to be ready for attach
  VScroll  := BTScrollBar.Create(nil);


end;

destructor BTForm.Destroy;
var ctl,I:BTwindow;
begin
  HScroll.Free; //Destroy;
  VScroll.Free; //Destroy;
  RemoveProp(aHandle,'form');   //??? did I have handle hare
  RemoveProp(aHandle,'ctrlid');  //???
  // unlink if some left
  ctl := Childs;
  while (ctl <> nil) do
  begin
    ctl := ctl.NextChild;
    I := ctl;
    I.Free;
  end;
  Childs := nil;
  inherited Destroy;
end;


procedure BTForm.GetHandle(fParent:BTForm);
var
 ops :dword;
 parh:dword;
begin
  if aHandle <> 0 then Exit;

  parh := 0;
  ops := 0;
  if fParent <> nil then
  begin
    Parent := fParent;
    parh := fParent.Handle;
    ops := WS_CHILD;
  end;

  aBicons := [biSys,biMax,biMin];
  aWState := wsNormal;
   ops := ops or WS_POPUP or WS_CAPTION  or WS_CLIPSIBLINGS
   //or WS_CLIPCHILDREN //I dont need this flag to clip child I will do that
   // to have Transparent controls

   or WS_SYSMENU or WS_MAXIMIZEBOX or WS_MINIMIZEBOX
   or WS_BORDER or WS_THICKFRAME;
  Handle := CreateWindow('BF_win',nil,
                           ops,
                           8000,8000,0,0,
//                           aXpos,
//                           aYpos,
//                           aXlng,
//                           aYlng,
                           parh,
                           0,
                           0, //GetModuleHandle(nil),{ hInst, }
                           nil);
  if aHandle <> 0 then
  begin
    SetProp(aHandle,'form',dword(self));
    SetProp(aHandle,'ctrlid',1);
    HScroll.AttachToWindow(Handle,sbdHorizontal);
    VScroll.AttachToWindow(Handle,sbdVertical);
    aVisible := false; // I need show
  end else begin
    // Fatal error
    //TODO
  end;
end;


procedure BTForm.Close;
begin
  PostMessage(aHandle,WM_Close,0,0);
end;


procedure BTForm.CreateForm(Par:BTForm);
begin
  if Self <> BApplication.aMainForm then
  begin
     GetHandle(par);
     if Assigned(OnCreate) then OnCreate;
  end;
end;


procedure BTForm.CreateFormIndirect(parentHandle:dword);
begin
  Parent := BTForm.Create(NIL);
  Parent.handle := parentHandle;
  GetHandle(parent);
  if Assigned(OnCreate) then OnCreate;
end;


procedure BTForm.ShowInside;
var d:dword;
begin
     if Parent <> nil then
     begin
        d := GetWindowLong(Handle,GWL_STYLE);
        if d <> 0 then
        begin
           d := d and ( not WS_CHILD);
           SetWindowLong(Handle,GWL_STYLE,d);
           windows.SetParent(Handle,Parent.Handle);
        end;
     end;
     Show;
end;


procedure BTForm.ShowModal;
var d:dword;
    ph:dword;
    pf:BTForm;
    old:BTForm;
begin
  if StandAloneMode = 0 then
  begin
     old := BApplication.ForceMainForm(Parent);
  end;
  if BApplication.aMainForm <> nil then
  begin
     ph := Parent.Handle;
     Show;
     d := GetWindowLong(Handle,GWL_STYLE);
     if d <> 0 then
     begin
          d := d and ( not WS_CHILD);
          SetWindowLong(Handle,GWL_STYLE,d);
             pf := Parent;
             while (pf <> nil) do
             begin
               Pf.Enabled := false;
               pf := pf.Parent;
             end;
          ModalOn := Handle;
          BApplication.Runner;
          ModalOn := 0;
//          if StandAloneMode = 1 then
//          begin
             pf := Parent;
             while (pf <> nil) do
             begin
               Pf.Enabled := true;
               pf := pf.Parent;
             end;
//          end else begin
//             pf:=BTForm.Create;
//             pf.handle := Parent.Handle;  // i have one parent
//             k := windows.GetAncestor(pf.Handle,GA_ROOT);
//             while (pf.handle <> 0) do
//             begin
//               if k = pf.Handle then k := 0;
//               if k <> 0 then Pf.Enabled := true;
//               pf.handle := windows.GetAncestor(pf.Handle,GA_PARENT);
//               d := GetWindowLong(Handle,GWL_STYLE);
//               if (d and WS_CHILD) = 0 then pf.Handle := 0;
//             end;
//             pf.Destroy;
//          end;
     end;
     SetActiveWindow(PH);
  end;
  if StandAloneMode = 0 then
  begin
     BApplication.ForceMainForm(old);
  end;
end;


procedure BTForm.SetBorderIcons(value:BTBorderIcons);
var d:dword;
begin
  if aHandle <> 0 then
  begin
    aBicons := value;
    d := GetWindowLong(aHandle,GWL_STYLE);
    if d <> 0 then
    begin
       d := d and ( not ( WS_SYSMENU or WS_MAXIMIZEBOX or WS_MINIMIZEBOX));
       if biSys in aBicons then d := d or WS_SYSMENU;
       if biMax in aBicons then d := d or WS_MAXIMIZEBOX;
       if biMin in aBicons then d := d or WS_MINIMIZEBOX;
       SetWindowLong(aHandle,GWL_STYLE,d);
       if Visible then SetWindowPos(aHandle,0,0,0,0,0,
                           SWP_NOMOVE or SWP_NOSIZE or SWP_NOZORDER or SWP_FRAMECHANGED);
    end;
  end;
end;


procedure BTForm.SetWindowState(value:BTWindowState);
begin
  if aHandle <> 0 then
  begin
    aWstate := value;
    case Value of
          wsNormal    : ShowWindow(aHandle, SW_RESTORE);
          wsMaximized : ShowWindow(aHandle, SW_SHOWMAXIMIZED);
          wsMinimized : ShowWindow(aHandle, SW_SHOWMINIMIZED);
    end;
    if aVisible then windows.UpdateWindow(aHandle);
  end;
end;


procedure BTForm.AttachPicture(b:BTBitmap; mode:dword);
begin
  aBitMap := b;
  aBitMap.Xlng := aXlng;
  aBitMap.Ylng := aYlng;
  // 0 - nithing
  // 1 - resize
  // 2 - stretch;
  aBitMapMode  := mode;
end;


procedure BTForm.SetNewMenu(value:BTMenu);
begin
  if aHandle <> 0 then windows.SetMenu(aHandle,value.Handle);
end;

{******************************************************************************}
//// T O O L S

constructor BTTimer.Create(Par:BTWindow);
var s:string;
begin
   aFormHandle  := Par.Handle;
   aID := getProp(aFormHandle,'ctrlid');
   RemoveProp(aFormHandle,'ctrlid');
   inc(aID);
   SetProp(aFormHandle,'ctrlid',aID);
   aHandle      := 0;
   aTime        := 1000; {1 S}
   OnTimer      := nil;
   str(aID,s);
   aName        := 'tmr'+s;
   Enabled      := true;
   SetProp(aFormHandle,pchar(aName),dword(self));
   StartTimer;
end;

destructor BTTimer.Destroy;
begin
   if aHandle <> 0 then StopTimer;
   RemoveProp(aFormHandle,pchar(aName));
   inherited;
end;

procedure  BTTimer.SetInterval(value:dword);
begin
   if aHandle <> 0 then StopTimer;
   aTime := value;
   StartTimer;
end;

procedure  BTTimer.StartTimer;
begin
   if aHandle <> 0 then Exit;
   aHandle := windows.SetTimer(aFormHandle, aID, aTime, nil);
end;

procedure  BTTimer.StopTimer;
begin
   windows.KillTimer(aFormHandle, aID);
   aHandle := 0;
end;

{******************************************************************************}
//// A P P L I C A T I O N

Constructor BTApplication.Create;
var WndClass    : TWndClass;
begin
 aMainForm := nil;
 OnIdle := nil;
 Cursor := BTcursor.Create;
 aBreak := false;

  FillChar(WndClass,SizeOf(WndClass),0);
  WndClass.hInstance := 0; //hInstance;
  with WndClass do begin
   Style := CS_VREDRAW or CS_HREDRAW;
   lpfnWndProc := @Form_WindowProc; // direct link
   hIcon := 0; //LoadIcon(hInstance,'MAINICON');
   hCursor := LoadCursor(0, IDC_ARROW);
   hbrBackground := 0; //GetSysColorBrush(COLOR_BTNFACE); // default
   lpszClassName := 'BF_win';
  end;
  RegisterClass(WndClass);  //TODO error check
end;

Destructor  BTApplication.Destroy;
begin
 inherited Destroy;
 Cursor.destroy;
 UnregisterClass('BF_win',0);
end;


procedure BTApplication.Runner;
var a:boolean;
begin
   a := aBreak;
   repeat
      ProcessMessages;
   until aBreak;
   aBreak := a;
end;


procedure BTApplication.ProcessMessages;
var
  aMSG : MSG;
begin
    //??BUG TODO  if aMainForm = nil then Exit;
{$IFDEF FPC }
         if PeekMessage(@amsg,0,0,0,PM_NOREMOVE or PM_NOYIELD) = true then
         begin
            if GetMessage(@amsg,0,0,0) = true then
            begin
               TranslateMessage(@amsg);
               DispatchMessage(@amsg);
{$ELSE}
// DELPHI
         if PeekMessage(amsg,0,0,0,PM_NOREMOVE or PM_NOYIELD) = true then
         begin
            if GetMessage(amsg,0,0,0) = true then
            begin
               TranslateMessage(amsg);
               DispatchMessage(amsg);
{$ENDIF}
            end else begin
               aBREAK := true;
            end;
         end else begin
            { OnIdle; }
            if Assigned(OnIdle) then  OnIdle;
         end;
end;



Procedure BTApplication.Terminate;
begin
  PostMessage(aMainForm.aHandle,WM_CLOSE,0,0);
end;


function BTApplication.ForceMainForm(frm:BTForm):BTForm;
var res:BTform;
begin
 res := aMainForm;
 aMainForm := frm;
 ForceMainForm := res;
end;


Procedure BTApplication.Run;
begin
   if aMainForm = nil then Exit;
   aMainForm.Show;
   if aMainForm.Handle <> 0 then
   begin
     // aMainForm := MainForm;
      FatherForm := aMainForm;
      repeat
         ProcessMessages;
      until aBreak;
   end;
end;


procedure BTApplication.CreateForm(InstanceClass: BTFormClass; var Reference);
var
  Instance: BTWindow;
begin
  Instance := BTWindow(InstanceClass.NewInstance);
  BTWindow(Reference) := Instance;
  if Instance <> nil then
  begin
     Instance.Create(nil);
     aMainForm := BTForm(Instance);
     aMainForm.GetHandle(nil);
     if Assigned(aMainForm.OnCreate) then aMainForm.OnCreate;
  end;
end;



Initialization
 KBDstatus := 0;
 StandAloneMode := 1;
 ModalOn := 0;
 FormName := 0;
 BApplication:=BTApplication.Create;
Finalization
// Application.Destroy;
 BApplication.Free;

end.