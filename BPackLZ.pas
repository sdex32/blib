unit BPackLZ;

interface

function LZcompress(src: PAnsiChar; size: integer; dst: PAnsiChar): integer;
procedure ZipStr(instr:string; var outstr:string);
procedure UnZipStr(instr:string; var outstr:string);

implementation

type
  bufar = array[0..0] of byte; {will be overindexed}
var
  WriteFromBuffer,
  ReadToBuffer: procedure;
  inbuf,outbuf: ^bufar;
  inptr,inend,outptr,outend: word;

//  procedure Encode (bytes: LongInt);
//  procedure Decode;

  // Add by me
//  procedure ZipStr(instr:string; var outstr:string);
//  procedure UnZipStr(instr:string; var outstr:string);


Const
{-LZSS Parameters}
  N         = 4096; {Size of string buffer}
  F         = 60;   {60 Size of look-ahead buffer}
  THRESHOLD = 2;
  NODENIL   = N;    {End of tree's node}

{-Huffman coding parameters}
  N_CHAR    = 256-THRESHOLD+F;
                            {character code (= 0..N_CHAR-1)}
  T         = N_CHAR*2 -1;  {Size of table}
  R         = T-1;          {root position}
  MAX_FREQ  = $8000; {update when cumulative frequency reaches to this value}

{-Tables for encoding/decoding upper 6 bits of sliding dictionary pointer}
{-encoder table}
p_len: array[0..63] of byte =
       ($03,$04,$04,$04,$05,$05,$05,$05,$05,$05,$05,$05,$06,$06,$06,$06,
        $06,$06,$06,$06,$06,$06,$06,$06,$07,$07,$07,$07,$07,$07,$07,$07,
        $07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,
        $08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08);

p_code: array[0..63] of byte =
       ($00,$20,$30,$40,$50,$58,$60,$68,$70,$78,$80,$88,$90,$94,$98,$9C,
        $A0,$A4,$A8,$AC,$B0,$B4,$B8,$BC,$C0,$C2,$C4,$C6,$C8,$CA,$CC,$CE,
        $D0,$D2,$D4,$D6,$D8,$DA,$DC,$DE,$E0,$E2,$E4,$E6,$E8,$EA,$EC,$EE,
        $F0,$F1,$F2,$F3,$F4,$F5,$F6,$F7,$F8,$F9,$FA,$FB,$FC,$FD,$FE,$FF);

{-decoder table}
d_code: array[0..255] of byte =
       ($00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
        $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
        $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,
        $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,
        $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,
        $04,$04,$04,$04,$04,$04,$04,$04,$05,$05,$05,$05,$05,$05,$05,$05,
        $06,$06,$06,$06,$06,$06,$06,$06,$07,$07,$07,$07,$07,$07,$07,$07,
        $08,$08,$08,$08,$08,$08,$08,$08,$09,$09,$09,$09,$09,$09,$09,$09,
        $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,
        $0C,$0C,$0C,$0C,$0D,$0D,$0D,$0D,$0E,$0E,$0E,$0E,$0F,$0F,$0F,$0F,
        $10,$10,$10,$10,$11,$11,$11,$11,$12,$12,$12,$12,$13,$13,$13,$13,
        $14,$14,$14,$14,$15,$15,$15,$15,$16,$16,$16,$16,$17,$17,$17,$17,
        $18,$18,$19,$19,$1A,$1A,$1B,$1B,$1C,$1C,$1D,$1D,$1E,$1E,$1F,$1F,
        $20,$20,$21,$21,$22,$22,$23,$23,$24,$24,$25,$25,$26,$26,$27,$27,
        $28,$28,$29,$29,$2A,$2A,$2B,$2B,$2C,$2C,$2D,$2D,$2E,$2E,$2F,$2F,
        $30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$3A,$3B,$3C,$3D,$3E,$3F);

d_len: array[0..255] of byte =
       ($03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,
        $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,
        $04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,
        $04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,
        $04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,
        $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,
        $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,
        $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,
        $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,
        $06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,
        $06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,
        $06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06,
        $07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,
        $07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,
        $07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,
        $08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08);
var
  getbuf: word = 0;
  getlen: byte = 0;
  putbuf: word = 0;
  putlen: word = 0;

  textsize: LongInt = 0;
  codesize: LongInt = 0;
//  printcount: LongInt = 0;


  text_buf: array[0..N + F - 2] of byte;
  match_position, match_length: word;
  lson,dad: array[0..N] of word;
  rson:     array[0..N + 256] of word;

  freq: array[0..T] of word; {cumulative freq table}

{-pointing parent nodes. area [T..(T + N_CHAR - 1)] are pointers for leaves}
  prnt: array [0..T+N_CHAR-1] of word;

{-pointing children nodes (son[], son[] + 1)}
  son: array[0..T-1] of word;

  function getc: byte;
  begin
    getc:= inbuf^[inptr];
    Inc(inptr);
    if inptr=inend then
    begin //dec(inptr); //ReadToBuffer
       inptr := 0;
       inend := 0;
    end;
  end;

  procedure putc (c: byte);
  begin
    outbuf^[outptr]:= c;
    Inc(outptr);
//    if outptr=outend then WriteFromBuffer
  end;

procedure InitTree;
{-Initializing tree}
var
  i: word;
begin
  for i:= N+1 to N+256 do rson[i] := NODENIL; {root}
  for i:= 0 to N-1 do     dad[i]  := NODENIL; {node}

  textsize:= 0;
  codesize:= 0;
  getbuf:= 0;
  getlen:= 0;
  putbuf:= 0;
  putlen:= 0;

end;

procedure InsertNode (r: word);
{-Inserting node to the tree}
Label
  Done;
var
  i,p: word;
  geq: boolean;
  c: word;
begin
  geq:= true;
  p:= N+1+text_buf[r];
  rson[r]:= NODENIL;
  lson[r]:= NODENIL;
  match_length := 0;
  while TRUE do begin
    if geq then
      if rson[p]=NODENIL then begin
        rson[p]:= r;
        dad[r] := p;
        exit
      end else
        p:= rson[p]
    else
      if lson[p]=NODENIL then begin
        lson[p]:= r;
        dad[r] := p;
        exit
      end else
        p:= lson[p];
    i:= 1;
    while (i<F) AND (text_buf[r+i]=text_buf[p+i]) do Inc(i);
    geq:= (text_buf[r+i]>=text_buf[p+i]) or (i=F);

    if i>THRESHOLD then begin
      if i>match_length then begin
        match_position := (r-p) AND (N-1) -1;
        match_length:= i;
        if match_length>=F then goto done;
      end;
      if i=match_length then begin
        c:= (r-p) AND (N-1) -1;
        if c<match_position then match_position:= c
      end
    end
  end;
  Done:
  dad[r]:= dad[p];
  lson[r]:= lson[p];
  rson[r]:= rson[p];
  dad[lson[p]]:= r;
  dad[rson[p]]:= r;
  if rson[dad[p]]=p then
    rson[dad[p]]:= r
  else
    lson[dad[p]]:= r;
  dad[p]:= NODENIL; {remove p}
end;

procedure DeleteNode (p: word);
{-Delete node from the tree}
var
  q: word;
begin
  if dad[p] =NODENIL then exit; {unregistered}
  if rson[p]=NODENIL then q:= lson[p] else
  if lson[p]=NODENIL then q:= rson[p] else begin
    q:= lson[p];
    if rson[q]<>NODENIL then begin
      repeat
        q:= rson[q];
      until rson[q]=NODENIL;
      rson[dad[q]]:= lson[q];
      dad[lson[q]]:= dad[q];
      lson[q]:= lson[p];
      dad[lson[p]]:= q;
    end;
    rson[q]:= rson[p];
    dad[rson[p]]:= q;
  end;
  dad[q]:= dad[p];
  if rson[dad[p]]=p then
    rson[dad[p]]:= q
  else
    lson[dad[p]]:= q;
  dad[p]:= NODENIL;
end;

function GetBit: byte;
{-get one bit}
begin
  while getlen<=8 do begin
    getbuf := getbuf OR (WORD(getc) SHL (8-getlen));
    Inc(getlen,8);
  end;
  GetBit:= getbuf SHR 15;
  {if (getbuf AND $8000)>0 then GetBit:= 1 else GetBit:= 0;}
  getbuf:= getbuf SHL 1;
  Dec(getlen);
end;

function GetByte: Byte;
{-get a byte}
begin
  while getlen<=8 do begin
    getbuf:= getbuf OR (WORD(getc) SHL (8 - getlen));
    Inc(getlen,8);
  end;
  GetByte:= Hi(getbuf);
  getbuf:= getbuf SHL 8;
  Dec(getlen,8);
end;

procedure Putcode (l: byte; c: word);
{-output l bits}
begin
  putbuf:= putbuf OR (c SHR putlen);
  Inc(putlen,l);
  if putlen>=8 then begin
    putc(Hi(putbuf));
    Dec(putlen,8);
    if putlen>=8 then begin
      putc(Lo(putbuf));
      Inc(codesize,2);
      Dec(putlen,8);
      putbuf:= c SHL (l-putlen);
    end else begin
      putbuf:= Swap(putbuf AND $FF); {SHL 8;}
      Inc(codesize);
    end
  end
end;

procedure StartHuff;
{-initialize freq tree}
var
  i,j: word;
begin
  for i:= 0 to N_CHAR-1 do begin
    freq[i]:= 1;
    son[i] := i+T;
    prnt[i+T]:= i
  end;
  i:= 0; j:= N_CHAR;
  while j<=R do begin
    freq[j]:= freq[i]+freq[i+1];
    son[j] := i;
    prnt[i]:= j;
    prnt[i+1]:= j;
    Inc(i,2); Inc(j)
  end;
  freq[T]:= $FFFF;
  prnt[R]:= 0;
end;

procedure reconst;
{-reconstruct freq tree }
var
  i,j,k,f,l: word;
begin
  {-halven cumulative freq for leaf nodes}
  j:= 0;
  for i:= 0 to T-1 do
    if son[i]>=T then begin
      freq[j]:= (freq[i]+1) SHR 1;
      son[j] := son[i];
      Inc(j)
    end;
  {-make a tree : first, connect children nodes}
  i:= 0; j:= N_CHAR;
  while j<T do begin
    k:= i+1;
    f:= freq[i]+freq[k];
    freq[j]:= f;
    k:= j-1;
    while f<freq[k] do Dec(k);
    Inc(k);
    l:= (j-k)*2;

    move(freq[k],freq[k+1],l);
    freq[k]:= f;
    move(son[k],son[k+1],l);
    son[k]:= i;
    Inc(i,2);
    Inc(j)
  end;
  {-connect parent nodes}
  for i:= 0 to T-1 do begin
    k:= son[i];
    prnt[k]:= i;
    if k<T then
      prnt[k+1]:= i
  end
end;

procedure update(c: word);
{-update freq tree}
var
  i,j,k,l: word;
begin
  if freq[R]=MAX_FREQ then reconst;
  c:= prnt[c+T];
  repeat
    Inc(freq[c]);
    k:= freq[c];
    {-swap nodes to keep the tree freq-ordered}
    l:= c+1;
    if k>freq[l] then begin
      while k>freq[l+1] do Inc(l);
      freq[c]:= freq[l];
      freq[l]:= k;

      i:= son[c];
      prnt[i]:= l;
      if i<T then prnt[i+1]:= l;

      j:= son[l];
      son[l]:= i;

      prnt[j]:= c;
      if j<T  then prnt[j+1]:= c;
      son[c]:= j;

      c := l;
    end;
    c:= prnt[c]
  until c=0; {do it until reaching the root}
end;

procedure EncodeChar (c: word);
var
  code,len,k: word;
begin
  code:= 0;
  len:= 0;
  k:= prnt[c+T];

  {-search connections from leaf node to the root}
  repeat
    code:= code SHR 1;
    {-if node's address is odd, output 1 else output 0}
    if (k AND 1)>0 then Inc(code,$8000);
    Inc(len);
    k:= prnt[k];
  until k=R;
  Putcode(len,code);
  update(c)
end;

procedure EncodePosition(c: word);
var
  i: word;
begin
  {-output upper 6 bits with encoding}
  i:= c SHR 6;
  Putcode(p_len[i], WORD(p_code[i]) SHL 8);
  {-output lower 6 bits directly}
  Putcode(6, (c AND $3F) SHL 10);
end;

procedure EncodeEnd;
begin
  if putlen>0 then begin
    putc(Hi(putbuf));
    Inc(codesize)
  end
end;

function DecodeChar: word;
var
  c: word;
begin
  c:= son[R];
  {-start searching tree from the root to leaves.
    choose node #(son[]) if input bit = 0
    else choose #(son[]+1) (input bit = 1)}
  while c<T do c:= son[c+GetBit];
  Dec(c,T);
  update(c);
  DecodeChar:= c
end;

function DecodePosition: word;
var
  i,j,c: word;
begin
  {-decode upper 6 bits from given table}
  i:= GetByte;
  c:= WORD(d_code[i]) SHL 6;
  j:= d_len[i];
  {-input lower 6 bits directly}
  Dec(j,2);
  while j>0 do begin
    Dec(j);
    i:= (i SHL 1) OR GetBit;
  end;
  DecodePosition:= c OR (i AND $3F);
end;

{-Compression }
procedure Encode (bytes: LongInt);
{-Encoding/Compressing}
type
  ByteRec = record
              b0,b1,b2,b3: byte
            end;
var
  i,c,len,r,s,last_match_length: word;
begin
  {-write size of original text}
  with ByteRec(Bytes) do begin
    putc(b0);
    putc(b1);
    putc(b2);
    putc(b3)
  end;
  if bytes=0 then exit;
  textsize:= 0;
  StartHuff;
  InitTree;
  s:= 0;
  r:= N-F;
  fillchar(text_buf[0],r,' ');
  len:= 0;
  while (len<F) AND (inptr OR inend>0) do begin
    text_buf[r+len]:= getc;
    Inc(len)
  end;
  textsize := len;
  for i:= 1 to F do InsertNode(r - i);
  InsertNode(r);
  repeat
    if match_length>len then match_length:= len;
    if match_length<=THRESHOLD then begin
      match_length := 1;
      EncodeChar(text_buf[r])
    end else begin
      EncodeChar(255 - THRESHOLD + match_length);
      EncodePosition(match_position)
    end;
    last_match_length := match_length;
    i:= 0;
    while (i<last_match_length) AND (inptr OR inend>0) do begin
      Inc(i);
      DeleteNode(s);
      c:= getc;
      text_buf[s]:= c;
      if s<F-1 then text_buf[s+N]:= c;
      s:= (s+1) AND (N-1);
      r:= (r+1) AND (N-1);
      InsertNode(r);
    end;
    Inc(textsize,i);
//    if textsize>printcount then begin
//      write(textsize,#13);
//      Inc(printcount,1024)
//    end;
    while i<last_match_length do begin
      Inc(i);
      DeleteNode(s);
      s := (s+1) AND (N-1);
      r := (r+1) AND (N-1);
      Dec(len);
      if len>0 then InsertNode(r)
    end;
  until len=0;
  EncodeEnd;
//  writeln('input:  ',textsize,' bytes');
//  writeln('output: ',codesize,' bytes');
//  writeln('compression: ',textsize*100 DIV codesize,'%');
end;

procedure Decode;
{-Decoding/Uncompressing}
type
  ByteRec = Record
              b0,b1,b2,b3: byte
            end;
var
  i,j,k,r,c: word;
  count: LongInt;
begin
  {-read size of original text}
  with ByteRec(textsize) do begin
    b0:= getc;
    b1:= getc;
    b2:= getc;
    b3:= getc
  end;
  if textsize=0 then exit;
  StartHuff;
  fillchar(text_buf[0],N-F,' ');
  r:= N-F;
  count:= 0;
  while count<textsize do begin
    c:= DecodeChar;
    if c<256 then begin
      putc(c);
      text_buf[r]:= c;
      r:= (r+1) AND (N-1);
      Inc(count)
    end else begin
      i:= (r-DecodePosition-1) AND (N-1);
      j:= c-255+THRESHOLD;
      for k:= 0 to j-1 do begin
        c:= text_buf[(i+k) AND (N-1)];
        putc(c);
        text_buf[r]:= c;
        r:= (r+1) AND (N-1);
        Inc(count)
      end;
    end;
//    if count>printcount then begin
//      write(count,#13);
//      Inc(printcount,1024)
//    end
  end;
//  writeln(count);
end;

procedure ZipStr(instr:ansistring; var outstr:ansistring);
var s:string;
begin
   inbuf:=@inStr[1];
   SetLength(S,length(inStr)*2); // Must be little
   outbuf:=@s[1];
   inptr:= 0;
   inend:= length(inStr) ;
   outptr:= 0;
   outend:= 0;
   Encode (inend);
   SetLength(OutStr,OutPtr);
   OutStr := Copy(s,0,OutPtr);
end;

procedure UnZipStr(instr:ansistring; var outstr:ansistring);
type
  ByteRec = Record
              b0,b1,b2,b3: byte
            end;
var s:string;
    l:longword;
begin
   inbuf:=@inStr[1];
   inptr:= 0;
   with ByteRec(l) do begin
      b0:= getc;
      b1:= getc;
      b2:= getc;
      b3:= getc
   end;
   SetLength(S,l);
   outbuf:=@s[1];
   inptr:= 0;
   inend:= length(inStr) ;
   outptr:= 0;
   outend:= 0;
   Decode;
   SetLength(OutStr,OutPtr);
   OutStr := Copy(s,0,OutPtr);
end;







function LZcompress(src: PAnsiChar; size: integer; dst: PAnsiChar): integer;
var dst_beg, // initial dst value
    src_end,          // real last byte available in src
    src_endmatch,     // last byte to try for hashing
    o: pAnsiChar;
    CWbit: byte;
    CWpoint: PInteger;
    h, v, cached: integer;
    t, tmax: integer;
    offset: array[0..4095] of PAnsiChar; // 16KB+16KB=32KB hashing code
    cache: array[0..4095] of integer;
begin
  dst_beg := dst;
  src_end := src+size;
  src_endmatch := src_end-(6+5);
  CWbit := 0;
  CWpoint := pointer(dst);
  pInteger(dst)^ := 0;
 // inc(dst,sizeof(CWpoint^));
  fillchar(offset,sizeof(offset),0); // fast 16KB reset to 0
  // 1. main loop to search using hash[]
  if src<=src_endmatch then
  repeat
    v := pInteger(src)^;
    h := ((v shr 12) xor v) and 4095;
    o := offset[h];
    offset[h] := src;
    cached := v xor cache[h];
    cache[h] := v;
    if (cached and $00ffffff=0) and (o<>nil) and (src-o>2) then begin
      CWpoint^ := CWpoint^ or (1 shl CWbit);
      inc(src,2);
      inc(o,2);
      t := 1;
      tmax := src_end-src-1;
      if tmax>=(255+16) then
        tmax := (255+16);
      while (o[t]=src[t]) and (t<tmax) do
        inc(t);
      inc(src,t);
      h := h shl 4;
      // here we have always t>0
      if t<=15 then begin // mark 2 to 17 bytes -> size=1..15
        pWord(dst)^ := integer(t or h);
        inc(dst,2);
      end else begin // mark 18 to (255+16) bytes -> size=0, next byte=t
        dec(t,16);
        pWord(dst)^ := h; // size=0
        dst[2] := ansichar(t);
        inc(dst,3);
      end;
    end else begin
      dst^ := src^;
      inc(src);
      inc(dst);
    end;
    if CWbit<31 then begin
      inc(CWbit);
      if src<=src_endmatch then continue else break;
    end else begin
      CWpoint := pointer(dst);
      pInteger(dst)^ := 0;
      inc(dst,sizeof(CWpoint^));
      CWbit := 0;
      if src<=src_endmatch then continue else break;
    end;
  until false;
  // 2. store remaining bytes
  if src<src_end then
  repeat
    dst^ := src^;
    inc(src);
    inc(dst);
    if CWbit<31 then begin
      inc(CWbit);
      if src<src_end then continue else break;
    end else begin
      pInteger(dst)^ := 0;
      inc(dst,4);
      CWbit := 0;
      if src<src_end then continue else break;
    end;
  until false;
  result := dst-dst_beg;
end;

function SynLZdecompress1pas(src: PAnsiChar; size: integer; dst: PAnsiChar): Integer;
var last_hashed: PAnsiChar; // initial src and dst value
    src_end: PAnsiChar;
    CWbit: integer;
    CW, v, t, h: integer;
    offset: array[0..4095] of PAnsiChar; // 16KB hashing code
label nextCW;
begin
  src_end := src+size;
  // 1. retrieve out_len
  result := pWord(src)^;
  if result=0 then exit;
  inc(src,2);
  if result and $8000<>0 then begin
    result := (result and $7fff) or (integer(pWord(src)^) shl 15);
    inc(src,2);
  end;
  // 2. decompress
  last_hashed := dst-1;
nextCW:
  CW := pInteger(src)^;
  inc(src,4);
  CWbit := 1;
  if src<src_end then
  repeat
    if CW and CWbit=0 then begin
      dst^ := src^;
      inc(src);
      inc(dst);
      if src>=src_end then break;
      if last_hashed<dst-3 then begin
        inc(last_hashed);
        v := pInteger(last_hashed)^;
        offset[((v shr 12) xor v) and 4095] := last_hashed;
      end;
      CWbit := CWbit shl 1;
      if CWbit<>0 then
        continue else
        goto nextCW;
    end else begin
      h := pWord(src)^;
      inc(src,2);
      t := (h and 15)+2;
      h := h shr 4;
      if t=2 then begin
        t := ord(src^)+(16+2);
        inc(src);
      end;
//bogi      if dst-offset[h]<t then // avoid overlaping move() bug
//bogi        movechars(offset[h],dst,t) else
        move(offset[h]^,dst^,t);
      if src>=src_end then break;
      while last_hashed<dst do begin
        inc(last_hashed);
        v := pInteger(last_hashed)^;
        offset[((v shr 12) xor v) and 4095] := last_hashed;
      end;
      inc(dst,t);
      last_hashed := dst-1;
      CWbit := CWbit shl 1;
      if CWbit<>0 then
        continue else
        goto nextCW;
    end;
  until false;
end;









end.


