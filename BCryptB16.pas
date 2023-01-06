unit BCryptB16;

interface

// WARNING the data must be word align
procedure BCryptB16_DecodeBlock(password:longword; data:pointer; len:longword);
procedure BCryptB16_CodeBlock(password:longword; data:pointer; len:longword);


implementation



procedure BCryptB16_CodeBlock(password:longword; data:pointer; len:longword);
var oe,j,w,gh:longword; //odd even

   function B16_C_Operator(v,ghost:longword):longword;
   var a,b,c:longword;
   begin
      oe := oe xor 1;
      a := ((v shr 11) and $1F) xor longword(random($1F));
      b := ((v shr 5) and $3F) xor longword(random($3F));
      c := (v and $1f) xor longword(random($1F));
      if (oe and 1) <> 0 then
      begin
         // B A C
         Result := (b shl 10) or (a shl 5) or c;
      end else begin
         // A C B
         Result := (a shl 11) or (c shl 6) or b;
      end;
      Result := (Result xor ((longword(random($FF)) shl 8) or longword(random($FF)))) xor ghost;
   end;
begin
   if len mod 2 <> 0 then Exit;

   randseed:= password;
   oe:= 0;
   gh := longword(random($FFFF));
   j := len;
   repeat
      w := word(data^);
      dec(j,2);
      gh := B16_C_Operator(w,gh);
      word(data^) := word(gh);
      data := pointer(longword(data)+2);
   until (j = 0);
end;

procedure BCryptB16_DecodeBlock(password:longword; data:pointer; len:longword);
var oe,j,w,gh:longword; //odd even

   function B16_D_Operator(v,ghost:longword):longword;
   var a,b,c:longword;
   begin
      a := longword(random($1F));
      b := longword(random($3F));
      c := longword(random($1F));
      v := (v xor ghost) xor ((longword(random($FF)) shl 8) or longword(random($FF)));
      oe := oe xor 1;
      if (oe and 1) <> 0 then
      begin
         // B A C
         a := ((v shr 5) and $1F) xor a;
         b := ((v shr 10) and $3F) xor b;
         c := (v and $1F) xor c;
      end else begin
         // A C B
         a := ((v shr 11) and $1F) xor a;
         b := (v and $3F) xor b;
         c := ((v shr 6) and $1F) xor c;
      end;
      Result := (a shl 11) or (b shl 5) or c;
   end;
begin
   if len mod 2 <> 0 then Exit;

   randseed:= password;
   oe:=0;
   gh := longword(random($FFFF));
   j := len;
   repeat
      w := word(data^);
      dec(j,2);
      gh := B16_D_Operator(w,gh);
      word(data^) := word(gh);
      gh := w;
      data := pointer(longword(data)+2);
   until (j = 0);
end;

end.
