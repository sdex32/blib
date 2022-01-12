unit BUTFtxtFile;

interface

function FileUTFLoad (const FileName :string; var Data:WideString ) :boolean;
function FileUTFSave (const FileName :string; const data :WideString; typUTF:longword) :boolean;


implementation

uses BFileTools, BUnicode;

function FileUTFLoad (const FileName :string; var Data:WideString) :boolean;
var a:ansistring;
begin
   Data := '';
   Result := FileLoadEx(FileName,a);
   if Result then // test BOM header (byte order mark)
   begin
      if length(a) > 3 then
      begin
         // UTF 8   EFBBBF
         if (byte(a[1]) = $EF) and (byte(a[2]) = $BB) and (byte(a[3]) = $BF)  then
         begin // UTF8
            Data := UTF82Unicode(a); //todo cut first 3 bytes
         end else begin
            // UTF 16 (BE)  FE FF
            if (byte(a[1]) = $FE) and (byte(a[2]) = $FF) then
            begin // UTF16 BE


            end else begin
               // UTF 16 (LE)  FF FE
               if (byte(a[1]) = $FF) and (byte(a[2]) = $FE) then
               begin // UTF16 LE


               end;
            end;
         end;
      end;
      if length(Data) = 0 then  Result := false;
   end;
end;

function FileUTFSave (const FileName :string; const data :WideString; typUTF:longword) :boolean;
//var a:ansistring;
begin
   Result := true;
end;


end.
