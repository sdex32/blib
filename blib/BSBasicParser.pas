unit BSBasicParser;

interface
{
   Small Basic   parser v 0.2.0

}
uses BLangScanner, BIdents, BStack, BCodeTree;

type  BTSBasicParser = class
         private
            aBlock      : longword;
            aError      : integer;
            aIdents     : BTIdents;
            aStack      : BTStack;    // did i need this
            aScan       : BTLangScanner;
            aScanProp   : BTLangScanner_Prop;
            aCTree      : BTCodeTree;
            procedure   _ResetVars;
            procedure   _BLOCK;
            procedure   _REM(m:longword);
            procedure   _IF;
            procedure   _END;
            procedure   _FOR;
            procedure   _DATA;
            procedure   _RESET;
            procedure   _READ;
            procedure   _GOTO;
            procedure   _RETURN;
            procedure   _DIM;
            procedure   _BREAK;
            procedure   _CONTINUE;
            procedure   _FUNC;
            procedure   _CALL;
            procedure   _INVOKE;
            procedure   _DEF;
            procedure   _WHILE;
            procedure   _LOOP;
            procedure   _OPTION;
            procedure   _CHOOSE;
            procedure   _HALT;
            procedure   _GOSUB;
            procedure   _TEXT;
            procedure   _EXPRESSION;
         public
            constructor Create(Tree:BTCodeTree);
            destructor  Destroy; override;
            procedure   Reset;
            function    Parse:longint;
            procedure   Load(txt: string);
            function    LoadFromFile(const file_name: string):boolean;
//GetErrorText
      end;



implementation

const CMD_count = 57;
      SB_ResWord : array [1..CMD_count] of string = (
   { 1}'IF',      { 2}'THEN',    { 3}'END',     { 4}'FOR',     { 5}'TO',
   { 6}'STEP',    { 7}'NEXT',    { 8}'DATA',    { 9}'RESET',   {10}'READ',
   {11}'GOTO',    {12}'ELSE',    {13}'ON',      {14}'RETURN',  {15}'REM',
   {16}'OR',      {17}'AND',     {18}'NOT',     {19}'XOR',     {20}'DIM',
   {21}'SHR',     {22}'SHL',     {23}'+',       {24}'-',       {25}'*',
   {26}'/',       {27}'%',       {28}'^',       {29}'(',       {30}')',
   {31}',',       {32}';',       {33}'<>',      {34}'>=',      {35}'<=',
   {36}'=',       {37}'>',       {38}'<',       {39}'[',       {40}']',
   {41}'BREAK',   {42}'CONTINUE',{43}'FUNC',    {44}'CALL',    {45}'INVOKE',
   {46}'DEF',     {47}'AS',      {48}'WHILE',   {49}'LOOP',    {50}'OPTION',
   {51}'CHOOSE',  {52}'CASE',    {53}'STRUCT',  {54}'DO',      {55}'.',
   {56}'HALT',    {57}'GOSUB'
   );

   {tokens}
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
   C_ELSE           = 12;
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
   C_BREAK          = 41;
   C_CONTINUE       = 42;
   C_SUB            = 43;
   C_CALL           = 44;
   C_INVOKE         = 45;
   C_DEF            = 46;
   C_AS             = 47;
   C_WHILE          = 48;
   C_LOOP           = 49;
   C_OPTION         = 50;
   C_CHOOSE         = 51;
   C_CASE           = 52;
   C_STRUCT         = 53;
   C_DO             = 54;
   C_DOT            = 55;
   C_HALT           = 56;
   C_GOSUB          = 57;

   err_ParserBase                 = -100;

   err_ExpectedThen               = err_ParserBase + -1;
   err_SyntaxError                = err_ParserBase + -2;
   err_OnlyRootBlock              = err_ParserBase + -3;
   err_OnlyInBlock                = err_ParserBase + -4;
   err_UnsupportedInThisContex    = err_ParserBase + -5;

const max_error_cnt =  2;
      Error_text : array [1..max_error_cnt] of string = (
        'Unterminated string constant',
        'Invalid char constant'
//todo
      );



//------------------------------------------------------------------------------
constructor BTSBasicParser.Create(Tree:BTCodeTree);
begin
   aCTree := Tree;
   aIdents := BTIdents.Create(nil);
   aStack  := BTStack.Create(1024);
   aScanProp.CaseSense := false;
   aScanProp.ResWord := @SB_ResWord[1];
   aScanProp.ResWordBase := 1;
   aScanProp.ResWordSize := CMD_count;
   aScanProp.StrOpenChar := '"''';
   aScanProp.StrDoubleChar := #0;
   aScanProp.StrSpecialChar := '~';
   aScanProp.StrSpecialList := '~tnec';
   aScanProp.StrSpecialInterp := '~'+#9+#13+#27+#10;
   aScanProp.ErrorBase := 0;
   aScan   := BTLangScanner.Create(aScanProp);
   _ResetVars;
end;

//------------------------------------------------------------------------------
destructor  BTSBasicParser.Destroy;
begin
   aScan.Free;
   aStack.Free;
   aIdents.Free;
   inherited;
end;

{------------------------------------------------------------------------------}
procedure   BTSBasicParser.Load(txt: string);
begin
   aScan.LoadScript(txt);
end;

{------------------------------------------------------------------------------}
function    BTSBasicParser.LoadFromFile(const file_name: string) :boolean;
begin
   Result := aScan.LoadScriptFromFile(File_name)
end;

{------------------------------------------------------------------------------}
procedure   BTSBasicParser.Reset;
begin
   aScan.Reset;
   aStack.Reset;
   aIdents.Reset;
   aCTree.Reset;
   _ResetVars;
end;

{------------------------------------------------------------------------------}
procedure   BTSBasicParser._ResetVars;
begin
   aError  := 0;
   aBlock  := 0;
end;

{------------------------------------------------------------------------------}
function    BTSBasicParser.Parse:longint;
begin
   _BLOCK;
   Result := aError;
end;


(*
  procedure _TRB; // Test not  Root Block
   begin
      if aBlock <> 1 then aError := err_OnlyRootBlock;
   end;

   procedure _TRB_0; // Test Root Block
   begin
      if aBlock = 1 then aError := err_OnlyInBlock;
   end;
 *)
{------------------------------------------------------------------------------}
procedure   BTSBasicParser._BLOCK;



begin
   if aError <> 0 then Exit;
   inc(aBlock);
   repeat
      aScan.GetToken;
      case aScan.Token of
        C_IF          : _IF;
        C_FOR         : _FOR;
        C_DATA        : _DATA;
        C_END         : _END;
        C_RESET       : _RESET;
        C_READ        : _READ;
        C_GOTO        : _GOTO;
        C_RETURN      : _RETURN;
        C_REM         : _REM(0);
        C_DIM         : _DIM;
        C_DIVIDE      : _REM(1);
        C_OPENBRACKET : _REM(2);
        C_BREAK       : _BREAK;
        C_CONTINUE    : _CONTINUE;
        C_SUB         : _FUNC;
        C_CALL        : _CALL;
        C_INVOKE      : _INVOKE;
        C_DEF         : _DEF;
        C_WHILE       : _WHILE;
        C_LOOP        : _LOOP;
        C_OPTION      : _OPTION;
        C_CHOOSE      : _CHOOSE;
        C_HALT        : _HALT;
        C_GOSUB       : _GOSUB;
        TOKEN_TEXT    : _TEXT;
        else aError := err_UnsupportedInThisContex;
      end;
   until (aScan.Token <= 0) or (aError <> 0);
   if aScan.Token < 0 then aError := aScan.Token;
   dec(aBlock);
end;

{------------------------------------------------------------------------------}
procedure   BTSBasicParser._REM(m:longword);
begin
   if m = 1 then  // comment type //xxxxx
   begin
     if aScan.PeekChar <> '/' then aError := err_SyntaxError;
   end else begin
      if m = 2 then // comment type (* xxx xxxx *)
      begin
         if aScan.PeekChar <> '*' then aError := err_SyntaxError;
         if aError = 0  then
         begin
            aScan.SkipToPattern('*)');
            Exit;
         end;
      end;
   end;
   if aError = 0 then aScan.ToNextLine;
end;


{------------------------------------------------------------------------------}
procedure   BTSBasicParser._IF;
var MustHaveEnd:boolean;
begin
   MustHaveEnd := false;
   aCTree._Begin;
   aCTree.Add_L(TNID_IF);
   aCTree._Begin;
      _EXPRESSION;
   aCTree._End(True,False);
   if aScan.GetToken = C_THEN then
   begin
      if aScan.FirstWord then MustHaveEnd := true;  // ne stava taka!!!!!!!:(

      aCTree.Add_R(TNID_THENELSE);
      aCTree._Begin;  // this will be add to right
      _BLOCK;
      aCTree._End(True,False);
      if aScan.Token = C_ELSE then
      begin
         aCTree._Begin; // this will be add to right
         _BLOCK;
         aCTree._End(False,True);
      end;
   end else aError := err_ExpectedThen;
//   C_END C_IF
   aCTree._End(True,False);
end;

{------------------------------------------------------------------------------}
procedure   BTSBasicParser._END;
begin

end;

{------------------------------------------------------------------------------}
procedure   BTSBasicParser._FOR;
begin

end;

{------------------------------------------------------------------------------}
procedure   BTSBasicParser._DATA;
begin

end;

{------------------------------------------------------------------------------}
procedure   BTSBasicParser._RESET;
begin

end;

{------------------------------------------------------------------------------}
procedure   BTSBasicParser._READ;
begin

end;

{------------------------------------------------------------------------------}
procedure   BTSBasicParser._GOTO;
begin

end;

{------------------------------------------------------------------------------}
procedure   BTSBasicParser._RETURN;
begin

end;

{------------------------------------------------------------------------------}
procedure   BTSBasicParser._DIM;
begin

end;

{------------------------------------------------------------------------------}
procedure   BTSBasicParser._BREAK;
begin

end;

{------------------------------------------------------------------------------}
procedure   BTSBasicParser._CONTINUE;
begin

end;

{------------------------------------------------------------------------------}
procedure   BTSBasicParser._FUNC;
begin

end;

{------------------------------------------------------------------------------}
procedure   BTSBasicParser._CALL;
begin

end;

{------------------------------------------------------------------------------}
procedure   BTSBasicParser._INVOKE;
begin

end;

{------------------------------------------------------------------------------}
procedure   BTSBasicParser._DEF;
begin

end;

{------------------------------------------------------------------------------}
procedure   BTSBasicParser._WHILE;
begin

end;

{------------------------------------------------------------------------------}
procedure   BTSBasicParser._LOOP;
begin

end;

{------------------------------------------------------------------------------}
procedure   BTSBasicParser._OPTION;
begin

end;

{------------------------------------------------------------------------------}
procedure   BTSBasicParser._CHOOSE;
begin

end;

{------------------------------------------------------------------------------}
procedure   BTSBasicParser._HALT;
begin

end;

{------------------------------------------------------------------------------}
procedure   BTSBasicParser._GOSUB;
begin

end;

{------------------------------------------------------------------------------}
procedure   BTSBasicParser._TEXT;
begin

end;

{------------------------------------------------------------------------------}
procedure   BTSBasicParser._EXPRESSION;
begin

end;


end.
