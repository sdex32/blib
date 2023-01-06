unit BMath;

interface

function  Min(a,b :single):single;
function  Max(a,b :single):single;
function  Clamp(a,minv,maxv:single):single;
function  Radians( degrees :single) :single;
function  Degrees( radians :single) :single;
function  Rand :single; {0..1}
function  Ceil(X: single): integer;
function  Floor(X: single): integer;
function  Lerp(a, b, i :single) :single;



implementation

function  Min(a,b :single):single;
begin
   if a < b then Min := a
            else Min := b;
end;

function  Max(a,b :single):single;
begin
   if a > b then Max := a
            else Max := b;
end;

function  Clamp(a,minv,maxv:single):single;
begin
   Clamp := Min( Max(a,minv), maxv);
end;

function  Radians( degrees :single) :single;
begin
   Radians := (degrees * PI) / 180;
end;

function  Degrees( radians :single) :single;
begin
   Degrees := (radians * 180) / PI;
end;

function  Rand :single; {0..1}
begin
   Rand := Random;
end;

function  Ceil(X: single): integer;
begin
  Result := Integer(Trunc(X));
  if Frac(X) > 0 then
    Inc(Result);
end;

function  Floor(X: single): integer;
begin
  Result := Integer(Trunc(X));
  if Frac(X) < 0 then
    Dec(Result);
end;

function  Lerp(a, b, i :single) :single;
begin
   Lerp := a + i*(b-a);
end;



begin
   Randomize;
end.
