unit BKbdSwitch;

interface

function  kbd_GetRegionLocalisation:string;
function  kbd_GetIsInstaledCiryllic:boolean;
procedure kbd_SetLatinKeyboard;
procedure kbd_SetCiryllicKeyboard;
procedure kbd_SwichKayboard;
function  kbd_GetActiveKeyboard:longword;
function  kbd_GetKeyboardCount:longword;
function  kbd_GetKeyboardName(i:longword):string;
procedure kbd_ForceEnglis(a:longword);
procedure kbd_ForceCiryllic(a:longword);
function  kbd_GetCiryllicCnt:longword;
function  kbd_GetActiveKayboarID:longword;


implementation

uses
  Windows,Bregistry,BStrTools;

var
    langs:longword;
    haveCyr:boolean;
    wa:array[1..10] of longword;
    wacnt:longword;
    bs:string;
    was:array[1..10] of longword;
    wass:array[1..10] of string;
    wac:array[1..10] of longword; //cyr
    english:longword;
    bulgarian:longword;


function GetWindowsLanguage2(LCTYPE: LCTYPE {type of information}): string;
var
  Buffer : PChar;
  Size : integer;
begin
  Size := GetLocaleInfo (LOCALE_USER_DEFAULT, LCType, nil, 0);
  GetMem(Buffer, Size);
  try
    GetLocaleInfo (LOCALE_USER_DEFAULT, LCTYPE, Buffer, Size);
    Result := string(Buffer);
  finally
    FreeMem(Buffer);
  end;
end;


procedure _Analyzer;
var f,n:longword;
    k :boolean;
    some:longword;
    aaaa:string;
    pc:pchar;
begin                                            //1026 - kirilica
   haveCyr := false;                             //1033 - usa
   wacnt := 0;                                   //2057 - uk
                                                 // 1026-1026 bds
   langs := 0;                                              // 1026-     driga kirilica
   some := 1033;
   bulgarian := 0;
   english := 0;
   f := GetKeyBoardLayout(0) ; // get first
   n := f;
   repeat
      inc(langs);
      inc(wacnt);
      wa[wacnt] := n and $FFFF;
      if wa[wacnt] = 1026 then
      begin
         haveCyr := true;
         wac[wacnt] := 1;
         if bulgarian = 0 then bulgarian := n;
      end else begin
         some := n;  // some language
         if wa[wacnt]=1033 then english := n; // usa
         if wa[wacnt]=2057 then english := n; // uk
         wac[wacnt] := 0;
      end;

      was[wacnt] := n;
      n := n and $FFFFF;
      wass[wacnt] := ''+#0;
   //   if wa[wacnt] = (n shr 16) then n := n and $FFFF;
//   HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Keyboard Layouts
      aaaa := '                                                                                      '+#0;
      pc := @aaaa[1];
      GetKeyBoardLayoutName(pc);

//      aaaa := ansistring(ToHex(n,8));
      k := Reg_ReadKey( $80000002 {HKEY_LOCAL_MACHINE},
                  'SYSTEM\CurrentControlSet\Control\Keyboard Layouts\'+aaaa,
                  'Layout Text',
                  wass[wacnt]);
      if k = false  then
      begin
          n := n and $FFFF;
//   HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Keyboard Layouts
          aaaa := ToHex(n,8);
          Reg_ReadKey( $80000002 {HKEY_LOCAL_MACHINE},
                     'SYSTEM\CurrentControlSet\Control\Keyboard Layouts\'+aaaa,
                     'Layout Text',
                  wass[wacnt]);
      end;
      if length(wass[wacnt]) < 2 then wass[wacnt] := 'Undef';

      wass[wacnt] := wass[wacnt] + #0;

      ActivateKeyboardLayout(HKL_NEXT,$100) ;//KLF_SETFORPROCESS);
      n := GetKeyBoardLayout(0); // next
   until (n = f) or (wacnt = 10);
   if english = 0 then english := some;
   if bulgarian = 0 then bulgarian := english;

   bs := GetWindowsLanguage2(LOCALE_SENGLANGUAGE);
end;

//------------------------------------------------------------------------------
function kbd_GetRegionLocalisation:string;
begin
   Result := bs;
end;

//------------------------------------------------------------------------------
function kbd_GetIsInstaledCiryllic:boolean;
begin
   Result := HaveCyr;
end;

//------------------------------------------------------------------------------
procedure kbd_SetLatinKeyboard;
begin
   ActivateKeyboardLayout(english,$100);
end;

//------------------------------------------------------------------------------
procedure kbd_SetCiryllicKeyboard;
begin
   if HaveCyr then ActivateKeyboardLayout(bulgarian,$100);
end;

//------------------------------------------------------------------------------
procedure kbd_SwichKayboard;
var f:longword;
begin
   f := GetKeyBoardLayout(0);
   if (f and $ffff) = 1026 then kbd_SetLatinKeyboard
                           else kbd_SetCiryllicKeyboard;
end;

//------------------------------------------------------------------------------
function kbd_GetActiveKeyboard:longword;
var f:longword;
begin
   Result := 0;
   f := GetKeyBoardLayout(0);
   if (f and $ffff) = 1026 then Result := 1;
end;

//------------------------------------------------------------------------------
function kbd_GetKeyboardCount:longword;
begin
   Result := langs;
end;

//------------------------------------------------------------------------------
const
 outofrange :string = 'out of range error'+#0;

function kbd_GetKeyboardName(i:longword):string;
begin
   Result := outofrange;

   if (i > 0) and (i <= langs) then
   begin
      Result := wass[i];
   end;
end;

//------------------------------------------------------------------------------
procedure kbd_ForceEnglis(a:longword);
begin
   if (a > 0) and (a <= langs) then
   begin
      english := was[a];
   end;
end;

//------------------------------------------------------------------------------
procedure kbd_ForceCiryllic(a:longword);
begin
   if (a > 0) and (a <= langs) then
   begin
      bulgarian := was[a];
   end;
end;

//------------------------------------------------------------------------------
function kbd_GetCiryllicCnt:longword;
var i:longword;
begin
   Result := 0;
   if HaveCyr then
   begin
      for i := 1 to wacnt do
      begin
         if wac[i] = 1 then Result := Result + 1;
      end;
    end;
end;

//------------------------------------------------------------------------------
function kbd_GetActiveKayboarID:longword;
var f,n:longword;
begin
   Result := 0 ;
   f := GetKeyBoardLayout(0);
   for n:= 1 to langs do
   begin
      if was[n]  = f then Result := n;
   end;
end;






begin
   _Analyzer;
end.
