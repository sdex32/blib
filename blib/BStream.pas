unit BStream;

interface

const
     BTStartOffsetFromBeginning=0;
     BTStartOffsetFromCurrent=1;
     BTStartOffsetFromEnd=2;

type
     PBTStreamData=^BTStreamData;
     BTStreamData=PACKED ARRAY[0..$7FFFFFFE] OF BYTE;

//     PBTStreamBuffer=^BTStreamBuffer;
//     BTStreamBuffer=PACKED ARRAY[1..8192] OF BYTE;

      BTStream = class
         private
            aMemorySize :longword;
            aPosition :longword;
            aSize :longword;
            aStreamData :PBTStreamData;
       StreamBitBuffer:LONGWORD;
       StreamBitBufferSize:BYTE;
            procedure Resize(NewSize:INTEGER);
       FUNCTION GetString:STRING;
       PROCEDURE SetString(Value:STRING);
       FUNCTION GetByte(BytePosition:INTEGER):BYTE;
       PROCEDURE SetByte(BytePosition:INTEGER;Value:BYTE);
         public
            constructor Create;
            destructor  Destroy; override;
       FUNCTION Assign(Src:BTStream):INTEGER;
       FUNCTION Append(Src:BTStream):INTEGER;
       FUNCTION AppendFrom(Src:BTStream;Counter:INTEGER):INTEGER;
       PROCEDURE Clear; VIRTUAL;
       FUNCTION Read(VAR Buf;Count:INTEGER):INTEGER; VIRTUAL;
       FUNCTION ReadAt(Position:INTEGER;VAR Buf;Count:INTEGER):INTEGER; VIRTUAL;
       FUNCTION Write(CONST Buf;Count:INTEGER):INTEGER; VIRTUAL;
       FUNCTION SeekEx(APosition:INTEGER):INTEGER; VIRTUAL;
       FUNCTION Seek(APosition:INTEGER):INTEGER; OVERLOAD;
       FUNCTION Seek(APosition,Origin:INTEGER):INTEGER; OVERLOAD;
       FUNCTION Position:INTEGER; VIRTUAL;
       FUNCTION Size:INTEGER; VIRTUAL;
       PROCEDURE SetSize(NewSize:INTEGER);
       FUNCTION ReadByte:BYTE;
       FUNCTION ReadWord:WORD;
       FUNCTION ReadDWord:LONGWORD;
       FUNCTION ReadLine:STRING;
       FUNCTION ReadString:STRING;
       PROCEDURE WriteByte(Value:BYTE);
       FUNCTION WriteByteCount(Value:BYTE;Count:INTEGER):INTEGER;
       PROCEDURE WriteWord(Value:WORD);
       PROCEDURE WriteDWord(Value:LONGWORD);
       PROCEDURE WriteShortInt(Value:SHORTINT);
       PROCEDURE WriteSmallInt(Value:SMALLINT);
       PROCEDURE WriteLongInt(Value:LONGINT);
       PROCEDURE WriteBoolean(Value:BOOLEAN);
       PROCEDURE WriteLine(Line:STRING);
       PROCEDURE WriteString(S:STRING);
       PROCEDURE WriteDataString(S:STRING);
       PROCEDURE ResetBits;
       FUNCTION ReadBit:BOOLEAN;
       FUNCTION ReadBits(BitsCount:BYTE):LONGWORD;
       FUNCTION ReadBitsSigned(BitsCount:BYTE):LONGINT;
       PROCEDURE WriteBit(Value:BOOLEAN);
       PROCEDURE WriteBits(Value:LONGWORD;BitsCount:BYTE);
       PROCEDURE WriteBitsSigned(Value:LONGINT;BitsCount:BYTE);
       PROCEDURE FlushBits;
       PROPERTY Text:STRING READ GetString WRITE SetString;
       PROPERTY Bytes[BytePosition:INTEGER]:BYTE READ GetByte WRITE SetByte; DEFAULT;
       PROPERTY BitsInBuffer:BYTE READ StreamBitBufferSize;
     end;

     BTMemoryStream = BTStream;

     BTFileStream=CLASS(BTStream)
      PRIVATE
       fFile:FILE;
      PUBLIC
       CONSTRUCTOR Create(Dateiname:STRING);
       CONSTRUCTOR CreateNew(Dateiname:STRING);
       DESTRUCTOR Destroy; OVERRIDE;
       FUNCTION Read(VAR Buf;Count:INTEGER):INTEGER; OVERRIDE;
       FUNCTION Write(CONST Buf;Count:INTEGER):INTEGER; OVERRIDE;
       FUNCTION SeekEx(APosition:INTEGER):INTEGER; OVERRIDE;
       FUNCTION Position:INTEGER; OVERRIDE;
       FUNCTION Size:INTEGER; OVERRIDE;
     END;

implementation

//------------------------------------------------------------------------------
constructor BTStream.Create;
begin
   aStreamData := nil;
   aPosition:=0;
   aSize:=0;
   aMemorySize:=0;
   ResetBits;
end;

//------------------------------------------------------------------------------
destructor  BTStream.Destroy;
begin
   Clear;
   inherited Destroy;
end;

FUNCTION BTStream.Assign(Src:BTStream):INTEGER;
VAR Remain,Count:INTEGER;
    Buf:BTStreamBuffer;
BEGIN
 Clear;
 RESULT:=0;
 Remain:=Src.Size;
 IF (Seek(0)<>0) OR (Src.Seek(0)<>0) THEN EXIT;
 WHILE Remain>=SIZEOF(BTStreamBuffer) DO BEGIN
  Count:=Src.Read(Buf,SIZEOF(BTStreamBuffer));
  Write(Buf,Count);
  INC(RESULT,Count);
  DEC(Remain,SIZEOF(BTStreamBuffer));
 END;
 Count:=Src.Read(Buf,Remain);
 Write(Buf,Count);
 INC(RESULT,Count);
END;

FUNCTION BTStream.Append(Src:BTStream):INTEGER;
VAR Remain,Count:INTEGER;
    Buf:BTStreamBuffer;
BEGIN
 RESULT:=0;
 Remain:=Src.Size;
 IF Src.Seek(0)<>0 THEN EXIT;
 WHILE Remain>=SIZEOF(BTStreamBuffer) DO BEGIN
  Count:=Src.Read(Buf,SIZEOF(BTStreamBuffer));
  Write(Buf,Count);
  INC(RESULT,Count);
  DEC(Remain,SIZEOF(BTStreamBuffer));
 END;
 Count:=Src.Read(Buf,Remain);
 Write(Buf,Count);
 INC(RESULT,Count);
END;

FUNCTION BTStream.AppendFrom(Src:BTStream;Counter:INTEGER):INTEGER;
VAR Remain,Count:INTEGER;
    Buf:BTStreamBuffer;
BEGIN
 RESULT:=0;
 Remain:=Counter;
 WHILE Remain>=SIZEOF(BTStreamBuffer) DO BEGIN
  Count:=Src.Read(Buf,SIZEOF(BTStreamBuffer));
  Write(Buf,Count);
  INC(RESULT,Count);
  DEC(Remain,SIZEOF(BTStreamBuffer));
 END;
 Count:=Src.Read(Buf,Remain);
 Write(Buf,Count);
 INC(RESULT,Count);
END;

procedure   BTStream.Clear;
begin
   ReallocMem(aStreamData,0); //free
   aPosition:=0;
   aSize:=0;
   aMemorySize:=0;
end;

procedure   BTStream.Resize(NewSize:longword);
var  NewMemorySize:longword;
begin
   aSize := NewSize;
   NewMemorySize:=((aSize div 65536)+1)*65536;
   if aMemorySize <> NewMemorySize then
   begin
      aMemorySize := NewMemorySize;
      ReallocMem(aStreamData,aMemorySize);
   end;
   if aPosition > aSize then aPosition := aSize;
END;

function   BTStream.Read(var Buf; Count:longword):longword;
VAR RealSize:INTEGER;
BEGIN
 RealSize:=Count;
 IF (StreamPosition+RealSize)>StreamSize THEN RealSize:=StreamSize-StreamPosition;
 IF RealSize>0 THEN BEGIN
  MOVE(StreamData^[StreamPosition],Buf,RealSize);
  INC(StreamPosition,RealSize);
 END;
 RESULT:=RealSize;
END;

FUNCTION BTStream.ReadAt(Position:INTEGER;VAR Buf;Count:INTEGER):INTEGER;
BEGIN
 IF Seek(Position)=Position THEN BEGIN
  RESULT:=Read(Buf,Count);
 END ELSE BEGIN
  RESULT:=0;
 END;
END;

FUNCTION BTStream.Write(CONST Buf;Count:INTEGER):INTEGER;
VAR RealSize,RemainSize:INTEGER;
BEGIN
 RealSize:=Count;
 IF (StreamPosition+RealSize)>StreamSize THEN RealSize:=StreamSize-StreamPosition;
 IF RealSize>0 THEN BEGIN
  MOVE(Buf,StreamData^[StreamPosition],RealSize);
  INC(StreamPosition,RealSize);
 END;
 RemainSize:=Count-RealSize;
 IF RemainSize>0 THEN BEGIN
  Resize(StreamSize+RemainSize);
  MOVE(Buf,StreamData^[StreamPosition],RemainSize);
  INC(StreamPosition,RemainSize);
 END ELSE BEGIN
  RemainSize:=0;
 END;
 RESULT:=RealSize+RemainSize;
END;

FUNCTION BTStream.SeekEx(APosition:INTEGER):INTEGER;
VAR AltePos,RemainSize:INTEGER;
BEGIN
 StreamPosition:=APosition;
 IF StreamPosition<0 THEN StreamPosition:=0;
 IF StreamPosition>StreamSize THEN BEGIN
  AltePos:=StreamSize;
  RemainSize:=StreamPosition-StreamSize;
  IF RemainSize>0 THEN BEGIN
   Resize(StreamSize+RemainSize);
   FILLCHAR(StreamData^[AltePos],RemainSize,#0);
  END;
  RESULT:=StreamPosition;
 END ELSE BEGIN
  RESULT:=StreamPosition;
 END;
END;

FUNCTION BTStream.Seek(APosition:INTEGER):INTEGER;
BEGIN
 RESULT:=SeekEx(APosition);
END;

FUNCTION BTStream.Seek(APosition,Origin:INTEGER):INTEGER;
BEGIN
 CASE Origin OF
  BTStartOffsetFromBeginning:RESULT:=SeekEx(APosition);
  BTStartOffsetFromCurrent:RESULT:=SeekEx(Position+APosition);
  BTStartOffsetFromEnd:RESULT:=SeekEx(Size-APosition);
  ELSE RESULT:=SeekEx(APosition);
 END;
END;

FUNCTION BTStream.Position:INTEGER;
BEGIN
 RESULT:=StreamPosition;
END;

FUNCTION BTStream.Size:INTEGER;
BEGIN
 RESULT:=StreamSize;
END;

PROCEDURE BTStream.SetSize(NewSize:INTEGER);
BEGIN
 StreamSize:=NewSize;
 IF StreamPosition>StreamSize THEN StreamPosition:=StreamSize;
 REALLOCMEM(StreamData,StreamSize);
END;

FUNCTION BTStream.ReadByte:BYTE;
VAR B:BYTE;
BEGIN
 IF Read(B,1)<>1 THEN BEGIN
  RESULT:=0;
 END ELSE BEGIN
  RESULT:=B;
 END;
END;

FUNCTION BTStream.ReadWord:WORD;
BEGIN
 RESULT:=ReadByte OR (ReadByte SHL 8);
END;

FUNCTION BTStream.ReadDWord:LONGWORD;
BEGIN
 RESULT:=ReadWord OR (ReadWord SHL 16);
END;

FUNCTION BTStream.ReadLine:STRING;
VAR C:CHAR;
BEGIN
 RESULT:='';
 WHILE Position<Size DO BEGIN
  Read(C,1);
  IF C=#10 THEN BEGIN
   BREAK;
  END ELSE IF C<>#13 THEN BEGIN
   RESULT:=RESULT+C;
  END;
 END;
END;

FUNCTION BTStream.ReadString:STRING;
VAR L:LONGWORD;
BEGIN
 L:=ReadDWord;
 SETLENGTH(RESULT,L);
 Read(RESULT[1],L);
END;

PROCEDURE BTStream.WriteByte(Value:BYTE);
BEGIN
 Write(Value,SIZEOF(BYTE));
END;

FUNCTION BTStream.WriteByteCount(Value:BYTE;Count:INTEGER):INTEGER;
VAR Counter:INTEGER;
BEGIN
 RESULT:=0;
 FOR Counter:=1 TO Count DO INC(RESULT,Write(Value,SIZEOF(BYTE)));
END;

PROCEDURE BTStream.WriteWord(Value:WORD);
BEGIN
 Write(Value,SIZEOF(WORD));
END;

PROCEDURE BTStream.WriteDWord(Value:LONGWORD);
BEGIN
 Write(Value,SIZEOF(LONGWORD));
END;

PROCEDURE BTStream.WriteShortInt(Value:SHORTINT);
BEGIN
 Write(Value,SIZEOF(SHORTINT));
END;

PROCEDURE BTStream.WriteSmallInt(Value:SMALLINT);
BEGIN
 Write(Value,SIZEOF(SMALLINT));
END;

PROCEDURE BTStream.WriteLongInt(Value:LONGINT);
BEGIN
 Write(Value,SIZEOF(LONGINT));
END;

PROCEDURE BTStream.WriteBoolean(Value:BOOLEAN);
BEGIN
 IF Value THEN BEGIN
  WriteByte(1);
 END ELSE BEGIN
  WriteByte(0);
 END;
END;

PROCEDURE BTStream.WriteLine(Line:STRING);
BEGIN
 IF LENGTH(Line)>0 THEN Write(Line[1],LENGTH(Line));
 Write(#13#10,2);
END;

PROCEDURE BTStream.WriteString(S:STRING);
VAR L:LONGWORD;
BEGIN
 L:=LENGTH(S);
 IF L>0 THEN Write(S[1],L);
END;

PROCEDURE BTStream.WriteDataString(S:STRING);
VAR L:LONGWORD;
BEGIN
 L:=LENGTH(S);
 WriteDWord(L);
 IF L>0 THEN Write(S[1],L);
END;

PROCEDURE BTStream.ResetBits;
BEGIN
 StreamBitBuffer:=0;
 StreamBitBufferSize:=0;
END;

FUNCTION BTStream.ReadBit:BOOLEAN;
BEGIN
 RESULT:=(ReadBits(1)<>0);
END;

FUNCTION BTStream.ReadBits(BitsCount:BYTE):LONGWORD;
BEGIN
 WHILE StreamBitBufferSize<BitsCount DO BEGIN
  StreamBitBuffer:=(StreamBitBuffer SHL 8) OR ReadByte;
  INC(StreamBitBufferSize,8);
 END;
 RESULT:=(StreamBitBuffer SHR (StreamBitBufferSize-BitsCount)) AND ((1 SHL BitsCount)-1);
 DEC(StreamBitBufferSize,BitsCount);
END;

FUNCTION BTStream.ReadBitsSigned(BitsCount:BYTE):LONGINT;
BEGIN
 RESULT:=0;
 IF BitsCount>1 THEN BEGIN
  IF ReadBits(1)<>0 THEN BEGIN
   RESULT:=-ReadBits(BitsCount-1);
  END ELSE BEGIN
   RESULT:=ReadBits(BitsCount-1);
  END;
 END;
END;

PROCEDURE BTStream.WriteBit(Value:BOOLEAN);
BEGIN
 IF Value THEN BEGIN
  WriteBits(1,1);
 END ELSE BEGIN
  WriteBits(0,1);
 END;
END;

PROCEDURE BTStream.WriteBits(Value:LONGWORD;BitsCount:BYTE);
BEGIN
 StreamBitBuffer:=(StreamBitBuffer SHL BitsCount) OR Value;
 INC(StreamBitBufferSize,BitsCount);
 WHILE StreamBitBufferSize>=8 DO BEGIN
  WriteByte((StreamBitBuffer SHR (StreamBitBufferSize-8)) AND $FF);
  DEC(StreamBitBufferSize,8);
 END;
END;

PROCEDURE BTStream.WriteBitsSigned(Value:LONGINT;BitsCount:BYTE);
BEGIN
 IF BitsCount>1 THEN BEGIN
  IF Value<0 THEN BEGIN
   WriteBits(1,1);
   WriteBits(LONGWORD(0-Value),BitsCount-1);
  END ELSE BEGIN
   WriteBits(0,1);
   WriteBits(LONGWORD(Value),BitsCount-1);
  END;
 END;
END;

PROCEDURE BTStream.FlushBits;
BEGIN
 IF StreamBitBufferSize>0 THEN BEGIN
  WriteByte(StreamBitBuffer SHL (8-StreamBitBufferSize));
 END;
 StreamBitBuffer:=0;
 StreamBitBufferSize:=0;
END;

FUNCTION BTStream.GetString:STRING;
BEGIN
 Seek(0);
 IF Size>0 THEN BEGIN
  SETLENGTH(RESULT,Size);
  Read(RESULT[1],Size);
 END ELSE BEGIN
  RESULT:='';
 END;
END;

PROCEDURE BTStream.SetString(Value:STRING);
BEGIN
 Clear;
 Write(Value[1],LENGTH(Value));
END;

FUNCTION BTStream.GetByte(BytePosition:INTEGER):BYTE;
VAR AltePosition:INTEGER;
BEGIN
 AltePosition:=Position;
 Seek(BytePosition);
 Read(RESULT,SIZEOF(BYTE));
 Seek(AltePosition);
END;

PROCEDURE BTStream.SetByte(BytePosition:INTEGER;Value:BYTE);
VAR AltePosition:INTEGER;
BEGIN
 AltePosition:=Position;
 Seek(BytePosition);
 Write(Value,SIZEOF(BYTE));
 Seek(AltePosition);
END;

CONSTRUCTOR BTFileStream.Create(Dateiname:STRING);
VAR Alt:BYTE;
BEGIN
 INHERITED Create;
 Alt:=FileMode;
 FileMode:=0;
 ASSIGNFILE(fFile,Dateiname);
 {$I-}RESET(fFile,1);{$I+}
 FileMode:=Alt;
 IF IOResult<>0 THEN {$I-}REWRITE(fFile,1);{$I+}
 IF IOResult<>0 THEN BEGIN
 END;
END;

CONSTRUCTOR BTFileStream.CreateNew(Dateiname:STRING);
VAR Alt:BYTE;
BEGIN
 INHERITED Create;
 Alt:=FileMode;
 FileMode:=2;
 ASSIGNFILE(fFile,Dateiname);
 {$I-}REWRITE(fFile,1);{$I+}
 FileMode:=Alt;
 IF IOResult<>0 THEN BEGIN
 END;
END;

DESTRUCTOR BTFileStream.Destroy;
BEGIN
 {$I-}CLOSEFILE(fFile);{$I+}
 IF IOResult<>0 THEN BEGIN
 END;
 INHERITED Destroy;
END;

FUNCTION BTFileStream.Read(VAR Buf;Count:INTEGER):INTEGER;
VAR I:INTEGER;
BEGIN
 {$I-}BLOCKREAD(fFile,Buf,Count,I);{$I+}
 IF IOResult<>0 THEN BEGIN
  RESULT:=0;
  EXIT;
 END;
 {$I-}StreamPosition:=FILEPOS(fFile);{$I+}
 IF IOResult<>0 THEN BEGIN
  RESULT:=0;
  EXIT;
 END;
 RESULT:=I;
END;

FUNCTION BTFileStream.Write(CONST Buf;Count:INTEGER):INTEGER;
VAR I:INTEGER;
BEGIN
 {$I-}BLOCKWRITE(fFile,Buf,Count,I);{$I+}
 IF IOResult<>0 THEN BEGIN
  RESULT:=0;
  EXIT;
 END;
 {$I-}StreamPosition:=FILEPOS(fFile);{$I+}
 IF IOResult<>0 THEN BEGIN
  RESULT:=0;
  EXIT
 END;
 RESULT:=I;
END;

FUNCTION BTFileStream.SeekEx(APosition:INTEGER):INTEGER;
BEGIN
 IF APosition<=Size THEN BEGIN
  {$I-}System.SEEK(fFile,APosition);{$I+}
  IF IOResult<>0 THEN BEGIN
   RESULT:=0;
   EXIT;
  END;
 END;
 {$I-}RESULT:=FILEPOS(fFile);{$I+}
 IF IOResult<>0 THEN BEGIN
  RESULT:=0;
 END;
END;

FUNCTION BTFileStream.Position:INTEGER;
BEGIN
 {$I-}RESULT:=FILEPOS(fFile);{$I+}
 IF IOResult<>0 THEN BEGIN
  RESULT:=0;
 END;
END;

FUNCTION BTFileStream.Size:INTEGER;
BEGIN
 {$I-}RESULT:=FILESIZE(fFile);{$I+}
 IF IOResult<>0 THEN BEGIN
  RESULT:=0;
 END;
END;



end.
