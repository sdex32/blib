unit BEnigma256;

interface

function  BEnigma_256(const pwd,intxt:ansistring):ansistring;

implementation

function  BEnigma_256(const pwd,intxt:ansistring):ansistring;
var ring_1_in  : array [0..255] of byte;
    ring_1_out : array [0..255] of byte;
    ring_2_in  : array [0..255] of byte;
    ring_2_out : array [0..255] of byte;
    ring_3_in  : array [0..255] of byte;
    ring_3_out : array [0..255] of byte;
    ring_4_link: array [0..255] of byte;
    ring       : array [0..255] of byte;
    indx1,indx2,indx3 :longword;
    mindx,iindx:longword;
    i,j,k,m,w:longword;

   procedure Init_ring(o:longword);
   var ii:longword;
   begin
      for ii := 0 to 255 do ring[ii] := 0; // clear
      w := 0;
      repeat
         j := random(256);
         if ring[j] = 0 then
         begin
            ring[j] := 1;
            case o of
               1: begin
                  ring_1_in[w] := j;
                  ring_1_out[j] := w;
               end;
               2: begin
                  ring_2_in[w] := j;
                  ring_2_out[j] := w;
               end;
               3: begin
                  ring_3_in[w] := j;
                  ring_3_out[j] := w;
               end;
               4: begin
                  k := random(256);
                  while ring[k] <> 0  do k := random(256);
                  ring_4_link[k] := j;
                  ring_4_link[j] := k;
                  ring[k] := 1;
                  inc(w);
               end;
            end;
            inc(w);
         end;
      until (w = 256);
   end;
begin
   Result := '';
   j := Length(intxt);
   k := length(pwd);
   if j = 0 then Exit;
   if k = 0 then Exit;
   SetLength(Result,j);
   // Generate rings on Pwr
   w := 0;
   for i := 1 to k do
   begin
      w := w xor longword(pwd[i]);
      asm
         mov eax, w
         rol eax,2
         mov w, eax
      end;
   end;
   mindx := w;
   iindx := 1;
   randseed := w;
   init_ring(1);
   init_ring(2);
   init_ring(3);
   init_ring(4);
   for i:= 0 to 255 do ring[i] := i;

   j := Length(intxt);
   for i := 1 to j do
   begin
      indx1 :=  mindx and $ff;
      indx2 := (mindx shr 8) and $ff;
      indx3 := (mindx shr 16) and $ff;
      k := longword(intxt[i]);
      k := ring_1_in[(k + indx1) and $ff];
      k := ring_2_in[(k + indx2) and $ff];
      k := ring_3_in[(k + indx3) and $ff];
      k := ring_4_link[k];
      k := (ring_3_out[k] - indx3) and $ff;
      k := (ring_2_out[k] - indx2) and $ff;
      k := (ring_1_out[k] - indx1) and $ff;
      Result[i] := ansichar(k);
      inc(mindx,iindx);
   end;

end;

end.
