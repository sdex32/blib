unit BLogFile;

//TODO to work for mutitasking must be only ansistring  copy from boristools

interface

uses Windows;

type
   BTLogFile = class
      private
        aLogname:String;
      public
        Enabled    :boolean;
        constructor Create(LogName:String='bdebug.log');
        destructor  Destroy; override;
        procedure   Log(data:Pchar; idata:longword); overload;
        procedure   Log(data:ShortString; idata:longword); overload;
        procedure   Log(data:String; idata:longword); overload; // WARNNING this is not tread save call
        property    LogFileName :String read aLogName write aLogName;
   end;

procedure BDebug(const FileName:String; data:pansichar; idata:longword); stdcall;
procedure BDebugS(const FileName:String; data:string; idata:longword);

implementation

var main_cs : _RTL_CRITICAL_SECTION;

constructor BTLogFile.Create(LogName:String = 'bdebug.log');
begin
   aLogName := LogName;
   Enabled := true;
end;

destructor  BTLogFile.Destroy;
begin
   inherited;
end;

type barray = array[0..0]of byte;
     pbarray = ^barray;

procedure BDebug(const FileName:String; data:pansichar; idata:longword); stdcall;
var
  ttt:_SystemTime;
  s,st:shortstring;
  f:file of byte;
  b:byte;
  j,fm:longint;
begin                          // tester in boris system
   if data = nil then exit;
   fm := FileMode;
   try
   EnterCriticalSection(main_cs);
//  getSystemTime(ttt);
   GetLocalTime(ttt);
   str(ttt.wYear,s);
   st :=      s + '.';
   str(ttt.wMonth,s);
   st := st + s + '.';
   str(ttt.wDay,s);
   st := st +  s + ' ';
   str(ttt.wHour,s);
   st := st +  s + ':';
   str(ttt.wMinute,s);
   st := st +  s + ':';
   str(ttt.wSecond,s);
   st := st +  s + ' |';

   FileMode := 2;
   system.assign(f,FileName);
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
   system.CloseFile(f);
   FileMode := 2;
   system.assign(f,FileName);
   {$I-}
   system.reset(f);
   {$I+}
   if system.IOResult = 0 then
   begin // good open
      seek(f,system.fileSize(F));  // WARNING this will slow down the system if file become too big
      BlockWrite(f,st[1],length(st));
      j := 0;
      while pbarray(data)^[j] <> 0 do inc(j);
      if j > 0 then BlockWrite(f,data^,j);
      str(idata,s);
      st := '|' + s + #13#10;
      BlockWrite(f,st[1],length(st));
   end;
   system.CloseFile(f);
   except
      // FileSave('d:\log\kdebug.log','exception  internal> ');
   end;
   FileMode := fm;
   LeaveCriticalSection(main_cs);
end;

procedure   BTLogFile.Log(data:Pchar; idata:longword);
begin
   if not Enabled then Exit;

   BDebug(aLogName,pansichar(data),idata);
end;

procedure   BTLogFile.Log(data:ShortString; idata:longword);
begin
   if not Enabled then Exit;

   data := data + #0;
   Log(@data[1],idata);
end;

procedure   BTLogFile.Log(data:String; idata:longword);
var a:AnsiString;
begin
   if not Enabled then Exit;

   a := AnsiString(data) + #0;
   Log(@a[1],idata);
end;

procedure BDebugS(const FileName:String; data:string; idata:longword);
var a:ansistring;
begin
   a := ansistring(data)+#0;
   BDebug(FileName,@a[1],idata);
end;



begin
   InitializeCriticalSection(main_cs);
   InitializeCriticalSectionandSpinCount(main_cs,2); // fock the delete  will be clean after terminate process
end.
