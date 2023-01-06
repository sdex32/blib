unit BBitmap32;

interface

type  BTBitmap32 = class
         private
            aBitmap :pointer;
            aXlng   :longword;
            aYlng   :longword;
            aPitch  :longword;
         public
            constructor Create;
            destructor  Destroy; override;
            procedure   Init(Xlng,Ylng :longword);
            procedure   Clear; overload;
            procedure   Clear(A,R,G,B :longword);  overload;
            procedure   Clear(Col :longword);  overload;
            procedure   RenderOnDC(DC :longword; X,Y:longint);
//save bmp
//load bmp
            property    BitmapPtr :pointer read aBitmap;
            property    Pitch :longword read aPitch;
            property    Xlng :longword read aXlng;
            property    Ylng :longword read aYlng;            
      end;





implementation

uses Windows;

type  BTPixel32 = packed record
         Alpha  :byte;
         Red    :byte;
         Green  :byte;
         Blue   :byte;
      end;
      PBTPixel32 = ^BTPixel32;
      DWptr = ^longword;

var   AlphaShift,RedShift,GreenShift,BlueShift:longword;


procedure FastBlendPixelInline(dest: PBTpixel32; const c: BTPixel32);  inline;
var
  a1f, a2f, a12, a12m: longword;
begin
  if c.alpha = 0 then
    exit;
  if c.alpha = 255 then
  begin
    dest^ := c;
    exit;
  end;
  { $ HINTS OFF}
  a12  := 65025 - (not dest^.alpha) * (not c.alpha);
  { $ HINTS ON}
  a12m := a12 shr 1;
  a1f := dest^.alpha * (not c.alpha);
  a2f := (c.alpha shl 8) - c.alpha;
  DWptr(dest)^ := (((dest^.red * a1f + c.red * a2f + a12m) div a12) shl RedShift) or
                  (((dest^.green * a1f + c.green * a2f + a12m) div a12) shl GreenShift) or
                  (((dest^.blue * a1f + c.blue * a2f + a12m) div a12) shl BlueShift) or
                  (((a12 + a12 shr 7) shr 8) shl AlphaShift);
end;


(*
     function blend(color1,color2:longword; alpha:byte)
     var rb,g:longword
     begin
        rb := Color1 and $FF00FF;
        g  := Color1 and $00FF00;
        rb := rb + (((Color2 and $FF00FF) - rb) * alpha ) shr 8 ;
        g  := g  + (((Color2 and $00FF00) - g ) * alpha ) shr 8 ;
        Result := (rb and $FF00FF) or (g and $00FF00);
     end;
*)


//------------------------------------------------------------------------------
constructor BTBitmap32.Create;
var c:BTPixel32;
begin
   aBitmap := Nil;
//  FastBlendPixelInline(aBitmap,c);
//  FastBlendPixelInline(aBitmap,c);
end;

//------------------------------------------------------------------------------
destructor  BTBitmap32.Destroy;
begin
   if aBitmap <> nil then Reallocmem(aBitmap,0); //free
   inherited;
end;

//------------------------------------------------------------------------------
procedure   BTBitmap32.Init(Xlng,Ylng :longword);
begin
   aXlng := Xlng;
   aYlng := Ylng;
   ReallocMem(aBitmap,Xlng*Ylng*4);

   aPitch  := Xlng*4;
end;

//------------------------------------------------------------------------------
procedure   BTBitmap32.Clear;
begin
   if aBitmap <> nil then fillchar(aBitmap^, Xlng*Ylng*4, 0);
end;

//------------------------------------------------------------------------------
procedure   BTBitmap32.Clear(A,R,G,B:longword);
begin
   Clear(((A and $FF) shl 24) or ((B and $FF) shl 16) or ((G and $FF) shl 8) or (R and $FF));
end;

//------------------------------------------------------------------------------
procedure   BTBitmap32.Clear(Col :longword); 
var i:longword;
begin
   if aBitmap <> nil then for i := 0 to Xlng*Ylng-1 do longword(pointer((longword(aBitmap)+i*4))^) := Col;
end;

//------------------------------------------------------------------------------
procedure   BTBitmap32.RenderOnDC(DC :longword; X,Y:longint);
var bisize : longword;
    pbitmapinfo : array[0..2048] of byte; // sizeof(BITMAPINFOHEADER)+512  { 512 for 256 di colors word }

begin
   if aBitmap = nil then Exit;

   bisize:=sizeof(BITMAPINFOHEADER);
   fillchar(pbitmapinfo, bisize+32, 0);

   with BITMAPINFO((@pbitmapinfo)^) do
   begin {BitmapInfoHeader 16Bit}
      bmiHeader.biSize        :=bisize;
      bmiHeader.biWidth       := aXlng;
      bmiHeader.biHeight      := -aYlng;
      bmiHeader.biPlanes      := 1;
      bmiHeader.biBitCount    := 32; //bpp
      bmiHeader.biCompression :=BI_BITFIELDS;
   end;

   longword((@pbitmapinfo[bisize])^)   := $0000FF;
   longword((@pbitmapinfo[bisize+4])^) := $00FF00;
   longword((@pbitmapinfo[bisize+8])^) := $FF0000;

   SetDIBitsToDevice(dc, X, Y,
                     aXlng, aYlng, 0, 0,
                     0, aYlng,
                     aBitmap , bitmapinfo((@pbitmapinfo)^), DIB_RGB_COLORS);
end;


end.
