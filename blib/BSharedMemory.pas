unit BSharedMemory;

interface

function CreateSharedMemory(const IDname:string; TheSize:longword):longint;
function DestroySharedMemory(const IDname:string):longint;
function GetSharedMemorySize(const IDname:string):longword;
function AccessSharedMemory(const IDname:string; Get0_Set1 :longword; DataOffset:longword; Data:pointer; DataSize:longword):longint;



implementation

uses Windows;

//------------------------------------------------------------------------------
function CreateSharedMemory(const IDname:string; TheSize:longword):longint;
var er:longint;
    p,O:^longword;
begin
   Result := 0;
   TheSize := TheSize + 8; // for header
   er := OpenFileMapping(FILE_MAP_ALL_ACCESS, False, PChar(IDname));
   if er <> 0 then // all ready exist
   begin
      Result := 1;
      Exit;
   end;

   er := CreateFileMapping(INVALID_HANDLE_VALUE, nil, PAGE_READWRITE, 0,
                           TheSize+16, PChar(IDname));
   if er <> 0 then
   begin
      O := MapViewOfFile(er, FILE_MAP_ALL_ACCESS, 0, 0, 8);
      p := O;
      p^:=TheSize;
      inc(p,1);
      p^:=er;
      UnmapViewOfFile(O);
//      CloseHandle(er);
      Result := 1
   end;
end;

//------------------------------------------------------------------------------
function DestroySharedMemory(const IDname:string):longint;
var fh,ph:longword;
    p,O:^longword;
begin
   Result := 0;
   fh := OpenFileMapping(FILE_MAP_ALL_ACCESS, False, PChar(IDname));
   if fh <> 0 then
   begin
      O := MapViewOfFile(fh, FILE_MAP_ALL_ACCESS, 0, 0, 8);
      p := pointer(longword(o)+4);
      ph := p^;
      UnmapViewOfFile(O);
      CloseHandle(fh);
      CloseHandle(ph); // the papa
      Result := 1;
   end;
end;

//------------------------------------------------------------------------------
function GetSharedMemorySize(const IDname:string):longword;
var fh:longword;
    p:^longword;
begin
   Result := 0;
   fh := OpenFileMapping(FILE_MAP_ALL_ACCESS, False, PChar(IDname));
   if fh <> 0 then
   begin
      p := MapViewOfFile(fh, FILE_MAP_ALL_ACCESS, 0, 0, 8);
      Result := p^ - 8;
      UnmapViewOfFile(p);
      CloseHandle(fh);
   end;
end;

//------------------------------------------------------------------------------
function AccessSharedMemory(const IDname:string; Get0_Set1 :longword; DataOffset:longword; Data:pointer; DataSize:longword):longint;
var fh,sz:longword;
    p:^longword;
begin
   Result := 0;
   fh := OpenFileMapping(FILE_MAP_ALL_ACCESS, False, PChar(IDname));
   if fh <> 0 then
   begin
      p := MapViewOfFile(fh, FILE_MAP_ALL_ACCESS, 0, 0, 8);
      sz:= p^ - 8;
      UnmapViewOfFile(p);
      p := MapViewOfFile(fh, FILE_MAP_ALL_ACCESS, 0, 0, sz+8);
      if (DataOffset+DataSize) <= sz then
      begin
         p := pointer(longword(p)+8+DataOffset);
         if get0_set1 = 0 then
         begin
            move(p^,Data^,DataSize);
            Result := DataSize;
         end;
         if get0_set1 = 1 then
         begin
            move(Data^,p^,DataSize);
            Result := DataSize;
         end;
      end;
      UnmapViewOfFile(p);
      CloseHandle(fh);
   end;
end;



end.
