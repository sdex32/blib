unit BSHA1hash;

interface


//function SHA1Hash(const Str: AnsiString) :string;
function SHA1Hash(Buf :pointer; len:longword) :string;

implementation

uses BStrTools;

{$IFDEF FPC }
{$MODE DELPHI }
{$ASMMODE INTEL }
{$ENDIF}


type
   TSHA256Ctx = record
      state: array[0..7] of LongWord;
      length, curlen: Int64;
      buf: array[0..63] of Byte;
   end;


//function Endian(X: LongWord): LongWord; assembler;
//asm
//   bswap eax
//end;

//function rol(x: LongWord; y: Byte): LongWord; assembler;
//asm
//   mov   cl,dl
//   rol   eax,cl
//end;

function Endian(X: LongWord): LongWord; //fpc
begin
asm
   mov eax, x
   bswap eax
   mov Result ,eax
end;
end;


function rol(x: LongWord; y: Byte): LongWord; //fpc
begin
asm
   mov   eax, x
   mov   cl, y
//   mov   cl,dl
   rol   eax,cl
   mov Result ,eax
end;
end;



function ft1(t: Byte; x, y, z: LongWord): LongWord;
begin
   case t of
      0..19: Result := (x and y) or ((not x) and z);
      20..39: Result := x xor y xor z;
      40..59: Result := (x and y) or (x and z) or (y and z);
   else
      Result := x xor y xor z;
   end;
end;

function Kt1(t: Byte): LongWord;
begin
   case t of
      0..19: Result := $5a827999;
      20..39: Result := $6ed9eba1;
      40..59: Result := $8f1bbcdc;
   else
      Result := $ca62c1d6
   end;
end;

procedure sha1_compress(var md: TSHA256Ctx);
var S: array[0..4] of LongWord;
    W: array[0..79] of LongWord;
    i, t: LongWord;
begin
   Move(md.state, S, SizeOf(S));
   for i := 0 to 15 do
      W[i] := Endian(PLongWord(LongWord(@md.buf) + i * 4)^);
   for i := 16 to 79 do
      W[i] := rol(W[i - 3] xor W[i - 8] xor W[i - 14] xor W[i - 16], 1);
   for i := 0 to 79 do
   begin
      t := rol(S[0], 5) + ft1(i, S[1], S[2], S[3]) + S[4] + Kt1(i) + W[i];
      S[4] := S[3];
      S[3] := S[2];
      S[2] := rol(S[1], 30);
      S[1] := S[0];
      S[0] := t;
   end;
   for i := 0 to 4 do
   md.state[i] := md.state[i] + S[i];
end;


function SHA1Hash(Buf :pointer; len:longword) :string;
//function SHA1Hash(const Str: AnsiString) :string;
var md : TSHA256Ctx;
    i :longword;
//    len :longword;
//    buf :pointer;
begin
   // init
   md.curlen := 0;
   md.length := 0;
   md.state[0] := $67452301;
   md.state[1] := $efcdab89;
   md.state[2] := $98badcfe;
   md.state[3] := $10325476;
   md.state[4] := $c3d2e1f0;

   //Update
//   len := length(Str);
//   buf := @str[1];
   while (len > 0) do
   begin
      md.buf[md.curlen] := PByte(buf)^;
      md.curlen := md.curlen + 1;
      buf := pointer(LongWord(buf) + 1);
      if (md.curlen = 64) then
      begin
         sha1_compress(md);
         md.length := md.length + 512;
         md.curlen := 0;
      end;
      Dec(len);
   end;

   //Finale
   md.length := md.length + md.curlen shl 3;
   md.buf[md.curlen] := $80;
   md.curlen := md.curlen + 1;
   if (md.curlen > 56) then
   begin
      while md.curlen < 64 do
      begin
         md.buf[md.curlen] := 0;
         md.curlen := md.curlen + 1;
      end;
      sha1_compress(md);
      md.curlen := 0;
   end;
   while md.curlen < 56 do
   begin
      md.buf[md.curlen] := 0;
      md.curlen := md.curlen + 1;
   end;
   for i := 56 to 63 do
      md.buf[i] := (md.length shr ((63 - i) * 8)) and $FF;
   sha1_compress(md);
   Result := '';
   for i := 0 to 4 do
      Result := Result + ToHex(md.state[i], 8);

end;


end.
