unit BLangScanner;

// version 1.1  27.07.2018 -----------------------------------------------------

interface

const
      TOKEN_EOF        = 0; { reserved words  must start from 1}
      TOKEN_NUMBER     = 2048; // special tokens
      TOKEN_STRING     = 2049; // if <0 then token = error code
      TOKEN_TEXT       = 2050;
      TOKEN_UNKNOWN    = 2051;

      //local eror code added to str.ErrorBase
      err_Unterminated_string_constant  =  -1;
      err_BadStringConstant             =  -2;
      err_Bad_hex_constant              =  -3;
      err_Too_Big_Integer               =  -4;


type  BTLangScanner_prop = record
         CaseSense       :boolean;
         ErrorInToken    :boolean;
         ResWord         :pointer;   // ptr to array [1..xx] of strings
         ResWordBase     :longword;  // value to be added to ResWord (zero start)
         ResWordSize     :longword;  // count of res words
         StrOpenChar     :string;    // "   '   or "'
         StrDoubleChar   :char;      // #0- no double char or ' for ''
         StrSpecialChar  :char;      //  / after that char is special char
         StrSpecialList  :string;    //  /nt       /t = tab  same position
         StrSpecialInterp:string;    //  /+#13+#9  #9 = tab
         ErrorBase       :longint;
      end;

      BTLangScanner = class
         private
            aTokenCnt    :longword;
            aTokenFW     :longword;
            aError       :longint;
            aErrorBool   :boolean;
            aToken       :longint;
            aTokenData   :String;
            aFirstWord   :boolean;
            aProp        :BTLangScanner_prop;
            aScript      :String;
            aOffset      :longword;
            aGotChar     :char;
            aResWordHash :pointer;
            aSkipedChars :longword;
            function    GetTokenColumn:longword;
            function    GetTokenRow:longword;
         public
            constructor Create(const tinit_prop :BTLangScanner_prop);
            destructor  Destroy; override;
            procedure   SetProp(id,value :longword);
            procedure   LoadScript(const Txt:String);
            function    LoadScriptFromFile(const FileName:string) :boolean;
            procedure   Reset;
            function    GetToken :longint;
            function    PeekToken :longint;
            procedure   PutBackChar;
            function    PeekChar :char;
            function    GetChar :char;
            procedure   ToNextLine;
            procedure   SkipToPattern(pat:string);
            procedure   ScanHex(CharLimit:longword);
            procedure   ScanNumber;
            function    SubScanTokenData(indx:longword;delim:String):String;
            function    GetErrorText(ErrCode:longint):string;
            property    TokenColumn :longword read GetTokenColumn;
            property    TokenRow :longword read GetTokenRow;
            property    Token :longint read aToken;
            property    TokenData :String read aTokenData;
            property    FirstWord :boolean read aFirstWord;
            property    GotChar :char read aGotChar;
            property    SkipedChars :longword read aSkipedChars;
            property    GetError :longint read aError;
            property    IsError :boolean read aErrorBool;
      end;




implementation

type   BT_LookTblHash = array [0..0] of longword;
       BTP_LookTblHash = ^BT_LookTblHash;
       BT_LookTbl = array [0..2047] of String;
       BTP_LookTbl = ^BT_LookTbl;

//------------------------------------------------------------------------------
function   _CalcHash(s:String):longword;
var i:integer;
const  //FNV-1a hash
    FNV_offset_basis = 2166136261;
    FNV_prime = 16777619;
begin
   Result := FNV_offset_basis;
   for i := 1 to length(s) do Result := (Result xor byte(s[i])) * FNV_prime;
end;

//------------------------------------------------------------------------------
constructor BTLangScanner.Create(const tinit_prop :BTLangScanner_prop);
var i:longword;
begin
   aResWordHash := nil;
   if aProp.ResWord <> nil then
   begin
      ReallocMem(aResWordHash,sizeof(longword)*(aProp.ResWordSize+1));
      if aResWordHash <> nil then
      begin
         for i := 0 to aProp.ResWordSize - 1 do
         begin
            BTP_LookTblHash(aResWordHash)[i] := _CalcHash(BTP_LookTbl(aProp.ResWord)[i]);
         end;
      end;
   end;
   aScript := '';
   Reset;
end;

//------------------------------------------------------------------------------
destructor  BTLangScanner.Destroy;
begin
   if aResWordHash <> nil then ReallocMem(aResWordHash,0);
   inherited;
end;

//------------------------------------------------------------------------------
procedure   BTLangScanner.SetProp(id,value :longword);
begin

end;

//------------------------------------------------------------------------------
procedure   BTLangScanner.LoadScript(const Txt:string);
begin
//todo utf conversion

   aScript := String(Txt) + #0;  //put The End
   Reset;
end;

//------------------------------------------------------------------------------
function    BTLangScanner.LoadScriptFromFile(const FileName:string) :boolean;
var s,s1:widestring;
    f:Text;
begin
   s := '';
   Result := false;
   assign(f,FileName);
   {$I-}
   system.reset(f);
   {$I+}
   if IOResult = 0 then
   begin
      while not eof(f) do
      begin
         readln(f,s1);    //todo why iam doing this
         s := s + s1 + #13 + #10;
      end;
      close(f);
   end;
   if length(s) > 0 then begin LoadScript(s); Result := true; end;
end;

//------------------------------------------------------------------------------
procedure   BTLangScanner.Reset;
begin
   aOffset := 1; //first char
   aToken := 0;
   aTokenData := '';
   aGotChar := #0;
   aSkipedChars := 0;
   aTokenCnt := 0;
   aTokenFW := 1;
end;

//------------------------------------------------------------------------------
function    BTLangScanner.PeekToken :longint;
var ao,ac,af:longword;
begin
   ao := aOffset;
   ac := aTokenCnt;
   af := aTokenFW;
   Result := GetToken;
   aOffset := ao;
   aTokenCnt := ac;
   aTokenFW := af;
end;

//------------------------------------------------------------------------------
function    BTLangScanner.GetToken :longint;
var i:longint;

   procedure _ScanString(C:char);
   begin
      aToken := TOKEN_STRING;
      GetChar; { bypass " }
      while True do
      begin
         GetChar;
         if (aGotChar >= #0) and (aGotChar <= #31) then
//         if aGotChar in [#0..#31] then
         begin
            aToken := aProp.ErrorBase + err_Unterminated_string_constant;
            break;
         end;
         if aGotChar = c then
         begin
            if aProp.StrDoubleChar = c then
            begin
               aGotChar := c;
            end else break; // the end of string
         end;
         if aGotChar = aProp.StrSpecialChar then
         begin
            GetChar; // get next
            i := Pos(aGotChar,aProp.StrSpecialList);
            if i<>0 then
            begin
               aGotChar := aProp.StrSpecialInterp[i];
            end else begin
               aToken := err_BadStringConstant;
               break;
            end;
         end;
         aTokenData := aTokenData + aGotChar;
      end;
   end;

   function  _Look_Up(Txt:String):longint;
   var w,j:longword;
       ph:BTP_LookTblHash;
       p:BTP_LookTbl;
   begin
      Result := TOKEN_UNKNOWN;
      p := aProp.ResWord;
      ph := aResWordHash;
      w := _CalcHash(Txt);
      if (aProp.ResWordSize <> 0) and (p <> nil) and (ph <> nil) then
      begin
         for j := 0 to aProp.ResWordSize - 1 do
         begin
            if ph[j] = w then
            begin
               if P^[j] = Txt then // if same hash
               begin
                  Result := j + aProp.ResWordBase;
                  break;
               end;
            end;
         end;
      end;
   end;


begin
   aSkipedChars := 0;
   aError := 0;
   aErrorBool := false;
   aToken := TOKEN_UNKNOWN;
   aTokenData := '';

//   While PeekChar in [#1..#31]
   While ((PeekChar >= #1) and (PeekChar <= #31)) do begin inc(aSkipedChars); GetChar; end; // skip blanks
   //uses SkipedChars for c style hex 0x1234 ????

   GetChar; // Get first data char

   case aGotChar of
      #0 : aToken := TOKEN_EOF;
      { group numbers }
      '0'..'9': begin
            PutBackChar;
            ScanNumber;
         end;
      { group strings }
      '"' : if Pos('"',aProp.StrOpenChar) <> 0 then _ScanString('"')
                                               else aToken := _Look_Up('"');
      '''' : if Pos('''',aProp.StrOpenChar) <> 0 then _ScanString('''')
                                               else aToken := _Look_Up('''');
      { group of text }
      '_','A'..'Z','a'..'z':
         begin
            while True do
            begin
               if aProp.CaseSense then aTokenData := aTokenData + aGotChar
                                  else aTokenData := aTokenData + UpCase(aGotChar);
//               if not(PeekChar in ['A'..'Z', 'a'..'z', '0'..'9', '_']) then Break;
               if not(    ((PeekChar >= 'A') and (PeekChar <= 'Z'))
                       or ((PeekChar >= 'a') and (PeekChar <= 'z'))
                       or ((PeekChar >= '0') and (PeekChar <= '9'))
                       or (PeekChar = '_') ) then break;
//                      PeekChar in ['A'..'Z', 'a'..'z', '0'..'9', '_']) then Break; // problem set wide char
               GetChar;
            end;
            aToken := _Look_Up(aTokenData);
            if aToken = TOKEN_UNKNOWN then aToken := TOKEN_TEXT;
         end;
      else  { Symbols }
         aTokenData := aGotChar;
         aToken := _Look_UP(aTokenData);
         if aToken <> TOKEN_UNKNOWN then
         begin // test enxt symbol for   2char tokens
            i := _Look_Up(aTokenData + PeekChar);
            if i <> TOKEN_UNKNOWN then
            begin
               GetChar;
               aTokenData := aTokenData + aGotChar;
               aToken := i
            end;
         end;
   end; // case

   if aToken < 0 then
   begin
      aToken := aProp.ErrorBase + aToken;
      aError := aToken;
      aErrorBool := true;
      if aProp.ErrorInToken then aToken := TOKEN_EOF;
   end;
   if Token > 0 then inc(aTokenCnt);
   if aTokenCnt = aTokenFW  then aFirstWord := true
                            else aFirstWord := false;

   Result := aToken;
end;


//------------------------------------------------------------------------------
procedure   BTLangScanner.PutBackChar;
begin
   if aOffset > 1 then  dec(aOffset);
end;

//------------------------------------------------------------------------------
function    BTLangScanner.PeekChar :char;
begin
   Result := aScript[aOffset];
end;

//------------------------------------------------------------------------------
function    BTLangScanner.GetChar :char;
begin
   aGotChar := aScript[aOffset];
   if aGotChar <> #0 then inc(aOffset);
   if (aGotChar = #13) then
   begin
      aTokenFW := aTokenCnt + 1; // next token will be on new line
      if PeekChar = #10 then inc(aOffset);
   end;
   Result := aGotChar;
end;

//------------------------------------------------------------------------------
//to skip rem fill tokendata
procedure   BTLangScanner.SkipToPattern(pat:string);
var j,i,done:longword;
    cc:char;
begin
   aToken := TOKEN_UNKNOWN;
   aTokenData := '';
   j := length(pat);  // if pat = '' then end is #13
   GetChar;
   while (aGotChar <> #0)do
   begin
      if j > 0 then
      begin
         if aGotChar = pat[1] then
         begin
            done := 1;
            if j > 1 then
            begin
               for i := 2 to j do
               begin
                  cc := aScript[aOffset + i - 2];
                  if cc = #0 then break;
                  if pat[i] = cc then inc(done);
               end;
            end;
            if done = j then break;
         end;
      end else begin
         if aGotChar = #13 then break;
      end;
      aTokenData := aTokenData + aGotChar;
      GetChar;
   end;
end;

//------------------------------------------------------------------------------
procedure   BTLangScanner.ScanHex(CharLimit:longword);
const HexCode : String = '0123456789ABCDEF';
var i:longword;
    DatLo,DatHi:longword;
    c:char;
begin
   aToken := TOKEN_NUMBER;
   aTokenData := '';
   i := 0;
   DatLo := 0;
   DatHi := 0;
   While (((UpCase(PeekChar) >= '0') and (UpCase(PeekChar) <= '9')) or ((UpCase(PeekChar) >= 'A') and (UpCase(PeekChar) <= 'F')))
//         UpCase(PeekChar) in ['0'..'9','A'..'F']) // not work with widechar
         and (PeekChar <> #0) do
   begin
      inc(i);
      if i > 8 then DatHi := (DatHi SHL 4) or (DatLo SHR 28);
      GetChar; // get real
      c := UpCase(aGotChar);
      aTokenData := aTokenData + c;
      DatLo := (DatLo SHL 4) + longword(Pos(c,HexCode))-1;
   end;
   if i = 0 then aToken := err_Bad_hex_constant; // not started
   if i > CharLimit then aToken := err_Too_Big_Integer;

   //TODO get result

end;

//------------------------------------------------------------------------------
procedure   BTLangScanner.ScanNumber;
var vv:longword;
begin
   aToken := TOKEN_UNKNOWN;
   aTokenData := '';
   vv := 0;
   {integer part}
//   while(PeekChar in ['0'..'9']) do
   while( (PeekChar >= '0') and (PeekChar <= '9') ) do
   begin
      GetChar;
      aTokenData := aTokenData + aGotChar;
      vv := (vv * 10) + longword(byte(aGotChar)-48);
   end;


//todo in C =.7
   { real part }
   if PeekChar = '.' then
   begin

//      while(PeekChar in ['0'..'9']) do
      while( (PeekChar >= '0') and (PeekChar <= '9') ) do
      begin
         GetChar;
         aTokenData := aTokenData + aGotChar;
         vv := (vv * 10) + longword(byte(aGotChar)-48);
      end;
   end;

//   if PeekChar in ['E','e'] then
   if( (PeekChar = 'E') or (PeekChar = 'e') ) then
   begin
      aTokenData := aTokenData + GetChar;
      if PeekChar = '-' then
      begin
         aTokenData := aTokenData + GetChar;
   //todo exp sign
      end;
   //   while(PeekChar in ['0'..'9']) do
      while( (PeekChar >= '0') and (PeekChar <= '9') ) do
      begin
         GetChar;
         aTokenData := aTokenData + aGotChar;
         vv := (vv * 10) + longword(byte(aGotChar)-48);
      end;
   end;

   //todo get result
   //todo corect test
end;



//------------------------------------------------------------------------------
function    BTLangScanner.SubScanTokenData(indx:longword;delim:String):String;
var  i,j,k : longword;
     c:Char;
begin
   Result := '';
   j := length(aTokenData);
   if j = 0 then Exit;
   i := 0;
   k := 0;  // counter start from 0
   while i < j do
   begin
      inc(i);
      c := aTokenData[i];
      if pos(c,delim) <> 0 then
      begin
         if k = indx then break;
         inc(k);
         continue;
      end;
      if k = indx then Result := Result + c;
   end;
end;

//------------------------------------------------------------------------------
procedure   BTLangScanner.ToNextLine;
begin
   aToken := TOKEN_UNKNOWN;
   aTokenData := '';
   aSkipedChars := 0;
//   while not(PeekChar in [#0,#13]) do
   while not( (PeekChar = #0) or (PeekChar = #13) ) do
   begin
      aTokenData := aTokenData + GetChar;
      inc(aSkipedChars);
   end;
end;

//------------------------------------------------------------------------------
function    BTLangScanner.GetTokenColumn:longword;
var i:longword;
begin
   Result := 1;
   for i := 1 to aOffset do
   begin
      inc(Result);
      if aScript[i] = #10 then dec(Result);
      if aScript[i] = #13 then Result := 1;
   end;
end;

//------------------------------------------------------------------------------
function    BTLangScanner.GetTokenRow:longword;
var i:longword;
begin
   Result := 1;
   for i := 1 to aOffset do
   begin
      if aScript[i] = #13 then inc(Result);
   end;
end;

//------------------------------------------------------------------------------
const max_error_cnt =  2;
      Error_text : array [1..max_error_cnt] of string = (
        'Unterminated string constant',
        'Invalid char constant'
//todo
      );

function    BTLangScanner.GetErrorText(ErrCode:longint):string;
begin
   ErrCode := abs(ErrCode -  aProp.ErrorBase);
   if (ErrCode > 0) and (ErrCode <= max_error_cnt ) then  Result := Error_text[ErrCode]
                                                    else  Result := 'Unknown Error';
end;


end.
