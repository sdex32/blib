unit Bzlib1wrap;

interface


function  BZlib1_Exist :boolean;
procedure BZlib1_Close;
procedure BZlib1_rawmode(on_off :boolean);
//return 0 = ok
//if OutStr='' then auto alloc
function  BZlib1_compress(const inStr :AnsiString; var outStr :AnsiString) :longint;
function  BZlib1_decompress(const inStr :AnsiString; var outStr :AnsiString) :longint;
// if des=nil auto alloc 
function  BZlib1_PTRcompress(Src :pointer; SrcLen:longword; var Des :pointer; var DesLen :longword) :longint;
function  BZlib1_PTRdecompress(Src :pointer; SrcLen:longword; var Des :pointer; var DesLen :longword) :longint;

function  BZlib1_adler32(crc:longword; Src:pointer; SrcLen:longword):longword;
function  BZlib1_crc32(crc:longword; Src:pointer; SrcLen:longword):longword;



implementation



uses  windows;

type
   TZStreamRec = packed record
      next_in :pointer;      // next input byte
      avail_in :longword;    // number of bytes available at next_in
      total_in :longword;    // total nb of input bytes read so far
      next_out :pointer;     // next output byte should be put here
      avail_out :Integer;    // remaining free space at next_out
      total_out :Longint;    // total nb of bytes output so far
      msg :pchar;            // last error message, NULL if no error
      internal :pointer;     // not visible by applications
      zalloc :pointer;       // used to allocate the internal state
      zfree :pointer;        // used to free the internal state
      AppData :pointer;      // private data object passed to zalloc and zfree
      data_type :integer;    // best guess about the data type: ascii or binary
      adler :longword;       // adler32 value of the uncompressed data
      reserved :longint;     // reserved for future use
   end;

var   zlib_hand :longword;
      zlib_raw  :longword;
      zlib_version  :function:longword; cdecl;
      zlib_compress2 :function(Des:pointer; var DesLen:longword; Src:pointer; SrcLen:longword; Level:longword):longint; cdecl;
      zlib_uncompress :function(Des:pointer; var DesLen:longword; Src:pointer; SrcLen:longword):longint; cdecl;
      zlib_crc32 : function(crc:longword; Src:pointer; SrcLen:longword):longword; cdecl;
      zlib_adler32 : function(crc:longword; Src:pointer; SrcLen:longword):longword; cdecl;
      zlib_deflateinit :function(var strm:TZStreamRec; Level:longword; ver:pointer; recsize:longword):longint; cdecl;
      zlib_deflateinit2 :function(var strm:TZStreamRec; Level,methode,Wbits,Memlev,Strategy:longword; ver:pointer; recsize:longword):longint; cdecl;
      zlib_deflate :function(var strm:TZStreamRec; Flush:longword):longint; cdecl;
      zlib_deflateend :function(var strm:TZStreamRec):longint; cdecl;
      zlib_inflateinit :function(var strm:TZStreamRec; version:pointer; stmlen:longword):longint; cdecl;
      zlib_inflateinit2 :function(var strm:TZStreamRec; windowbits:longint; version:pointer; stmlen:longword):longint; cdecl;
      zlib_inflate :function(var strm:TZStreamRec):longint; cdecl;
      zlib_inflateend :function(var strm:TZStreamRec):longint; cdecl;



//------------------------------------------------------------------------------
function  BZlib1_adler32(crc:longword; Src:pointer; SrcLen:longword):longword;
begin
   Result := 0;
   if BZlib1_Exist then
   begin
      Result := zlib_adler32(crc,src,SrcLen);
   end;
end;

//------------------------------------------------------------------------------
function  BZlib1_crc32(crc:longword; Src:pointer; SrcLen:longword):longword;
begin
   Result := 0;
   if BZlib1_Exist then
   begin
      Result := zlib_crc32(crc,src,SrcLen);
   end;
end;

//------------------------------------------------------------------------------
function  BZlib1_version :longword;
begin

end;

//------------------------------------------------------------------------------
function  BZlib1_Exist :boolean;
var Res :longint;
begin
   Res := 0;
   Result := false;
   if zlib_hand <> 0 then
   begin
      Result := true;
      Exit;
   end;



   zlib_hand := LoadLibrary('zlib1.dll');
//   if zlib_hand = 0 then zlib_hand := LoadLibrary('zlibwapi.dll');

   if zlib_hand <> 0 then
   begin
      zlib_version      := GetProcAddress(zlib_hand,'zlibVersion');
      if longword(@zlib_version)      = 0 then Res := -1;
      zlib_compress2    := GetProcAddress(zlib_hand,'compress2');
      if longword(@zlib_compress2)    = 0 then Res := -2;
      zlib_uncompress   := GetProcAddress(zlib_hand,'uncompress');
      if longword(@zlib_uncompress)   = 0 then Res := -3;
      zlib_crc32        := GetProcAddress(zlib_hand,'crc32');
      if longword(@zlib_crc32)        = 0 then Res := -4;
      zlib_adler32      := GetProcAddress(zlib_hand,'adler32');
      if longword(@zlib_adler32)      = 0 then Res := -5;
      zlib_deflateinit  := GetProcAddress(zlib_hand,'deflateInit_');
      if longword(@zlib_deflateinit)  = 0 then Res := -6;
      zlib_deflateinit2 := GetProcAddress(zlib_hand,'deflateInit2_');
      if longword(@zlib_deflateinit2) = 0 then Res := -6;
      zlib_deflate      := GetProcAddress(zlib_hand,'deflate');
      if longword(@zlib_deflate)      = 0 then Res := -7;
      zlib_deflateend   := GetProcAddress(zlib_hand,'deflateEnd');
      if longword(@zlib_deflateend)   = 0 then Res := -8;
      zlib_inflateinit  := GetProcAddress(zlib_hand,'inflateInit_');
      if longword(@zlib_inflateinit)  = 0 then Res := -9;
      zlib_inflateinit2 := GetProcAddress(zlib_hand,'inflateInit2_');
      if longword(@zlib_inflateinit2) = 0 then Res := -9;
      zlib_inflate      := GetProcAddress(zlib_hand,'inflate');
      if longword(@zlib_inflate)      = 0 then Res := -10;
      zlib_inflateend   := GetProcAddress(zlib_hand,'inflateEnd');
      if longword(@zlib_inflateend)   = 0 then Res := -11;

      Result := true;
      if Res <> 0 then
      begin
         FreeLibrary(zlib_hand);
         zLib_hand := 0;
         Result := false;
      end;
   end;
end;

//------------------------------------------------------------------------------
procedure BZlib1_Close;
begin
   if zlib_hand <> 0 then
   begin
      FreeLibrary(zlib_hand);
      zlib_hand := 0;
   end;
end;

//------------------------------------------------------------------------------
procedure BZlib1_rawmode(on_off :boolean);
begin
   if on_off = true then  zlib_raw := 1
                    else  zlib_raw := 0;
end;



const
   need_ver:ansistring='1.2.0';
//------------------------------------------------------------------------------
function _acomp(mode:longword; Src:pointer; SrcLen:longword; Des:pointer; var DesLen:longword) :longint;
var s:TZStreamRec;
    p:pointer;
begin
   Result := -100;
   if BZlib1_Exist then
   begin
      FillChar(s,sizeof(s),0);
      p := @need_ver[1];
      s.next_in := Src;
      s.avail_in := SrcLen;
      s.next_out := Des;
      s.avail_out := DesLen;
      if mode = 0 then
      begin
         // compress
         if zlib_raw = 1 then Result := zlib_deflateinit2(s,6,8,longword(-15),8,0,p,sizeof(s)) //8=deflate -14 8=memdefault 0=defstartegy $FFFFFFF2
                         else Result := zlib_deflateinit(s,6,p,sizeof(s));
      end else begin
         // decompress
         if zlib_raw = 1 then Result := zlib_inflateinit2(s,-14,p,sizeof(s))
                         else Result := zlib_inflateinit(s,p,sizeof(s));
      end;

      if Result = 0 then
      begin
         if mode = 0 then
         begin
            // compress
            Result := zlib_deflate(s,4); // flag = z_finish
            zlib_deflateend(s);
         end else begin
            // decompress
            Result := zlib_inflate(s);
            zlib_inflateend(s);
         end;
         if Result = 1 then Result := 0; // stream end
         if Result = 0 then DesLen := s.total_out;
      end;
   end;
end;

//------------------------------------------------------------------------------
function  _STRcomp(mode:longword; const inStr :AnsiString; var outStr :AnsiString) :longint;
var i,k,ki:longword;
begin
   Result := -100;
   i := length(inStr);
   if i > 0 then
   begin
      ki := length(outStr);
      if ki = 0 then
      begin
         k := i * 2;
         SetLength(outStr,k);
      end else k := ki;
      Result := _acomp(mode,@inStr[1],length(inStr),@outStr[1],k);
      if Result = 0  then
      begin
         if ki <> k then SetLength(outStr,k);
      end else begin
         outStr := '';
      end;
   end;
end;

//------------------------------------------------------------------------------
function  BZlib1_compress(const inStr :AnsiString; var outStr :AnsiString) :longint;
begin
   Result := _STRcomp(0,inStr,outStr);
end;

//------------------------------------------------------------------------------
function  BZlib1_decompress(const inStr :AnsiString; var outStr :AnsiString) :longint;
begin
   Result := _STRcomp(1,inStr,outStr);
end;

//------------------------------------------------------------------------------
function  _PTRcomp(Mode:longword; Src :pointer; SrcLen:longword; var Des :pointer; var DesLen :longword) :longint;
var k:longword;
    b:boolean;
begin
   b := false;
   Result := -100;
   if (SrcLen > 0) and (Src <> nil) then
   begin
      if Des = nil then
      begin
         if DesLen = 0 then DesLen := SrcLen * 3;
         ReallocMem(Des,DesLen);
         if Des = nil then Exit;
         b := true; // alloc here
      end;
      k := DesLen;
      Result := _acomp(mode,Src,SrcLen,Des,k);
      if Result = 0  then
      begin
         if DesLen <> k then
         begin
            Reallocmem(Des,k);
            DesLen := k;
         end;
      end else begin
         if b then ReallocMem(Des,0);
      end;
   end;
end;
//------------------------------------------------------------------------------
function  BZlib1_PTRcompress(Src :pointer; SrcLen:longword; var Des :pointer; var DesLen :longword) :longint;
begin
   Result := _PTRcomp(0,Src,SrcLen,Des,DesLen);
end;

//------------------------------------------------------------------------------
function  BZlib1_PTRdecompress(Src :pointer; SrcLen:longword; var Des :pointer; var DesLen :longword) :longint;
begin
   Result := _PTRcomp(1,Src,SrcLen,Des,DesLen);
end;



begin
   zlib_raw := 0; // default
   zlib_hand := 0;
end.
