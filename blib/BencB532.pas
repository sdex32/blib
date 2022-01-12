unit BencB532;

interface

function  encB532_code(w:longword):ansistring;
function  encB532_decode(a:ansistring):longword;

function  encB532_code7(w:longword):ansistring;
function  encB532_decode7(a:ansistring):longword;

function  encB532_validate(a:ansistring):boolean;


implementation

const B532tab : array [0..31] of ansichar =
      ('M', '0', '2', 'V', 'E', 'F', '9', 'Q',
       'A', 'C', '1', 'D', '3', 'G', 'Z', 'W',
       'N', 'P', 'R', '6', '4', 'Y', 'L', '8',
       '5', 'B', 'S', 'T', 'X', '7', 'H', 'K');


function  encB532_validate(a:ansistring):boolean;
var i,j,k,m:longword;
begin
  Result := false;
  j:=length(a);
  if (j = 6) or (j = 7) then
  begin
     k := 0;
     for i:= 1 to j do
     begin
        for m := 0 to 31 do if a[i] = B532tab[m] then inc(k);
     end;
     if k = j then Result := true; //OK
  end;
end;

function  encB532_code(w:longword):ansistring;
var w1,w2,w3,w4,w5,w6:longword;
begin
    Result := '000000';
    w1 :=  w and $1F;          //max encode val  1FFFFFF = 33 554 431
    w2 := (w shr 5) and $1F;
    w3 := (w shr 10) and $1F;
    w4 := (w shr 15) and $1F;
    w5 := (w shr 20) and $1F;
    w6 := w1 xor w2 xor w3 xor w4 xor w5;
    RandSeed:=w6;
    Result[1] := B532tab[w1 xor longword(Random($1F))];
    Result[2] := B532tab[w2 xor longword(Random($1F))];
    Result[5] := B532tab[w3 xor longword(Random($1F))];
    Result[6] := B532tab[w4 xor longword(Random($1F))];
    Result[3] := B532tab[w5 xor longword(Random($1F))];
    Result[4] := B532tab[w6];
end;

function  encB532_decode(a:ansistring):longword;
var w1,w2,w3,w4,w5,w6:longword;
   function fc(c:ansichar):longword;
   var i:longword;
   begin
      Result := 0;
      for i := 0 to 31 do if B532tab[i] = c then begin Result := i; break; end;
   end;
begin
   Result := 0;
   if length(a) <> 6 then Exit;
   w1 := fc(a[1]);
   w2 := fc(a[2]);
   w3 := fc(a[5]);
   w4 := fc(a[6]);
   w5 := fc(a[3]);
   w6 := fc(a[4]);
   RandSeed:=w6;
   w1 := w1 xor longword(Random($1F));
   w2 := w2 xor longword(Random($1F));
   w3 := w3 xor longword(Random($1F));
   w4 := w4 xor longword(Random($1F));
   w5 := w5 xor longword(Random($1F));
   Result := w1
          or (w2 shl 5)
          or (w3 shl 10)
          or (w4 shl 15)
          or (w5 shl 20);
end;


function  encB532_code7(w:longword):ansistring;
var w1,w2,w3,w4,w5,w6,w7,w8:longword;
begin
    Result := '0000000';
    w1 :=  w and $1F;          //max encode val  full FFFFFFFF
    w2 := (w shr 5) and $1F;
    w3 := (w shr 10) and $1F;
    w4 := (w shr 15) and $1F;
    w5 := (w shr 20) and $1F;
    w6 := (w shr 25) and $1F;
    w7 := (w shr 30) and $3;
    w8 := (((w1 xor w2 xor w3 xor w4 xor w5 xor w6 xor w7) and 7) shl 3) and $1C;
    RandSeed:=w8;
    Result[1] := B532tab[w1 xor longword(Random($1F))];
    Result[2] := B532tab[w2 xor longword(Random($1F))];
    Result[5] := B532tab[w3 xor longword(Random($1F))];
    Result[6] := B532tab[w4 xor longword(Random($1F))];
    Result[3] := B532tab[w5 xor longword(Random($1F))];
    Result[4] := B532tab[w6 xor longword(Random($1F))];
    w7 := ( (w7 xor longword(Random($1F))) and $3) or w8 ;
    Result[7] := B532tab[w7];
end;

function  encB532_decode7(a:ansistring):longword;
var w1,w2,w3,w4,w5,w6,w7,w8:longword;
   function fc(c:ansichar):longword;
   var i:longword;
   begin
      Result := 0;
      for i := 0 to 31 do if B532tab[i] = c then begin Result := i; break; end;
   end;
begin
   Result := 0;
   if length(a) <> 7 then Exit;
   w1 := fc(a[1]);
   w2 := fc(a[2]);
   w3 := fc(a[5]);
   w4 := fc(a[6]);
   w5 := fc(a[3]);
   w6 := fc(a[4]);
   w7 := fc(a[7]);
   w8 := w7 and $1C;
   w7 := w7 and $3;
   RandSeed:=w8;
   w1 := w1 xor longword(Random($1F));
   w2 := w2 xor longword(Random($1F));
   w3 := w3 xor longword(Random($1F));
   w4 := w4 xor longword(Random($1F));
   w5 := w5 xor longword(Random($1F));
   w6 := w6 xor longword(Random($1F));
   w7 := (w7 xor longword(Random($1F))) and $3;
   Result := w1
          or (w2 shl 5)
          or (w3 shl 10)
          or (w4 shl 15)
          or (w5 shl 20)
          or (w6 shl 25)
          or (w7 shl 30);
end;




end.
