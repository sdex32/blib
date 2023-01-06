{ TODO
  speed Up string operations
  Error handling !!!!!!!!!!!!!!!!!!!!!!!!!! must do this
  remove //BUG
}
unit BFile;

interface


Type

    BTFile = class
    private
       aFileName : string;
       FF:File of byte;
       aLen:longword;
       aHand :longword;
       procedure SetPos(value:longword);
       function  GetPos:longword;
    public
       property    position : longword read GetPos write SetPos;
       property    length : longword read aLen;
       constructor Create;
       destructor  Destroy; override;
       function    eof:boolean;
       function    CreateNew( File_Name :string; mode :longword):longword;
       function    Open( File_Name :string; mode :longword):longword;
       function    OpenCreate(File_Name:string; mode:longword):longword;
       procedure   Close;
       procedure   Truncate;
       procedure   GotoEnd;
       function    Read(var Something; length_toread :longword):longword;
       function    Write(var Something; length_towrite :longword):longword;
       function    ReadZStr : string;
       procedure   WriteZStr( S :String);
       function    ReadStr : string;
       function    ReadCntStr(Count :longword) : string;
       procedure   WriteStr( S :String);
       procedure   WriteLnStr( S :String);
       function    LoadAllToStr:string;
       procedure   Seek(Pos:longword; Origin:longword);
       function    ReadByte : byte;
       function    ReadWord : word;
       function    ReadDWord : longword;
       function    ReadSingle : single;
       function    ReadDouble : double;
       procedure   WriteByte( b :byte);
       procedure   WriteWord( w :word);
       procedure   WriteDWord( d :longword);
       procedure   WriteSingle( s :single);
       procedure   WriteDouble( d :double);
    end;


implementation



////////////////////////////////////////////////////////////////////////////////

constructor BTFile.Create;
begin
   aHand := 0;
end;

destructor  BTFile.Destroy;
begin
   Close;
   inherited;
end;


function    BTFile.CreateNew(File_Name:string; mode:longword):longword;
begin
   Assign(FF,File_Name);
   {$I-}
   rewrite(FF);
   {$I+}
   if IOResult = 0 then
   begin
      aLen := FileSize(FF);
      aHand := 1;
   end;
aHand:=1; //BUG
   CreateNew := aHand;
end;

function    BTFile.Open(File_Name:string; mode:longword):longword;
begin
   aFileName := File_Name;
   Assign(FF,File_Name);
   {$I-}
   reset(FF);
   {$I+}
   if IOResult = 0 then
   begin
      aLen := FileSize(FF);
      aHand := 2;
   end;
   Open := aHand;
end;

function    BTFile.OpenCreate(File_Name:string; mode:longword):longword;
begin
   aFileName := File_Name;
   Assign(FF,File_Name);
   {$I-}
   reset(FF);
   {$I+}
   if IOResult = 0 then
   begin
      aLen := FileSize(FF);
      aHand := 2;
   end else begin
      aHand := CreateNew(File_Name,mode);
   end;
   OpenCreate := aHand;
end;


procedure   BTFile.Close;
begin
   if aHand <> 0 then
   begin
      system.Close(FF);
   end;
   aHand := 0;
end;

procedure   BTFile.Truncate;
begin
   if aHand <> 0 then system.Truncate(FF);
      { delete all after the position }
end;

procedure   BTFile.GotoEnd;
begin
   if aHand <> 0 then System.Seek(ff, FileSize(ff))
end;

procedure   BTFile.SetPos(value:longword);
begin
   if aHand <> 0 then System.seek(ff,value);
end;

function    BTFile.GetPos:longword;
begin
   if aHand <> 0 then GetPos := FilePos(FF)
                 else GetPos := 0;
end;

function    BTFile.Read(var Something; length_toread:longword):longword;
var error : longword;
begin
   error := 0;
   if aHand <> 0 then BlockRead(ff,Something,length_toread);
   Read := error;
end;

function    BTFile.Write(var Something; length_towrite:longword):longword;
var error : longword;
begin
   error := 0;
   if aHand <> 0 then BlockWrite(ff,Something,length_towrite);
   write := error;
end;

function    BTFile.eof:boolean;
begin
   if aHand <> 0 then eof := system.Eof(ff)
                 else eof := true;
end;

function    BTFile.ReadZStr : string;
var s:string;
    c:char;
begin
   s := '';
   repeat
      self.Read(c,1);
      if c <> #0 then s:= s + c;
   until (c = #0) or (self.eof);
   ReadZStr := s;
end;

procedure   BTFile.WriteZStr(S:String);
begin
   s := s + #0;
   self.write(s[1],system.length(S));
end;


function    BTFile.ReadStr : string;
var s:string;
    c:char;
begin
   s := '';
   repeat
      self.Read(c,1);
      if c <> #13 then s:= s + c;
   until (c = #13) or (self.eof);
   if Position > self.length then
   begin
      self.Read(c,1);
      if c <> #10 then Position := Position - 1;
   end;
   ReadStr := s;
end;


procedure   BTFile.WriteLnStr(S:String);
begin
   s := s + #13#10;
   self.write(s[1],system.length(S));
end;

procedure   BTFile.WriteStr(S:String);
begin
   self.write(s[1],system.length(S));
end;


function    BTFile.ReadCntStr(Count:longword) : string;
var s:string;
    i:longword;
    c:char;
begin
   s := '';
   if (Position + Count) > length then Count := Length - Position + 1;
   if Count > 0 then
      for i := 1 to Count do
      begin
         self.Read(C,1);
         s := s + c;
      end;
   ReadCntStr := S;
end;

function    BTFile.LoadAllToStr:string;
var s,sl:string;
    p:longword;
    ft : Text;
begin
   s := '';
   if aHand = 2 then
   begin
      p := Position;
      Close;
      assign(ft,aFileName);
      system.reset(ft);
      while not system.eof(ft) do
      begin
         readln(ft,sl);
         s := s + sl + #13 + #10;
      end;
      system.Close(ft);

      Open(aFileName,0);
      Position := p;
   end;
   LoadAllToStr := s;
end;

procedure    BTFile.Seek(Pos:longword; Origin:longword);
begin
   if Origin = 0 then SetPos(Pos); // from the begininig
   if Origin = 1 then SetPos(GetPos + Pos); // From Current possition
   if Origin = 2 then if aHand <> 0 then SetPos(longword(FileSize(ff)) + Pos); // From the end
end;

function    BTFile.ReadByte : byte;
var b:byte;
begin
   Read(b,1);
   ReadByte := b;
end;

function    BTFile.ReadWord : word;
var w:word;
begin
   Read(w,2);
   ReadWord := w;
end;

function    BTFile.ReadDWord : longword;
var d:longword;
begin
   Read(d,4);
   ReadDWord := d;
end;

function    BTFile.ReadSingle : single;
var s:single;
begin
   Read(s,sizeof(single));
   ReadSingle := s;
end;

function    BTFile.ReadDouble : double;
var d:double;
begin
   Read(d,sizeof(double));
   ReadDouble := d;
end;

procedure   BTFile.WriteByte( b :byte);
begin
   Write(b,1);
end;

procedure   BTFile.WriteWord( w :word);
begin
   Write(w,2);
end;

procedure   BTFile.WriteDWord( d : longword);
begin
   Write(d,4);
end;

procedure   BTFile.WriteSingle( s :single);
begin
   Write(s,sizeof(single));
end;

procedure   BTFile.WriteDouble( d :double);
begin
   Write(d,sizeof(double));
end;


end.
