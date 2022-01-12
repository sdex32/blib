unit BMemFillTools;

interface

procedure BMemSet_1(Dst, Xpos, Size, Color :longword); assembler; stdcall;
procedure BMemSet_4(Dst, Xpos, Size, Color :longword); assembler; stdcall;
procedure BMemSet_8(Dst, Xpos, Size, Color :longword); assembler; stdcall;
procedure BMemSet_1516(Dst, Xpos, Size, Color :longword); assembler; stdcall;
procedure BMemSet_24(Dst, Xpos, Size, Color :longword); assembler; stdcall;
procedure BMemSet_32(Dst, Xpos, Size, Color: longword); assembler; stdcall;


procedure BMemSetOr_4(Dst, Xpos, Size, Color :longword); assembler; stdcall;
procedure BMemSetOr_8(Dst, Xpos, Size, Color :longword); assembler; stdcall;
procedure BMemSetOr_1516(Dst, Xpos, Size, Color :longword); assembler; stdcall;
procedure BMemSetOr_24(Dst, Xpos, Size, Color :longword); assembler; stdcall;
procedure BMemSetOr_32(Dst, Xpos, Size, Color :longword); assembler; stdcall;


procedure BMemSetAnd_4(Dst, Xpos, Size, Color :longword); assembler; stdcall;
procedure BMemSetAnd_8(Dst, Xpos, Size, Color :longword); assembler; stdcall;
procedure BMemSetAnd_1516(Dst, Xpos, Size, Color :longword); assembler; stdcall;
procedure BMemSetAnd_24(Dst, Xpos, Size, Color :longword); assembler; stdcall;
procedure BMemSetAnd_32(Dst, Xpos, Size, Color :longword); assembler; stdcall;


procedure BMemSetXor_4(Dst, Xpos, Size, Color :longword); assembler; stdcall;
procedure BMemSetXor_8(Dst, Xpos, Size, Color :longword); assembler; stdcall;
procedure BMemSetXor_1516(Dst, Xpos, Size, Color :longword); assembler; stdcall;
procedure BMemSetXor_24(Dst, Xpos, Size, Color :longword); assembler; stdcall;
procedure BMemSetXor_32(Dst, Xpos, Size, Color :longword); assembler; stdcall;



implementation

//No test for overlap surface to surface  no in same surface
// size is in elements
//------------------------------------------------------------------------------

{                          1     4     8    15    16    24    32   RAW
memSet                    OK    OK    OK    OK    OK    OK    OK
memSetOr                        OK    OK    OK    OK    OK    OK
memSetAnd                       OK    OK    OK    OK    OK    OK
memSetXor                       OK    OK    OK    OK    OK    OK
memSetAdd
memSetSub
memSetMul
memCopy
memStretch
memCopyKey
memStretchKey

memCopyAlpha
memStretchAlpha
memCopyKeyAlpha
memStretchKeyAlpha

memCopyOr
memStretchOr
memCopyKeyOr
memStretchKeyOr
memCopyAnd
memStretchAnd
memCopyKeyAnd
memStretchKeyAnd
memCopyXor
memStretchXor
memCopyKeyXor
memStretchKeyXor
memCopyAdd
memStretchAdd
memCopyKeyAdd
memStretchKeyAdd
memCopySub
memStretchSub
memCopyKeySub
memStretchKeySub
memCopyMul
memStretchMul
memCopyKeyMul
memStretchKeyMul

  Stencil !!!!
   Texture
   Pattern 1001110101  for fonts

memGradient
memGradientAlpha





}



//------------------------------------------------------------------------------
Const
   MaskMono : array[0..7] of byte = ($80,$40,$20,$10,$8,$4,$2,$1);

procedure BMemSet_1(Dst, Xpos, Size, Color :longword); assembler; stdcall;
asm
   push  esi
   push  edi
   push  ebx
   cld

   mov   edx, Color
   and   edx, 1

   mov   ecx, Size
   mov   ebx, Xpos
   mov   edi, ebx
   shr   edi, 3
   add   edi, Dst
   xor   eax, eax

(* //slow but small
   and   ebx, 7
   mov   al, byte ptr ds:[MaskMono + ebx]
   mov   ah, al
   not   ah
   mov   dh, al
   test  dl, 1
   jnz   @@Run
   xor   dh, dh
@@Run:
   mov   dl, byte ptr ds:[edi]  // read byte
@@loop:
   and   dl, ah
   or    dl, dh
   ror   dh, 1
   ror   ah, 1
   ror   al, 1
   jnc   @@SameByte
   mov   byte ptr ds:[edi], dl
   inc   edi
   mov   dl, byte ptr ds:[edi]  // read byte
@@SameByte:
   loop  @@loop
   mov   byte ptr ds:[edi], dl
   //end
*)


   and   ebx, 7
   mov   al, byte ptr ds:[MaskMono + ebx]
@BeginFiller:
   or    ah, al
   dec   ecx
   jz    @Done
   shr   al, 1
   jc    @Done
   jmp   @BeginFiller;
@Done:
   mov   al, ah
   not   ah
   mov   bl, ds:[edi]
   and   bl, ah
   or    edx, edx
   jz    @@BlackColor
   or    bl, al
@@BlackColor:
   mov   ds:[edi], bl
   inc   edi
// Midle
   cmp   ecx, 8
   jb    @@ToEndPart
   mov   ebx, ecx
   shr   ecx, 3
   mov   eax, ecx
   shl   eax, 3
   sub   ebx, eax
   xor   eax, eax
   or    edx, edx
   jz    @@BlackColor2
   mov   eax, $FF;
@@BlackColor2:
   rep   stosb
   mov   ecx, ebx
@@ToEndPart:
// EndPart
   or    ecx, ecx
   jz    @@NoMore
   xor   eax, eax
   mov   al, $80
@EndFiller:
   or    ah, al
   shr   al, 1
   loop  @EndFiller
   mov   al, ah
   not   ah
   mov   bl, ds:[edi]
   and   bl, ah
   or    edx, edx
   jz    @@BlackColor3
   or    bl, al
@@BlackColor3:
   mov ds:[edi], bl

@@NoMore:
   pop   ebx
   pop   edi
   pop   esi
end;

//------------------------------------------------------------------------------
procedure BMemSet_4(Dst, Xpos, Size, Color :longword); assembler; stdcall;
asm
   push  esi
   push  edi
   push  ebx
   cld
   mov   edi, Dst
   mov   ecx, Size
   mov   eax, Color
   and   eax, $F
   mov   ah, al
   shl   al, 4
   or    al, ah

   mov   ebx, Xpos
   shr   ebx, 1
   jnc   @@NoBeginPixel
   mov   dl, ds:[edi+ebx]
   and   dl, $F0;
   or    dl, ah
   mov   ds:[edi+ebx], dl
   dec   ecx
   inc   ebx
@@NoBeginPixel:
   add   edi, ebx
   mov   ebx, ecx
   shr   ecx, 1
   or    ecx, ecx
   jz    @NoMiddle
   rep   stosb
@NoMiddle:
   test  ebx, 1
   jz    @NoEndPart
   mov   dl, ds:[edi]
   and   dl, $0F
   and   al, $F0;
   or    dl, al
   mov   ds:[edi], dl
@NoEndPart:
   pop   ebx
   pop   edi
   pop   esi
end;


//------------------------------------------------------------------------------
procedure BMemSet_8(Dst, Xpos, Size, Color :longword); assembler; stdcall;
asm
   push  esi
   push  edi
   push  ebx
   cld
   mov   edi, Dst
   add   edi, Xpos
   mov   ecx, Size
   mov   eax, Color
   mov   ah, al
   mov   ebx, eax
   shl   eax, 16
   mov   ax, bx
   mov   edx, ecx
   shr   ecx, 2
   and   edx, 3
   rep   stosd
   mov   ecx, edx
   rep   stosb
   pop   ebx
   pop   edi
   pop   esi

{
   the fast
   movzx eax, al
   mov edx, ecx
   imul eax,eax,$01010101
   shr ecx,$02
   and edx,$03   
   rep stosd
   mov ecx,edx
   rep stob
}

end;


//------------------------------------------------------------------------------
procedure BMemSet_1516(Dst, Xpos, Size, Color :longword); assembler; stdcall;
asm
   push  esi
   push  edi
   push  ebx
   cld
   mov   edi, Dst
   mov   eax, Xpos
   shl   eax, 1  //*2 bytes
   add   edi, eax
   mov   ecx, Size
   mov   eax, Color
   mov   ebx, eax
   shl   eax, 16
   mov   ax, bx
   mov   edx, ecx
   shr   ecx, 1
   and   edx, 1
   rep   stosd
   mov   ecx, edx
   rep   stosw
   pop   ebx
   pop   edi
   pop   esi
end;

//------------------------------------------------------------------------------
procedure BMemSet_24(Dst, Xpos, Size, Color :longword); assembler; stdcall;
asm
   push  esi
   push  edi
   push  ebx
   mov   edi, Dst
   mov   eax, Xpos
   lea   eax, [eax*2+eax] //*3
   add   edi, eax
   mov   ecx, Size
   jz    @Out
   mov   eax, Color
   mov   ebx, eax
   shr   ebx, 16
@Loop:
   mov   ds:[edi], ax
   mov   ds:[edi+ 2], bl
   add   edi, 3
   loop  @Loop
@Out:
   pop   ebx
   pop   edi
   pop   esi
end;


//------------------------------------------------------------------------------
procedure BMemSet_32(Dst, Xpos, Size, Color: longword); assembler; stdcall;
asm
   push  edi
   cld
   mov   edi, Dst
   mov   eax, Xpos
   shl   eax, 2  //*4 bytes
   add   edi, eax
   mov   ecx, Size
   mov   eax, Color
   rep   stosd
   pop   edi
end;







//------------------------------------------------------------------------------
procedure BMemSetOr_4(Dst, Xpos, Size, Color :longword); assembler; stdcall;
asm
   push  esi
   push  edi
   push  ebx
   cld
   mov   edi, Dst
   mov   ecx, Size
   mov   eax, Color
   and   eax, $F
   mov   ah, al  // al = 0F
   shl   ah, 4   // ah = F0

   mov   ebx, Xpos
   shr   ebx, 1
   jnc   @@NoBeginPixel
   mov   dl, ds:[edi+ebx]
   or    dl, al
   mov   ds:[edi+ebx], dl
   dec   ecx
   inc   ebx
@@NoBeginPixel:
   add   edi, ebx
   mov   ebx, ecx
   shr   ecx, 1
   or    ecx, ecx
   jz    @NoMiddle
@@dobybyte:
   mov   dl, ds:[edi]
   or    dl, al
   or    dl, ah
   mov   ds:[edi], dl
   inc   edi
   loop  @@dobybyte
@NoMiddle:
   test  ebx, 1
   jz    @NoEndPart
   mov   dl, ds:[edi]
   or    dl, ah
   mov   ds:[edi], dl
@NoEndPart:
   pop   ebx
   pop   edi
   pop   esi
end;


//------------------------------------------------------------------------------
procedure BMemSetOr_8(Dst, Xpos, Size, Color :longword); assembler; stdcall;
asm
   push  esi
   push  edi
   push  ebx
   mov   edi, Dst
   add   edi, Xpos
   mov   ecx, Size
   mov   ebx, Color
@@NextPix:
   or    ds:[edi], bl
   inc   edi
   loop  @@NextPix
   pop   ebx
   pop   edi
   pop   esi
end;


//------------------------------------------------------------------------------
procedure BMemSetOr_1516(Dst, Xpos, Size, Color :longword); assembler; stdcall;
asm
   push  esi
   push  edi
   push  ebx
   mov   edi, Dst
   mov   eax, Xpos
   shl   eax, 1  //*2 bytes
   add   edi, eax
   mov   ecx, Size
   mov   ebx, Color
@@NextPix:
   or    ds:[edi], bx
   add   edi, 2
   loop  @@NextPix
   pop   ebx
   pop   edi
   pop   esi
end;


//------------------------------------------------------------------------------
procedure BMemSetOr_24(Dst, Xpos, Size, Color :longword); assembler; stdcall;
asm
   push  esi
   push  edi
   push  ebx
   mov   edi, Dst
   mov   eax, Xpos
   lea   eax, [eax*2+eax] //*3
   add   edi, eax
   mov   ecx, Size
   mov   ebx, Color
   mov   eax, ebx
   shr   eax, 16
@@NextPix:
   or    ds:[edi], bx
   or    ds:[edi+ 2], al
   add   edi, 3
   loop  @@NextPix
   pop   ebx
   pop   edi
   pop   esi
end;


//------------------------------------------------------------------------------
procedure BMemSetOr_32(Dst, Xpos, Size, Color :longword); assembler; stdcall;
asm
   push  esi
   push  edi
   push  ebx
   mov   edi, Dst
   mov   eax, Xpos
   shl   eax, 2  //*4 bytes
   add   edi, eax
   mov   ecx, Size
   mov   ebx, Color
@@NextPix:
   or    ds:[edi], ebx
   add   edi, 4
   loop  @@NextPix
   pop   ebx
   pop   edi
   pop   esi
end;






//------------------------------------------------------------------------------
procedure BMemSetAnd_4(Dst, Xpos, Size, Color :longword); assembler; stdcall;
asm
   push  esi
   push  edi
   push  ebx
   cld
   mov   edi, Dst
   mov   ecx, Size
   mov   eax, Color
   and   eax, $F
   mov   ah, al  // al = 0F
   shl   ah, 4   // ah = F0
   or    al, $F0  // fill rest
   or    ah, $0F

   mov   ebx, Xpos
   shr   ebx, 1
   jnc   @@NoBeginPixel
   mov   dl, ds:[edi+ebx]
   and   dl, al
   mov   ds:[edi+ebx], dl
   dec   ecx
   inc   ebx
@@NoBeginPixel:
   add   edi, ebx
   mov   ebx, ecx
   shr   ecx, 1
   or    ecx, ecx
   jz    @NoMiddle
@@dobybyte:
   mov   dl, ds:[edi]
   and   dl, al
   and   dl, ah
   mov   ds:[edi], dl
   inc   edi
   loop  @@dobybyte
@NoMiddle:
   test  ebx, 1
   jz    @NoEndPart
   mov   dl, ds:[edi]
   and   dl, ah
   mov   ds:[edi], dl
@NoEndPart:
   pop   ebx
   pop   edi
   pop   esi
end;


//------------------------------------------------------------------------------
procedure BMemSetAnd_8(Dst, Xpos, Size, Color :longword); assembler; stdcall;
asm
   push  esi
   push  edi
   push  ebx
   mov   edi, Dst
   add   edi, Xpos
   mov   ecx, Size
   mov   ebx, Color
@@NextPix:
   and   ds:[edi], bl
   inc   edi
   loop  @@NextPix
   pop   ebx
   pop   edi
   pop   esi
end;


//------------------------------------------------------------------------------
procedure BMemSetAnd_1516(Dst, Xpos, Size, Color :longword); assembler; stdcall;
asm
   push  esi
   push  edi
   push  ebx
   mov   edi, Dst
   mov   eax, Xpos
   shl   eax, 1  //*2 bytes
   add   edi, eax
   mov   ecx, Size
   mov   ebx, Color
@@NextPix:
   and   ds:[edi], bx
   add   edi, 2
   loop  @@NextPix
   pop   ebx
   pop   edi
   pop   esi
end;


//------------------------------------------------------------------------------
procedure BMemSetAnd_24(Dst, Xpos, Size, Color :longword); assembler; stdcall;
asm
   push  esi
   push  edi
   push  ebx
   mov   edi, Dst
   mov   eax, Xpos
   lea   eax, [eax*2+eax] //*3
   add   edi, eax
   mov   ecx, Size
   mov   ebx, Color
   mov   eax, ebx
   shr   eax, 16
@@NextPix:
   and   ds:[edi], bx
   and   ds:[edi+ 2], al
   add   edi, 3
   loop  @@NextPix
   pop   ebx
   pop   edi
   pop   esi
end;


//------------------------------------------------------------------------------
procedure BMemSetAnd_32(Dst, Xpos, Size, Color :longword); assembler; stdcall;
asm
   push  esi
   push  edi
   push  ebx
   mov   edi, Dst
   mov   eax, Xpos
   shl   eax, 2  //*4 bytes
   add   edi, eax
   mov   ecx, Size
   mov   ebx, Color
@@NextPix:
   and    ds:[edi], ebx
   add   edi, 4
   loop  @@NextPix
   pop   ebx
   pop   edi
   pop   esi
end;




//------------------------------------------------------------------------------
procedure BMemSetXor_4(Dst, Xpos, Size, Color :longword); assembler; stdcall;
asm
   push  esi
   push  edi
   push  ebx
   cld
   mov   edi, Dst
   mov   ecx, Size
   mov   eax, Color
   and   eax, $F
   mov   ah, al  // al = 0F
   shl   ah, 4   // ah = F0

   mov   ebx, Xpos
   shr   ebx, 1
   jnc   @@NoBeginPixel
   mov   dl, ds:[edi+ebx]
   xor   dl, al
   mov   ds:[edi+ebx], dl
   dec   ecx
   inc   ebx
@@NoBeginPixel:
   add   edi, ebx
   mov   ebx, ecx
   shr   ecx, 1
   or    ecx, ecx
   jz    @NoMiddle
@@dobybyte:
   mov   dl, ds:[edi]
   xor   dl, al
   xor   dl, ah
   mov   ds:[edi], dl
   inc   edi
   loop  @@dobybyte
@NoMiddle:
   test  ebx, 1
   jz    @NoEndPart
   mov   dl, ds:[edi]
   xor   dl, ah
   mov   ds:[edi], dl
@NoEndPart:
   pop   ebx
   pop   edi
   pop   esi
end;



//------------------------------------------------------------------------------
procedure BMemSetXor_8(Dst, Xpos, Size, Color :longword); assembler; stdcall;
asm
   push  esi
   push  edi
   push  ebx
   mov   edi, Dst
   add   edi, Xpos
   mov   ecx, Size
   mov   ebx, Color
@@NextPix:
   xor   ds:[edi], bl
   inc   edi
   loop  @@NextPix
   pop   ebx
   pop   edi
   pop   esi
end;


//------------------------------------------------------------------------------
procedure BMemSetXor_1516(Dst, Xpos, Size, Color :longword); assembler; stdcall;
asm
   push  esi
   push  edi
   push  ebx
   mov   edi, Dst
   mov   eax, Xpos
   shl   eax, 1  //*2 bytes
   add   edi, eax
   mov   ecx, Size
   mov   ebx, Color
@@NextPix:
   xor   ds:[edi], bx
   add   edi, 2
   loop  @@NextPix
   pop   ebx
   pop   edi
   pop   esi
end;


//------------------------------------------------------------------------------
procedure BMemSetXor_24(Dst, Xpos, Size, Color :longword); assembler; stdcall;
asm
   push  esi
   push  edi
   push  ebx
   mov   edi, Dst
   mov   eax, Xpos
   lea   eax, [eax*2+eax] //*3
   add   edi, eax
   mov   ecx, Size
   mov   ebx, Color
   mov   eax, ebx
   shr   eax, 16
@@NextPix:
   xor   ds:[edi], bx
   xor   ds:[edi+ 2], al
   add   edi, 3
   loop  @@NextPix
   pop   ebx
   pop   edi
   pop   esi
end;


//------------------------------------------------------------------------------
procedure BMemSetXor_32(Dst, Xpos, Size, Color :longword); assembler; stdcall;
asm
   push  esi
   push  edi
   push  ebx
   mov   edi, Dst
   mov   eax, Xpos
   shl   eax, 2  //*4 bytes
   add   edi, eax
   mov   ecx, Size
   mov   ebx, Color
@@NextPix:
   xor   ds:[edi], ebx
   add   edi, 4
   loop  @@NextPix
   pop   ebx
   pop   edi
   pop   esi
end;




 (*

procedure BMemCopy_8(Src, Dst, Size : longword); assembler;  stdcall;
asm
  push   esi
  push   edi
  push   es
  mov    ax, ds
  mov    es, ax
  cld
  mov    esi, Src
  mov    edi, Dst
  mov    ecx, Size
  mov    eax, ecx
  shr    ecx, 2
  and    eax, 3
  rep    movsd
  mov    ecx, eax
  rep    movsb
  mov    es, dx
  pop    es
  pop    edi
  pop    esi
end;



//------------------------------------------------------------------------------
procedure BMemCopy_16(Src, Dst, Size : longword); assembler;  stdcall;
asm
  push   esi
  push   edi
  push   es
  mov    ax, ds
  mov    es, ax
  cld
  mov    esi, Src
  mov    edi, Dst
  mov    ecx, Size
  mov    eax, ecx
  shr    ecx, 1
  and    eax, 1
  rep    movsd
  mov    ecx, eax
  rep    movsw
  pop    es
  pop    edi
  pop    esi
end;

//------------------------------------------------------------------------------
procedure BMemCopy_24(Src, Dst, Size : longword); assembler;  stdcall;
asm
  push   esi
  push   edi
  push   es
  mov    ax, ds
  mov    es, ax
  cld
  mov    esi, Src
  mov    edi, Dst
  mov    ecx, Size
  lea    ecx, [ecx*2+ecx]
  mov    eax, ecx
  shr    ecx, 2
  and    eax, 3
  rep    movsd
  mov    ecx, eax
  rep    movsb
  pop    es
  pop    edi
  pop    esi
end;

//------------------------------------------------------------------------------
procedure BMemCopy_32(Src, Dst, Size : longword); assembler;  stdcall;
asm
  push   esi
  push   edi
  push   es
  mov    ax, ds
  mov    es, ax
  cld
  mov    esi, Src
  mov    edi, Dst
  mov    ecx, Size
  rep    movsd
  pop    es
  pop    edi
  pop    esi
end;



procedure BMemSetOr1(Dst, Xpos, Size, Color :longword); assembler; stdcall;
asm
  push  esi
  push  edi
  push  ebx
  cld

  mov   edx, Color
  and   edx, 1

  mov   ecx, Size
  mov   ebx, Xpos
  mov   edi, ebx
  shr   edi, 3
  add   edi, Dst
  xor   eax, eax
  and   ebx, 7
  mov   al, byte ptr ds:[MaskMono + ebx]
@BeginFiller:
  or    ah, al
  dec   ecx
  jz    @Done
  shr   al, 1
  jc    @Done
  jmp   @BeginFiller;
@Done:
  mov   bl, ds:[edi]
  or    edx, edx
  jz    @@BlackColor
  or    bl, al
@@BlackColor:
  mov   ds:[edi], bl
  inc   edi
// Midle
  cmp   ecx, 8
  jb    @@ToEndPart
  mov   ebx, ecx
  shr   ecx, 3
  mov   eax, ecx
  shl   eax, 3
  sub   ebx, eax
  xor   eax, eax
  or    edx, edx
  jz    @@BlackColor2
  mov   eax, $FF;
@@BlackColor2:
@@Lopper:
  or    ds:[edi], al
  inc   edi
  loop  @@Lopper
  mov   ecx, ebx
@@ToEndPart:
// EndPart
  or    ecx, ecx
  jz    @@NoMore
  xor   eax, eax
  mov   al, $80
@EndFiller:
  or    ah, al
  shr   al, 1
  loop  @EndFiller
  mov   bl, ds:[edi]
  or    edx, edx
  jz    @@BlackColor3
  or    bl, al
@@BlackColor3:
  mov   ds:[edi], bl

@@NoMore:
  pop   ebx
  pop   edi
  pop   esi
end;

procedure BMemSetAnd1(Dst, Xpos, Size, Color :longword); assembler; stdcall;
asm
  push  esi
  push  edi
  push  ebx
  cld

  mov   edx, Color
  and   edx, 1

  mov   ecx, Size
  mov   ebx, Xpos
  mov   edi, ebx
  shr   edi, 3
  add   edi, Dst
  xor   eax, eax
  and   ebx, 7
  mov   al, byte ptr ds:[MaskMono + ebx]
@BeginFiller:
  or    ah, al
  dec   ecx
  jz    @Done
  shr   al, 1
  jc    @Done
  jmp   @BeginFiller;
@Done:
  mov   bl, ds:[edi]
  or    edx, edx
  jz    @@BlackColor
  and    bl, al
@@BlackColor:
  mov ds:[edi], bl
  inc edi
// Midle
  cmp   ecx, 8
  jb    @@ToEndPart
  mov   ebx, ecx
  shr   ecx, 3
  mov   eax, ecx
  shl   eax, 3
  sub   ebx, eax
  xor   eax, eax
  or    edx, edx
  jz    @@BlackColor2
  mov   eax, $FF;
@@BlackColor2:
@@Lopper:
  and    ds:[edi], al
  inc   edi
  loop  @@Lopper
  mov   ecx, ebx
@@ToEndPart:
// EndPart
  or    ecx, ecx
  jz    @@NoMore
  xor   eax, eax
  mov   al, $80
@EndFiller:
  or    ah, al
  shr   al, 1
  loop  @EndFiller
  mov   bl, ds:[edi]
  or    edx, edx
  jz    @@BlackColor3
  and    bl, al
@@BlackColor3:
  mov ds:[edi], bl

@@NoMore:
  pop   ebx
  pop   edi
  pop   esi
end;

procedure BMemSetXor1(Dst, Xpos, Size, Color :longword); assembler; stdcall;
asm
  push  esi
  push  edi
  push  ebx
  cld

  mov   edx, Color
  and   edx, 1

  mov   ecx, Size
  mov   ebx, Xpos
  mov   edi, ebx
  shr   edi, 3
  add   edi, Dst
  xor   eax, eax
  and   ebx, 7
  mov   al, byte ptr ds:[MaskMono + ebx]
@BeginFiller:
  or    ah, al
  dec   ecx
  jz    @Done
  shr   al, 1
  jc    @Done
  jmp   @BeginFiller;
@Done:
  mov   bl, ds:[edi]
  or    edx, edx
  jz    @@BlackColor
  xor    bl, al
@@BlackColor:
  mov ds:[edi], bl
  inc edi
// Midle
  cmp   ecx, 8
  jb    @@ToEndPart
  mov   ebx, ecx
  shr   ecx, 3
  mov   eax, ecx
  shl   eax, 3
  sub   ebx, eax
  xor   eax, eax
  or    edx, edx
  jz    @@BlackColor2
  mov   eax, $FF;
@@BlackColor2:
@@Lopper:
  xor    ds:[edi], al
  inc   edi
  loop  @@Lopper
  mov   ecx, ebx
@@ToEndPart:
// EndPart
  or    ecx, ecx
  jz    @@NoMore
  xor   eax, eax
  mov   al, $80
@EndFiller:
  or    ah, al
  shr   al, 1
  loop  @EndFiller
  mov   bl, ds:[edi]
  or    edx, edx
  jz    @@BlackColor3
  xor    bl, al
@@BlackColor3:
  mov ds:[edi], bl

@@NoMore:
  pop   ebx
  pop   edi
  pop   esi
end;









procedure BMemSetAnd8(Dst, Size, Color : longword); assembler; stdcall;
asm
  push  esi
  push  edi
  push  ebx
  mov   edi, Dst
  mov   ecx, Size
  mov   ebx, Color
@@NextPix:
  mov   al, ds:[edi]
  And    al, bl
  mov   ds:[edi], al
  inc   edi
  loop  @@NextPix
  pop   ebx
  pop   edi
  pop   esi
end;

procedure BMemSetXor8(Dst, Size, Color : longword); assembler; stdcall;
asm
  push  esi
  push  edi
  push  ebx
  mov   edi, Dst
  mov   ecx, Size
  mov   ebx, Color
@@NextPix:
  mov   al, ds:[edi]
  Xor   al, bl
  mov   ds:[edi], al
  inc   edi
  loop  @@NextPix
  pop   ebx
  pop   edi
  pop   esi
end;


procedure BMemSetAnd1516(Dst, Size, Color : longword); assembler; stdcall;
asm
  push  esi
  push  edi
  push  ebx
  mov   edi, Dst
  mov   ecx, Size
  mov   ebx, Color
@@NextPix:
  mov   ax, ds:[edi]
  And    ax, bx
  mov   ds:[edi], ax
  add   edi, 2
  loop  @@NextPix
  pop   ebx
  pop   edi
  pop   esi
end;

procedure BMemSetXor1516(Dst, Size, Color : longword); assembler; stdcall;
asm
  push  esi
  push  edi
  push  ebx
  mov   edi, Dst
  mov   ecx, Size
  mov   ebx, Color
@@NextPix:
  mov   ax, ds:[edi]
  Xor   ax, bx
  mov   ds:[edi], ax
  add   edi, 2
  loop  @@NextPix
  pop   ebx
  pop   edi
  pop   esi
end;



procedure BMemSetAnd24(Dst, Size, Color : longword); assembler; stdcall;
asm
  push  esi
  push  edi
  push  ebx
  mov   edi, Dst
  mov   ecx, Size
  mov   ebx, Color
@@NextPix:
  mov   eax, ds:[edi]
  and   eax, 00FFFFFFh
  and   eax, ebx
  mov   ds:[edi], ax
  shr   eax, 16
  mov   ds:[edi+ 2], al
  add   edi, 3
  loop  @@NextPix
  pop   ebx
  pop   edi
  pop   esi
end;

procedure BMemSetXor24(Dst, Size, Color : longword); assembler; stdcall;
asm
  push  esi
  push  edi
  push  ebx
  mov   edi, Dst
  mov   ecx, Size
  mov   ebx, Color
@@NextPix:
  mov   eax, ds:[edi]
  and   eax, 00FFFFFFh
  xor   eax, ebx
  mov   ds:[edi], ax
  shr   eax, 16
  mov   ds:[edi+ 2], al
  add   edi, 3
  loop  @@NextPix
  pop   ebx
  pop   edi
  pop   esi
end;

procedure BMemSetOr32(Dst, Size, Color : longword); assembler; stdcall;
asm
  push  esi
  push  edi
  push  ebx
  mov   edi, Dst
  mov   ecx, Size
  mov   ebx, Color
@@NextPix:
  mov   eax, ds:[edi]
  or    eax, ebx
  mov   ds:[edi], eax
  add   edi, 4
  loop  @@NextPix
  pop   ebx
  pop   edi
  pop   esi
end;

procedure BMemSetAnd32(Dst, Size, Color : longword); assembler; stdcall;
asm
  push  esi
  push  edi
  push  ebx
  mov   edi, Dst
  mov   ecx, Size
  mov   ebx, Color
@@NextPix:
  mov   eax, ds:[edi]
  And    eax, ebx
  mov   ds:[edi], eax
  add   edi, 4
  loop  @@NextPix
  pop   ebx
  pop   edi
  pop   esi
end;

procedure BMemSetXor32(Dst, Size, Color : longword); assembler; stdcall;
asm
  push  esi
  push  edi
  push  ebx
  mov   edi, Dst
  mov   ecx, Size
  mov   ebx, Color
@@NextPix:
  mov   eax, ds:[edi]
  Xor   eax, ebx
  mov   ds:[edi], eax
  add   edi, 4
  loop  @@NextPix
  pop   ebx
  pop   edi
  pop   esi
end;


procedure BMemKey8(Src, Dst, Size, Key : longword); assembler; stdcall;
asm
  push  esi
  push  edi
  push  ebx
  mov   ecx, Size
  mov   edx, ecx
  shr   ecx, 1
  jz    @Out
  mov   edi, Src
  mov   esi, Dst
  mov   ebx, Key
@Loop:
    mov   ax, ds:[edi]
    cmp   al, bl
    jz    @Next1
    mov   ds:[esi], al
@Next1:
    cmp   ah, bl
    jz    @Next2
    mov   ds:[esi + 1], ah
@Next2:
    add   edi, 2
    add   esi, 2
  loop  @Loop
  and   edx, 1
  jz    @Out
  mov   al, ds:[edi]
  cmp   al, bl
  jz    @Out
  mov   ds:[esi], al
@Out:
  pop   ebx
  pop   edi
  pop   esi
end;

procedure BMemKey1516(Src, Dst, Size, Key : longword); assembler; stdcall;
asm
  push  esi
  push  edi
  push  ebx
  mov   ecx, Size
  mov   edi, Src
  mov   esi, Dst
  mov   ebx, Key
@Loop:
    mov   ax, ds:[edi]
    cmp   ax, bx
    jz @Next1
    mov   ds:[esi], ax
@Next1:
    add   edi, 2
    add   esi, 2
  loop  @Loop
  pop   ebx
  pop   edi
  pop   esi
end;

procedure BMemKey24(Src, Dst, Size, Key : longword); assembler; stdcall;
asm
  push  esi
  push  edi
  push  ebx
  mov   ecx, Size
  mov   edi, Src
  mov   esi, Dst
  mov   ebx, Key
  and   ebx, 00FFFFFFh
@Loop:
    mov   eax, ds:[edi]
    and   eax, 00FFFFFFh
    cmp   eax, ebx
    jz @Next1
      mov   ds:[esi], ax
      shr   eax, 16
      mov   ds:[esi+ 2], al
@Next1:
    add   edi, 3
    add   esi, 3
  loop  @Loop
  pop   ebx
  pop   edi
  pop   esi
end;

procedure BMemKey32(Src, Dst, Size, Key : longword); assembler; stdcall;
asm
  push  esi
  push  edi
  push  ebx
  mov   ecx, Size
  mov   edi, src
  mov   esi, dst
  mov   ebx, Key
@Loop:
    mov   eax, ds:[edi]
    cmp   eax, ebx
    jz    @Next1
      mov   ds:[esi], eax
@Next1:
    add   edi, 4
    add   esi, 4
  loop  @Loop
  pop   ebx
  pop   edi
  pop   esi
end;

{//LENS 50% fixed blending }
procedure BMemKeyLens15(Src, Dst, Size, Key : longword); assembler; stdcall;
asm
  push  esi
  push  edi
  push  ebx
  mov   ecx, Size
  mov   edi, Src
  mov   esi, Dst
  mov   ebx, Key
  push  ebp
  mov   bp, 0011110111101111b    {; AndMask (15bpp) }
@Loop:
    mov   ax, ds:[edi]
    cmp   ax, bx
    jz @Next1
    mov   dx, ds:[esi]            {;// EDX = color from destation bitmap }
    shr   ax, 1                   {;// EAX = EAX / 2  }
    shr   dx, 1                   {;// EDX = EDX / 2  }
    and   ax, bp                  {;// clear overflow bits in EAX }
    and   dx, bp                  {;// clear overflow bits in EDX }
    add   ax, dx                  {;// EAX = EAX + EDX }
    mov   ds:[esi], ax
@Next1:
    add   edi, 2
    add   esi, 2
  loop  @Loop
  pop   ebp
  pop   ebx
  pop   edi
  pop   esi
end;

procedure BMemKeyLens16(Src, Dst, Size, Key : longword); assembler; stdcall;
asm
  push  esi
  push  edi
  push  ebx
  mov   ecx, Size
  mov   edi, Src
  mov   esi, Dst
  mov   ebx, Key
  push  ebp
  mov   bp, 0111101111101111b    {; AndMask (16bpp) }
@Loop:
    mov   ax, ds:[edi]
    cmp   ax, bx
    jz @Next1
    mov   dx, ds:[esi]            {;// EDX = color from destation bitmap }
    shr   ax, 1                   {;// EAX = EAX / 2  }
    shr   dx, 1                   {;// EDX = EDX / 2  }
    and   ax, bp                  {;// clear overflow bits in EAX }
    and   dx, bp                  {;// clear overflow bits in EDX }
    add   ax, dx                  {;// EAX = EAX + EDX }
    mov   ds:[esi], ax
@Next1:
    add   edi, 2
    add   esi, 2
  loop  @Loop
  pop   ebp
  pop   ebx
  pop   edi
  pop   esi
end;

procedure BMemKeyLens24(Src, Dst, Size, Key : longword); assembler; stdcall;
asm
  push  esi
  push  edi
  push  ebx
  mov   ecx, Size
  mov   edi, Src
  mov   esi, Dst
  mov   ebx, Key
  and   ebx, 00FFFFFFh
@Loop:
    mov   eax, ds:[edi]
    and   eax, 00FFFFFFh
    cmp   eax, ebx
    jz @Next1
      mov   edx, ds:[esi]            {;// EDX = color from destation bitmap }
      and   edx, 00FFFFFFh
      shr   eax, 1                   {;// EAX = EAX / 2 }
      shr   edx, 1                   {;// EDX = EDX / 2 }
      and   eax, ebp                 {;// clear overflow bits in EAX }
      and   edx, ebp                 {;// clear overflow bits in EDX }
      add   eax, edx                 {;// EAX = EAX + EDX   }

      mov   ds:[esi], ax
      shr   eax, 16
      mov   ds:[esi+ 2], al
@Next1:
    add   edi, 3
    add   esi, 3
  loop  @Loop
  pop   ebx
  pop   edi
  pop   esi
end;

procedure BMemKeyLens32(Src, Dst, Size, Key : longword); assembler; stdcall;
asm
  push  esi
  push  edi
  push  ebx
  mov   ecx, Size
  mov   edi, src
  mov   esi, dst
  mov   ebx, Key
  push  ebp
  mov   ebp, 011111110111111101111111b  {; AndMask (32bpp) }

@Loop:
    mov   eax, ds:[edi]
    cmp   eax, ebx
    jz    @Next1
      mov   edx, ds:[esi]            {;// EDX = color from destation bitmap }
      shr   eax, 1                   {;// EAX = EAX / 2 }
      shr   edx, 1                   {;// EDX = EDX / 2 }
      and   eax, ebp                 {;// clear overflow bits in EAX }
      and   edx, ebp                 {;// clear overflow bits in EDX }
      add   eax, edx                 {;// EAX = EAX + EDX   }
      mov   ds:[esi], eax
@Next1:
    add   edi, 4
    add   esi, 4
  loop  @Loop
  pop   ebp
  pop   ebx
  pop   edi
  pop   esi
end;

{//SHADOW 50% fixed blending from specify color (shadow color)}
procedure BMemKeyShadow15(Src, Dst, Size, Key, Color : longword); assembler; stdcall;
asm
  push  esi
  push  edi
  push  ebx
  mov   ecx, Size
  mov   edi, Src
  mov   esi, Dst
  mov   ebx, Key
  mov   edx, Color
  shr   dx, 1
  push  ebp
  mov   bp, 0011110111101111b    {; AndMask (15bpp) }
  and   dx, bp                   {; pre calc }
@Loop:
    mov   ax, ds:[edi]
    cmp   ax, bx
    jz @Next1
    mov   ax, ds:[esi]            {;// EDX = color from destation bitmap }
    shr   ax, 1                   {;// EAX = EAX / 2  }
    and   ax, bp                  {;// clear overflow bits in EAX }
    add   ax, dx                  {;// EAX = EAX + EDX }
    mov   ds:[esi], ax
@Next1:
    add   edi, 2
    add   esi, 2
  loop  @Loop
  pop   ebp
  pop   ebx
  pop   edi
  pop   esi
end;

procedure BMemKeyShadow16(Src, Dst, Size, Key, Color : longword); assembler; stdcall;
asm
  push  esi
  push  edi
  push  ebx
  mov   ecx, Size
  mov   edi, Src
  mov   esi, Dst
  mov   ebx, Key
  mov   edx, Color
  shr   dx, 1
  push  ebp
  mov   bp, 0111101111101111b    {; AndMask (16bpp) }
  and   dx, bp                   {; pre calc }
@Loop:
    mov   ax, ds:[edi]
    cmp   ax, bx
    jz @Next1
    mov   ax, ds:[esi]            {;// EDX = color from destation bitmap }
    shr   ax, 1                   {;// EAX = EAX / 2  }
    and   ax, bp                  {;// clear overflow bits in EAX }
    add   ax, dx                  {;// EAX = EAX + EDX }
    mov   ds:[esi], ax
@Next1:
    add   edi, 2
    add   esi, 2
  loop  @Loop
  pop   ebp
  pop   ebx
  pop   edi
  pop   esi
end;

procedure BMemKeyShadow24(Src, Dst, Size, Key, Color : longword); assembler; stdcall;
asm
  push  esi
  push  edi
  push  ebx
  mov   ecx, Size
  mov   edi, Src
  mov   esi, Dst
  mov   ebx, Key
  and   ebx, 00FFFFFFh
  mov   edx, Color
  shr   edx, 1
  push  ebp
  mov   ebp, 011111110111111101111111b  {; AndMask (32bpp) }
  and   edx, ebp

@Loop:
    mov   eax, ds:[edi]
    and   eax, 00FFFFFFh
    cmp   eax, ebx
    jz @Next1
      mov   eax, ds:[esi]            {;// EDX = color from destation bitmap }
      and   eax, 00FFFFFFh
      shr   eax, 1                   {;// EAX = EAX / 2 }
      and   eax, ebp                 {;// clear overflow bits in EAX }
      add   eax, edx                 {;// EAX = EAX + EDX   }

      mov   ds:[esi], ax
      shr   eax, 16
      mov   ds:[esi+ 2], al
@Next1:
    add   edi, 3
    add   esi, 3
  loop  @Loop
  pop   ebp
  pop   ebx
  pop   edi
  pop   esi
end;

procedure BMemKeyShadow32(Src, Dst, Size, Key, Color : longword); assembler; stdcall;
asm
  push  esi
  push  edi
  push  ebx
  mov   ecx, Size
  mov   edi, src
  mov   esi, dst
  mov   ebx, Key
  mov   edx, Color
  shr   edx, 1
  push  ebp
  mov   ebp, 011111110111111101111111b  {; AndMask (32bpp) }
  and   edx, ebp

@Loop:
    mov   eax, ds:[edi]
    cmp   eax, ebx
    jz    @Next1
      mov   eax, ds:[esi]            {;// EDX = color from destation bitmap }
      shr   eax, 1                   {;// EAX = EAX / 2 }
      and   eax, ebp                 {;// clear overflow bits in EAX }
      add   eax, edx                 {;// EAX = EAX + EDX   }
      mov   ds:[esi], eax
@Next1:
    add   edi, 4
    add   esi, 4
  loop  @Loop
  pop   ebp
  pop   ebx
  pop   edi
  pop   esi
end;

{//GREY convert to grey scale (midle methode )}
procedure BMemKeyGrey15(Src, Dst, Size, Key : longword); assembler; stdcall;
asm
  push  esi
  push  edi
  push  ebx
  mov   ecx, Size
  mov   edi, Src
  mov   esi, Dst
  mov   ebx, Key
@Loop:
    mov   ax, ds:[edi]
    cmp   ax, bp
    jz @Next1
      mov   dl, al      {; al = 0RRR RRGG GGGB BBBB }
      and   dl, $1f     {; dl = blue color }

      shr   ax, 2       {; ah == 000RRRRR,  al == GGGGGBBB }
      shr   al, 3       {; al = green color, ah = red color }

      shl   ax, 1       {; convert into Intensity= G*2+R*2+B*8 }
      shl   dl, 2

      add   al,ah
      add   al,dl       { al = r + g + b   }
      shr   al, 3       {Intensity div 8   }

      xor   ah, ah
      mov   dl, al      {intensity into dl }

      shl   dx, 5
      or    ax, dx
      shl   dx, 5
      or    ax, dx

      mov   ds:[esi], ax
@Next1:
    add   edi, 2
    add   esi, 2
  loop  @Loop
  pop   ebx
  pop   edi
  pop   esi
end;

procedure BMemKeyGrey16(Src, Dst, Size, Key : longword); assembler; stdcall;
asm
  push  esi
  push  edi
  push  ebx
  mov   ecx, Size
  mov   edi, Src
  mov   esi, Dst
  mov   ebx, Key
@Loop:
    mov   ax, ds:[edi]
    cmp   ax, bx
    jz @Next1
      mov   dl, al      {; al = RRRR RGGG GGGB BBBB }
      and   dl, $1f     {; dl = blue color }

      shr   ax, 3       {; ah == 000RRRRR,  al == GGGGGGBB }
      shr   al, 3       {; al = green color div 2, ah = red color }

      shl   ax, 1       {; convert into Intensity= G*2+R*2+B*8 }
      shl   dl, 2

      add   al,ah
      add   al,dl       { al = r + g + b   }
      shr   al, 3       {Intensity div 8   }

      xor   ah, ah
      mov   dl, al      {intensity into dl   put blue  0000 0000 000X XXXX}

      shl   dx, 11      { put red                      XXXX XX00 0000 0000}
      or    ax, dx
      shr   dx, 5       { put green                    0000 0XXX XX00 0000}
      or    ax, dx
      mov   ds:[esi], ax
@Next1:
    add   edi, 2
    add   esi, 2
  loop  @Loop
  pop   ebx
  pop   edi
  pop   esi
end;

procedure BMemKeyGrey24(Src, Dst, Size, Key : longword); assembler; stdcall;
asm
  push  esi
  push  edi
  push  ebx
  mov   ecx, Size
  mov   edi, Src
  mov   esi, Dst
  mov   ebx, Key
  and   ebx, 00FFFFFFh
@Loop:
    mov   eax, ds:[edi]
    and   eax, 00FFFFFFh
    cmp   eax, ebx
    jz @Next1
      xor   edx, edx
      shr   eax, 1
      and   eax, 011111110111111101111111b

      shr   al, 6
      mov   dl, al
      shr   eax, 8
      add   dl, al
      add   dl, ah

      xor   eax,eax
      mov   al, dl
      shl   edx, 8
      or    eax, edx
      shl   edx, 8
      or    eax, edx

      mov   ds:[esi], ax
      shr   eax, 16
      mov   ds:[esi+ 2], al
@Next1:
    add   edi, 3
    add   esi, 3
  loop  @Loop
  pop   ebx
  pop   edi
  pop   esi
end;

procedure BMemKeyGrey32(Src, Dst, Size, Key : longword); assembler; stdcall;
asm
  push  esi
  push  edi
  push  ebx
  mov   ecx, Size
  mov   edi, src
  mov   esi, dst
  mov   ebx, Key
@Loop:
    mov   eax, ds:[edi]
    cmp   eax, ebx
    jz    @Next1
      xor   edx, edx
      shr   eax, 1
      and   eax, 011111110111111101111111b

      shr   al, 6
      mov   dl, al
      shr   eax, 8
      add   dl, al
      add   dl, ah

      xor   eax,eax
      mov   al, dl
      shl   edx, 8
      or    eax, edx
      shl   edx, 8
      or    eax, edx

      mov   ds:[esi], eax
@Next1:
    add   edi, 4
    add   esi, 4
  loop  @Loop
  pop   ebx
  pop   edi
  pop   esi
end;

//Fill BMem Alpha
procedure BMemSetAlpha15(Dst, Size, Color, Alpha : longword); assembler; stdcall;
asm
  push  esi
  push  edi
  push  ebx
  mov   ecx, Size
  mov   edi, Dst
  mov   ebx, $FF
  mov   eax, Alpha
  and   eax, $FF
  sub   ebx, eax
  shr   ebx, 3
  mov   esi, Color
  push  ebp
  mov   ebp, esi
  and   esi, 00000000000000000111110000011111b
  and   ebp, 00000000000000000000001111100000b
@Loop:
    mov   ax, ds:[edi]
    and   eax, 00000000000000000111110000011111b
    sub   eax, esi
    imul  eax, ebx
    shr   eax, 5
    add   eax, esi
    and   eax, 00000000000000000111110000011111b
    mov   edx, eax

    mov   ax, ds:[edi]
    and   eax, 00000000000000000000001111100000b
    sub   eax, ebp
    imul  eax, ebx
    shr   eax, 5
    add   eax, ebp
    and   eax, 00000000000000000000001111100000b
    or    eax, edx

    mov   ds:[edi], ax
    add   edi, 2
  loop  @Loop
  pop   ebp
  pop   ebx
  pop   edi
  pop   esi
end;

procedure BMemSetAlpha16(Dst, Size, Color, Alpha : longword); assembler; stdcall;
asm
  push  esi
  push  edi
  push  ebx
  mov   ecx, Size
  mov   edi, Dst
  mov   ebx, $FF
  mov   eax, Alpha
  and   eax, $FF
  sub   ebx, eax
  shr   ebx, 3
  mov   esi, Color
  push  ebp
  mov   ebp, esi
  and   esi, 00000000000000001111100000011111b
  and   ebp, 00000000000000000000011111100000b
@Loop:
    mov   ax, ds:[edi]
    and   eax, 00000000000000001111100000011111b
    sub   eax, esi
    imul  eax, ebx
    shr   eax, 5
    add   eax, esi
    and   eax, 00000000000000001111100000011111b
    mov   edx, eax

    shl   ebx, 1
    mov   ax, ds:[edi]
    and   eax, 00000000000000000000011111100000b
    sub   eax, ebp
    imul  eax, ebx
    shr   eax, 6
    add   eax, ebp
    and   eax, 00000000000000000000011111100000b
    or    eax, edx
    shr   ebx, 1

    mov   ds:[edi], ax
    add   edi, 2
  loop  @Loop
  pop   ebp
  pop   ebx
  pop   edi
  pop   esi
end;

procedure BMemSetAlpha24(Dst, Size, Color, Alpha : longword); assembler; stdcall;
asm
  push  esi
  push  edi
  push  ebx
  mov   ecx, Size
  mov   edi, Dst
  mov   ebx, $FF
  mov   eax, Alpha
  and   eax, $FF
  sub   ebx, eax
  mov   esi, Color
  push  ebp
  mov   ebp, esi
  and   esi, 00FF00FFh
  and   ebp, 0000FF00h
@Loop:
    mov   eax, ds:[edi]
    and   eax, 0FF00FFh
    sub   eax, esi
    imul  eax, ebx
    shr   eax, 8
    add   eax, esi
    and   eax, 0FF00FFh
    mov   edx, eax

    mov   eax, ds:[edi]
    and   eax, 000FF00h
    sub   eax, ebp
    imul  eax, ebx
    shr   eax, 8
    add   eax, ebp
    and   eax, 000FF00h
    or    eax, edx

    mov   ds:[edi], ax
    shr   eax, 16
    mov   ds:[edi+ 2], al
    add   edi, 3
  loop  @Loop
  pop   ebp
  pop   ebx
  pop   edi
  pop   esi
end;

procedure BMemSetAlpha32(Dst, Size, Color, Alpha : longword); assembler; stdcall;
asm
  push  esi
  push  edi
  push  ebx
  mov   ecx, Size
  mov   edi, Dst
  mov   ebx, $FF
  mov   eax, Alpha
  and   eax, $FF
  sub   ebx, eax
  mov   esi, Color
  push  ebp
  mov   ebp, esi
  and   esi, 00FF00FFh
  and   ebp, 0000FF00h
@Loop:
    mov   eax, ds:[edi]
    and   eax, 0FF00FFh
    sub   eax, esi
    imul  eax, ebx
    shr   eax, 8
    add   eax, esi
    and   eax, 0FF00FFh
    mov   edx, eax

    mov   eax, ds:[edi]
    and   eax, 000FF00h
    sub   eax, ebp
    imul  eax, ebx
    shr   eax, 8
    add   eax, ebp
    and   eax, 000FF00h
    or    eax, edx

    mov   ds:[edi], eax
    add   edi, 4
  loop  @Loop
  pop   ebp
  pop   ebx
  pop   edi
  pop   esi
end;

//BMem Move Alpha
procedure BMemAlpha15(Src, Dst, Size, Alpha : longword); assembler; stdcall;
Var Col:longword;
asm
  push  esi
  push  edi
  push  ebx
  mov   ecx, Size
  mov   esi, Src
  mov   edi, Dst
  mov   edx, Alpha
  and   edx, $FF
  shr   edx, 3
@Loop:
    mov   ax, ds:[esi]
    mov   bx, ds:[edi]
    and   eax, 00000000000000000111110000011111b
    and   ebx, 00000000000000000111110000011111b
    sub   eax, ebx
    imul  eax, edx
    shr   eax, 5
    add   eax, ebx
    and   eax, 00000000000000000111110000011111b
    mov   Col, eax

    mov   ax, ds:[esi]
    mov   bx, ds:[edi]
    and   eax, 00000000000000000000001111100000b
    and   ebx, 00000000000000000000001111100000b
    sub   eax, ebx
    imul  eax, edx
    shr   eax, 5
    add   eax, ebx
    and   eax, 00000000000000000000001111100000b

    or    eax, Col

    mov   ds:[edi], ax
    add   esi, 2
    add   edi, 2
  loop  @Loop
  pop   ebx
  pop   edi
  pop   esi
end;

procedure BMemAlpha16(Src, Dst, Size, Alpha : longword); assembler; stdcall;
Var Col:longword;
asm
  push  esi
  push  edi
  push  ebx
  mov   ecx, Size
  mov   esi, Src
  mov   edi, Dst
  mov   edx, Alpha
  and   edx, $FF
  shr   edx, 3
@Loop:
    mov   ax, ds:[esi]
    mov   bx, ds:[edi]
    and   eax, 00000000000000001111100000011111b
    and   ebx, 00000000000000001111100000011111b
    sub   eax, ebx
    imul  eax, edx
    shr   eax, 5
    add   eax, ebx
    and   eax, 00000000000000001111100000011111b
    mov   Col, eax

    shl   edx, 1
    mov   ax, ds:[esi]
    mov   bx, ds:[edi]
    and   eax, 00000000000000000000011111100000b
    and   ebx, 00000000000000000000011111100000b
    sub   eax, ebx
    imul  eax, edx
    shr   eax, 6
    add   eax, ebx
    and   eax, 00000000000000000000011111100000b
    shr   edx, 1

    or    eax, Col

    mov   ds:[edi], ax
    add   esi, 2
    add   edi, 2
  loop  @Loop
  pop   ebx
  pop   edi
  pop   esi
end;


procedure BMemAlpha24(Src, Dst, Size, Alpha : longword); assembler; stdcall;
Var Col:longword;
asm
  push  esi
  push  edi
  push  ebx
  mov   ecx, Size
  mov   esi, Src
  mov   edi, Dst
  mov   edx, Alpha
  and   edx, $FF
@Loop:
    mov   eax, ds:[esi]
    and   eax, 0FFFFFFh
    mov   ebx, ds:[edi]
    and   eax, 0FF00FFh
    and   ebx, 0FF00FFh
    sub   eax, ebx
    imul  eax, edx
    shr   eax, 8
    add   eax, ebx
    and   eax, 0FF00FFh
    mov   Col, eax

    mov   eax, ds:[esi]
    mov   ebx, ds:[edi]
    and   eax, 000FF00h
    and   ebx, 000FF00h
    sub   eax, ebx
    imul  eax, edx
    shr   eax, 8
    add   eax, ebx
    and   eax, 000FF00h

    or    eax, Col

    mov   ds:[edi], ax
    shr   eax, 16
    mov   ds:[edi+ 2], al

    add   esi, 3
    add   edi, 3
  loop  @Loop
  pop   ebx
  pop   edi
  pop   esi
end;

procedure BMemAlpha32(Src, Dst, Size, Alpha : longword); assembler; stdcall;
Var Col:longword;
asm
  push  esi
  push  edi
  push  ebx
  mov   ecx, Size
  mov   esi, Src
  mov   edi, Dst
  mov   edx, Alpha
  and   edx, $FF
@Loop:
    mov   eax, ds:[esi]
    mov   ebx, ds:[edi]
    and   eax, 0FF00FFh
    and   ebx, 0FF00FFh
    sub   eax, ebx
    imul  eax, edx
    shr   eax, 8
    add   eax, ebx
    and   eax, 0FF00FFh
    mov   Col, eax

    mov   eax, ds:[esi]
    mov   ebx, ds:[edi]
    and   eax, 000FF00h
    and   ebx, 000FF00h
    sub   eax, ebx
    imul  eax, edx
    shr   eax, 8
    add   eax, ebx
    and   eax, 000FF00h
    or    eax, Col

    mov   ds:[edi], eax
    add   esi, 4
    add   edi, 4
  loop  @Loop
  pop   ebx
  pop   edi
  pop   esi
end;

procedure BMemAlpha24_mmx(Src, Dst, Size, Alpha : longword); assembler; stdcall;
asm
  push  esi
  push  edi
  push  ebx
  mov   ecx, Size
  mov   esi, Src
  mov   edi, Dst


  mov   ebx, Alpha
  and   ebx, $FF

  pxor      mm7, mm7    // mm7 = 0
  mov       eax, ebx
  imul      eax, $00010001
  push      eax
  push      eax
  movq      mm6, [esp]  // mm6 - alpfa multip

  mov       eax, $00FF00FF
  push      eax
  push      eax
  mov       edx, $FFFFFF
  movq      mm5, [esp]  // mm5 - $00FF00FF00FF00FF

  push      edx
  movd      mm4, [esp]  // mm4 - $0000000000FFFFFF

  mov       eax, 255
  sub       eax, ebx // 255 - Alpha
  imul      eax, $00010001
  push      eax
  push      eax
  movq      mm3, [esp]  // mm3 - opaque alpha

//  sub       esi, 3

@Loop:
  mov       eax, [esi]
  and       eax, $FFFFFF
  add       esi, 3

  movd      mm0, eax    // get source
  mov       edx, [edi]
  punpcklbw mm0, mm7    // unpack lo byte in word
  movd      mm1, edx    // get destination
  pmullw    mm0, mm6
  pand      mm1, mm4

  punpcklbw mm1, mm7    // unpack lo byte in word
  pmullw    mm1, mm3
  paddw     mm0, mm1
  psrlq     mm0, 8

  pand      mm0, mm5    // cut garbage bytes
  and       edx, $FF000000
  packuswb  mm0, mm7    // pack

  movd      eax, mm0    // save
  or        eax, edx
  mov       [edi], eax
  add       edi, 3
  dec       ecx
  jnz       @loop

  pop   ebx
  pop   edi
  pop   esi
  emms
end;



procedure BMemAlpha32_mmx(Src, Dst, Size, Alpha : longword); assembler; stdcall;
asm
  push  esi
  push  edi
  push  ebx
  mov   ecx, Size
  mov   esi, Src
  mov   edi, Dst


  mov   ebx, Alpha
  and   ebx, $FF

  pxor      mm7, mm7    // mm7 = 0
  mov       eax, ebx
  imul      eax, $00010001
  push      eax
  push      eax
  movq      mm6, [esp]  // mm6 - alpfa multip

  mov       eax, $00FF00FF
  push      eax
  push      eax
  mov       edx, $FFFFFF
  movq      mm5, [esp]  // mm5 - $00FF00FF00FF00FF

  push      edx
  movd      mm4, [esp]  // mm4 - $0000000000FFFFFF

  mov       eax, 255
  sub       eax, ebx // 255 - Alpha
  imul      eax, $00010001
  push      eax
  push      eax
  movq      mm3, [esp]  // mm3 - opaque alpha

//  sub       esi, 4

@Loop:
  mov       eax, [esi]
  and       eax, 0FFFFFFh
  add       esi, 4

  movd      mm0, eax    // get source
  mov       edx, [edi]
  punpcklbw mm0, mm7    // unpack lo byte in word
  movd      mm1, edx    // get destination
  pmullw    mm0, mm6
  punpcklbw mm1, mm7    // unpack lo byte in word

  pmullw    mm1, mm3
  paddw     mm0, mm1
  psrlq     mm0, 8

  pand      mm0, mm5    // cut garbage
  packuswb  mm0, mm7    // pack
  movd      [edi], mm0
  add       edi, 4
  dec       ecx
  jnz       @loop
@End:
  pop   ebx
  pop   edi
  pop   esi
  emms
end;


//BMem Move Key Alpha
procedure BMemKeyAlpha15(Src, Dst, Size, Key, Alpha : longword); assembler; stdcall;
Var Col:longword;
asm
  push  esi
  push  edi
  push  ebx
  mov   ecx, Size
  mov   esi, Src
  mov   edi, Dst
  mov   edx, Alpha
  and   edx, $FF
  shr   edx, 3
@Loop:
    mov   ebx, Key
    movzx eax, word ptr ds:[esi]
    cmp   ax, bx
    je    @@Next
    movzx ebx, word ptr ds:[edi]
    and   eax, 00000000000000000111110000011111b
    and   ebx, 00000000000000000111110000011111b
    sub   eax, ebx
    imul  eax, edx
    shr   eax, 5
    add   eax, ebx
    and   eax, 00000000000000000111110000011111b
    mov   Col, eax

    movzx eax, word ptr ds:[esi]
    movzx ebx, word ptr ds:[edi]
    and   eax, 00000000000000000000001111100000b
    and   ebx, 00000000000000000000001111100000b
    sub   eax, ebx
    imul  eax, edx
    shr   eax, 5
    add   eax, ebx
    and   eax, 00000000000000000000001111100000b

    or    eax, Col

    mov   ds:[edi], ax
@@Next:
    add   esi, 2
    add   edi, 2
  loop  @Loop
  pop   ebx
  pop   edi
  pop   esi
end;

procedure BMemKeyAlpha16(Src, Dst, Size, Key, Alpha : longword); assembler; stdcall;
Var Col:longword;
asm
  push  esi
  push  edi
  push  ebx
  mov   ecx, Size
  mov   esi, Src
  mov   edi, Dst
  mov   edx, Alpha
  and   edx, $FF
  shr   edx, 3
@Loop:
    mov   ebx, Key
    movzx eax, word ptr ds:[esi]
    cmp   ax, bx
    je    @@Next
    movzx ebx, word ptr ds:[edi]
    and   eax, 00000000000000001111100000011111b
    and   ebx, 00000000000000001111100000011111b
    sub   eax, ebx
    imul  eax, edx
    shr   eax, 5
    add   eax, ebx
    and   eax, 00000000000000001111100000011111b
    mov   Col, eax

    shl   edx, 1
    movzx eax, word ptr ds:[esi]
    movzx ebx, word ptr ds:[edi]
    and   eax, 00000000000000000000011111100000b
    and   ebx, 00000000000000000000011111100000b
    sub   eax, ebx
    imul  eax, edx
    shr   eax, 6
    add   eax, ebx
    and   eax, 00000000000000000000011111100000b
    shr   edx, 1

    or    eax, Col

    mov   ds:[edi], ax
@@Next:
    add   esi, 2
    add   edi, 2
  loop  @Loop
  pop   ebx
  pop   edi
  pop   esi
end;


procedure BMemKeyAlpha24(Src, Dst, Size, Key, Alpha : longword); assembler; stdcall;
Var Col:longword;
asm
  push  esi
  push  edi
  push  ebx
  mov   ecx, Size
  mov   esi, Src
  mov   edi, Dst
  mov   edx, Alpha
  and   edx, $FF
@Loop:
    mov   ebx, Key
    mov   eax, ds:[esi]
    and   eax, 0FFFFFFh
    cmp   eax, ebx
    je    @@Next
    mov   ebx, ds:[edi]
    and   eax, 0FF00FFh
    and   ebx, 0FF00FFh
    sub   eax, ebx
    imul  eax, edx
    shr   eax, 8
    add   eax, ebx
    and   eax, 0FF00FFh
    mov   Col, eax

    mov   eax, ds:[esi]
    mov   ebx, ds:[edi]
    and   eax, 000FF00h
    and   ebx, 000FF00h
    sub   eax, ebx
    imul  eax, edx
    shr   eax, 8
    add   eax, ebx
    and   eax, 000FF00h

    or    eax, Col

    mov   ds:[edi], ax
    shr   eax, 16
    mov   ds:[edi+ 2], al

@@Next:
    add   esi, 3
    add   edi, 3
  loop  @Loop
  pop   ebx
  pop   edi
  pop   esi
end;

procedure BMemKeyAlpha24_mmx(Src, Dst, Size, Key, Alpha : longword); assembler; stdcall;
asm
  push  esi
  push  edi
  push  ebx
  mov   ecx, Size
  mov   esi, Src
  mov   edi, Dst


  mov   ebx, Alpha
  and   ebx, $FF

  pxor      mm7, mm7    // mm7 = 0
  mov       eax, ebx
  imul      eax, $00010001
  push      eax
  push      eax
  movq      mm6, [esp]  // mm6 - alpfa multip

  mov       eax, $00FF00FF
  push      eax
  push      eax
  mov       edx, $FFFFFF
  movq      mm5, [esp]  // mm5 - $00FF00FF00FF00FF

  push      edx
  movd      mm4, [esp]  // mm4 - $0000000000FFFFFF

  mov       eax, 255
  sub       eax, ebx // 255 - Alpha
  imul      eax, $00010001
  push      eax
  push      eax
  movq      mm3, [esp]  // mm3 - opaque alpha

  mov       ebx, Key
  and       ebx, 0FFFFFFh
//  sub       esi, 3

@Loop:
  mov       eax, [esi]
  and       eax, $FFFFFF
  add       esi, 3
  cmp       eax, ebx
  jnz       @next
  add       edi, 3
  loop      @loop
  jmp       @end
@Next:
  movd      mm0, eax    // get source
  mov       edx, [edi]
  punpcklbw mm0, mm7    // unpack lo byte in word
  movd      mm1, edx    // get destination
  pmullw    mm0, mm6
  pand      mm1, mm4

  punpcklbw mm1, mm7    // unpack lo byte in word
  pmullw    mm1, mm3
  paddw     mm0, mm1
  psrlq     mm0, 8

  pand      mm0, mm5    // cut garbage bytes
  and       edx, $FF000000
  packuswb  mm0, mm7    // pack

  movd      eax, mm0    // save
  or        eax, edx
  mov       [edi], eax
  add       edi, 3
  dec       ecx
  jnz       @loop
@End:
  pop   ebx
  pop   edi
  pop   esi
  emms
end;



procedure BMemKeyAlpha32(Src, Dst, Size, Key, Alpha : longword); assembler; stdcall;
Var Col:longword;
asm
  push  esi
  push  edi
  push  ebx
  mov   ecx, Size
  mov   esi, Src
  mov   edi, Dst
  mov   edx, Alpha
  and   edx, $FF
@Loop:
    mov   ebx, Key
    mov   eax, ds:[esi]
    and   eax, 0FFFFFFh
    cmp   eax, ebx
    je    @@Next
    mov   ebx, ds:[edi]
    and   eax, 0FF00FFh
    and   ebx, 0FF00FFh
    sub   eax, ebx
    imul  eax, edx
    shr   eax, 8
    add   eax, ebx
    and   eax, 0FF00FFh
    mov   Col, eax

    mov   eax, ds:[esi]
    mov   ebx, ds:[edi]
    and   eax, 000FF00h
    and   ebx, 000FF00h
    sub   eax, ebx
    imul  eax, edx
    shr   eax, 8
    add   eax, ebx
    and   eax, 000FF00h
    or    eax, Col

    mov   ds:[edi], eax
@@Next:
    add   esi, 4
    add   edi, 4
  loop  @Loop
  pop   ebx
  pop   edi
  pop   esi
end;


procedure BMemKeyAlpha32_mmx(Src, Dst, Size, Key, Alpha : longword); assembler; stdcall;
asm
  push  esi
  push  edi
  push  ebx
  mov   ecx, Size
  mov   esi, Src
  mov   edi, Dst


  mov   ebx, Alpha
  and   ebx, $FF

  pxor      mm7, mm7    // mm7 = 0
  mov       eax, ebx
  imul      eax, $00010001
  push      eax
  push      eax
  movq      mm6, [esp]  // mm6 - alpfa multip

  mov       eax, $00FF00FF
  push      eax
  push      eax
  mov       edx, $FFFFFF
  movq      mm5, [esp]  // mm5 - $00FF00FF00FF00FF

  push      edx
  movd      mm4, [esp]  // mm4 - $0000000000FFFFFF

  mov       eax, 255
  sub       eax, ebx // 255 - Alpha
  imul      eax, $00010001
  push      eax
  push      eax
  movq      mm3, [esp]  // mm3 - opaque alpha

  mov       ebx, Key
  and       ebx, 0FFFFFFh
  sub       esi, 4

@Loop:
  mov       eax, [esi]
  add       edi, 4
  and       eax, 0FFFFFFh
  add       esi, 4
  cmp       eax, ebx
  jnz       @next
  dec       ecx
  jnz       @loop
  jmp       @end
@Next:
  movd      mm0, eax    // get source
  mov       edx, [edi]
  punpcklbw mm0, mm7    // unpack lo byte in word
  movd      mm1, edx    // get destination
  pmullw    mm0, mm6
  punpcklbw mm1, mm7    // unpack lo byte in word

  pmullw    mm1, mm3
  paddw     mm0, mm1
  psrlq     mm0, 8

  pand      mm0, mm5    // cut garbage
  packuswb  mm0, mm7    // pack
  movd      [edi], mm0
  dec       ecx
  jnz       @loop
@End:
  pop   ebx
  pop   edi
  pop   esi
  emms
end;


// 8bit mono patter or FNT draw
procedure BMemMonPat8(Src, Dst, Skip, Size, Color : longword); assembler; stdcall;
asm
  push  esi
  push  edi
  push  ebx
  mov   esi, Src
  mov   edi, Dst
  mov   ecx, Size
  mov   eax, Color
  mov   dh, 1
  mov   ebx, ds:[esi]
  @Loop:
    rol   bl, 1
    jnc   @noDot
    test  Skip,0FFFFFFFFh
    jnz   @noDot
    mov   ds:[edi], al
  @NoDot:
    test  Skip,0FFFFFFFFh
    jz    @SkipEnd
    dec   Skip
  @SkipEnd:
    rol   dh, 1
    jnc   @NoNext
    inc   esi
    mov   ebx, ds:[esi]
  @NoNext:
    inc   edi
  loop @Loop
  pop   ebx
  pop   edi
  pop   esi
end;

procedure BMemMonPat1516(Src, Dst, Skip, Size, Color : longword); assembler; stdcall;
asm
  push  esi
  push  edi
  push  ebx
  mov   esi, Src
  mov   edi, Dst
  mov   ecx, Size
  mov   eax, Color
  mov   dh, 1
  mov   ebx, ds:[esi]
  @Loop:
    rol   bl, 1
    jnc   @noDot
    test  Skip,0FFFFFFFFh
    jnz   @noDot
    mov   ds:[edi], ax
  @NoDot:
    test  Skip,0FFFFFFFFh
    jz    @SkipEnd
    dec   Skip
  @SkipEnd:
    rol   dh, 1
    jnc   @NoNext
    inc   esi
    mov   ebx, ds:[esi]
  @NoNext:
    add   edi, 2
  loop @Loop
  pop   ebx
  pop   edi
  pop   esi
end;

procedure BMemMonPat24(Src, Dst, Skip, Size, Color : longword); assembler; stdcall;
asm
  push  esi
  push  edi
  push  ebx
  mov   esi, Src
  mov   edi, Dst
  mov   ecx, Size
  mov   eax, Color
  mov   edx, eax
  shr   edx, 16
  mov   dh, 1
  mov   ebx, ds:[esi]
  @Loop:
    rol   bl, 1
    jnc   @noDot
    test  Skip,0FFFFFFFFh
    jnz   @noDot
    mov   ds:[edi], ax
    mov   ds:[edi+ 2], dl
  @NoDot:
    test  Skip,0FFFFFFFFh
    jz    @SkipEnd
    dec   Skip
  @SkipEnd:
    rol   dh, 1
    jnc   @NoNext
    inc   esi
    mov   ebx, ds:[esi]
  @NoNext:
    add   edi, 3
  loop @Loop
  pop   ebx
  pop   edi
  pop   esi
end;

procedure BMemMonPat32(Src, Dst, Skip, Size, Color : longword); assembler; stdcall;
asm
  push  esi
  push  edi
  push  ebx
  mov   esi, Src
  mov   edi, Dst
  mov   ecx, Size
  mov   eax, Color
  mov   dh, 1
  mov   ebx, ds:[esi]
  @Loop:
    rol   bl, 1
    jnc   @noDot
    test  Skip,0FFFFFFFFh
    jnz   @noDot
    mov   ds:[edi], eax
  @NoDot:
    test  Skip,0FFFFFFFFh
    jz    @SkipEnd
    dec   Skip
  @SkipEnd:
    rol   dh, 1
    jnc   @NoNext
    inc   esi
    mov   ebx, ds:[esi]
  @NoNext:
    add   edi, 4
  loop @Loop
  pop   ebx
  pop   edi
  pop   esi
end;


// 8x8 mono pattern
procedure BMemPat8(Src, Dst, Skip, Size, Color : longword); assembler; stdcall;
asm
  push  esi
  push  edi
  push  ebx
  mov   esi, Src
  mov   edi, Dst
  mov   eax, Color
  mov   ebx, ds:[esi]
  mov   ecx, Skip
  rol   bl, cl
  mov   ecx, Size
  @Loop:
    rol   bl, 1
    jnc   @noDot
    mov   ds:[edi], al
  @NoDot:
    inc   edi
  loop @Loop
  pop   ebx
  pop   edi
  pop   esi
end;

procedure BMemPat1516(Src, Dst, Skip, Size, Color : longword); assembler; stdcall;
asm
  push  esi
  push  edi
  push  ebx
  mov   esi, Src
  mov   edi, Dst
  mov   eax, Color
  mov   ebx, ds:[esi]
  mov   ecx, Skip
  rol   bl, cl
  mov   ecx, Size
  @Loop:
    rol   bl, 1
    jnc   @noDot
    mov   ds:[edi], ax
  @NoDot:
    add   edi, 2
  loop @Loop
  pop   ebx
  pop   edi
  pop   esi
end;

procedure BMemPat24(Src, Dst, Skip, Size, Color : longword); assembler; stdcall;
asm
  push  esi
  push  edi
  push  ebx
  mov   esi, Src
  mov   edi, Dst
  mov   eax, Color
  mov   edx, eax
  shr   edx, 16
  mov   ebx, ds:[esi]
  mov   ecx, Skip
  rol   bl, cl
  mov   ecx, Size
  @Loop:
    rol   bl, 1
    jnc   @noDot
    mov   ds:[edi], ax
    mov   ds:[edi+ 2], dl
  @NoDot:
    add   edi, 3
  loop @Loop
  pop   ebx
  pop   edi
  pop   esi
end;

procedure BMemPat32(Src, Dst, Skip, Size, Color : longword); assembler; stdcall;
asm
  push  esi
  push  edi
  push  ebx
  mov   esi, Src
  mov   edi, Dst
  mov   eax, Color
  mov   ebx, ds:[esi]
  mov   ecx, Skip
  rol   bl, cl
  mov   ecx, Size
  @Loop:
    rol   bl, 1
    jnc   @noDot
    mov   ds:[edi], eax
  @NoDot:
    add   edi, 4
  loop @Loop
  pop   ebx
  pop   edi
  pop   esi
end;


// AxA color pattern
procedure BMemColPat8(Src, Dst, SrcMax, Size : longword); assembler; stdcall;
asm
  push  esi
  push  edi
  push  ebx
  mov   esi, Src
  mov   edi, Dst
  mov   ebx, SrcMax
  mov   ecx, Size
  @Loop:
    mov   al, ds:[esi]
    mov   ds:[edi], al
    inc   esi
    inc   edi
    cmp   esi, ebx
    jle   @NoEnd
    mov   esi, Src
  @NoEnd:
  loop @Loop
  pop   ebx
  pop   edi
  pop   esi
end;

procedure BMemColPat1516(Src, Dst, SrcMax, Size : longword); assembler; stdcall;
asm
  push  esi
  push  edi
  push  ebx
  mov   esi, Src
  mov   edi, Dst
  mov   ebx, SrcMax
  mov   ecx, Size
  @Loop:
    mov   ax, ds:[esi]
    mov   ds:[edi], ax
    add   esi, 2
    add   edi, 2
    cmp   esi, ebx
    jle   @NoEnd
    mov   esi, Src
  @NoEnd:
  loop @Loop
  pop   ebx
  pop   edi
  pop   esi
end;

procedure BMemColPat24(Src, Dst, SrcMax, Size: longword); assembler; stdcall;
asm
  push  esi
  push  edi
  push  ebx
  mov   esi, Src
  mov   edi, Dst
  mov   ebx, SrcMax
  mov   ecx, Size
  @Loop:
    mov   ax, ds:[esi]
    mov   dl, ds:[esi+ 2]
    mov   ds:[edi], ax
    mov   ds:[edi+ 2], dl
    add   esi, 3
    add   edi, 3
    cmp   esi, ebx
    jle   @NoEnd
    mov   esi, Src
  @NoEnd:
  loop @Loop
  pop   ebx
  pop   edi
  pop   esi
end;

procedure BMemColPat32(Src, Dst, SrcMax, Size : longword); assembler; stdcall;
asm
  push  esi
  push  edi
  push  ebx
  mov   esi, Src
  mov   edi, Dst
  mov   ebx, SrcMax
  mov   ecx, Size
  @Loop:
    mov   ax, ds:[esi]
    mov   ds:[edi], ax
    add   esi, 4
    add   edi, 4
    cmp   esi, ebx
    jle   @NoEnd
    mov   esi, Src
  @NoEnd:
  loop @Loop
  pop   ebx
  pop   edi
  pop   esi
end;



//  Gradient Fill
procedure BMemGradient15(Dst, Size, Color1, Color2 : longword); assembler; stdcall;
VAR Rval,Gval,Bval,Rdx,Gdx,Bdx:longword;
asm
{; Calc color DX }
  push  esi
  push  edi
  push  ebx
    mov   eax, Color2
    mov   ecx, Color1
    and   eax, 0111110000000000b
    and   ecx, 0111110000000000b
    shr   eax, 10
    shr   ecx, 10
    mov   ebx, ecx
    shl   ebx, 16
    sub   eax, ecx
    jns   @@nsr
    add   eax, -2
    or    ebx, 0FFFFh
  @@nsr:
    inc   eax
    shl   eax, 16
    cdq
    idiv  Size
    mov   Rdx, eax
    mov   Rval, ebx

    mov   eax, Color2
    mov   ecx, Color1
    and   eax, 0000001111100000b
    and   ecx, 0000001111100000b
    shr   eax, 5
    shr   ecx, 5
    mov   ebx, ecx
    shl   ebx, 16
    sub   eax, ecx
    jns   @@nsg
    add   eax, -2
    or    ebx, 0FFFFh
  @@nsg:
    inc   eax
    shl   eax, 16
    cdq
    idiv  Size
    mov   Gdx, eax
    mov   Gval, ebx

    mov   eax, Color2
    mov   ecx, Color1
    and   eax, 0000000000011111b
    and   ecx, 0000000000011111b
    mov   ebx, ecx
    shl   ebx, 16
    sub   eax, ecx
    jns   @@nsb
    add   eax, -2
    or    ebx, 0FFFFh
  @@nsb:
    inc   eax
    shl   eax, 16
    cdq
    idiv  Size
    mov   Bdx, eax
    mov   Bval, ebx

 {; Fill Grad }
   mov   ecx, Size
   mov   edi, Dst
 @@Loop:
   xor   ebx, ebx

   mov   eax, Rval
   mov   edx, eax
   {;               1234123412341234 }
   and   eax, 0111110000000000000000b
   add   edx, Rdx
   shr   eax, 6
   or    ebx, eax
   mov   Rval, edx

   mov   eax, Gval
   mov   edx, eax
   {;               1234123412341234 }
   and   eax, 0111110000000000000000b
   add   edx, Gdx
   shr   eax, 11
   or    ebx, eax
   mov   Gval, edx

   mov   eax, Bval
   mov   edx, eax
   {;               1234123412341234 }
   and   eax, 0111110000000000000000b
   add   edx, Bdx
   shr   eax, 16
   or    ebx, eax
   mov   Bval, edx

   mov   ds:[edi], bx
   add   edi, 2
   loop  @@Loop
  pop   ebx
  pop   edi
  pop   esi

end;

procedure BMemGradient16(Dst, Size, Color1, Color2 : longword); assembler; stdcall;
VAR Rval,Gval,Bval,Rdx,Gdx,Bdx:longword;
asm
  push  esi
  push  edi
  push  ebx
{; Calc color DX }
    mov   eax, Color2
    mov   ecx, Color1
    and   eax, 01111100000000000b
    and   ecx, 01111100000000000b
    shr   eax, 11
    shr   ecx, 11
    mov   ebx, ecx
    shl   ebx, 16
    sub   eax, ecx
    jns   @@nsr
    add   eax, -2
    or    ebx, 0FFFFh
  @@nsr:
    inc   eax
    shl   eax, 16
    cdq
    idiv  Size
    mov   Rdx, eax
    mov   Rval, ebx

    mov   eax, Color2
    mov   ecx, Color1
    and   eax, 0000011111100000b
    and   ecx, 0000011111100000b
    shr   eax, 5
    shr   ecx, 5
    mov   ebx, ecx
    shl   ebx, 16
    sub   eax, ecx
    jns   @@nsg
    add   eax, -2
    or    ebx, 0FFFFh
  @@nsg:
    inc   eax
    shl   eax, 16
    cdq
    idiv  Size
    mov   Gdx, eax
    mov   Gval, ebx

    mov   eax, Color2
    mov   ecx, Color1
    and   eax, 0000000000011111b
    and   ecx, 0000000000011111b
    mov   ebx, ecx
    shl   ebx, 16
    sub   eax, ecx
    jns   @@nsb
    add   eax, -2
    or    ebx, 0FFFFh
  @@nsb:
    inc   eax
    shl   eax, 16
    cdq
    idiv  Size
    mov   Bdx, eax
    mov   Bval, ebx

 {; Fill Grad }
   mov   ecx, Size
   mov   edi, Dst

 @@Loop:
   xor   ebx, ebx

   mov   eax, Rval
   mov   edx, eax
   {;               1234123412341234 }
   and   eax, 0111110000000000000000b
   add   edx, Rdx
   shr   eax, 5
   or    ebx, eax
   mov   Rval, edx

   mov   eax, Gval
   mov   edx, eax
   {;                1234123412341234 }
   and   eax, 01111110000000000000000b
   add   edx, Gdx
   shr   eax, 11
   or    ebx, eax
   mov   Gval, edx

   mov   eax, Bval
   mov   edx, eax
   {;               1234123412341234 }
   and   eax, 0111110000000000000000b
   add   edx, Bdx
   shr   eax, 16
   or    ebx, eax
   mov   Bval, edx

   mov   ds:[edi], bx
   add   edi, 2
   loop  @@Loop
  pop   ebx
  pop   edi
  pop   esi
end;


procedure BMemGradient24(Dst, Size, Color1, Color2 : longword); assembler; stdcall;
VAR Rval,Gval,Bval,Rdx,Gdx,Bdx:longword;
asm
  push  esi
  push  edi
  push  ebx
{; Calc color DX }
    mov   eax, Color2
    mov   ecx, Color1
    and   eax, 0FF0000h
    and   ecx, 0FF0000h
    shr   eax, 16
    shr   ecx, 16
    mov   ebx, ecx
    shl   ebx, 16
    sub   eax, ecx
    jns   @@nsr
    add   eax, -2
    or    ebx, 0FFFFh
  @@nsr:
    inc   eax
    shl   eax, 16
    cdq
    idiv  Size
    mov   Rdx, eax
    mov   Rval, ebx

    mov   eax, Color2
    mov   ecx, Color1
    and   eax, 00FF00h
    and   ecx, 00FF00h
    shr   eax, 8
    shr   ecx, 8
    mov   ebx, ecx
    shl   ebx, 16
    sub   eax, ecx
    jns   @@nsg
    add   eax, -2
    or    ebx, 0FFFFh
  @@nsg:
    inc   eax
    shl   eax, 16
    cdq
    idiv  Size
    mov   Gdx, eax
    mov   Gval, ebx

    mov   eax, Color2
    mov   ecx, Color1
    and   eax, 0000FFh
    and   ecx, 0000FFh
    mov   ebx, ecx
    shl   ebx, 16
    sub   eax, ecx
    jns   @@nsb
    add   eax, -2
    or    ebx, 0FFFFh
  @@nsb:
    inc   eax
    shl   eax, 16
    cdq
    idiv  Size
    mov   Bdx, eax
    mov   Bval, ebx

 {; Fill Grad }
   mov   ecx, Size
   mov   edi, Dst

 @@Loop:
   xor   ebx, ebx

   mov   eax, Rval
   mov   edx, eax
   and   eax, 0FF0000h
   add   edx, Rdx
   or    ebx, eax
   mov   Rval, edx

   mov   eax, Gval
   mov   edx, eax
   and   eax, 0FF0000h
   add   edx, Gdx
   shr   eax, 8
   or    ebx, eax
   mov   Gval, edx

   mov   eax, Bval
   mov   edx, eax
   and   eax, 0FF0000h
   add   edx, Bdx
   shr   eax, 16
   or    ebx, eax
   mov   Bval, edx

   mov   eax, ebx
   shr   eax, 16

   mov   ds:[edi], bx
   mov   ds:[edi+ 2], al
   add   edi, 3
   loop  @@Loop
  pop   ebx
  pop   edi
  pop   esi

end;

procedure BMemGradient32(Dst, Size, Color1, Color2 : longword); assembler; stdcall;
VAR Rval,Gval,Bval,Rdx,Gdx,Bdx:longword;
asm
  push  esi
  push  edi
  push  ebx
{; Calc color DX }
    mov   eax, Color2
    mov   ecx, Color1
    and   eax, 0FF0000h
    and   ecx, 0FF0000h
    shr   eax, 16
    shr   ecx, 16
    mov   ebx, ecx
    shl   ebx, 16
    sub   eax, ecx
    jns   @@nsr
    add   eax, -2
    or    ebx, 0FFFFh
  @@nsr:
    inc   eax
    shl   eax, 16
    cdq
    idiv  Size
    mov   Rdx, eax
    mov   Rval, ebx

    mov   eax, Color2
    mov   ecx, Color1
    and   eax, 00FF00h
    and   ecx, 00FF00h
    shr   eax, 8
    shr   ecx, 8
    mov   ebx, ecx
    shl   ebx, 16
    sub   eax, ecx
    jns   @@nsg
    add   eax, -2
    or    ebx, 0FFFFh
  @@nsg:
    inc   eax
    shl   eax, 16
    cdq
    idiv  Size
    mov   Gdx, eax
    mov   Gval, ebx

    mov   eax, Color2
    mov   ecx, Color1
    and   eax, 0000FFh
    and   ecx, 0000FFh
    mov   ebx, ecx
    shl   ebx, 16
    sub   eax, ecx
    jns   @@nsb
    add   eax, -2
    or    ebx, 0FFFFh
  @@nsb:
    inc   eax
    shl   eax, 16
    cdq
    idiv  Size
    mov   Bdx, eax
    mov   Bval, ebx

 {; Fill Grad }
   mov   ecx, Size
   mov   edi, Dst

 @@Loop:
   xor   ebx, ebx

   mov   eax, Rval
   mov   edx, eax
   and   eax, 0FF0000h
   add   edx, Rdx
   or    ebx, eax
   mov   Rval, edx

   mov   eax, Gval
   mov   edx, eax
   and   eax, 0FF0000h
   add   edx, Gdx
   shr   eax, 8
   or    ebx, eax
   mov   Gval, edx

   mov   eax, Bval
   mov   edx, eax
   and   eax, 0FF0000h
   add   edx, Bdx
   shr   eax, 16
   or    ebx, eax
   mov   Bval, edx

   mov   ds:[edi], ebx
   add   edi, 4
   loop  @@Loop
  pop   ebx
  pop   edi
  pop   esi

end;


////// stretch  draw

procedure BMemStretch8 (Src, Dst, SSize, DSize :longword);  assembler; stdcall;
var x_dx:longword;
asm
  push  esi
  push  edi
  push  ebx
  mov  ecx, DSize    //  xinc := ( SSize shl 16 ) div DSize
  xor  edx, edx      //  step Dsize    Src (+ xinc)
  mov  ebx, ecx
  mov  eax, SSize
  shl  eax, 16
  div  ebx
  xor  edx, edx
  mov  ebx, edx
  mov  x_dx, eax
  mov  edi, Src
  mov  esi, Dst
@@looper:
    mov  al, ds:[edi + ebx]
    mov  ds:[esi], al
    add  edx, x_dx
    mov  ebx, edx
    shr  ebx ,16
    inc  esi
  loop  @@looper
  pop   ebx
  pop   edi
  pop   esi
end;


procedure BMemStretch1516 (Src, Dst, SSize, DSize :longword);  assembler; stdcall;
var x_dx:longword;
asm
  push  esi
  push  edi
  push  ebx
  mov  ecx, DSize    //  xinc := ( SSize shl 16 ) div DSize
  xor  edx, edx      //  step Dsize    Src (+ xinc)
  mov  ebx, ecx
  mov  eax, SSize
  shl  eax, 16
  div  ebx
  xor  edx, edx
  mov  ebx, edx
  mov  x_dx, eax
  mov  edi, Src
  mov  esi, Dst
@@looper:
    mov  ax, ds:[edi + ebx]
    mov  ds:[esi], ax
    add  edx, x_dx
    mov  ebx, edx
    shr  ebx, 16
    shl  ebx, 1
    add  esi, 2
  loop  @@looper
  pop   ebx
  pop   edi
  pop   esi
end;


procedure BMemStretch24 (Src, Dst, SSize, DSize :longword);  assembler; stdcall;
var x_dx:longword;
asm
  push  esi
  push  edi
  push  ebx
  mov  ecx, DSize    //  xinc := ( SSize shl 16 ) div DSize
  xor  edx, edx      //  step Dsize    Src (+ xinc)
  mov  ebx, ecx
  mov  eax, SSize
  shl  eax, 16
  div  ebx
  xor  edx, edx
  mov  ebx, edx
  mov  x_dx, eax
  mov  edi, Src
  mov  esi, Dst
@@looper:
    mov  eax, ds:[edi + ebx]
    and eax, 00FFFFFFh
    mov  ds:[esi], ax
    shr  eax, 16
    mov  ds:[esi + 2], al
    add  edx, x_dx
    mov  ebx, edx
    shr  ebx, 16
    lea  ebx, longword ptr [ebx + ebx*2]
    add  esi, 3
  loop  @@looper
  pop   ebx
  pop   edi
  pop   esi
end;


procedure BMemStretch32 (Src, Dst, SSize, DSize :longword);  assembler; stdcall;
var x_dx:longword;
asm
  push  esi
  push  edi
  push  ebx
  mov  ecx, DSize    //  xinc := ( SSize shl 16 ) div DSize
  xor  edx, edx      //  step Dsize    Src (+ xinc)
  mov  ebx, ecx
  mov  eax, SSize
  shl  eax, 16
  div  ebx
  xor  edx, edx
  mov  ebx, edx
  mov  x_dx, eax
  mov  edi, Src
  mov  esi, Dst
@@looper:
    mov  eax, ds:[edi + ebx]
    mov  ds:[esi], eax
    add  edx, x_dx
    mov  ebx, edx
    shr  ebx, 16
    shl  ebx, 2
    add  esi, 4
  loop  @@looper
  pop   ebx
  pop   edi
  pop   esi
end;


/// stretch draw color off
procedure BMemStretchKey8 (Src, Dst, SSize, DSize, Key :longword);  assembler; stdcall;
var x_dx:longword;
    c_off:byte;
asm
  push  esi
  push  edi
  push  ebx
  mov  ecx, DSize    //  xinc := ( SSize shl 16 ) div DSize
  xor  edx, edx      //  step Dsize    Src (+ xinc)
  mov  ebx, ecx
  mov  eax, SSize
  shl  eax, 16
  div  ebx
  xor  edx, edx
  mov  ebx, edx
  mov  x_dx, eax
  mov  edi, Src
  mov  esi, Dst
  mov  eax, Key
  mov  c_off, al
@@looper:
    mov  al, ds:[edi + ebx]
    cmp  al, c_off
    je   @@ByPass
      mov  ds:[esi], al
@@ByPass:
    add  edx, x_dx
    mov  ebx, edx
    shr  ebx ,16
    inc  esi
  loop  @@looper
  pop   ebx
  pop   edi
  pop   esi
end;


procedure BMemStretchKey1516 (Src, Dst, SSize, DSize, Key :longword);  assembler; stdcall;
var x_dx:longword;
    c_off:word;
asm
  push  esi
  push  edi
  push  ebx
  mov  ecx, DSize    //  xinc := ( SSize shl 16 ) div DSize
  xor  edx, edx      //  step Dsize    Src (+ xinc)
  mov  ebx, ecx
  mov  eax, SSize
  shl  eax, 16
  div  ebx
  xor  edx, edx
  mov  ebx, edx
  mov  x_dx, eax
  mov  edi, Src
  mov  esi, Dst
  mov  eax, Key
  mov  c_off, ax
@@looper:
    mov  ax, ds:[edi + ebx]
    cmp  ax, c_off
    je   @@ByPass
      mov  ds:[esi], ax
@@ByPass:
    add  edx, x_dx
    mov  ebx, edx
    shr  ebx, 16
    shl  ebx, 1
    add  esi, 2
  loop  @@looper
  pop   ebx
  pop   edi
  pop   esi
end;


procedure BMemStretchKey24 (Src, Dst, SSize, DSize, Key :longword);  assembler; stdcall;
var x_dx:longword;
    c_off:longword;
asm
  push  esi
  push  edi
  push  ebx
  mov  ecx, DSize    //  xinc := ( SSize shl 16 ) div DSize
  xor  edx, edx      //  step Dsize    Src (+ xinc)
  mov  ebx, ecx
  mov  eax, SSize
  shl  eax, 16
  div  ebx
  xor  edx, edx
  mov  ebx, edx
  mov  x_dx, eax
  mov  edi, Src
  mov  esi, Dst
  mov  eax, Key
  and  eax, 00FFFFFFh
  mov  c_off, eax
@@looper:
    mov  eax, ds:[edi + ebx]
    and  eax, 00FFFFFFh
    cmp  eax, c_off
    je   @@ByPass
      mov  ds:[esi], ax
      shr  eax, 16
      mov  ds:[esi + 2], al
@@ByPass:
    add  edx, x_dx
    mov  ebx, edx
    shr  ebx, 16
    lea  ebx, longword ptr [ebx + ebx*2]
    add  esi, 3
  loop  @@looper
  pop   ebx
  pop   edi
  pop   esi
end;


procedure BMemStretchKey32 (Src, Dst, SSize, DSize, Key :longword);  assembler; stdcall;
var x_dx:longword;
    c_off:longword;
asm
  push  esi
  push  edi
  push  ebx
  mov  ecx, DSize    //  xinc := ( SSize shl 16 ) div DSize
  xor  edx, edx      //  step Dsize    Src (+ xinc)
  mov  ebx, ecx
  mov  eax, SSize
  shl  eax, 16
  div  ebx
  xor  edx, edx
  mov  ebx, edx
  mov  x_dx, eax
  mov  edi, Src
  mov  esi, Dst
  mov  eax, Key
  mov  c_off, eax
@@looper:
    mov  eax, ds:[edi + ebx]
    cmp  eax, c_off
    je   @@ByPass
       mov  ds:[esi], eax
@@ByPass:
    add  edx, x_dx
    mov  ebx, edx
    shr  ebx, 16
    shl  ebx, 2
    add  esi, 4
  loop  @@looper
  pop   ebx
  pop   edi
  pop   esi
end;


// stretch alpha

procedure BMemStretchAlpha15 (Src, Dst, SSize, DSize, Alpha :longword);  assembler; stdcall;
var x_dx:longword;
    c_dx:longword;
    Col:longword;

asm
  push  esi
  push  edi
  push  ebx
  mov  ecx, DSize    //  xinc := ( SSize shl 16 ) div DSize
  xor  edx, edx      //  step Dsize    Src (+ xinc)
  mov  c_dx, edx
  mov  ebx, ecx
  mov  eax, SSize
  shl  eax, 16
  div  ebx
  mov  ebx, edx
  mov  x_dx, eax
  mov  esi, Src
  mov  edi, Dst
  mov  edx, Alpha
  and  edx, $FF
  shr  edx, 3
@@looper:

    movzx eax, word ptr ds:[esi]
    movzx ebx, word ptr ds:[edi]
    and   eax, 00000000000000000111110000011111b
    and   ebx, 00000000000000000111110000011111b
    sub   eax, ebx
    imul  eax, edx
    shr   eax, 5
    add   eax, ebx
    and   eax, 00000000000000000111110000011111b
    mov   Col, eax

    movzx eax, word ptr ds:[esi]
    movzx ebx, word ptr ds:[edi]
    and   eax, 00000000000000000000001111100000b
    and   ebx, 00000000000000000000001111100000b
    sub   eax, ebx
    imul  eax, edx
    shr   eax, 5
    add   eax, ebx
    and   eax, 00000000000000000000001111100000b

    or    eax, Col
    mov   ds:[edi], ax

    mov  esi, Src
    mov  eax, c_dx
    add  eax, x_dx
    mov  c_dx, eax
    shr  eax, 16
    shl  eax, 1
    add  esi, eax
    add  edi, 2
  loop  @@looper
  pop   ebx
  pop   edi
  pop   esi
end;


procedure BMemStretchAlpha16 (Src, Dst, SSize, DSize, Alpha :longword);  assembler; stdcall;
var x_dx:longword;
    c_dx:longword;
    Col:longword;
asm
  push  esi
  push  edi
  push  ebx
  mov  ecx, DSize    //  xinc := ( SSize shl 16 ) div DSize
  xor  edx, edx      //  step Dsize    Src (+ xinc)
  mov  c_dx, edx
  mov  ebx, ecx
  mov  eax, SSize
  shl  eax, 16
  div  ebx
  mov  ebx, edx
  mov  x_dx, eax
  mov  esi, Src
  mov  edi, Dst
  mov  edx, Alpha
  and  edx, $FF
  shr  edx, 3
@@looper:
    movzx eax, word ptr ds:[esi]
    movzx ebx, word ptr ds:[edi]
    and   eax, 00000000000000001111100000011111b
    and   ebx, 00000000000000001111100000011111b
    sub   eax, ebx
    imul  eax, edx
    shr   eax, 5
    add   eax, ebx
    and   eax, 00000000000000001111100000011111b
    mov   Col, eax

    shl   edx, 1
    movzx eax, word ptr ds:[esi]
    movzx ebx, word ptr ds:[edi]
    and   eax, 00000000000000000000011111100000b
    and   ebx, 00000000000000000000011111100000b
    sub   eax, ebx
    imul  eax, edx
    shr   eax, 6
    add   eax, ebx
    and   eax, 00000000000000000000011111100000b
    shr   edx, 1

    or    eax, Col

    mov   ds:[edi], ax

    mov  esi, Src
    mov  eax, c_dx
    add  eax, x_dx
    mov  c_dx, eax
    shr  eax, 16
    shl  eax, 1
    add  esi, eax
    add  edi, 2
  loop  @@looper
  pop   ebx
  pop   edi
  pop   esi
end;


procedure BMemStretchAlpha24 (Src, Dst, SSize, DSize, Alpha :longword);  assembler; stdcall;
var x_dx:longword;
    c_dx:longword;
    Col:longword;
asm
  push  esi
  push  edi
  push  ebx
  mov  ecx, DSize    //  xinc := ( SSize shl 16 ) div DSize
  xor  edx, edx      //  step Dsize    Src (+ xinc)
  mov  c_dx, edx
  mov  ebx, ecx
  mov  eax, SSize
  shl  eax, 16
  div  ebx
  mov  ebx, edx
  mov  x_dx, eax
  mov  esi, Src
  mov  edi, Dst
  mov  edx, Alpha
  and  edx, $FF
@@Looper:
    mov   eax, ds:[esi]
    mov   ebx, ds:[edi]
    and   eax, 0FF00FFh
    and   ebx, 0FF00FFh
    sub   eax, ebx
    imul  eax, edx
    shr   eax, 8
    add   eax, ebx
    and   eax, 0FF00FFh
    mov   Col, eax

    mov   eax, ds:[esi]
    mov   ebx, ds:[edi]
    and   eax, 000FF00h
    and   ebx, 000FF00h
    sub   eax, ebx
    imul  eax, edx
    shr   eax, 8
    add   eax, ebx
    and   eax, 000FF00h

    or    eax, Col

    mov   ds:[edi], ax
    shr   eax, 16
    mov   ds:[edi+ 2], al

    mov  esi, Src
    mov  eax, c_dx
    add  eax, x_dx
    mov  c_dx, eax
    shr  eax, 16
    lea  eax, longword ptr [eax + eax*2]
    add  esi, eax
    add  edi, 3
  loop  @@looper
  pop   ebx
  pop   edi
  pop   esi

end;

procedure BMemStretchAlpha24_mmx (Src, Dst, SSize, DSize, Alpha :longword);  assembler; stdcall;
var x_dx:longword;
    c_dx:longword;
asm
  push  esi
  push  edi
  push  ebx
  mov  ecx, DSize    //  xinc := ( SSize shl 16 ) div DSize
  xor  edx, edx      //  step Dsize    Src (+ xinc)
  mov  c_dx, edx
  mov  ebx, ecx
  mov  eax, SSize
  shl  eax, 16
  div  ebx
  mov  ebx, edx
  mov  x_dx, eax

  mov  esi, Src
  mov  edi, Dst

  mov   ebx, Alpha
  and   ebx, $FF

  pxor      mm7, mm7    // mm7 = 0
  mov       eax, ebx
  imul      eax, $00010001
  push      eax
  push      eax
  movq      mm6, [esp]  // mm6 - alpfa multip

  mov       eax, $00FF00FF
  push      eax
  push      eax
  mov       edx, $FFFFFF
  movq      mm5, [esp]  // mm5 - $00FF00FF00FF00FF

  push      edx
  movd      mm4, [esp]  // mm4 - $0000000000FFFFFF

  mov       eax, 255
  sub       eax, ebx // 255 - Alpha
  imul      eax, $00010001
  push      eax
  push      eax
  movq      mm3, [esp]  // mm3 - opaque alpha

@Loop:
  mov       eax, [esi]
  movd      mm0, eax    // get source
  mov       edx, [edi]
  punpcklbw mm0, mm7    // unpack lo byte in word
  movd      mm1, edx    // get destination
  pmullw    mm0, mm6
  pand      mm1, mm4

  punpcklbw mm1, mm7    // unpack lo byte in word
  pmullw    mm1, mm3
  paddw     mm0, mm1
  psrlq     mm0, 8

  pand      mm0, mm5    // cut garbage bytes
  and       edx, $FF000000
  packuswb  mm0, mm7    // pack

  movd      eax, mm0    // save
  or        eax, edx
  mov       [edi], eax

    mov  esi, Src
    mov  eax, c_dx
    add  eax, x_dx
    mov  c_dx, eax
    shr  eax, 16
    lea  eax, longword ptr [eax + eax*2]
    add  esi, eax
    add  edi, 3
  loop  @loop
  pop   ebx
  pop   edi
  pop   esi
  emms
end;


procedure BMemStretchAlpha32 (Src, Dst, SSize, DSize, Alpha :longword);  assembler; stdcall;
var x_dx:longword;
    c_dx:longword;
    Col:longword;
asm
  push  esi
  push  edi
  push  ebx
  mov  ecx, DSize    //  xinc := ( SSize shl 16 ) div DSize
  xor  edx, edx      //  step Dsize    Src (+ xinc)
  mov  c_dx, edx
  mov  ebx, ecx
  mov  eax, SSize
  shl  eax, 16
  div  ebx
  mov  ebx, edx
  mov  x_dx, eax
  mov  esi, Src
  mov  edi, Dst
  mov  edx, Alpha
  and  edx, $FF
@@Looper:
    mov   eax, ds:[esi]
    mov   ebx, ds:[edi]
    and   eax, 0FF00FFh
    and   ebx, 0FF00FFh
    sub   eax, ebx
    imul  eax, edx
    shr   eax, 8
    add   eax, ebx
    and   eax, 0FF00FFh
    mov   Col, eax

    mov   eax, ds:[esi]
    mov   ebx, ds:[edi]
    and   eax, 000FF00h
    and   ebx, 000FF00h
    sub   eax, ebx
    imul  eax, edx
    shr   eax, 8
    add   eax, ebx
    and   eax, 000FF00h
    or    eax, Col

    mov   ds:[edi], eax

    mov  esi, Src
    mov  eax, c_dx
    add  eax, x_dx
    mov  c_dx, eax
    shr  eax, 16
    shl  eax, 2
    add  esi, eax
    add  edi, 4
  loop  @@looper
  pop   ebx
  pop   edi
  pop   esi
end;


procedure BMemStretchAlpha32_mmx (Src, Dst, SSize, DSize, Alpha :longword);  assembler; stdcall;
var x_dx:longword;
    c_dx:longword;
asm
  push  esi
  push  edi
  push  ebx
  mov  ecx, DSize    //  xinc := ( SSize shl 16 ) div DSize
  xor  edx, edx      //  step Dsize    Src (+ xinc)
  mov  c_dx, edx
  mov  ebx, ecx
  mov  eax, SSize
  shl  eax, 16
  div  ebx
  mov  ebx, edx
  mov  x_dx, eax

  mov  esi, Src
  mov  edi, Dst
  mov   ebx, Alpha
  and   ebx, $FF

  pxor      mm7, mm7    // mm7 = 0
  mov       eax, ebx
  imul      eax, $00010001
  push      eax
  push      eax
  movq      mm6, [esp]  // mm6 - alpfa multip

  mov       eax, $00FF00FF
  push      eax
  push      eax
  mov       edx, $FFFFFF
  movq      mm5, [esp]  // mm5 - $00FF00FF00FF00FF

  push      edx
  movd      mm4, [esp]  // mm4 - $0000000000FFFFFF

  mov       eax, 255
  sub       eax, ebx // 255 - Alpha
  imul      eax, $00010001
  push      eax
  push      eax
  movq      mm3, [esp]  // mm3 - opaque alpha


@Loop:
  mov       eax, [esi]
  movd      mm0, eax    // get source
  mov       edx, [edi]
  punpcklbw mm0, mm7    // unpack lo byte in word
  movd      mm1, edx    // get destination
  pmullw    mm0, mm6
  punpcklbw mm1, mm7    // unpack lo byte in word

  pmullw    mm1, mm3
  paddw     mm0, mm1
  psrlq     mm0, 8

  pand      mm0, mm5    // cut garbage
  packuswb  mm0, mm7    // pack
  movd      [edi], mm0

    mov  esi, Src
    mov  eax, c_dx
    add  eax, x_dx
    mov  c_dx, eax
    shr  eax, 16
    shl  eax, 2
    add  esi, eax
    add  edi, 4
  loop  @loop
  pop   ebx
  pop   edi
  pop   esi
  emms
end;


///// stretch draw color off alpha put


procedure BMemStretchKeyAlpha15 (Src, Dst, SSize, DSize, Key, Alpha :longword);  assembler; stdcall;
var x_dx:longword;
    c_dx:longword;
    Col:longword;

asm
  push  esi
  push  edi
  push  ebx
  mov  ecx, DSize    //  xinc := ( SSize shl 16 ) div DSize
  xor  edx, edx      //  step Dsize    Src (+ xinc)
  mov  c_dx, edx
  mov  ebx, ecx
  mov  eax, SSize
  shl  eax, 16
  div  ebx
  mov  ebx, edx
  mov  x_dx, eax
  mov  esi, Src
  mov  edi, Dst
  mov  edx, Alpha
  and  edx, $FF
  shr  edx, 3
@@looper:

    mov   ebx, Key
    movzx eax, word ptr ds:[esi]
    cmp   ax, bx
    je    @@Next
    movzx ebx, word ptr ds:[edi]
    and   eax, 00000000000000000111110000011111b
    and   ebx, 00000000000000000111110000011111b
    sub   eax, ebx
    imul  eax, edx
    shr   eax, 5
    add   eax, ebx
    and   eax, 00000000000000000111110000011111b
    mov   Col, eax

    movzx eax, word ptr ds:[esi]
    movzx ebx, word ptr ds:[edi]
    and   eax, 00000000000000000000001111100000b
    and   ebx, 00000000000000000000001111100000b
    sub   eax, ebx
    imul  eax, edx
    shr   eax, 5
    add   eax, ebx
    and   eax, 00000000000000000000001111100000b

    or    eax, Col

    mov   ds:[edi], ax
@@Next:

    mov  esi, Src
    mov  eax, c_dx
    add  eax, x_dx
    mov  c_dx, eax
    shr  eax, 16
    shl  eax, 1
    add  esi, eax
    add  edi, 2
  loop  @@looper
  pop   ebx
  pop   edi
  pop   esi
end;


procedure BMemStretchKeyAlpha16 (Src, Dst, SSize, DSize, Key, Alpha :longword);  assembler; stdcall;
var x_dx:longword;
    c_dx:longword;
    Col:longword;
asm
  push  esi
  push  edi
  push  ebx
  mov  ecx, DSize    //  xinc := ( SSize shl 16 ) div DSize
  xor  edx, edx      //  step Dsize    Src (+ xinc)
  mov  c_dx, edx
  mov  ebx, ecx
  mov  eax, SSize
  shl  eax, 16
  div  ebx
  mov  ebx, edx
  mov  x_dx, eax
  mov  esi, Src
  mov  edi, Dst
  mov  edx, Alpha
  and  edx, $FF
  shr  edx, 3
@@looper:
    mov   ebx, Key
    movzx eax, word ptr ds:[esi]
    cmp   ax, bx
    je    @@Next
    movzx ebx, word ptr ds:[edi]
    and   eax, 00000000000000001111100000011111b
    and   ebx, 00000000000000001111100000011111b
    sub   eax, ebx
    imul  eax, edx
    shr   eax, 5
    add   eax, ebx
    and   eax, 00000000000000001111100000011111b
    mov   Col, eax

    shl   edx, 1
    movzx eax, word ptr ds:[esi]
    movzx ebx, word ptr ds:[edi]
    and   eax, 00000000000000000000011111100000b
    and   ebx, 00000000000000000000011111100000b
    sub   eax, ebx
    imul  eax, edx
    shr   eax, 6
    add   eax, ebx
    and   eax, 00000000000000000000011111100000b
    shr   edx, 1

    or    eax, Col

    mov   ds:[edi], ax
@@Next:

    mov  esi, Src
    mov  eax, c_dx
    add  eax, x_dx
    mov  c_dx, eax
    shr  eax, 16
    shl  eax, 1
    add  esi, eax
    add  edi, 2
  loop  @@looper
  pop   ebx
  pop   edi
  pop   esi
end;


procedure BMemStretchKeyAlpha24 (Src, Dst, SSize, DSize, Key, Alpha :longword);  assembler; stdcall;
var x_dx:longword;
    c_dx:longword;
    Col:longword;
asm
  push  esi
  push  edi
  push  ebx
  mov  ecx, DSize    //  xinc := ( SSize shl 16 ) div DSize
  xor  edx, edx      //  step Dsize    Src (+ xinc)
  mov  c_dx, edx
  mov  ebx, ecx
  mov  eax, SSize
  shl  eax, 16
  div  ebx
  mov  ebx, edx
  mov  x_dx, eax
  mov  esi, Src
  mov  edi, Dst
  mov  edx, Alpha
  and  edx, $FF
@@Looper:
    mov   ebx, Key
    mov   eax, ds:[esi]
    and   eax, 0FFFFFFh
    cmp   eax, ebx
    je    @@Next
    mov   ebx, ds:[edi]
    and   eax, 0FF00FFh
    and   ebx, 0FF00FFh
    sub   eax, ebx
    imul  eax, edx
    shr   eax, 8
    add   eax, ebx
    and   eax, 0FF00FFh
    mov   Col, eax

    mov   eax, ds:[esi]
    mov   ebx, ds:[edi]
    and   eax, 000FF00h
    and   ebx, 000FF00h
    sub   eax, ebx
    imul  eax, edx
    shr   eax, 8
    add   eax, ebx
    and   eax, 000FF00h

    or    eax, Col

    mov   ds:[edi], ax
    shr   eax, 16
    mov   ds:[edi+ 2], al

@@Next:

    mov  esi, Src
    mov  eax, c_dx
    add  eax, x_dx
    mov  c_dx, eax
    shr  eax, 16
    lea  eax, longword ptr [eax + eax*2]
    add  esi, eax
    add  edi, 3
  loop  @@looper
  pop   ebx
  pop   edi
  pop   esi

end;

procedure BMemStretchKeyAlpha24_mmx (Src, Dst, SSize, DSize, Key, Alpha :longword);  assembler; stdcall;
var x_dx:longword;
    c_dx:longword;
asm
  push  esi
  push  edi
  push  ebx
  mov  ecx, DSize    //  xinc := ( SSize shl 16 ) div DSize
  xor  edx, edx      //  step Dsize    Src (+ xinc)
  mov  c_dx, edx
  mov  ebx, ecx
  mov  eax, SSize
  shl  eax, 16
  div  ebx
  mov  ebx, edx
  mov  x_dx, eax

  mov  esi, Src
  mov  edi, Dst

  mov   ebx, Alpha
  and   ebx, $FF

  pxor      mm7, mm7    // mm7 = 0
  mov       eax, ebx
  imul      eax, $00010001
  push      eax
  push      eax
  movq      mm6, [esp]  // mm6 - alpfa multip

  mov       eax, $00FF00FF
  push      eax
  push      eax
  mov       edx, $FFFFFF
  movq      mm5, [esp]  // mm5 - $00FF00FF00FF00FF

  push      edx
  movd      mm4, [esp]  // mm4 - $0000000000FFFFFF

  mov       eax, 255
  sub       eax, ebx // 255 - Alpha
  imul      eax, $00010001
  push      eax
  push      eax
  movq      mm3, [esp]  // mm3 - opaque alpha

  mov       ebx, Key
  and       ebx, 0FFFFFFh

@Loop:
  mov       eax, [esi]
  and       eax, 0FFFFFFh
  cmp       eax, ebx
  jnz       @next
  jmp       @end
@Next:
  movd      mm0, eax    // get source
  mov       edx, [edi]
  punpcklbw mm0, mm7    // unpack lo byte in word
  movd      mm1, edx    // get destination
  pmullw    mm0, mm6
  pand      mm1, mm4

  punpcklbw mm1, mm7    // unpack lo byte in word
  pmullw    mm1, mm3
  paddw     mm0, mm1
  psrlq     mm0, 8

  pand      mm0, mm5    // cut garbage bytes
  and       edx, $FF000000
  packuswb  mm0, mm7    // pack

  movd      eax, mm0    // save
  or        eax, edx
  mov       [edi], eax
@End:
    mov  esi, Src
    mov  eax, c_dx
    add  eax, x_dx
    mov  c_dx, eax
    shr  eax, 16
    lea  eax, longword ptr [eax + eax*2]
    add  esi, eax
    add  edi, 3
  loop  @loop
  pop   ebx
  pop   edi
  pop   esi
  emms
end;


procedure BMemStretchKeyAlpha32 (Src, Dst, SSize, DSize, Key, Alpha :longword);  assembler; stdcall;
var x_dx:longword;
    c_dx:longword;
    Col:longword;
asm
  push  esi
  push  edi
  push  ebx
  mov  ecx, DSize    //  xinc := ( SSize shl 16 ) div DSize
  xor  edx, edx      //  step Dsize    Src (+ xinc)
  mov  c_dx, edx
  mov  ebx, ecx
  mov  eax, SSize
  shl  eax, 16
  div  ebx
  mov  ebx, edx
  mov  x_dx, eax
  mov  esi, Src
  mov  edi, Dst
  mov  edx, Alpha
  and  edx, $FF
@@Looper:
    mov   ebx, Key
    mov   eax, ds:[esi]
    and   eax, 0FFFFFFh
    cmp   eax, ebx
    je    @@Next
    mov   ebx, ds:[edi]
    and   eax, 0FF00FFh
    and   ebx, 0FF00FFh
    sub   eax, ebx
    imul  eax, edx
    shr   eax, 8
    add   eax, ebx
    and   eax, 0FF00FFh
    mov   Col, eax

    mov   eax, ds:[esi]
    mov   ebx, ds:[edi]
    and   eax, 000FF00h
    and   ebx, 000FF00h
    sub   eax, ebx
    imul  eax, edx
    shr   eax, 8
    add   eax, ebx
    and   eax, 000FF00h
    or    eax, Col

    mov   ds:[edi], eax
@@Next:
    mov  esi, Src
    mov  eax, c_dx
    add  eax, x_dx
    mov  c_dx, eax
    shr  eax, 16
    shl  eax, 2
    add  esi, eax
    add  edi, 4
  loop  @@looper
  pop   ebx
  pop   edi
  pop   esi
end;


procedure BMemStretchKeyAlpha32_mmx (Src, Dst, SSize, DSize, Key, Alpha :longword);  assembler; stdcall;
var x_dx:longword;
    c_dx:longword;
asm
  push  esi
  push  edi
  push  ebx
  mov  ecx, DSize    //  xinc := ( SSize shl 16 ) div DSize
  xor  edx, edx      //  step Dsize    Src (+ xinc)
  mov  c_dx, edx
  mov  ebx, ecx
  mov  eax, SSize
  shl  eax, 16
  div  ebx
  mov  ebx, edx
  mov  x_dx, eax

  mov  esi, Src
  mov  edi, Dst
  mov   ebx, Alpha
  and   ebx, $FF

  pxor      mm7, mm7    // mm7 = 0
  mov       eax, ebx
  imul      eax, $00010001
  push      eax
  push      eax
  movq      mm6, [esp]  // mm6 - alpfa multip

  mov       eax, $00FF00FF
  push      eax
  push      eax
  mov       edx, $FFFFFF
  movq      mm5, [esp]  // mm5 - $00FF00FF00FF00FF

  push      edx
  movd      mm4, [esp]  // mm4 - $0000000000FFFFFF

  mov       eax, 255
  sub       eax, ebx // 255 - Alpha
  imul      eax, $00010001
  push      eax
  push      eax
  movq      mm3, [esp]  // mm3 - opaque alpha

  mov       ebx, Key
  and       ebx, 0FFFFFFh

@Loop:
  mov       eax, [esi]
  and       eax, 0FFFFFFh
  cmp       eax, ebx
  jnz       @next
  jmp       @end
@Next:
  movd      mm0, eax    // get source
  mov       edx, [edi]
  punpcklbw mm0, mm7    // unpack lo byte in word
  movd      mm1, edx    // get destination
  pmullw    mm0, mm6
  punpcklbw mm1, mm7    // unpack lo byte in word

  pmullw    mm1, mm3
  paddw     mm0, mm1
  psrlq     mm0, 8

  pand      mm0, mm5    // cut garbage
  packuswb  mm0, mm7    // pack
  movd      [edi], mm0
@End:

    mov  esi, Src
    mov  eax, c_dx
    add  eax, x_dx
    mov  c_dx, eax
    shr  eax, 16
    shl  eax, 2
    add  esi, eax
    add  edi, 4
  loop  @loop
  pop   ebx
  pop   edi
  pop   esi
  emms
end;



// mask is 4 byte align
procedure BMemMaskBlt8(Src,Dst,Size,Mask,Skip:longword) assembler; stdcall;
asm
  push  esi
  push  edi
  push  ebx
    mov   edx, 080000000h
    mov   ecx, skip
    ror   edx, cl
    mov   esi, Src
    mov   edi, Dst
    mov   ebx, Mask
    mov   ecx, Size
  @NextPixel:
    mov   eax, ds:[ebx]
    and   eax, edx
    jz    @noPoint
    mov   al, ds:[esi]
    mov   ds:[edi], al
  @noPoint:
    inc   esi
    inc   edi
    ror   edx, 1
    jnc   @noNextMask
    add   ebx, 4
  @noNextMask:
    loop  @NextPixel
  pop   ebx
  pop   edi
  pop   esi
end;

procedure BMemMaskBlt1516(Src,Dst,Size,Mask,Skip:longword) assembler; stdcall;
asm
  push  esi
  push  edi
  push  ebx
    mov   edx, 080000000h
    mov   ecx, skip
    ror   edx, cl
    mov   esi, Src
    mov   edi, Dst
    mov   ebx, Mask
    mov   ecx, Size
  @NextPixel:
    mov   eax, ds:[ebx]
    and   eax, edx
    jz    @noPoint
    mov   ax, ds:[esi]
    mov   ds:[edi], ax
  @noPoint:
    add   esi, 2
    add   edi, 2
    ror   edx, 1
    jnc   @noNextMask
    add   ebx, 4
  @noNextMask:
    loop  @NextPixel
  pop   ebx
  pop   edi
  pop   esi
end;

procedure BMemMaskBlt24(Src,Dst,Size,Mask,Skip:longword) assembler; stdcall;
asm
  push  esi
  push  edi
  push  ebx
    mov   edx, 080000000h
    mov   ecx, skip
    ror   edx, cl
    mov   esi, Src
    mov   edi, Dst
    mov   ebx, Mask
    mov   ecx, Size
  @NextPixel:
    mov   eax, ds:[ebx]
    and   eax, edx
    jz    @noPoint
    mov   ax, ds:[esi]
    mov   ds:[edi], ax
    mov   al, ds:[esi+2]
    mov   ds:[edi+2], al
  @noPoint:
    add   esi, 3
    add   edi, 3
    ror   edx, 1
    jnc   @noNextMask
    add   ebx, 4
  @noNextMask:
    loop  @NextPixel
  pop   ebx
  pop   edi
  pop   esi
end;

procedure BMemMaskBlt32(Src,Dst,Size,Mask,Skip:longword) assembler; stdcall;
asm
  push  esi
  push  edi
  push  ebx
    mov   edx, 080000000h
    mov   ecx, skip
    ror   edx, cl
    mov   esi, Src
    mov   edi, Dst
    mov   ebx, Mask
    mov   ecx, Size
  @NextPixel:
    mov   eax, ds:[ebx]
    and   eax, edx
    jz    @noPoint
    mov   eax, ds:[esi]
    mov   ds:[edi], eax
  @noPoint:
    add   esi, 4
    add   edi, 4
    ror   edx, 1
    jnc   @noNextMask
    add   ebx, 4
  @noNextMask:
    loop  @NextPixel
  pop   ebx
  pop   edi
  pop   esi
end;


procedure BMemTrueAlpha32(Src, Dst, Size : longword); assembler; stdcall;
Var Col:longword;
asm
  push  esi
  push  edi
  push  ebx
  mov   ecx, Size
  mov   esi, Src
  mov   edi, Dst
@Loop:
    mov   eax, ds:[esi]
    mov   edx, eax
    shr   edx, 24
    mov   ebx, ds:[edi]
    and   eax, 0FF00FFh
    and   ebx, 0FF00FFh
    sub   eax, ebx
    imul  eax, edx
    shr   eax, 8
    add   eax, ebx
    and   eax, 0FF00FFh
    mov   Col, eax

    mov   eax, ds:[esi]
    mov   ebx, ds:[edi]
    and   eax, 000FF00h
    and   ebx, 000FF00h
    sub   eax, ebx
    imul  eax, edx
    shr   eax, 8
    add   eax, ebx
    and   eax, 000FF00h
    or    eax, Col

    mov   ds:[edi], eax
    add   esi, 4
    add   edi, 4
  loop  @Loop
  pop   ebx
  pop   edi
  pop   esi
end;






/// Texture drawer   { not finishet yet !!!! }
procedure BMemLinTexture1516(Src, Dst, Size, U1, V1, U2, V2, Xl, DXL :longword); assembler; stdcall;
var du,dv:longword;
asm
    mov   eax, U2
    mov   ebx, U1
    mov   ecx, ebx
    shl   ecx, 16
    sub   eax, ebx
    jns   @@nsu
    add   eax, -2
    or    ecx, 0FFFFh
   @@nsu:
    mov   ebx, Size
    inc   eax
    shl   eax, 16
    cdq
    idiv  ebx
    mov   du, eax

    push  ecx

    mov   eax, V2
    mov   ebx, V1
    mov   ecx, ebx
    shl   ecx, 16
    sub   eax, ebx
    jns   @@nsv
    add   eax, -2
    or    ecx, 0FFFFh
   @@nsv:
    mov   ebx, Size
    inc   eax
    shl   eax, 16
    cdq
    idiv  ebx
    mov   dv, eax

    mov   edx, ecx
    pop   ecx

    mov   edi, Dst
    mov   esi, Src

   @@Loop:
    mov   ebx, ecx
    mov   eax, edx
    shr   ebx, 16
    imul  ebx, xl
    shr   eax, 16
    add   ebx, eax
    mov   bx, ds:[esi+ebx*2]
    add   edx, du
    mov   ds:[edi], bx
    add   ecx, dv
    add   edi, dxl   { //;2  destination xl step  xlng=vertical 1=horizontal }
    dec   Size
    jnz   @@Loop
end;

procedure BMemLinTexture32(Src, Dst, Size, U1, V1, U2, V2, Xl, DXL :longword); assembler; stdcall;
var du,dv:longword;
asm
    mov   eax, U2
    mov   ebx, U1
    mov   ecx, ebx
    shl   ecx, 16
    sub   eax, ebx
    jns   @@nsu
    add   eax, -2
    or    ecx, 0FFFFh
   @@nsu:
    mov   ebx, Size
    inc   eax
    shl   eax, 16
    cdq
    idiv  ebx
    mov   du, eax

    push  ecx

    mov   eax, V2
    mov   ebx, V1
    mov   ecx, ebx
    shl   ecx, 16
    sub   eax, ebx
    jns   @@nsv
    add   eax, -2
    or    ecx, 0FFFFh
   @@nsv:
    mov   ebx, Size
    inc   eax
    shl   eax, 16
    cdq
    idiv  ebx
    mov   dv, eax

    mov   edx, ecx
    pop   ecx

    mov   edi, Dst
    mov   esi, Src

   @@Loop:
    mov   ebx, ecx
    mov   eax, edx
    shr   ebx, 16
    imul  ebx, xl
    shr   eax, 16
    add   ebx, eax
    mov   ebx, ds:[esi+ebx*4]
    add   edx, du
    mov   ds:[edi], ebx
    add   ecx, dv
    add   edi, dxl   { //;2  destination xl step  xlng=vertical 1=horizontal }
    dec   Size
    jnz   @@Loop

    ///
    // struct    des             + 0
    //           size            + 4
    //           src             + 8
    //           u               + 12
    //           v               + 16
    //           w               + 20
    //           du              + 24
    //           dv              + 28
    //           dw              + 32
    //           xl              + 36
    //           const (10000h)  + 40
    //           color off       + 44
    //           Alpha           + 48
    //           c               + 52
    //           dc              + 56
    //           a1              + 60
    //           a2              + 64
    //           a3              + 68
    //           a4              + 72

    // Perspective-correct
  push  esi
  push  edi
  push  ebx

//    mov   ecx, TheUVstruct
    mov   esi, ds:[ecx + 8] {src}
    mov   edx, ds:[ecx + 4] {size}
@@Looper:
    push  edx
    xor   eax, eax
    mov   edx, 1
    idiv  longword ptr ds:[ecx + 20] {w}

    mov   ebx, eax
    mov   eax, ds:[ecx + 16] {v}
    imul  ebx
    idiv  longword ptr ds:[ecx + 40] {const}
    shr   eax, 16
    imul  longword ptr ds:[ecx + 36] {xl}
    mov   edi, eax

    mov   eax, ds:[ecx + 12] {u}
    imul  ebx
    idiv  longword ptr ds:[ecx + 40] { const }
    shr   eax, 16
    add   eax, edi

    mov   edi, ds:[ecx]  {des}
    mov   al, ds:[esi + eax]
    mov   ds:[edi], al
    inc   edi
    mov   ds:[ecx], edi  {des}

    mov   eax, ds:[ecx + 24]   {du}
    add   ds:[ecx + 12] , eax  {u}
    mov   eax, ds:[ecx + 28]   {dv}
    add   ds:[ecx + 16] , eax  {v}
    mov   eax, ds:[ecx + 32]   {dw}
    add   ds:[ecx + 20] , eax  {w}

    pop   edx
    dec   edx
    jnz   @@Looper

end;

*)
end.
