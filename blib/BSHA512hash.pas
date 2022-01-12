unit BSHA512hash;

interface

function SHA512(Data:pointer; DataLen:longword):ansistring;
function SHA512hex(Data:pointer; DataLen:longword):string;

implementation

uses BStrTools;

const K:array[0..79] of uint64 =
($428a2f98d728ae22, $7137449123ef65cd, $b5c0fbcfec4d3b2f, $e9b5dba58189dbbc,
 $3956c25bf348b538, $59f111f1b605d019, $923f82a4af194f9b, $ab1c5ed5da6d8118,
 $d807aa98a3030242, $12835b0145706fbe, $243185be4ee4b28c, $550c7dc3d5ffb4e2,
 $72be5d74f27b896f, $80deb1fe3b1696b1, $9bdc06a725c71235, $c19bf174cf692694,
 $e49b69c19ef14ad2, $efbe4786384f25e3, $0fc19dc68b8cd5b5, $240ca1cc77ac9c65,
 $2de92c6f592b0275, $4a7484aa6ea6e483, $5cb0a9dcbd41fbd4, $76f988da831153b5,
 $983e5152ee66dfab, $a831c66d2db43210, $b00327c898fb213f, $bf597fc7beef0ee4,
 $c6e00bf33da88fc2, $d5a79147930aa725, $06ca6351e003826f, $142929670a0e6e70,
 $27b70a8546d22ffc, $2e1b21385c26c926, $4d2c6dfc5ac42aed, $53380d139d95b3df,
 $650a73548baf63de, $766a0abb3c77b2a8, $81c2c92e47edaee6, $92722c851482353b,
 $a2bfe8a14cf10364, $a81a664bbc423001, $c24b8b70d0f89791, $c76c51a30654be30,
 $d192e819d6ef5218, $d69906245565a910, $f40e35855771202a, $106aa07032bbd1b8,
 $19a4c116b8d2d0c8, $1e376c085141ab53, $2748774cdf8eeb99, $34b0bcb5e19b48a8,
 $391c0cb3c5c95a63, $4ed8aa4ae3418acb, $5b9cca4f7763e373, $682e6ff3d6b2b8a3,
 $748f82ee5defb2fc, $78a5636f43172f60, $84c87814a1f0ab72, $8cc702081a6439ec,
 $90befffa23631e28, $a4506cebde82bde9, $bef9a3f7b2c67915, $c67178f2e372532b,
 $ca273eceea26619c, $d186b8c721c0c207, $eada7dd6cde0eb1e, $f57d4f7fee6ed178,
 $06f067aa72176fba, $0a637dc5a2c898a6, $113f9804bef90dae, $1b710b35131c471b,
 $28db77f523047d84, $32caab7b40c72493, $3c9ebe0a15c9bebc, $431d67c49c100d4c,
 $4cc5d4becb3e42b6, $597f299cfc657e2a, $5fcb6fab3ad6faec, $6c44198c4a475817);


function SwapDWord(a: int64): int64;
begin
  Result:= ((a and $FF) shl 56) or ((a and $FF00) shl 40) or ((a and $FF0000) shl 24) or ((a and $FF000000) shl 8) or
    ((a and $FF00000000) shr 8) or ((a and $FF0000000000) shr 24) or ((a and $FF000000000000) shr 40) or ((a and $FF00000000000000) shr 56);
end;


function SHA512(Data:pointer; DataLen:longword):ansistring;
var HashBuffer: array[0..127] of byte;
    CurrentHash: array[0..7] of uint64;
    a, b, c, d, e, f, g, h, t1, t2: uint64;
    W: array[0..79] of int64;
    LenHi, LenLo: int64;
    Index, size: longword;
    PBuf: ^byte;
    p:pointer;

   procedure Compress;
   var i: longword;
   begin
      Index:= 0;
      a:= CurrentHash[0]; b:= CurrentHash[1]; c:= CurrentHash[2]; d:= CurrentHash[3];
      e:= CurrentHash[4]; f:= CurrentHash[5]; g:= CurrentHash[6]; h:= CurrentHash[7];
      Move(HashBuffer,W,Sizeof(HashBuffer));
      for i:= 0 to 15 do
         W[i]:= SwapDWord(W[i]);
      for i:= 16 to 79 do
         W[i]:= (((W[i-2] shr 19) or (W[i-2] shl 45)) xor ((W[i-2] shr 61) or (W[i-2] shl 3)) xor
         (W[i-2] shr 6)) + W[i-7] + (((W[i-15] shr 1) or (W[i-15] shl 63)) xor ((W[i-15] shr 8) or
         (W[i-15] shl 56)) xor (W[i-15] shr 7)) + W[i-16];

      { Non-optimised version }
      for i:= 0 to 79 do
      begin
       t1:= h + (((e shr 14) or (e shl 50)) xor ((e shr 18) or (e shl 46)) xor ((e shr 41) or (e shl 23))) +
         ((e and f) xor (not e and g)) + K[i] + W[i];
       t2:= (((a shr 28) or (a shl 36)) xor ((a shr 34) or (a shl 30)) xor ((a shr 39) or (a shl 25))) +
         ((a and b) xor (a and c) xor (b and c));
       h:= g; g:= f; f:= e; e:= d + t1; d:= c; c:= b; b:= a; a:= t1 + t2;
      end;

      CurrentHash[0]:= CurrentHash[0] + a;
      CurrentHash[1]:= CurrentHash[1] + b;
      CurrentHash[2]:= CurrentHash[2] + c;
      CurrentHash[3]:= CurrentHash[3] + d;
      CurrentHash[4]:= CurrentHash[4] + e;
      CurrentHash[5]:= CurrentHash[5] + f;
      CurrentHash[6]:= CurrentHash[6] + g;
      CurrentHash[7]:= CurrentHash[7] + h;
      FillChar(W,Sizeof(W),0);
      FillChar(HashBuffer,Sizeof(HashBuffer),0);
   end;



begin
   //init;
   FillChar(HashBuffer,Sizeof(HashBuffer),0);

   CurrentHash[0]:= $6a09e667f3bcc908;
   CurrentHash[1]:= $bb67ae8584caa73b;
   CurrentHash[2]:= $3c6ef372fe94f82b;
   CurrentHash[3]:= $a54ff53a5f1d36f1;
   CurrentHash[4]:= $510e527fade682d1;
   CurrentHash[5]:= $9b05688c2b3e6c1f;
   CurrentHash[6]:= $1f83d9abfb41bd6b;
   CurrentHash[7]:= $5be0cd19137e2179;

   LenHi:= 0; LenLo:= 0;
   Index:= 0;

   //update
   Size := DataLen;
   Inc(LenLo,Size*8);
   if LenLo < (Size*8) then Inc(LenHi);
   pbuf := Data;
   while Size> 0 do
   begin
      if (Sizeof(HashBuffer)-Index)<= longWord(Size) then
      begin
         Move(PBuf^,HashBuffer[Index],Sizeof(HashBuffer)-Index);
         Dec(Size,Sizeof(HashBuffer)-Index);
         Inc(PBuf,Sizeof(HashBuffer)-Index);
         Compress;
      end else begin
         Move(PBuf^,HashBuffer[Index],Size);
         Inc(Index,Size);
         Size:= 0;
      end;
   end;

   //finish
   HashBuffer[Index]:= $80;
   if Index>= 112 then  Compress;
   Pint64(@HashBuffer[112])^:= SwapDWord(LenHi);
   Pint64(@HashBuffer[120])^:= SwapDWord(LenLo);
   Compress;

   CurrentHash[0]:= SwapDWord(CurrentHash[0]);
   CurrentHash[1]:= SwapDWord(CurrentHash[1]);
   CurrentHash[2]:= SwapDWord(CurrentHash[2]);
   CurrentHash[3]:= SwapDWord(CurrentHash[3]);
   CurrentHash[4]:= SwapDWord(CurrentHash[4]);
   CurrentHash[5]:= SwapDWord(CurrentHash[5]);
   CurrentHash[6]:= SwapDWord(CurrentHash[6]);
   CurrentHash[7]:= SwapDWord(CurrentHash[7]);

   SetLength(Result,64);
   p := @Result[1];
   Move(CurrentHash,p^,Sizeof(CurrentHash));
   index:= 12;
end;

function SHA512hex(Data:pointer; DataLen:longword):string;
var r:ansistring;
    i:longword;
begin
   Result := '';
   r := SHA512(Data,DataLen);
   for i:= 1 to 64 do Result:=Result + ToHex(byte(r[i]),2);
end;

end.
