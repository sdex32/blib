unit BBase64;

interface

function    BCodeBase64(const in_s:AnsiString):AnsiString;
function    BDecodeBase64(in_s:AnsiString):AnsiString;

implementation




function    BCodeBase64(const in_s:AnsiString):AnsiString;
const
Map: array[0..63] of Char = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
var j,k:longword;
    le : longint;
    aCount :longword;
    outs :boolean;
begin
   aCount := length(in_s);
   Result := '';
   if aCount > 0 then
   begin
      le := (((((aCount - 1) div 3 ) + 1) * 4)  ); // for uni code
      k := 1;
      j := 1;
      SetLength(Result,le);
      outs := true;
      le := aCount;
      while outs do
      begin
         //byte 0    11111100  >> 2   -> 00111111
         Result[K+0] := ansichar(Map[ byte(in_s[j + 0]) shr 2 ]);
         //byte 0    00000011 << 4   00110000
         //byte 1    11110000 >> 4   00001111
         //        or                00111111
         if le > 1 then Result[K+1] := ansichar(Map[ ((byte(in_s[J + 0]) and $3) shl 4) or ((byte(in_s[J + 1]) and $F0) shr 4) ])
                   else Result[K+1] := ansichar(Map[ (byte(in_s[J + 0]) and $3) shl 4 ]);
         //byte 1     00001111 << 2  00111100
         //byte 2     11000000 >> 6  00000011
         if le > 2 then Result[k+2] := ansichar(Map[ ((byte(in_s[J + 1]) and $f) shl 2) or ((byte(in_s[J + 2]) and $c0) shr 6) ])
                   else begin
                      if le > 1 then Result[k+2] := ansichar(Map[((byte(in_s[J + 1]) and $f) shl 2) ])
                                else Result[k+2] := ansichar('=');
                   end;
         if le > 2 then Result[k+3] := ansichar(Map[ (byte(in_s[J + 2]) and $3F) ])
                   else Result[k+3] := ansichar('=');
         inc(k,4);
         inc(j,3);
         dec(le,3);
         if le <= 0 then outs := false;
      end;
   end;
end;


function    BDecodeBase64(in_s:AnsiString):AnsiString;
const
  Map: array[0..255] of Byte = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 62, 0, 0, 0, 63, 52, 53,
    54, 55, 56, 57, 58, 59, 60, 61, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2,
    3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19,
    20, 21, 22, 23, 24, 25, 0, 0, 0, 0, 0, 0, 26, 27, 28, 29, 30,
    31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45,
    46, 47, 48, 49, 50, 51, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0);
var sz,bs,i,l,p,bo:longword;
begin
   bo := 1;
   Result := '';
   sz := length(in_s);
   if sz > 0  then
   begin
      i := sz mod 4; // correction for unaligned files :(
      if i <> 0 then for l := 1 to (4-i) do in_s := in_s + '=';
      sz := length(in_s);
      if sz mod 4 = 0 then
      begin
         bs := (sz div 4) * 3;
         SetLength(result,bs);
         sz := sz div 4;
         for l:= 1 to sz do
         begin
            p := (l - 1 ) * 4;
            I := Map[byte(in_s[P + 1])];
            I := (I shl 6 ) or (longword(Map[byte(in_s[P + 2])]));
            I := (I shl 6 ) or (longword(Map[byte(in_s[P + 3])]));
            I := (I shl 6 ) or (longword(Map[byte(in_s[P + 4])]));
            Result[bo] := ansichar((i shr 16) and $FF); inc(bo);
            if byte(in_s[P + 3]) <> byte('=') then
            begin
               Result[bo] := ansichar((i shr 8 ) and $FF); inc(bo);
               if byte(in_s[P + 4]) <> byte('=') then
               begin
                  Result[bo] := ansichar((i ) and $FF); inc(bo);
               end;
            end;
         end;
         if bs <> (bo-1) then SetLength(Result,bo-1); //readjust aproximation
      end;
   end;
end;



end.
