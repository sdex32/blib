unit BMD5hash;

interface

uses BStrTools;

function GetMD5hash(Data:pointer; dataLen:longword):string;



implementation

const
  T: array[1..64] of LongWord = ($D76AA478, $E8C7B756, $242070DB,
    $C1BDCEEE, $F57C0FAF, $4787C62A, $A8304613, $FD469501, $698098D8,
    $8B44F7AF, $FFFF5BB1, $895CD7BE, $6B901122, $FD987193, $A679438E,
    $49B40821, $F61E2562, $C040B340, $265E5A51, $E9B6C7AA, $D62F105D,
    $02441453, $D8A1E681, $E7D3FBC8, $21E1CDE6, $C33707D6, $F4D50D87,
    $455A14ED, $A9E3E905, $FCEFA3F8, $676F02D9, $8D2A4C8A, $FFFA3942,
    $8771F681, $6D9D6122, $FDE5380C, $A4BEEA44, $4BDECFA9, $F6BB4B60,
    $BEBFBC70, $289B7EC6, $EAA127FA, $D4EF3085, $04881D05, $D9D4D039,
    $E6DB99E5, $1FA27CF8, $C4AC5665, $F4292244, $432AFF97, $AB9423A7,
    $FC93A039, $655B59C3, $8F0CCC92, $FFEFF47D, $85845DD1, $6FA87E4F,
    $FE2CE6E0, $A3014314, $4E0811A1, $F7537E82, $BD3AF235, $2AD7D2BB,
    $EB86D391);


function F(X, Y, Z: LongWord): LongWord;
  begin
  Result := (X and Y) or ((not X) and Z)
end;

function G(X, Y, Z: LongWord): LongWord;
  begin
  Result := (X and Z) or (Y and (not Z))
end;

function H(X, Y, Z: LongWord): LongWord;
  begin
  Result := X xor Y xor Z
end;

function I(X, Y, Z: LongWord): LongWord;
  begin
  Result := Y xor (X or (not Z))
end;


function Rotate(L: LongWord; NumBits: Cardinal): LongWord;
  begin
  Result := (L shl NumBits) + (L shr (32 - NumBits))
end;

function swaplong(a:longword):longword;
begin
   Result := ((a shr 24) and $FF)
          or ((a shr 8) and $FF00)
          or ((a shl 8) and $FF0000)
          or ((a shl 24) and $FF000000);
end;


type ByteArray = array [0..0] of byte;
     PByteArray = ^ ByteArray;


function GetMD5hash(Data:pointer; dataLen:longword):string;
var
   Buffer: array[0..15] of LongWord;
   A: longword;
   B: longword;
   C: longword;
   D: longword;
   BufCount,Tmp :longword;
   P : PByteArray;
   ofs :longword;

   procedure _UpdateDigest;
   var
      AA: LongWord;
      BB: LongWord;
      CC: LongWord;
      DD: LongWord;
   begin
//      Inc(BlockCount);
      AA := A;
      BB := B;
      CC := C;
      DD := D;

      A := B + Rotate(A + F(B, C, D) + Buffer[ 0] + T[ 1],  7);
      D := A + Rotate(D + F(A, B, C) + Buffer[ 1] + T[ 2], 12);
      C := D + Rotate(C + F(D, A, B) + Buffer[ 2] + T[ 3], 17);
      B := C + Rotate(B + F(C, D, A) + Buffer[ 3] + T[ 4], 22);
      A := B + Rotate(A + F(B, C, D) + Buffer[ 4] + T[ 5],  7);
      D := A + Rotate(D + F(A, B, C) + Buffer[ 5] + T[ 6], 12);
      C := D + Rotate(C + F(D, A, B) + Buffer[ 6] + T[ 7], 17);
      B := C + Rotate(B + F(C, D, A) + Buffer[ 7] + T[ 8], 22);
      A := B + Rotate(A + F(B, C, D) + Buffer[ 8] + T[ 9],  7);
      D := A + Rotate(D + F(A, B, C) + Buffer[ 9] + T[10], 12);
      C := D + Rotate(C + F(D, A, B) + Buffer[10] + T[11], 17);
      B := C + Rotate(B + F(C, D, A) + Buffer[11] + T[12], 22);
      A := B + Rotate(A + F(B, C, D) + Buffer[12] + T[13],  7);
      D := A + Rotate(D + F(A, B, C) + Buffer[13] + T[14], 12);
      C := D + Rotate(C + F(D, A, B) + Buffer[14] + T[15], 17);
      B := C + Rotate(B + F(C, D, A) + Buffer[15] + T[16], 22);

      A := B + Rotate(A + G(B, C, D) + Buffer[ 1] + T[17],  5);
      D := A + Rotate(D + G(A, B, C) + Buffer[ 6] + T[18],  9);
      C := D + Rotate(C + G(D, A, B) + Buffer[11] + T[19], 14);
      B := C + Rotate(B + G(C, D, A) + Buffer[ 0] + T[20], 20);
      A := B + Rotate(A + G(B, C, D) + Buffer[ 5] + T[21],  5);
      D := A + Rotate(D + G(A, B, C) + Buffer[10] + T[22],  9);
      C := D + Rotate(C + G(D, A, B) + Buffer[15] + T[23], 14);
      B := C + Rotate(B + G(C, D, A) + Buffer[ 4] + T[24], 20);
      A := B + Rotate(A + G(B, C, D) + Buffer[ 9] + T[25],  5);
      D := A + Rotate(D + G(A, B, C) + Buffer[14] + T[26],  9);
      C := D + Rotate(C + G(D, A, B) + Buffer[ 3] + T[27], 14);
      B := C + Rotate(B + G(C, D, A) + Buffer[ 8] + T[28], 20);
      A := B + Rotate(A + G(B, C, D) + Buffer[13] + T[29],  5);
      D := A + Rotate(D + G(A, B, C) + Buffer[ 2] + T[30],  9);
      C := D + Rotate(C + G(D, A, B) + Buffer[ 7] + T[31], 14);
      B := C + Rotate(B + G(C, D, A) + Buffer[12] + T[32], 20);

      A := B + Rotate(A + H(B, C, D) + Buffer[ 5] + T[33],  4);
      D := A + Rotate(D + H(A, B, C) + Buffer[ 8] + T[34], 11);
      C := D + Rotate(C + H(D, A, B) + Buffer[11] + T[35], 16);
      B := C + Rotate(B + H(C, D, A) + Buffer[14] + T[36], 23);
      A := B + Rotate(A + H(B, C, D) + Buffer[ 1] + T[37],  4);
      D := A + Rotate(D + H(A, B, C) + Buffer[ 4] + T[38], 11);
      C := D + Rotate(C + H(D, A, B) + Buffer[ 7] + T[39], 16);
      B := C + Rotate(B + H(C, D, A) + Buffer[10] + T[40], 23);
      A := B + Rotate(A + H(B, C, D) + Buffer[13] + T[41],  4);
      D := A + Rotate(D + H(A, B, C) + Buffer[ 0] + T[42], 11);
      C := D + Rotate(C + H(D, A, B) + Buffer[ 3] + T[43], 16);
      B := C + Rotate(B + H(C, D, A) + Buffer[ 6] + T[44], 23);
      A := B + Rotate(A + H(B, C, D) + Buffer[ 9] + T[45],  4);
      D := A + Rotate(D + H(A, B, C) + Buffer[12] + T[46], 11);
      C := D + Rotate(C + H(D, A, B) + Buffer[15] + T[47], 16);
      B := C + Rotate(B + H(C, D, A) + Buffer[ 2] + T[48], 23);

      A := B + Rotate(A + I(B, C, D) + Buffer[ 0] + T[49],  6);
      D := A + Rotate(D + I(A, B, C) + Buffer[ 7] + T[50], 10);
      C := D + Rotate(C + I(D, A, B) + Buffer[14] + T[51], 15);
      B := C + Rotate(B + I(C, D, A) + Buffer[ 5] + T[52], 21);
      A := B + Rotate(A + I(B, C, D) + Buffer[12] + T[53],  6);
      D := A + Rotate(D + I(A, B, C) + Buffer[ 3] + T[54], 10);
      C := D + Rotate(C + I(D, A, B) + Buffer[10] + T[55], 15);
      B := C + Rotate(B + I(C, D, A) + Buffer[ 1] + T[56], 21);
      A := B + Rotate(A + I(B, C, D) + Buffer[ 8] + T[57],  6);
      D := A + Rotate(D + I(A, B, C) + Buffer[15] + T[58], 10);
      C := D + Rotate(C + I(D, A, B) + Buffer[ 6] + T[59], 15);
      B := C + Rotate(B + I(C, D, A) + Buffer[13] + T[60], 21);
      A := B + Rotate(A + I(B, C, D) + Buffer[ 4] + T[61],  6);
      D := A + Rotate(D + I(A, B, C) + Buffer[11] + T[62], 10);
      C := D + Rotate(C + I(D, A, B) + Buffer[ 2] + T[63], 15);
      B := C + Rotate(B + I(C, D, A) + Buffer[ 9] + T[64], 21);

      A := A + AA;
      B := B + BB;
      C := C + CC;
      D := D + DD;
      BufCount := 0;
      FillChar(Buffer, SizeOf(Buffer), 0)
   end;

   procedure _AddByte(Ba:Byte);
   begin
       case BufCount mod 4 of
            0: Buffer[BufCount div 4] := Buffer[BufCount div 4] or Ba;
            1: Buffer[BufCount div 4] := Buffer[BufCount div 4] or (Ba shl 8);
            2: Buffer[BufCount div 4] := Buffer[BufCount div 4] or (Ba shl 16);
            3: Buffer[BufCount div 4] := Buffer[BufCount div 4] or (Ba shl 24)
         end;
         Inc(BufCount);
         if BufCount = 64 then _UpdateDigest;
   end;

begin
   FillChar(Buffer, SizeOf(Buffer), 0);
   A := $67452301;
   B := $EFCDAB89;
   C := $98BADCFE;
   D := $10325476;
   BufCount := 0;
//   BlockCount := 0;
//   ofs := 0;

   P := Data;
   if (Data <> nil) and (DataLen > 0) then
   begin
      for ofs := 0 to dataLen - 1 do _AddByte(P[ofs]);
   end;

   _AddByte($80);
   if BufCount < 56 then
   begin
     while BufCount < 56 do _AddByte(0);
   end else begin
     Tmp := 63 - BufCount;
     for ofs := 1 to Tmp do _AddByte(0);
     for ofs := 1 to 55 do _AddByte(0); // fill to length
   end;
   Buffer[14] := DataLen shl 3;
   Buffer[15] := 0;
   _UpdateDigest;


   Result := ToHex(swaplong(A),8)+ToHex(swaplong(B),8)+ToHex(swaplong(C),8)+ToHex(swaplong(D),8);
end;

  (*
  type context = array[0..3] of longint;

  var x: array[0..15] of longint;
      ctxt: context;

  function f(x,y,z: longint): longint; far;
  begin
    f := (x and y) or ((not x) and z)
  end;

  function g(x,y,z: longint): longint; far;
  begin
    g := (x and z) or (y and (not z))
  end;

  function h(x,y,z: longint): longint; far;
  begin
    h := x xor y xor z
  end;

  function i(x,y,z: longint): longint; far;
  begin
    i := y xor (x or (not z))
  end;

  function rol(x: longint; s: byte): longint;
  begin
    {$ifdef bp7bug}
    for s := 1 to s do
      if x >= 0
	then x := x+x
	else x := x+x+1;
    rol := x
    {$else}
    rol := (x shl s) or (x shr (32-s))
    {$endif}
  end;

  procedure transform;
    type fn = function(x,y,z: longint): longint;
    const fntbl: array[0..3] of fn = (f,g,h,i);
	  order: array[0..3] of byte = (0,3,2,1);
	  schedule1: array[0..63] of byte =
     (0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,1,6,11,0,5,10,15,4,9,14,3,8,13,2,7,12,
      5,8,11,14,1,4,7,10,13,0,3,6,9,12,15,2,0,7,14,5,12,3,10,1,8,15,6,13,4,11,2,9);
	  schedule2: array[0..63] of byte =
     (7,12,17,22,7,12,17,22,7,12,17,22,7,12,17,22,5,9,14,20,5,9,14,20,5,9,14,20,5,9,14,20,
      4,11,16,23,4,11,16,23,4,11,16,23,4,11,16,23,6,10,15,21,6,10,15,21,6,10,15,21,6,10,15,21);
	  t: array[0..63] of longint =
     ($d76aa478,$e8c7b756,$242070db,$c1bdceee,$f57c0faf,$4787c62a,$a8304613,
      $fd469501,$698098d8,$8b44f7af,$ffff5bb1,$895cd7be,$6b901122,$fd987193,
      $a679438e,$49b40821,$f61e2562,$c040b340,$265e5a51,$e9b6c7aa,$d62f105d,
      $02441453,$d8a1e681,$e7d3fbc8,$21e1cde6,$c33707d6,$f4d50d87,$455a14ed,
      $a9e3e905,$fcefa3f8,$676f02d9,$8d2a4c8a,$fffa3942,$8771f681,$6d9d6122,
      $fde5380c,$a4beea44,$4bdecfa9,$f6bb4b60,$bebfbc70,$289b7ec6,$eaa127fa,
      $d4ef3085,$04881d05,$d9d4d039,$e6db99e5,$1fa27cf8,$c4ac5665,$f4292244,
      $432aff97,$ab9423a7,$fc93a039,$655b59c3,$8f0ccc92,$ffeff47d,$85845dd1,
      $6fa87e4f,$fe2ce6e0,$a3014314,$4e0811a1,$f7537e82,$bd3af235,$2ad7d2bb,
      $eb86d391);
    var ctct: context;
	i,n: word;
  begin
    ctct := ctxt;
    for i := 0 to 63 do
      begin
	n := order[i and 3];
	ctxt[n] := ctxt[succ(n) and 3]+rol(ctxt[n]+fntbl[i shr 4](ctxt[succ(n) and 3],
	 ctxt[succ(succ(n)) and 3],ctxt[pred(n) and 3])+x[schedule1[i]]+t[i],schedule2[i])
      end;
    for i := 0 to 3 do inc(ctxt[i],ctct[i])
  end;

  procedure md5digest(var message; len: word; var d: digest);
    const ctxtini: digest =
     ($01,$23,$45,$67,$89,$ab,$cd,$ef,$fe,$dc,$ba,$98,$76,$54,$32,$10);
    var xx: array[0..63] of byte absolute x;
	p: pointer;
	i: word;
  begin
    move(ctxtini,ctxt,16);
    p := @message;
    i := len;
    while i >= 64 do
      begin
	move(p^,x,64);
	transform;
	inc(word(p),64);
	dec(i,64)
      end;
    move(p^,x,i);
    xx[i] := $80;
    if i < 56
      then fillchar(xx[i+1],55-i,#0)
      else
	begin
	  fillchar(xx[i+1],63-i,#0);
	  transform;
	  fillchar(x,56,#0)
	end;
    x[14] := longint(len) shl 3;
    x[15] := 0;
    transform;
    move(ctxt,d,16)
  end;

*)

end.
