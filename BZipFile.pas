unit BZipFile;

interface

uses Bzlib1wrap, Windows, SysUtils;
// based on SciZipFile reader
// using Zlib1 wrapper

type

   _BTZIPCommonFileHeader = packed record
      VersionNeededToExtract: WORD;
      GeneralPurposeBitFlag: WORD;
      CompressionMethod: WORD;
      LastModFileTimeDate: DWORD;
      Crc32: DWORD;
      CompressedSize: DWORD;
      UncompressedSize: DWORD;
      FilenameLength: WORD;
      ExtraFieldLength: WORD;
   end;

   _BTZIPLocalFile = packed record
      LocalFileHeaderSignature: DWORD; //   (0x04034b50)
      CommonFileHeader: _BTZIPCommonFileHeader;
      filename: AnsiString;
      extrafield: AnsiString;
      CompressedData: longword; // offset in file
   end;

   _BTZIPFileHeader = packed record
      CentralFileHeaderSignature: DWORD; //   (0x02014b50)
      VersionMadeBy: WORD;
      CommonFileHeader: _BTZIPCommonFileHeader;
      FileCommentLength: WORD;
      DiskNumberStart: WORD;
      InternalFileAttributes: WORD;
      ExternalFileAttributes: DWORD;
      RelativeOffsetOfLocalHeader: DWORD;
      filename: AnsiString;
      extrafield: AnsiString;
      fileComment: AnsiString;
   end;

   _BTZIPEndOfCentralDir = packed record
      EndOfCentralDirSignature: DWORD; //  (0x06054b50)
      NumberOfThisDisk: WORD;
      NumberOfTheDiskWithTheStart: WORD;
      TotalNumberOfEntriesOnThisDisk: WORD;
      TotalNumberOfEntries: WORD;
      SizeOfTheCentralDirectory: DWORD;
      OffsetOfStartOfCentralDirectory: DWORD;
      ZipfileCommentLength: WORD;
   end;

   BTZipFile = class
      private
         Files: array of _BTZIPLocalFile;
         CentralDirectory: array of _BTZIPFileHeader;
         EndOfCentralDirectory: _BTZIPEndOfCentralDir;
         aZipFileComment: string;
         aCount :longword;
         aFileName :string;
         _aCpointFilesEnd :longword;
         _aCpointDirEnd :longword;
         function _GetName(i :longword) :string;
         function _ReadItem(Item :longword; var  Data :ansistring) :longint;
      public
         constructor Create;
         destructor  Destroy; override;
         function    LoadFile(const filename :string) :longint;
         function    ReadItemAsStr(item :longword; var Data :ansistring) :longint;
         function    ReadItemAsPtr(item :longword; var Data :pointer; var DataLen:longword) :longint;
         function    ReadItemToFile(item :longword; const FileName :string) :longint;
         function    FindItemByFullName(const name :string) :longword;
         function    WriteNewStrItemAndSave(const name :string; const Data :ansistring) :longint;
         function    WriteNewPtrItemAndSave(const name :string; Data :pointer; DataLen:longword) :longint;
         property    Items[i :longword] :string read _GetName;
         property    Count :longword read aCount;
         property    ZipFileComment :ansistring read aZipFileComment write aZipFileComment;
   end;


implementation


constructor BTZipFile.Create;
begin
   aCount := 0;
end;

destructor  BTZipFile.Destroy;
begin
   inherited;
end;


//------------------------------------------------------------------------------
function    BTZipFile.LoadFile(const filename :string) :longint;
var
  ZipFile: File of byte;
  fsize :longword;
  fofs :longword;
  signature: longword;
  n :longword;

   function reader(P:pointer; Sz:longword) :boolean;
   var i:longword;
   begin
      Result := true; //error
      if fofs + Sz < fsize then
      begin
         blockread(zipfile,p^,Sz,i);
         if i = Sz then
         begin
            inc(fofs,Sz);
            Result := false;
         end;
      end;
      if Result then Close(zipfile);
   end;

begin
   Result := -1; //OK
   aFileName := filename;
   Assign(ZipFile,filename);
   {$I-}
   reset(ZipFile);
   {$I+}
   if IOResult <> 0 then
   begin
      Exit; // File not exist;
   end;
   fsize := FileSize(ZipFile);
   fofs := 0;


   repeat //Find first data file
      if reader(@signature,4) then Exit;
   until (signature = $04034B50) or (eof(ZipFile));

   aCount := 0;
   SetLength(Files, aCount);
   SetLength(CentralDirectory, aCount);

   repeat
      if (signature = $04034B50) then
      begin
         inc(aCount); // file counter
         SetLength(Files, aCount);
         SetLength(CentralDirectory, aCount);
         with Files[aCount - 1] do
         begin
            LocalFileHeaderSignature := signature;
            if reader(@CommonFileHeader, SizeOf(CommonFileHeader)) then Exit;
            SetLength(filename, CommonFileHeader.FilenameLength);
            if reader(PChar(filename),CommonFileHeader.FilenameLength) then Exit;
            SetLength(extrafield, CommonFileHeader.ExtraFieldLength);
            if reader(PChar(extrafield),CommonFileHeader.ExtraFieldLength) then Exit;
            CompressedData := fofs;
            //Bypass compressed data
            seek(ZipFile,fofs + CommonFileHeader.CompressedSize );
            fofs := fofs + CommonFileHeader.CompressedSize;
         end;
      end;
      if reader(@signature,4) then Exit;
   until (signature <> ($04034B50)) or (eof(ZipFile));

   _aCpointFilesEnd := fofs - 4; // scip last signature

   n := 0;
   repeat
      if (signature = $02014B50) then
      begin
         inc(n);
         with CentralDirectory[n - 1] do
         begin
            CentralFileHeaderSignature := signature;
            if reader(@VersionMadeBy, 2) then Exit;
            if reader(@CommonFileHeader, SizeOf(CommonFileHeader)) then Exit;
            if reader(@FileCommentLength, 2) then Exit;
            if reader(@DiskNumberStart, 2) then Exit;
            if reader(@InternalFileAttributes, 2) then Exit;
            if reader(@ExternalFileAttributes, 4) then Exit;
            if reader(@RelativeOffsetOfLocalHeader, 4) then Exit;
            SetLength(filename, CommonFileHeader.FilenameLength);
            if reader(PChar(filename),CommonFileHeader.FilenameLength) then Exit;
            SetLength(extrafield, CommonFileHeader.ExtraFieldLength);
            if reader(PChar(extrafield),CommonFileHeader.ExtraFieldLength) then Exit;
            SetLength(fileComment, FileCommentLength);
            if reader(PChar(fileComment), FileCommentLength) then Exit;
         end;
      end;
      if reader(@signature, 4) then Exit;
   until (signature <> ($02014B50)) or (eof(ZipFile)) ;

   _aCpointDirEnd := fofs - 4; // scip last signature

   if signature = $06054B50 then
   begin
      EndOfCentralDirectory.EndOfCentralDirSignature := Signature;
      if reader(@EndOfCentralDirectory.NumberOfThisDisk,
                 SizeOf(EndOfCentralDirectory) - 4) then Exit;
      SetLength(aZipFileComment, EndOfCentralDirectory.ZipfileCommentLength);
      if reader(PChar(aZipFileComment),EndOfCentralDirectory.ZipfileCommentLength) then Exit;
   end;

   Close(ZipFile);
   Result := 0; //OK
end;

//------------------------------------------------------------------------------
function    BTZipFile._GetName(i: longword): string;
begin
   Result := '';
   if i > aCount then Exit;
   Result := Files[i].filename;
end;

//------------------------------------------------------------------------------
function    BTZipFile.FindItemByFullName(const Name :string) :longword;
var i :longword;
begin
   Result := $FFFFFFFF;
   if aCount = 0 then Exit;
   // find file
   for i := 0 to aCount - 1 do
   begin
      if Files[i].filename = name then
      begin
         Result := i;
         break;
      end;
   end;
end;

//------------------------------------------------------------------------------
function    BTZipFile._ReadItem(Item :longword; var  Data :ansistring) :longint;
var i,sz:longword;
    ZipFile:File of byte;
    p:pointer;
begin
   Result := -100;
   if aCount = 0 then Exit;

   sz := Files[Item].CommonFileHeader.CompressedSize;
   SetLength(Data,sz);

   Assign(ZipFile,afilename);
   reset(ZipFile);
   seek(ZipFile,Files[Item].CompressedData);
   p := @Data[1];
   blockread(zipfile,p^,sz,i);
   close(ZipFile);

   if i = sz then Result := 0;
end;

//------------------------------------------------------------------------------
function    BTZipFile.ReadItemAsStr(item :longword; var Data :ansistring) :longint;
var ad:longword;
    p:pointer;
begin
   SetLength(Data,Files[item].CommonFileHeader.UncompressedSize);
   p := @Data[1];
   ad := length(data);
   result := ReadItemAsPtr(item,p,ad);
end;

//------------------------------------------------------------------------------
function    BTZipFile.ReadItemAsPtr(item :longword; var Data :pointer; var DataLen:longword) :longint;
var ad:longword;
    s:ansistring;
begin
   Result := _ReadItem(item,s);
   if Result = 0 then
   begin
      Result := -102;
      if Data = nil then
      begin
         Data := nil;
         DataLen := Files[item].CommonFileHeader.UncompressedSize;
         ReallocMem(Data,DataLen);
         if Data = nil then Exit;
      end;
      bzlib1_rawmode(true); // zip data is in raw mode
      if bzlib1_PTRdecompress(@s[1],length(s),Data,DataLen) = 0 then
      begin
         ad := BZlib1_crc32(0,Data,DataLen);
         if Files[item].CommonFileHeader.Crc32 = ad then Result := 0;
      end else Result := -101;
   end;
end;

//------------------------------------------------------------------------------
function    BTZipFile.ReadItemToFile(item :longword; const FileName :string) :longint;
var f:file of byte;
    s:ansistring;
    p:pointer;
begin
   Result := ReadItemAsStr(item,s);
   if Result = 0 then
   begin
      Windows.DeleteFile(PChar(FileName));
      Result := -10;
      system.Assign(f,Filename);
      {$I-}
      rewrite(f);
      {$I+}
      if IOResult <> 0 then Exit;
      p := @s[1];
      {$I-}
      blockwrite(f,p^,length(s));
      {$I+}
      if IOResult <> 0 then p := nil;
      system.Close(f);
      if p <> nil then Result := 0; //OK
   end;
end;

//------------------------------------------------------------------------------
function    BTZipFile.WriteNewStrItemAndSave(const name :string; const Data :ansistring) :longint;
begin
   Result := WriteNewPtrItemAndSave(name,@Data[1],length(data));
end;

//------------------------------------------------------------------------------
function    BTZipFile.WriteNewPtrItemAndSave(const name :string; Data :pointer; DataLen:longword) :longint;
var p,pb:pointer;
    psz,fofs,dbegin,fbegin:longword;
    ZipFile:file of byte;
    NewZipFile:file of byte;
    newzip:boolean;
    buf:ansistring;
    cp,ccp:longword;
    er:longint;
    ItemFileHeader: _BTZIPCommonFileHeader;
    ItemDirHeader: _BTZIPFileHeader;
    ItemEndDirHeader: _BTZIPEndOfCentralDir;
    signature:longword;
    done:boolean;
    astr:ansistring;

   procedure CloseAll;
   begin
      {$I-}
      Close(ZipFile);
      Close(NewZipFile);
      if not done then Windows.DeleteFile(PChar(aFileName+'.b'));
      {$I+}
   end;

   function PutBytes(_dp:pointer; _dl:longword):boolean;
   var i:longword;
   begin
      Result := true; //error
      blockwrite(newzipfile,_dp^,_dl,i);
      if i = _dl then
      begin
         inc(fofs,_dl);
         Result := false;
      end;
      if Result then CloseAll;
   end;

   function CopyFilePart(cfp_sz:longword):boolean;
   begin
      Result := true; //error
      if not newzip then
      begin
         pb := @buf[1];
         cp := cfp_sz;
         inc(fofs,cp);
         repeat
            if cp > 32768 then ccp := 32768
                          else ccp := cp;
            {$I-}
            blockread(ZipFile,pb^,ccp);
            er := IOresult;
            blockwrite(NewZipFile,pb^,ccp);
            er := er + IOresult;
            {$I+}
            if er <> 0 then
            begin
               CloseAll;
               Exit;
            end;
            cp := cp - 32768;
         until (ccp < 32768) or (cp = 0);
      end;
      Result := false; //ok
   end;

begin
   fofs := 0;
   SetLength(buf,32768);
   astr := ansistring(name);
   done := false;
   Result := -150;

   // 1. compress data & prepare data
   ItemFileHeader.VersionNeededToExtract := 20;
   ItemFileHeader.GeneralPurposeBitFlag := 0; //2
   ItemFileHeader.CompressionMethod := 8;
   ItemFileHeader.LastModFileTimeDate := DateTimeToFileDate(Now); //sysutils
   ItemFileHeader.crc32 := BZlib1_crc32(0,Data,DataLen);
   ItemFileHeader.UncompressedSize := dataLen;
   ItemFileHeader.FilenameLength := length(astr);
   ItemFileHeader.ExtraFieldLength := 0;
   p := nil;
   psz := 0;
   BZlib1_rawmode(true);
   if BZlib1_PTRcompress(Data,DataLen,p,psz) <> 0 then Exit;
   ItemFileHeader.CompressedSize := psz;

   // 2. Create new file
   Assign(NewZipFile,aFileName+'.b');
   {$I-}
   rewrite(NewZipfile);
   {$I+}
   if IOResult <> 0 then Exit; // cant create
   // 3. open Existing if there was
   newzip := false;
   Assign(ZipFile,aFileName);
   {$I-}
   reset(ZipFile);
   {$I+}
   if IOResult <> 0 then  newzip := true;

   // 4. If not new copy to entry point
   Result := -152;
   if CopyFilePart(_aCpointFilesEnd) then Exit;

   // 5. Create new file item
   fbegin := fofs;
   signature := $04034B50;
   if PutBytes(@signature,4) then Exit;
   if PutBytes(@ItemFileHeader,sizeof(_BTZIPCommonFileHeader)) then Exit;
   if PutBytes(@astr[1],length(astr)) then Exit;
   if PutBytes(p,psz) then Exit;
   ReallocMem(p,0); // i dont need it release

   // 6. copy directory
   dbegin := fofs;
   Result := -154;
   if CopyFilePart(_aCpointDirEnd - _aCpointFilesEnd) then Exit;

   // 7. new dir data
   ItemDirHeader.CentralFileHeaderSignature := $02014b50;
   ItemDirHeader.VersionMadeBy := 20;
   ItemDirHeader.CommonFileHeader :=  ItemFileHeader;
   ItemDirHeader.FileCommentLength := 0;
   ItemDirHeader.DiskNumberStart := 0;
   ItemDirHeader.InternalFileAttributes := 1;
   ItemDirHeader.ExternalFileAttributes := $20;
   ItemDirHeader.RelativeOffsetOfLocalHeader := fbegin;

   if PutBytes(@ItemDirHeader,sizeof(_BTZIPFileHeader) - 3*4) then Exit; // skip 3 string pointers
   if PutBytes(@astr[1],length(astr)) then Exit; // Name

   // 8. write new dir end record
   inc(aCount);
   psz := fofs - dbegin;
   ItemEndDirHeader.EndOfCentralDirSignature := $06054B50;
   ItemEndDirHeader.NumberOfThisDisk := 0;
   ItemEndDirHeader.NumberOfTheDiskWithTheStart := 0;
   ItemEndDirHeader.TotalNumberOfEntriesOnThisDisk := aCount;
   ItemEndDirHeader.TotalNumberOfEntries := aCount;
   ItemEndDirHeader.SizeOfTheCentralDirectory := psz;
   ItemEndDirHeader.OffsetOfStartOfCentralDirectory := dbegin;
   cp := length(aZipFileComment);
   ItemEndDirHeader.ZipfileCommentLength := cp;
   if PutBytes(@ItemEndDirHeader,sizeof(_BTZIPEndOfCentralDir)) then Exit;
   if cp > 0 then
   begin
      astr := ansistring(aZipFileComment);
      if PutBytes(@astr[1],length(astr)) then Exit; // Name
   end;

   // 9. Close all files
   done := true;
   CloseAll;

   // 10. move new to old
   Result := -190;
   if Windows.DeleteFile(PChar(aFileName)) = false then Exit;
   if Windows.MoveFile(PChar(aFileName+'.b'), PChar(aFileName)) = false then Exit;

   Result := LoadFile(aFileName);
end;




end.
