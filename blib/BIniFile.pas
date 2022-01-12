unit BIniFile;

interface

{Write is not thread save :(  }

function Ini_WriteKey(const FileName,KeySection,KeyName,Data:String):boolean;
function Ini_ReadKey(const FileName,KeySection,KeyName,DefValue:String; var Data:String):boolean;
function Ini_WriteKeyDW(const FileName,KeySection,KeyName:String; Data:longword):boolean;
function Ini_ReadKeyDW(const FileName,KeySection,KeyName:String; DefValue:longword; var Data:longword):boolean;
function Ini_WriteKeyHEX(const FileName,KeySection,KeyName:String; Data:longword):boolean;
function Ini_ReadKeyHEX(const FileName,KeySection,KeyName:String; DefValue:longword; var Data:longword):boolean;
function Ini_DeleteKey(const FileName,KeySection,KeyName:String):boolean;
function Ini_DeleteSection(const FileName,KeySection:String):boolean;

function Ini_RawReadKey(const RawData,KeySection,KeyName,DefValue:String; var Data:String):boolean;

implementation

uses BFileTools,BStrTools;

//------------------------------------------------------------------------------
function _Parser(const INI,KeySection,KeyName :String; var Sofs,Kofs,Dofs,BSofs,ESofs:longword; var Data:String):boolean;
var Limit :longword;
    C:Char;
    Section :String;
    SectionLen :longword;
    Key :String;
    KeyLen :longword;
    ofs, stage :longword;
    procedure _LeadSpaceOut;
    begin
       while ((INI[ofs] = ' ') or (INI[ofs] = #9)) and (ofs <= Limit) do inc(ofs);
    end;
    procedure _ByPassToNewLine;
    begin
       while (INI[ofs] <> #13) and (ofs <= Limit) do inc(ofs);
       inc(ofs); // Bypass #13
       if ofs <= Limit then if INI[ofs] = #10 then inc(ofs);
       if ofs > Limit then ofs := Limit;
       //dec(ofs); // one back
    end;
    function _Compare(const txt:String; txt_len:longword):boolean;
    var j:longword;
    begin
       Result := false;
       if (ofs + txt_len) <= Limit then
       begin
          Result := true; // preapre found
          for j := 1 to txt_len do
          begin
             if Upcase(INI[ofs + j - 1]) <> txt[j] then
             begin
                Result := false;
                break; // no need to loop
             end;
          end;
       end;
    end;
begin
   Limit := Length(INI);
   Sofs := 0;
   Kofs := 0;
   Dofs := 0;
   ESofs := 0;
   BSofs := 0;
   Data := '';
   Section := '['+UpperCase(KeySection)+']';
   SectionLen := length(Section);
   Key := UpperCase(KeyName);
   KeyLen := length(Key);
   ofs := 1;
   Result := false; // not found
   stage := 0;
   if (ofs > Limit) then Exit;
   repeat
      _LeadSpaceOut;
      if stage = 0 then
      begin
         if INI[ofs] = '[' then // section begin
         begin
            BSofs := ofs;
            if _Compare(Section,SectionLen) then
            begin
               stage := 1; // section found search key
               _ByPassToNewLine;
               Sofs := ofs; //+1;
               Continue;
            end else _ByPassToNewLine;
         end else _ByPassToNewLine;
      end else begin
         if INI[ofs] <> ';' then // comment
         begin
            // must be new line
            _LeadSpaceOut;
            if INI[ofs] = '['  then
            begin // new section stop
               ESofs := ofs; //+1
               break;
            end;
            if _Compare(Key,KeyLen) then
            begin
               Kofs := ofs; //+1
               ofs := ofs + KeyLen;
               _LeadSpaceOut;
               if ofs < Limit then
               begin
                  if INI[ofs] = '=' then
                  begin
                     inc(ofs); //by pass =
                     _LeadSpaceOut;
                     if ofs < Limit then
                     begin
                        // Copy data
                        Result := true; // found
                        repeat
                           C := INI[ofs];
                           if C <> #13 then
                           begin
                              Data := Data + C; // Slow ????
                              inc(ofs);
                           end else break;
                        until ofs > Limit;
                        _ByPassToNewLine;
                        Dofs := ofs; // + 1;
                        Data := Trim(Data);
                        break;
                     end;
                  end;
               end;
            end else _ByPassToNewLine;
         end else _ByPassToNewLine;
      end;
     // inc(ofs)
   until (ofs >= Limit) or (Dofs <> 0);
end;

//------------------------------------------------------------------------------
function __WriteAndRename(const FileName,F1,F2,F3:string):boolean;
var err:longint;
begin
   Result := false;
   if FileRename(FileName,FileName+'2')then
   begin
      err := 1;
      if FileSave(FileName+'1',ansistring(F1)) then
      begin
         if length(F2) > 0 then if not FileAdd(FileName+'1',ansistring(F2)) then err := 2;
         if err = 1 then
         begin
           if length(F3) > 0 then if not FileAdd(FileName+'1',ansistring(F3)) then err := 2;
           if err = 1 then if FileRename(FileName+'1',FileName) then err := 0;
         end;
      end;
      if err = 0 then
      begin
         FileDelete(FileName+'2');
         Result := true;
      end else begin
         //error
         FileDelete(FileName+'1');
         FileRename(FileName+'2',FileName);
      end;
   end;
end;

//------------------------------------------------------------------------------
function Ini_WriteKey(const FileName,KeySection,KeyName,Data:String):boolean;
var txt:AnsiString;
    stxt:string;
    S,K,D,F,BS,ES:longword;
    f1,f2,f3:String;
//    err:integer;
begin
   Result := false; // fault

   if not FileExist(FileName) then
   begin
      F1 := #13#10+'[' + KeySection + ']'+#13#10 + KeyName + '=' + Data +#13#10;
      if FileSave(FileName,ansistring(F1)) then Result := true;
      Exit;
   end;

   if FileLoad(FileName,txt) then
   begin

      stxt := string(txt);
      F := FileSize(FileName);

      if _Parser(stxt,KeySection,KeyName,S,K,D,BS,ES,f2) =  false then
      begin
         // not found key add
         F2 := '';
         F3 := '';
         if S = 0 then // not found section
         begin
            F2 := #13#10+'[' + KeySection + ']'+#13#10;
            S := F + 1;
         end else begin
//            SetLength(F3, F - S + 1);
            F3 := Copy(stxt, S, F - S + 1);
         end;
         F2 := F2 + KeyName + '=' + Data +#13#10;
         F1 := Copy(stxt,1,S - 1);
      end else begin
         if (K=0) or (D=0)  then Exit;  //???
         F2 := KeyName + '=' + Data +#13#10;
//         SetLength(F1, K - 1);
         F1 := Copy(stxt, 1, K - 1);
//         SetLength(F3, F - D);
         if F > D then F3 := Copy(stxt, D, F - D + 1)
                  else F3 := '';
      end;

      Result := __WriteAndRename(FileName,F1,F2,F3);
   end;
end;

//------------------------------------------------------------------------------
function Ini_DeleteKey(const FileName,KeySection,KeyName:String):boolean;
var txt:AnsiString;
    stxt:string;
    S,K,D,F,BS,ES:longword;
    f1,f2,f3:String;
begin
   Result := false; // fault

   if FileExist(FileName) then
   begin

      if FileLoad(FileName,txt) then
      begin

         stxt := string(txt);
         F := FileSize(FileName);

         if _Parser(stxt,KeySection,KeyName,S,K,D,BS,ES,f2) then
         begin
            if (K=0) or (D=0)  then Exit;  //???
            F1 := Copy(stxt, 1, K - 1);
            F2 := '';
            if F > D then F3 := Copy(stxt, D, F - D + 1)
                     else F3 := '';


            Result := __WriteAndRename(FileName,F1,F2,F3);
         end;
      end;
   end;
end;

//------------------------------------------------------------------------------
function Ini_DeleteSection(const FileName,KeySection:String):boolean;
var txt:AnsiString;
    stxt:string;
    S,K,D,F,BS,ES:longword;
    f1,f2,f3:String;
begin
   Result := false; // fault

   if FileExist(FileName) then
   begin

      if FileLoad(FileName,txt) then
      begin

         stxt := string(txt);
         F := FileSize(FileName);

         if _Parser(stxt,KeySection,';;;',S,K,D,BS,ES,f2) = false then
         begin
            if (BS=0) then Exit;  //???
            F1 := Copy(stxt, 1, BS - 1);
            F2 := '';
            if ES > 0 then F3 := Copy(stxt, D, F - ES + 1)
                      else F3 := '';

            Result := __WriteAndRename(FileName,F1,F2,F3);
         end;
      end;
   end;
end;

//------------------------------------------------------------------------------
function Ini_ReadKey(const FileName,KeySection,KeyName,DefValue:String; var Data:String):boolean;
var txt:AnsiString;
    S,K,D,BS,ES:longword;
begin
   Result := false; // fault
   Data := DefValue;
   if FileExist(FileName) then
   begin
      if FileLoad(FileName,txt) then
      begin
         Result := _Parser(string(txt),KeySection,KeyName,S,K,D,BS,ES,Data);
         if Result = true then Data := ClearQuotes(Data) else Data := DefValue;
      end;
   end;
end;

//------------------------------------------------------------------------------
function Ini_RawReadKey(const RawData,KeySection,KeyName,DefValue:String; var Data:String):boolean;
var S,K,D,BS,ES:longword;
begin
   Result := _Parser(RawData,KeySection,KeyName,S,K,D,BS,ES,Data);
   if Result = true then Data := ClearQuotes(Data) else Data := DefValue;
end;

//------------------------------------------------------------------------------
function Ini_WriteKeyDW(const FileName,KeySection,KeyName:String; Data:longword):boolean;
var s:String;
begin
   s := ToStr(Data);
   Ini_WriteKeyDW := Ini_WriteKey(FileName,KeySection,KeyName,s);
end;

//------------------------------------------------------------------------------
function Ini_ReadKeyDW(const FileName,KeySection,KeyName:String; DefValue:longword; var Data:longword):boolean;
var s:String;
begin
   Data := DefValue;
   Result := Ini_ReadKey(FileName,KeySection,KeyName,'0',s);
   if Result then
   begin
      Data := ToVal(s);
   end;
end;

//------------------------------------------------------------------------------
function Ini_WriteKeyHEX(const FileName,KeySection,KeyName:String; Data:longword):boolean;
var s:String;
begin
   s := ToHex(Data,8);
   Ini_WriteKeyHEX := Ini_WriteKey(FileName,KeySection,KeyName,s);
end;

//------------------------------------------------------------------------------
function Ini_ReadKeyHEX(const FileName,KeySection,KeyName:String; DefValue:longword; var Data:longword):boolean;
var s:String;
begin
   Data := DefValue;
   Result := Ini_ReadKey(FileName,KeySection,KeyName,'0',s);
   if Result then
   begin
      Data := HexVal(s);
   end;
end;


end.
