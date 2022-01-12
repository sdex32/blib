unit BPaint32;

interface              //Paint32

// pallete
// COMODORE 64
//rgb     (190,53,53)
//        (249,155,151)
//        (145,95,51)
//        (209,127,48)
//        (247,238,89)
//        (89,205,54)
//        (131,240,220)
//        (117,161,236)
//        (65,55,205)
//        (204,89,198)
//        (255,255,255)
//        (202,202,202)
//        (142,142,142)
//        (91,91,91)
//        (0,0,0)



uses BBitmap32;

type  _BTPaint32_DrawObject = class
         private
            aBitmap     :BTBitmap32;
            aColor      :longword;
            _Render_Point :procedure (x,y :longint) of object;
            _Render_HLine :procedure (x,y,l :longint) of object;
            //rasterizer
            procedure   _SetRasterizer(id :longword);
            procedure   _ras_cpoint(x,y :longint);
         public
            constructor Create(Bitmap :BTBitmap32; pb:longword);
            destructor  Destroy; override;
            procedure   SetColor(R,G,B :longword); overload;
            procedure   SetColor(A,R,G,B :longword); overload;
      end;




      BTPaint32 = class
         private
            aBitmap     :BTBitmap32;
            aOriginXpos :integer;
            aOriginYpos :integer;
            aXshift     :integer;
            aYshift     :integer;
            aScaleFac   :single;
            aRotAngle   :single;
            aTransMat   :array[1..9] of single;
            aMemoryMat  :array[0..7,1..9] of single;

            aPenXpos    :integer;
            aPenYpos    :integer;

            procedure   _GenTransMat;
            procedure   _GetScrCord(var X,Y:longint);
         public
            Pen         :_BTPaint32_DrawObject;
            Brush       :_BTPaint32_DrawObject;
            AntialiasMode :boolean;

constructor Create(Bitmap:BTBitmap32);
//            constructor Create(TheBitmap:pointer; Xlng,Ylng,Pitch, Driver, Apos,Rpos,Gpos,Bpos, Flags, Res :longword);
            destructor  Destroy; override;

            procedure   ResetTransformation;
            procedure   PushTrans(memid :longword);
            procedure   PopTrans(memid :longword);
            procedure   SetShift(Xpos,Ypos :longint);
            procedure   SetScale(Factor:single);
            procedure   SetRotate(Angle:single);
            procedure   SetOrigin(Xpos,Ypos :longint);

//            procedure   GetBitmapCord(Xpos,Ypos:single; var BitmapXpos,BitmapYpos:longint);


            procedure   MoveTo(x,y :integer);
            procedure   LineTo(x,y :integer);
            procedure   Line(x1,y1,x2,y2 :integer);

//            procedure   MoveTo(x,y :single); overload;
//            procedure   LineTo(x,y :single); overload;
//            procedure   Line(x1,y1,x2,y2 :single); overload;





//            procedure   SetClipRectangle( Xbegin. Xend, YBegin, Yend :longint );
//            procedure   GetClipRectangle( var Xbegin. Xend, YBegin, Yend :longint );
//            procedure   SetClipping( On_Off :boolean );
//            function    GetClipping :boolean;
//            procedure   SetStencilSurface(
//            procedure   SetStencil( On_Off :boolean );
//            function    GetStencil :boolean;
//            procedure   SetStencilLogic( ????
//            procedure   SetWriteMask( Mask :longword );
//            function    GetWriteMask :longword;
//            procedure   SetWriteLogic( Logic :longword);
//            function    GetWriteLogic :longword;
//            procedure   SetPenColor( Color :longword );
//            procedure   SetPenColor( A, R, G, B :longword );  //??? byte
//            procedure   SetBrushColor( Color :longword );
//            procedure   SetBrushColor( A, R, G, B :longword );  //??? byte




//            procedure   Line( Xpos, Ypos, Xend, Yend :longint );
//            procedure   MoveTo( Xpos, Ypos :longint );
//            procedure   LineTo( Xpos, Ypos :longint );
//            procedure   Rectangle( Xpos, Ypos, Xlng, Ylng:longint );
//            procedure   FillRectangle( Xpos, Ypos, Xlng, Ylng:longint );
//            procedure   RoundRectangle( Xpos, Ypos, Xlng, Ylng:longint; Radius :longword );
//            procedure   FillRRoundectangle( Xpos, Ypos, Xlng, Ylng:longint; Radius :longword );
//            procedure   Circle( Xpos, Ypos :longint; Radius :longword );
//            procedure   FillCircle( Xpos, Ypos :longint; Radius :longword );
//            procedure   Ellipse( Xpos, Ypos :longint;  Xradius, Yradius :longword );
//            procedure   FillEllipse( Xpos, Ypos :longint;  Xradius, Yradius :longword );
//            procedure   Arc( Xpos, Ypos :longint;  Xradius, Yradius, Start_Angle, End_Angle :longword );
//            procedure   FillArc( Xpos, Ypos :longint;  Xradius, Yradius, Start_Angle, End_Angle :longword );
//            procedure   Polygon
//            procedure   FillPolygon
//            procedure   Fill
//            procedure   Clear
//            procedure   PutPixel
//            procedure   TextOut
//            procedure   SetRasterFont
//            procedure   SetRasterFontExt


      end;


implementation



{ Remake of an old project
 -----------------------------------------------------------------------------
 -----------------------------------------------------------------------------
    EEEEEEEE  GGGGGGG   GGGGGGG
    EEE      GGG       GGG         +      +
    EEEEEE   GGG  GGG  GGG  GGG  +++++  +++++
    EEE      GGG   GG  GGG   GG    +      +
    EEEEEEEE  GGGGGGG   GGGGGGG                     Extendet Graphic Giant
 -----------------------------------------------------------------------------
 -----------------------------------------------------------------------------
}


type
   SingleArr = array [0..0] of single;
   DwordArr  = array [0..0] of longword;
const
   Rad = Pi / 180.0;




//-------- T O O L S -----------------------------------------------------------


//-------- P A I N T 32 --------------------------------------------------------
//------------------------------------------------------------------------------
constructor BTPaint32.Create(Bitmap:BTBitmap32);
var i:longint;
begin
   aBitmap := Bitmap;
   AntialiasMode := false;
   ResetTransformation;
   for i := 0 to 7 do PushTrans(i);
   SetOrigin(0,0);
   Pen := _BTPaint32_DrawObject.Create(aBitmap,0);
   Brush := _BTPaint32_DrawObject.Create(aBitmap,1);
end;

//------------------------------------------------------------------------------
destructor  BTPaint32.Destroy;
begin
   Pen.Free;
   Brush.Free;
   inherited;
end;



//-------- T R A N S F O R M A T I O N  ----------------------------------------
//------------------------------------------------------------------------------
procedure   _InitMatrix(p:pointer);
const _IM : array[1..9]of single = (1,0,0,0,1,0,0,0,1);
begin
   move(_IM,p^,12*4);
end;

procedure   _MatrixMul(m1,m2:pointer);  // m1 x m2 -> m1
var m:array[0..8]of single;
    i,j:longint;
    m1p,m2p :^SingleArr;
begin
   m1p := m1;
   m2p := m2;
   for i := 0 to 2 do
     for j := 0 to 2 do
        m[ j + i*3 ] := m1p[ j + 0*3 ] * m2p[ i*3 + 0 ] +
                        m1p[ j + 1*3 ] * m2p[ i*3 + 1 ] +
                        m1p[ j + 2*3 ] * m2p[ i*3 + 2 ] ;
   move(m,m1^,12*4);
end;

//------------------------------------------------------------------------------
procedure   BTPaint32._GenTransMat;
var aMat :array[1..9] of single;
    s,c:single;
begin
   _InitMatrix(@aTransMat);
   //Shift
   _InitMatrix(@aMat);       //  1  0  0
   aMat[7] := aXshift;       //  0  1  0
   aMat[8] := aYshift;       //  X  Y  1
   _MatrixMul(@aTransMat,@aMat);
   //Scale
   _InitMatrix(@aMat);       //  F  0  0
   aMat[1] := aScaleFac;     //  0  F  0
   aMat[5] := aScaleFac;     //  0  0  1
   _MatrixMul(@aTransMat,@aMat);
   //Rotate
   s := sin(aRotAngle);
   c := cos(aRotAngle);
   _InitMatrix(@aMat);       //  C  S  0
   aMat[1] := c;             // -S  C  0
   aMat[2] := s;             //  0  0  1
   aMat[4] := -s;
   aMat[5] := -c;
   _MatrixMul(@aTransMat,@aMat);
end;

//------------------------------------------------------------------------------
procedure   BTPaint32.SetShift(Xpos,Ypos:integer);
begin
   aXshift := Xpos;
   aYShift := Ypos;
   _GenTransMat;
end;

//------------------------------------------------------------------------------
procedure   BTPaint32.SetScale(Factor:single);
begin
   aScaleFac := Factor;
   _GenTransMat;
end;

//------------------------------------------------------------------------------
procedure   BTPaint32.SetRotate(Angle:single);
begin
   aRotAngle := Angle * Rad;
   _GenTransMat;
end;

//------------------------------------------------------------------------------
procedure   BTPaint32.ResetTransformation;
begin
   _InitMatrix(@aTransMat);
   aXshift := 0;
   aYShift := 0;
   aScaleFac := 0;
   aRotAngle := 0;
end;

//------------------------------------------------------------------------------
procedure   BTPaint32.PushTrans(memid :longword);
var p:pointer;
begin
   p := @aMemoryMat[memid and 7,1];
   move(aTransMat,p^,12*4);
end;

//------------------------------------------------------------------------------
procedure   BTPaint32.PopTrans(memid :longword);
var p:pointer;
begin
   p := @aMemoryMat[memid and 7,1];
   move(p^,aTransMat,12*4);
end;

//------------------------------------------------------------------------------
procedure   BTPaint32.SetOrigin(Xpos,Ypos :longint);
begin
   aOriginXpos := Xpos;
   aOriginYpos := Ypos;
end;








//-------- P R I M I T I V E S -------------------------------------------------
//------------------------------------------------------------------------------
procedure   BTPaint32._GetScrCord(var X,Y:longint);
var xa:longint;
begin
   xa := x;
   x := aOriginXpos + round(aTransMat[1]*xa + aTransMat[4]*y + aTransMat[7]);
   y := aOriginYpos + round(aTransMat[2]*xa + aTransMat[5]*y + aTransMat[8]);
end;


//------------------------------------------------------------------------------
procedure   BTPaint32.MoveTo(x,y: integer);
begin
   aPenXpos := x;
   aPenYpos := y;
end;

//------------------------------------------------------------------------------
procedure   BTPaint32.LineTo(x,y: integer);
begin
   Line(aPenXpos,aPenYpos,x,y);
   aPenXpos := x;
   aPenYpos := y;
end;

//------------------------------------------------------------------------------
procedure   BTPaint32.Line(x1,y1,x2,y2: integer);
var W,H,Dxd,Dyd,Dxn,Dyn,P,D,Dinc,NDinc:longint;
    Mask :longword;
    ux1,ux2,uy1,uy2:longint;
    GX_LinePat:longword;
begin
   GX_LinePat := $FFAAFFAA;
   Mask := $80000000;  // it can be shifted by X corrector

   ux1 := x1;
   ux2 := x2;
   uy1 := y1;
   uy2 := y2;

   W := X2 - X1;
   H := Y2 - Y1;

   if (W < 0) then begin  W := -W;  Dxd := -1; end else  Dxd := 1;
   if (H < 0) then begin  H := -H;  Dyd := -1; end else  Dyd := 1;
   if (W < H) then  { big swap }
   begin
      P := H; H := W; W := P;
      Dxn := 0;
      Dyn := Dyd;
   end else begin
      Dxn := Dxd;
      Dyn := 0;
   end;

   Ndinc := H * 2;
   D := Ndinc - W;
   Dinc := D - W;

   for P := 0 to  W do
   begin
      if (Mask and GX_LinePat) > 0 then Pen._Render_Point(X1,Y1);
      Mask := Mask shr 1;
      if Mask = 0 then Mask := $80000000;

      //GX_putpixel(scrptr,X1,Y1,Color);

      if ( D < 0 ) then
      begin
          inc(X1,Dxn);
          inc(Y1,Dyn);
          inc(D,Ndinc);
      end else begin
          inc(X1,Dxd);
          inc(Y1,Dyd);
          inc(D,Dinc);
      end;
   end;

//   GX_TrapRePaint := false;
//   if ux1 > ux2 then
//   begin
//     h:=ux1; ux1:=ux2; ux2 :=h;
//   end;
//   if uy1 > uy2 then
//   begin
//     h:=uy1; uy1:=uy2; uy2 :=h;
//   end;
//   ux2 := ux2 - ux1 + 1;
//   uy2 := uy2 - uy1 + 1;
//   _GX_repaint(ux1,uy1,ux2,uy2);
//   if GX_DirectX then GlobalEndDX;
end;



//-------- P A I N T 32      D r a w   O b j e c t   ---------------------------
//------------------------------------------------------------------------------
constructor _BTPaint32_DrawObject.Create(Bitmap:BTBitmap32; pb:longword);
begin
   aBitmap := Bitmap;
   if pb = 0 then SetColor(255,255,255) //pen default
             else SetColor(128,128,128); //brush default
end;

//------------------------------------------------------------------------------
destructor  _BTPaint32_DrawObject.Destroy;
begin

   inherited;
end;

//------------------------------------------------------------------------------
procedure   _BTPaint32_DrawObject.SetColor(R,G,B :longword);
begin
   SetColor(255,R,G,B);
end;

//------------------------------------------------------------------------------
procedure   _BTPaint32_DrawObject.SetColor(A,R,G,B :longword);
begin
   aColor := ((A and $FF) shl 24) or ((B and $FF) shl 16) or ((G and $FF) shl 8) or (R and $FF);
   _SetRasterizer(0);
end;

//------------------------------------------------------------------------------
procedure   _BTPaint32_DrawObject._SetRasterizer(id :longword);
begin
   case id of
      0 : begin // Pure color
         _Render_Point := _ras_cpoint;
      end;


   end;
end;


procedure   _BTPaint32_DrawObject._ras_cpoint(x,y:longint);
begin
   DWordArr(pointer(longword(aBitmap.BitmapPtr)+longword(y)*aBitmap.Pitch)^)[x] := aColor;
end;


end.
