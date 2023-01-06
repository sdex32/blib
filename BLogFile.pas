unit BLogFile;

//note
// Fork perfect in multask multi thread compiled with FreePascal used as debug tool in modules under IIS
// !!!! Dir not work with Delphi (promlem with multhi thread) !!! :(  bad embarcadero
// Working with strings from Delphi in multhi thread is not save :(

interface


type
   BTLogFile = class
      private
        aLognamePath:string;
        aLognameExt :string;
        aLognameName:string;
        aLogname    :string;
        procedure   _WS2A(const a:widestring; var o:ansistring);
        procedure   B_Debug(data:pansichar; idata:longword);
        procedure   SetLogName(value:string);
      public
        Enabled     :boolean;
        Multifile   :boolean;
        constructor Create(LogName:String='bdebug.log');
        destructor  Destroy; override;
        procedure   Log(data:Pansichar; idata:longword); overload;
        procedure   Log(data:Pwidechar; idata:longword); overload;
        procedure   Log(data:AnsiString; idata:longword); overload;
        procedure   Log(data:String; idata:longword); overload;
        property    LogFileName :String read aLogName write SetLogName;
   end;

procedure BDebug(const FileName:String; mode:longword; data:pansichar; idata:longword); stdcall;
procedure BDebugS(const FileName:String; mode:longword; data:string; idata:longword); stdcall;

implementation

uses Windows,BFileTools,BStrTools;

var main_cs : _RTL_CRITICAL_SECTION;


procedure   BTLogFile.SetLogName(value:string);
begin
   aLogname := value;
   aLogNamePath:= ExtractFilePath(value);
   aLogNameExt:= ExtractFileExt(value);
   aLogNameName := ExtractFileName(value);
end;

constructor BTLogFile.Create(LogName:String = 'bdebug.log');
begin
   SetLogName(LogName);
   Enabled := true;
   Multifile := false;
end;

destructor  BTLogFile.Destroy;
begin
   inherited;
end;

type barray = array[0..0]of byte;
     pbarray = ^barray;

procedure BTLogFile.B_Debug(data:pansichar; idata:longword);
var
  ttt:_SystemTime;
  ft,s,st:shortstring;
  dbuf:ansistring;
//  f:file of byte;
//  b:byte;
  j:longint;
//  fm:longword;
  fhand,w:longword;
  bdf:string;
//  fn:string; 1
  p:pointer;
    // cs : _RTL_CRITICAL_SECTION;
begin
   if data = nil then exit;
   if not Enabled then Exit;
  // in mod =1 logging  mandatory write
//  fm := FileMode;
   try
//     FileAdd('c:\log\kdebug.log','b_debug !');
   EnterCriticalSection(main_cs);
//  getSystemTime(ttt);
   GetLocalTime(ttt);
   str(ttt.wYear,s);
   st :=      s + '.';
   str(ttt.wMonth,s);
   st := st + s + '.';
   str(ttt.wDay,s);
   st := st +  s + ' ';
   ft := st;
   str(ttt.wHour,s);
   st := st +  s + ':';
   str(ttt.wMinute,s);
   st := st +  s + ':';
   str(ttt.wSecond,s);
   st := st +  s + ' |';


   if multifile then
   begin
      bdf := aLognamePath + aLognameName+string(ft)+aLognameExt;
   end else begin
      bdf := aLogname;
   end;

//  FileAdd('c:\log\kdebug.log','exist test '+bdf+'|');
   if not FileExist(bdf) then
   begin
//     FileAdd('c:\log\kdebug.log','crt new !');
     FileSave(bdf,#13#10);
   end;
(*
  FileMode := 2;
  system.assign(f,bdf);
  {$I-}
  system.reset(f);
  {$I+}
  if system.IOResult <> 0 then
  begin
     system.rewrite(f);
     b := 13;
     system.write(f,b);
     b := 10;
     system.write(f,b);
  end;
{$IFDEF FPC}
  system.Close(f);
{$ELSE}
  system.CloseFile(f);
{$ENDIF}
*)

//FileAdd('c:\log\kdebug.log','write open begin !');
   j := 0;
   while pbarray(data)^[j] <> 0 do inc(j);

   bdf := bdf +#0;
   fhand := CreateFile(@bdf[1], {GENERIC_WRITE or} FILE_APPEND_DATA , FILE_SHARE_WRITE ,nil,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL or FILE_FLAG_WRITE_THROUGH, 0);
   if fhand > 0 then
   begin
// FileAdd('c:\log\kdebug.log','write begin !');
      str(idata,s);
      SetLength(dbuf,length(st)+j+length(s)+3);

      dbuf := st + DataToStr(data,j)+'|' + s + #13#10;
      p := @dbuf[1];
//      setfilepointer(fhand,0,nil,FILE_END);  //no need FILE_APPEND_DATA

      writefile(fhand,p^,length(dbuf),w,nil);
//      writefile(fhand,st,length(st),w,nil);
//  1    writefile(fhand,data^,j,w,nil);
//      st := '|' + s + #13#10;
//      writefile(fhand,st,length(st),w,nil);
      CloseHandle(fhand);
// FileAdd('c:\log\kdebug.log','write done !');
   end;
(*
  FileMode := 2;    // this code work on delphi fut not on freepascal  writing on opaned file (sharingh)
  system.assign(f,bdf);
  {$I-}
  system.reset(f);
  {$I+}
  if system.IOResult = 0 then
  begin // good open
     FileAdd('c:\log\kdebug.log','begin seek');
     seek(f,system.fileSize(F));
     FileAdd('c:\log\kdebug.log','block write');
     BlockWrite(f,st[1],length(st));
     j := 0;
     while pbarray(data)^[j] <> 0 do inc(j);
     if j > 0 then BlockWrite(f,data^,j);
     str(idata,s);
     st := '|' + s + #13#10;
     BlockWrite(f,st[1],length(st));
  end;
{$IFDEF FPC}
  system.Close(f);
{$ELSE}
  system.CloseFile(f);
{$ENDIF}
*)
   except
//     on E:Exception do E.message sysutil unit
//     begin
    // OnLocalException('b_debug');
//        FileAdd('c:\kdebug.log','exception  internal> ');  // imposible  did I need that
//     end;

    // if d then system.CloseFile(f);


     //mainata ti
   end;
//  FileMode := fm;
   LeaveCriticalSection(main_cs);
end;


procedure   BTLogFile._WS2A(const a:widestring; var o:ansistring);
var ps,pd:pointer;
    i:longword;
begin
   o := '';
   i := length(a)*2;
   if i > 0 then
   begin
      SetLength(o,i);
      ps := @a[1];
      pd := @o[1];
      move(ps^,pd^,i);
   end;
end;

procedure   BTLogFile.Log(data:PWidechar; idata:longword);
var ps,pd:pointer;
    i:longword;
    a:ansistring;
    c:widechar;
begin
   a := '';
   i := 0;
   ps := data;
   try
      if ps <> nil then
      begin
         repeat
            c := pwidechar(ps)^;
            if c <> #0 then inc(i) else break;
            ps := pointer(nativeUint(ps)+2);
         until i = 0;
      end;
   except
      i := 0;
   end;
   if i > 0 then
   begin
      i := i*2;
      SetLength(a,i);
      ps := @data[1];
      pd := @a[1];
      move(ps^,pd^,i);
   end;
   Log(pansichar(@a[1]),idata);
end;

procedure   BTLogFile.Log(data:Pansichar; idata:longword);
begin
   B_Debug(data,idata);
end;

procedure   BTLogFile.Log(data:AnsiString; idata:longword);
begin
   data := data + #0;
   Log(pansichar(@data[1]),idata);
end;

procedure   BTLogFile.Log(data:String; idata:longword);
var a:AnsiString;
begin
   if sizeof(char) = 1 then a := AnsiString(data)  else _WS2A(data,a);
   a := a + #0;
   Log(pansichar(@a[1]),idata);
end;


procedure BDebug(const FileName:String; mode:longword; data:pansichar; idata:longword); stdcall;
var a:BTLogFile;
begin
   a := BTLogFile.Create(FileName);
   if (mode and 1) <> 0 then a.Multifile := true;
   a.Log(data,idata);
   a.Free;
end;

procedure BDebugS(const FileName:String; mode:longword; data:string; idata:longword); stdcall;
var a:BTLogFile;
begin
   a := BTLogFile.Create(FileName);
   if (mode and 1) <> 0 then a.Multifile := true;
   a.Log(data,idata);
   a.Free;
end;


begin
   InitializeCriticalSection(main_cs);
   InitializeCriticalSectionandSpinCount(main_cs,2); // fock the delete  will be clean after terminate process
end.
