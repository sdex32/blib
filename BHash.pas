unit BHash;
interface

function RSHash   (const Str : Ansistring) : Cardinal;
function JSHash   (const Str : Ansistring) : Cardinal;
function PJWHash  (const Str : Ansistring) : Cardinal;
function ELFHash  (const Str : Ansistring) : Cardinal;
function BKDRHash (const Str : Ansistring) : Cardinal;
function SDBMHash (const Str : Ansistring) : Cardinal;
function DJBHash  (const Str : Ansistring) : Cardinal;
function DEKHash  (const Str : Ansistring) : Cardinal;
function BPHash   (const Str : Ansistring) : Cardinal;
function FNVHash  (const Str : Ansistring) : Cardinal;
function FNV1aHash(const Str : Ansistring) : Cardinal;
function APHash   (const Str : Ansistring) : Cardinal;



implementation


function RSHash(const Str : Ansistring) : Cardinal;
const b = 378551;
var
  a : Cardinal;
  i : Integer;
begin
  a      := 63689;
  Result := 0;
  for i := 1 to Length(Str) do
  begin
    Result := Result * a + Ord(Str[i]);
    a      := a * b;
  end;
end;
(* End Of RS Hash function *)


function JSHash(const Str : Ansistring) : Cardinal;
var
  i : Integer;
begin
  Result := 1315423911;
  for i := 1 to Length(Str) do
  begin
    Result := Result xor ((Result shl 5) + Ord(Str[i]) + (Result shr 2));
  end;
end;
(* End Of JS Hash function *)


function PJWHash(const Str : Ansistring) : Cardinal;
const BitsInCardinal = Sizeof(Cardinal) * 8;
const ThreeQuarters  = (BitsInCardinal  * 3) div 4;
const OneEighth      = BitsInCardinal div 8;
const HighBits       : Cardinal = (not Cardinal(0)) shl (BitsInCardinal - OneEighth);
var
  i    : Cardinal;
  Test : Cardinal;
begin
  Result := 0;
  for i := 1 to Length(Str) do
  begin
    Result := (Result shl OneEighth) + Ord(Str[i]);
    Test   := Result and HighBits;
    If (Test <> 0) then
    begin
      Result := (Result xor (Test shr ThreeQuarters)) and (not HighBits);
    end;
  end;
end;
(* End Of P. J. Weinberger Hash function *)


function ELFHash(const Str : Ansistring) : Cardinal;
var
  i : Cardinal;
  x : Cardinal;
begin
  Result := 0;
  for i := 1 to Length(Str) do
  begin
    Result := (Result shl 4) + Ord(Str[i]);
    x      := Result and $F0000000;
    if (x <> 0) then
    begin
      Result := Result xor (x shr 24);
    end;
    Result := Result and (not x);
  end;
end;
(* End Of ELF Hash function *)


function BKDRHash(const Str : Ansistring) : Cardinal;
const Seed = 131; (* 31 131 1313 13131 131313 etc... *)
var
  i : Cardinal;
begin
  Result := 0;
  for i := 1 to Length(Str) do
  begin
    Result := (Result * Seed) + Ord(Str[i]);
  end;
end;
(* End Of BKDR Hash function *)


function SDBMHash(const Str : Ansistring) : Cardinal;
var
  i : Cardinal;
begin
  Result := 0;
  for i := 1 to Length(Str) do
  begin
    Result := Ord(str[i]) + (Result shl 6) + (Result shl 16) - Result;
  end;
end;
(* End Of SDBM Hash function *)


function DJBHash(const Str : Ansistring) : Cardinal;
var
  i : Cardinal;
begin
  Result := 5381;
  for i := 1 to Length(Str) do
  begin
    Result := ((Result shl 5) + Result) + Ord(Str[i]);
  end;
end;
(* End Of DJB Hash function *)


function DEKHash(const Str : Ansistring) : Cardinal;
var
  i : Cardinal;
begin
  Result := Length(Str);
  for i := 1 to Length(Str) do
  begin
    Result := ((Result shr 5) xor (Result shl 27)) xor Ord(Str[i]);
  end;
end;
(* End Of DEK Hash function *)


function BPHash(const Str : Ansistring) : Cardinal;
var
  i : Cardinal;
begin
  Result := 0;
  for i := 1 to Length(Str) do
  begin
    Result := Result shl 7 xor Ord(Str[i]);
  end;
end;
(* End Of BP Hash function *)


function FNVHash(const Str : Ansistring) : Cardinal;
const FNVPrime = $811C9DC5;
var
  i : Cardinal;
begin
  Result := 0;
  for i := 1 to Length(Str) do
  begin
    Result := Result * FNVPrime;
    Result := Result xor Ord(Str[i]);
  end;
end;
(* End Of FNV Hash function *)

function  FNV1aHash(const Str:Ansistring) : Cardinal;
var i:integer;
const  //FNV-1a hash
    FNV_offset_basis = 2166136261;
    FNV_prime = 16777619;
begin
   result := FNV_offset_basis;
   for i := 1 to length(Str) do
      result := (result xor byte(Str[i])) * FNV_prime;
end;
(* End Of FNV variant  Hash function *)


function APHash(const Str : Ansistring) : Cardinal;
var
  i : Cardinal;
begin
  Result := $AAAAAAAA;
  for i := 1 to Length(Str) do
  begin
    if ((i - 1) and 1) = 0 then
      Result := Result xor ((Result shl 7) xor Ord(Str[i]) * (Result shr 3))
    else
      Result := Result xor (not((Result shl 11) + Ord(Str[i]) xor (Result shr 5)));
  end;
end;
(* End Of AP Hash function *)




end.
