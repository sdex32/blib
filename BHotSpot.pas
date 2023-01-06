unit BHotSpot;
{ (C) 2009 - last touch 21.1.2009

  Hot Spot 


}

interface

uses BSurface;

const
    BHotSpot_MaxCount = 20;
    BHotSpot_Clip     = $80000000;

type
    BTHotSpotCallBack = procedure (INDX:longword; X,Y,DX,DY:longint)of object;
    BTHotSpot = class
       private
{TODO   - add cursors shape circle triangle not only square
        - add cursor support
}
          aPointX : array[1..BHotSpot_MaxCount] of longint;
          aPointY : array[1..BHotSpot_MaxCount] of longint;
          aPColor : array[1..BHotSpot_MaxCount] of longword;
          aPColorB : array[1..BHotSpot_MaxCount] of longword;
          aPType  : array[1..BHotSpot_MaxCount] of longword;
          aPState : array[1..BHotSpot_MaxCount] of longword;
          aPCursor : array[1..BHotSpot_MaxCount] of longword;
          aCallBack : array[1..BHotSpot_MaxCount] of BTHotSpotCallBack;
          aCount :longword;
          aMouseDown :boolean;
          aMouseObj :longword;
          aRefresh :boolean; // Have to refresh;
          aSurface :BTSurface;
          aMinX,aMaxX,aMinY,aMaxY : longint;
          aOldX,aOldY :longint;
          procedure SetX(indx:longword; X:longint);
          procedure SetY(indx:longword; Y:longint);
          function  GetX(indx:longword):longint;
          function  GetY(indx:longword):longint;
       public
          procedure MouseDown(X,Y:longint);
          procedure MouseUp(X,Y:longint);
          procedure MouseMove(X,Y:longint);
          procedure Refresh(force:boolean); // Draw it on screen
          function  AddPoint(X,Y:longint; Format,Color,BorderColor:longword):longword;
          procedure SetCallBack(indx:longword; CBfunc:BTHotSpotCallBack);
          procedure GetHotSpot(indx:longword; var X,Y:longint; var T,C,BC,A:longword);
          procedure SetHotSpot(indx:longword; X,Y:longint; T,C,BC,A:longword);
          procedure DelHotSpot(indx:longword);
          procedure SetClipArea(minX,maxX,minY,maxY:longint);
          constructor Create(Surface:BTSurface);
          destructor  Destroy; override;
          property  PointsX [indx :longword]:longint read GetX write SetX;
          property  PointsY [indx :longword]:longint read GetY write SetY;
          property  Count:longword read aCount;
          property  NeedRefresh:boolean read aRefresh;
    end;




implementation



constructor BTHotSpot.Create(Surface:BTSurface);
var i:longword;
begin
   aSurface := Surface;
   aCount := 0;
   aMouseObj := $FFFF;
   aMouseDown := false;
   aRefresh := false;
   for i := 1 to BHotSpot_MaxCount do aPointX[i] := 0;
   for i := 1 to BHotSpot_MaxCount do aPointY[i] := 0;
   for i := 1 to BHotSpot_MaxCount do aPType[i] := 0;
   for i := 1 to BHotSpot_MaxCount do aPState[i] := 0;
   for i := 1 to BHotSpot_MaxCount do aPCursor[i] := 0;
   for i := 1 to BHotSpot_MaxCount do aCallBack[i] := nil;
   SetClipArea(0,0,65000,65000);
end;

destructor  BTHotSpot.Destroy;
begin
  inherited;
end;

procedure   BTHotSpot.SetX(indx:longword; X:longint);
begin
   if (indx > 0) and (indx <= BHotSpot_MaxCount) then
   begin
      aPointX[indx] := X;
   end;
end;

procedure   BTHotSpot.SetY(indx:longword; Y:longint);
begin
   if (indx > 0) and (indx <= BHotSpot_MaxCount) then
   begin
      aPointY[indx] := Y;
   end;
end;

function    BTHotSpot.GetX(indx:longword):longint;
begin
   result := 0;
   if (indx > 0) and (indx <= BHotSpot_MaxCount) then
   begin
      result := aPointX[indx];
   end;
end;

function    BTHotSpot.GetY(indx:longword):longint;
begin
   result := 0;
   if (indx > 0) and (indx <= BHotSpot_MaxCount) then
   begin
      result := aPointY[indx];
   end;
end;

procedure   BTHotSpot.MouseDown(X,Y:longint);
var i,mon,T:longword;
    xa,ya:longint;
begin
   aMouseObj := $FFFF;
   aMouseDown := true;
   if aCount >0 then
   begin
      for i := 1 to BHotSpot_MaxCount do
      begin
         if aPState[i] = 1 then
         begin
            mon := 0;
            T := aPType[i];
            case (T and $F) of
              0,2 : begin
                    xa := aPointX[i] -2 ;
                    ya := aPointY[i] -2 ;
                    if (x >= xa) and (x <= (xa + 4))
                    and (y >= ya) and (y <= (ya + 4)) then mon := 1;
              end;
              1,3 : begin
                    xa := aPointX[i] -3 ;
                    ya := aPointY[i] -3 ;
                    if (x >= xa) and (x <= (xa + 6))
                    and (y >= ya) and (y <= (ya + 6)) then mon := 1;
              end;
            end;
            if mon = 1 then
            begin
               aPointX[i] := x;
               aPointY[i] := y;
               aOldX := X;
               aOldY := Y;
               aMouseObj := i;
            end;
         end;
      end;
   end;

end;

procedure   BTHotSpot.MouseUp(X,Y:longint);
begin
   aMouseDown := false;
   aMouseObj := $FFFF;
end;

procedure   BTHotSpot.MouseMove(X,Y:longint);
begin
   if aMouseDown and (aMouseOBJ <> $FFFF) then
   begin
      if (aPType[aMouseOBJ] and BHotSpot_Clip) <> 0 then
      begin
         if X < aMinX then Exit;
         if X > aMaxX then Exit;
         if Y < aMinY then Exit;
         if Y > aMaxY then Exit;
      end;

      aPointX[aMouseOBJ] := X;
      aPointY[aMouseOBJ] := Y;
      if assigned(aCallBack[aMouseOBJ]) then aCallBack[aMouseOBJ](aMouseOBJ,X,Y,X-aOldX,Y-aOldY);

      aOldX := X;
      aOldY := Y;
      aRefresh := true;
   end;
end;

procedure   BTHotSpot.Refresh(force:boolean); // Draw it on screen
var i,xi,yi,c,b,T,L:longword;
    x,y,K:longint;
begin
   if force then aRefresh := true;

   if (aRefresh) and (aCount >0) then
   begin
      for i := 1 to BHotSpot_MaxCount do
      begin
         if aPState[i] = 1 then
         begin // have to draw
            L := 4; K := 2;
            T := aPType[i];
            case (T and $F) of
               1,3: begin L := 6; K := 3; end;
            end;

            x := aPointX[i] -K ;
            y := aPointY[i] -K ;
            c := aPColor[i]; // fill color
            b := aPColorB[i]; // Border

            case (T and $F) of
               0,1: begin
                    for yi := 0 to L do
                    for xi := 0 to L do
                    if (yi = 0) or (yi = L) or (xi = 0) or (xi = L) then aSurface.Pixels[xi+x,yi+y] := b
                                                                    else aSurface.Pixels[xi+x,yi+y] := c;
               end;
               2,3: begin


               end;

            end;
         end;
      end;
   end;
   aRefresh := false;
end;

function    BTHotSpot.AddPoint(X,Y:longint; Format,Color,BorderColor:longword):longword;
var i:longword;
begin
   result := 0;
   if aCount < BHotSpot_MaxCount then
   begin
      inc(aCount);
      // find place
      for i := 1 to BHotSpot_MaxCount do
      begin
         if aPState[i] = 0 then break;
      end;

      aPState[i] := 1; // ON marker;
      aPointX[i] := X;
      aPointY[i] := Y;
      aPType [i] := Format;
      aPColorB[i] := BorderColor;
      aPColor[i] := Color;
      aPCursor[i] := 0;
      aCallBack[i] := nil;
      aRefresh := true;
      Result := i;
   end;
end;

procedure   BTHotSpot.DelHotSpot(indx:longword);
begin
   if (indx > 0) and (indx <= BHotSpot_MaxCount) then
   begin
      dec(aCount);
      aPState[indx]  := 0; //OFF
      aCallBack[indx]:= nil;
      aRefresh := true;
   end;
end;

procedure   BTHotSpot.SetCallBack(indx:longword; CBfunc:BTHotSpotCallBack);
begin
   if (indx > 0) and (indx <= BHotSpot_MaxCount) then
   begin
      if aPState[indx] = 1 then aCallBack[indx] := CBfunc;
   end;
end;

procedure   BTHotSpot.GetHotSpot(indx:longword; var X,Y:longint; var T,C,BC,A:longword);
begin
   if (indx > 0) and (indx <= BHotSpot_MaxCount) then
   begin
      X := aPointX[indx];
      Y := aPointY[indx];
      T := aPType[indx];
      C := aPColor[indx];
      BC := aPColorB[indx];
      A := aPState[indx];
   end;
end;

procedure   BTHotSpot.SetHotSpot(indx:longword; X,Y:longint; T,C,BC,A:longword);
begin
   if (indx > 0) and (indx <= BHotSpot_MaxCount) then
   begin
      if aPState[indx] = 1 then
      begin
         aPointX[indx] := X;
         aPointY[indx] := Y;
         aPType[indx]  := T;
         aPColor[indx] := C;
         aPColorB[indx] := BC;
         aPState[indx] := A;
         aRefresh := true;
      end;
   end;
end;

procedure   BTHotSpot.SetClipArea(minX,maxX,minY,maxY:longint);
begin
   aMinX := minX;
   aMaxX := maxX;
   aMinY := minY;
   aMaxY := maxY;
end;



end.
