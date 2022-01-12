unit BBasic_v1;
{
  version 1RC
  TODO :)
   - Optimize or rewrite stack


read map
   - if then else end if
   - in [ ]
   - chars
   - invoke DLL
   - subroutine call  functions CALL SUB FUNC RETURN
   - JIT compiler


print(input + Nl)
e = val(input) + 2
a$ = 'Hello'
b$ = a$ + ' ' + "Bogi"
print(b$ + ' '+str(e)+ Nl)
a = 2
on a gosub koko, boko
a = a + 5
if a > 6 then goto cici
print('dont see me')
cici:
print (NL + 'Ater Jump' + nl)
k# = 1
for i = 1 to 2
   for j = 1 to 5
      print('/'+str(k#)+'='+str(i)+'*'+str(j)+' ')
      k# = k# + 1
   next
next
print(NL)

dim p[7]
p[2] = Pi * sin(23.4) - 4.7
p[3] = sin(23.4)
print(str(p[2])+NL)
print(str(p[3])+NL)
end
    koko:
        print ('Koko') : return
   boko:
       print ('Boko')
       return

}

interface

uses Windows;

Const
      MAX_IDENT_SIZE = 32;
type
      BTSB_IdentItem = record
         Hash     : longword;
         Name     : string[MAX_IDENT_SIZE];
         Typ      : longword;
         Complex  : string[MAX_IDENT_SIZE];
         Base     : longword;
         Data     : longword;
      end;
      BTSB_Idents = array [0..0] of BTSB_IdentItem;
      BTSB_PIdents = ^BTSB_Idents;

      BTSB_PStr = ^string;
      BTSB_VarItem = record
         case Integer of
         1 : (I : longint);
         2 : (R : single);
         3 : (S : BTSB_PStr);
      end;
      BTSB_Vars = array [0..0] of BTSB_VarItem;
      BTSB_PVars = ^BTSB_Vars;



      BTSmallBasic = class
         private
            { Parser variables }
            Prog        : ^string;
            _NewRow     : longword;
            _Offset     : longword;
            _PreOffset  : longword;
            Token_Data  : string;
            Token       : longint;
            Token_SubType : longword;

            { Identifiers }
            _Idents     : BTSB_PIdents;
            _IdentCapacity : longword;
            _IdentCount : longword;
            _LocalIdentsCount : longword;
            { Variables }
            _Vars       : BTSB_PVars;
            _VarsCapacity : longword;
            _VarsCount  : longword;

            { Stack }
            Stack       : pointer;
            StackTop    : longword;

            { Sbasic variables }
            Script      : string;
            Labels_offset : longword;
            Data_offset   : longword;
            Data_offset_copy : longword;
            Data_C_offset : longword;
            Data_Cnt    : longword;
            On_jump     : longword;
            Expr_dovar  : boolean;

            Error       : longint;
            ErrorOfs    : longword;
            ErrorD      : longword;

            procedure   SetError(Op:longint);
            procedure   initrtl;
            function    variable(var V:longword) : boolean;
            function    expresion(var V:longword) : boolean;
            function    func(var V:longword) : boolean;
            function    gotolabel(lbl:string) : boolean;
            function    getlabel(var lbl:string):boolean;
            procedure   IntegerToReal(var s,d:longword);
            procedure   RealToInteger(var s,d:longword);
            procedure   FreePStr(V:longword);
            procedure   _ON;
            procedure   _IF;
            procedure   _FOR;
            procedure   _NEXT;
            procedure   _GOTO;
            procedure   _GOSUB;
            procedure   _RETURN;
            procedure   _READ;
            procedure   _RESET;
            procedure   _TEXT;
            procedure   _DIM;
            { Parser functions }
            procedure   ResetParser(var script:string);
            function    NextChar: Char;
            function    PeekNextChar: Char;
            function    NextToken:longint;
            procedure   ToNextLine;
            function    MatchToken(needToken:longint; Explicit:boolean; ErrorCode:longint):boolean;
            procedure   expectDelimiter;            
            { Identifier functions }
            function    Init_Idents:longint;
            procedure   Close_Idents;
            function    FindIdent(TheName:string):longword;
            function    Ident(TheName:string; asize:longword):longword;
            function    GetLocalIdent(var P :longword):boolean;
            { Stack functions }
            procedure   Init_Stack;
            procedure   Close_Stack;
            function    Push:boolean;
            procedure   Pop;
            procedure   Stack_ReturnPos;
         public
            OutPut      : string;
            InPut       : string;
            constructor Create;
            destructor  Destroy; override;
            procedure   Reset;
            function    Run:longint;
            procedure   Load(txt: string);
            function    LoadFromFile(file_name: string): longint;
            function    GetError:string;
            procedure   RegisterFunction(Name, Args, Retval:string; The_Func :pointer; Ext:longword);
      end;




{==============================================================================}
implementation

const
   MAX_STACK_SIZE = 64;
   MAX_PARAM_COUNT = 8;

const   // ERRORS
   err_Unrecognized_word               = -1;
   err_Too_Big_Integer                 = -2;
   err_Bad_hex_constant                = -3;
   err_Unfinished_real_constant        = -4;
   err_Unterminated_string_constant    = -5;
   err_Internal_error                  = -6;
   err_Variable_Name_Expected          = -7;
   err_Arrays_are_non_AutoDef          = -8;
   err_Divide_by_zero                  = -9;
   err_Expected_Close_Bracket          = -10;
   err_Type_Mismatch                   = -11;
   err_Expected_Equal                  = -12;
   err_Operator_not_support_this_type  = -13;
   err_Expected_open_bracket           = -14;
   err_Need_Boolean_Result             = -15;
   err_Expected_THEN                   = -16;
   err_Need_Integer_Value              = -17;
   err_Stack_Overload                  = -19;
   err_Next_Without_For                = -20;
   err_Uncorrect_Stack_Levels          = -21;
   err_Return_Without_Gosub            = -22;
   err_Expected_Goto_or_Gosub          = -23;
   err_Undefined_Label                 = -24;
   err_Label_Not_Found                 = -25;
   err_Expected_Label                  = -26;
   err_Expected_Comma                  = -27;
   err_Param_Diferent_type             = -28;
   err_No_data_to_read                 = -29;
   err_Expected_Variable               = -30;
   err_No_more_data_to_read            = -31;
   err_Variable_in_Data                = -32;
   err_Expected_To                     = -33;
   err_Reserved_Word                   = -34;
   err_This_var_is_array               = -35;
   err_Expected_Close_Index            = -36;
   err_Expected_Open_Index_mark        = -37;
   err_Too_many_array_levels           = -38;
   err_Too_Big_Array                   = -40;
   err_Only_positive_values            = -41;
   err_Outside_of_dimension            = -42;
   err_Expected_delimiter              = -43;

const
   TYP_STRING       = 1;
   TYP_INTEGER      = 2;
   TYP_REAL         = 3;
   TYP_UNDEF        = 0;


const
   TOKEN_EOF        = 0;
// TOKEN_IF         = 1; { must the the first command }
   TOKEN_NUMBER     = 2048;
   TOKEN_STRING     = 2049;
   TOKEN_TEXT       = 2050;
   TOKEN_UNKNOWN    = 2051;

   CMD_count = 40;
   CMD : array [1..CMD_count] of string = (
   { 1}'IF',      { 2}'THEN',    { 3}'END',     { 4}'FOR',     { 5}'TO',
   { 6}'STEP',    { 7}'NEXT',    { 8}'DATA',    { 9}'RESET',   {10}'READ',
   {11}'GOTO',    {12}'GOSUB',   {13}'ON',      {14}'RETURN',  {15}'REM',
   {16}'OR',      {17}'AND',     {18}'NOT',     {19}'XOR',     {20}'DIM',
   {21}'SHR',     {22}'SHL',     {23}'+',       {24}'-',       {25}'*',
   {26}'/',       {27}'%',       {28}'^',       {29}'(',       {30}')',
   {31}',',       {32}':',       {33}'<>',      {34}'>=',      {35}'<=',
   {36}'=',       {37}'>',       {38}'<',       {39}'[',       {40}']'
   );

   C_IF             = 1;
   C_THEN           = 2;
   C_END            = 3;
   C_FOR            = 4;
   C_TO             = 5;
   C_STEP           = 6;
   C_NEXT           = 7;
   C_DATA           = 8;
   C_RESET          = 9;
   C_READ           = 10;
   C_GOTO           = 11;
   C_GOSUB          = 12;
   C_ON             = 13;
   C_RETURN         = 14;
   C_REM            = 15;
   C_OR             = 16;
   C_AND            = 17;
   C_NOT            = 18;
   C_XOR            = 19;
   C_DIM            = 20;
   C_SHR            = 21;
   C_SHL            = 22;
   C_PLUS           = 23;
   C_MINUS          = 24;
   C_MULTIPLY       = 25;
   C_DIVIDE         = 26;
   C_MODULE         = 27;
   C_POWER          = 28;
   C_OPENBRACKET    = 29;
   C_CLOSEBRACKET   = 30;
   C_COMMA          = 31;
   C_DELIMITER      = 32;
   C_NOTEQUAL       = 33;
   C_GREATEQUAL     = 34;
   C_LESSEQUAL      = 35;
   C_EQUAL          = 36;
   C_GREAT          = 37;
   C_LESS           = 38;
   C_OPENINDEX      = 39;
   C_CLOSEINDEX     = 40;

   C_LABEL          = 41;

//   C_DELIMITER_CHAR = ':';

   EXPLICIT         = TRUE;
   NOT_EXPLICIT     = FALSE;

{----- P A R S E R ------------------------------------------------------------}


procedure   BTSmallBasic.ResetParser(var script:string);
begin
   _Offset := 1;
   _PreOffset := 1;
   Prog := @Script;
end;

{------------------------------------------------------------------------------}
function    BTSmallBasic.NextChar: Char;
var _LastChar:char;
begin
   if Prog^[_Offset] = #27 then inc(_Offset,5);
   if Prog^[_Offset] = #28 then inc(_Offset,5);

  _LastChar := #0;
   if Prog^[_Offset] <> #0 then
   begin
      _LastChar := Prog^[_Offset];
      Inc (_Offset);
      if _LastChar = #13 then _NewRow := 1; if Prog^[_Offset] = #10 then inc(_Offset);
   end;
   NextChar := _LastChar;
end;

{------------------------------------------------------------------------------}
function    BTSmallBasic.PeekNextChar: Char;
var res:char;
    p:longword;
begin
   p := _Offset;
   if Prog^[_Offset] = #27 then inc(_Offset,5);
   if Prog^[_Offset] = #28 then inc(_Offset,5);

   res := #0;
   if Prog^[_Offset] <> #0 then
   begin
      res := Prog^[_Offset];
   end;

   _Offset := p;
   PeekNextChar := res;
end;

{------------------------------------------------------------------------------}
procedure   BTSmallBasic.ToNextLine;
var C:char;
begin
   repeat C := NextChar; until C in [#0,#13];
   if C = #13 then if PeekNextChar = #10 then NextChar;
   NextToken;
end;


{------------------------------------------------------------------------------}
{ Tool for parser }
function    BTSmallBasic.MatchToken(needToken:longint; Explicit:boolean; ErrorCode:longint):boolean;
begin
   if needToken = Token then
   begin
      NextToken;
      Result := True;
   end else begin
      if Explicit then
      begin
         SetError(ErrorCode); // todo  Expected
      end;
      Result := false;
   end;
end;

{------------------------------------------------------------------------------}
procedure   BTSmallBasic.expectDelimiter;
var C:char;
    D:longword;
begin
   D := 0;
   if (Token = C_DELIMITER) then
   begin
      NextToken;
      D := 1;
   end else begin
      if (Token = TOKEN_EOF) or ( _NewRow = 1) then D := 1;
   end;
   if D = 0 then SetError(err_Expected_delimiter);
end;

{------------------------------------------------------------------------------}
function    BTSmallBasic.NextToken:longint;
var C,QC:char;
    I:longword;

   {..............................}
   { first biger then small  '>=|>'                              }
   function    Look_up(test_token:string):longword;
   var i:longword;
   begin
      Result := 0;
      for i := 1 to CMD_count do
      begin
         if Cmd[i] = test_token then
         begin
            Result := i;
            break;
         end;
      end;
   end;
   {..............................}
   const hexdigit:array[0..15]of char = ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F');

   function HEXval(s:string):longword;
   var res,i,j,k,l:longword;
   begin
      res := 0;
      j := length(s);
      if j > 0 then
      begin
         for i := 1 to j do
         begin
            res := res shl 4;
            l:=0;
            for k := 0 to 15 do if hexdigit[k] = s[i] then l:=k;
            res := res + l;
         end;
      end;
      HEXval := res;
   end;
   {..............................}

begin
   Token := TOKEN_EOF;  // Token
   Token_Data := '';
   if _Offset = 1 then _NewRow := 1  // in the begining
                  else _NewRow := 0;

   _PreOffset := _Offset;
   C := NextChar;
   while C in [#1..' '] do
   begin
      _PreOffset := _Offset;
      C := NextChar;
   end;

   case C of
      #0 : Token := TOKEN_EOF;
      { group of numbers }
      '0'..'9': begin
              if (PeekNextChar in ['X','x']) then
//TODO
                begin
                   NextChar; { bypass  X}
                   i := 0;
                   while True do begin
                      if not(PeekNextChar in ['0'..'9', 'A'..'F', 'a'..'f']) then Break;
                      inc(i);
                      C := NextChar;
                      Token_Data := Token_Data + C;
                   end;
                   if i > 8 then begin Token := err_Too_Big_Integer; Result := Token; Exit; end;
                   if Token_Data = '' then begin Token := err_Bad_hex_constant; Result := Token; Exit; end;
                   Str(Hexval(Token_Data),Token_Data);
                   Token_SubType := TYP_INTEGER;
                end else begin
                   { integer }
                   Token_SubType := TYP_INTEGER;
                   { Number : collect integer part }
                   while True do begin
                      Token_Data := Token_Data + C;
                      if not(PeekNextChar in ['0'..'9']) then Break;
                      C := NextChar;
                   end;
                   if PeekNextChar = '.' then
                   begin
                      Token_Data := Token_Data + NextChar;
                      Token_SubType := TYP_REAL;
                   end;
                   { Continue with digits after dot }
                   if PeekNextChar in ['0'..'9'] then
                   begin
                      C := NextChar;
                      while True do begin
                         Token_Data := Token_Data + C;
                         if not(PeekNextChar in ['0'..'9']) then Break;
                         C := NextChar;
                      end;
                   end;
                   { test for exponent }
                   if PeekNextChar in ['E','e'] then
                   begin { exponent }
                      Token_Data := Token_Data + UpCase(NextChar); // get E
                      if PeekNextChar = '-' then Token_Data := Token_Data + C; // add -
                      i := 0; { after need digits }
                      while True do begin
                          if not(PeekNextChar in ['0'..'9']) then Break;
                          inc(i);
                          C := NextChar;
                          Token_Data := Token_Data + C;
                      end;
                      if i = 0 then begin Token := err_Unfinished_real_constant; Result := Token; Exit; end;
                      Token_SubType := TYP_REAL;
                   end;
                end;
              Token := TOKEN_NUMBER;
           end;
      { group of string }
      '"','''' : begin  // can be both
              QC := C; // get begin string char for test double
              while True do begin
                 C := NextChar;
                 case C of
                    #0,#10,#13: begin Token := err_Unterminated_string_constant; result := Token; Exit; end;
                 else
                    if C = QC then
                    begin
                       if PeekNextChar = QC then
                       begin
                           C := NextChar
                       end else begin
                           { this must the end of the string }
                           Token := TOKEN_STRING;
                           Break;
                       end;
                    end;
                    Token_Data := Token_Data + C;
                 end;
              end;
           end;
      { group of text }
      '_','A'..'Z','a'..'z': begin
              while True do
              begin
                 Token_Data := Token_Data + UpCase(C);
                 if not(PeekNextChar in ['A'..'Z', 'a'..'z', '0'..'9', '_']) then Break;
                 C := NextChar;
              end;
              Token := look_Up(Token_Data);
              if Token = 0 then Token := TOKEN_TEXT;
           end;
      else
         { Symbols }
         Token_Data := C;
         Token := look_UP(C);
         if Token > 0 then
         begin
            i := Look_Up(C + PeekNextChar);
            if i > 0 then
            begin
               Token_Data := Token_Data + NextChar;
               Token := i
            end;
         end else begin
            Token := TOKEN_UNKNOWN;   ///??????TODO
         end;
   end;


/// Specific part
   if (( Token = TOKEN_text ) and ( _NewRow <> 0)) then
   begin
      if PeekNextChar = ':' then
      begin
         NextChar; // skip :
         Token := C_LABEL;
      end
   end;

   if (Token = C_REM) then
   begin
      ToNextLine;
//      NextToken;
   end;

//output := output +Token_Data+#13#10;

   Result := Token;
end;

{----- V A R I A B L E S ------------------------------------------------------}


function    BTSmallBasic.Init_Idents:longint;
begin
   Result := 0;
   _Idents := nil;
   _IdentCapacity := 32;
   _IdentCount := 0;
   _LocalIdentsCount := 0;
   _Vars := nil;
   _VarsCapacity := 32;
   _VarsCount := 0;

   ReallocMem(_Idents, _IdentCapacity * Sizeof(BTSB_IdentItem));
   ReallocMem(_Vars, _VarsCapacity * sizeof(longword));
   if _Idents = Nil then Result := -1;
end;

procedure   BTSmallBasic.Close_Idents;
begin
   ReallocMem(_Idents, 0);
   ReallocMem(_Vars, 0);
end;

function    IdentHash(Name:string):longword;
asm
  mov  eax, Name
  test eax, eax
  jz   @@exit
  mov  ecx, [eax-4]  // ecx = Length(S)
  xor  edx, edx
  test ecx, ecx
  jz   @@exit
  push esi
  mov  esi, eax
  @@loop:
  mov  al, [esi]
  cmp  al, 'a'
  jb   @@doxor
  cmp  al, 'z'
  ja   @@doxor
  sub  al, 'a'-'A'
  @@doxor:
  rol  dx, 5
  inc  esi
  xor  dl, al
  dec  ecx
  jnz  @@loop
  pop  esi
  mov  eax, edx
@@exit:
end;

function    BTSmallBasic.FindIdent(TheName:string):longword;
var i: Integer;
    H: longword;
begin
   Result := 0;
   H := IdentHash(TheName);
   for i := 1 to _IdentCount do
   begin
      if H = _Idents[i].Hash then
      begin
         if TheName = _Idents[i].Name then
         begin
            Result := i;
            Exit; // Found
         end;
      end;
   end;
end;

function    BTSmallBasic.Ident(TheName:string; asize:longword):longword;
var i: Integer;
begin
   Result := FindIdent(TheName);
   if Result <> 0 then Exit;

   inc(_IdentCount);
   if _IdentCount >= _IdentCapacity then
   begin
      inc(_IdentCapacity,32);
      ReallocMem(_Idents, _IdentCapacity * Sizeof(BTSB_IdentItem));
      if _Idents = nil then
      begin
         SetError(err_Internal_Error);
         Exit;
      end;
   end;
   if _VarsCount + asize >= _VarsCapacity then
   begin
      i := 32;
      if i < aSize then inc(i,aSize);
      inc(_VarsCapacity,i);
      ReallocMem(_Vars, _VarsCapacity * Sizeof(longword));
      if _Vars = nil then
      begin
         SetError(err_Internal_Error);
         Exit;
      end;
   end;

   Result := _IdentCount;

   with _Idents[Result] do
   begin
      Hash := IdentHash(TheName);
      Name := TheName;
      Data := _VarsCount;
      Typ  := TYP_UNDEF;   // NOTE : this part must be setup by user
      Complex := '';
      Base := _VarsCount;
   end;
   for i  := 0 to aSize - 1 do _Vars[_varsCount + i].I := 0;

   _VarsCount := _VarsCount + asize;

end;

function    BTSmallBasic.GetLocalIdent(var P :longword):boolean;
var S:string;
begin
   inc(_LocalIdentsCount);
   str(_LocalIdentsCount, S);
   S := '@#Lok'+S;
   P := Ident(S,1);
   if P <> 0 then
   begin // clear
      _Idents[P].Typ := TYP_UNDEF;
      _Idents[P].Complex := '';
      _Vars[_Idents[P].Data].I := 0;
   end;
   Result := P <> 0;
end;




{----- S T A C K --------------------------------------------------------------}

type
    TStackPoint = record
       CallTyp  : longword;
       a_Offset : longword;
       varA     : longword;
       _To      : longint;
       _Step    : longint;
    end;
    PTStackPoint = ^TStackPoint;

    TStackArray = array [1..MAX_STACK_SIZE] of TStackPoint;
    PTStackArray = ^TStackArray;


procedure   BTSmallBasic.Init_Stack;
begin
   Stack := nil;
   StackTop := 0;
   ReallocMem(Stack, Sizeof(TStackArray));
end;

procedure   BTSmallBasic.Close_Stack;
begin
   ReallocMem(Stack, 0);
end;

function   BTSmallBasic.Push:boolean;
begin
   Result := false;
   if Stack <> nil then
   begin
      inc(StackTop);
      if StackTop > MAX_STACK_SIZE  then
      begin
         Error := err_Stack_Overload;
         exit;
      end else Result := true;
   end else begin
      Error := err_Internal_Error;
   end;
end;

procedure   BTSmallBasic.Stack_ReturnPos;
begin
   if Stack <> nil then
   begin
      if StackTop > 0 then
      begin
         // Force parser position
         _Offset := PTStackArray(Stack)^[StackTop].a_Offset;
      end;
   end;
end;

procedure   BTSmallBasic.Pop;
begin
   if Stack <> nil then
   begin
      if StackTop > 0 then Dec(StackTop);
   end;
end;




{----- T O O L S --------------------------------------------------------------}

procedure   BTSmallBasic.IntegerToReal(var s,d:longword);
begin
   if _Idents[S].Typ = TYP_INTEGER then
   begin
      _Vars[_Idents[d].data].R := _Vars[_Idents[s].data].I ;
      _Idents[D].Typ := TYP_REAL;
   end else begin
      if _Idents[S].Typ = TYP_REAL then
      begin
         _Vars[_Idents[d].data].R := _Vars[_Idents[s].data].R ;
         _Idents[D].Typ := TYP_REAL;
      end;
   end;
end;

{------------------------------------------------------------------------------}
procedure   BTSmallBasic.RealToInteger(var s,d:longword);
begin
   if _Idents[S].Typ = TYP_REAL then
   begin
      if frac(_Vars[_Idents[s].data].R) = 0 then
      begin
         _Vars[_Idents[d].data].I := trunc(_Vars[_Idents[s].data].R);
         _Idents[D].Typ := TYP_INTEGER;
      end else begin
         SetError(err_Type_mismatch);
      end;
   end else begin
      if _Idents[S].Typ = TYP_INTEGER then
      begin
         _Vars[_Idents[d].data].I := _Vars[_Idents[s].data].I;
         _Idents[D].Typ := TYP_INTEGER;
      end;
   end;
end;

{------------------------------------------------------------------------------}
procedure   BTSmallBasic.FreePStr(V:longword);
begin
   if (_Idents[v].Typ = TYP_STRING) and ( _Vars[_Idents[V].data].I <> 0 ) then
   begin
      dispose(_Vars[_Idents[V].data].S);
   end;
end;





{----- B A S I C --------------------------------------------------------------}

constructor BTSmallBasic.Create;
begin
   Init_Idents;
   InitRTL;
   Init_Stack;
   On_Jump := 0;
   Expr_dovar := true;
   OutPut := '';
end;

{------------------------------------------------------------------------------}
destructor  BTSmallBasic.Destroy;
begin
   Close_Stack;
   Close_Idents;
   inherited;
end;

{------------------------------------------------------------------------------}
procedure   BTSmallBasic.SetError(Op:longint);
begin
   if Error  = 0 then
   begin
      Error := Op;
      ErrorOfs := _Offset;
      ErrorD := Data_Cnt;
   end;
end;

{------------------------------------------------------------------------------}
function    BTSmallBasic.GetError:string;
var S:String;
   C:char;
   _Row,_Column:longword;
   Ofs:longword;
   function ToStr(a:longint):string;
   begin
      Str(a,Result);
   end;
begin
   // Rescan to find row column
   Ofs := ErrorOfs;
   _Row := 1;
   _Column := 1;
   _Offset := 0;
   repeat
      C := Prog^[_Offset];
      inc(_offset);
      inc(_Column);
      if C = #13 then
      begin
         inc(_Row);
         _Column := 0;
         if Prog^[_Offset] = #10 then inc(_Offset);
      end;
   until (c = #0) or (_Offset >= Ofs); // use > to take #10



//   repeat NextChar;  until _Offset >= Ofs; // use > to take #10

   if Error <> 0 then
   begin
      case Error of
         err_Unrecognized_word        : S := 'Unrecognized word';
         err_Too_Big_Integer          : S := 'Too big integer';
         err_Bad_hex_constant         : S := 'Bad hexagonal constant';
         err_Unfinished_real_constant : S := 'Unfinished real constant';
         err_Unterminated_string_constant : S := 'Unterminated string constant';
         err_Internal_error           : S := 'Internal error';
         err_Variable_Name_Expected   : S := 'Variable name expected';
         err_Arrays_are_non_AutoDef   : S := 'Arrays are not auto defined';
         err_Divide_by_zero           : S := 'Divide by zero';
         err_Expected_Close_Bracket   : S := 'Expected close bracket';
         err_Type_Mismatch            : S := 'Type mismatch';
         err_Expected_Equal           : S := 'Expected equal';
         err_Operator_not_support_this_type : S := 'Operator not support this type';
         err_Expected_open_bracket    : S := 'Expected open bracket';
         err_Need_Boolean_Result      : S := 'Need boolean result';
         err_Expected_THEN            : S := 'Expected THEN';
         err_Need_Integer_Value       : S := 'Need integer value';
         err_Stack_Overload           : S := 'Stack overload';
         err_Next_Without_For         : S := 'Next without for';
         err_Uncorrect_Stack_Levels   : S := 'Uncorect stack levels';
         err_Return_Without_Gosub     : S := 'Return without GOSUB';
         err_Expected_Goto_or_Gosub   : S := 'Expected GOTO or GOSUB';
         err_Undefined_Label          : S := 'Undefined label';
         err_Label_Not_Found          : S := 'Label not found';
         err_Expected_Label           : S := 'Expeted label';
         err_Expected_Comma           : S := 'Expected comma';
         err_Param_Diferent_type      : S := 'Param is in different type';
         err_No_data_to_read          : S := 'No data to read';
         err_Expected_Variable        : S := 'Expected variable';
         err_No_more_data_to_read     : S := 'No more data to read';
         err_Variable_in_Data         : S := 'Variable inside data';
         err_Expected_To              : S := 'Expected TO';
         err_Reserved_Word            : S := 'Reserved word';
         err_This_var_is_array        : S := 'This variable is array';
         err_Expected_Close_Index     : S := 'Expected close array marker';
         err_Expected_Open_Index_mark : S := 'Expected open array marker';
         err_Too_many_array_levels    : S := 'Too many array levels';
         err_Too_Big_Array            : S := 'Dimension of array is too big';
         err_Only_positive_values     : S := 'Expected positive value';
         err_Outside_of_dimension     : S := 'Outsite of array dimension';
         err_Expected_delimiter       : S := 'Expected delimiter';  

      end;
      Result := 'Error('+ToStr(Error)+' ['+ToStr(_Row)+','+ToStr(_Column)+'])(d'+ToStr(Data_Cnt)+') ' +  S;
   end else begin
      Result := '';
   end;
end;

{------------------------------------------------------------------------------}
procedure   BTSmallBasic.Reset;
begin
   Error := 0;
   ErrorOfs := 0;
   Close_Idents;
   Init_Idents;
   InitRTL;
   OutPut := '';
   _RESET; // data pointer
   ResetParser(Script);
end;

{------------------------------------------------------------------------------}
procedure   BTSmallBasic.Load(txt: string);
var lbl,dat :longword;
    s :string;

    procedure MakeList(ID:char; var Begin_Offset, Local_Offset:longword);
    begin
       S := ID + char($FF)+char($FF)+char($FF)+char($FF);
       if Begin_offset = 0  then
       begin
          Begin_offset := _Preoffset;
          Local_offset := _Offset;
          Insert(S,Script,_offset); // end mark
       end else begin
          // update last mark
          Script[Local_offset  + 1] := char((_Preoffset shr 24) and $FF);
          Script[Local_offset  + 2] := char((_Preoffset shr 16) and $FF);
          Script[Local_offset  + 3] := char((_Preoffset shr 8 ) and $FF);
          Script[Local_offset  + 4] := char((_Preoffset       ) and $FF);
          Local_offset  := _Offset;
          Insert(S,Script,_offset);
       end;
    end;

begin
   Script := txt + ' '; // I need that for parser.PutBack at the end of script :)

   // preprocess script
   Labels_offset := 0;
   Data_offset   := 0;
   Data_C_offset := 0;
   Data_Cnt := 0;
   ResetParser(Script);
   repeat
      NextToken;
      if Token = C_LABEL then MakeList(#27,Labels_offset,lbl);
      if Token = C_DATA  then MakeList(#28,Data_offset,dat);
   until (Token = TOKEN_EOF) or (Token < 0);
   if Data_Offset <> 0 then Data_Offset := Data_Offset + 4; // bypass data :)
   Data_Offset_Copy := Data_Offset;
//   ResetParser(Script);
   Reset;
   Data_Offset_Copy := Data_offset;
end;

{------------------------------------------------------------------------------}
function    BTSmallBasic.LoadFromFile(file_name: string): longint;
var s,s1:string;
    f:Text;
    res:longword;
begin
   s := '';
   res := 0;
   assign(f,file_name);
   {$I-}
   system.reset(f);
   {$I+}
   if IOResult = 0 then
   begin
      while not eof(f) do
      begin
         readln(f,s1);
         s := s + s1 + #13 + #10;
         res := 1;
      end;
      close(f);
   end;
   if length(s) > 0 then Load(s);
   LoadFromFile := res;
end;




{------------------------------------------------------------------------------}
function    BTSmallBasic.Run:longint;
//var Loop : longint;
begin
   Error := 0; // OK no error
   ErrorOfs := 0;
   NextToken;
   while (Token <> TOKEN_EOF) and (Error = 0) do
   begin
      _LocalIdentsCount := 0;
      case Token of
         C_IF         : _IF;
         C_FOR        : _FOR;
         C_NEXT       : _NEXT;
         C_GOTO       : _GOTO;
         C_GOSUB      : _GOSUB;
         C_ON         : _ON;
         C_RETURN     : _RETURN;
         C_READ       : _READ;
         C_RESET      : _RESET;
         C_DATA       : begin ToNextLine; {NextToken;} end;
         C_END        : break;
         C_DIM        : _DIM;
         C_DELIMITER,
         C_LABEL      : NextToken;
//         TOKEN_EOL    : begin end;  // JUST NOP
         TOKEN_EOF    : break;
         TOKEN_TEXT   : _TEXT;  // variable or func
         else begin
            SetError(err_Unrecognized_word);
         end;
      end;
   end;
   Result := Error;
end;


{------------------------------------------------------------------------------}
{ IF (expresion) THEN ...                                                      }

procedure   BTSmallBasic._IF;
var  Ap:longword;
     PasToNextLine :boolean;
begin
   PasToNextLine := true;
   NextToken;
   if GetLocalIdent(Ap) then
   begin
      if expresion(Ap) then
      begin
         if _Idents[AP].Typ = TYP_STRING then
         begin
            SetError(err_Need_Boolean_Result);
            FreePstr(Ap);
         end else begin
            if (_Idents[AP].Typ = TYP_INTEGER) and (_Vars[_Idents[AP].Data].I <> 0) then PasToNextLine := false;
            if (_Idents[AP].Typ = TYP_REAL)    and (_Vars[_Idents[AP].Data].R <> 0) then PasToNextLine := false;
            if not PasToNextLine then
            begin
               MatchToken(c_THEN,EXPLICIT,err_Expected_THEN);

            end;
         end;
      end;
   end;
   if PasToNextLine then ToNextLine;
end;

{------------------------------------------------------------------------------}
{ FOR (variable) = (expresion) TO (expresion) [ STEP (expresion) ]             }
procedure   BTSmallBasic._FOR;
var A,Bp,Sp: longword;
begin
   NextToken;
   if Push then
   begin
      if GetLocalIdent(Bp) and GetLocalIdent(Sp) then
      begin
         if variable(A) then
         begin
            if MatchToken(C_EQUAL,EXPLICIT,err_Expected_Equal) then
            begin
               if expresion(A) then
               begin
                  if _Idents[A].TYP = TYP_STRING then begin SetError(err_Need_Integer_Value); Exit; end;
                  if MatchToken(C_TO,EXPLICIT,err_Expected_To) then
                  begin
                     if expresion(Bp) then
                     begin
                        if _Idents[Bp].TYP = TYP_STRING then begin SetError(err_Need_Integer_Value); FreePstr(Bp); Exit; end;
                        if MatchToken(C_STEP,NOT_EXPLICIT,0) then
                        begin
                           if expresion(Sp) then
                           begin
                              if _Idents[Sp].TYP = TYP_STRING then begin SetError(err_Need_Integer_Value);  FreePstr(Sp); Exit; end;
                           end;
                        end;
                        // create FOR
                        if _Idents[Sp].Typ = TYP_UNDEF then
                        begin
                           _Idents[Sp].Typ := TYP_INTEGER;
                           _Vars[_Idents[Sp].Data].I := 1;
                        end;

                        if _Idents[A].Typ = TYP_INTEGER then
                        begin
                           RealToInteger(Bp,Bp);
                           RealToInteger(Sp,Sp);
                           PTStackArray(Stack)[StackTop]._To := _Vars[_Idents[Bp].Data].I;
                           PTStackArray(Stack)[StackTop]._Step := _Vars[_Idents[Sp].Data].I;
                        end;
                        if _Idents[A].Typ = TYP_REAL then
                        begin
                           IntegerToReal(Bp,Bp);
                           IntegerToReal(Sp,Sp);
                           single(pointer(@PTStackArray(Stack)[StackTop]._To)^) := _Vars[_Idents[Bp].Data].R;
                           single(pointer(@PTStackArray(Stack)[StackTop]._Step)^) := _Vars[_Idents[Sp].Data].R;
                        end;
                        PTStackArray(Stack)[StackTop].a_Offset := _PreOffset;
                        PTStackArray(Stack)[StackTop].CallTyp := 1;
                        PTStackArray(Stack)[StackTop].varA := A;
                     end;
                  end;
               end;
            end;
         end;
      end;
   end;
   expectDelimiter;
end;

{------------------------------------------------------------------------------}
procedure   BTSmallBasic._NEXT;
var A:longword;
    Old : longint;
begin
   NextToken;
   if StackTop > 0 then
   begin
      if PTStackArray(Stack)[StackTop].CallTyp = 1 then
      begin
         A := PTStackArray(Stack)[StackTop].varA;
         if _Idents[A].typ = TYP_INTEGER then
         begin
            Old := _Vars[_Idents[A].Data].I;
            _Vars[_Idents[A].Data].I := _Vars[_Idents[A].Data].I + PTStackArray(Stack)[StackTop]._Step;
            if _Vars[_Idents[A].Data].I > PTStackArray(Stack)[StackTop]._To then
            begin
               _Vars[_Idents[A].Data].I := Old;
               Pop; // GetOut
               expectDelimiter;
            end else begin
               Stack_ReturnPos; // do it again
               NextToken;
            end;
         end;
         if _Idents[A].typ = TYP_REAL then
         begin
            Old := _Vars[_Idents[A].Data].I; // get like integer :)
            _Vars[_Idents[A].Data].R := _Vars[_Idents[A].Data].R + single(pointer(@PTStackArray(Stack)[StackTop]._Step)^);
            if _Vars[_Idents[A].Data].R > single(pointer(@PTStackArray(Stack)[StackTop]._To)^) then
            begin
               _Vars[_Idents[A].Data].I := Old;
               Pop; // GetOut
               expectDelimiter;
            end else begin
               Stack_ReturnPos; // do it again
               NextToken;
            end;
         end;
      end else begin
         SetError(err_Uncorrect_Stack_Levels);
      end;
   end else begin
      SetError(err_Next_Without_For);
   end;
end;

{------------------------------------------------------------------------------}
{ ON (expresion) GOTO label,label[,label]                                      }
{ ON (expresion) GOSUB label,label[,label]                                     }
procedure   BTSmallBasic._ON;
var
    Bp:longword;
    Op,I:integer;
begin
   NextToken;
   if GetLocalIdent(Bp) then
   begin
      if expresion(Bp) then
      begin
         // prepare ON
         i := -1;
         if _Idents[Bp].TYP = TYP_STRING then begin SetError(err_Need_Integer_Value); FreePstr(Bp); Exit; end;
         if _Idents[Bp].Typ = TYP_INTEGER then
         begin
            i := _Vars[_Idents[Bp].Data].I;
         end;
         if _Idents[Bp].Typ = TYP_REAL then
         begin
            Op := trunc(_Vars[_Idents[Bp].Data].R);
            if Frac(_Vars[_Idents[Bp].Data].R) = 0 then I := Op
         end;
         // do After on
         if i >= 0 then
         begin
            if i = 0 then i := -1;
            On_Jump := i;
            if Token = C_GOTO then
            begin
               _GOTO
            end else begin
               if Token = C_GOSUB then
               begin
                  _GOSUB
               end else begin
                  SetError(err_Expected_Goto_or_Gosub);
               end;
            end;
         end else begin
            SetError(err_Need_Integer_Value);
         end;
      end;
   end;
end;

{------------------------------------------------------------------------------}
{ GOTO label                                                                   }
procedure   BTSmallBasic._GOTO;
var lbl:string;
begin
   NextToken;
   if getlabel(lbl) then GotoLabel(lbl);
end;

{------------------------------------------------------------------------------}
{ GOSUB label                                                                  }
procedure   BTSmallBasic._GOSUB;
var lbl:string;
begin
   NextToken;
   if getlabel(lbl) then
   begin
      if Push then
      begin
         PTStackArray(Stack)[StackTop].a_Offset := _PreOffset;
         PTStackArray(Stack)[StackTop].CallTyp := 0;
         GotoLabel(lbl);
      end;
   end;
//   expectDelimiter; //????
end;

{------------------------------------------------------------------------------}
procedure   BTSmallBasic._RETURN;
begin
   if StackTop > 0 then
   begin
      if PTStackArray(Stack)[StackTop].CallTyp = 0 then
      begin
         Stack_ReturnPos;
         Pop;
         NextToken;
      end else begin
         SetError(err_Uncorrect_Stack_Levels);
      end;
   end else begin
      SetError(err_Return_Without_Gosub);
   end;
end;

{------------------------------------------------------------------------------}
procedure   BTSmallBasic._READ;
var A:longword;
    S_offset:longword;
begin
   NextToken;
   if not ((Data_offset = 0) or (Data_offset = $FFFFFFFF)) then
   begin
      if variable(A) then
      begin
         S_offset := _PreOffset;
         inc(Data_cnt);
         _Offset := Data_Offset + Data_C_offset;
         NextToken;
         Expr_dovar := false;
         expresion(A);
         Expr_dovar := true;
         if Token = C_COMMA then
         begin
            Data_C_offset := _Offset - Data_Offset;
         end else begin
            if _newRow = 1 then
            begin
               Data_Offset :=  ( longword(Prog^[Data_Offset+1]) shl 24 ) or
                               ( longword(Prog^[Data_Offset+2]) shl 16 ) or
                               ( longword(Prog^[Data_Offset+3]) shl 8  ) or
                               ( longword(Prog^[Data_Offset+4])        );
               if data_Offset <> $FFFFFFFF then Data_Offset := Data_Offset + 4; // by pass data :)
               Data_C_Offset := 0;
            end else begin
               SetError(err_Unrecognized_Word);
            end;
         end;
         _Offset := S_offset;
         NextToken;
      end else begin
         SetError(err_Expected_Variable);
      end;
   end else begin
      SetError(err_No_data_to_read);
      if Data_Offset = $FFFFFFFF then  SetError(err_No_more_data_to_read);
   end;
   expectDelimiter;
end;

{------------------------------------------------------------------------------}
procedure   BTSmallBasic._RESET;
begin
   NextToken;
   Data_Offset := Data_Offset_Copy;
   Data_C_offset := 0;
   Data_Cnt := 0;
   expectDelimiter;
end;

{------------------------------------------------------------------------------}
{ DIM name[dim[,dim]]                                                          }
procedure   BTSmallBasic._DIM;
var Bp,A:longword;
    i,st,j:integer;
    s,name:string;
    K:longword;
    dims:array [1..8] of longint;
begin
   NextToken; // remove dim get name
   if Token = TOKEN_TEXT then
   begin
      st := TYP_REAL;
      Name := Token_data;
      if PeekNextChar in ['$','#'] then
      begin
         NextToken; // Get that char
         Name := Name + Token_Data;
         if Token_Data = '$' then st := TYP_STRING
                             else st := TYP_INTEGER;
      end;

      NextToken;

      j := 0;
      if Token = C_OPENINDEX then
      begin
        NextToken;

        repeat
           GetLocalIdent(bp);  //TODO error
           if expresion(Bp) then
           begin
              RealToInteger(Bp,Bp);
              if Error <> 0 then Error := err_Need_Integer_value;
           end else begin
              break;
           end;

           inc(j);
           if j > 8 then
           begin
              SetError(err_Too_many_array_levels);
              break;
           end;
           dims[j] := _vars[_Idents[Bp].Data].I;

           if Token = C_COMMA then
           begin
              NextToken;
              continue;
           end;
        until (Token <= 0) or ( Token = C_CLOSEINDEX ) or (Error <> 0);

        if Token <> C_CLOSEINDEX then
        begin
            SetError(err_Expected_Close_Index);
        end;
        NextToken;

        S := '[' + chr(byte(j));
        k := 1;
        for i := 1 to j do
        begin
          if dims[i] <= 0  then
          begin
             SetError(err_Only_positive_values);
             Exit;
          end;
          k := k * dims[i];
          S := S + chr(byte(dims[i] and $FF));
          S := S + chr(byte((dims[i] shr 8) and $FF));
        end;
        if K > 20000000 then //  :)
        begin
           SetError(err_Too_Big_Array);
        end else begin
           A := Ident(Name,k);
           _Idents[A].Typ := st;
           _Idents[A].Complex := s;
           for i  := 0 to k - 1 do
           begin
              if st = TYP_STRING then  new(_Vars[_Idents[A].Data + i].S);
           end;
        end;
        freePstr(Bp);
      end else begin
        SetError(err_Expected_Open_Index_mark);
      end;
   end else begin
      SetError(err_Variable_Name_Expected);
   end;
//   freePstr(Bp);
   expectDelimiter;
end;

{------------------------------------------------------------------------------}
procedure   BTSmallBasic._TEXT;
var A,Bp:longword;
begin
   if GetLocalIdent(Bp) then
   begin
      if not func(Bp) then // skip result
      begin
         if variable(A) then
         begin
            if MatchToken(C_EQUAL,EXPLICIT,err_Expected_Equal) then
            begin
               expresion(A);
            end;
         end;
      end;
   end;
   FreePstr(Bp);
   expectDelimiter;
end;

{------------------------------------------------------------------------------}
function    BTSmallBasic.getlabel(var lbl:string):boolean;
var op,i:longint;
begin
   Result := false;
   if On_Jump = 0 then
   begin // One label
      if Token = TOKEN_TEXT then
      begin
         lbl := TOKEN_Data;
         Result := true;
      end else begin
         SetError(err_Expected_Label);
      end;
   end else begin

   lbl := '';
   i := 1;
   repeat
      if Token = TOKEN_TEXT then
      begin
         if i = On_Jump then
         begin
            lbl := Token_data;
            Result := true;
         end;
         inc(i);
         NextToken;
         if Token = C_COMMA  then
         begin
            NextToken;
            Continue;
         end else break;
      end;
   until (Op = 0) or (Error <> 0) ;
   end;
   On_Jump := 0;
end;

{------------------------------------------------------------------------------}
function    BTSmallBasic.gotolabel(lbl:string) : boolean;
var clb : string;
    ofs : longword;
    bye:boolean;
begin
   for Ofs := 1 to Length(lbl) do lbl[Ofs] := UpCase(lbl[Ofs]);
   Ofs := Labels_Offset;
   Result := true;
   if Labels_Offset <> 0 then
   begin
      repeat
         clb:= '';
         bye := true;
         repeat
            while Prog^[Ofs] in [#1..' '] do inc(Ofs);
            clb := clb + UpCase(Prog^[Ofs]);
            inc(Ofs);
         until Prog^[Ofs] = ':';
         if lbl = clb then
         begin // Found
            _Offset := Ofs + 1;
            NextToken; // After new ofset fill Token
         end else begin
            if  (Prog^[Ofs+2] = char($FF)) and (Prog^[Ofs+3] = char($FF))
            and (Prog^[Ofs+4] = char($FF)) and (Prog^[Ofs+5] = char($FF)) then
            begin
               SetError(err_Label_Not_Found);
               Result := false;
            end else begin
               Ofs :=  ( longword(Prog^[Ofs+2]) shl 24 ) or
                       ( longword(Prog^[Ofs+3]) shl 16 ) or
                       ( longword(Prog^[Ofs+4]) shl 8  ) or
                       ( longword(Prog^[Ofs+5])        );
               bye := false;
            end;
         end;
      until bye;
   end else begin
      SetError(err_Label_Not_Found);
      Result := false;
   end;
end;

{------------------------------------------------------------------------------}
function    BTSmallBasic.variable(var V:longword) : boolean;
var i,j,k,op,m,p: integer;
    st : longword;
    name : string;
    VI: longword;
    dims: array [1..8] of longword;
    cdims: array [1..8] of longword;
begin
   if Error <> 0 then begin Result := false;  Exit; end;  // Todo optimize
   Result := true;

   if Token = TOKEN_TEXT then
   begin
      st := TYP_REAL;
      Name := Token_data;
      if PeekNextChar in ['$','#'] then
      begin
         NextToken;
         Name := Name + Token_Data;
         if Token_Data = '$' then st := TYP_STRING
                             else st := TYP_INTEGER;
         NextToken; // Get that char
      end else nextToken;

      if Token = C_OPENINDEX then i := 1  // marker for array
                             else i := 0; // no test for i < 0 ??????

      V := FindIdent(Name);
      if V = 0 then
      begin
//         for j := 1 to CMD_count do
//         begin
//            if Name = CMD[j] then SetError(err_Reserved_Word);
//         end;
         V := Ident(Name,1);
         if V <> 0 then
         begin
            _Idents[V].Typ := st;
            if st = TYP_STRING then  new(_Vars[_Idents[V].Data].S);
            if i = 1 then SetError(err_Arrays_are_non_AutoDef);
         end;
      end;

      if (V <> 0) and (Error = 0) then
      begin
         if _Idents[V].Complex[1] = '(' then
         begin
            SetError(err_Reserved_Word);
         end;

         if (_Idents[V].Complex[1] = '[') then

         if i = 1 then
         begin  // Index
            NextToken; // get [
            j := byte(_Idents[V].Complex[2]);
            for i :=  1 to j  do
            begin

               GetLocalIdent(VI);  //TODO error
               expresion(VI);
               if _Idents[VI].Typ = TYP_STRING then
               begin
                  SetError(err_Need_Integer_Value);
                  FreePstr(VI);
               end;
               RealToInteger(vi,vi);
               if Error = 0 then
               begin
                  k := (i - 1)*2;
                  Op := longword(byte(_Idents[V].Complex[3 + k])) or (longword(byte(_Idents[V].Complex[3 + k + 1])) shl 8);
                  k := _Vars[_Idents[Vi].Data].I;
                  if k > Op then
                  begin
                     SetError(err_Outside_of_dimension);
                     break;
                  end;
                  dims[i] := Op;
                  if k <= 0 then
                  begin
                     SetError(err_Only_positive_values);
                     break;
                  end;
                  cdims[i] := k;
               end;
               if i <> j then
               begin
                  if Token <> C_COMMA then SetError(err_Expected_Comma);
                  NextToken;
               end;
               if Error <> 0  then Break;
            end;
            if Token <> C_CLOSEINDEX then SetError(err_Expected_Close_Index);
            NextToken;

            // calc index
            k := 0;
            for i := 1 to j do
            begin
               if i <> 1 then
               begin
                  p := 1;
                  for m := 1 to (i-1) do p := p * dims[m];
                  k := K + ( (cdims[i] - 1) * p );
               end else begin
                  k := k + (cdims[i] - 1);
               end;
            end;
            _Idents[V].Data := _Idents[V].Base + k ;

         end else begin
            SetError(err_This_var_is_array);
         end;
      end;
   end else begin
      SetError(err_Variable_Name_Expected);
      if i < 0 then SetError(i);
   end;
   if Error <> 0 then Result := false;
end;

{------------------------------------------------------------------------------}
{ ! WARNING !                                                                  }
{ The called function must be std call                                         }
type
    TinPArray = array [1..MAX_PARAM_COUNT] of longword;

function    BTSmallBasic.func(var V:longword) : boolean;
var Va:longword;
    op,i,pcnt,lpos: integer;
    pform:string;
    Bpa:longword;
    fn:longword;
    prms:TinPArray;
    Name:String;
    fnc:function(dop:longword; inP:TinPArray):longint; stdcall;
    res:longword;

    function GetCParam(NeedType:longword):boolean;
    begin
       Result := false; // no error go on
       inc(pcnt);

       if pcnt > 1 then
       begin
          if Token <> C_COMMA then
          begin
             SetError(err_Expected_Comma);
             Result := true;
             Exit;
          end;
          NextToken;
       end;

       if GetLocalIdent(Bpa) then
       begin
          if expresion(Bpa) then
          begin
          if (_Idents[Bpa].typ = TYP_INTEGER) and (NeedType = TYP_REAL) then
          begin
              IntegerToReal(Bpa,Bpa);
              NeedType := TYP_REAL;
          end;
          if _Idents[Bpa].typ = NeedType then
          begin
             if NeedType = TYP_STRING then
             begin
                New(BTSB_PStr(prms[pcnt]));
                BTSB_PStr(prms[pcnt])^ := _Vars[_Idents[Bpa].Data].S^;
             end else begin
                prms[pcnt] := _Vars[_Idents[Bpa].Data].I;
             end;
          end else begin
             SetError(err_Param_Diferent_type);
             Result := true;
          end;
          FreePstr(Bpa);
       end else Result := True;;
       end;
    end;


begin
   Result := false; // not func or error
   if Error <> 0 then Exit;

   if Token = TOKEN_TEXT then
   begin
      Name := Token_Data;
      if PeekNextChar in ['#','$'] then Name := Name + PeekNextChar;

      Va := FindIdent(Name);
      if Va <> 0 then
      begin
         if Length(_Idents[Va].Complex)> 0 then
         begin
            if _Idents[Va].Complex[1] = '(' then
            begin // Call function
               NextToken; // name
               if PeekNextChar in ['#','$'] then NextToken;

               pform := _Idents[Va].Complex;
               pcnt := 0;
               lpos := 1;

               if Copy(pform,1,2) <> '()' then // if no param no need of ()
               begin
                  for i := 1 to length(pform) do
                  begin
                     inc(lpos);
                     case char(UpCase(pform[i])) of
                       '(' : begin // start of function declaration
                          if Token <> C_OPENBRACKET then
                          begin
                             SetError(err_Expected_open_bracket);
                             Exit;
                          end;
                          NextToken;
                       end;
                       'S' : begin
                          if GetCParam(TYP_STRING) then Exit;
                       end;
                       'I' : begin
                          if GetCParam(TYP_INTEGER) then Exit;
                       end;
                       'R' : begin
                          if GetCParam(TYP_REAL) then Exit;
                       end;
                       ')' : begin
                          if Token <> C_CLOSEBRACKET then
                          begin
                             SetError(err_Expected_Close_Bracket);
                             Exit;
                          end;
                          NextToken;
                          break; // No more
                       end;
                     end; // case
                  end;
               end else begin
                  lpos := 3;
               end;

               fn := 0;
               if pform[lpos] = '*' then // Special char;
               begin
                  fn := fn or (longword(pform[lpos+1]) shl 24);
                  fn := fn or (longword(pform[lpos+2]) shl 16);
                  fn := fn or (longword(pform[lpos+3]) shl 8);
                  fn := fn or (longword(pform[lpos+4]) );
               end;

               // Make physical call
               if _Idents[Va].Base <> 0 then
               begin
                  fnc := pointer(_Idents[Va].Base);
                  res := fnc(fn,prms);
                  if _Idents[Va].typ = TYP_STRING then
                  begin
                     if _Vars[_Idents[V].Data].I = 0 then
                     begin //alloc
                        new(_Vars[_Idents[V].Data].S);
                     end;
                     _Vars[_Idents[V].Data].S^ := BTSB_PStr(res)^;
                     dispose(BTSB_PStr(res));
                  end else begin
                     _Vars[_Idents[V].Data].I := res;
                  end;
                  _Idents[V].typ := _Idents[Va].typ;
               end;
               // caller is responsible to free strings
               Result := True; // Ok Exec
            end;
         end;
      end;
   end;
end;

//var dstr:^string;
//    destr :string;
{------------------------------------------------------------------------------}
function    BTSmallBasic.expresion(var V:longword) : boolean;
var Vp : longword;
    R:single;

   const
      t_NEG = 1024;

   procedure Level2(var x:longword); forward;

   procedure arith(op:longword; var x,y:longword);
   var rres,rx,ry : real;
       ires,ix,iy : longint;
       sx,sy:^string;
       sres:string;
   begin
      if Error = 0 then
      begin
         if _Idents[X].Typ = TYP_REAL then
         begin
            rres :=0;
            ry := 0;
            rx := _Vars[_Idents[x].Data].R;
            case _Idents[Y].Typ of
               TYP_INTEGER : ry := _Vars[_Idents[y].Data].I;
               TYP_REAL    : ry := _Vars[_Idents[y].Data].R;
               TYP_STRING, TYP_UNDEF: begin SetError(err_Type_Mismatch); Exit; end;
            end;
            case op of
              C_PLUS     : rres := rx + ry;
              C_MINUS    : rres := rx - ry;
              C_MULTIPLY : rres := rx * ry;
              C_DIVIDE   : begin
                              if ry = 0 then
                              begin
                                 Error := err_Divide_by_zero;
                                 rres := 0;
                              end else begin
                                 rres := rx / ry;
                              end;
                           end;
              C_MODULE   : rres := trunc(rx) mod trunc(ry);
              C_POWER    : rres := exp(ln(rx)*ry);
              C_AND      : rres := trunc(rx) and trunc(ry);
              C_OR       : rres := trunc(rx) or  trunc(ry);
              C_XOR      : rres := trunc(rx) xor trunc(ry);
              C_NOT      : rres := not trunc(rx);
              t_NEG      : rres := rx * -1;
              C_EQUAL    :  if rx =  ry then rres := 1;
              C_NOTEQUAL :  if rx <> ry then rres := 1;
              C_GREAT    :  if rx >  ry then rres := 1;
              C_GREATEQUAL :if rx >= ry then rres := 1;
              C_LESS     :  if rx <  ry then rres := 1;
              C_LESSEQUAL : if rx <= ry then rres := 1;
              C_SHR      : rres := trunc(rx) shr trunc(ry);
              C_SHL      : rres := trunc(rx) shl trunc(ry);
            end;
            _Vars[_Idents[x].Data].R := rres;
         end;

         if _Idents[X].Typ = TYP_INTEGER then
         begin
            ires :=0;
            iy := 0;
            ix := _Vars[_Idents[x].Data].I;
            case _Idents[Y].Typ of
               TYP_INTEGER : iy := _Vars[_Idents[y].Data].I;
               TYP_REAL: begin // Bypass to upper level int + real = real
                  _Idents[x].Typ := TYP_REAL;
                  _Vars[_Idents[x].Data].R := _Vars[_Idents[x].Data].I;
                  arith(op,x,y); // do real real
                  Exit;
               end;
               TYP_STRING, TYP_UNDEF: begin SetError(err_Type_Mismatch); Exit; end;
            end;
            case op of
              C_PLUS     : ires := ix + iy;
              C_MINUS    : ires := ix - iy;
              C_MULTIPLY : ires := ix * iy;
              C_DIVIDE   : begin
                              if iy = 0 then
                              begin
                                 Error := err_Divide_by_zero;
                                 ires := 0;
                              end else begin
                                 rx := ix;
                                 ry := iy;
                                 rx := rx / ry;
                                 if Frac(rx) = 0 then
                                 begin
                                    ires := ix div iy;
                                 end else begin
                                    _Idents[x].typ := TYP_REAL;
                                    _Vars[_Idents[x].Data].R := rx;
                                    exit;
                                 end;
                              end;
                           end;
              C_MODULE   : ires := ix mod iy;
              C_POWER    : ires := round(exp(ln(ix)*iy));
              C_AND      : ires := ix and iy;
              C_OR       : ires := ix or  iy;
              C_XOR      : ires := ix xor iy;
              C_NOT      : ires := not ix;
              t_NEG      : ires := ix * -1;
              C_EQUAL    :  if ix =  iy then ires := 1;
              C_NOTEQUAL :  if ix <> iy then ires := 1;
              C_GREAT    :  if ix >  iy then ires := 1;
              C_GREATEQUAL :if ix >= iy then ires := 1;
              C_LESS     :  if ix <  iy then ires := 1;
              C_LESSEQUAL : if ix <= iy then ires := 1;
              C_SHR      : ires := ix shr iy;
              C_SHL      : ires := ix shl iy;
            end;
            _Vars[_Idents[x].Data].I := ires;
         end;

         if _Idents[X].Typ = TYP_STRING then
         begin

            if _Idents[Y].Typ <> TYP_STRING then
            begin
               SetError(err_Type_Mismatch);
               Exit;
            end;
            ires := 2;

            if _Vars[_Idents[X].data].I <> 0 then sx := pointer(_Vars[_Idents[x].Data].S) else inc(ires);
            if _vars[_Idents[Y].data].I <> 0 then sy := pointer(_Vars[_Idents[y].Data].S) else inc(ires);
            if ires <> 2 then
            begin
               SetError(err_Type_Mismatch); //????????
               Exit;
            end;
            case op of
              C_PLUS     : sres := sx^ + sy^;

              C_EQUAL    :  if sx^ =  sy^ then ires := 1 else ires :=0 ;
              C_NOTEQUAL :  if sx^ <> sy^ then ires := 1 else ires :=0 ;
              C_GREAT    :  if sx^ >  sy^ then ires := 1 else ires :=0 ;
              C_GREATEQUAL :if sx^ >= sy^ then ires := 1 else ires :=0 ;
              C_LESS     :  if sx^ <  sy^ then ires := 1 else ires :=0 ;
              C_LESSEQUAL : if sx^ <= sy^ then ires := 1 else ires :=0 ;

              C_MINUS,
              C_MULTIPLY,
              C_DIVIDE,
              C_MODULE,
              C_POWER,
              C_AND,
              C_OR,
              C_XOR,
              C_NOT,
              t_NEG,
              C_SHR,
              C_SHL : SetError(err_Operator_not_support_this_type);
            end;

            if ires <> 2 then
            begin //
               _Idents[x].typ := TYP_INTEGER;
               Dispose(_Vars[_Idents[x].Data].S);
               _Vars[_Idents[x].Data].I := ires;
            end else begin
               // it is not posible to be not alocatted at this point
               // but
               _Vars[_Idents[x].Data].S^ := sres;
            end;


         end;
      end;
   end;

   procedure     Level9(var x:longword);
   var Op,c: longint;
       xx:longword;
       pxx:longword;
       fnc:boolean;
   begin
      if Error <> 0 then Exit;

      if Token = C_OPENBRACKET then
      begin
         NextToken;
         Level2(x);
         if Token = C_CLOSEBRACKET then NextToken
                                   else SetError(err_Expected_Close_Bracket)
      end else begin
         case Token of
            TOKEN_NUMBER : begin
                val(Token_Data,OP,c); // no need of OP :) use it
                val(Token_Data,R,c); //
                if Token_SubType = TYP_INTEGER then _Vars[_Idents[x].Data].I := OP;
                if Token_SubType = TYP_REAL    then _Vars[_Idents[x].Data].R := R;
                _Idents[x].Typ := Token_SubType;
                NextToken;
             end;
            TOKEN_STRING : begin
                if _Vars[_Idents[x].Data].I = 0 then
                begin //alloc
                   new(_Vars[_Idents[x].Data].S);
                end;
                _Vars[_Idents[x].Data].S^ := Token_Data;
                _Idents[x].Typ := TYP_STRING;
                NextToken;
             end;
            TOKEN_TEXT : begin
                if Expr_dovar then
                begin
//                   PutBack;
                   if GetLocalIdent(pxx) then
                   begin
                      fnc := true;
                      if not func(pxx) then
                      begin
                         fnc := false;
                         variable(pxx);
                      end;
                      _Idents[x].typ := _Idents[pxx].typ;
                      if _Idents[x].typ = TYP_STRING then
                      begin
                         if _Vars[_Idents[x].Data].I = 0 then
                         begin //alloc
                            new(_Vars[_Idents[x].Data].S);
                         end;
                         _Vars[_Idents[x].Data].S^ := _Vars[_Idents[pxx].Data].S^;
                      end else begin
                         _Vars[_Idents[x].Data].I :=  _Vars[_Idents[pxx].Data].I;
                      end;
                      FreePstr(pxx);
                   end;
                end else begin
                   SetError(err_Variable_in_Data);
                end;
             end;
             else
                SetError(err_Unrecognized_word);
         end; // case
      end;
   end;

   procedure     Level8(var x:longword);
   var OP : longint;
   begin
      OP := Token;
      if OP = C_MINUS then NextToken;
      level9(x);
      if OP = C_MINUS then arith(t_NEG,x,x);
   end;

   procedure     Level7(var x:longword);
   begin
      if Token = C_NOT then
      begin
         NextToken;
         level2(x);
         arith(C_NOT,x,x);
      end else begin
         level8(x);
      end;
   end;

   procedure     Level6(var x:longword);
   var Phold : longword;
       OP : longint;
   begin
      level7(x);
      while (Token in [C_AND,C_OR,C_XOR,C_SHR,C_SHL]) and (Error = 0) do
      begin
         if GetLocalIdent(PHold) then
         begin
            Op := Token;
            NextToken;
            Level7(Phold);
            arith(Op,x,Phold);
            FreePstr(PHold);
         end;
      end;
   end;

   procedure     Level5(var x:longword);
   var Phold : longword;
       OP : longint;
   begin
      level6(x);
      while (Token = C_POWER) and (Error = 0) do
      begin
         if GetLocalIdent(PHold) then
         begin
            Op := Token;
            NextToken;
            Level6(Phold);
            arith(Op,x,Phold);
            FreePstr(PHold);
         end;
      end;
   end;

   procedure     Level4(var x:longword);
   var Phold : longword;
       OP : longint;
   begin
      level5(x);
      while (Token in [C_MULTIPLY,C_DIVIDE,C_MODULE]) and (Error = 0) do
      begin
         if GetLocalIdent(PHold) then
         begin
            Op := Token;
            NextToken;
            Level5(Phold);
            arith(Op,x,Phold);
            FreePstr(PHold);
         end;
      end;
   end;

   procedure     Level3(var x:longword);
   var Phold : longword;
       OP : longint;
   begin
      level4(x);
      While (Token in [C_PLUS,C_MINUS]) and (Error = 0) do
      begin
         if GetLocalIdent(PHold) then
         begin
            Op := Token;
            NextToken;
            Level4(Phold);
            arith(Op,x,Phold);
            FreePstr(PHold);
         end;
      end;
   end;

   procedure     Level2(var x:longword);
   var Phold : longword;
       OP : longint;
   begin
      level3(x);
      While (Token in [C_EQUAL,C_GREATEQUAL,C_LESSEQUAL,C_NOTEQUAL,C_GREAT,C_LESS]) and (Error = 0) do
      begin
         if GetLocalIdent(PHold) then
         begin
            OP := Token;
            NextToken;
            Level3(Phold);
            arith(OP,x,Phold);
            FreePstr(PHold);
         end;
      end;
   end;


begin
   Result := true;
   if V <> 0 then
   begin
      if GetLocalIdent(Vp) then
      begin
      Level2(Vp);
      // Type cast test and assign
      if Error = 0 then
      begin
         case _Idents[V].Typ of
            TYP_UNDEF: begin  // Undef dasnt have Complex and Index
               _Idents[V].Typ := _Idents[Vp].Typ;
               if _Idents[VP].Typ = TYP_STRING then
               begin
                  New(_Vars[_Idents[V].Data].S); // no need of V index if undef :)
                  _Vars[_Idents[V].Data].S^ := _Vars[_Idents[Vp].Data].S^;
               end else begin
                  _Vars[_Idents[V].Data].I := _Vars[_Idents[Vp].Data].I;
               end;
            end;
            TYP_STRING: begin
               if _Idents[Vp].Typ = TYP_STRING then
               begin
                  if _Vars[_Idents[V].Data].I = 0  then
                  begin //Alloc
                     new(_Vars[_Idents[V].Data].S);
                  end;
                  _Vars[_Idents[V].Data].S^ := _Vars[_Idents[Vp].Data].S^; // copy
               end else begin
                  SetError(err_Type_mismatch);
               end;
            end;
            TYP_REAL: begin
               if _Idents[Vp].Typ = TYP_STRING then
               begin
                  SetError(err_Type_mismatch);
               end else begin
                  IntegerToReal(Vp,V);
               end;
            end;
            TYP_INTEGER: begin
               if _Idents[Vp].Typ = TYP_STRING then
               begin
                  SetError(err_Type_mismatch);
               end else begin
                  RealToInteger(Vp,V);
               end;
            end;
         end;
      end;
      end;
      FreePstr(Vp);
   end else begin
      Error := err_Internal_error;
   end;

   if Error <> 0 then Result := false;
end;

{------------------------------------------------------------------------------}
procedure   BTSmallBasic.RegisterFunction(Name, Args, Retval:string; The_Func :pointer; Ext:longword);
var A:longword;
    s:string;
begin
   A := Ident(Name,0 );
   if A <> 0 then
   begin // Add ne
      case Retval[1] of
        'S' : _Idents[A].Typ := TYP_STRING;
        'I' : _Idents[A].Typ := TYP_INTEGER;
        'R' : _Idents[A].Typ := TYP_REAL;
      end;
      S := '';
      if Ext <> 0  then
      begin
         S := '*1234';
         S[2] := char((Ext shr 24) and $FF);
         S[3] := char((Ext shr 16) and $FF);
         S[4] := char((Ext shr  8) and $FF);
         S[5] := char((Ext       ) and $FF);
      end;
      _Idents[A].Complex := Args + S;
      _Idents[A].Base := longword(The_Func);
      _Idents[A].Data := 0; // readu for result ???todo  is this used
   end;
end;

{----- R T L ------------------------------------------------------------------}



function    _Print(ex:longword; par:TinParray):longint; stdcall;
var Obj:BTSmallBasic;
begin
   if par[1] <> 0 then
   begin
      OBJ := BTSmallBasic(ex);
      OBJ.OutPut := OBJ.OutPut + BTSB_PStr(par[1])^;
      dispose(BTSB_PStr(par[1]));
   end;
end;

function    _Input(ex:longword; par:TinParray):longint; stdcall;
var Obj:BTSmallBasic;
    a:BTSB_PStr;
begin
   New(a);
   OBJ := BTSmallBasic(ex);
   a^ := Obj.Input;
   Result := longword(a);
end;

function    _Date(ex:longword; par:TinParray):longint; stdcall;
var Obj:BTSmallBasic;
    a:BTSB_PStr;
    Tim:TSYSTEMTIME;
    s:string;
begin
   GetLocalTime(Tim);
   New(a);
   a^ := '';
   str(Tim.wYear,s);   a^ := a^ + s + '.';
   str(Tim.wMonth,s);   a^ := a^ + s + '.';
   str(Tim.wDay,s);   a^ := a^ + s;
   Result := longword(a);
end;

function    _Time(ex:longword; par:TinParray):longint; stdcall;
var Obj:BTSmallBasic;
    a:BTSB_PStr;
    Tim:TSYSTEMTIME;
    s:string;
begin
   GetLocalTime(Tim);
   New(a);
   a^ := '';
   str(Tim.wHour,s);   a^ := a^ + s + '.';
   str(Tim.wMinute,s);   a^ := a^ + s + ':';
   str(Tim.wSecond,s);   a^ := a^ + s;
   Result := longword(a);
end;

// String functions
function    _Str(ex:longword; par:TinParray):longint; stdcall;
var a:BTSB_PStr;
    r:single;
    s,s1:string;
    i:integer;
begin
   New(a); r := single(pointer(@par[1])^);
   if Frac(r) = 0 then str(trunc(r),s)
                  else str(r:8:2,s);
   s1 := '';
   for i := 1 to length(s) do  if s[i] <> ' ' then s1 := s1 + s[i];
   a^ := s1;
   Result := longword(a);
end;

function    _Val(ex:longword; par:TinParray):longint; stdcall;
var r:single;
    i,c:integer;
    s,s1:string;
begin
   s := BTSB_PStr(par[1])^;
   c := length(s);
   s1 := '';
   for I := 1 to c do
   begin
      if s[i] in ['0'..'9','-','.','e','E'] then
      begin
         s1 := s1 + s[i];
      end;
   end;
   val(s1,r,c);
   if c <> 0 then r := 0;
   dispose(BTSB_PStr(par[1]));
   single(pointer(@Result)^) := r;
end;

function    _Mid(ex:longword; par:TinParray):longint; stdcall;
var a:BTSB_PStr;
begin
   New(a);
   a^ := Copy(BTSB_PStr(par[1])^,par[2],par[3]);
   dispose(BTSB_PStr(par[1]));
   Result := longword(a);
end;

function    _Left(ex:longword; par:TinParray):longint; stdcall;
var a:BTSB_PStr;
begin
   New(a);
   a^ := Copy(BTSB_PStr(par[1])^,1,par[2]);
   dispose(BTSB_PStr(par[1]));
   Result := longword(a);
end;

function    _Right(ex:longword; par:TinParray):longint; stdcall;
var a:BTSB_PStr;
    i:integer;
begin
   New(a);
   i := length(BTSB_PStr(par[1])^);
   if par[2] < i then
   begin
      a^ := Copy(BTSB_PStr(par[1])^,i - par[2] + 1, par[2]);
   end else begin
      a^ := BTSB_PStr(par[1])^;
   end;
   dispose(BTSB_PStr(par[1]));
   Result := longword(a);
end;

function    _Char(ex:longword; par:TinParray):longint; stdcall;
var a:BTSB_PStr;
begin
   New(a);
   a^:=' ';
   a^[1] := char(BTSB_PStr(par[1])^[par[2]]);
   dispose(BTSB_PStr(par[1]));
   Result := longword(a);
end;

function    _Chr(ex:longword; par:TinParray):longint; stdcall;
var a:BTSB_PStr;
begin
   New(a);
   a^:=' ';
   a^[1] := char(par[1] and $FF);
   Result := longword(a);
end;

function    _Asc(ex:longword; par:TinParray):longint; stdcall;
begin
   Result := Longword(byte(BTSB_PStr(par[1])^[1]));
   dispose(BTSB_PStr(par[1]));
end;

function    _Pos(ex:longword; par:TinParray):longint; stdcall;
begin
   Result := Pos(BTSB_PStr(par[1])^,BTSB_PStr(par[2])^);
   dispose(BTSB_PStr(par[1]));
   dispose(BTSB_PStr(par[2]));
end;

function    _Trim(ex:longword; par:TinParray):longint; stdcall;
var a:BTSB_PStr;
    i,l:integer;
    s:string;
begin
   New(a);
   a^ := '';
   s := BTSB_PStr(par[1])^;

   L := Length(S);
   I := 1;
   while (I <= L) and (S[I] <= ' ') do Inc(I);
   if I > L then S := '' else
   begin
      while S[L] <= ' ' do Dec(L);
      S := Copy(S, I, L - I + 1);
   end;
   a^ := s;
   dispose(BTSB_PStr(par[1]));
   Result := longword(a);
end;

function    _Len(ex:longword; par:TinParray):longint; stdcall;
begin
   Result := length(BTSB_PStr(par[1])^);
   dispose(BTSB_PStr(par[1]));
end;

function    _NL(ex:longword; par:TinParray):longint; stdcall;
var a:BTSB_PStr;
begin
   New(a);
   a^:=#13#10;
   Result := longword(a);
end;

// Math functions
function    _Rnd(ex:longword; par:TinParray):longint; stdcall;
begin
   single(pointer(@Result)^) := random;
end;

function    _Int(ex:longword; par:TinParray):longint; stdcall;
begin
   Result := Trunc(single(pointer(@par[1])^));
end;

function    _Frac(ex:longword; par:TinParray):longint; stdcall;
begin
   single(pointer(@Result)^) := Frac(single(pointer(@par[1])^));
end;

function    _Sqr(ex:longword; par:TinParray):longint; stdcall;
begin
   single(pointer(@Result)^) := sqrt(single(pointer(@par[1])^));
end;

function    _Abs(ex:longword; par:TinParray):longint; stdcall;
begin
   single(pointer(@Result)^) := abs(single(pointer(@par[1])^));
end;

function    _Exp(ex:longword; par:TinParray):longint; stdcall;
begin
   single(pointer(@Result)^) := exp(single(pointer(@par[1])^));
end;

function    _Log(ex:longword; par:TinParray):longint; stdcall;
begin
   single(pointer(@Result)^) := ln(single(pointer(@par[1])^));
end;

const Rad = Pi/180.0;

function    _Sin(ex:longword; par:TinParray):longint; stdcall;
begin
   single(pointer(@Result)^) := sin(single(pointer(@par[1])^)*Rad);
end;

function    _Cos(ex:longword; par:TinParray):longint; stdcall;
begin
   single(pointer(@Result)^) := cos(single(pointer(@par[1])^)*Rad);
end;

function    _Atan(ex:longword; par:TinParray):longint; stdcall;
begin
   single(pointer(@Result)^) := arctan(single(pointer(@par[1])^)*Rad);
end;

function    _Round(ex:longword; par:TinParray):longint; stdcall;
begin
   Result := Round(single(pointer(@par[1])^));
end;

function    _Sgn(ex:longword; par:TinParray):longint; stdcall;
var r:real;
begin
   Result := 0;
   if r < 0 then Result := -1;
   if r > 0 then Result := 1;
end;

function    _Pi(ex:longword; par:TinParray):longint; stdcall;
begin
   single(pointer(@Result)^) := Pi;
end;


procedure   BTSmallBasic.initrtl;
begin
   randomize;

   RegisterFunction('PRINT','(S)','I',@_Print,longword(self));
   RegisterFunction('INPUT','()','S',@_Input,longword(self));
   RegisterFunction('DATE','()','S',@_Date,longword(self));
   RegisterFunction('TIME','()','S',@_Time,longword(self));

   RegisterFunction('STR','(R)','S',@_Str,0);
   RegisterFunction('VAL','(S)','R',@_Val,0);
   RegisterFunction('MID','(SII)','S',@_Mid,0);
   RegisterFunction('LEFT','(SI)','S',@_Left,0);
   RegisterFunction('RIGHT','(SI)','S',@_Right,0);
   RegisterFunction('CHAR','(SI)','S',@_Char,0);   
   RegisterFunction('CHR','(I)','S',@_Chr,0);
   RegisterFunction('ASC','(S)','I',@_Asc,0);
   RegisterFunction('POS','(SS)','I',@_Pos,0);
   RegisterFunction('TRIM','(S)','S',@_Trim,0);
   RegisterFunction('LEN','(S)','I',@_Len,0);
   RegisterFunction('NL','()','S',@_Nl,0);

   RegisterFunction('RND','()','R',@_Rnd,0);
   RegisterFunction('INT','(R)','I',@_Int,0);
   RegisterFunction('FRAC','(R)','R',@_Frac,0);
   RegisterFunction('SQR','(R)','R',@_Sqr,0);
   RegisterFunction('ABS','(R)','R',@_Abs,0);
   RegisterFunction('EXP','(R)','R',@_Exp,0);
   RegisterFunction('LOG','(R)','R',@_Log,0);
   RegisterFunction('SIN','(R)','R',@_Sin,0);
   RegisterFunction('COS','(R)','R',@_Cos,0);
   RegisterFunction('ATAN','(R)','R',@_Atan,0);
   RegisterFunction('ROUND','(R)','I',@_Round,0);
   RegisterFunction('SGN','(R)','I',@_Sgn,0);
   RegisterFunction('PI','()','R',@_Pi,0);

end;

end.
