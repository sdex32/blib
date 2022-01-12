(*
	BCanvas   version 1.8
	Copyright (C) 2005-2008  SAB labs

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.


  author Bogdan Stoyanov

  sdex32@yahoo.com

*)

{///  TODO /////////////////////////////////////////////////////////////////////


!!!  BitsPerPixel := GetDeviceCaps(DC, BITSPIXEL);

!!! Calculatins with shift and zoom TO BE with MATRIX


  Gradient Shift factor + radial diamont and so

  Filter region, laplace

  Filters Blur,Glow,Dither error
           Emboss in out grey
  Filters todo add DistortionGlass
                   PointilizeEffect
                   Sobel

  Pen stamp mode tith Bitmaps

  test blit function
  add rgb to hsv
  Paths Fill & BeginPath
  Optimization
    !!!  Font To Create Before GetHandle
  AspectRatio
  Write Logic
  Mask Draw    MaskBlt
  Angle in alpha textout
  assign for Pen,Brush,Font
  Zoom + shift in canvas
  Cliping with global and fillshape
  user Clipping
  char set to font
  more shapes and adjust existing evritska zwezada
  shape with fillshape error  in 4 colors
  CORECT ALPHA ON SHAPE artefacts
  Gif loader
  crop to bmp


  not working on win98  !!!!!!!!!!!!!!! :(

  Rectangle win98 with Pen ok  no Pen size is with -1 ???? xlng ylng

  Copy dec(Xl,YL) to all not only from rectangle


  size allign 4     (((a-1) shr 2 ) + 1) shl 2   for surface to put in surface

///////////////////////////////////////////////////////////////////////////////}



unit BCanvas;
{$APPTYPE GUI }



/// if FPC is not defined DELPHI usage
{$IFDEF FPC }
{$MODE DELPHI }

{*********** CODE GENERATION ****************}
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
uses windows,BSurface {$IFDEF FPC};{$ELSE},messages,shellapi;{$ENDIF}


Type
{$IFNDEF FPC}
      RECT = TRECT; // for DELPHI
{$ENDIF}
      BTFontStyles = set of (bfsBold, bfsItalic, bfsUnderline, bfsAntialiased);
      BTBrushStyle=(bbsSolid, bbsClear, bbsPattern, bbsBitMap, bbsGradient,
                    bbsTransparentPattern);
      BTPenStyle = (bpsSolid, bpsDash, bpsDot, bpsDashDot, bpsDashDotDot, bpsClear,
                    bpsInsideFrame);
      BTFillStyle = (bfsSurface, bfsBorder);
      BTPenMode = (bpmBlack, bpmWhite, bpmNop, bpmNot, bpmCopy, bpmNotCopy,
                  bpmMergePenNot, bpmMaskPenNot, bpmMergeNoBTPen, bpmMaskNoBTPen, bpmMerge,
                  bpmNotMerge, bpmMask, bpmNotMask, bpmXor, bpmNotXor);


      BTPoint5  = record
         X,Y,Z,U,V : longint;
      end;


      BTPen = class
      private
        aDoit       : boolean;
        aAlpha      : dword;
        aColor      : dword;
        aStyle      : BTPenStyle;
        aWidth      : dword;
        aMode       : BTPenMode;
        aHandle     : dword;
        function    GetHandle:dword;
        procedure   SetHandle(value:dword);
        procedure   SetColor(Value:dword);
        procedure   SetWidth(Value:dword);
        procedure   SetStyle(value:BTPenStyle);
        procedure   SetMode(value:BTPenMode);
      public
        OnChange    : procedure(obj:BTPen) of object;
        CloseFigure : boolean;
        constructor Create;
        Destructor  Destroy; override;
        procedure   Assign(p:BTPen);
        property    Handle :dword  read GetHandle write SetHandle;
        property    Color  :dword  read aColor write SetColor;
        property    Style  :BTPenStyle read aStyle write SetStyle;
        property    Width  :dword  read aWidth write SetWidth;
        property    Mode   :BTPenMode read aMode write SetMode;
        property    Alpha  :dword read aAlpha write aAlpha;
      end;

      BTBitmap = class;

      BTBrush = class
      private
        aDoit       : boolean;
        aInvPattern : boolean;
        aAlpha      : dword;
        aTrans      : boolean;
        aBitMap     : BTBitmap;
        aDrawMod    : dword;
        aPattern    : array [0..7] of word;
        aColor      : dword;
        aColor2     : dword;
        aColor3     : dword;
        aColor4     : dword;
        aPreset     : dword;
        aStyle      : BTBrushStyle;
        aHandle     : dword;
        function    GetHandle:dword;
        procedure   SetHandle(value:dword);
        procedure   SetColor(Value:dword);
        procedure   SetColor2(Value:dword);
        procedure   SetColor3(Value:dword);
        procedure   SetColor4(Value:dword);
        procedure   SetStyle(value:BTBrushStyle);
        procedure   SetPreset(Value:dword);
        procedure   SetPattern(Value:pointer);
        procedure   SetTrans(Value:boolean);
      public
        OnChange    : procedure(obj:BTBrush) of object;
        constructor Create;
        Destructor  Destroy; override;
        procedure   Assign(b:BTBrush);
        procedure   Gradient(ColorA,COlorB,Direction:dword);
        procedure   Gradient4(ColorA,COlorB,ColorC,ColorD:dword);
        procedure   AttachBitmap(BMP:BTBitmap; DrawMode:dword);
        property    Handle :dword  read GetHandle write SetHandle;
        property    Color  :dword  read aColor write SetColor;
        property    Color2 :dword  read aColor2 write SetColor2;
        property    Color3 :dword  read aColor3 write SetColor3;
        property    Color4 :dword  read aColor4 write SetColor4;
        property    Style  :BTBrushStyle read aStyle write SetStyle;
        property    Pattern :pointer write SetPattern;
        property    PresetPattern :dword  read aPreset write SetPreset;
        property    InversePattern : boolean read aInvPattern write aInvPattern;
        property    Color2Transparent : boolean read aTrans write SetTrans;
        property    Alpha  : dword read aAlpha write aAlpha;
        property    BMP : BTBitmap read aBitMap;
        property    BMP_DM : dword read aDrawMod;
      end;


      BTFont = class
      private
        aAlpha    : dword;
        aAngle    : dword;
        aHandle   : dword;
        aName     : string;
        aSize     : dword;
        aStyle    : BTFontStyles;
        aColor    : dword;
        procedure  SetName(value:string);
        procedure  SetSize(value:dword);
        procedure  SetStyle(value:BTFontStyles);
        procedure  GetHandle;
        procedure  SetAngle(value:dword);
        procedure  SetByHandle(value:dword);
      public
        OnChange    : procedure(obj:BTFont) of object;
        OutLine     : boolean;
        Fill        : boolean;
        property    Handle:dword read aHandle write SetByHandle;
        property    Name:string read aName write SetName;
        property    Size:dword read aSize write SetSize;
        property    Style:BTFontStyles read aStyle write SetStyle;
        property    Color:dword read aColor write aColor;
        property    Angle:dword read aAngle write SetAngle;
        property    Alpha:dword read aAlpha write aAlpha;
        procedure   Assign(f:BTFont);
        procedure   LoadTTF(TTF_FileName, FontName:string);
        constructor Create;
        destructor  Destroy; override;
      end;



      BTCanvas = class
      private
        aMat : array [0..8] of single;
        aZoom   :single;
        aShiftX :longint;
        aShiftY :longint;
        aAngle  :longint; //0..360;
        aRealPie:boolean;
        aInCall :dword;
        aTriangle : boolean;
        points : array [0..3] of Tpoint;
        aRegion : Hrgn;
        a_Xp, a_Yp, a_Xl, a_Yl: longint; // for buffer
        aX,aY   : longint;
        aOldGDI : boolean; // win95/98/Me/NT -old ; 2000/XP -new
        aHandle : dword; // This is Device Context  (HDC)  :)
        aPen    :BTPen;
        aBrush  :BTBrush;
        aFont   :BTFont;
        aoPen   : dword;
        aoBrush : dword;
        aoFont  : dword;
        aoTextColor : dword;
        aoBkColor   : dword;
        aoStackDC   : dword;
        aClipRGN :HRGN;
        aParent  : dword;
        aBMPown  : BTSurface;
        procedure _point(var X,Y:longint);
        procedure _pointLP(var X,Y,XL,YL:longint);        
        procedure Smooth(h:dword);
        procedure SeBTFont(Value:BTFont);
        procedure SeBTPen(Value:BTPen);
        procedure SeBTBrush(Value:BTBrush);
        procedure SetHandle(Value:dword);
        function  GetHandle:dword;
        procedure BeginGDI;
        procedure EndGDI;
        procedure FillShape;
        procedure BeginPenDraw;
        procedure EndPenDraw(x,y,ax,ay:longint);
        Procedure _TextOutS(aHand:dword; x,y:longint;const s:string);
        procedure CalcPoly(var Points: Array of TPoint; Source: Array of TPoint; aXpos, aYpos, aXlng, aYlng, PCount: longint);
//        procedure _calccord(var a, b :longint);
        procedure _LineEnd(P1,X1,Y1,ax,ay,sz:longint; var NewX1,NewY1:longint);
        procedure _CalcAnim(an:PBTPicAnimation; AnimPic:dword; var sXpos,sYpos:longint);
        Procedure Scan_line( xl,xr,ul,ur,vl,vr,zl,zr: single; y,xres: Longint; texture,Temp: BTBitmap);
        procedure AlphaDraw(X, Y, Xl, Yl, Xp, Yp, pXl, pYl, Alpha :longint; P:BTBitmap);
        procedure AlphaRectangle(Xp, Yp, Xl, Yl, ALpha :longint);
        procedure SetZoom(value:single);
        procedure SetAngle(value:longint);
        procedure SetShiftX(value:longint);
        procedure SetShiftY(value:longint);
        function  _aaLine(X1,Y1,X2,Y2:Integer;Bitmap:TBitmap;StP,EndP:Boolean;An1,An2,An0:single;StartDis:single):single;        
      public
        OnChange    : procedure(obj:BTCanvas) of object;
        OnGDIbegin  : procedure of object;
        OnGDIend    : procedure of object;
        DrawSmooth : boolean;
        ArrowSize  : longword;
        ArrowSolid : boolean;
        DrawScaleFactor : single;
        TextureMapSmooth : dword;
        Constructor Create;
        Destructor Destroy; override;
        procedure  Clear(Color:dword);
        procedure  AttachToWindow(wnd_hand:dword);
        procedure  Solid(XPos,Ypos,Xlng,Ylng:longint; Color:dword);
        procedure  Box(XPos,Ypos,Xlng,Ylng:longint; Color:dword);
        procedure  ColorLine(X1,Y1,X2,Y2:Longint; Color:dword);
        procedure  Blit(X,Y:Longint; Xlng,Ylng,Bpp,Source,Pal:longword);
        function   GetXlng:dword;
        function   GetYlng:dword;
        procedure  Arc(X1, Y1, X2, Y2, X3, Y3, X4, Y4 :longint); overload;
        procedure  Arc(Xc, Yc, StartAngle, StopAngle, Xradius, Yradius :longint); overload;
        procedure  Chord(X1, Y1, X2, Y2, X3, Y3, X4, Y4 :longint); overload;
        procedure  Chord(Xc, Yc, StartAngle, StopAngle, Xradius, Yradius :longint); overload;
        procedure  Circle(Xp, Yp, Xl :longint); overload;
        procedure  Circle(Xc, Yc, StartAngle, StopAngle, Radius :longint); overload;
        procedure  Ellipse(Xp, Yp, Xl, Yl :longint); overload;
        procedure  Ellipse(Xc, Yc, StartAngle, StopAngle, Xradius, Yradius :longint); overload;
        procedure  Curve (x1, y1, x2, y2, x3, y3 : longint);
        Procedure  BezierCurve (x1, y1, x2, y2, x3, y3, x4, y4 : Longint);
        procedure  Rectangle(Xp, Yp, Xl, Yl :longint);
        procedure  Triangle(X1, Y1, X2, Y2, X3, Y3: Longint);
        procedure  Shape(Xpos, Ypos, Xlng, Ylng: Longint; Shape : dword);
        procedure  StarShape(Xpos, Ypos, Xlng, Ylng: Longint; Elements, StartAngle, Typ: longint);
        procedure  MoveTo(X, Y :longint);
        procedure  MoveRel(Dx, Dy : longint);
        procedure  LineTo(X, Y :longint);
        procedure  LineRel(Dx, Dy : longint);
        procedure  Line(X1, Y1, X2, Y2 :longint);
        procedure  Arrow(X1, Y1, X2, Y2, P1, P2 :longint);
        function   GetPixel(X, Y: Longint): dword;
        procedure  SetPixel(X, Y: Longint; Value: dword);
        procedure  Invert(Xp, Yp, Xl, Yl : longint);
        procedure  TextOut(X, Y :longint; const s:string);
        procedure  TextRect(Rect:TRect; X, Y: longint; theText:string);
        function   TextWidth(s:string):integer;
        function   TextHeight(s:string):integer;
        procedure  Read(X, Y, Xl, YL :longint; P:BTBitmap);
        procedure  UseMask(M:BTBitMap; MaskColor:dword);
        procedure  Draw(X, Y, Angle :longint; P:BTBitmap; AnimPic:dword); overload;
        procedure  Draw(X, Y, Angle, XhotSpot, YhotSpot :longint; P:BTBitmap; AnimPic:dword); overload;
        procedure  Draw(X, Y :longint; P:BTBitmap); overload;
        procedure  Draw(X, Y :longint; P:BTBitmap; AnimPic:dword); overload;
        procedure  DrawEx(X, Y, Xp, Yp, Xl, Yl :longint; P:BTBitmap);
        procedure  StretchDraw(X, Y, Xl, Yl :longint; P:BTBitmap); overload;
        procedure  StretchDraw(X, Y, Xl, Yl :longint; P:BTBitmap; AnimPic : dword); overload;
        procedure  StretchDrawEx(X, Y, Xl, Yl, Xp, Yp, pXl, pYl:longint; P:BTBitmap);
        procedure  CopyRect(Dest: TRect; Canvas: BTCanvas; Source: TRect);
        procedure  DrawFocusRect(Rect: TRect);
        procedure  FloodFill(X, Y: Integer; Color: dword; FillStyle: BTFillStyle);
        procedure  Pie(X1, Y1, X2, Y2, X3, Y3, X4, Y4: longint);
        procedure  Polygon(Points: array of TPoint; cnt:dword);
        procedure  PolyBezier(Points: array of TPoint; cnt:dword);
        procedure  RoundRectangle(Xp, Yp, Xl, Yl, Xe, Ye: longint);
        procedure  SetClipRect(top, left, right, bottom:longint);
        function   GetClipRect:TRect;
        procedure  ResetMatix;
        procedure  SetShift(X, Y :longint);
        procedure  TextureMap( p1,p2,p3: BTPoint5; texture: BTBitmap);
        procedure  AttachBitmap(bmp:BTSurface);
        property   Zoom  :single read aZoom write SetZoom;
        property   Angle :longint read aAngle write SetAngle;
        property   ShiftX : longint read aShiftX write SetShiftX;
        property   ShiftY : longint read aShiftY write SetShiftY;
        property   Parent:dword write aParent;
        property   AttachToBitmap : BTSurface read aBMPown write aBMPown;
        property   Handle:dword read GetHandle write SetHandle;
        property   Brush :BTBrush read aBrush write SeBTBrush;
        property   Pen   :BTPen   read aPen write SeBTPen;
        property   Font  :BTFont read aFont write SeBTFont;
        property   Pixels[X, Y: longint]: dword read GetPixel write SetPixel;
      end;



      BTBitmap = class (BTSurface)
      Private
        aFX,aFY,aFXlng,aFYlng : longint;
        aCanvas    : BTCanvas;
        aAlpha     : dword;
        procedure  SetAlpha(value:dword);
        procedure  BilDrawer(W,H,x_dc:longword);
      public
        property    Alpha : dword read aAlpha write setAlpha;
        property    Canvas : BTCanvas read aCanvas;
        Constructor Create;
        Destructor  Destroy; override;
        procedure   GetHandle(ownerHandle:dword);
        function    Init(Xres,Yres,Bpp :Dword; RGBmask:PBTRGBmask):dword; overload; override;
        function    Init(Xres,Yres,Bpp :dword):dword; overload;
        function    Init(Xin_mm,Yin_mm,Dpi,Bpp :dword):dword; overload; {A4 210x297mm}
        procedure   LoadFromFile(FileName:pchar);
        procedure   Load(bmp_dc:dword); overload;
        procedure   Load(bmp_dc:dword; bXpos,bYpos,bXlng,bYlng:longint; bBpp:dword); overload;
        procedure   AutoTransparent;
        // Filters
        procedure   FilterRegion(X,Y,Xl,Yl:longint);
        procedure   UserFilter(FILT:pointer; FiltXl,FiltYl :longword; FiltDiv,FiltBais :single);
        procedure   Aritmetic(AritTyp:dword; Xpos,Ypos,Alpha: longint; bmp:BTBitmap);
        procedure   GrayScale;
        procedure   Lightness(Amount: Integer); // 0..255
        procedure   Darkness(Amount: Integer); // 0..255
        procedure   Saturation(Amount: Integer); // 0..255
        procedure   Contrast(Amount: Integer); // (-255..0..255)
        procedure   Brightness(Amount: Integer); // (-255..0..255)
        procedure   Gamma(Amount :Integer); // 0..255;
        procedure   Sharpness;
        procedure   Smooth;
        procedure   ColorEmboss;
        procedure   Emboss(UpDown:longword);
        procedure   Blur;
        procedure   Glow(Amount : Integer);
        procedure   BadFocus;
        procedure   OldLook;
        procedure   AntiAlias;
        procedure   Colorize(rgb_value :dword);
        procedure   Edge(Amount: Integer); // 0..255
        procedure   Posterize(Amount: Integer);  // 0..255
        procedure   Blinds(Amount: Integer); // 0..255
        procedure   Mosaic(Amount: Integer); // 0..X
        procedure   Noise(Amount, Typ: Integer); //0..255
        procedure   Trace(Amount :integer);
        procedure   Mirror;
        procedure   Flip;
        procedure   MotionBlur(Amount, Angle: Integer);
        procedure   ReduceNoise;
        procedure   Dither(Typ : integer);
        procedure   Treshhold(Amount: Integer);
        procedure   Art;
        procedure   OilPaint(Amount: Integer); // 1..10
        procedure   WaterColor;
        procedure   Smear(Typ,Amount,Angle,Alpha : integer);
        procedure   Chanel(ch : dword);
        procedure   Negativ;
      end;



function  CreateAnimation(bmp:BTBitmap; sprXlng,sprYlng,StartPic,EndPic:longword):dword;  // return handle
function  CreateAnimationRect(bmp:BTBitmap; Xpos,Ypos,Xlng,Ylng,sprXlng,sprYlng,StartPic,EndPic:longword):dword;
procedure ChangeAnimationCurrent(hand:dword; Current:longword);
procedure DeleteAnimation(hand:dword);

function  Color4(ind:dword):dword;
function  Color(r,g,b:dword):dword;
procedure ColorValue(c:dword; var r,g,b:dword);
function  ColorRValue(c:dword):dword;
function  ColorGValue(c:dword):dword;
function  ColorBValue(c:dword):dword;



implementation

type
  PPoints = ^TPoints;
  TPoints = array[0..0] of TPoint;


//////--------- using from MSIMG32
type
  TBlendFunc = packed record
    BlendOp     :byte;
    BlendFlags  :byte;
    Alpha       :byte;
    Format      :byte;
  end;

const
    GRADIENT_FILL_TRIANGLE = $00000002;
type
    GRADIENT_TRIANGLE = packed record
      Vertex1: dword;
      Vertex2: dword;
      Vertex3: dword;
    end;
    VERTEX = packed record
      X, Y : DWORD;
      Red, Green, Blue, Alpha : Word;
    end;

function GradientFill(DC : hDC; pVertex : Pointer; dwNumVertex : DWORD; pMesh : Pointer;
                      dwNumMesh, dwMode: DWORD) : DWord; stdcall; external 'msimg32.dll';
function TransparentBlt(awdc,xpos,ypos,ptx,pty,
                        HmemDC,Pxp,Pyp,Nxl,Nyl,Coff:dword):dword; stdcall;  external 'msimg32.dll';
function AlphaBlend(p1,p2,p3,p4,p5,p6,p7,p8,p9,p10:DWord;p11:TBlendFunc):DWord; stdcall;  external 'msimg32.dll';


procedure debuggdi(a:string; w:real);
var f:text;
    s,s1:string;
begin
   str(w,s1);
   assign(f,'debug.log');
//   reset(f);
   append(f);
   s:=a+'/'+s1;
   writeln(f,s);
   close(f);
end;




////////////////////////////////////////////////////////// F O N T


constructor BTFont.Create;
begin
  OutLine   := false;
  Fill      := false;
  aAlpha    := 255;
  aAngle    := 0;
  aHandle   := 0;   //GetStockObject(DEFAULT_GUI_FONT);
  aName     := '';  // 'default_gui_font';
  aSize     := 14;
  aStyle    := [];
  OnChange  := nil;
  aColor    := rgb(120,120,120);
end;

destructor BTFont.Destroy;
begin
  if aHandle <> 0 then DeleteObject( aHandle );
  inherited Destroy;
end;

procedure  BTFont.SetByHandle(value:dword);
var TM:TEXTMETRIC;
    dc:dword;
    nf:dword;
begin
  if value = 0 then Exit;
  if aHandle <> 0 then DeleteObject( aHandle );
  aHandle := value;
  aAlpha := 255;
  dc := CreateCompatibleDc(0);
  nf := selectObject(dc,aHandle);
  GetTextMetrics(dc,tm);
  aSize := tm.tmHeight;
  aStyle := [];
  if TM.tmItalic <> 0 then aStyle := [bfsItalic];

  selectObject(dc,nf); // restore;
  DeleteDc(dc);

end;

procedure  BTFont.SetName(value:string);
begin
  aName := value;
  GetHandle;
end;

procedure   BTFont.SetAngle(value:dword);
begin
  aAngle := value;
  GetHandle;
end;

procedure  BTFont.SetSize(value:dword);
begin
  aSize := value;
  GetHandle;
end;

procedure  BTFont.SetStyle(value:BTFontStyles);
begin
  aStyle := value;
  GetHandle;
end;


procedure  BTFont.GetHandle;
var del:dword;
    FntName,Angle,BLD,FItalic,FUnderline : dword;
    s:string;
    al,cs:dword;
begin
  del := 1;
  if length(Name) > 1 then
  if aSize <> 0 then
  begin
    // I have all values to create font
    //if exist delete
    if aHandle <> 0 then DeleteObject( aHandle );
    s := aName + #0;
    FntName := dword(@s[1]);
    Angle := aAngle * 10;;
    BLD := 0; //700 - for bold
    FItalic := 0;
    FUnderline := 0;
    al := 0;
    cs := DEFAULT_CHARSET;
    if bfsBold in aStyle then BLD := 700;
    if bfsItalic in aStyle  then FItalic := 1;
    if bfsUnderline in aStyle  then FUnderline := 1;
    if bfsAntialiased in aStyle  then al := ANTIALIASED_QUALITY;
    aHandle := CreateFont(aSize,0,Angle,0,BLD,FItalic,FUnderline,0,cs,0,0,al,0,pchar(FntName)); //lpcwstr(FntName));
     if assigned(OnChange) then OnChange(self);
    del := 0;
  end;
  if del = 1 then if aHandle <> 0 then DeleteObject( aHandle );
end;


procedure BTFont.Assign(f:BTFont);
begin
   Name := F.Name;
   Size := F.Size;
   Style := F.Style;
   Color := F.Color;
   Angle := F.Angle;
   Alpha := F.Alpha;
   GetHandle;
end;

procedure BTFont.LoadTTF(TTF_FileName, FontName:string);
begin
   TTF_FileName := TTF_FileName + #0;
   if AddFontResource(pchar(TTF_FileName)) <> 0 then { instalation is ok }
   begin
      // Note : no need to remove this font is valid only for this window
      // session, after restart font is not present
      // if you want to have that font after restart you must set in registry
      SetName(FontName);
   end;
end;

////////////////////////////////////////////////////////// P E N

Constructor BTPen.Create;
begin
  aDoit := true;
  aAlpha := 255;
  aHandle := 0;
  aColor := 0;
  aStyle := bpsSolid;
  aWidth := 1;
  aMode  := bpmCopy;
  OnChange := nil;
  CloseFigure := false;  
end;

Destructor BTPen.Destroy;
begin
  if aHandle <> 0 then DeleteObject(aHandle);
  aHandle := 0;
  inherited;
end;

procedure  BTPen.Assign(p:BTPen);
begin
  aColor := p.Color;
  aStyle := p.Style;
  aWidth := p.Width;
  aMode := p.Mode;
  aAlpha := p.Alpha;
  SetHandle(p.Handle);
// Parent and gdi do not pass ! :)
end;

var
 PenModes: array[BTPenMode] of Word =
    (R2_BLACK, R2_WHITE, R2_NOP, R2_NOT, R2_COPYPEN, R2_NOTCOPYPEN, R2_MERGEPENNOT,
     R2_MASKPENNOT, R2_MERGENOTPen, R2_MASKNOTPen, R2_MERGEPEN, R2_NOTMERGEPEN,
     R2_MASKPEN, R2_NOTMASKPEN, R2_XORPEN, R2_NOTXORPEN);

function  BTPen.GetHandle:dword;
const
  PenStyles: array[BTPenStyle] of Word =
    (PS_SOLID, PS_DASH, PS_DOT, PS_DASHDOT, PS_DASHDOTDOT, PS_NULL,
     PS_INSIDEFRAME);
var
 LgPen: LogBrush ;
begin
  if aDoit = true then
  begin
     if aHandle <> 0 then DeleteObject(aHandle);
// PS_USERSTYLE

//PS_ENDCAP_ROUND
//PS_ENDCAP_SQUARE
//PS_ENDCAP_FLAT

//PS_JOIN_BEVEL
//PS_JOIN_MITER
//PS_JOIN_ROUND

//22                       SetROP2(aParent,PenModes[aMode]);


     LgPen.lbStyle := BS_SOLID;
     LgPen.lbColor := aColor;
     LgPen.lbHatch := 0;
     aHandle := ExtCreatePen(PenStyles[aStyle] or PS_GEOMETRIC,aWidth,LgPen,0,nil);
     if assigned(OnChange) then self.OnChange(self);
     aDoit := false;
  end;
  GetHandle := aHandle;
end;

procedure BTPen.SetHandle(value:dword);
begin
  if Value = aHandle then exit;
  if aHandle <> 0 then DeleteObject(aHandle);
  aHandle := value;
  aDoit := false;
//22                       SelectObject(aParent,aHandle); // select to Device Context
//22                       SetROP2(aParent,PenModes[aMode]);
end;

procedure BTPen.SetColor(value:dword);
begin
  if Value = aColor then exit;
  aColor := value;
  aDoit := true; // order to create
//  GetHandle;
end;

procedure BTPen.SetWidth(value:dword);
begin
  if Value = aWidth then exit;
  aWidth := value;
  aDoit := true; // order to create
//  GetHandle;
end;

procedure BTPen.SetStyle(value:BTPenStyle);
begin
  aStyle := value;
  aDoit := true; // order to create
//  GetHandle;
end;

procedure BTPen.SetMode(value:BTPenMode);
begin
  aMode := value;
  aDoit := true; // order to create
//  GetHandle;
end;



////////////////////////////////////////////////////////// B R U S H

Constructor BTBrush.Create;
begin
  aDoit := true;
  aInvPattern := false;
  aBitMap := nil;
  aDrawMod := 0;
  aAlpha := 255;
  aTrans := false;
  aHandle := 0;
  aColor := 0; // main color
  aColor2 := rgb(255,255,255);
  aColor3 := 0;
  aColor4 := 0;
  aPreset := 255;
  aStyle := bbsSolid;
  OnChange := nil;
end;

Destructor BTBrush.Destroy;
begin
  if aHandle <> 0 then DeleteObject(aHandle);
  aHandle := 0;
  inherited;
end;

function  BTBrush.GetHandle:dword;
var  a_Pattern    : array [0..7] of word;
     i : dword;
begin
  if aDoit = true then
  begin
    for i := 0 to 7 do a_Pattern[i] := aPattern[i] xor $FF;
    if aHandle <> 0 then DeleteObject(aHandle);
    case aStyle of
       bbsClear : aHandle := GetStockObject(NULL_BRUSH);
       bbsSolid : aHandle := CreateSolidBrush(aColor);
    // note: aPattern must be word alligment on each scan line
       bbsTransparentPattern,
       bbsPattern : begin
//                   SetTextColor(Parent,aColor2);
//                   SetBkColor(Parent,aColor);
                   aHandle := CreatePatternBrush(CreateBitmap(8, 8, 1, 1, @a_Pattern));
                end;
        bbsBitmap : aHandle := CreatePatternBrush(aBitMap.Handle);
     end;
     if assigned(OnChange) then self.OnChange(self);
     aDoit := false;
  end;
  GetHandle := aHandle;
end;


procedure BTBrush.SetHandle(value:dword);
begin
  if Value = aHandle then exit;
  if aHandle <> 0 then DeleteObject(aHandle);
  aHandle := value;
  aDoit := false;
end;

procedure BTBrush.SetColor(value:dword);
begin
  if Value = aColor then exit;
  aColor := value;
  aDoit := true; // order to create
//  GetHandle;
end;

procedure BTBrush.SetColor2(value:dword);
begin
  if Value = aColor2 then exit;
  aColor2 := value;
  if (aStyle = bbsPattern) or (aStyle = bbsGradient) then
  begin
     aDoit := true; // order to create
//     GetHandle;
  end;
end;

procedure BTBrush.SetColor3(value:dword);
begin
  if Value = aColor3 then exit;
  aColor3 := value;
  if (aStyle = bbsGradient) then
  begin
     aDoit := true; // order to create
//     GetHandle;
  end;
end;

procedure BTBrush.SetColor4(value:dword);
begin
  if Value = aColor4 then exit;
  aColor4 := value;
  if (aStyle = bbsGradient) then
  begin
     aDoit := true; // order to create
//     GetHandle;
  end;
end;

procedure BTBrush.SetStyle(value:BTBrushStyle);
begin
  if Value = aStyle then exit;
  aStyle := value;
  aDoit := true; // order to create
//  GetHandle;
end;


procedure res_Patterns; assembler;
asm

  db $AA, $55, $AA, $55, $AA, $55, $AA, $55      // 0
  db $AA, $AA, $AA, $AA, $AA, $AA, $AA, $AA      // 1
  db $FF, $00, $FF, $00, $FF, $00, $FF, $00      // 2
  db $33, $33, $CC, $CC, $33, $33, $CC, $CC      // 3
  db $F0, $F0, $F0, $F0, $F, $F, $F, $F          // 4

  db 0, 0, 0, $18, $18, 0, 0, 0                  // 5
  db 0, 0, $3C, $3C, $3C, $3C, 0, 0              // 6
  db 0, $7E, $7E, $7E, $7E, $7E, $7E, 0          // 7

  db 187, 95, 174, 93, 186, 117, 234, 245        // 8 Bricks
  db 170, 125, 198, 71, 198, 127, 190, 85        // 9 Buttons
  db 120, 49, 19, 135, 225, 200, 140, 30         //10 Cargo Net
  db 82, 41, 132, 66, 148, 41, 66, 132           //11 Circuits
  db 40, 68, 146, 171, 214, 108, 56, 16          //12 Cobblestones
  db 130, 1, 1, 1, 171, 85, 170, 85              //13 Colosseum
  db 30, 140, 216, 253, 191, 27, 49, 120         //14 Daisies
  db 62, 7, 225, 7, 62, 112, 195, 112            //15 Dizzy
  db 86, 89, 166, 154, 101, 149, 106, 169        //16 Field Effect
  db 254, 2, 250, 138, 186, 162, 190, 128        //17 Key
  db 239, 239, 14, 254, 254, 254, 224, 239       //18 Live Wire
  db 240, 240, 240, 240, 170, 85, 170, 85        //19 Plaid
  db 215, 147, 40, 215, 40, 147, 213, 215        //20 Rounder
  db 225, 42, 37, 146, 85, 152, 62, 247          //21 Scales
  db 174, 77, 239, 255, 8, 77, 174, 77           //22 Stone
  db 248, 116, 34, 71, 143, 23, 34, 113          //23 Thatches
  db 69, 130, 1, 0, 1, 130, 69, 170              //24 Tile
  db 135, 7, 6, 4, 0, 247, 231, 199              //25 Triangles
  db 77, 154, 8, 85, 239, 154, 77, 154           //26 Waffle's Revenge
end;



procedure BTBrush.SetPreset(Value:dword);
begin
//  if ((aStyle = bsPattern) or (aStyle = bsTransparentPattern))
//     and (Value = aPreset) then exit;
  aPreset := value;
  SetPattern(pointer(dword(@res_patterns)+Value*8));
end;

type gdi1x1pat = array [0..7] of byte;
procedure BTBrush.SetPattern(Value:pointer);
var pat:^gdi1x1pat;
    i:dword;
begin
  if Value = nil then exit;
  pat := Value;
  for i:=0 to 7 do aPattern[i] := pat[i];
  aStyle := bbsPattern;
  if aTrans then aStyle := bbsTransparentPattern;
  aDoit := true; // order to create
//  GetHandle;
end;




procedure BTBrush.Gradient(ColorA,COlorB,Direction:dword);
begin
   aColor := ColorA;
   aColor3 := ColorB;
   if Direction = 0 then // horizontal
   begin
     aColor2 := aColor;
     aColor4 := aColor3
   end;
   if Direction = 1 then // vertical
   begin
     aColor4 := aColor;
     aColor2 := aColor3
   end;

   aStyle := bbsGradient;
   aDoit := true; // order to create
//   GetHandle;
end;

procedure BTBrush.Gradient4(ColorA,COlorB,ColorC,ColorD:dword);
begin
   aColor := ColorA;
   aColor2 := ColorB;
   aColor3 := ColorC;
   aColor4 := ColorD;
   aStyle := bbsGradient;
   aDoit := true; // order to create
//   GetHandle;
end;

procedure BTBrush.SetTrans(Value:boolean);
begin
   aTrans := value;
   if aStyle = bbsPattern then
   begin
      if aTrans = true then aStyle := bbsTransparentPattern;
   end else begin
      if aStyle = bbsTransparentPattern then
      begin
         if aTrans = false then aStyle := bbsPattern;
      end;
   end;
end;

procedure BTBrush.AttachBitmap(BMP:BTBitmap; DrawMode:dword);
begin
   if DrawMode > 4 then DrawMode := 0 ;
   aBitmap := bmp;
   aDrawMod := DrawMode;
   aStyle := bbsBitmap;
//   GetHandle;
   aDoit := true; // order to create
end;


procedure BTBrush.Assign(b:BTBrush);
var i:dword;
begin
  aStyle := B.Style;
  aBitMap := B.BMP;
  aDrawMod := B.BMP_DM;
  aAlpha := B.Alpha;
  aTrans := B.Color2Transparent;
  aColor := B.Color;
  aColor2 := B.Color2;
  aColor3 := B.Color3;
  aColor4 := B.Color4;
  aPreset := B.PresetPattern;
  for i:=0 to 7 do aPattern[i] := B.aPattern[i];

  SetHandle(b.Handle);
end;


////////////////////////////////////////////////////////// C A N V A S


const
  N3   : single = 3;
  N0   : single = 0;
  N05  : single = 0.5;
  N255 : single = 255;
  N04  : single = 0.499999999999999;


function Distance(X1,Y1,X2,Y2:single):single;
// Result := SQRT(SQR(X1-X2)+SQR(Y1-Y2));
asm
   FLD   X1
   FLD   X2
   FSUB
   FLD   st(0)
   FMUL
   FLD   Y1
   FLD   Y2
   FSUB
   FLD   st(0)
   FMUL
   FADD
   FSQRT
   FWAIT
end;

procedure Swap(var A, B: Integer);
// Swaps the values A and B
asm
   mov   ecx,[eax]
   xchg  ecx,[edx]
   mov  [eax],ecx
end;

function TruncC(D:single):integer;
// Just a Trunc
asm
   Push    esp
   FLD     D
   FSUB    N04
   FISTP   dword ptr [esp]
   POP     eax
end;


function RoundC(D:single):integer;
// Just a Round
asm
   Push    esp
   FLD     D
   FISTP   dword ptr [esp]
   POP     eax
end;

function Limit(Val,Min,Max:integer):integer;
// Limits the value val to a minimum or maximimum of min/max
asm
    cmp   eax,edx
    jl    @Min
    cmp   eax,ecx
    jg    @Max
    jmp   @End
  @Max:
    mov   eax,ecx
    jmp   @End
  @Min:
    mov   eax,edx
  @End:
end;

function DisL(X1,Y1,X2,Y2,X3,Y3,L:single):single;
// result := ((Y1-Y2)*Y3-(X1-X2)*X3)/L;
asm
   FLD   Y1
   FLD   Y2
   FSUB
   FLD   Y3
   FMUL
   FLD   X1
   FSUB  X2
   FLD   X3
   FMUL
   FSUB
   FLD   L
   FDIV
   FWAIT
end;

function GetB(D,W:single):byte;
// Retuns the pixel byte value depending the distance from the line relative to the line width
asm
    fld      W
    fsub     D
    fst      D
    fcomp    N3
    fstsw    ax
    sahf
    jb       @NotBig
    mov      al,$ff
    jmp      @End
  @NotBig:
    fld      D
    fcomp    N0
    fstsw    ax
    sahf
    jnb      @SinV
    xor      eax,eax
    jmp      @End
  @SinV:
    FLD      D
    FLD      N05
    FMUL
    FSIN
    FLD      st(0)
    FMUL
    FLD      N255
    FMUL
    FWAIT
    Push     esp
    FSUB     N04
    FISTP    dword ptr [esp]
    POP      eax
  @End:
end;



function LineCutOff(StP,EndP,Sw:Boolean;An1,An2,An0:single;I,J,X1,Y1,X2,Y2:Integer):boolean;
  //-------------
  function LineRespect(XA,YA,XB,YB:integer;An:double):boolean;
  var
   A : single;
  begin
    if Sw then A := -(YA-YB)*An-(XA-XB)
    else A := (YA-YB)-(XA-XB)*An;

    if Sw and (An0 >= 1E30) then A := (YA-YB)-(XA-XB)*An;

    if (A >= 0) then Result := False else Result := True;

    if Sw then begin
      if (An <= 0) then begin
         if (An0 <> 0) and (An0 < 1E30) then if (An > -1/An0) then Result := not Result;
      end else begin
         if (An0 <> 0) then if (An > -1/An0) and (An0 < 1E30) then Result := not Result;
      end;
    end else begin
      if (An <= 0) then begin
         if not (An0 = 0) and (An < An0) then Result := not Result;
         if (An0 < 0) then Result := not Result;
      end else if (An > 0) then begin
         if (An0 <= 0) then Result := not Result;
         if (An < An0) then Result := not Result;
      end else;
    end;

    if (A > -0.001) and (A < 0.001) then Result := False;

  end;
  //-------------
begin
  Result := True;
  if not EndP then begin
    if not Sw then begin
       if LineRespect(I,J,X2,Y2,An2) then Result := false
       else Result := True;
    end else begin
       if LineRespect(I,J,X1,Y1,An2) then Result := false
       else Result := True;
    end;
  end;

  if Result and not StP then begin
    if not Sw then begin
       if LineRespect(I,J,X1,Y1,An1) then Result := True
       else Result := False;
    end else begin
       if LineRespect(I,J,X2,Y2,An1) then Result := True
       else Result := False;
    end;
 end;
end;



type
  TEZAV = record
    Rdis,Sdis,Rreal:single;
    L,sqrL,Yab,Yba,Xba:single;
    E : single;
  end;
  TEZColor = record
            r,g,b: byte;
         end;

// Code form EZLine
function  BTCanvas._aaLine(X1,Y1,X2,Y2:Integer;Bitmap:TBitmap;StP,EndP:Boolean;An1,An2,An0:single;StartDis:single):single;
var
 EZAV      : TEZAV;
 I,J,dif,dy1,dy2,dx1,dx2,X1a,Y1a,X2a,Y2a,ScrXlng,ScrYlng: Integer;
 D,Lw,AnT: single;
 Clrt   : TEZColor;
//Row    : pRGBTripleArray;
B,By   : byte;
Sw,Ep  : boolean;
Col    : longword;

FCutOff:boolean;


    procedure SetDisConst(XA,YA,XB,YB:single);
    begin
       with EZAV do begin
          L   := Distance(XA,YA,XB,YB);
          sqrL:= SQR(L);
          Yab := YA-YB;
          Yba := YB-YA;
          Xba := XB-XA;
       end;
    end;

    function DistanceLine(XC,YC,XA,YA,XB,YB,W:single;Sw:Boolean): single;
    var R,S: single;
    begin
       Result     := 0;
       R          := 0;
       S          := 0;
       EZAV.Rdis  := 0;
       EZAV.Sdis  := 0;
       EZAV.Rreal := 0;

       if (EZAV.L <> 0) then begin
         R := DisL(XA,YA,XC,YC,EZAV.Xba,EZAV.Yab,EZAV.sqrL);
         S := DisL(XA,YA,XC,YC,EZAV.Yba,EZAV.Xba,EZAV.sqrL);
         if (R >= 0) and (R <= 1) then Result := abs(EZAV.L*S)
         else if (R > 1) then Result := Distance(XB,YB,XC,YC)
         else if (R < 0) then Result := Distance(XA,YA,XC,YC);
       end else Result := Distance(XA,YA,XC,YC);

       if Sw then EZAV.Rdis := (EZAV.L*(1-R)) else EZAV.Rdis := (EZAV.L*R);
       EZAV.Sdis := S*EZAV.L;
       EZAV.Rreal := R;
    end;

    procedure aSetPix(X,Y:longint;B:byte;Col:TEZColor);
    begin
    end;

  //-------------
//  Function SetPix(Pix:TRGBTriple;B:Byte;Col:TRGBTriple):TRGBTriple;
//  begin
//     By := TruncC(Interrupt(EZAV.Rdis,StartDis,FPenS)*B*FTrans);
//     if (B > 0) and (By > 0) then Result := ColByPenMode(Pix,Col,By,FPenM)
//     else Result := Pix;
//  end;
  //-------------
begin
  ScrXlng := GetXlng;
  ScrYlng := GEtYlng;
  Col := Pen.Color;

  Result := StartDis + Distance(X1,Y1,X2,Y2);
//  if LineWidth < 0.01 then Exit;
//  if LineWidth < 1 then LW := FWidth - (1-FWidth)
//  else Lw := FWidth;
//  if Outside(X1,X2,Y1,Y2,Round(2+LW/2),Bitmap) then exit;

 // Col := NormCol(FColor);

  if ((X1 >= X2) and (Y1 > Y2)) or (X1 <= X2) and (Y1 >= Y2) then begin
    Swap(X1,X2);
    Swap(Y1,Y2);
    Sw := true;
  end else Sw := false;

  if not FCutOff then begin
     StP  := True;
     EndP := True;
  end;

  LW := LW+2;
  dif := TruncC(1+LW/2);

  with clrt do begin
    R := GetRValue(Col);
    G := GetGValue(Col);
    B := GetBValue(Col);
  end;

  SetDisConst(X1,Y1,X2,Y2);


  X1a := Limit(X1,Dif,ScrXlng -1-dif);
  X2a := Limit(X2,Dif,ScrXlng -1-dif);
  Y1a := Limit(Y1,Dif,ScrYlng -1-Dif);
  Y2a := Limit(Y2,Dif,ScrYlng -1-Dif);

 if ((X2-X1)*(Y2-Y1) >= 0) and ((Y2-Y1) <> 0) then begin
  dy1 := Y1a-Dif;
  dy2 := Y2a+dif+1;
  dx1 := X1a-Dif;
  dx2 := X2a+dif+1;
  J   := dy1;
  repeat
    I   := dx1;
    repeat
      D := DistanceLine(I,J,X1,Y1,X2,Y2,LW,Sw)*2;
      B := GetB(D,LW);
      Ep:= LineCutOff(StP,EndP,Sw,An1,An2,An0,I,J,X1,Y1,X2,Y2);

      if Ep then aSetPix(I,J,B,Clrt);

      if (EZAV.SDis < -LW/2+1) then dx1 := I;
      if (EZAV.Sdis > LW/2)    then I := dx2;

      Inc(I);
    until (I >= dx2);
    Inc(J);
  until (J >= dy2);
 end else begin
  dy1 := Y1a-dif;
  dy2 := Y2a+dif+1;
  dx1 := X1a+Dif;
  dx2 := X2a-dif-1;
  J   := dy1;
  repeat
    I   := dx1;
   repeat
      D := DistanceLine(I,J,X1,Y1,X2,Y2,LW,Sw)*2;
      B := GetB(D,LW);
      Ep:= LineCutOff(StP,EndP,Sw,An1,An2,An0,I,J,X1,Y1,X2,Y2);

      if Ep then aSetPix(I,J,B,Clrt);

      if (EZAV.SDis >  LW/2-1) then dx1 := I;
      if (EZAV.Sdis < -LW/2)   then I := dx2;

      I := I-1;
    until (I <= dx2);
    Inc(J);
  until (J >= dy2);
 end;
end;




Type
 TPalette256=packed record
  Version:word;
  Entries:word;
  Colors:array[0..255] of integer;
 end;

// WARNING pitch must by dword align
procedure  BTCanvas.Blit(X,Y:Longint; Xlng,Ylng,Bpp,Source,Pal:longword);
Var bisize,i : longint;
    cmask : array[0..2] of longint;
    colors :array[0..255] of word;
    color:integer;
    palette:TPalette256;
    old:Thandle;
    pbitmapinfo : array[0..2048] of byte; // sizeof(BITMAPINFOHEADER)+512  { 512 for 256 di colors word }
    gdiPal   :Thandle;
BEGIN
   if Source = 0 then exit;

   BeginGDI;
   bisize:=sizeof(BITMAPINFOHEADER);
   fillchar(pbitmapinfo, bisize+512, 0);

   with BITMAPINFO((@pbitmapinfo)^) do
   begin {BitmapInfoHeader 16Bit}
     bmiHeader.biSize        :=bisize;
     bmiHeader.biWidth       := Xlng;
     bmiHeader.biHeight      := -Ylng;
     bmiHeader.biPlanes      :=1;
     bmiHeader.biBitCount    := bpp;
     if bpp = 8 then
     begin
       bmiHeader.biCompression  :=BI_RGB;
       bmiHeader.biSizeImage    :=xlng*ylng;
       bmiHeader.biclrused      :=256;
     end else
       bmiHeader.biCompression :=BI_BITFIELDS;
   end;

   if bpp = 8 then
   begin
      if Pal = 0 then Exit;

      cmask[0] := 1;
      for i := 0 to 255 do colors[i]:=i;
      move(colors,pointer(longint(@pbitmapinfo)+ bisize)^,sizeof(colors));

      //Prepare palette
      Palette.Version:=$300;
      Palette.Entries:=256;
//      GetSystemPaletteEntries(GetDC(0),0,256,Palette.Colors);
      gdipal:=CreatePalette(PLogPalette(@Palette)^);
      for i := 0 to 255 do
      begin
         //                                               B                                G                              R
         color:=(((((PC_NOCOLLAPSE shl 8) + byte(Pointer(Pal+2)^)) shl 8) + byte(Pointer(Pal+1)^)) shl 8) + byte(Pointer(Pal)^);
         Pal := Pal + 3;
         SetPaletteEntries(gdipal,i,1,Color);
      end;
   end;
   if bpp = 15 then
   begin
      cmask[0]:=$7C00;                       {Bit-Positions R G B 15Bit }
      cmask[1]:=$03E0;
      cmask[2]:=$001F;
      move(cmask,pointer(longint(@pbitmapinfo)+ bisize)^,sizeof(cmask));
   end;
   if bpp = 16 then
   begin
      cmask[0]:=$F800;                       {Bit-Positions R G B 16Bit }
      cmask[1]:=$07E0;
      cmask[2]:=$001F;
      move(cmask,pointer(longint(@pbitmapinfo)+ bisize)^,sizeof(cmask));
   end;
   if bpp > 16 then
   begin
      cmask[0]:=$FF0000;                       {Bit-Positions R G B 24/32Bit }
      cmask[1]:=$00FF00;
      cmask[2]:=$0000FF;
      move(cmask,pointer(longint(@pbitmapinfo)+ bisize)^,sizeof(cmask));
   end;

   if bpp = 8 then
   begin
           Old:=SelectPalette(aHandle,gdipal,False);
           RealizePalette(aHandle);
           SetDIBitsToDevice(aHandle, x, y, xlng, ylng, 0, 0, 0,
                             ylng, pointer( Source), bitmapinfo((@pbitmapinfo)^),
                             DIB_PAL_COLORS);

           SelectPalette(aHandle,Old,False);
           DeleteObject(gdipal);
   end else begin
           SetDIBitsToDevice(aHandle, X, Y, Xlng, Ylng, 0, 0, 0,
                             Ylng, pointer( Source ), bitmapinfo((@pbitmapinfo)^),
                             DIB_RGB_COLORS);
   end;
   EndGDI;
end;




const
 Rad = Pi / 180.0;

type
 matrix3x3 = array [0..8] of single;


procedure   _MatrixMul(var m1,m2:matrix3x3);  // m1 x m2 -> m1
var m:matrix3x3;
    i,j:longint;
begin
   for i := 0 to 2 do
     for j := 0 to 2 do
        m[ j + i*3 ] := m1[ j + 0*3 ] * m2[ i*3 + 0 ] +
                        m1[ j + 1*3 ] * m2[ i*3 + 1 ] +
                        m1[ j + 2*3 ] * m2[ i*3 + 2 ] ;
   for i := 0 to 8 do m1[i] := m[i];
end;


procedure  _MatrixSH( var m1:matrix3x3; x,y:single);
var i:longint;
begin
   for i := 0 to 8 do m1[i] := 0;  { 0 1 2 }
   m1[0] := 1;                     { 3 4 5 }
   m1[4] := 1;                     { 6 7 8 }
   m1[8] := 1;
   m1[6] := x;
   m1[7] := y;
end;

procedure  _Matrix1( var m1:matrix3x3; v:single);
var i:longint;
begin
   for i := 0 to 8 do m1[i] := 0;  { 0 1 2 }
   m1[0] := v;                     { 3 4 5 }
   m1[4] := v;                     { 6 7 8 }
   m1[8] := 1;
end;

procedure  _MatrixA( var m1:matrix3x3; v:single);
var i:longint;
begin
   v := v * Rad;
   for i := 0 to 8 do m1[i] := 0;          { 0 1 2 }  { C S 0 }
   m1[0] := cos(v);    m1[1]:= -sin(v);    { 3 4 5 }  {-S C 0 }
   m1[3] := sin(v);    m1[4]:= cos(v);     { 6 7 8 }  { 0 0 1 }
   m1[8] := 1;
end;

procedure   BTCanvas._point(var X,Y:longint);
var xa,ya:longint;
begin
   xa := x; ya := y;
   x := round(aMat[0]*xa + aMat[3]*ya + aMat[6]);
   y := round(aMat[1]*xa + aMat[4]*ya + aMat[7]);
end;

procedure   BTCanvas._pointLP(var X,Y,XL,YL:longint);
begin
   if aAngle = 0 then
   begin
      x := round(aMat[0]*x + aMat[3]*y + aMat[6]);
      y := round(aMat[1]*x + aMat[4]*y + aMat[7]);
      xl := round(xl * aZoom);
      yl := round(yl * aZoom);
   end else begin
      XL := X + XL - 1;
      YL := Y + YL - 1;
      x := round(aMat[0]*x + aMat[3]*y + aMat[6]);
      y := round(aMat[1]*x + aMat[4]*y + aMat[7]);
      xl := round(aMat[0]*xl + aMat[3]*yl + aMat[6]);
      yl := round(aMat[1]*xl + aMat[4]*yl + aMat[7]);
   end;
end;


procedure BTCanvas.SetZoom(value:single);
var m1,m2:matrix3x3;
    i :longint;
begin
   aZoom := value;
   _Matrix1(M1,aZoom);
   _MatrixSH(M2,aShiftX,aShiftY);
   _MatrixMul(M1,M2);
   _MatrixA(M2,aAngle);
   _MatrixMul(M1,M2);
   for i := 0 to 8 do aMat[i] := m1[i];
end;

procedure BTCanvas.SetAngle(value:longint);
var m1,m2:matrix3x3;
    i :longint;
begin
   aAngle := value mod 360;
   _Matrix1(M1,aZoom);
   _MatrixSH(M2,aShiftX,aShiftY);
   _MatrixMul(M1,M2);
   _MatrixA(M2,aAngle);
   _MatrixMul(M1,M2);
   for i := 0 to 8 do aMat[i] := m1[i];
end;

procedure  BTCanvas.SetShift(X, Y :longint);
var m1,m2:matrix3x3;
    i :longint;
begin
   aShiftX := X;
   aShiftY := Y;
   _Matrix1(M1,aZoom);
   _MatrixSH(M2,aShiftX,aShiftY);
   _MatrixMul(M1,M2);
   _MatrixA(M2,aAngle);
   _MatrixMul(M1,M2);
   for i := 0 to 8 do aMat[i] := m1[i];
end;

procedure  BTCanvas.SetShiftX(Value:longint);
begin
   self.SetShift(value ,aShiftY);
end;

procedure  BTCanvas.SetShiftY(Value:longint);
begin
   self.SetShift(aShiftX, value);
end;

procedure  BTCanvas.ResetMatix;
var m1:matrix3x3;
    i:longword;
begin
   aShiftX := 0;
   aShiftY := 0;
   aAngle := 0;
   aZoom := 1.0;
   _Matrix1(M1,1);
   for i := 0 to 8 do aMat[i] := m1[i];
end;


Constructor BTCanvas.Create;
var OS:dword;
    i :dword;
    m1: matrix3x3;
begin
   onGDIbegin := nil;
   onGDIend := nil;
   onChange := nil;

   _Matrix1(m1,1);
   for i:= 0 to 8 do aMAt[i] := m1[i];
   aAngle := 0;
   aZoom := 1.0;
   aShiftX := 0;
   aShiftY := 0;

   DrawScaleFactor := 1;
   TextureMapSmooth := 0;

   aBMPown := nil;
   aRealPie := true;
   ainCall := 0;
   ArrowSize := 10;
   ArrowSolid := true;
   DrawSmooth := false;

   aTriangle := false;
   aX := 0;
   aY := 0;

   aOldGDI := false;
   OS := GetVersion;
   if (OS and $80000000) <> 0  then aOldGDI := True
                               else if ( OS and $FF) < 4 then aOldGDI := True;

   aParent := 0;
   aHandle := 0;
   aClipRGN := 0;

   aBrush := BTBrush.create;
   aBrush.Color := rgb(255,255,255);

   aPen := BTPen.Create;
   aPen.Color := rgb(0,0,0);

   aFont := BTFont.create;
   aFont.Name := 'Tahoma';
   aFont.Size := 14;
   aFont.Color := rgb(128,128,128);
end;

Destructor BTCanvas.Destroy;
begin
   aPen.Destroy;
   aBrush.Destroy;
   aFont.Destroy;
   if aParent <> 0 then if aHandle <> 0 then ReleaseDC(aParent,aHandle);
   inherited;
end;

procedure BTCanvas.Clear(Color:dword);
begin
   Solid(0,0,GetXlng,GetYlng,Color);
end;


procedure BTCanvas.AttachToWindow(wnd_hand:dword);
begin
  if aParent <> 0 then if aHandle <> 0 then ReleaseDC(aParent,aHandle);
  aParent := wnd_hand;
 // aHandle := GetDC(aParent);
 // setHandle(aHandle);
end;

function  BTCanvas.GetHandle:dword;
begin

   if aHandle = 0 then
   begin
     if aParent <> 0 then
     begin
        aHandle := GetDC(aParent);
     end;

     if aHandle = 0 then if assigned(aBMPown) then aHandle := aBMPown.GetDC;
   end;

   GetHandle := aHandle;
end;

Procedure BTCanvas.SetHandle(value:dword);
begin
  if value = 0 then Exit;
 // if (aParent <> 0) and (aHandle <> 0 ) then ReleaseDC(aParent,aHandle);
  aHandle := value;
//22  selectObject(aHandle,Pen.Handle);
//22  selectObject(aHandle,Brush.Handle);
//22  selectObject(aHandle,Font.Handle);

end;

procedure BTCanvas.Smooth(h:dword);
begin
  if not aOldGDI then
  begin
     if DrawSmooth then setstretchBltMode(h, HALFTONE)
                   else setstretchBltMode(h, BLACKONWHITE);
  end;
end;

procedure  BTCanvas.AttachBitmap(bmp:BTSurface);
begin
  aBMPown := bmp
end;

Procedure BTCanvas.BeginGDI;
begin
//  if aOldGDi then
//  begin
//    { NOTE  in old version of windows GDI i cant have more that 5 common DC
//            in that case i will getDC every time
//            window 95/98/ME/NT
//            No problems on NT 3.1 up /200/Xp
//    }
//    if aParent <> 0 then begin
//       if aHandle <> 0 then ReleaseDC(aParent,aHandle);
//       aHandle := GetDC(aParent);
//       setHandle(aHandle);
////       aBrush.Parent := aHandle;
////       aPen.Parent := aHandle;
////       aFont.Parent := aHandle;
//
//
////         if aClipRgn <> 0 then ExtSelectClipRgn(aHandle,aClipRgn,RGN_AND);
////22       selectObject(aHandle,Pen.Handle);
////22       selectObject(aHandle,Brush.Handle);
////22       selectObject(aHandle,Font.Handle);
//    end;
//  end else begin
//    if (aHandle = 0) and (aParent <> 0) then
//    begin
//       aHandle := GetDC(aParent);
//       setHandle(aHandle);
//    end;
//  end;
//  SelectClipRgn(aHandle,aClipRgn);
//  if aClipRgn <> 0 then ExtSelectClipRgn(aHandle,aClipRgn,RGN_AND);


{  if aHandle = 0 then
  begin
     if aParent <> 0 then
     begin
        aHandle := GetDC(aParent);
     end;

     if aHandle = 0 then if assigned(aBMPown) then aHandle := aBMPown.GetDC;
  end;
}


  GetHandle;

  if aInCall  = 0 then
  begin
     if assigned(OnGDIbegin) then onGDIbegin;
     if aHandle <> 0 then
     begin
//?     aoStackDC := SaveDC(aHandle);
        aoPen   :=  selectObject(aHandle,Pen.Handle);
        aoBrush :=  selectObject(aHandle,Brush.Handle);
        aoFont  :=  selectObject(aHandle,Font.Handle);
        aoTextColor := SetTextColor(aHandle,Brush.aColor2);
        aoBkColor   := SetBkColor(aHandle,Brush.aColor);
        Windows.MoveToEx(aHandle, aX, aY, nil);
     end;
  end;
  inc(ainCall);
end;

Procedure BTCanvas.EndGDI;
begin
//  SelectClipRgn(aHandle,0);
   dec(ainCall);
   if aInCall = 0 then
   begin
      if aHandle <> 0 then
      begin
//?    RestoreDC(aHandle,aoStackDC);
     // restore
         selectObject(aHandle,aoPen);
         selectObject(aHandle,aoBrush);
         selectObject(aHandle,aoFont);
         SetTextColor(aHandle,aoTextColor);
         SetBkColor(aHandle,aoBkColor);
//     Windows.MoveToEx(aHandle, aoPoint.X, aoPoint.Y, nil);
         if assigned(OnChange) then self.OnChange(self);

         if assigned(aBMPown) then
         begin
            aBMPown.ReleaseDC;
            aHandle := 0;
         end;

         if aParent <> 0 then
         begin
            ReleaseDC(aParent,aHandle);
            aHandle := 0;
         end;

         if Assigned(OnGDIend) then OnGDIend;

      end;
   end;



//  if aOldGDi then
//  begin
//    if aParent <> 0 then
//    begin
//       ReleaseDC(aParent,aHandle);
//       aHandle := 0;
//    end;
//  end;


end;
{
procedure BTCanvas._calccord(var a, b :longint);
var zf:real;
begin
   if aZoom <> 1.0 then
   begin
      if aZoom >= 0 then
      begin
         zf := aZoom;
      end else begin
         zf := 1 / ( aZoom * -1.0);
      end;
      a := Round(a * zf);
      b := Round(b * zf);
   end;
end;
}


procedure BTCanvas.Solid(XPos,Ypos,Xlng,Ylng:longint; Color:dword);
var rect:TRect;
    brush:HBRUSH;
begin
  BeginGDI;
  if aHandle <> 0 then
  begin
    rect.left := Xpos;
    rect.top := Ypos;
    rect.right := xpos + xlng ;
    rect.bottom := ypos + ylng ;
    brush :=  CreateSolidBrush(Color);
    FillRect(aHandle, Rect,brush);
    DeleteObject(brush);
  End;
  EndGDI;
end;


procedure BTCanvas.Box(XPos,Ypos,Xlng,Ylng:longint; Color:dword);
var pen,old_pen:HPEN;
begin
  BeginGDI;
  if aHandle <> 0 then
  begin
    pen := createPen(ps_SOLID,0,color);
    old_pen := SelectObject(aHandle,pen);
    Windows.MoveToEx(aHandle,Xpos,Ypos,nil);
    Windows.LineTo(aHandle,Xpos+Xlng-1,Ypos);
    Windows.LineTo(aHandle,Xpos+Xlng-1,Ypos+Ylng-1);
    Windows.LineTo(aHandle,Xpos,Ypos+Ylng-1);
    Windows.LineTo(aHandle,Xpos,Ypos);
    SelectObject(aHandle,old_pen);
    DeleteObject(pen);
  end;
  EndGDI;
end;


procedure BTCanvas.ColorLine(X1,Y1,X2,Y2:Longint; Color:dword);
var pen,old_pen:HPEN;
begin
  BeginGDI;
  if aHandle <> 0 then
  begin
    pen := createPen(ps_SOLID,0,color);
    old_pen := SelectObject(aHandle,pen);
    Windows.MoveToEx(aHandle,X1,Y1,nil);
    Windows.LineTo(aHandle,X2,Y2);
    SelectObject(aHandle,old_pen);
    DeleteObject(pen);
  end;
  EndGDI;
end;


function BTCanvas.GetXlng:dword;
var rect:TRECT;
    res :dword;
begin
 BeginGDI;
 res := 0;
 if aParent <> 0 then
 begin
   getClientRect(aParent,rect);
   res := rect.right + 1;
 end else if aHandle <> 0 then if assigned(aBMPown) then res := aBMPown.Xlng
                                                    else res := GetDeviceCaps(aHandle, HORZRES);
 EndGDI;
 GetXlng := res;
end;


function BTCanvas.GetYlng:dword;
var rect:TRECT;
    res :dword;
begin
 BeginGDI;
 res :=0;
 if aParent <> 0 then
 begin
   getClientRect(aParent,rect);
   res := rect.bottom + 1;
 end else  if aHandle <>0 then  if assigned(aBMPown) then res := aBMPown.Ylng
                                                     else res := GetDeviceCaps(aHandle, VERTRES);
 EndGDI;
 GetYlng := res;
end;


procedure BTCanvas.Invert(Xp, Yp, Xl, Yl : longint);
var r:rect;
begin
   BeginGDI;
   windows.SetRect(r,Xp,Yp,Xp+Xl-1,Yp+Yl-1);
   if aHandle <> 0 then windows.InvertRect(aHandle,r);
   EndGDI;
end;

/// only PEN

Procedure BTCanvas.Arc(X1, Y1, X2, Y2, X3, Y3, X4, Y4: longint);
begin
  BeginGDI;
  if aHandle <> 0 then
  begin
     BeginPenDraw;
     Windows.Arc(aHandle, X1, Y1, X2, Y2, X3, Y3, X4, Y4);
     EndPenDraw(x1,y1,x2,y2);
  end;
  EndGDI;
end;

procedure BTCanvas.Arc(Xc, Yc, StartAngle, StopAngle, Xradius, Yradius :longint);
begin
  BeginGDI;
  if aHandle <> 0 then
     BeginPenDraw;
     Windows.Arc(aHandle, Xc - Xradius, Yc - Yradius, Xc + Xradius , Yc + Yradius,
                           Xc + Round( Xradius * Cos( StartAngle * Rad)),
                           Yc - Round( Yradius * Sin( startAngle * Rad)),
                           Xc + Round( Xradius * Cos( StopAngle * Rad)),
                           Yc - Round( Yradius * Sin( stopAngle * Rad)));
     EndPenDraw(Xc - Xradius, Yc - Yradius, Xc + Xradius , Yc + Yradius);
  EndGDI;
end;


Procedure BTCanvas.Curve (x1, y1, x2, y2, x3, y3 : longint);
begin
  // todo
  BezierCurve(x1,y1,x2,y2,x2,y2,x3,y3);
end;


Procedure BTCanvas.BezierCurve (x1, y1, x2, y2, x3, y3, x4, y4 : Longint);
var points : array [0..3] of TPoint;
    i:integer;
begin
   points[0].X := x1;   points[0].Y := Y1;  // begin point
   points[1].X := x2;   points[1].Y := Y2;  // control 1-2
   points[2].X := x3;   points[2].Y := Y3;  // control 3-4
   points[3].X := x4;   points[3].Y := Y4;  // end point
    a_XP:=65000;   a_Yp:=65000;   a_Xl:=-65000;  a_Yl:=-65000; { 65000 my be BUG :( }
       for i := 0 to  3 do
       begin
           if a_Xp > Points[i].X then a_Xp := Points[i].X;  { get min X value }
           if a_Xl < Points[i].X then a_Xl := Points[i].X;  { get max X value }
           if a_Yp > Points[i].Y then a_Yp := Points[i].Y;  { get min Y value }
           if a_Yl < Points[i].Y then a_Yl := Points[i].Y;  { get max Y value }
       end;
       { corect to length }
       a_Xl := a_Xl - a_Xp + 1;
       a_Yl := a_Yl - a_Yp + 1;

   BeginGDI;
   if aHandle <> 0 then
   begin
      BeginPenDraw;
        windows.PolyBezier(aHandle,PPoints(@Points)^[0],4);
      EndPenDraw(a_Xp,a_Yp,a_Xp+a_Xl, a_Yp+a_Yl);
   end;
   EndGDI;
end;






/// SHAPES  PEN & BRUSH
procedure BTCanvas.FillShape;
var BMP:BTBitmap;
    Triangle: array [0..1] of GRADIENT_TRIANGLE;
    vertices: array [0..3] of VERTEX;
    coloff,rop,dump :dword;
    sdc:dword;
    xi,yi,xii,yii,nextx,nexty,xl,yl,nextxx:longint;
    argn : HRGN;
begin
  sdc := aoStackDC;
//  argn := CreateRectRgn(0,0,4000,4000);
  argn := 0;
  if GetClipRgn(aHandle,argn) = 0 then argn := 0;
//n  SelectClipRgn(aHandle,aClipRGN);


  if argn <> 0 then ExtSelectClipRgn(aHandle,aRegion,RGN_AND)
               else SelectClipRgn(aHandle,aRegion);

  //----------------------------------------------------------------
  if Brush.Style = bbsSolid then
  begin
     if Brush.Alpha = $FF
     then windows.Rectangle(aHandle, a_Xp, a_Yp, a_Xp+a_Xl, a_Yp+a_Yl)
     else AlphaRectangle(0, 0, a_Xp+a_Xl, a_Yp+a_Yl,brush.Alpha);
  end;
  //----------------------------------------------------------------
  if Brush.Style = bbsPattern then
  begin
     SetTextColor(aHandle,Brush.Color2);
     SetBkColor(aHandle,Brush.Color);
     if Brush.Alpha = $FF
     then windows.Rectangle(aHandle, a_Xp, a_Yp, a_Xp+a_Xl, a_Yp+a_Yl)
     else AlphaRectangle(0, 0, a_Xp+a_Xl, a_Yp+a_Yl,brush.Alpha);
  end;
  //----------------------------------------------------------------
  if Brush.Style = bbsTransparentPattern then
  begin
     coloff := rgb(255,255,255);
     if coloff = Brush.Color then
     begin
        coloff := rgb(0,0,0);
     end;
     BMP := BTBitmap.Create;
     dec(a_XL); dec(a_Yl);
     BMP.init(a_XL,a_YL,32,nil);
     SetTextColor(BMP.GetDC,coloff);
     SetBkColor(BMP.GetDC,Brush.Color);
     dump := SelectObject(BMP.GetDC,Brush.Handle);
     windows.Rectangle(BMP.GetDC, 0,0, a_Xl, a_Yl);
     BMP.Transparent := true;
     BMP.ColorOff := coloff;
     if Brush.Alpha = $FF then Draw(a_Xp,a_Yp,BMP)
                          else AlphaDraw(a_Xp,a_Yp,a_Xl,a_Yl,0,0,0,0,Brush.Alpha,BMP);
     SelectObject(BMP.GetDC,dump);
     BMP.Free;

  (*
     coloff := rgb(255,255,255);  rop := $00A000C9;
     if coloff = Brush.Color then
     begin
        coloff := rgb(0,0,0);
        rop := $0050325;
     end;
     BMP := BTBitmap.Create;
     dec(a_XL); dec(a_Yl);
     BMP.init(a_XL,a_YL,32,nil);
     SelectObject(BMP.h_dc,Brush.Handle);
     SetTextColor(BMP.h_dc,coloff);
     SetBkColor(BMP.h_dc,Brush.Color);
//   SetBrushOrgEx(handle,0,0,0);
//  SetBkMode(handle,TRANSPARENT);
     BMP.Canvas.Solid(0,0,a_XL,a_YL,coloff);
     windows.PatBlt(BMP.h_dc, 0,0, a_Xl,a_Yl,rop);
//  windows.Rectangle(BMP.h_dc, 0,0, a_Xl, a_Yl);
     BMP.Transparent := true;
     BMP.ColorOff := coloff;
     if Brush.Alpha = $FF then Draw(a_Xp,a_Yp,BMP)
                          else AlphaDraw(a_Xp,a_Yp,a_Xl,a_Yl,0,0,0,0,Brush.Alpha,BMP);
     BMP.Free;
     *)
 {
     SetTextColor(handle,rgb(255,255,255));
     SetBkColor(handle,Brush.Color);
     if Brush.Alpha = $FF
     then windows.PatBlt(aHandle, a_Xp, a_Yp, a_Xp+a_Xl, a_Yp+a_Yl,$00A000C9) // $00A000C9)
     else AlphaRectangle(0, 0, a_Xp+a_Xl, a_Yp+a_Yl,brush.Alpha);
  }
  end;
  //----------------------------------------------------------------
  if Brush.Style = bbsBitMap then
  begin
     if assigned(Brush.BMP) then
     begin
        BMP := BTBitmap.Create;
        dec(a_XL); dec(a_Yl);
        BMP.init(a_XL,a_YL,32,nil);
        case Brush.BMP_DM of
          0,1 : begin { Normal }
                rop := 0;
                xii := (a_Xl div 2) - (longint(Brush.BMP.Xlng) div 2);
                yii := (a_Yl div 2) - (longint(Brush.BMP.Ylng) div 2);
                if a_Xl > longint(Brush.BMP.Xlng) then rop := 1; { Fill size is big that pic }
                if a_Yl > longint(Brush.BMP.Ylng) then rop := 1;
                if Brush.BMP.Transparent = true then rop := 1;
                if rop = 1 then Read(a_Xp,a_Yp,a_Xl,a_Yl,BMP);
                case Brush.BMP_DM of
                 0 : BMP.Canvas.Draw(xii,yii,Brush.BMP); { Normal / rect origin }
                 1 : BMP.Canvas.Draw(xii - a_Xp + 1,yii - a_Yp + 1,Brush.BMP); { Normal / screen origin }
                end;
          end;
          2,3 : begin { Tile / rect orogin }
             if Brush.BMP.Transparent = true then Read(a_Xp,a_Yp,a_Xl,a_Yl,BMP);
             xl := Brush.BMP.Xlng;
             yl := Brush.BMP.Ylng;

             xii := ((a_Xl + 1) div xl )+ 2;
             yii := ((a_Yl + 1) div yl )+ 2;
             nextxx := 0;
             nexty := 0;
             if Brush.BMP_DM = 3 then  { /screen origin }
             begin
                nextxx := nextxx - (a_Xp mod xl) + 1;
                nexty := nexty - (a_Yp mod yl) + 1;
             end;
             for yi := 1 to yii do
             begin
               nextx := nextxx;
               for xi := 1 to xii do
               begin
                  BMP.Canvas.Draw(nextx,nexty,Brush.BMP);
                  nextx := nextx + xl;
               end;
               nexty := nexty + yl;
             end;
          end;
          4 : begin  { Stretch }
             if Brush.BMP.Transparent = true then Read(a_Xp,a_Yp,a_Xl,a_Yl,BMP);
             BMP.Canvas.DrawSmooth := self.DrawSmooth; // bypass smooth mode
             BMP.Canvas.StretchDraw(0,0,a_Xl,a_Yl,Brush.BMP);
          end;
        end;
        if Brush.Alpha = $FF then Draw(a_Xp,a_Yp,BMP)
                             else AlphaDraw(a_Xp,a_Yp,a_Xl,a_Yl,0,0,0,0,Brush.Alpha,BMP);
        BMP.Free;
     end;
  end;
  //----------------------------------------------------------------
  if Brush.Style = bbsGradient then
  begin
     BMP := BTBitmap.Create;
     dec(a_XL); dec(a_Yl);
     BMP.init(a_XL,a_YL,32,nil);

       vertices[0].x    := 0;          {  0  1   }
       vertices[0].y    := 0;          {  3  2   }
       vertices[0].Alpha  := $ff00;
       vertices[1].x    := a_Xl ;
       vertices[1].y    := 0;
       vertices[1].Alpha  := $ff00;
       vertices[2].x    := a_Xl;
       vertices[2].y    := a_Yl;
       vertices[2].Alpha  := $ff00;
       vertices[3].x    := 0;
       vertices[3].y    := a_Yl;
       vertices[3].Alpha  := $ff00;


       vertices[0].Red   := getRvalue(brush.Color) SHL 8;
       vertices[0].Green := getGvalue(brush.Color) SHL 8;
       vertices[0].Blue  := getBvalue(brush.Color) SHL 8;
       vertices[1].Red   := getRvalue(brush.Color2) SHL 8;
       vertices[1].Green := getGvalue(brush.Color2) SHL 8;
       vertices[1].Blue  := getBvalue(brush.Color2) SHL 8;
       vertices[2].Red   := getRvalue(brush.Color3) SHL 8;
       vertices[2].Green := getGvalue(brush.Color3) SHL 8;
       vertices[2].Blue  := getBvalue(brush.Color3) SHL 8;
       vertices[3].Red   := getRvalue(brush.Color4) SHL 8;
       vertices[3].Green := getGvalue(brush.Color4) SHL 8;
       vertices[3].Blue  := getBvalue(brush.Color4) SHL 8;


       Triangle[0].Vertex1 := 0;
       Triangle[0].Vertex2 := 1;
       Triangle[0].Vertex3 := 2;
       Triangle[1].Vertex1 := 0;
       Triangle[1].Vertex2 := 2;
       Triangle[1].Vertex3 := 3;
       if aTriangle then
       begin
          vertices[0].x := points[0].x - a_Xp;
          vertices[0].y := points[0].y - a_Yp;
          vertices[1].x := points[1].x - a_Xp;
          vertices[1].y := points[1].y - a_Yp;
          vertices[2].x := points[2].x - a_Xp;
          vertices[2].y := points[2].y - a_Yp;
          GradientFill(BMP.GetDC,@vertices[0],4,@Triangle,1,GRADIENT_FILL_TRIANGLE)
       end else begin
          GradientFill(BMP.GetDC,@vertices[0],4,@Triangle,2,GRADIENT_FILL_TRIANGLE);
       end;

     if Brush.Alpha = $FF then Draw(a_Xp,a_Yp,BMP)
                           else AlphaDraw(a_Xp,a_Yp,a_Xl,a_Yl,0,0,0,0,Brush.Alpha,BMP);

     BMP.Free;

  end;
//n  SelectClipRgn(aHandle,aClipRGN);
  aoStackDC := sdc;

  SelectClipRgn(aHandle,argn);
//  DeleteObject(argn);
//  SelectClipRgn(aHandle,0);
end;


procedure BTCanvas.Chord(Xc, Yc, StartAngle, StopAngle, Xradius, Yradius :longint);
var nXStartArc,nYStartArc,nXEndArc,nYEndArc: longint;
begin
    nXStartArc := Round( Xradius * Cos( StartAngle * Rad));
    nXEndArc := Round( Xradius * Cos( StopAngle * Rad));
    nYStartArc := Round( Yradius * Sin( startAngle * Rad));
    nYEndArc := Round( Yradius * Sin( stopAngle * Rad));
    Self.Chord(Xc-xradius,Yc-yradius,Xc+xradius+1,Yc+yradius+1,Xc+nXStartArc,
                          Yc-nYStartArc,Xc+nXEndArc,Yc-nYEndArc);
end;


procedure BTCanvas.Chord(X1, Y1, X2, Y2, X3, Y3, X4, Y4: longint);
var     oldBrush,ClearBrush :HBrush;
begin
  BeginGDI;
  if aHandle <> 0 then
  begin
      clearBrush := GetStockObject(NULL_PEN);
      oldBrush := selectObject(handle, ClearBrush);
      BeginPath(aHandle);
      Windows.Chord(aHandle, X1, Y1, X2, Y2, X3, Y3, X4, Y4);
      EndPath(aHandle);
      aRegion := PathToRegion(aHandle);
      a_XP := x1;
      a_Yp := y1;
      a_Xl := x2 - x1 + 1;
      a_Yl := y2 - y1 + 1;
      fillShape;
      selectObject(handle,oldBrush);
      clearBrush := GetStockObject(NULL_BRUSH);
      oldBrush := selectObject(handle, ClearBrush);
        BeginPenDraw;
        Windows.Chord(aHandle, X1, Y1, X2, Y2, X3, Y3, X4, Y4);
        EndPenDraw(X1, Y1, X2, Y2);
      selectObject(handle,oldBrush);
      DeleteObject(aRegion);
      DeleteObject(clearBrush);
  end;
  EndGDI;
end;


procedure BTCanvas.Circle(Xp, Yp, Xl :longint);
begin
  Ellipse(Xp,Yp,Xl,Xl);
end;


procedure BTCanvas.Circle(Xc, Yc, StartAngle, StopAngle, Radius :longint);
begin
  Ellipse(Xc,Yc,StartAngle,StopAngle,Radius,Radius);
end;


const
  POLY_TRIANGLE_UP    : Array[0..3] of TPoint =
                        ((X:50;Y:0),(X:100;Y:100),(X:0;Y:100),(X:50;Y:0));
  POLY_TRIANGLE_LEFT  : Array[0..3] of TPoint =
                        ((X:0;Y:50),(X:100;Y:0),(X:100;Y:100),(X:0;Y:50));
  POLY_TRIANGLE_RIGHT : Array[0..3] of TPoint =
                        ((X:0;Y:0),(X:100;Y:50),(X:0;Y:100),(X:0;Y:0));
  POLY_TRIANGLE_DOWN  : Array[0..3] of TPoint =
                        ((X:0;Y:0),(X:100;Y:0),(X:50;Y:100),(X:0;Y:0));
  POLY_ARROW_UP       : Array[0..7] of TPoint =
                        ((X:50;Y:0),(X:100;Y:66),(X:66;Y:66),(X:66;Y:100),
                         (X:33;Y:100),(X:33;Y:66),(X:0;Y:66),(X:50;Y:0));
  POLY_ARROW_LEFT     : Array[0..7] of TPoint =
                        ((X:0;Y:50),(X:66;Y:0),(X:66;Y:33),(X:100;Y:33),
                         (X:100;Y:66),(X:66;Y:66),(X:66;Y:100),(X:0;Y:50));
  POLY_ARROW_RIGHT    : Array[0..7] of TPoint =
                        ((X:33;Y:0),(X:100;Y:50),(X:33;Y:100),(X:33;Y:66),
                         (X:0;Y:66),(X:0;Y:33),(X:33;Y:33),(X:33;Y:0));
  POLY_ARROW_DOWN     : Array[0..7] of TPoint =
                        ((X:33;Y:0),(X:66;Y:0),(X:66;Y:33),(X:100;Y:33),
                         (X:50;Y:100),(X:0;Y:33),(X:33;Y:33),(X:33;Y:0));
  POLY_ROMB           : Array[0..4] of TPoint =
                        ((X:50;Y:0),(X:100;Y:50),(X:50;Y:100),(X:0;Y:50),(X:50;Y:0));
  POLY_4STAR          : Array[0..8] of TPoint =
                        ((X:50;Y:0),(X:60;Y:40),(X:100;Y:50),(X:60;Y:60),(X:50;Y:100),
                         (X:40;Y:60),(X:0;Y:50),(X:40;Y:40),(X:50;Y:0));
  POLY_PARALLELOGRAM  : Array[0..4] of TPoint =
                        ((X:0;Y:0),(X:75;Y:0),(X:100;Y:100),(X:25;Y:100),(X:0;Y:0));
  POLY_TRAPEZOID      : Array[0..4] of TPoint =
                        ((X:25;Y:0),(X:75;Y:0),(X:100;Y:100),(X:0;Y:100),(X:25;Y:0));
  POLY_PENTAGON       : Array[0..5] of TPoint =
                        ((X:50;Y:0),(X:100;Y:50),(X:75;Y:100),(X:25;Y:100),(X:0;Y:50),(X:50;Y:0));
  POLY_HEXAGON        : Array[0..6] of TPoint =
                        ((X:25;Y:0),(X:75;Y:0),(X:100;Y:50),(X:75;Y:100),(X:25;Y:100),(X:0;Y:50),
                         (X:25;Y:0));
  POLY_OCTAGON        : Array[0..8] of TPoint =
                        ((X:25;Y:0),(X:75;Y:0),(X:100;Y:25),(X:100;Y:75),(X:75;Y:100),(X:25;Y:100),
                         (X:0;Y:75),(X:0;Y:25),(X:25;Y:0));
  POLY_STAR           : Array[0..16] of TPoint =
                        ((X:11*4;Y:0*4),(X:13*4;Y:6*4),(X:19*4;Y:3*4),(X:16*4;Y:9*4),(X:22*4;Y:11*4),(X:16*4;Y:13*4),
                         (X:19*4;Y:19*4),(X:13*4;Y:16*4),(X:11*4;Y:22*4),(X:9*4;Y:16*4),(X:3*4;Y:19*4),(X:6*4;Y:13*4),
                         (X:0*4;Y:11*4),(X:6*4;Y:9*4),(X:3*4;Y:3*4),(X:9*4;Y:6*4),(X:11*4;Y:0*4));
  POLY_BUBBLE         : Array[0..11] of TPoint =
                        ((X:10*4;Y:23*4),(X:17*4;Y:10*4),(X:20*4;Y:10*4),(X:23*4;Y:7*4),(X:23*4;Y:3*4),(X:20*4;Y:0*4),
                         (X:3*4;Y:0*4),(X:0*4;Y:3*4),(X:0*4;Y:7*4),(X:3*4;Y:10*4),(X:15*4;Y:10*4),(X:10*4;Y:23*4));


function MulDiv(a,b,c:longint):longint;
begin
   MulDiv := (a*b) div c;
end;


procedure BTCanvas.CalcPoly(var Points: Array of TPoint; Source: Array of TPoint; aXpos, aYpos, aXlng, aYlng, PCount: longint);
var i      : Integer;
    lx,ly  : LongInt;
begin
   for i := 0 to PCount do begin
      lx := MulDiv(Source[i].x,aXlng,100);
      ly := MulDiv(Source[i].y,aYlng,100);
      Points[i].x := lx + aXpos;
      Points[i].y := ly + aYpos;
    end;
end;


procedure BTCanvas.Shape(Xpos, Ypos, Xlng, Ylng: Longint; Shape : dword);
var ppoints : array [0..64] of TPoint;
    Pcount  : dword;
begin
    // Prepare default Shape = 0 is rectangle
    PCount := 5;
    ppoints[0].x := Xpos;                ppoints[0].y := Ypos;
    ppoints[1].x := Xpos + Xlng - 1;     ppoints[1].y := Ypos;
    ppoints[2].x := Xpos + Xlng - 1;     ppoints[2].y := Ypos + Ylng - 1;
    ppoints[3].x := Xpos;                ppoints[3].y := Ypos + Ylng - 1;
    ppoints[4].x := Xpos;                ppoints[4].y := Ypos;
    Case Shape of
      1 : begin PCount := 4;   CalcPoly(ppoints, POLY_TRIANGLE_UP, Xpos,Ypos,Xlng,Ylng,PCount)   end;
      2 : begin PCount := 4;   CalcPoly(ppoints, POLY_TRIANGLE_LEFT, Xpos,Ypos,Xlng,Ylng,PCount)   end;
      3 : begin PCount := 4;   CalcPoly(ppoints, POLY_TRIANGLE_RIGHT, Xpos,Ypos,Xlng,Ylng,PCount)   end;
      4 : begin PCount := 4;   CalcPoly(ppoints, POLY_TRIANGLE_DOWN, Xpos,Ypos,Xlng,Ylng,PCount)   end;
      5 : begin PCount := 8;   CalcPoly(ppoints, POLY_ARROW_UP, Xpos,Ypos,Xlng,Ylng,PCount)   end;
      6 : begin PCount := 8;   CalcPoly(ppoints, POLY_ARROW_LEFT, Xpos,Ypos,Xlng,Ylng,PCount)   end;
      7 : begin PCount := 8;   CalcPoly(ppoints, POLY_ARROW_RIGHT, Xpos,Ypos,Xlng,Ylng,PCount)   end;
      8 : begin PCount := 8;   CalcPoly(ppoints, POLY_ARROW_DOWN, Xpos,Ypos,Xlng,Ylng,PCount)   end;
      9 : begin PCount := 5;   CalcPoly(ppoints, POLY_ROMB, Xpos,Ypos,Xlng,Ylng,PCount)   end;
     10 : begin PCount := 9;   CalcPoly(ppoints, POLY_4STAR, Xpos,Ypos,Xlng,Ylng,PCount)   end;
     11 : begin PCount := 5;   CalcPoly(ppoints, POLY_PARALLELOGRAM, Xpos,Ypos,Xlng,Ylng,PCount)   end;
     12 : begin PCount := 5;   CalcPoly(ppoints, POLY_TRAPEZOID, Xpos,Ypos,Xlng,Ylng,PCount)   end;
     13 : begin PCount := 6;   CalcPoly(ppoints, POLY_PENTAGON, Xpos,Ypos,Xlng,Ylng,PCount)   end;
     14 : begin PCount := 7;   CalcPoly(ppoints, POLY_HEXAGON, Xpos,Ypos,Xlng,Ylng,PCount)   end;
     15 : begin PCount := 9;   CalcPoly(ppoints, POLY_OCTAGON, Xpos,Ypos,Xlng,Ylng,PCount)   end;
     16 : begin PCount := 17;  CalcPoly(ppoints, POLY_STAR, Xpos,Ypos,Xlng,Ylng,PCount)   end;
     17 : begin PCount := 12;  CalcPoly(ppoints, POLY_BUBBLE, Xpos,Ypos,Xlng,Ylng,PCount)   end;
    end;
    Polygon(ppoints,Pcount);
end;


procedure BTCanvas.StarShape(Xpos, Ypos, Xlng, Ylng: Longint; Elements, StartAngle, Typ: longint);
var ppoints : array [1..129] of TPoint;
    Pcount,i  : dword;
    th,ch :single;
    dx,dy:longint;
begin
    dx := Xlng div 2;
    dy := Ylng div 2;
    StartAngle := StartAngle mod 360;
    if typ = 0 then
    begin
       if Elements < 3 then Elements := 3;
       if Elements > 128 then Elements := 128;
       th := 360 / Elements;
       ch :=0;
       for i := 1 to Elements do
       begin
          ppoints[i].X := round(Xpos + dx + (cos(Rad*(StartAngle + ch)))*dx);
          ppoints[i].Y := round(Ypos + dy - (sin(Rad*(StartAngle + ch)))*dy);
          ch := ch + th;
       end;
       Pcount := Elements + 1; // Loop it
       ppoints[Pcount].X := ppoints[1].X;
       ppoints[Pcount].Y := ppoints[1].Y;
    end else begin
       if Elements < 5 then Elements := 5;
       if Elements > 127 then Elements := 127;
       Elements := Elements or 1; // Even;
       if Typ > (Elements - 2) then Typ := Elements - 2;
       th := (360 / Elements) * (1 + typ);
       ch := 0;
       for i := 1 to Elements do
       begin
          ppoints[i].X := round(Xpos + dx + (cos(Rad*(StartAngle + ch)))*dx);
          ppoints[i].Y := round(Ypos + dy - (sin(Rad*(StartAngle + ch)))*dy);
          ch := ch + th;
       end;
       Pcount := Elements + 1; // Loop it
       ppoints[Pcount].X := ppoints[1].X;
       ppoints[Pcount].Y := ppoints[1].Y;
    end;
    Polygon(ppoints,Pcount);
end;


procedure BTCanvas.Pie(X1, Y1, X2, Y2, X3, Y3, X4, Y4: longint);
var oldBrush,ClearBrush :HBrush;
begin
   BeginGDI;
   if aHandle <> 0 then
   begin
      clearBrush := GetStockObject(NULL_PEN);
      oldBrush := selectObject(handle, ClearBrush);

      BeginPath(aHandle);
      windows.Pie(aHandle,x1,y1,x2,y2,x3,y3,x4,y4);

      EndPath(aHandle);
      aRegion := PathToRegion(aHandle);
      a_XP := x1;
      a_Yp := y1;
      a_Xl := x2 - x1 + 1;
      a_Yl := y2 - y1 + 1;
      fillShape;
      selectObject(handle,oldBrush);

      clearBrush := GetStockObject(NULL_BRUSH);
      oldBrush := selectObject(handle, ClearBrush);
      if Pen.CloseFigure or aRealPie then
      begin
         windows.Pie(aHandle,x1,y1,x2,y2,x3,y3,x4,y4);
      end else begin
         windows.Arc(aHandle,x1,y1,x2,y2,x3,y3,x4,y4);
      end;
      selectObject(handle,oldBrush);
      DeleteObject(aRegion);
      DeleteObject(clearBrush);
   end;
   EndGDI;
end;


procedure BTCanvas.Ellipse(Xc, Yc, StartAngle, StopAngle, Xradius, Yradius :longint);
var nXStartArc,nYStartArc,nXEndArc,nYEndArc: longint;
//    oldBrush,ClearBrush :HBrush;
begin
      nXStartArc := Round( Xradius * Cos( StartAngle * Rad));
      nXEndArc := Round( Xradius * Cos( StopAngle * Rad));
      nYStartArc := Round( Yradius * Sin( startAngle * Rad));
      nYEndArc := Round( Yradius * Sin( stopAngle * Rad));


      aRealPie := false;
      Self.Pie(Xc-xradius,Yc-yradius,Xc+xradius+1,Yc+yradius+1,Xc+nXStartArc,
                          Yc-nYStartArc,Xc+nXEndArc,Yc-nYEndArc);
      aRealPie := true;
end;


procedure BTCanvas.Ellipse(Xp, Yp, Xl, Yl: Longint);
var oldBrush,ClearBrush :HBrush;
begin
  BeginGDI;
  if aHandle <> 0 then
  begin
    if Pen.Style = bpsClear then
    begin
       inc(Xl);
       inc(Yl);
    end;
    if (Brush.Alpha = $FF) and (Pen.Alpha = $FF) and (( Brush.Style = bbsSolid ) or ( Brush.Style = bbsClear )) then
    begin
       Windows.Ellipse(aHandle, Xp, Yp, Xp+Xl, Yp+Yl); // to be fast
    end else begin
       a_Xp := Xp;  a_Yp := Yp;   a_Xl := Xl;  a_Yl := Yl;
       clearBrush := GetStockObject(NULL_PEN);
       oldBrush := selectObject(handle, ClearBrush);
       aRegion := CreateEllipticRgn(Xp, Yp, Xp+Xl, Yp+Yl);
       fillShape;
       selectObject(handle,oldBrush);
              
       clearBrush := GetStockObject(NULL_BRUSH);
       oldBrush := selectObject(handle, ClearBrush);
       BeginPenDraw;
          Windows.Ellipse(aHandle, Xp, Yp, Xp+Xl, Yp+Yl);
       EndPenDraw( Xp, Yp, Xp+Xl, Yp+Yl);
       selectObject(handle,oldBrush);
       DeleteObject(aRegion);
       DeleteObject(clearBrush);
    end;
  end;
  EndGDI;
end;


procedure BTCanvas.Triangle(X1, Y1, X2, Y2, X3, Y3: Longint);
begin
    points[0].x := X1;    points[0].y := Y1;
    points[1].x := X2;    points[1].y := Y2;
    points[2].x := X3;    points[2].y := Y3;
    points[3].x := X1;    points[3].y := Y1;
    aTriangle := true;
    Polygon(points,4);
    aTriangle := false;
end;


function Tan(a:single):single;
begin
   Tan := Sin(a)/Cos(a);
end;

procedure BTCanvas._LineEnd(P1,X1,Y1,ax,ay,sz:longint; var NewX1,NewY1:longint);
var
   cor:longint;
   points : array [0..4] of Tpoint;
begin
      NewX1 := x1;
      NewY1 := y1;

      if p1 = 0 then Exit;

      BeginPenDraw;
      case P1 of
         1: begin // SIMPLE ARROW
              Windows.MoveToEx(aHandle, x1+ax+(ay div 2) ,y1+ay-(ax div 2), nil);
              Windows.LineTo(aHandle,x1,y1);
              Windows.LineTo(aHandle, x1+ax-(ay div 2) ,y1+ay+(ax div 2));
            end;
         2: begin // ARROW TEHNICAL
              points[0].x := x1;                       points[0].y := y1;
              points[1].x := x1+ax+(ay div 2);         points[1].y := y1+ay-(ax div 2);
              newX1 := x1+(ax * 2 div 3);              newY1 := y1+(ay * 2 div 3);
              points[2].x := newX1;                    points[2].y := newY1;
              points[3].x := x1+ax-(ay div 2);         points[3].y := y1+ay+(ax div 2);
              Windows.Polygon(aHandle, PPoints(@Points)^[0], 4);
            end;
         3: begin // ARROW TEHNICAL
              points[0].x := x1;                       points[0].y := y1;
              points[1].x := x1+ax+(ay div 2);         points[1].y := y1+ay-(ax div 2);
              newX1 := x1+ax;                          newY1 := y1+ay;
              points[2].x := x1+ax-(ay div 2);         points[2].y := y1+ay+(ax div 2);
              Windows.Polygon(aHandle, PPoints(@Points)^[0], 3);
            end;
         4: begin // LINE
//              Windows.MoveToEx(aHandle, x1+(ax div 2)+(ay div 2) ,y1+(ay div 2)-(ax div 2), nil);
//              Windows.LineTo(aHandle  , x1+(ax div 2)-(ay div 2) ,y1+(ay div 2)+(ax div 2));
              Windows.MoveToEx(aHandle, x1+(ay div 2) ,y1-(ax div 2), nil);
              Windows.LineTo(aHandle  , x1-(ay div 2) ,y1+(ax div 2));

            end;
         5: begin // DOUBLE LINE
              Windows.MoveToEx(aHandle, x1+(ay div 2) ,y1-(ax div 2), nil);
              Windows.LineTo(aHandle  , x1-(ay div 2) ,y1+(ax div 2));
//              Windows.MoveToEx(aHandle, x1+(ax div 2)+(ay div 2) ,y1+(ay div 2)-(ax div 2), nil);
//              Windows.LineTo(aHandle  , x1+(ax div 2)-(ay div 2) ,y1+(ay div 2)+(ax div 2));
              Windows.MoveToEx(aHandle, x1+(ax div 3)+(ay div 2) ,y1+(ay div 3)-(ax div 2), nil);
              Windows.LineTo(aHandle  , x1+(ax div 3)-(ay div 2) ,y1+(ay div 3)+(ax div 2));
            end;
         6: begin // CIRCLE
              Windows.Ellipse(aHandle,x1+(ax div 2)-(sz div 2),y1+(ay div 2)-(sz div 2),
                                      x1+(ax div 2)+(sz div 2),y1+(ay div 2)+(sz div 2));
              newX1 := x1+ax;                          newY1 := y1+ay;
            end;
         7: begin // DIAMOND
              points[0].x := x1;                       points[0].y := y1;
              points[1].x := x1+(ax div 2)+(ay div 2); points[1].y := y1+(ay div 2)-(ax div 2);
              newX1 := x1+ax;                          newY1 := y1+ay;
              points[2].x := x1+ax;                    points[2].y := y1+ay;
              points[3].x := x1+(ax div 2)-(ay div 2); points[3].y := y1+(ay div 2)+(ax div 2);
              Windows.Polygon(aHandle, PPoints(@Points)^[0], 4);
            end;
          8: Begin // invert Arrow
              Windows.MoveToEx(aHandle, x1+(ay div 2) ,y1-(ax div 2), nil);
              Windows.LineTo(aHandle,x1+ax,y1+ay);
              newX1 := x1+ax;                          newY1 := y1+ay;
              Windows.LineTo(aHandle, x1-(ay div 2) ,y1+(ax div 2));
            end;
          9: Begin // Box
              newX1 := x1+ax;                          newY1 := y1+ay;
              points[0].x := x1+(ay div 2);            points[0].y := y1-(ax div 2);
              points[1].x := x1-(ay div 2);            points[1].y := y1+(ax div 2);
              points[2].x := x1+ax-(ay div 2);         points[2].y := y1+ay+(ax div 2);
              points[3].x := x1+ax+(ay div 2);         points[3].y := y1+ay-(ax div 2);
              Windows.Polygon(aHandle, PPoints(@Points)^[0], 4);
            end;
      end;

      cor := abs(ax) + abs(ay);

      EndPenDraw(x1-cor,y1-cor,x1+cor,y1+cor);  // BUG TODO
end;

procedure BTCanvas.Arrow(X1, Y1, X2, Y2, P1, P2 :longint);
var
   ArSize                  :single;
   lp                      :single;
   ax,ay,sz                :longint;
   newX1,newY1,newX2,newY2 : longint;

   penBrush,oldBrush       : dword;
   penPen,oldPen           : dword;
begin
   BeginGDI;
   if aHandle <> 0 then
   begin
      ArSize := ArrowSize+pen.width-1;
      sz := round(ArSize);

      penPen := createPen(ps_SOLID,pen.width,pen.color);
      oldPen := selectObject(aHandle,penPen);
      penBrush := 0;
      if ArrowSolid then
      begin
         penBrush := CreateSolidBrush(pen.Color);
         oldBrush := selectObject(aHandle,penBrush);
      end else begin
         oldBrush := selectObject(aHandle,GetStockObject(NULL_BRUSH));
      end;

      // P1 - source marker (beginning)
      // Source x1,y1   destination x2,y2
      lp   := Sqrt( (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1) ) ;  // get distance
      if lp < 1 then lp := 1;                              // max(1,distance)
      ax := trunc( (Arsize * (x2 - x1)) / lp);
      ay := trunc( (Arsize * (y2 - y1)) / lp);
      _LineEnd(P1,X1,Y1,ax,ay,sz,newX1,newY1);

      // P2 - source marker (end)
      // Source x2,y2   destination x1,y1
      ax := trunc( (Arsize * (x1 - x2)) / lp);
      ay := trunc( (Arsize * (y1 - y2)) / lp);
      _LineEnd(P2,X2,Y2,ax,ay,sz,newX2,newY2);

      selectObject(aHandle,oldBrush);
      if penBrush <> 0 then
      begin
         DeleteObject(penBrush);
      end;
      selectObject(aHandle,oldPen);
      DeleteObject(penPen);

      // Actual line draw
      MoveTo(newX1, newY1);
      LineTo(newX2,newY2);

   end;
   EndGDI;
end;


procedure BTCanvas.Rectangle(Xp, Yp, Xl, Yl: Longint);
var oldBrush,ClearBrush :HBrush;
begin
  BeginGDI;
  if aHandle <> 0 then
  begin
    // Do something for windows bugs see MSDN this remark not a BUG
    if Pen.Style = bpsClear then
    begin
       inc(Xl);
       inc(Yl);
    end;
    if (Brush.Alpha = $FF) and (Pen.Alpha = $FF) and (( Brush.Style = bbsSolid ) or ( Brush.Style = bbsClear )) then
    begin
       windows.Rectangle(aHandle, Xp, Yp, Xp+Xl, Yp+Yl); // to be fast
    end else begin
       a_Xp := Xp;  a_Yp := Yp;   a_Xl := Xl;  a_Yl := Yl;
       clearBrush := GetStockObject(NULL_PEN);
       oldBrush := selectObject(handle, ClearBrush);
       aRegion := CreateRectRgn(Xp, Yp, Xp+Xl, Yp+Yl);
       fillShape;
       selectObject(handle,oldBrush);

       clearBrush := GetStockObject(NULL_BRUSH);
       oldBrush := selectObject(handle, ClearBrush);
       BeginPenDraw;
         windows.Rectangle(aHandle, Xp, Yp, Xp+Xl, Yp+Yl);
       EndPenDraw(Xp, Yp, Xp+Xl, Yp+Yl);
       selectObject(handle,oldBrush);
       DeleteObject(aRegion);
       DeleteObject(clearBrush);
    end;
  end;
  EndGDI;
end;

procedure BTCanvas.RoundRectangle(Xp, Yp, Xl, Yl, Xe, Ye: longint);
var oldBrush,ClearBrush :HBrush;
begin
  BeginGDI;
  if aHandle <> 0 then
  begin
    if (Brush.Alpha = $FF) and (Pen.Alpha = $FF) and (( Brush.Style = bbsSolid ) or ( Brush.Style = bbsClear )) then
    begin
       windows.RoundRect(aHandle, Xp, Yp, Xp+Xl, Yp+Yl, Xe, Ye); // to be fast
    end else begin
       a_Xp := Xp;  a_Yp := Yp;   a_Xl := Xl;  a_Yl := Yl;
       clearBrush := GetStockObject(NULL_PEN);
       oldBrush := selectObject(handle, ClearBrush);
       aRegion := CreateRoundRectRgn(Xp, Yp, Xp+Xl, Yp+Yl, Xe, Ye);
       fillShape;
       selectObject(aHandle,oldBrush);

       clearBrush := GetStockObject(NULL_BRUSH);
       oldBrush := selectObject(handle, ClearBrush);
       BeginPenDraw;
          windows.RoundRect(aHandle, Xp, Yp, Xp+Xl, Yp+Yl, Xe, Ye);
       EndPenDraw( Xp, Yp, Xp+Xl, Yp+Yl);
       selectObject(aHandle,oldBrush);
       DeleteObject(aRegion);
    end;
  end;
  EndGDI;
end;



procedure BTCanvas.Polygon(Points: array of TPoint; cnt:dword);
var oldBrush,ClearBrush :HBrush;
    i:dword;
begin
//  BeginGDI;
//  if aHandle <> 0 then Windows.Polygon(aHandle, PPoints(@Points)^[0], cnt);
//  EndGDI;
  if cnt < 3 then Exit;
  BeginGDI;

       a_XP:=65000;   a_Yp:=65000;   a_Xl:=-65000;  a_Yl:=-65000; { 65000 my be BUG :( }
       for i := 0 to  cnt-1 do
       begin
           if a_Xp > Points[i].X then a_Xp := Points[i].X;  { get min X value }
           if a_Xl < Points[i].X then a_Xl := Points[i].X;  { get max X value }
           if a_Yp > Points[i].Y then a_Yp := Points[i].Y;  { get min Y value }
           if a_Yl < Points[i].Y then a_Yl := Points[i].Y;  { get max Y value }
       end;
       { corect to length }
       a_Xl := a_Xl - a_Xp + 1;
       a_Yl := a_Yl - a_Yp + 1;

  if aHandle <> 0 then
  begin
    SetPolyFillMode(aHandle,WINDING);
    if (Brush.Alpha = $FF) and (Pen.Alpha = $FF) and (( Brush.Style = bbsSolid ) or ( Brush.Style = bbsClear )) then
    begin
       Windows.Polygon(aHandle, PPoints(@Points)^[0], cnt);
    end else begin
       clearBrush := GetStockObject(NULL_PEN);
       oldBrush := selectObject(handle, ClearBrush);
       aRegion := CreatePolygonRgn(PPoints(@Points)^[0], cnt, WINDING);
       fillShape;
       selectObject(aHandle,oldBrush);

       clearBrush := GetStockObject(NULL_BRUSH);
       oldBrush := selectObject(handle, ClearBrush);
       BeginPenDraw;
          Windows.Polygon(aHandle, PPoints(@Points)^[0], cnt);
       EndPenDraw(a_Xp,a_Yp,a_Xp+a_Xl, a_Yp+a_Yl);
       selectObject(aHandle,oldBrush);
       DeleteObject(aRegion);
    end;
  end;
  EndGDI;
end;

procedure BTCanvas.PolyBezier(Points: array of TPoint; cnt:dword);
begin
  if cnt < 3 then Exit;
  BeginGDI;
  if aHandle <> 0 then
  begin
     //BeginPenDraw;
     Windows.PolyBezier(aHandle, PPoints(@Points)^[0], cnt);
     //EndPenDraw(); //todo
  end;
  EndGDI;
end;





procedure BTCanvas.TextRect(Rect:TRect; X, Y: longint; theText:string);
var
  Options: Longint;
begin
  BeginGDI;
  if aHandle > 0 then
  begin
     Options := ETO_CLIPPED;
     if Brush.Style <> bbsClear then  Options := Options or ETO_OPAQUE;
     Windows.ExtTextOut(aHandle, X, Y, Options, @Rect, PChar(TheText), Length(TheText), nil);
  end;
  EndGDI;
end;






Procedure BTCanvas.SeBTFont(Value:BTFont);
begin
  Font.Assign(Value);
end;

Procedure BTCanvas.SeBTPen(Value:BTPen);
begin
  Pen.Assign(Value);
end;

Procedure BTCanvas.SeBTBrush(Value:BTBrush);
begin
  Brush.Assign(Value);
end;

Procedure BTCanvas.MoveTo(X, Y:longint);
begin
  BeginGDI;
  _point(X, Y);
  if aHandle <> 0 then  Windows.MoveToEx(aHandle, X, Y, nil);
  aX := X; aY := Y;
  EndGDI;
end;


procedure BTCanvas.MoveRel(Dx, Dy : longint);
begin
   self.MoveTo(aX + Dx, aY + Dy);
end;

procedure BTCanvas.LineRel(Dx, Dy : longint);
begin
   self.LineTo(aX + Dx, aY + Dy);
end;


//var
//     dlaHandle     : dword;
//     dlaPenColor   : dword;
//     dlaBrushColor : dword;
//     dlaBrushUse   : boolean;
//     dlaWidth      : dword;
//     dlaPattern    : dword;
//     LineDrawMask    : dword;
//     LineDrawCounter : dword;
//
//
//Procedure DrawLine(X,Y:longint; data:dword); stdcall;
//var temp:dword;
//begin
//   if (LineDrawCounter mod dlaWidth) = 0 then
//   begin
//      LineDrawMask := LineDrawMask shr 1;
//      if LineDrawMask = 0 then LineDrawMask := $80000000;
//   end;
//
//         if ((LineDrawMask and dlaPattern ) = 0) then
//         begin
//            if dlaBrushUse then
//            begin
//               Temp := selectObject(dlaHandle,dlaBrushColor);
//               Windows.MoveToEx(dlaHandle,X,Y,nil);
//               Windows.LineTo(dlaHandle,X+1,Y);
//               SelectObject(dlaHandle,Temp);
//            end;
//         end else begin
//            Temp := selectObject(dlaHandle,dlaPenColor);
//            Windows.MoveToEx(dlaHandle,X,Y,nil);
//            Windows.LineTo(dlaHandle,X+1,Y);
//            SelectObject(dlaHandle,Temp);
//         end;
//
//   inc(LineDrawCounter);
//end;

//    if Pen.Width < 2 then
//    begin
//       Windows.LineTo(aHandle,x,y);
//    end else begin
//       aPen := CreatePen(PS_NULL,0,0);
//       oldPen := SelectObject(aHandle,aPen);
//       DLaHandle := aHandle;
//       DLaPenColor := CreatePen(PS_SOLID,pen.aWidth,pen.Color);
//       DLaBrushColor := CreatePen(PS_SOLID,pen.aWidth,brush.Color);
//       DLaBrushUse := false;
//       if brush.Style = bbsSolid then DLaBrushUse := true;
//       DLaWidth := pen.Width;
//       DLaPattern := $FFFFFFFF;
//       if Pen.Style = bpsDash then DLaPattern := $F8F8F8F8;
//       if Pen.Style = bpsDot then DLaPattern := $33333333;
//       if Pen.Style = bpsDashDot then DLaPattern := $C187C187;
//       if Pen.Style = bpsDashDotDot then DLaPattern := $F198F198;
//       LineDrawCounter := 1;
//       LineDrawMask := $80000000;
//       LineDDA(X,Y,aX,aY,@DrawLine,0);
//       DeleteObject(selectObject(aHandle,oldPen));
//       DeleteObject(DLaPenColor);
//       DeleteObject(DLaBrushColor);
//    end;



procedure BTCanvas.BeginPenDraw;
begin
    if Pen.Alpha < 255 then
    begin
       BeginPath(aHandle);
       SetPolyFillMode(aHandle,WINDING);
    end;
end;

procedure BTCanvas.EndPenDraw(x,y,ax,ay:longint);
var blend:TBlendFunc;
   hdcMem:HDC;
   bmMem,bmMemold:HBITMAP;
   argn : HRGN;
   NewBrush,newPen:dword;
   a:longint;
begin
    if Pen.Alpha < 255 then
    begin
       EndPath(aHandle);
       WidenPath(aHandle);
       aRegion := PathToRegion(aHandle);
       argn := 0;
       if GetClipRgn(aHandle,argn) = 0 then argn := 0;

       if argn <> 0 then ExtSelectClipRgn(aHandle,aRegion,RGN_AND)
                    else SelectClipRgn(aHandle,aRegion);

  //todo optimization

       // bound rectangle
       a_Xp := x;
       a_Xl := ax;                  // a_XP  := min(x1,x2) a_Xl := max(x1,x2)
       if a_Xp > ax then begin a_Xp := ax;  a_Xl := x; end;
       a_Yp := y;
       a_Yl := ay;                  // a_YP  := min(y1,y2) a_Yl := max(y1,y2)
       if a_Yp > ay then begin a_Yp := ay;  a_Yl := y; end;
       a := pen.Width+1;
       dec(a_Xp,a);
       dec(a_Yp,a);
       inc(a_Xl,a);
       inc(a_Yl,a);

       a_Xl := a_Xl - a_Xp + 1;
       a_Yl := a_Yl - a_Yp + 1;

       Blend.BlendOp := 0;
       Blend.BlendFlags := 0;
       Blend.Alpha := dword(Pen.Alpha) and $FF;
       Blend.Format := 0;

       hdcMem   := CreateCompatibleDC(aHandle);
       bmMem    := CreateCompatibleBitmap(aHandle, a_Xl, a_Yl);
       bmMemOld := SelectObject(hdcMem, bmMem);

       newBrush := CreateSolidBrush(Pen.Color);
       newpen := createPen(ps_NULL,0,0);

       DeleteObject(selectObject(hdcMem,NewPen));
       DeleteObject(selectObject(hdcMem,NewBrush));

       Windows.Rectangle(hdcMem, 0, 0, a_Xl, a_Yl);
       AlphaBlend(aHandle,a_Xp,a_Yp,a_Xl-1,a_Yl-1,hdcMem,0,0,a_Xl-1,a_Yl-1,blend);

       DeleteObject(newPen);
       DeleteObject(NewBrush);
       DeleteObject(SelectObject(hdcMem, bmMemOld));
       DeleteDC(hdcMem);

       SelectClipRgn(aHandle,argn);

       DeleteObject(aRegion);
    end;
end;


Procedure BTCanvas.LineTo(X, Y:longint);
//var aPen,OldPen :dword;
begin
   BeginGDI;
   _point(X,Y);
   if aHandle <> 0 then
   begin
      if Brush.Style = bbsClear then  SetBkMode(aHandle,TRANSPARENT)
                                else  begin
                                      SetBkMode(aHandle,OPAQUE);
                                      SetBkColor(aHandle,Brush.aColor);
                                     end;
   //   selectObject(ahandle,CreateSolidBrush(rgb(255,0,0)));
      BeginPenDraw;
      Windows.LineTo(aHandle,x,y);
      EndPenDraw(x,y,aX,aY);

      SetBkMode(aHandle,TRANSPARENT);
   end;
   aX := X; aY := Y;
   EndGDI;
end;

Procedure BTCanvas.Line(X1,Y1,X2,Y2:longint);
begin
   BeginGDI;
   self.MoveTo(X1,Y1);
   self.LineTo(X2,Y2);
   aX := X2; aY := Y2;
   EndGDI;
end;


Procedure BTCanvas._TextOutS(aHand:dword; x,y:longint;const s:string);
var Fobj,Bobj:dword;
begin
   Fobj := selectObject(aHand,Font.Handle);
   SetTextColor(aHand,Font.Color);
   if Brush.Style = bbsClear then  SetBkMode(aHand,TRANSPARENT)
                             else begin
                                   SetBkMode(aHand,OPAQUE);
                                   SetBkColor(aHand,Brush.aColor);
                                  end;

   if Font.Fill = false then
   begin
      Windows.TextOut(aHand,X,Y,PChar(s),length(s));
   end else begin
      SetBkMode(aHand,TRANSPARENT);
      BeginPath(aHand);
      Windows.TextOut(aHand,x,y,PChar(s),length(s));
      EndPath(aHand);
      Bobj := selectObject(aHand, Brush.Handle);
      StrokeAndFillPath(aHand);
      SelectObject(aHand,Bobj);
   end;

   if Font.OutLine Then
   begin
      BeginPath(aHand);
      Windows.TextOut(aHand,x,y,PChar(s),length(s));
      EndPath(aHand);
      Bobj := selectObject(aHand, Pen.Handle);
      StrokePath(aHand);
      SelectObject(aHand,Bobj);
   end;
   SetBkMode(aHand,TRANSPARENT);
   selectObject(aHand,Fobj);
end;

Procedure BTCanvas.TextOut(x,y:longint;const s:string);
var xl,yl:dword;
    BMP:BTBitmap;
//    Fobj:dword;
//    coloroff,i,d:dword;
begin
  BeginGDI;
  inc(x,aShiftX);
  inc(y,aShiftY);
  if aHandle <> 0 then
  if s<>'' then
  begin
//    Fobj := selectobject(aHandle,Font.Handle);
    if Font.Alpha = 255 then
    begin
//       if Font.Fill = false then
//       begin
//          if Brush.Style = bbsClear then  SetBkMode(aHandle,TRANSPARENT)
//                                    else  SetBkColor(aHandle,Brush.aColor);
//          SetTextColor(aHandle,Font.Color);
//          Windows.TextOut(aHandle,x,y,PChar(s),length(s));
            _TextOutS(aHandle,x,y,s);
//       end else begin
//          SetBkMode(aHandle,TRANSPARENT);
//          BeginPath(aHandle);
//          Windows.TextOut(aHandle,x,y,PChar(s),length(s));
//          EndPath(aHandle);
//          selectObject(aHandle,Brush.Handle);
//          StrokeAndFillPath(aHandle);
//       end;
//       if Font.OutLine Then
//       begin
//          BeginPath(aHandle);
//          Windows.TextOut(aHandle,x,y,PChar(s),length(s));
//          EndPath(aHandle);
//          selectObject(aHandle,Pen.Handle);
//          StrokePath(aHandle);
//       end;
    end else begin
       xl := TextWidth(s);
       yl := TextHeight(s);
       BMP := BTBitmap.Create;
       BMP.init(xl,yl,32,nil);
       // Chose color off
//       for i := 1 to 3 do
//       begin
//         d := 0;
//         case i of
//           1: coloroff := rgb(255,0,0);
//           2: coloroff := rgb(0,255,0);
//           3: coloroff := rgb(0,0,255);
//         end;
//         if Font.Color = Coloroff then d := 1;
//         if Brush.Color = coloroff then d := 1;
//         if d = 0 then Break;
//       end;
//       BMP.Canvas.Solid(0,0,XL,YL,coloroff);


       Read(X,Y,Xl,YL,BMP);
//       selectObject(BMP.h_dc,Font.Handle);
//       SetTextColor(BMP.h_dc,Font.Color);
//       if Brush.Style = bbsClear then  SetBkMode(BMP.h_dc,TRANSPARENT)
//                                 else  SetBkColor(BMP.h_dc,Brush.aColor);
//
//       Windows.TextOut(BMP.h_dc,0,0,PChar(s),length(s));
         _TextOutS(BMP.GetDC,0,0,s);


//       BMP.Transparent := true;
//       BMP.ColorOff := coloroff;
       AlphaDraw(X,Y,Xl,Yl,0,0,0,0,Font.Alpha,BMP);
       BMP.Free;
    end;
//    selectobject(aHandle,Fobj);
  end;
  EndGDI;;
end;

Function BTCanvas.TextWidth(s:string):integer;
var
  Size:TSize;
  Fobj:dword;
begin
  BeginGDI;
  Size.cX := 0;
    if aHandle <> 0 then
    begin
       Fobj := selectobject(aHandle,Font.Handle);
       Windows.GetTextExtentPoint32(aHandle, PChar(s), Length(s), Size);
       selectobject(aHandle,Fobj);
    end;
  EndGDI;
  TextWidth := Size.cX;
end;

Function BTCanvas.TextHeight(s:string):integer;
var
 Size:TSize;
 Fobj:dword;
begin
  BeginGDI;
  Size.cY := 0;
    if aHandle <> 0 then
    begin
       Fobj := selectobject(aHandle,Font.Handle);
       Windows.GetTextExtentPoint32(aHandle, PChar(s), Length(s), Size);
       selectobject(aHandle,Fobj);
    end;
  EndGDI;
  TextHeight := Size.cY;
end;

function BTCanvas.GetPixel(X, Y: Longint): dword;
begin
  BeginGDI;
  GetPixel := Windows.GetPixel(aHandle, X, Y);
  EndGDI;
end;

procedure BTCanvas.SetPixel(X, Y: Longint; Value: dword);
begin
  BeginGDI;
  if aHandle <> 0 then Windows.SetPixel(aHandle, X, Y, Value);
  EndGDI;
end;


procedure BTCanvas.AlphaRectangle(Xp, Yp, Xl, Yl, ALpha :longint);
var
   blend:TBlendFunc;
   hdcMem:HDC;
   bmMem,bmMemold:HBITMAP;
begin
   BeginGDI;
   if aHandle <> 0 then
   begin

      _PointLP(Xp,Yp,Xl,Yl);

      if aAngle = 0 then
      begin
         Blend.BlendOp := 0;
         Blend.BlendFlags := 0;
         Blend.Alpha := dword(Alpha) and $FF;
         Blend.Format := 0;

         hdcMem   := CreateCompatibleDC(aHandle);
         bmMem    := CreateCompatibleBitmap(aHandle, Xl, Yl);
         bmMemOld := SelectObject(hdcMem, bmMem);
         DeleteObject(selectObject(hdcMem,Pen.handle));
         DeleteObject(selectObject(hdcMem,Brush.handle));
         if (Brush.Style = bbsPattern) or (Brush.Style = bbsTRansparentPattern) then
         begin
            SetTextColor(hdcMem,Brush.Color2);
            SetBkColor(hdcMem,Brush.Color);
         end;

         Windows.Rectangle(hdcMem, 0, 0, Xl, Yl);
         AlphaBlend(aHandle,Xp,Yp,Xl-1,Yl-1,hdcMem,0,0,Xl-1,Yl-1,blend);

         DeleteObject(SelectObject(hdcMem, bmMemOld));
         DeleteDC(hdcMem);
      end else begin
         // ToDo

      end;
   end;
   EndGDI;
end;



//procedure BTCanvas.AlphaDraw(X, Y, Alpha :longint; P:BTBitmap; AnimPic:dword);
//var an :PBTBitmapAnimation;
//    done: dword;
//    sXpos,sYpos :longint;
//begin
//  done :=0;
//  if p <> nil then
//  begin
//     if p.aAnimation <> 0 then
//     begin
//        an := pointer(p.aAnimation);
//        if an.pwd = $1045AEFF then
//        begin
//
//           _CalcAnim(an,AnimPic,sXpos,sYpos);
//           AlphaDraw(X,Y,an.PXlng,an.PYlng,sXpos,sYpos,an.PXlng,an.PYlng,Alpha,P);
//
//           done := 1;
//        end;
//     end;
//     if done = 0 then AlphaDraw(X,Y,p.Xlng,p.Ylng,0,0,p.Xlng,p.Ylng,Alpha,p); // No animation do normal
//  end;
//end;


//procedure BTCanvas.AlphaDraw(X, Y, Xl, Yl, Alpha :longint; P:BTBitmap; AnimPic:dword);
//var an :PBTBitmapAnimation;
//    done: dword;
//    sXpos,sYpos :longint;
//begin
//  done := 0;
//  if p <> nil then
//  begin
//     if p.aAnimation <> 0 then
//     begin
//        an := pointer(p.aAnimation);
//        if an.pwd = $1045AEFF then
//        begin
//
//           _CalcAnim(an,AnimPic,sXpos,sYpos);
//           AlphaDraw(X,Y,Xl,Yl,sXpos,sYpos,an.PXlng,an.PYlng,Alpha,P);
//
//           done := 1;
//        end;
//     end;
//     if done = 0 then AlphaDraw(X,Y,Xl,Yl,0,0,p.Xlng,p.Ylng,Alpha,p); // No animation do normal
//  end;
//end;


procedure BTCanvas.AlphaDraw(X,Y,Xl,Yl,Xp,Yp,pXl,pYl,Alpha:longint; p:BTBitmap);
var blend:TBlendFunc;
//    cColor :COLORREF;
    rHand,OldAlpha : dword;
    bmMem,bmOldMem : HBitmap;
    hdcMem : HDC;
//    bmAndBack, bmAndObject,  bmMem, bmScr: HBITMAP;
//    bmBackOld, bmObjectOld,  bmOldMem, bmScrOld: HBITMAP;
//    hdcMem, hdcBack, hdcObject, hdcScr :HDC;
begin
  if p = nil then Exit;
  BeginGDI;
  if aHandle <> 0 then
  begin

  Blend.BlendOp := 0;
  Blend.BlendFlags := 0;
  Blend.Alpha := dword(Alpha) and $FF;
  Blend.Format := 0;
  if p <> nil then
  begin
    if Xl = 0 then Xl := p.Xlng;
    if Yl = 0 then Yl := p.Ylng;
    if pXl = 0 then pXl := p.Xlng;
    if pYl = 0 then pYl := p.Ylng;
    if pXl > longint(p.Xlng) then pXl := p.Xlng;
    if pYl > longint(p.Ylng) then pYl := p.Ylng;

       if (p.Transparent) then
       begin
          //
            hdcMem    := CreateCompatibleDC(Handle);
            bmMem     := CreateCompatibleBitmap(Handle, Xl, Yl);
            bmOldMem  := SelectObject(hdcMem, bmMem);
            BitBlt(hdcMem,0,0,XL,Yl,aHandle,X,Y,SRCCOPY);
            rHand := aHandle;
            aHandle := hdcMem;
            oldAlpha := P.alpha;
            p.Alpha := 255; // Do not do dead loop
            StretchDrawEx(0,0,Xl,Yl,Xp,Yp,pXl,pYl,p);
            p.Alpha := oldAlpha;
            aHandle := rHand;
            AlphaBlend(aHandle,X,Y,Xl,Yl,hdcMem,0,0,Xl,Yl,blend);
            DeleteObject(SelectObject(hdcMem, bmOldMem));
            DeleteDC(hdcMem);

   (*
      !!!!!!  This Version gives  artefacts  when stretch to smaller

          // color off
            hdcMem    := CreateCompatibleDC(Handle);
            bmMem     := CreateCompatibleBitmap(Handle, Xl, Yl);
            bmOldMem  := SelectObject(hdcMem, bmMem);
            hdcScr    := CreateCompatibleDC(Handle);
            bmScr     := CreateCompatibleBitmap(Handle, Xl, Yl);
            bmScrOld  := SelectObject(hdcScr, bmScr);

            //Mono masks
            hdcBack    := CreateCompatibleDC(Handle);
            hdcObject  := CreateCompatibleDC(Handle);
            bmAndBack   := CreateBitmap(Xl, Yl, 1, 1, nil);
            bmAndObject := CreateBitmap(Xl, Yl, 1, 1, nil);
            bmBackOld   := SelectObject(hdcBack, bmAndBack);
            bmObjectOld := SelectObject(hdcObject, bmAndObject);


            BitBlt(hdcMem,0,0,XL,Yl,aHandle,X,Y,SRCCOPY);
            BitBlt(hdcScr,0,0,XL,Yl,aHandle,X,Y,SRCCOPY);
            AlphaBlend(hdcMem,0,0,Xl,Yl,p.h_dc,Xp,Yp,pXl,pYl,blend);

            // Now Make mash draw of hdcMEM to Handle using p.dc for mask
            // Create mask
            cColor := SetBkColor(p.h_DC, p.ColorOff);
      Smooth(hdcObject);
      StretchBlt(hdcObject, 0, 0, Xl, YL, p.h_dc, Xp, Yp, pxl, pyl, SRCCOPY);
            SetBkColor(p.h_DC, cColor);
      BitBlt(hdcBack, 0, 0, Xl, YL, hdcObject, 0, 0, NOTSRCCOPY);
      // Mask out the places where the bitmap will be placed.
      BitBlt(hdcScr, 0, 0, XL, YL, hdcObject, 0, 0, SRCAND);
      // Mask out the transparent colored pixels on the bitmap.
      BitBlt(hdcMem, 0, 0, Xl, Yl, hdcBack, 0, 0, SRCAND);
      BitBlt(hdcScr, 0, 0, Xl, YL, hdcMem, 0, 0,SRCPAINT);
      BitBlt(Handle, X, Y, Xl, Yl, hdcScr, 0, 0, SRCCOPY);

            DeleteObject(SelectObject(hdcMem, bmOldMem));
            DeleteObject(SelectObject(hdcScr, bmScrOld));
            DeleteObject(SelectObject(hdcBack, bmBackOld));
            DeleteObject(SelectObject(hdcObject, bmObjectOld));
            DeleteDC(hdcBack);
            DeleteDC(hdcObject);
            DeleteDC(hdcMem);
            DeleteDC(hdcScr);
    *)
       end else begin
          AlphaBlend(aHandle,X,Y,Xl,Yl,p.GetDC,Xp,Yp,pXl,pYl,blend);
          p.ReleaseDC;
       end;
  end ;

  end; // have gdi
  EndGDI;
end;


procedure BTCanvas.DrawEx(X, Y, Xp, Yp, Xl, Yl :longint; P:BTBitmap);
begin
  BeginGDI;
  if aHandle <> 0 then
  if p <> nil then
  begin
    if P.Alpha = 255 then
    begin
       if (p.Transparent) then
       begin
          TransparentBlt(aHandle,X,Y,Xl,Yl,p.GetDC,Xp,Yp,Xl,Yl,p.ColorOff);
          p.ReleaseDC;
       end else begin
          // normal
          BitBlt(aHandle,X,Y,Xl,Yl,p.getDC,Xp,Yp,SRCCOPY);
          p.ReleaseDC;
       end;
    end else begin
       self.AlphaDraw(X,Y,Xl,Yl,Xp,Yp,Xl,Yl,p.Alpha,P);
    end;
  end ;
  EndGDI;
end;

procedure BTCanvas.Read(X, Y, Xl, Yl :longint; P:BTBitmap);
begin
  BeginGDI;
  if aHandle <> 0 then
  begin
    if P.Handle <> 0 then
    begin
       if Xl > longint(P.Xlng) then Xl := P.Xlng;
       if Yl > longint(P.Ylng) then Yl := P.Ylng;
       windows.BitBlt(p.GetDC,0,0,Xl,Yl,aHandle,X,Y,SRCCOPY);
       p.ReleaseDC;
    end;
  end;
  EndGDI;
end;





procedure BTCanvas.Draw(X, Y, Angle :longint; P:BTBitmap; AnimPic:dword);
var an :PBTPicAnimation;
    done : dword;
begin
  done := 0;     
  if p <> nil then
  begin
     if p.Animation <> 0 then
     begin
        an := pointer(p.Animation);
        if an.pwd = $1045AEFF then
        begin
           Draw(X,Y,Angle,an.PXlng div 2,an.PYlng div 2,P,AnimPic);
           done := 1;
        end;
     end;
     if done = 0 then  Draw(X,Y,Angle,P.Xlng div 2,P.Ylng div 2,P,0);
  end;
end;

procedure BTCanvas.Draw(X, Y, Angle, XhotSpot, YhotSpot :longint; P:BTBitmap; AnimPic:dword);
var an :PBTPicAnimation;
    done,i : dword;
    ax,ay,sXPos,sYpos,tXpos,tYpos,tXlng,tYlng:longint;
    Pt : array[1..6] of BTPoint5;
    Scale : single;
begin
  done := 0;
  if p <> nil then
  begin
     if p.Animation <> 0 then
     begin
        an := pointer(p.Animation);
        if an.pwd = $1045AEFF then
        begin
           _CalcAnim(an,AnimPic,sXpos,sYpos);
           done := 1;
        end;
     end;

     if done = 0 then
     begin // No Animation
         tXpos := 0;            tYpos := 0;
         tXlng := P.Xlng -1;    tYlng := P.Ylng -1;
     end else begin
         // With Animation
         tXpos := sXpos;                tYpos := sYpos;
         tXlng := an.PXlng + sXpos -1;  tYlng := an.PYlng + sYpos -1;
     end;

     scale := DrawScaleFactor;

     pt[1].x := 0;          pt[1].y := 0;
     pt[2].x := tXlng;      pt[2].y := 0;
     pt[3].x := tXlng;      pt[3].y := tYlng;

     pt[4].x := 0;          pt[4].y := 0;
     pt[5].x := tXlng;      pt[5].y := tYlng;
     pt[6].x := 0;          pt[6].y := tYlng;

     angle := angle *-1;
     // rotate by angle
     for i := 1 to 6 do
     begin
        // translate
        Pt[i].X := Pt[i].X - XhotSpot;
        Pt[i].Y := Pt[i].Y - YhotSpot;
        // scale
        Pt[i].X := Round(Pt[i].X * scale);
        Pt[i].Y := Round(Pt[i].Y * scale);
        // rotate
        aX := Round(Pt[i].X * cos(angle*Rad) - Pt[i].Y*sin(angle*Rad));
        aY := Round(Pt[i].X * sin(angle*Rad) + Pt[i].Y*cos(angle*Rad));
        Pt[i].X := aX;
        Pt[i].Y := aY;
        Pt[i].Z := 0; // We dont use this
        // translate to skreen
        Pt[i].X := Pt[i].X + X;
        Pt[i].Y := Pt[i].Y + Y;
     end;

     pt[1].u := tXpos;  pt[1].v := tYpos;
     pt[2].u := tXlng;  pt[2].v := tYpos;
     pt[3].u := tXlng;  pt[3].v := tYlng;
     TextureMap(pt[1],pt[2],pt[3],P);

     pt[4].u := tXpos;  pt[4].v := tYpos;
     pt[5].u := tXlng;  pt[5].v := tYlng;
     pt[6].u := tXpos;  pt[6].v := tYlng;
     TextureMap(pt[4],pt[5],pt[6],P);
  end;
end;


procedure BTCanvas.Draw(X, Y :longint; P:BTBitmap);
begin
  if p <> nil then  DrawEx(X, Y, 0, 0, p.Xlng, p.Ylng, p);
end;


procedure BTCanvas._CalcAnim(an:PBTPicAnimation; AnimPic:dword; var sXpos,sYpos:longint);
begin
   if AnimPic = 0 then
   begin {Auto Animation }
      if (an.CurrentPic + an.BeginPic - 1) > an.EndPic then an.CurrentPic := 1;
      AnimPic := an.CurrentPic + an.BeginPic - 1;
      inc (an.CurrentPic);
   end else begin
      if (AnimPic) > (an.Xmod * an.Ymod) then AnimPic := 1;
      if (AnimPic + an.BeginPic - 1) > an.EndPic then AnimPic := 1;
   end;
   dec(AnimPic);
   sXPos := ( AnimPic mod an.Xmod ) * an.PXlng + an.PXpos;
   sYpos := ( AnimPic div an.Xmod ) * an.PYlng + an.Pypos;
end;


procedure BTCanvas.Draw(X, Y :longint; P:BTBitmap; AnimPic:dword);
var an :PBTPicAnimation;
    done : dword;
    sXPos,sYpos:longint;
begin
  done := 0;
  if p <> nil then
  begin
     if p.Animation <> 0 then
     begin
        an := pointer(p.Animation);
        if an.pwd = $1045AEFF then
        begin

           _CalcAnim(an,AnimPic,sXpos,sYpos);
           DrawEx(X,Y,sXpos,sYpos,an.PXlng,an.PYlng,p);
           done := 1;
        end;
     end;
     if done = 0 then  Draw(X,Y,p); // No animation do normal
  end;
end;


procedure BTCanvas.UseMask(M:BTBitMap; MaskColor:dword);   // set nil to close mask
begin
   if assigned(M) then
   begin

   end else begin

   end;
end;

procedure BTCanvas.StretchDrawEx(X, Y, Xl, Yl, Xp, Yp, pXl, pYl:longint; P:BTBitmap);
begin
  BeginGDI;
  if aHandle <> 0 then
  if p <> nil then
  begin
    if pXl > longint(p.Xlng) then pXl := p.Xlng;
    if pYl > longint(p.Ylng) then pYl := p.Ylng;
    if P.Alpha = 255 then
    begin
       if (p.Transparent) then
       begin
          TransparentBlt(aHandle,X,Y,Xl,Yl,p.GetDC,Xp,Yp,pXl,pYl,p.ColorOff);
          p.ReleaseDC;
       end else begin
          // normal
          Smooth(aHandle);
          StretchBlt(aHandle,X,Y,Xl,Yl,p.GetDC,Xp,Yp,pXl,pYl,SRCCOPY);
          p.ReleaseDC;
       end;
    end else begin
       self.AlphaDraw(X,Y,Xl,Yl,Xp,Yp,pXl,pYl,p.Alpha,P);
    end;
  end ;
  EndGDI;
end;

procedure BTCanvas.StretchDraw(X, Y, Xl, Yl :longint; P:BTBitmap);
begin
  StretchDrawEx(X, Y, Xl, Yl, 0, 0, p.Xlng, p.Ylng, p);
end;

procedure BTCanvas.StretchDraw(X, Y, Xl, Yl :longint; P:BTBitmap; AnimPic : dword);
var an :PBTPicAnimation;
    done : dword;
    sXPos,sYpos:longint;
begin
  done := 0;
  if p <> nil then
  begin
     if p.Animation <> 0 then
     begin
        an := pointer(p.Animation);
        if an.pwd = $1045AEFF then
        begin

           _CalcAnim(an,AnimPic,sXpos,sYpos);
           StretchDrawEx(X,Y,Xl,Yl,sXpos,sYpos,an.PXlng,an.PYlng,p);
           done := 1;
        end;
     end;
     if done = 0 then  StretchDraw(X,Y,Xl,Yl,p); // No animation do normal
  end;
end;


procedure BTCanvas.CopyRect(Dest: TRect; Canvas: BTCanvas; Source: TRect);
begin
  BeginGDI;
  if aHandle <> 0 then
  StretchBlt(aHandle, Dest.Left, Dest.Top, Dest.Right - Dest.Left + 1,
    Dest.Bottom - Dest.Top + 1, Canvas.Handle, Source.Left, Source.Top,
    Source.Right - Source.Left + 1, Source.Bottom - Source.Top + 1, SRCCOPY);
  EndGDI;
end;

procedure BTCanvas.DrawFocusRect(Rect: TRect);
//const Rect: TRect
begin
//  Rect.left := Xp;
//  Rect.Top := Yp;
//  Rect.Right := Xp + Xl - 1;
//  Rect.Bottom := Yp + Yl - 1;
    BeginGDI;
    if aHandle <> 0 then Windows.DrawFocusRect(aHandle, Rect);
    EndGDI;
end;

procedure BTCanvas.FloodFill(X, Y: Integer; Color: dword; FillStyle: BTFillStyle);
const
  FillStyles: array[BTFillStyle] of Word =
    (FLOODFILLSURFACE, FLOODFILLBORDER);
begin
  BeginGDI;
  if aHandle <> 0 then Windows.ExtFloodFill(aHandle, X, Y, Color, FillStyles[FillStyle]);
  EndGDI;
end;


function BTCanvas.GetClipRect: TRect;
begin
  BeginGDI;
  GetClipBox(aHandle, Result);
  EndGDI;
end;

procedure BTCanvas.SetClipRect(top,left,right,bottom:longint);
begin
  Exit;
  BeginGDI;
    if dword(aClipRgn) <> 0 then
    begin
       DeleteObject(aClipRgn);
       aClipRgn := 0;
    end;
    if (top+left+right+bottom) <> 0 then
    begin
      // set clip region
      aClipRgn:=CreateRectRgn(top,left,right,bottom);
//      ExtSelectClipRgn(aHandle,aClipRgn,RGN_AND);
      SelectClipRgn(aHandle,aClipRgn);
    end else begin
      // no clip region
      SelectClipRgn(aHandle,0);
      aClipRgn := 0;
    end;
  EndGDI;
end;


Procedure BTCanvas.Scan_line( xl,xr,ul,ur,vl,vr,zl,zr: single; y,xres: Longint; texture,Temp: BTBitmap);
var xx,xsize,tu,tv,startP,endP,i: Longint;
    dist,subTex,
    u_step,v_step,z_step,u,v,z,j,w: single;
    A,R,G,B:DWORD;
      R00,G00,B00:DWORD;
      R10,G10,B10:DWORD;
      R01,G01,B01:DWORD;
      R11,G11,B11:DWORD;
      wu,wv,du,dv,w1,w2,w3,w4:single;

const ucor:array[0..1,0..1] of single = ((0.25,0.50),(0.75,0.0));
const vcor:array[0..1,0..1] of single = ((0.0,0.75),(0.50,0.25));

begin
   xres := GetXlng;

   {if left is < than right}   // test is this posible to come
   if (xl>xr) then
   begin
      j:=xr;xr:=xl;xl:=j;
      j:=ur;ur:=ul;ul:=j;
      j:=vr;vr:=vl;vl:=j;
      j:=zr;zr:=zl;zl:=j;
   end;

   if ( ((xr-xl)>0) and (xr>0) and (xl < Temp.Xlng) ) then {if we can draw anything}
   begin

   startP := trunc(xl); // ceil
   endP := trunc(xr);

   dist := 1.0 / (xr - xl);  // no danger of ZEROdiv    I have test (xr-xl)>0
   u_step := (ur-ul) * dist;
   v_step := (vr-vl) * dist;
   z_step := (zr-zl) * dist;

   xsize := EndP - StartP ;//+ 1;

   // Texture adjustment (some call this "sub-texel accuracy")
   subTex := (startP) - xl;
   u := ul + u_step * subTex;
   v := vl + v_step * subTex;
   z := zl + z_step * subTex;

{   u := ul; // test to show atrefact without subTex acuracy
   v := vl;
   z := zl;
}
   xx := 0;

   {clip left page}
   if (xl < 0) then
   begin
      u := u - (xl + SubTex) * u_step;
      v := v - (xl + SubTex) * v_step;
      z := z - (xl + SubTex) * z_step;
      startP := 0;
      xsize := endP ; //+ 1;
   end;

   for i := StartP to EndP -1 do   //end + 1
   begin
       if TextureMapSmooth = 0 then
       begin
          w := 1 / z;
          tu := Trunc(u * w);
          tv := Trunc(v * w);
          Temp.Pixels[xx,0] := Texture.Pixels[tu,tv];
       end else begin
          if TextureMapSmooth = 1 then
          begin
             // Tim Sweeney  UNREAL  dither smoother  // poor mans bilinear
             // work perfect
             //
             //             (X&1)==0        (X&1==1)
             //         +---------------------------------
             //(Y&1)==0 | u+=.25,v+=.00  u+=.50,v+=.75
             //(Y&1)==1 | u+=.75,v+=.50  u+=.00,v+=.25
             //
             //const ucor:array[0..1,0..1] of single = ((0.25,0.50),(0.75,0.0));
             //const vcor:array[0..1,0..1] of single = ((0.0,0.75),(0.50,0.25));
             //
             w := 1 / z;
             tu := Trunc(u * w + ucor[Y and 1, i and 1]);
             tv := Trunc(v * w + vcor[Y and 1, i and 1]);
             Temp.Pixels[xx,0] := Texture.Pixels[tu,tv];
          end else begin
             w := 1 / z;
             tu := Trunc(u * w);
             tv := Trunc(v * w);
             // Bi Linear Texture mapping
             Texture.color2rgb(Texture.Pixels[tu,tv],A,R00,G00,B00);
             Texture.color2rgb(Texture.Pixels[tu,tv+1],A,R01,G01,B01);
             Texture.color2rgb(Texture.Pixels[tu+1,tv],A,R10,G10,B10);
             Texture.color2rgb(Texture.Pixels[tu+1,tv+1],A,R11,G11,B11);

             du := (u * w) - tu;
             dv := (v * w) - tv;
             wu := 1 - du;
             wv := 1 - dv;

             w1 := wu*wv;   // top
             w2 := wu*dv;
             w3 := du*wv;
             w4 := du*dv;   // bottom

             R := round(w1*r00 + w2*r01 + w3*r10 + w4*r11);
             G := round(w1*g00 + w2*g01 + w3*g10 + w4*g11);
             B := round(w1*b00 + w2*b01 + w3*b10 + w4*b11);

             Temp.Pixels[xx,0] := Temp.rgb2color(A,R,G,B);
          end;
       end;
      u := u + u_step;
      v := v + v_step;
      z := z + z_step;
      inc(xx);
      if (xx + StartP ) > xres then Break;
   end;

   if xx > 0 then
   begin
     // draw the spole
     if (Texture.Alpha = 255) and (Texture.Transparent = false) then
     begin
        BitBlt(handle,startP,y,xx,1,Temp.getDC,0,0,srccopy);
//        Temp.ReleaseDC;  // last free will do that
     end else begin
        self.DrawEx(startP,y,0,0,xx,1,Temp);
     end;
   end;

   end;{end of drawing}
end;


procedure   BTCanvas.TextureMap( p1,p2,p3: BTPoint5; texture: BTBitmap);
var            j,x,y,x1,x2,x3,y1,y2,y3,
               z1,z2,z3,u1,u2,u3,v1,v2,v3,
               dy,x_1,x_2,u_1,u_2,v_1,v_2,z_1,z_2,
               xlu_step,ulu_step,vlu_step,zlu_step,
               xld_step,uld_step,vld_step,zld_step,
               xru_step,uru_step,vru_step,zru_step,
               xrd_step,urd_step,vrd_step,zrd_step,
               f,xres,yres,subPix,
               d1x,d1y,d2x,d2y  : single;
               temp : BTBitmap;

begin
   if not assigned(Texture) then exit;
   BeginGDI;

   if TextureMapSmooth > 2 then TextureMapSmooth := 0;

   temp := BTBitmap.Create;
   xres := GetXlng;
   yres := GetYlng;
   temp.Init(round(xres),1,texture.bpp,@texture.RGBmask);
   Temp.Alpha := Texture.Alpha;
   Temp.ColorOff := Texture.ColorOff;
   Temp.Transparent := Texture.Transparent;


   x1 := p1.x;   x2 := p2.x;   x3 := p3.x;
   y1 := p1.y;   y2 := p2.y;   y3 := p3.y;

   // Clockvise test  BACK face remover
   d1x := x3 - x1;
   d1y := y3 - y1;
   d2x := x3 - x2;
   d2y := y3 - y2;
   if ((d1x*d2y)-(d1y*d2x)) < 0 then
   begin
      temp.Free;
      EndGDI;
      Exit;
   end;


   f := 0;
   if P1.z = 0 then f := 640000;
   z1 := 1 / (p1.z+f);
   f := 0;
   if P2.z = 0 then f := 640000;
   z2 := 1 / (p2.z+f);
   f := 0;
   if P3.z = 0 then f := 640000;
   z3 := 1 / (p3.z+f);

   u1 := P1.u*z1;   u2 := P2.u*z2;   u3 := P3.u*z3;    // U' = U / Z
   v1 := P1.v*z1;   v2 := P2.v*z2;   v3 := P3.v*z3;    // intr  U = U'/Z

   // triangle sorter

   if (y1>y2) then
   begin
      j:=y2;y2:=y1;y1:=j;j:=x2;x2:=x1;x1:=j;
      j:=u2;u2:=u1;u1:=j;j:=v2;v2:=v1;v1:=j;
      j:=z2;z2:=z1;z1:=j;
   end;

   if (y2>y3) then
   begin
      j:=y3;y3:=y2;y2:=j;j:=x3;x3:=x2;x2:=j;
      j:=u3;u3:=u2;u2:=j;j:=v3;v3:=v2;v2:=j;
      j:=z3;z3:=z2;z2:=j;
   end;

   if (y1>y2) then
   begin
      j:=y2;y2:=y1;y1:=j;j:=x2;x2:=x1;x1:=j;
      j:=u2;u2:=u1;u1:=j;j:=v2;v2:=v1;v1:=j;
      j:=z2;z2:=z1;z1:=j;
   end;

   // Get The Midle point in X
   if (abs(y2-y1)>=1) then x:=((x3-x1)/(y3-y1))*y2+x1  else x:= x1;

   if (x2<x) then
   begin

{     // face type LLR
      //      1
      //     /|
      //   2/ |
      //    \ |
      //     \|
      //      3
}

      dy:= y2-y1;
      if (abs(dy)>=1) then
      begin                           // Left Up
         xlu_step := (x2 - x1)/dy;
         ulu_step := (u2 - u1)/dy;
         vlu_step := (v2 - v1)/dy;
         zlu_step := (z2 - z1)/dy;
      end;

      dy:= y3-y2;
      if (abs(dy)>=1) then
      begin                          // left down
         xld_step := (x3 - x2)/dy;
         uld_step := (u3 - u2)/dy;
         vld_step := (v3 - v2)/dy;
         zld_step := (z3 - z2)/dy;
      end;

      dy:= y3-y1;
      if (abs(dy)>=1) then
      begin                         // right Up down
         xru_step := (x3 - x1)/dy;
         uru_step := (u3 - u1)/dy;
         vru_step := (v3 - v1)/dy;
         zru_step := (z3 - z1)/dy;

         xrd_step := xru_step;
         urd_step := uru_step;
         vrd_step := vru_step;
         zrd_step := zru_step;
      end;

   end {x2<x} else begin

{     // face type LRR
      //    1
      //    |\
      //    | \2
      //    | /
      //    |/
      //    3
}
      dy:= y2-y1;
      if (abs(dy)>=1) then
      begin                               // Right up
         xru_step := (x2 - x1)/dy;
         uru_step := (u2 - u1)/dy;
         vru_step := (v2 - v1)/dy;
         zru_step := (z2 - z1)/dy;
      end;

      dy:= y3-y2;                        // right down
      if (abs(dy)>=1) then
      begin
         xrd_step := (x3 - x2)/dy;
         urd_step := (u3 - u2)/dy;
         vrd_step := (v3 - v2)/dy;
         zrd_step := (z3 - z2)/dy;
      end;

      dy:= y3-y1;
      if (abs(dy)>=1) then
      begin                              // left up down
         xlu_step := (x3 - x1)/dy;
         ulu_step := (u3 - u1)/dy;
         vlu_step := (v3 - v1)/dy;
         zlu_step := (z3 - z1)/dy;

         xld_step := xlu_step;
         uld_step := ulu_step;
         vld_step := vlu_step;
         zld_step := zlu_step;
      end;
   end;

   //begin from top -------------------------- TOP PART
   y := y1;


   // Screen pixel Adjustments (some call this "sub-pixel accuracy")
   subPix := (Trunc(y)) - y;
   x_1 := x1 + xlu_step * subPix;
   u_1 := u1 + ulu_step * subPix;
   v_1 := v1 + vlu_step * subPix;
   z_1 := z1 + zlu_step * subPix;

   x_2 := x1 + xru_step * subPix;  // start from one point
   u_2 := u1 + uru_step * subPix;
   v_2 := v1 + vru_step * subPix;
   z_2 := z1 + zru_step * subPix;



   // clip and draw
   while (y < y2) and ( y < yres) do  //y2*xres) and ( y < xres*yres) do
   begin

      if (y >=0 ) then  scan_line(x_1,x_2,u_1,u_2,v_1,v_2,z_1,z_2,Round(y),Trunc(xres),texture,temp);
      y := y + 1;

      // interpolation
      x_1 := x_1 + xlu_step;
      u_1 := u_1 + ulu_step;
      v_1 := v_1 + vlu_step;
      z_1 := z_1 + zlu_step;

      x_2 := x_2 + xru_step;
      u_2 := u_2 + uru_step;
      v_2 := v_2 + vru_step;
      z_2 := z_2 + zru_step;

   end;

   if (y1 = y2) then  // in case y1 = y1 Top is a line
   begin

      subPix := (Trunc(y)) - y;
      x_1 := x1 + xld_step * subPix;
      u_1 := u1 + uld_step * subPix;
      v_1 := v1 + vld_step * subPix;
      z_1 := z1 + zld_step * subPix;

      x_2 := x2 + xrd_step * subPix;
      u_2 := u2 + urd_step * subPix;
      v_2 := v2 + vrd_step * subPix;
      z_2 := z2 + zrd_step * subPix;

      if (x2 < x) then
      begin
         j:=x_1;x_1:=x_2;x_2:=j;
         j:=u_1;u_1:=u_2;u_2:=j;
         j:=v_1;v_1:=v_2;v_2:=j;
         j:=z_1;z_1:=z_2;z_2:=j;
      end;
   end;

   y := y2; //*xres;

   while (y < y3) and (y < yres) do
   begin
//debuggdi('bz_1 = ',z_1);
//debuggdi('bz_2 = ',z_2);

      if (y>=0) then scan_line(x_1,x_2,u_1,u_2,v_1,v_2,z_1,z_2,Round(y),Trunc(xres), texture,temp);
      y := y + 1;

      // interpolate
      x_1 := x_1 + xld_step;
      u_1 := u_1 + uld_step;
      v_1 := v_1 + vld_step;
      z_1 := z_1 + zld_step;

      x_2 := x_2 + xrd_step;
      u_2 := u_2 + urd_step;
      v_2 := v_2 + vrd_step;
      z_2 := z_2 + zrd_step;

   end;
   temp.free;
   EndGDI;
end;



{///////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

    (\~~/)   Hi from BOGI with LOVE to my vife  / this my code :]
   (='.'=)
   (")_(")~~o

}



function  CreateAnimation(bmp:BTBitmap; sprXlng,sprYlng,StartPic,EndPic:longword):dword;  // return handle
var p:PBTPicAnimation;
begin
   GetMem(p,sizeof(BTPicAnimation));
   if p <> nil then
   begin
      p.pwd := $1045AEFF;
      p.PXpos        := 0;  // offset of first picture
      p.PYpos        := 0;
      p.PXlng        := sprXlng;  // size of picture
      p.PYlng        := sprYlng;
      p.Xmod         := bmp.Xlng div sprXlng;  // count of columns
      if p.Xmod = 0 then p.PXlng := 0;
      p.Ymod         := bmp.Ylng div sprXlng;  // count of rows
      if p.Ymod = 0 then p.PYlng := 0;
      p.BeginPic     := StartPic;  // start picture index   ( start from 1)
      p.EndPic       := EndPic;  // last picture index
      p.CurrentPic   := 1;  // current drawn picture
   end;
   CreateAnimation := dword(P);
end;

function  CreateAnimationRect(bmp:BTBitmap; Xpos,Ypos,Xlng,Ylng,sprXlng,sprYlng,StartPic,EndPic:longword):dword;
var p:PBTPicAnimation;
begin
   GetMem(p,sizeof(BTPicAnimation));
   if p <> nil then
   begin
      p.pwd := $1045AEFF;
      p.PXpos        := Xpos;  // offset of first picture
      p.PYpos        := Ypos;
      p.PXlng        := sprXlng;  // size of picture
      p.PYlng        := sprYlng;
      p.Xmod         := Xlng div sprXlng;  // count of columns
      if (Xlng + Xpos - 1) > bmp.Xlng then p.Pxlng := 0;  // stop not corect data
      p.Ymod         := bmp.Ylng div sprXlng;  // count of rows
      if (Ylng + Ypos - 1) > bmp.Ylng then p.Pylng := 0;  // stop not corect data
      p.BeginPic     := StartPic;  // start picture index   ( start from 1)
      p.EndPic       := EndPic;  // last picture index
      p.CurrentPic   := 1;  // current drawn picture
   end;
   CreateAnimationRect := dword(P);
end;

procedure ChangeAnimationCurrent(hand:dword; Current:longword);
var p:PBTPicAnimation;
begin
   if hand = 0 then exit;
   p := pointer(hand);
   if p.pwd = $1045AEFF then
   begin
      if (Current >= p.BeginPic) and (Current <= p.EndPic) then  p.CurrentPic := Current;
   end;
end;

procedure DeleteAnimation(hand:dword);
var p:PBTPicAnimation;
begin
   if hand = 0 then exit;
   p := pointer(hand);
   if p.pwd = $1045AEFF then
   begin
      FreeMem(p,sizeof(BTPicAnimation));
   end;
end;


Constructor BTBitmap.Create;
begin
   inherited Create;
   aAlpha := 255;
   aCanvas := BTCanvas.Create;
   aCanvas.AttachToBitmap := self;
   Animation := 0;
   init(10,10,32,nil);
end;

Destructor  BTBitmap.Destroy;
begin
   Canvas.Free;
   inherited Destroy;
end;

procedure   BTBitmap.FilterRegion(X,Y,Xl,Yl:longint);
begin
   aFX := X;
   aFY := Y;
   if (Xl + Yl) <> 0 then
   begin
      aFXlng := Xl;
      aFYlng := Yl;
   end else begin
      aFXlng := self.Xlng;
      aFYlng := self.Ylng;
   end;
end;

procedure   BTBitmap.SetAlpha(value:dword);
begin
   aAlpha := value and 255;
end;

                         //?????????????????????????????????????
                         // allocate bitmap for given window
procedure   BTBitmap.GetHandle(ownerHandle:dword);
var BP,XX,YY,wdc:dword;
    Mask:BTRGBMask;
    re :TRECT;
begin
   XX := 1;
   YY := 1;
   if ownerHandle <> 0 then
   begin
      GetClientRect(ownerHandle,re);
      XX := re.Right;
      YY := re.Bottom;
   end;
   wdc := CreateCompatibleDC(0);
   BP := GetDeviceCaps(ownerHandle,BITSPIXEL);  // get system DC;
   DeleteDC(wdc);
   Mask.Amask := 0;
   Mask.Rmask := rgb(255,0,0);
   Mask.Gmask := rgb(0,255,0);
   Mask.Bmask := rgb(0,0,255);
   init(XX,YY,BP,@Mask);
   FilterRegion(0,0,XX,YY);   
end;


function    BTBitmap.Init(Xres,Yres,Bpp :Dword; RGBmask:PBTRGBmask):dword;
var res:dword;
    Mask:BTRGBMask;
begin
   Mask.Amask := 0;
   Mask.Rmask := rgb(255,0,0);
   Mask.Gmask := rgb(0,255,0);
   Mask.Bmask := rgb(0,0,255);
//   if RGBmask = nil then RGBmask := @mask;

   res := inherited Init(Xres,Yres,Bpp,RGBmask);
///   Canvas.Handle := H_DC; //todo
   FilterRegion(0,0,Xres,Yres);
   Init := res;
end;

function    BTBitmap.Init(Xres,Yres,Bpp :dword):dword;
begin
   FilterRegion(0,0,Xres,Yres);
   result := self.Init(Xres,Yres,Bpp,nil);
end;

function    BTBitmap.Init(Xin_mm,Yin_mm,Dpi,Bpp :dword):dword;
begin
   // 1 m = 39.3700787 inch
   // 1000 mm = 1 m
   // 1 mm =  0,0393700787 inch
   // X from mm to inc
   Xin_mm := round((Xin_mm * 0.0393700787) * dpi);
   Yin_mm := round((Yin_mm * 0.0393700787) * dpi);
   FilterRegion(0,0,Xin_mm,Yin_mm);
   result := self.Init(Xin_mm,Yin_mm,Bpp,nil);
end;


procedure   BTBitmap.AutoTransparent;
begin
   if Handle <> 0 then
   begin
      Transparent := true;
      ColorOff := Pixels[0,0];
   end;
end;





// SIMPLE   F I L T E R S    ///////////////////////////////////////////////////

function IntToByte(i:Integer):Byte;
begin
  if      i>255 then Result:=255
  else if i<0   then Result:=0
  else               Result:=i;
end;


procedure BTBitmap.GrayScale;
var X,Y:dword;
    A,R,G,B:dword;
begin
   for Y := 0 to Ylng - 1 do
   begin
     for X := 0 to Xlng - 1 do
     begin
        color2rgb(Pixels[X,Y],A,R,G,B);
        r := round( r * 0.299 + g * 0.587 + b * 0.114);
        r := IntToByte(integer(r));
        Pixels[X,Y] := rgb2color(A,R,R,R);
     end;
   end;
end;

procedure BTBitmap.Colorize(rgb_value :dword);
var X,Y:dword;
    A,R,G,B,I:dword;
    R1,G1,B1:dword;
begin
   R1 := GetRvalue(rgb_value);
   G1 := GetGvalue(rgb_value);
   B1 := GetBvalue(rgb_value);
   for Y := 0 to Ylng - 1 do
   begin
     for X := 0 to Xlng - 1 do
     begin
        color2rgb(Pixels[X,Y],A,R,G,B);
        r := round( r * 0.299 + g * 0.587 + b * 0.114);
        Pixels[X,Y] := rgb2color(A,IntToByte((R*R1) div 256 ),
                                   IntToByte((R*G1) div 256 ),
                                   IntToByte((R*B1) div 256 ));
     end;
   end;
end;

procedure BTBitmap.Lightness(Amount: Integer);
var X,Y:dword;
    A,R,G,B:dword;
begin
   for Y := 0 to Ylng - 1 do
   begin
     for X := 0 to Xlng - 1 do
     begin
        color2rgb(Pixels[X,Y],A,R,G,B);
        Pixels[X,Y] := rgb2color(A,IntToByte(integer(r)+((255-integer(r))*Amount)div 255),
                                   IntToByte(integer(g)+((255-integer(g))*Amount)div 255),
                                   IntToByte(integer(b)+((255-integer(b))*Amount)div 255));
     end;
   end;
end;


procedure BTBitmap.Darkness(Amount: Integer);
var X,Y:dword;
    A,R,G,B:dword;
begin
   for Y := 0 to Ylng - 1 do
   begin
     for X := 0 to Xlng - 1 do
     begin
        color2rgb(Pixels[X,Y],A,R,G,B);
        Pixels[X,Y] := rgb2color(A,IntToByte(integer(r)-(integer(r)*Amount)div 255),
                                   IntToByte(integer(g)-(integer(g)*Amount)div 255),
                                   IntToByte(integer(b)-(integer(b)*Amount)div 255));
     end;
   end;
end;

procedure BTBitmap.Blinds(Amount: Integer);
var X,Y:dword;
    A,R,G,B:dword;
begin
   for Y := 0 to Ylng - 1 do
   begin
     for X := 0 to Xlng - 1 do
     begin
        if ( Y and 1 ) = 0 then
        begin
           color2rgb(Pixels[X,Y],A,R,G,B);
           Pixels[X,Y] := rgb2color(A,IntToByte(integer(r)-(integer(r)*Amount)div 255),
                                      IntToByte(integer(g)-(integer(g)*Amount)div 255),
                                      IntToByte(integer(b)-(integer(b)*Amount)div 255));
        end;
     end;
   end;
end;

procedure BTBitmap.Mosaic(Amount: Integer);
var
   x,y,y1,i,j:integer;
   a,r,g,b:dword;
begin
  y:=0;
  repeat
    x:=0;
    repeat
      j:=1;
      y1 := y;      
      repeat
         x:=0;
         repeat
           color2rgb(Pixels[X,Y1],A,R,G,B);
           i:=1;
           repeat
              Pixels[X,Y] := rgb2color(A,R,G,B);
              inc(x);
              inc(i);
           until ( x >= Xlng) or (i > Amount);
         until x >= Xlng;
         inc(j);
         inc(y);
      until (y >= Ylng) or (j > Amount);
    until (y >= Ylng) or (x > Xlng);
  until y >= Ylng;
end;

procedure BTBitmap.Saturation(Amount: Integer);
var X,Y:dword;
    A,R,G,B:dword;
    Gray:Integer;
begin
   for Y := 0 to Ylng - 1 do
   begin
     for X := 0 to Xlng - 1 do
     begin
        color2rgb(Pixels[X,Y],A,R,G,B);
        Gray:=(r+g+b)div 3;
        Pixels[X,Y] := rgb2color(A,IntToByte(Gray+(((integer(r)-Gray)*Amount)div 255)),
                                   IntToByte(Gray+(((integer(g)-Gray)*Amount)div 255)),
                                   IntToByte(Gray+(((integer(b)-Gray)*Amount)div 255)));
     end;
   end;
end;

procedure BTBitmap.Brightness(Amount: Integer); //(-255,0,255)
var X,Y:dword;
    A,R,G,B:dword;
    LookUp : array [0..255] of integer;
    I : integer;
begin
   if Amount < -255 then Amount := -255;
   if Amount > 255 then Amount := 255;
   for I := 0 to 255 do LookUp[I] := IntToByte(I+Amount);

   for Y := 0 to Ylng - 1 do
   begin
     for X := 0 to Xlng - 1 do
     begin
        color2rgb(Pixels[X,Y],A,R,G,B);
        Pixels[X,Y] := rgb2color(A,LookUp[R],LookUp[G],LookUp[B]);
      end;
   end;
end;

procedure BTBitmap.Contrast(Amount: Integer);  //(-255,0,255)
var X,Y:dword;
    A,R,G,B:dword;
    LookUp : array [0..255] of integer;
    I : integer;
begin
   if Amount < -255 then Amount := -255;
   if Amount > 255 then Amount := 255;
   for I:=0   to 126 do LookUp[i]:=IntToByte(i-((Abs(128-i)*Amount)div 256));
   for I:=127 to 255 do LookUp[i]:=IntToByte(i+((Abs(128-i)*Amount)div 256));
   for Y := 0 to Ylng - 1 do
   begin
     for X := 0 to Xlng - 1 do
     begin
        color2rgb(Pixels[X,Y],A,R,G,B);
        Pixels[X,Y] := rgb2color(A,LookUp[R],LookUp[G],LookUp[B]);
      end;
   end;
end;

procedure BTBitmap.Mirror;
var X,Y:dword;
    C,DX:dword;
begin
   DX := Xlng div 2;
   for Y := 0 to Ylng - 1 do
   begin
     for X := 0 to DX - 1 do
     begin
        C := Pixels[X,Y];
        Pixels[X,Y] := Pixels[Xlng - X - 1, Y];
        Pixels[Xlng - X - 1, Y] := C;
     end;
   end;
end;

procedure BTBitmap.Flip;
var X,Y:dword;
    C,DY:dword;
begin
   DY := Ylng div 2;
   for Y := 0 to DY - 1 do
   begin
     for X := 0 to Xlng - 1 do
     begin
        C := Pixels[X,Y];
        Pixels[X,Y] := Pixels[X,Ylng - Y -1];
        Pixels[X,Ylng - Y -1] := C;
     end;
   end;
end;

// Typ = 0 Mono   Typ 1 = color
//
procedure BTBitmap.Noise(Amount, Typ: Integer);
var X,Y:dword;
    A,R,G,B:dword;
    Gray,Gray2,Gray3:Integer;
begin
   Typ := Typ and 1;
   Randomize;
   for Y := 0 to Ylng - 1 do
   begin
     for X := 0 to Xlng - 1 do
     begin
        color2rgb(Pixels[X,Y],A,R,G,B);
        if Typ = 0 then
        begin
          Gray:=Random(Amount)-(Amount shr 1);
          Gray2 := Gray;
          GRay3 := Gray;
        end else begin
          Gray:=Random(Amount)-(Amount shr 1);
          Gray2:=Random(Amount)-(Amount shr 1);
          Gray3:=Random(Amount)-(Amount shr 1);
        end;
        Pixels[X,Y] := rgb2color(A,IntToByte(Gray+R),
                                   IntToByte(Gray2+G),
                                   IntToByte(Gray3+B));
     end;
   end;
end;


procedure BTBitmap.Treshhold(Amount: Integer);
var X,Y:dword;
    A,R,G,B:dword;
    Gray:Integer;
begin
   for Y := 0 to Ylng - 1 do
   begin
     for X := 0 to Xlng - 1 do
     begin
        color2rgb(Pixels[X,Y],A,R,G,B);
        Gray := round( r * 0.299 + g * 0.587 + b * 0.114);
        if Gray < Amount then
        begin
           R := 0;  G := 0;     B := 0;
//           R := Amount div 2;  G :=  Amount div 2;   B :=  Amount div 2;
        end else begin
           R := 255;  G := 255;     B := 255;
        end;
        Pixels[X,Y] := rgb2color(A,R,G,B);
     end;
   end;
end;

procedure BTBitmap.Posterize(Amount: Integer);  // 0..255
var X,Y:dword;
    A,R,G,B:dword;
    I : dword;
begin
   if Amount <= 0 then Amount := 1;
   for Y := 0 to Ylng - 1 do
   begin
     for X := 0 to Xlng - 1 do
     begin
        color2rgb(Pixels[X,Y],A,R,G,B);
        Pixels[X,Y] := rgb2color(A,(R div Amount)*Amount,(G div Amount)*Amount,(B div Amount)*Amount);
      end;
   end;
end;


procedure BTBitmap.OldLook;

   procedure MinMaxInt3(const Value1,Value2,Value3:  INTEGER; var min, max:  INTEGER);
   begin
       if   Value1 > Value2
       then begin
         if   Value1 > Value3
         then max := Value1
         else max := Value3;

         if   Value2 < Value3
         then min := Value2
         else min := Value3
       end
       else begin
         if   Value2 > Value3
         then max := Value2
         else max := Value3;

         if   Value1 < Value3
         then min := Value1
         else min := Value3
       end
   end;

   function RGBLightness(R,G,B:integer):  INTEGER;
   var   min:  INTEGER;
         max:  INTEGER;
   begin
     MinMaxInt3(R, G, B, min, max);
     RESULT := (min + max) div 2
   end ;

var X,Y:dword;
    A,R,G,B:dword;

begin
   for Y := 0 to Ylng - 1 do
   begin
     for X := 0 to Xlng - 1 do
     begin
        color2rgb(Pixels[X,Y],A,R,G,B);
        Pixels[X,Y] := rgb2color(A,IntToByte(RGBLightness(R,G,B)),G,B);
        color2rgb(Pixels[X,Y],A,R,G,B);
        Pixels[X,Y] := rgb2color(A,R,IntToByte(RGBLightness(R,G,B)),B);
        color2rgb(Pixels[X,Y],A,R,G,B);
        Pixels[X,Y] := rgb2color(A,R,G,IntToByte(RGBLightness(R,G,B)));
      end;
   end;
end;



procedure BTBitmap.Gamma(Amount :Integer); // 0..255;
var X,Y:dword;
    A,R,G,B:dword;
    LookUp : array [0..255] of integer;
    I : integer;
    aGamma : real;
begin
   if Amount < 0 then Amount := 0;
   if Amount > 255 then Amount := 255;
   aGamma := (256 - Amount) / 255;
   LookUp[0] := 0;
   for I:=1 to 255 do LookUp[i]:=IntToByte(Round(255* exp (aGamma * ln(I/255))+0.5));

   for Y := 0 to Ylng - 1 do
   begin
     for X := 0 to Xlng - 1 do
     begin
        color2rgb(Pixels[X,Y],A,R,G,B);
        Pixels[X,Y] := rgb2color(A,LookUp[R],LookUp[G],LookUp[B]);
      end;
   end;
end;

procedure BTBitmap.Chanel(ch : dword);
var X,Y:dword;
    A,R,G,B:dword;
begin
   for Y := 0 to Ylng - 1 do
   begin
     for X := 0 to Xlng - 1 do
     begin
        color2rgb(Pixels[X,Y],A,R,G,B);
        case ch of
         1 : begin       G:=0; B:=0; end; // Red
         2 : begin R:=0;       B:=0; end; // Green
         3 : begin R:=0; G:=0;       end; // Blue
         4 : begin G:= (G+B) div 2; B:= G; R:=0; end;
         5 : begin R:= (R+G) div 2; G:= R; B:=0; end;
         6 : begin R:= (R+B) div 2; B:= R; G:=0; end;
        end;
        Pixels[X,Y] := rgb2color(A,R,G,B);
      end;
   end;
end;

procedure BTBitmap.Negativ;
var X,Y:dword;
    A,R,G,B:dword;
begin
   for Y := 0 to Ylng - 1 do
   begin
     for X := 0 to Xlng - 1 do
     begin
        color2rgb(Pixels[X,Y],A,R,G,B);
        Pixels[X,Y] := rgb2color(A,not R,not G,not B);
      end;
   end;
end;


procedure BTBitmap.Trace(Amount :integer);
var
  x,y,i : integer;
  tb,TraceB :byte;
  hasb :boolean;
  bitmap :BTBitmap;
begin
  bitmap := BTBitmap.create;
  bitmap.Init(Xlng,Ylng,8,nil);
  self.DrawTo(bitmap.GetDC,0,0);
  hasb := false;
  TraceB := $00;
  for i := 1 to Amount do
  begin
    for y := 0 to BitMap.Ylng -2 do
    begin
      x:=0;
      repeat
        if Bitmap.Pixels[x,y] <> Bitmap.Pixels[x+1,y] then
        begin
           if not hasb then
           begin
             tb := Bitmap.Pixels[x+1,y];
             hasb := true;
             Pixels[x,y] := TraceB;
           end else begin
             if Bitmap.Pixels[x,y] <> tb then
             begin
                Pixels[x,y] := TraceB;
             end else begin
                Pixels[x+1,y] := TraceB;
             end;
          end;
        end;
        if Bitmap.Pixels[x,y] <> Bitmap.Pixels[x,y+1] then
        begin
           if not hasb then
           begin
             tb := Bitmap.Pixels[x,y+1];
             hasb := true;
             Pixels[x,y] := TraceB;
           end else begin
             if Bitmap.Pixels[x,y] <> tb then
             begin
                 Pixels[x,y] := TraceB;
             end else begin
                 Pixels[x,y+1] := TraceB;
             end;
           end;
        end;
        inc(x);
      until x >= (Xlng -2);
    end;
    if i > 1 then
    for y := Ylng - 1 downto 1 do begin
      x := Xlng - 1;
      repeat
        if Bitmap.Pixels[x,y] <> Bitmap.Pixels[x-1,y] then
        begin
           if not hasb then
           begin
             tb := Bitmap.Pixels[x-1,y];
             hasb := true;
             Pixels[X,Y] := TraceB;
           end else begin
             if Bitmap.Pixels[x,y] <> tb then
             begin
                Pixels[X,Y] := TraceB;
             end else begin
                Pixels[X-1,Y] := TraceB;
             end;
           end;
        end;
        if Bitmap.Pixels[x,y] <> Bitmap.Pixels[x,y-1] then
        begin
           if not hasb then
           begin
             tb := Bitmap.Pixels[x,y-1];
             hasb := true;
             Pixels[x,y] := TraceB;
           end else begin
             if Bitmap.Pixels[x,y] <> tb then
             begin
                Pixels[x,y] := TraceB;
             end else begin
                Pixels[x,y-1] := TraceB;
             end;
           end;
        end;
        dec(x);
      until x <= 1;
    end;
  end;
  bitmap.free;
end;

procedure BTBitmap.Smear(Typ,Amount,Angle,Alpha : integer);
var density,scatter,mix : real;
    distance : integer;
    sinAngle,cosAngle : real;
    Temp : BTBitmap;
    i,numShapes : integer;
    X,Y,Leng,x1,y1 : integer;
    a,r,g,b,ar,ag,ab : dword;
    radius, radius2: integer;
    f : integer;
    sx,sy : integer;
    x0,y0,dx,dy : integer;
    d, incrE, incrNE, ddx, ddy : integer;

procedure MixColors(mix : real; r,g,b:dword; var ar,ag,ab:dword);
begin
   ar := IntToByte(Round((ar * mix) + (r * ( 1 - mix)) ));
   ag := IntToByte(Round((ag * mix) + (g * ( 1 - mix)) ));
   ab := IntToByte(Round((ab * mix) + (b * ( 1 - mix)) ));
end;

begin
   Temp := BTBitmap.Create;
   Temp.Init(Xlng,Ylng,Bpp,nil);
   self.DrawTo(Temp.GetDC,0,0);
   density := 0.5;
	 scatter := 0.0;
   distance := Amount;
   if distance = 0 then distance := 8;
//   seed := 567;
   Alpha := Alpha and $FF;
   mix := Alpha / 255;
//   mix := 0.4;

   sinAngle := sin(angle * Rad)*-1;
   cosAngle := cos(angle* Rad);

   if Typ = 0 then  // CROSSES
   begin
     	numShapes := Round(( 2 * density * Xlng * Ylng) / (distance + 1));
			for i := 0 to numShapes do
      begin
				 x := random(MaxInt) mod Xlng;
				 y := random(MaxInt) mod Ylng;
				 leng := (random(MaxInt) mod distance) + 1;
         color2rgb(Pixels[X,Y],A,r,g,b);
         for x1 := x - leng to x + leng do
         begin
  					if (x1 >= 0) and (x1 < Xlng) then
            begin
               color2rgb(Pixels[X1,Y],A,Ar,Ag,Ab);
               mixColors(mix, r,g,b, ar,ag,ab);
               Temp.Pixels[X1,Y] := rgb2color(A,ar,ag,ab);
					  end;
				 end;
         for y1 := y - leng to y + leng do
         begin
					 if (y1 >= 0) and (y1 < Ylng) then
           begin
               color2rgb(Pixels[X,Y1],A,Ar,Ag,Ab);
               mixColors(mix, r,g,b, ar,ag,ab);
               Temp.Pixels[X,Y1] := rgb2color(A,ar,ag,ab);
					end;
				end;
			end;
   end;


   if (Typ = 1) then // LINES
   begin
      numShapes := Round((2 * density * Xlng * Ylng) / 10);
			for i := 0 to numShapes do
      begin
				 sx := random(MaxInt) mod Xlng;
				 sy := random(MaxInt) mod Ylng;
         color2rgb(Pixels[X,Y],A,r,g,b);
 				 leng := (random(MaxInt) mod distance) + 1;
         dx := Round( leng * cosAngle);
         dy := Round( leng * sinAngle);

				 x0 := sx-dx;
				 y0 := sy-dy;
				 x1 := sx+dx;
				 y1 := sy+dy;

				 if (x1 < x0) then 	ddx := -1
              				else	ddx := 1;
         if (y1 < y0) then 	ddy := -1
                      else 	ddy := 1;
         dx := x1-x0;
				 dy := y1-y0;
				 dx := abs(dx);
				 dy := abs(dy);
				 x := x0;
				 y := y0;

				 if (x < Xlng) and (x >= 0) and (y < Ylng) and (y >= 0) then
         begin
             color2rgb(Pixels[X,Y],A,Ar,Ag,Ab);
             mixColors(mix, r,g,b, ar,ag,ab);
             Temp.Pixels[X,Y] := rgb2color(A,ar,ag,ab);
			   end;
				 if (abs(dx) > abs(dy)) then
         begin
					d := 2*dy-dx;
					incrE := 2*dy;
					incrNE := 2*(dy-dx);

					while (x <> x1) do
          begin
						if (d <= 0) then d := d + incrE
            		 		  	else begin
                 						 d := d +  incrNE;
                             y := y + ddy;
            						end;
						x := x + ddx;
            if (x < Xlng) and (x >= 0) and (y < Ylng) and (y >= 0) then
            begin
               color2rgb(Pixels[X,Y],A,Ar,Ag,Ab);
               mixColors(mix, r,g,b, ar,ag,ab);
               Temp.Pixels[X,Y] := rgb2color(A,ar,ag,ab);
		        end;

					end
				 end else begin
					d := 2*dx-dy;
					incrE := 2*dx;
					incrNE := 2*(dx-dy);

					while (y <> y1) do
          begin
						if (d <= 0) then d := d + incrE
                        else begin
                             d := d + incrNE;
                             x := x + ddx;
						            end;
						y := y +  ddy;
            if (x < Xlng) and (x >= 0) and (y < Ylng) and (y >= 0) then
            begin
               color2rgb(Pixels[X,Y],A,Ar,Ag,Ab);
               mixColors(mix, r,g,b, ar,ag,ab);
               Temp.Pixels[X,Y] := rgb2color(A,ar,ag,ab);
		        end;
					end;
				end;
			end;

   end;


   if (Typ = 2) or (Typ = 3) then // SQUARES:  CIRCLES:
   begin
			radius := distance+1;
			radius2 := radius * radius;
			numShapes := Round( 2 * density * Xlng * Ylng / radius);
			for i := 0 to numShapes do
      begin
 				 x1 := random(MaxInt) mod Xlng;
				 y1 := random(MaxInt) mod Ylng;
         color2rgb(Pixels[X,Y],A,r,g,b);
		     for x := x1 - radius to x1 + radius do
         begin
					  for y := y1 - radius to y1 + radius do
            begin
               if (typ = 3) then 	f := (x - x1) * (x - x1) + (y - y1) * (y - y1) // CIRCLES
                						else	f := 0;
               if (x >= 0) and (x < Xlng) and (y >= 0) and (y < Ylng) and (f <= radius2) then
               begin
                  color2rgb(Pixels[X,Y],A,Ar,Ag,Ab);
                  mixColors(mix, r,g,b, ar,ag,ab);
                  Temp.Pixels[X,Y] := rgb2color(A,ar,ag,ab);
						   end;
					  end;
				 end;
			end;
	 end;


   Temp.DrawTo(Canvas.Handle,0,0);
   Temp.Free;
end;


type pppdword = array[0..0] of dword;

procedure BTBitmap.OilPaint(Amount: Integer);
var
  paint_image : BTBitmap;
  histogram   : ^pppdword;
  x,y         : dword;
  u,v         : dword;
  k, width    : dword;
  a,r,g,b,c   : dword;
  count       : dword;
const
    MaxRGB = 256;
begin
   width := Amount;
   paint_image := BTBitmap.Create;
   paint_image.Init(Xlng,Ylng,32,nil);
   self.DrawTo(paint_image.GetDC,0,0);

   // Allocate histogram and scanline.
   getmem(histogram, MaxRGB * sizeof(dword));
   x := 0;
   if histogram <> nil then
   begin
      // Paint each row of the image.
      for y := 0 to Ylng - 1 do
      begin
      for x := 0 to Xlng - 1 do
      begin
         //Determine most frequent color.
         count := 0;
         FillChar(histogram^,MaxRGB*4,0);

         for  v := 0 to width do
         begin
            for u := 0 to width do
            begin
              color2rgb(Pixels[X+U,Y+V],A,R,G,B);
              k := Round(R*0.3+G*0.59+B*0.11);
              inc(histogram[k]);
              if histogram[k] > count then
              begin
                 paint_image.Pixels[X,Y] := Pixels[X+U,Y+V];
                 count := histogram[k];
              end;
            end;
         end; // U V end
      end; // X end
      end; // Y end
      freemem(histogram, MaxRGB * sizeof(dword));
   end;
   paint_image.DrawTo(Canvas.Handle,0,0);
   paint_image.Free;
end;


procedure BTBitmap.Art;
var X,Y:dword;
    A,R,G,B:dword;
    Temp : BTBitmap;
    C,Xp,Yp,Xl,Yl,i : integer;
    Brush,OB,Pen :Dword;
    points : array [0..128] of Tpoint;
begin
//   RAndomize;
   RandSeed := 10;
   Temp := BTBitmap.Create;
   Temp.Init(Xlng,Ylng,Bpp,nil);
   Pen := SelectObject(Temp.GetDC,GetStockObject(NULL_PEN));
   SetPolyFillMode(Temp.GetDC,ALTERNATE);//WINDING);
   for Y := 0 to Ylng - 1 do
   begin
        for X := 0 to Xlng + 1 do
        begin
              color2rgb(Pixels[X+Random(2),Y+Random(2)],A,R,G,B);
              Xp := X + Random(4)+(-1*Random(1));
              Yp := Y + Random(4)+(-1*Random(1));
              Brush := createSolidBrush(rgb(R,G,B));
              OB := SelectObject(Temp.GetDC,Brush);
                Windows.Ellipse(Temp.GetDC,xp,yp,xp+4+random(4),yp+4+random(4));
              DeleteObject(SelectObject(Temp.GetDC,OB));
        end;
   end;
   SelectObject(Temp.GetDC,Pen);
   Temp.DrawTo(Canvas.Handle,0,0);
   Temp.Free;
end;


type rgb9mat = array [0..8] of dword;

function rgbMedian(var R,G,B:rgb9mat):integer;
var i,j:integer;
    sum,index,min:integer;
begin
    index := 0;
    min := Maxint;
		for i := 0 to 8 do
    begin
			sum := 0;
			for j := 0 to 8 do
      begin
				sum := sum + abs(integer(r[i])-integer(r[j]));
				sum := sum + abs(integer(g[i])-integer(g[j]));
				sum := sum + abs(integer(b[i])-integer(b[j]));
			end;
			if (sum < min) then
      begin
				min := sum;
				index := i;
			end;
   end;
   rgbMedian := index;
end;

procedure BTBitmap.ReduceNoise; // Median cut algorithm
var X,Y,A:dword;
    aRGB,R,G,B : rgb9mat;
    k : integer;
    Temp : BTBitmap;
    dy,dx :integer;
    iy,ix : integer;
//    ioffset : integer;
begin
   Temp := BTBitmap.Create;
   Temp.Init(Xlng,Ylng,Bpp,nil);

	 for Y := 0 to Ylng -1 do
   begin
			for x := 0 to XLng -1 do
      begin
				k := 0;
				for dy := -1 to 1 do
        begin
					iy := y + dy;
					if (0 <= iy) and (iy < Ylng) then
          begin
//						ioffset := iy * Xlng;
						for dx := -1 to 1 do
            begin
							ix := x + dx;
							if (0 <= ix) and (ix < Xlng) then
              begin
								argb[k] := Pixels[ix,iy];
                color2rgb(argb[k],A,r[k],g[k],b[k]);
                inc(k);
              end;
            end;
          end;
				end;
				while (k < 9) do
        begin
					argb[k] := $FF000000;
					r[k] := 0;     g[k] := 0;     b[k] := 0;
					inc(k);
				end;
				Temp.Pixels[X,Y] := argb[rgbMedian(r, g, b)];
	  	end;
   end;

   Temp.DrawTo(Canvas.Handle,0,0);
   Temp.Free;
end;

procedure BTBitmap.WaterColor;
begin
   Gamma(120);
   ReduceNoise;
   ReduceNoise;
   ReduceNoise;
   ReduceNoise;
   Sharpness;
end;


procedure BTBitmap.Edge(Amount: Integer);
var X,Y:dword;
    A,R,G,B:dword;
    A1,R1,G1,B1:dword;
    A2,R2,G2,B2:dword;
    c1, c2:integer;
begin
   for Y := 0 to Ylng - 1 do
   begin
     for X := 0 to Xlng - 1 do
     begin
        color2rgb(Pixels[X,Y],A,R,G,B);
        color2rgb(Pixels[X+1,Y],A1,R1,G1,B1);
        color2rgb(Pixels[X,Y+1],A2,R2,G2,B2);
        c1 := Round(sqrt( (integer(r)-integer(r1))*(integer(r)-integer(r1))+(integer(g)-integer(g1))*(integer(g)-integer(g1)) ));
        c2 := Round(sqrt( (integer(r)-integer(r2))*(integer(r)-integer(r2))+(integer(g)-integer(g2))*(integer(g)-integer(g2)) ));
        if  (c1 >=  Amount) or (c2 >= Amount ) then Pixels[X,Y] := rgb2color(A,0,0,0)
                                               else Pixels[X,Y] := rgb2color(A,255,255,255);
     end;
   end;
end;


const DitMatrix:array[0..7,0..7] of  integer =
   (( 1, 59, 15, 55,  2, 56, 12, 52),
		(33, 17, 47, 31, 34, 18, 44, 28),
		( 9, 49,  5, 63, 10, 50,  6, 60),
		(41, 25, 37, 21, 42, 26, 38, 22),
		( 3, 57, 13, 53,  0, 58, 14, 54),
		(35, 19, 45, 29, 32, 16, 46, 30),
		(11, 51,  7, 61,  8, 48,  4, 62),
		(43, 27, 39, 23, 40, 24, 36, 20));

procedure   BTBitmap.Dither(Typ : integer);
var X,Y:dword;
    A,R,G,B:dword;
    cols,rows,V,i,rc,levels : integer;
    Temp : BTBitmap;
    divs : array [0..255] of integer;
    mods : array [0..255] of integer;
    map : array [0..255] of integer;
begin
   rows := 8;
   cols := 8;
   levels := 12;
   // init precalculations
		for i := 0 to levels -1 do
    begin
			v := (255 * i) div (levels - 1);
			map[i] := v;
		end;
		rc := (rows*cols+1);
		for i := 0 to 255 do
    begin
			divs[i] := ((levels - 1) * i) div 256;
			mods[i] :=  (i * rc) div 256;
		end;


   Temp := BTBitmap.Create;
   Temp.Init(Xlng,Ylng,Bpp,nil);
   for Y := 0 to Ylng - 1 do
   begin
//     cols := y mod cols;
     for X := 0 to Xlng - 1 do
     begin
//        rows := x mod rows;
        V := DitMatrix[Y mod cols,X mod rows];

        color2rgb(Pixels[X,Y],A,R,G,B);

//        R := (R+G+B) div 3;
        if mods[R] > V then I := divs[r]+1 else I := divs[r];
        R := map[I];
//        G := R;
//        B := R;

         if mods[G] > r then I := divs[g]+1 else I := divs[g];
        G := map[I];
//          G := IntToByte(map[I]*(levels+1));
        if mods[B] > r then I := divs[b]+1 else I := divs[b];
        B := map[I];
//          B := IntToByte(map[I]*(levels+1));

        Temp.Pixels[x,y] := rgb2color(A,R,G,B);
     end;
   end;
   Temp.DrawTo(Canvas.Handle,0,0);
   Temp.Free;
end;


procedure BTBitmap.Aritmetic(AritTyp:dword; Xpos,Ypos,Alpha: longint; bmp:BTBitmap); // 0 - Add  1- Modulate
var X,Xl,Y,YL,Xos,Yos,Xod,Yod,PXl,PYl:longint;
    A,R,G,B:dword;
    R1,G1,B1:dword;
    Alp : real;
begin
   XL := Xlng;
   YL := Ylng;
   PXl := bmp.Xlng;
   PYl := bmp.Ylng;

   // D       ----        ------   ------       --------     -----     ----
   // S  ---           -----         ------       -----    ---------         ---
   //     outside        clip       clip         inside      overlap    outsizde
   //
   //

   if Xpos > XL then Exit; // outside;
   Xos := 0;   if Xpos < 0 then begin Xos := Xpos * -1; PXl := PXl + Xpos; end;
   Xod := 0;   if Xpos > 0 then Xod := Xpos;
   if pxl <=  0 then Exit; //outside
   if Xos + PXl > XL then PXl := Xl - Xos + 1;
   if PXl < XL then Xl := PXl;

   if Ypos > YL then Exit; // outside;
   Yos := 0;   if Ypos < 0 then begin Yos := Ypos * - 1; PYl := PYl + Ypos; end;
   Yod := 0;   if Ypos > 0 then Yod := Ypos;
   if pyl <=  0 then Exit; //outside
   if Yos + PYl > YL then PYl := Yl - Yos + 1;
   if PYl < YL then Yl := PYl;

   Alpha := Alpha and $FF;
   Alp := Alpha/255;
   for Y := 0 to Yl -1  do
   begin
      for X := 0 to Xl - 1 do
      begin
         color2rgb(Pixels[X+Xod,Y+Yod],A,R,G,B);
         bmp.color2rgb(bmp.Pixels[X+Xos,Y+Yos],A,R1,G1,B1);
         case AritTyp of
            0: begin // Add
               R := (R + R1) div 2;
               G := (G + G1) div 2;
               B := (B + B1) div 2;
            end;
            1: begin // Modulate
               R := (R * R1) div 256;
               G := (G * G1) div 256;
               B := (B * B1) div 256;
            end;
            2: begin // Alpha
               R := IntToByte(Round((R1 * Alp) + (R*(1-Alp))));
               G := IntToByte(Round((G1 * Alp) + (G*(1-Alp))));
               B := IntToByte(Round((B1 * Alp) + (B*(1-Alp))));
            end;
         end;
         Pixels[X+Xod,Y+Yod] := rgb2color(A,R,G,B);
      end;
   end;
end;

procedure BTBitmap.MotionBlur(Amount, Angle: Integer);
var Temp : BTBitmap;
    X,Y,I:longint;
    A,R,G,B : dword;
    R1,G1,B1 : dword;
    Steps,dx,dy : longint;
    X0,Y0 : longint;
    ddx,ddy : real;
begin
   Temp := BTBitmap.Create;
   Temp.Init(Xlng,Ylng,Bpp,nil);
   self.DrawTo(Temp.GetDC,0,0);

   Steps := Amount;
   dx := Round( Amount * cos(angle* Rad));
   dy := Round( Amount * sin(angle* Rad) * -1);
   ddx := (dx *2) / Steps;
   ddy := (dy *2) / Steps;


   for Y := 0 to Ylng -1  do
   begin
      for X := 0 to Xlng - 1 do
      begin
         color2rgb(Pixels[X,Y],A,R,G,B);
         X0 := X - (dx div 2);
         Y0 := Y - (dy div 2);
         For I := 1 to Steps do
         begin
            color2rgb(Temp.Pixels[X0,Y0],A,R1,G1,B1);
            X0 := round( X0 + ddx);
            Y0 := round( Y0 + ddy);
            R := R + R1;
            G := G + G1;
            B := B + B1;
         end;
         R := R div (Steps + 1);
         G := G div (Steps + 1);
         B := B div (Steps + 1);
         Pixels[X,Y] := rgb2color(A,R,G,B);
     end;
   end;
   Temp.Free;
end;


type PTFilters = array [0..0] of integer;
procedure BTBitmap.UserFilter(FILT:pointer; FiltXl,FiltYl :longword; FiltDiv,FiltBais :single);
var X,Y:dword;
    L,K,I:integer;
    A,R,G,B:dword;
    SumR,SumG,SumB:dword;
    Filter : ^PTFilters;
    Temp : BTBitmap;
begin
   Temp := BTBitmap.Create;
   Temp.Init(Xlng,Ylng,Bpp,nil);
   Filter := FILT;
   for Y := 0 to Ylng do  // todo ???? - 1
   begin
     for X := 0 to Xlng  do
     begin
        SumR := 0;
        SumG := 0;
        SumB := 0;
        for K := 0 to filtXl - 1 do
        begin
           for L := 0 to filtYl - 1 do
           begin
             I := L*filtXl;
             color2rgb(Pixels[X - (( filtXl - 1) shr 1 ) + K,
                              Y - (( filtYl - 1) shr 1 ) + L],A,R,G,B);
             SumR := SumR + integer(R)*Filter[K+I];
             SumG := SumG + integer(G)*Filter[K+I];
             SumB := SumB + integer(B)*Filter[K+I];
           end;
        end;
        if filtDiv =  0 then filtDiv := 1;

        SumR := Round((SumR / filtDiv) + filtBais);
        SumG := Round((SumG / filtDiv) + filtBais);
        SumB := Round((SumB / filtDiv) + filtBais);

        Temp.Pixels[X,Y] := rgb2color(A,IntToByte(SumR),IntToByte(SumG),IntToByte(SumB));
     end;
   end;
   Temp.DrawTo(Canvas.Handle,0,0);
   Temp.Free;
end;

{
laplace      hipass     find edges   sharpen    edge enhance  color emboss
                        (top down)                            (well, kinda)
-1 -1 -1    -1 -1 -1     1  1  1     -1 -1 -1     0 -1  0       1  0  1
-1  8 -1    -1  9 -1     1 -2  1     -1 16 -1    -1  5 -1       0  0  0
-1 -1 -1    -1 -1 -1    -1 -1 -1     -1 -1 -1     0 -1  0       1  0 -2

    1           1           1            8           1             1

 Soften        blur    Soften (less)

 2  2  2     3  3  3     0  1  0
 2  0  2     3  8  3     1  2  1
 2  2  2     3  3  3     0  1  0

   16          32           6

}


const
   SharpFilter : array [0..8] of integer = (0,-1,0,-1,5,-1,0,-1,0); //3,3,1,0
   ColorEmbosF : array [0..8] of integer = (-1,-1,-1,0,1,0,1,1,1); //3,3,1,0
   EmbosLightUp  : array [0..8] of integer = (0,-1,0,0,0,0,0,1,0); //3,3,1,192
   EmbosLightDown  : array [0..8] of integer = (0,1,0,0,0,0,0,-1,0); //3,3,1,192
   Blur3 : array [0..48] of integer =
      (1, 2, 3, 4, 3, 2, 1,          //BlurBartlett
       2, 4, 6, 8, 6, 4, 2,
       3, 6, 9,12, 9, 6, 3,
       4, 8,12,16,12, 8, 4,
       3, 6, 9,12, 9, 6, 3,
       2, 4, 6, 8, 6, 4, 2,
       1, 2, 3, 4, 3, 2, 1); //7,7,256

(*
   (0, 0,  0,   5,   0,   0,  0,             // Gausian  Blur
    0, 5,  18,  32,  18,  5,  0,
    0, 18, 64,  100, 64,  18, 0,
    5, 32, 100, 100, 100, 32, 5,
    0, 18, 64,  100, 64,  18, 0,
    0, 5,  18,  32,  18,  5,  0,
    0, 0,  0,   5,   0,   0,  0); // 7,7,1068
*)




//   Blur2 : array [0..8] of integer = (1,3,1,3,16,3,1,3,1); //3,3,32,0
//   EmbosDark  : array [0..8] of integer = (-1,-2,-1,0,0,0,1,2,1); //3,3,1,192
//   SmoothF  : array [0..8] of integer = (1,1,1,1,1,1,1,1,1); //3,3,9,0
   Smooth2 : array [0..8] of integer = (0,1,0,1,1,1,0,1,0); //3,3,5,0
   AntiAliesF : array [0..8] of integer = (0,0,0,0,1,1,0,1,1); //3,3,4,0

//   ColorEdge : array [0..8] of integer = (1,1,1,1,-2,1,-1,-1,-1); //3,3,1,0
//   p1 : array [0..8] of integer = (-6,-2,-6,-1,32,-1,-6,-2,-6); //3,3,1,0
//   p2 : array [0..8] of integer = (1,3,1,3,-16,3,1,3,1); //3,3,1,0
//   SharpFilter : array [0..8] of integer = (-6,2,-6,-1,32,-1,-6,-2,-6); //3,3,1,0
 NoFocus     : array [0..24] of integer =  (1, 0, 0, 0, 1,
                                            0, 0, 0, 0, 0,
                                            0, 0, 0, 0, 0,
                                            0, 0, 0, 0, 0,
                                            1, 0, 0, 0, 1); //5,5,5,0

// NoFocusR     : array [0..24] of integer =  (1, 0, 0, 0, 0,
//                                            0, 1, 0, 0, 1,
//                                            0, 0, 0, 1, 0,
//                                            0, 0, 0, 0, 0,
//                                            0, 1, 0, 0, 0); //5,5,5,0
// SharpFilter2 : array [0..24] of integer =  (0, 0, 0, 0, 0,
//                                            0, 1, 0, 1, 0,
//                                            0, 0, 0, 0, 0,
//                                            0, 1, 0, 1, 0,
//                                            0, 0, 0, 0, 0); //5,5,5,0


(*
const
  { Kernel for 3x3 average smoothing filter.}
  FilterAverage3x3: TConvolutionFilter3x3 = (
    Kernel: ((1, 1, 1),
             (1, 1, 1),
             (1, 1, 1));
    Divisor: 9);

  { Kernel for 5x5 average smoothing filter.}
  FilterAverage5x5: TConvolutionFilter5x5 = (
    Kernel: ((1, 1, 1, 1, 1),
             (1, 1, 1, 1, 1),
             (1, 1, 1, 1, 1),
             (1, 1, 1, 1, 1),
             (1, 1, 1, 1, 1));
    Divisor: 25);

  { Kernel for 3x3 Gaussian smoothing filter.}
  FilterGaussian3x3: TConvolutionFilter3x3 = (
    Kernel: ((1, 2, 1),
             (2, 4, 2),
             (1, 2, 1));
    Divisor: 16);

  { Kernel for 5x5 Gaussian smoothing filter.}
  FilterGaussian5x5: TConvolutionFilter5x5 = (
    Kernel: ((1,  4,  6,  4, 1),
             (4, 16, 24, 16, 4),
             (6, 24, 36, 24, 6),
             (4, 16, 24, 16, 4),
             (1,  4,  6,  4, 1));
    Divisor: 256);

  { Kernel for 3x3 Sobel horizontal edge detection filter (1st derivative approximation).}
  FilterSobelHorz3x3: TConvolutionFilter3x3 = (
    Kernel: (( 1,  2,  1),
             ( 0,  0,  0),
             (-1, -2, -1));
    Divisor: 1);

  { Kernel for 3x3 Sobel vertical edge detection filter (1st derivative approximation).}
  FilterSobelVert3x3: TConvolutionFilter3x3 = (
    Kernel: ((-1, 0, 1),
             (-2, 0, 2),
             (-1, 0, 1));
    Divisor: 1);

  { Kernel for 3x3 Prewitt horizontal edge detection filter.}
  FilterPrewittHorz3x3: TConvolutionFilter3x3 = (
    Kernel: (( 1,  1,  1),
             ( 0,  0,  0),
             (-1, -1, -1));
    Divisor: 1);

  { Kernel for 3x3 Prewitt vertical edge detection filter.}
  FilterPrewittVert3x3: TConvolutionFilter3x3 = (
    Kernel: ((-1, 0, 1),
             (-1, 0, 1),
             (-1, 0, 1));
    Divisor: 1);

  { Kernel for 3x3 Kirsh horizontal edge detection filter.}
  FilterKirshHorz3x3: TConvolutionFilter3x3 = (
    Kernel: (( 5,  5,  5),
             (-3,  0, -3),
             (-3, -3, -3));
    Divisor: 1);

  { Kernel for 3x3 Kirsh vertical edge detection filter.}
  FilterKirshVert3x3: TConvolutionFilter3x3 = (
    Kernel: ((5, -3, -3),
             (5,  0, -3),
             (5, -3, -3));
    Divisor: 1);

  { Kernel for 3x3 Laplace omni-directional edge detection filter
    (2nd derivative approximation).}
  FilterLaplace3x3: TConvolutionFilter3x3 = (
    Kernel: ((-1, -1, -1),
             (-1,  8, -1),
             (-1, -1, -1));
    Divisor: 1);

  { Kernel for 5x5 Laplace omni-directional edge detection filter
    (2nd derivative approximation).}
  FilterLaplace5x5: TConvolutionFilter5x5 = (
    Kernel: ((-1, -1, -1, -1, -1),
             (-1, -1, -1, -1, -1),
             (-1, -1, 24, -1, -1),
             (-1, -1, -1, -1, -1),
             (-1, -1, -1, -1, -1));
    Divisor: 1);

  { Kernel for 3x3 spharpening filter (Laplacian + original color).}
  FilterSharpen3x3: TConvolutionFilter3x3 = (
    Kernel: ((-1, -1, -1),
             (-1,  9, -1),
             (-1, -1, -1));
    Divisor: 1);

  { Kernel for 5x5 spharpening filter (Laplacian + original color).}
  FilterSharpen5x5: TConvolutionFilter5x5 = (
    Kernel: ((-1, -1, -1, -1, -1),
             (-1, -1, -1, -1, -1),
             (-1, -1, 25, -1, -1),
             (-1, -1, -1, -1, -1),
             (-1, -1, -1, -1, -1));
    Divisor: 1);

  { Kernel for 5x5 glow filter.}
  FilterGlow5x5: TConvolutionFilter5x5 = (
    Kernel: (( 1, 2,   2, 2, 1),
             ( 2, 0,   0, 0, 2),
             ( 2, 0, -20, 0, 2),
             ( 2, 0,   0, 0, 2),
             ( 1, 2,   2, 2, 1));
    Divisor: 8);

  { Kernel for 3x3 edge enhancement filter.}
  FilterEdgeEnhance3x3: TConvolutionFilter3x3 = (
    Kernel: ((-1, -2, -1),
             (-2, 16, -2),
             (-1, -2, -1));
    Divisor: 4);

  FilterTraceControur3x3: TConvolutionFilter3x3 = (
    Kernel: ((-6, -6, -2),
             (-1, 32, -1),
             (-6, -2, -6));
    Divisor: 4;
    Bias:    240/255);

  { Kernel for filter that negates all images pixels.}
  FilterNegative3x3: TConvolutionFilter3x3 = (
    Kernel: ((0,  0, 0),
             (0, -1, 0),
             (0,  0, 0));
    Divisor: 1;
    Bias:    1);

  { Kernel for 3x3 horz/vert embossing filter.}
  FilterEmboss3x3: TConvolutionFilter3x3 = (
    Kernel: ((2,  0,  0),
             (0, -1,  0),
             (0,  0, -1));
    Divisor: 1;
    Bias:    0.5);
*)





procedure BTBitmap.Sharpness;
begin
   UserFilter(@SharpFilter,3,3,1,0);
end;

procedure BTBitmap.ColorEmboss;
begin
   UserFilter(@ColorEmbosF,3,3,1,0);
end;

procedure BTBitmap.Emboss(UpDown:longword);
begin
  if UpDown = 1 then UserFilter(@EmbosLightDown,3,3,1,192)
                else UserFilter(@EmbosLightUp,3,3,1,192);
end;

procedure BTBitmap.Blur;
begin
   UserFilter(@Blur3,7,7,256,0);
end;

procedure BTBitmap.BadFocus;
begin
   UserFilter(@NoFocus,5,5,4,0);
end;

procedure BTBitmap.Smooth;
begin
   UserFilter(@Smooth2,3,3,5,0);
end;

procedure BTBitmap.AntiAlias;
//var X,Y:dword;
//    A,R,G,B,I:dword;
//    SumR,SumG,SumB:dword;
//    N : array [0..3] of dword;
//
begin
   UserFilter(@AntiAliesF,3,3,4,0);
//   for Y := 0 to Ylng - 1 do
//   begin
//     for X := 0 to Xlng - 1 do
//     begin
//       if X > 0       then n[0] := Pixels[X-1,Y]
//                      else n[0] := Pixels[X+1,Y];
//       if X < Xlng -1 then n[1] := Pixels[X+1,Y]
//                      else n[1] := Pixels[X-1,Y];
//       if Y > 0       then n[2] := Pixels[X,Y-1]
//                      else n[2] := Pixels[X,Y+1];
//       if Y < Ylng -1 then n[3] := Pixels[X,Y+1]
//                      else n[3] := Pixels[X,Y-1];
//       SumR := 0;
//       SumG := 0;
//       SumB := 0;
//       for i := 0 to 3 do
//       begin
//        color2rgb(n[i],A,R,G,B);
//        SumR := SumR + R;
//        SumG := SumG + G;
//        SumB := SumB + B;
//       end;
//       SumR := SumR div 4;
//       SumG := SumG div 4;
//       SumB := SumB div 4;
//
//      Pixels[X,Y] := rgb2color(A,IntToByte(SumR),IntToByte(SumG),IntToByte(SumB));
//     end;
//   end;
end;

procedure BTBitmap.Glow(Amount : Integer);
var Temp : BTBitmap;
    X,Y:dword;
    A,R,G,B:dword;
    R1,G1,B1:dword;
begin
   Temp := BTBitmap.Create;
   Temp.Init(Xlng,Ylng,Bpp,nil);
   self.DrawTo(Temp.GetDC,0,0);
//   UserFilter(@Blur3,7,7,200,0);

//   Temp.BadFocus;
   Temp.Blur;
   Temp.Blur;
   Temp.Sharpness;
//   Temp.Sharpness;
//   self.Aritmetic(1,-50,50,Temp);
//   for Y := 0 to Ylng - 1 do
//   begin
//     for X := 0 to Xlng - 1 do
//    begin
//        color2rgb(Pixels[X,Y],A,R,G,B);
//        color2rgb(Temp.Pixels[X,Y],A,R1,G1,B1);
//        Pixels[X,Y] := rgb2color(A,IntToByte((R + Amount*R1) div 2),
//                                   IntToByte((G + Amount*G1) div 2),
//                                   IntToByte((B + Amount*B1) div 2));
//     end;
//   end;
   Temp.Alpha := Amount; // alpha draw
   self.Canvas.Draw(0,0,Temp,0);
   Temp.Free;
end;




(*==================    F I L E    L O A D E R    ===========================*)



type  BILS = record
        FileName : pchar;
        Drawer   : procedure(W,H,H_dc:longword); stdcall;
        Transparent : boolean;
        ColorOff : dword;
        Alpha    : dword;
      end;
      PBILS = ^BILS;
var
    Bil : BILS;
    hIJL: HINST;
    aImageLoader: function(BIL : PBILS):longword; stdcall;

function  Load_hIJL:boolean;
var res:boolean;

    Key: HKEY;
begin
   res := true;
   if hIJL = 0 then
   begin
      hIJL:=LoadLibrary('BImg.dll');
      if hIJL<>0 then
      begin
        @aImageLoader:=GetProcAddress(hIJL,'BImageLoader');
     end else begin
        res := false; // no lib
     end;
   end;
   Load_hIJL := res;
end;

var
  BilByPass : procedure(W,H,H_dc:longword) of object;

procedure xBilDrawer(W,H,H_dc:longword); stdcall;
begin
  BilByPass(W,H,H_DC);
end;

procedure BTBitmap.BilDrawer(W,H,x_dc:longword);
begin
   Init(W,H,32,nil);
   bitblt(self.GetDC,0,0,W,H,x_dc,0,0,SRCCOPY);
   self.ReleaseDC;
end;

procedure BTBitmap.LoadFromFile(FileName:pchar);
var i,j,d,Xl,Yl,lBpp:dword;
    s : string;

begin
   j := Length(FileName);
   if J > 0 then
   begin
      s := FileName;
      for i := 1 to j do s[i] := UpCase(s[i]);
      if Pos('.BMP',s) > 0  then
      begin
         inherited LoadFromFile(FileName);
      end else begin
         if Load_Hijl then
         begin
           BilByPass := self.BilDrawer;
           BIL.FileName := pchar(FileName);
           BIL.Drawer := xBilDrawer;
           i := aImageLoader(@BIL);
         end;
      end;
   end;
end;


procedure   BTBitMap.Load(bmp_dc:dword);
begin
   Load(bmp_dc,0,0,0,0,0);
end;

procedure   BTBitMap.Load(bmp_dc:dword; bXpos,bYpos,bXlng,bYlng:longint; bBpp:dword);
var bm:BITMAP;
    aX,aY,lBpp:dword;
    bmp_handle,bmp_dump:dword;
begin
   if dword(bmp_dc) <> 0 then
   begin

      bmp_dump := 0;
      if ((bXlng = 0) and (bYlng = 0)) or (bBpp = 0) then
      begin { AUTO detect mode }
         bmp_dump := CreateCompatibleBitmap(bmp_dc,1,1);
         bmp_handle := SelectObject(bmp_dc,bmp_dump);
         GetObject(bmp_handle,sizeof(BITMAP),@bm);
         SelectObject(bmp_dc,bmp_handle);
         aX := bm.bmWidth;
         aY := bm.bmHeight;
         lBpp := bm.bmBitsPixel;
         if bBpp = 0  then bBpp := lBpp;
         if bXlng = 0 then bXlng := aX;
         if bYlng = 0 then bYlng := aY;
      end;

// if pBpp = 4 then pBpp := 16; ??????????TODO

      Init(bXlng,bYlng,bBpp,nil);
      if self.GetDC <> 0 then
      begin
         bitblt(self.GetDC,0,0,bXlng,bYlng,bmp_dc,bXpos,bYpos,SRCCOPY); { this will make conversion }
         self.ReleaseDC;
      end;

      if bmp_dump <> 0 then DeleteObject(bmp_dump);
   end;
end;




////////////////////////////////////////////////////////////// T O O L S ///////


function  Color4(ind:dword):dword;
var outcol:dword;
begin
   outcol := 0;
   case ind of
   0:  outcol := rgb(   0,  0,  0);
   1:  outcol := rgb(   0,  0,128);
   2:  outcol := rgb(   0,128,  0);
   3:  outcol := rgb(   0,128,128);
   4:  outcol := rgb( 128,  0,  0);
   5:  outcol := rgb( 128,  0,128);
   6:  outcol := rgb( 128,128,  0);
   7:  outcol := rgb( 192,192,192);
   8:  outcol := rgb( 160,160,164);
   9:  outcol := rgb(   0,  0,255);
   10: outcol := rgb(   0,255,  0);
   11: outcol := rgb(   0,255,255);
   12: outcol := rgb( 255,  0,  0);
   13: outcol := rgb( 255,  0,255);
   14: outcol := rgb( 255,255,  0);
   15: outcol := rgb( 255,255,255);
   end;
   Color4 := outcol;
end;

function Color(r,g,b:dword):dword;
begin
  Color := windows.RGB(r,g,b);
end;

procedure ColorValue(c:dword; var r,g,b:dword);
begin
  r := windows.GetRvalue(c);
  g := windows.GetGvalue(c);
  b := windows.GetBvalue(c);
end;

function ColorRValue(c:dword):dword;
begin
  ColorRvalue := windows.GetRvalue(c);
end;

function ColorGValue(c:dword):dword;
begin
  ColorGvalue := windows.GetGvalue(c);
end;

function ColorBValue(c:dword):dword;
begin
  ColorBvalue := windows.GetBvalue(c);
end;



begin
   hIJL := 0;
end.


