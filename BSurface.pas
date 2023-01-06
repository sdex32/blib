(*
	BSurface   version 1.4
	Copyright (C) 2005-2009  SAB labs

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

{ ToDo

   load from file error hand
   save to file $ more fuctions
   test all
   rgbmask in load from file  ??
}
unit BSurface;
{$APPTYPE GUI }

/// if FPC is not defined DELPHI usage
{$IFDEF FPC }
{$MODE DELPHI }

{*********** CODE GENRATION ****************}
{ $ DEBUGINFO OFF }
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

{$ELSE }
{**** DELPHI }
{$APPTYPE GUI}
{ $ DEBUGINFO OFF}
{$OPTIMIZATION ON}
{$RANGECHECKS OFF}
{$OVERFLOWCHECKS OFF}

{$ENDIF}


interface
{ !! WARNING !!

  when use aFastMemory use it once only after creation and do not
  change, mey cause memory un free

  FastMemory mode is 30% faster that normal mode, when accessing
  Source and filling with asm proc.
}

uses windows;

type

     BTRGBmask = record
        Amask   : dword;
        Rmask   : dword;
        Gmask   : dword;
        Bmask   : dword;
     end;
     PBTRGBmask = ^BTRGBmask;

     BTRGBmaskvalue = record
        Amask   : dword;
        Rmask   : dword;
        Gmask   : dword;
        Bmask   : dword;
        Ashift  : dword;
        Rshift  : dword;
        Gshift  : dword;
        Bshift  : dword;
        Aadjust : dword;
        Radjust : dword;
        Gadjust : dword;
        Badjust : dword;
     end;



     PBTPicAnimation = ^BTPicAnimation;
     BTPicAnimation = record
        pwd          : dword;
        PXpos        : dword; // offset of first picture
        PYpos        : dword;
        PXlng        : dword; // size of picture
        PYlng        : dword;
        Xmod         : dword; // count of columns
        Ymod         : dword; // count of rows
        BeginPic     : dword; // start picture index   ( start from 1)
        EndPic       : dword; // last picture index
        CurrentPic   : dword; // current drawn picture
     end;
//     BTPicAnim = record
//        PXpos        : dword; // offset of first picture
//        PYpos        : dword;
//        PXlng        : dword; // size of picture
//        PYlng        : dword;
//        Xmod         : dword; // count of columns
//        Ymod         : dword; // count of rows
//        BeginPic     : dword; // start picture index   ( start from 1)
//        EndPic       : dword; // last picture index
//        CurrentPic   : dword; // current drawn picture
//     end;

{
     BTSurfaceCore = class
     private
        aSource      : dword;
        aXlng        : dword;
        aYlng        : dword;
        aPitch       : dword;
        aBpp         : dword;
        aBytePP      : dword;
        aRGBmask     : BTRGBmask;
        aRGBmaskValue:  BTRGBmaskValue;
        procedure    SetXlng(value:dword); //virtual;
        procedure    SetYlng(value:dword); //virtual;
        procedure    SetBpp(value:dword); //virtual;
        procedure    SetRGBmask(mask:BTRGBmask); //virtual;
//        procedure    AdjustRGBmaskValue(_A,_R,_G,_B:dword);
     public
        property     Pitch  : dword read aPitch;
        property     Xlng   : dword read aXlng write SetXlng;
        property     Ylng   : dword read aYlng write SetYlng;
        property     RGBmask : BTRGBmask read aRGBmask write SetRGBmask;
        property     RGBmaskValue:  BTRGBmaskValue read aRGBmaskValue;
        property     Bpp    : dword read aBpp write SetBpp;
        property     BytePP : dword read aBytePP;
        property     Source : dword read aSource;
        constructor  Create; //virtual;
        function     Lock   : dword;  //virtual;
        procedure    UnLock;  //virtual;
     end;
}
     BTSurface = class
     private
        aDump        : dword;
        aSource      : dword;
        aXlng        : dword;
        aYlng        : dword;
        aPitch       : dword;
        aBpp         : dword;
        aBytePP      : dword;
        aRGBmask     : BTRGBmask;
        aRGBmaskValue:  BTRGBmaskValue;

        aBitmapInfoHeader  : BITMAPINFOHEADER;
        aBitmapColors      : array [0..255] of dword;
        aBitmapColorsCount : dword;
//        aDDsurface   : dword;
        aH_DC        : dword;
        aHandle      : dword;
        aFastMemory  : boolean;
        procedure    SetXlng(value:dword);
        procedure    SetYlng(value:dword);
        procedure    SetBpp(value:dword); //override;
        procedure    SetRGBmask(mask:BTRGBmask); //override;
        function     GetScanLine(row:dword):pointer;
        procedure    SetPixelF(X,Y,Value:dword);
        function     GetPixelF(X,Y:dword):dword;
        procedure    AdjustRGBmaskValue(_A,_R,_G,_B:dword);


     public
        Alpha        : dword;
        ColorOff     : dword;
        Transparent  : boolean;
        Animation    : longword;

        property     Pitch  : dword read aPitch;
        property     Xlng   : dword read aXlng write SetXlng;
        property     Ylng   : dword read aYlng write SetYlng;
        property     RGBmask : BTRGBmask read aRGBmask write SetRGBmask;
        property     RGBmaskValue:  BTRGBmaskValue read aRGBmaskValue;
        property     Bpp    : dword read aBpp write SetBpp;
        property     BytePP : dword read aBytePP;
        property     Source : dword read aSource;

//        property     H_DC   : dword read aH_DC;
        property     Handle : dword read aHandle;
        property     ScanLine[Row:dword]:pointer read GetScanLine;
        property     Pixels[X, Y: dword]: dword read GetPixelF write SetPixelF;
        constructor  Create; virtual;
        destructor   Destroy; override;
        function     Init(Xres,Yres,Bpp :Dword; RGBmask:PBTRGBmask):dword; virtual;
        procedure    SetSize(Xres,Yres :dword);
        procedure    SetPalColor(i,r,g,b:byte);
        procedure    SetPalArray(Start,Count:dword; palarray:pointer);
        procedure    LoadFromFile(name:pchar); virtual;
        procedure    SaveToFile(name:string); virtual;
        procedure    DrawTo(to_dc :dword; X, Y:longint);
        procedure    SetProp(prop,Value:dword);
        function     rgb2color(A, R, G, B :dword):dword;
        procedure    color2rgb(Color :dword; var A, R, G, B :dword);
        procedure    SetPixelWLogic(X,Y,Value,Logic,LogicValue:dword);
        function     Lock   : dword;
        procedure    UnLock;
        function     GetDC : dword;
        procedure    ReleaseDC;
     end;


implementation

{
constructor  BTSurfaceCore.Create;
begin
   aSource := 0;
   aXlng := 0;
   aYlng := 0;
   aBpp := 0;
   aRGBmask.Amask := $FF000000;
   aRGBmask.Rmask := $00FF0000;
   aRGBmask.Gmask := $0000FF00;
   aRGBmask.Bmask := $000000FF;
//   AdjustRGBmaskValue(aRGBmask.Amask,aRGBmask.Rmask,aRGBmask.Gmask,aRGBmask.Bmask);
end;

procedure    BTSurfaceCore.SetXlng(value:dword);
begin
   aXlng := value;
end;

procedure    BTSurfaceCore.SetYlng(value:dword);
begin
   aYlng := value;
end;


procedure    BTSurfaceCore.SetBpp(value:dword);
begin
   aBPP := value;
end;


procedure    BTSurfaceCore.SetRGBmask(mask:BTRGBmask);
begin
   aRGBMask := mask;
//   AdjustRGBmaskValue(aRGBmask.Amask,aRGBmask.Rmask,aRGBmask.Gmask,aRGBmask.Bmask);
end;


}

Function     BTSurface.Lock:dword;
begin
   Lock := aSource;
end;

procedure    BTSurface.UnLock;
begin
end;

procedure    BTSurface.AdjustRGBmaskValue(_A,_R,_G,_B:dword);
var a:dword;
begin
         // Create Adjust mask
         aRGBmaskValue.Amask   := 0;
         aRGBmaskValue.Rmask   := 0;
         aRGBmaskValue.Gmask   := 0;
         aRGBmaskValue.Bmask   := 0;
         aRGBmaskValue.Ashift  := 0;
         aRGBmaskValue.Rshift  := 0;
         aRGBmaskValue.Gshift  := 0;
         aRGBmaskValue.Bshift  := 0;
         aRGBmaskValue.Aadjust := 0;
         aRGBmaskValue.Radjust := 0;
         aRGBmaskValue.Gadjust := 0;
         aRGBmaskValue.Badjust := 0;


         if aBpp > 8 then
         begin

            with aRGBmaskValue do
            begin

               Amask := _A;
               Rmask := _R;
               Gmask := _G;
               Bmask := _B;

               RShift := 0;
               Radjust := 0;
               a := RMask;
               if a > 0 then
               begin
                  while not boolean(a and 1) do
                  begin  inc(RShift);  a := a shr 1;  end;
                  while boolean(a and 1) do
                  begin  inc(Radjust); a := a shr 1; end;
                  Radjust := 8 - Radjust;
               end;

               GShift := 0;
               Gadjust := 0;
               a := GMask;
               if a > 0 then
               begin
                  while not boolean(a and 1) do
                  begin  inc(GShift);  a := a shr 1;  end;
                  while boolean(a and 1) do
                  begin  inc(Gadjust); a := a shr 1; end;
                  Gadjust := 8 - Gadjust;
               end;

               BShift := 0;
               Badjust := 0;
               a := BMask;
               if a > 0 then
               begin
                  while not boolean(a and 1) do
                  begin  inc(BShift);  a := a shr 1;  end;
                  while boolean(a and 1) do
                  begin  inc(Badjust); a := a shr 1; end;
                  Badjust := 8 - Badjust;
               end;

               AShift := 0;
               Aadjust := 0;
               a := AMask;
               if a > 0 then
               begin
                  while not boolean(a and 1) do
                  begin  inc(AShift);  a := a shr 1;  end;
                  while boolean(a and 1) do
                  begin  inc(Aadjust); a := a shr 1; end;
                  Aadjust := 8 - Aadjust;
               end;
            end;
         end;  // the end mask adjustment
end;



////////////////////////////////////////////////////////////////////////////////

constructor  BTSurface.Create;
begin
   Animation    := 0;
   aBpp         := 0; { load to get auto Bpp from file else use current }
   Alpha        := 255;
   ColorOff     := 0;
   Transparent  := false;
   aRGBmask.Amask := $FF000000;
   aRGBmask.Rmask := $00FF0000;
   aRGBmask.Gmask := $0000FF00;
   aRGBmask.Bmask := $000000FF;
   aH_DC := 0;
   aHandle := 0;
   aSource := 0;
   aFastMemory := false;
end;


destructor   BTSurface.Destroy;
begin
   if aHandle <> 0 then DeleteObject(aHandle);
   if aH_DC <> 0 then 
   begin
      SelectObject(aH_DC,aDump);
      DeleteDC(aH_DC);
   end;
   inherited;
end;


function     BTSurface.GetDC : dword;
begin
   if aH_DC = 0 then
   begin
     aH_DC := CreateCompatibleDC(0);
     aDump := SelectObject(aH_DC,aHandle);
//     DeleteObject(SelectObject(aH_DC,aHandle)); //todo
   end;
   GetDC := aH_DC;
end;


procedure    BTSurface.ReleaseDC;
begin
   if aH_DC <> 0 then
   begin
      SelectObject(aH_DC,aDump);
      DeleteDC(aH_DC);
   end;
   aH_DC := 0;
end;

procedure    BTSurface.SetXlng(value:dword);
begin
   Init(value,Ylng,Bpp,@aRGBmask);
end;

procedure    BTSurface.SetYlng(value:dword);
begin
   Init(Xlng,value,Bpp,@aRGBmask);
end;


procedure    BTSurface.SetBpp(value:dword);
begin
   Init(Xlng,Ylng,value,@aRGBmask);
end;


procedure    BTSurface.SetRGBmask(mask:BTRGBmask);
begin
   Init(Xlng,Ylng,Bpp,@mask);
end;


procedure res_palette2; assembler;
asm
   db 0,0,0
 db 0,0,128
 db 0,128,0
 db 0,128,128
 db 128,0,0
 db 128,0,128
 db 128,128,0
 db 192,192,192
 db 160,160,164
 db 0,0,255
 db 0,255,0
 db 0,255,255
 db 255,0,0
 db 255,0,255
 db 255,255,0
 db 255,255,255

 db 255,240,212
 db 255,226,177
 db 255,212,142
 db 255,198,107
 db 255,184,72
 db 255,170,37
 db 255,170,0
 db 220,146,0
 db 185,122,0
 db 150,98,0
 db 115,74,0
 db 80,50,0
 db 255,227,212
 db 255,199,177
 db 255,171,142
 db 255,143,107
 db 255,115,72
 db 255,87,37
 db 255,85,0
 db 220,73,0
 db 185,61,0
 db 150,49,0
 db 115,37,0
 db 80,25,0
 db 255,212,212
 db 255,177,177
 db 255,142,142
 db 255,107,107
 db 255,72,72
 db 255,37,37
 db 255,0,0
 db 220,0,0
 db 185,0,0
 db 150,0,0
 db 115,0,0
 db 80,0,0
 db 255,212,227
 db 255,177,199
 db 255,142,171
 db 255,107,143
 db 255,72,115
 db 255,37,87
 db 255,0,85
 db 220,0,73
 db 185,0,61
 db 150,0,49
 db 115,0,37
 db 80,0,25
 db 255,212,240
 db 255,177,226
 db 255,142,212
 db 255,107,198
 db 255,72,184
 db 255,37,170
 db 255,0,170
 db 220,0,146
 db 185,0,122
 db 150,0,98
 db 115,0,74
 db 80,0,50
 db 255,212,255
 db 255,177,255
 db 255,142,255
 db 255,107,255
 db 255,72,255
 db 255,37,255
 db 255,0,255
 db 220,0,220
 db 185,0,185
 db 150,0,150
 db 115,0,115
 db 80,0,80
 db 240,212,255
 db 226,177,255
 db 212,142,255
 db 198,107,255
 db 184,72,255
 db 170,37,255
 db 170,0,255
 db 146,0,220
 db 122,0,185
 db 98,0,150
 db 74,0,115
 db 50,0,80
 db 227,212,255
 db 199,177,255
 db 171,142,255
 db 143,107,255
 db 115,72,255
 db 87,37,255
 db 85,0,255
 db 73,0,220
 db 61,0,185
 db 49,0,150
 db 37,0,115
 db 25,0,80
 db 212,212,255
 db 177,177,255
 db 142,142,255
 db 107,107,255
 db 72,72,255
 db 37,37,255
 db 0,0,255
 db 0,0,220
 db 0,0,185
 db 0,0,150
 db 0,0,115
 db 0,0,80
 db 212,227,255
 db 177,199,255
 db 142,171,255
 db 107,143,255
 db 72,115,255
 db 37,87,255
 db 0,85,255
 db 0,73,220
 db 0,61,185
 db 0,49,150
 db 0,37,115
 db 0,25,80
 db 212,240,255
 db 177,226,255
 db 142,212,255
 db 107,198,255
 db 72,184,255
 db 37,170,255
 db 0,170,255
 db 0,146,220
 db 0,122,185
 db 0,98,150
 db 0,74,115
 db 0,50,80
 db 212,255,255
 db 177,255,255
 db 142,255,255
 db 107,255,255
 db 72,255,255
 db 37,255,255
 db 0,255,255
 db 0,220,220
 db 0,185,185
 db 0,150,150
 db 0,115,115
 db 0,80,80
 db 212,255,240
 db 177,255,226
 db 142,255,212
 db 107,255,198
 db 72,255,184
 db 37,255,170
 db 0,255,170
 db 0,220,146
 db 0,185,122
 db 0,150,98
 db 0,115,74
 db 0,80,50
 db 212,255,227
 db 177,255,199
 db 142,255,171
 db 107,255,143
 db 72,255,115
 db 37,255,87
 db 0,255,85
 db 0,220,73
 db 0,185,61
 db 0,150,49
 db 0,115,37
 db 0,80,25
 db 212,255,212
 db 177,255,177
 db 142,255,142
 db 107,255,107
 db 72,255,72
 db 37,255,37
 db 0,255,0
 db 0,220,0
 db 0,185,0
 db 0,150,0
 db 0,115,0
 db 0,80,0
 db 227,255,212
 db 199,255,177
 db 171,255,142
 db 143,255,107
 db 115,255,72
 db 87,255,37
 db 85,255,0
 db 73,220,0
 db 61,185,0
 db 49,150,0
 db 37,115,0
 db 25,80,0
 db 240,255,212
 db 226,255,177
 db 212,255,142
 db 198,255,107
 db 184,255,72
 db 170,255,37
 db 170,255,0
 db 146,220,0
 db 122,185,0
 db 98,150,0
 db 74,115,0
 db 50,80,0
 db 255,255,212
 db 255,255,177
 db 255,255,142
 db 255,255,107
 db 255,255,72
 db 255,255,37
 db 255,255,0
 db 220,220,0
 db 185,185,0
 db 150,150,0
 db 115,115,0
 db 80,80,0

 db 255,255,255
 db 245,245,245
 db 234,234,234
 db 223,223,223
 db 211,211,211
 db 200,200,200
 db 189,189,189
 db 178,178,178
 db 167,167,167
 db 156,156,156
 db 145,145,145
 db 134,134,134
 db 122,122,122
 db 111,111,111
 db 100,100,100
 db 89,89,89
 db 78,78,78
 db 67,67,67
 db 56,56,56
 db 45,45,45
 db 33,33,33
 db 22,22,22
 db 11,11,11
 db 0,0,0


/////
 db   0,  0,  0
 db   0,  0,160
 db   0,160,  0
 db   0,160,160
 db 160,  0,  0
 db 160,  0,160
 db 160,100,  0
 db 160,160,160
 db 100,100,100
 db   0,  0,255
 db   0,255,  0
 db   0,255,255
 db 255,  0,  0
 db 255,  0,255
 db 255,255,  0
 db 255,255,255
 {     (0,51,102,153,204,255);
       for R:=1 to 6 do for G:=1 to 6 do for B:=1 to 6 do ...
       total 6x6x6 = 216
       optimized for color dithering
 }
 db   0,  0,  0,  0,  0, 51,  0,  0,102,  0,  0,153,  0,  0,204,  0,  0,255
 db   0, 51,  0,  0, 51, 51,  0, 51,102,  0, 51,153,  0, 51,204,  0, 51,255
 db   0,102,  0,  0,102, 51,  0,102,102,  0,102,153,  0,102,204,  0,102,255
 db   0,153,  0,  0,153, 51,  0,153,102,  0,153,153,  0,153,204,  0,153,255
 db   0,204,  0,  0,204, 51,  0,204,102,  0,204,153,  0,204,204,  0,204,255
 db   0,255,  0,  0,255, 51,  0,255,102,  0,255,153,  0,255,204,  0,255,255

 db  51,  0,  0, 51,  0, 51, 51,  0,102, 51,  0,153, 51,  0,204, 51,  0,255
 db  51, 51,  0, 51, 51, 51, 51, 51,102, 51, 51,153, 51, 51,204, 51, 51,255
 db  51,102,  0, 51,102, 51, 51,102,102, 51,102,153, 51,102,204, 51,102,255
 db  51,153,  0, 51,153, 51, 51,153,102, 51,153,153, 51,153,204, 51,153,255
 db  51,204,  0, 51,204, 51, 51,204,102, 51,204,153, 51,204,204, 51,204,255
 db  51,255,  0, 51,255, 51, 51,255,102, 51,255,153, 51,255,204, 51,255,255

 db 102,  0,  0,102,  0, 51,102,  0,102,102,  0,153,102,  0,204,102,  0,255
 db 102, 51,  0,102, 51, 51,102, 51,102,102, 51,153,102, 51,204,102, 51,255
 db 102,102,  0,102,102, 51,102,102,102,102,102,153,102,102,204,102,102,255
 db 102,153,  0,102,153, 51,102,153,102,102,153,153,102,153,204,102,153,255
 db 102,204,  0,102,204, 51,102,204,102,102,204,153,102,204,204,102,204,255
 db 102,255,  0,102,255, 51,102,255,102,102,255,153,102,255,204,102,255,255

 db 153,  0,  0,153,  0, 51,153,  0,102,153,  0,153,153,  0,204,153,  0,255
 db 153, 51,  0,153, 51, 51,153, 51,102,153, 51,153,153, 51,204,153, 51,255
 db 153,102,  0,153,102, 51,153,102,102,153,102,153,153,102,204,153,102,255
 db 153,153,  0,153,153, 51,153,153,102,153,153,153,153,153,204,153,153,255
 db 153,204,  0,153,204, 51,153,204,102,153,204,153,153,204,204,153,204,255
 db 153,255,  0,153,255, 51,153,255,102,153,255,153,153,255,204,153,255,255

 db 204,  0,  0,204,  0, 51,204,  0,102,204,  0,153,204,  0,204,204,  0,255
 db 204, 51,  0,204, 51, 51,204, 51,102,204, 51,153,204, 51,204,204, 51,255
 db 204,102,  0,204,102, 51,204,102,102,204,102,153,204,102,204,204,102,255
 db 204,153,  0,204,153, 51,204,153,102,204,153,153,204,153,204,204,153,255
 db 204,204,  0,204,204, 51,204,204,102,204,204,153,204,204,204,204,204,255
 db 204,255,  0,204,255, 51,204,255,102,204,255,153,204,255,204,204,255,255

 db 255,  0,  0,255,  0, 51,255,  0,102,255,  0,153,255,  0,204,255,  0,255
 db 255, 51,  0,255, 51, 51,255, 51,102,255, 51,153,255, 51,204,255, 51,255
 db 255,102,  0,255,102, 51,255,102,102,255,102,153,255,102,204,255,102,255
 db 255,153,  0,255,153, 51,255,153,102,255,153,153,255,153,204,255,153,255
 db 255,204,  0,255,204, 51,255,204,102,255,204,153,255,204,204,255,204,255
 db 255,255,  0,255,255, 51,255,255,102,255,255,153,255,255,204,255,255,255

 { 216 + 16 = 232   256 - 232 = 24 for grey scale }

 db   0,  0,  0
 db  11, 11, 11
 db  22, 22, 22
 db  33, 33, 33
 db  45, 45, 45
 db  56, 56, 56
 db  67, 67, 67
 db  78, 78, 78
 db  89, 89, 89
 db 100,100,100
 db 111,111,111
 db 122,122,122
 db 134,134,134
 db 145,145,145
 db 156,156,156
 db 167,167,167
 db 178,178,178
 db 189,189,189
 db 200,200,200
 db 211,211,211
 db 223,223,223
 db 234,234,234
 db 245,245,245
 db 255,255,255
end;


Type
 MyPall = array [ 0..0] of byte;

function     BTSurface.Init(Xres,Yres,Bpp :Dword; RGBmask:PBTRGBmask):dword;
var i,oldSize :dword;
    temp_H_DC   :dword;
    old_bmp     :dword;
    temp_Handle :dword;
    cbitmapinfo :pointer;
    p,oldp      :pointer;
    _A,_R,_G,_B :dword;
    pal8 : ^MyPall;
    ByPP        :dword;
begin
   temp_Handle := 0;

   ByPP := 1;

   if bpp in [1,4,8,15,16,24,32] then
   begin


   oldp := pointer(aSource);
   oldSize := aPitch * aYlng;
                     { 95/98/Me suport only AABBGGRR }
   _A := $FF000000;
   _R := $00FF0000;
   _G := $0000FF00;
   _B := $000000FF;
   if RGBmask <> nil then
   begin
      _A := RGBmask.Amask;
      _R := RGBmask.Rmask;
      _G := RGBmask.Gmask;
      _B := RGBmask.Bmask;
   end;

//                              BITMAPV5HEADER
   getmem(cbitmapinfo, sizeof(BITMAPINFOHEADER)+1024);
   if cbitmapinfo <> nil then
   begin

   {
     ALPHA DIB
    ZeroMemory(&bi,sizeof(BITMAPV5HEADER));
    bi.bV5Size           = sizeof(BITMAPV5HEADER);
    bi.bV5Width           = dwWidth;
    bi.bV5Height          = dwHeight;
    bi.bV5Planes = 1;
    bi.bV5BitCount = 32;
    bi.bV5Compression = BI_BITFIELDS;
    // The following mask specification specifies a supported 32 BPP
    // alpha format for Windows XP.
    bi.bV5RedMask   =  0x00FF0000;
    bi.bV5GreenMask =  0x0000FF00;
    bi.bV5BlueMask  =  0x000000FF;
    bi.bV5AlphaMask =  0xFF000000;

    }

//      aPitch := (((Xres * Bpp) +31) shr 5) * 4;
//      aPitch := (((((Xres * Bpp) shr 3) -1) shr 2 ) + 1) shl 2;

      aPitch := ((Xres * Bpp + 31) and ( not 31 )) shr 3;
      if Bpp = 15 then aPitch := ((Xres * 16 + 31) and ( not 31 )) shr 3;


      aBitmapInfoHeader.biSize          := SizeOf(BitmapInfoHeader);
      aBitmapInfoHeader.biWidth         := Xres;
      aBitmapInfoHeader.biHeight        := - longint(Yres);  { Top Down / no compresion }
      aBitmapInfoHeader.biPlanes        := 1;
      aBitmapInfoHeader.biBitCount      := Bpp;
      if Bpp = 15 then aBitmapInfoHeader.biBitCount := 16;  { 15 -> 16 / mask control for 5.5.5 }
      aBitmapInfoHeader.biCompression   := BI_BITFIELDS; {15,16,32}
      if Bpp = 24 then aBitMapInfoHeader.biCompression := BI_RGB; {24 B ofs+0 , R + 1, G + 2 ..  :(}
      aBitmapInfoHeader.biSizeImage     := aPitch * Yres;
      aBitmapInfoHeader.biXPelsPerMeter := 0;
      aBitmapInfoHeader.biYPelsPerMeter := 0;
      aBitmapInfoHeader.biClrUsed       := 0; // set!!! see text
      aBitmapInfoHeader.biClrImportant  := 0;

      aBitMapColorsCount := 0;

      if Bpp <= 8 then
      begin
         aBitmapInfoHeader.biCompression  := BI_RGB;
         if Bpp = 8 then
         begin
           aBitmapInfoHeader.biclrused      := 256;
           aBitmapColorsCount               := 256;

           pal8 := @res_palette2;

//           Palette.Version := $300;
//           Palette.Entries := 256;
//           GetSystemPaletteEntries(GetDC(0),0,256,Palette.Colors);

           for i:= 0 to 255  do aBitmapColors[i] := rgb(pal8[i*3+2],pal8[i*3+1],pal8[i*3]); //       Palette.Colors[i] and $FFFFFF;
         end;

         if Bpp = 1 then
         begin
            aBitmapInfoHeader.biclrused   := 2;
            aBitmapColorsCount            := 2;
            aBitmapColors[0] := 0;
            aBitmapColors[1] := $FFFFFF;
         end;
         if Bpp = 4 then
         begin
            aBitmapInfoHeader.biclrused   := 16;
            aBitmapColorsCount            := 16;
            aBitmapColors[0]  := 0;
            aBitmapColors[1]  := $000080;
            aBitmapColors[2]  := $008000;
            aBitmapColors[3]  := $008080;
            aBitmapColors[4]  := $800000;
            aBitmapColors[5]  := $800080;
            aBitmapColors[6]  := $808000;
            aBitmapColors[7]  := $c0c0c0;
            aBitmapColors[8]  := $a0a0a4;
            aBitmapColors[9]  := $0000ff;
            aBitmapColors[10] := $00ff00;
            aBitmapColors[11] := $00ffff;
            aBitmapColors[12] := $ff0000;
            aBitmapColors[13] := $ff00ff;
            aBitmapColors[14] := $ffff00;
            aBitmapColors[15] := $ffffff;
         end;

      end else begin
         case Bpp of
               15: begin _R := $7C00; _G := $03E0;  _B := $001F;  ByPP := 2; end;
               16: begin _R := $F800; _G := $07E0;  _B := $001F;  ByPP := 2; end;
               24: begin ByPP := 3; end;
               32: begin ByPP := 4; end;
         end;
         if Bpp < 32 then _A := 0;

         aBitmapColors[0] := _R;
         aBitmapColors[1] := _G;
         aBitmapColors[2] := _B;
         aBitmapColorsCount := 3;
      end;

      aBitmapInfoHeader.biClrUsed       := aBitmapColorsCount;

      // Create Head
      move(aBitmapInfoHeader,cbitmapinfo^,sizeof(BITMAPINFOHEADER));
      move(aBitmapColors,pointer( dword(cbitmapinfo)+ sizeof(BITMAPINFOHEADER))^,1024);

      temp_H_DC := CreateCompatibleDC(0);
      aSource := 0;
      p := nil; { to create DIB in memory }

      if temp_H_DC <> 0 then
      begin
         if aFastMemory then
         begin
            GetMem(p,aPitch*Yres);
         end;

         temp_Handle := CreateDIBsection(temp_H_DC,BITMAPINFO(cbitmapinfo^),DIB_RGB_COLORS,p,0,0);

         aSource := dword(p);
         old_bmp := SelectObject(temp_H_DC, temp_Handle);
//         DeleteObject(SelectObject(temp_H_DC, temp_Handle));
      end;

      if temp_Handle <> 0 then
      begin
         // We Have a new BITMAP

         aBpp := Bpp; // need for this function
         AdjustRGBmaskValue(_A,_R,_G,_B);

         aRGBmask.Amask := aRGBmaskValue.Amask;
         aRGBmask.Rmask := aRGBmaskValue.Rmask;
         aRGBmask.Gmask := aRGBmaskValue.Gmask;
         aRGBmask.Bmask := aRGBmaskValue.Bmask;

         // Clear new screen
         fillchar(pointer(aSource)^, aPitch * Yres, 0);


         if aHandle <> 0 then
         begin
            // copy old to new
            aH_DC := self.GetDC;

            bitblt(temp_H_DC,0,0,aXlng,aYlng,aH_DC,0,0,SRCCOPY);

            // !! DELETE OLD HANDLES !!!!
            if aFastMemory then
            begin
               FreeMem(oldP,oldSize);
            end;
            self.ReleaseDC;
            DeleteObject(aHandle);
//            DeleteDC(aH_DC);
          end;
          SelectObject(temp_H_DC,old_bmp);
          DeleteDC(temp_H_DC);


          // All is ready
          aBytePP := ByPP;
          // aBpp := Bpp; look forword
          aXlng := Xres;
          aYlng := Yres;
////          aH_DC := temp_H_DC;
          aHandle := temp_Handle;

       end;
       freemem(cbitmapinfo, sizeof(BITMAPINFOHEADER)+1024);
    end;
    end;
    init := temp_Handle;
end;


procedure    BTSurface.SetSize(Xres,Yres :dword);
begin
   Init(Xres,Yres,Bpp,@aRGBmask);
end;


function     BTSurface.GetScanLine(row:dword):pointer;
begin
   if row > (aYlng - 1) then row := (aYlng - 1);
   GetScanLine := pointer((row * aPitch) + aSource);
end;


procedure    BTSurface.SetPalColor(i,r,g,b:byte);
var color :dword;
begin
   //???
   GetDC;
   if aH_DC <> 0 then
   begin
      color := (((((PC_NOCOLLAPSE shl 8) + r) shl 8) + g) shl 8) + b;
      aBitmapColors[i] := color and $FFFFFF;
      SetDIBColorTable(aH_DC,i,1,Color);
   end;
   ReleaseDC;
end;



Type
   TpalArray = array [0..0] of byte;

procedure    BTSurface.SetPalArray(Start,Count:dword; palarray:pointer);
var color : array [ 0..256] of dword;
    NewPal : ^TpalArray;
    i:dword;
begin
   NewPal := palarray;
   GetDC;
   begin
      if aH_DC <> 0 then
      begin
         for i := 0 to Count - 1 do
         color[i + Start] := (((((PC_NOCOLLAPSE shl 8) + NewPal[i*3]) shl 8) + NewPal[i*3+1]) shl 8) + NewPal[i*3+2];
         SetDIBColorTable(aH_DC,Start,Count,Color);
         for i := 0 to Count - 1 do aBitmapColors[start+i] := color[i+start] and $FFFFFF;
      end;
   end;
   ReleaseDC;
end;


procedure    BTSurface.LoadFromFile(name:pchar);
var d,oldd:HBITMAP;
    vdc:HDC;
    bm:BITMAP;
    aX,aY:dword;
//    s:string;
begin
  // first get from Resource
  //  d := LoadImage(GetModuleHandle(nil),Pchar(name),IMAGE_BITMAP,0,0,LR_DEFAULTSIZE or LR_CREATEDIBSECTION);
  d := LoadImage(hInstance,Pchar(name),IMAGE_BITMAP,0,0,LR_DEFAULTSIZE or LR_CREATEDIBSECTION);
  // if = 0 the from file
  if d = 0 then d := LoadImage(0,Pchar(name),IMAGE_BITMAP,0,0,LR_DEFAULTSIZE or LR_LOADFROMFILE or LR_CREATEDIBSECTION);
  if d <> 0 then
  begin
    vdc := CreateCompatibleDC(0);
    if dword(vdc) <> 0 then
    begin
       oldd := SelectObject(vdc,d);
       GetObject(d,sizeof(BITMAP),@bm);
       aX := bm.bmWidth;
       aY := bm.bmHeight;
       aBpp := bm.bmBitsPixel;
       Init(aX,aY,aBpp,nil);//@aRGBmask); // re create with new size of load picture
       // copy
       if self.GetDC <> 0 then
       begin
          bitblt(self.GetDC,0,0,aX,aY,vdc,0,0,SRCCOPY); { this will make conversion }
          self.ReleaseDC;
       end;
       SelectObject(vdc,oldd);
       DeleteDC(vdc);
    end;
    DeleteObject(d);
  end;
end;


procedure    BTSurface.SetProp(prop,Value:dword);
begin
   if Prop = 0 then aFastMemory := boolean(Value and 1);
end;


type  P_byte = array [0..0] of byte;
      P_word = array [0..0] of word;
      p_dword = array [0..0] of dword;

const mask1bit : array[0..31] of dword =
   (                                           { mem 1234567 -> 78563412 reg  }
    $00000080,$00000040,$00000020,$00000010,
    $00000008,$00000004,$00000002,$00000001,
    $00008000,$00004000,$00002000,$00001000,
    $00000800,$00000400,$00000200,$00000100,
    $00800000,$00400000,$00200000,$00100000,
    $00080000,$00040000,$00020000,$00010000,
    $80000000,$40000000,$20000000,$10000000,
    $08000000,$04000000,$02000000,$01000000
   );


procedure    BTSurface.SetPixelF(X,Y,Value:dword);
var pB : ^P_byte;
//    pW : ^P_word;
    pD : ^P_dword;
    m,x1 : dword;
    b : byte;
begin
   if X >= aXlng then Exit;
   if Y >= aYlng then Exit;

   case aBpp of
      1:     begin { is dword aligned }
                pD := pointer(aSource + Y*aPitch);
                m := mask1bit[X and $1F];
                X := X shr 5;
                if (Value and 1) = 0 then pD[X] := pD[X] and (not m)
                                     else pD[X] := pD[X] or m;
             end;
      4:     begin
                pB := pointer(aSource + Y*aPitch);
                X1 := X;
                X := X shr 1;
                b := pB[X];
                if ( X1 and 1 ) = 0 then b := (b and $0F) or ((Value and $FF) shl 4)
                                    else b := (b and $F0) or (Value and $FF);
                pB[X] := b;
             end;
      8:     begin p_byte(pointer(aSource + Y*aPitch)^)[X] := Value; end;
      15,16: begin p_word(pointer(aSource + Y*aPitch)^)[X] := Value; end;
      24:    begin
                m := aSource + Y*aPitch +X*3;
                word(pointer(m   )^) := Value; // No need of mask $FFFF :)
                byte(pointer(m +2)^) := Value shr 16;
             end;
      32:    begin p_dword(pointer(aSource + Y*aPitch)^)[X] := Value; end;

   end;
end;


function     BTSurface.GetPixelF(X,Y:dword):dword;
var pB : ^P_byte;
//    pW : ^P_word;
    pD : ^P_dword;
    m : dword;
    res : dword;
    b : byte;
begin
   res := 0;
   if X >= aXlng then X := 0;
   if Y >= aYlng then Y := 0;
   case aBpp of
      1:     begin
                m := mask1bit[X and $1F];
                pD := pointer(aSource + Y*aPitch);
                X := X shr 5;
                if (pD[X] and m) <> 0 then res := 1;
             end;
      4:     begin
                pB := pointer(aSource + Y*aPitch);
                X := X shr 1;
                b := pB[X shr 1];
                if ( X and 1 ) = 0 then res := (b and $F0) shr 4
                                    else res := (b and $0F);
             end;
      8:     begin res := p_byte(pointer(aSource + Y*aPitch)^)[X]; end;
      15,16: begin res := p_word(pointer(aSource + Y*aPitch)^)[X]; end;
      24:    begin
                m := aSource + Y*aPitch +X*3;
                res := word(pointer(m   )^);
                res := res or byte(pointer(m +2)^) shl 16;
             end;
      32:    begin res := p_dword(pointer(aSource + Y*aPitch)^)[X]; end;
   end;
   GetPixelF := res;
end;


procedure    BTSurface.SetPixelWLogic(X,Y,Value,Logic,LogicValue:dword);
var pB : ^P_byte;
    pW : ^P_word;
    pD : ^P_dword;
    a,c,m,x1 : dword;
    b : byte;
begin
   if X >= aXlng then Exit;
   if Y >= aYlng then Exit;

   case aBpp of
      1:     begin { is dword aligned }
                pD := pointer(aSource + Y*aPitch);
                m := mask1bit[X and $1F];
                X := X shr 5;
                if (Value and 1) = 0 then pD[X] := pD[X] and (not m)
                                     else pD[X] := pD[X] or m;
             end;
      4:     begin
                pB := pointer(aSource + Y*aPitch);
                X1 := X;
                X := X shr 1;
                b := pB[X];
                if ( X1 and 1 ) = 0 then b := (b and $0F) or ((Value and $FF) shl 4)
                                    else b := (b and $F0) or (Value and $FF);
                pB[X] := b;
             end;
      8:     begin pB := pointer(aSource + Y*aPitch);  pB[X] := Value; end;
      15,16: begin pW := pointer(aSource + Y*aPitch);  pW[X] := Value; end;
      24:    begin
                pB := pointer(aSource + Y*aPitch);  m := X*3;
                pB[m]   := value and $FF;
                pB[m+1] := (value shr 8) and $FF;
                pB[m+2] := (value shr 16) and $FF;
             end;
      32:    begin pD := pointer(aSource + Y*aPitch);
               case Logic of
                 0:  pD[X] := Value;
                 1:  pD[X] := pD[X] or Value;
                 2:  pD[X] := pD[X] xor Value;
                 3:  pD[X] := pD[X] and Value;
                 4:  pD[X] := not Value;
                 5:  begin // Modulate
                       asm
                         mov   eax, Value
                         mov   ecx, eax
                         and   eax, 0FF00FFh
                         imul  LogicValue
                         shr   eax, 8
                         and   eax, 0FF00FFh
                         xchg  eax, ecx
                         and   eax, 0FF00h
                         imul  LogicValue
                         shr   eax, 8
                         and   eax, 0FF00h
                         or    eax, ecx
                         mov   Value, eax
                       end;
                       pD[X] := value;
                     end;
                 6:  begin // Alpha
                       a := pD[X];
                       asm
                         mov   edx, LogicValue
                         mov   eax, Value
                         mov   ecx, A
                         and   eax, 0FF00FFh
                         and   ecx, 0FF00FFh
                         sub   eax, ecx
                         imul  eax, edx
                         shr   eax, 8
                         add   eax, ecx
                         and   eax, 0FF00FFh
                         mov   C, eax

                         mov   eax, Value
                         mov   ecx, A
                         and   eax, 000FF00h
                         and   ecx, 000FF00h
                         sub   eax, ecx
                         imul  eax, edx
                         shr   eax, 8
                         add   eax, ecx
                         and   eax, 000FF00h
                         or    eax, C

                         mov  Value, eax
                       end;
                       pD[X] := value;
                     end;
                 7:  begin // Add
                       A := pD[X];
                       asm
                         mov   eax, Value
                         mov   ecx, A
                         and   eax, 0FF00FFh
                         and   ecx, 0FF00FFh
                         add   eax, ecx
                         shr   eax, 1
                         and   eax, 0FF00FFh
                         mov   edx, Value
                         mov   ecx, A
                         and   edx, 0FF00h
                         and   ecx, 0FF00h
                         add   edx, ecx
                         shr   edx, 1
                         and   edx, 0FF00h
                         or    eax, edx
                         mov   Value, eax
                       end;
                       pD[X] := value;
                     end;

               end;
             end;
   end;
end;


function     BTSurface.rgb2color(A, R, G, B :dword):dword;
var Color,aa,minindx:dword;
    minval,val,Rv,Gv,Bv:longint;
begin
   if (aBpp > 8 ) then
   begin
      { 15,16,24,32 bpp }

      Color := ( ((A and $FF) shr aRGBmaskValue.Aadjust) shl aRGBmaskValue.AShift )
            or ( ((R and $FF) shr aRGBmaskValue.Radjust) shl aRGBmaskValue.RShift )
            or ( ((G and $FF) shr aRGBmaskValue.Gadjust) shl aRGBmaskValue.GShift )
            or ( ((B and $FF) shr aRGBmaskValue.Badjust) shl aRGBmaskValue.BShift );
   end else begin
      { for 8 bpp }
      {
      // find near color
      // val = sqr((r1-r2)^2 + (g1-g2)^2 + (b1-b2)^2)
      // val^2 = ((r1-r2)^2 + (g1-g2)^2 + (b1-b2)^2)
      // if val1 < val2 is equal to val1^2 < val2^2
      // max val is 3 * 256^2 = 3*196608
      // in this case 256000 is good
      }
      minval := 256000;
      minindx := 0; { must be black }
      for aa := 0 to (aBitmapColorsCount -1) do
      begin
         RV := longint((aBitmapColors[aa] and $FF0000) shr 16)  - longint(R) ;
         GV := longint((aBitmapColors[aa] and $FF00) shr 8)  - longint(G) ;
         BV := longint((aBitmapColors[aa] and $FF))  - longint(B) ;
         val := (RV * RV) + (GV * GV) + (BV * BV);
         if (val <= minval) then
         begin
            minval := val;
            minindx := aa;
         end;
      end;
      Color := minindx;
   end ;
   rgb2color := Color;
end;

procedure     BTSurface.color2rgb(Color :dword; var A, R, G, B :dword);
begin
   if aBpp > 8 then
   begin
      A := byte((( Color and aRGBmaskValue.AMask ) shr aRGBmaskValue.AShift) shl aRGBmaskValue.Aadjust );
      R := byte((( Color and aRGBmaskValue.RMask ) shr aRGBmaskValue.RShift) shl aRGBmaskValue.Radjust );
      G := byte((( Color and aRGBmaskValue.GMask ) shr aRGBmaskValue.GShift) shl aRGBmaskValue.Gadjust );
      B := byte((( Color and aRGBmaskValue.BMask ) shr aRGBmaskValue.BShift) shl aRGBmaskValue.Badjust );
   end else begin
      { Get from palette }
      Color := Color and $FF;
      R := (aBitmapColors[Color] and $FF0000) shr 16;
      G := (aBitmapColors[Color] and $FF00) shr 8;
      B := (aBitmapColors[Color] and $FF);
   end;
end;


procedure     BTSurface.SaveToFile(name:string);
var
  cSize,size,src,i,a: DWord;
  hFile: Windows.HFILE;
  fHead: BITMAPFILEHEADER;
  aY:longint;
begin
   if Handle <> 0 then
   begin
      size := aPitch * aYlng;
      hFile:=CreateFile(PChar(Name),GENERIC_WRITE,0,nil,CREATE_ALWAYS,0,0);

      cSize := aBitmapColorsCount*4;

      aY := aBitmapInfoHeader.biHeight;
      aBitmapInfoHeader.biHeight := aY * -1; // I need to reverse picture because
                                             // stupid microsoft loadimage
                                             // can load normal image
      fHead.bfType := $4D42;
      fHead.bfSize := sizeof(BITMAPFILEHEADER)+sizeof(BITMAPINFOHEADER)+cSize+Size;
      fHead.bfOffBits := sizeof(BITMAPFILEHEADER)+sizeof(BITMAPINFOHEADER)+cSize;
      fHead.bfReserved1 := 0;
      fHead.bfReserved2 := 0;

      WriteFile(hFile,fHead,SizeOf(fHead),i,nil);
      WriteFile(hFile,aBitmapInfoHeader,sizeof(BITMAPINFOHEADER),i,nil);
      if cSize <> 0 then WriteFile(hFile,aBitmapColors,cSize,i,nil);
      src := aSource + Size - aPitch;
      for i:=1 to aYlng do
      begin
         WriteFile(hFile,pointer(src)^,aPitch,a,nil);
         src := src - aPitch;
      end;
      CloseHandle(hFile);
      aBitmapInfoHeader.biHeight := aY;
   end;
end;

procedure  BTSurface.DrawTo(to_dc :dword; X, Y:longint);
begin
   aH_DC := self.GetDC;
   BitBlt(to_dc,x,y,aXlng,aYlng,aH_dc,0,0,SRCCOPY);
   self.ReleaseDC;
end;

end.
