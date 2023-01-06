unit BFileCache;

interface

// NOTE

// Because cache will be 1Gb memory in size and chunk for best file performance
// will be 8Mb. All this memory shuld be common for all File cache objects.
// In that case user have to call Flush and Refresh to synhronise mem with shared
// memory



type  BTShareMemCache = class
         private
            aCacheMemory :pointer;
            aChunkMemory :pointer;
         public
            constructor Create(var is_ok:boolean);
            destructor  Destroy; override;
            property    CacheMem :pointer read aCacheMemory;
            property    ChunkMem :pointer read aChunkMemory; // if nul no cache
      end;

      BTLDRCache = record
         Flags_Chain :longword; // free chain $FF  flags $FFFFFF00
         Page        :longword;
      end;

      BTFileCache = class
         private
            aShareMem: BTShareMemCache;
            aCacheMemory : boolean;
            aCache : array [0..127] of BTLDRCache;
            aCacheBuf :pointer;
            aCacheUsed :longword;
            aCacheGarbageC :longword;
            aFileName :string;
            aMemChunk :pointer;
         public
            constructor Create(FileName:string; ChunkSize,InitialCount:longword; CommonMem:BTShareMemCache);
            destructor  Destroy; override;
//            function    ReadChunk(chnk:longword):boolean;
//            function    WriteChunk(chnk:longword):boolean;
//            function    AddChunk(chnk:longword):boolean;
//            function    Flush:boolean; // put all from share to file
//            function    Refresh:boolean; // get all from file to share
            property    MemChunk :pointer read aMemChunk;
      end;

implementation

uses BFileTools, BMemInfo;

// !!WARNING !! dont change this values
// optimal page swap size $800000;  = 8388608    8192*1024
// cache memory 1Gb 1024*1024*1024 =  1073741824
// if you change this you have to change aCache !!! :(

const ChunkSize = 8192*1024;      // 8Mb  $800000;
      CacheSize = 1024*1024*1024; // 1Gb

//------------------------------------------------------------------------------
constructor BTShareMemCache.Create(var is_ok:boolean);
begin
   is_ok := false;
   aCacheMemory := nil;
   aChunkMemory := nil;
   ReallocMem(aChunkMemory,8192*1024);
   if aChunkMemory <> nil then
   begin
      if SystemInfo_TotalPhysMemMB > 3000 then // you must have good machine
      begin
         ReallocMem(aCacheMemory, CacheSize);
      end;
      is_ok := true;
   end;
end;

//------------------------------------------------------------------------------
destructor  BTShareMemCache.Destroy;
begin
   if aCacheMemory <> nil then ReallocMem(aCacheMemory,0);
   if aChunkMemory <> nil then ReallocMem(aChunkMemory,0);
   inherited;
end;






//------------------------------------------------------------------------------
constructor BTFileCache.Create(FileName:string; ChunkSize,InitialCount:longword; CommonMem:BTShareMemCache);
var i:longword;
begin
   aShareMem := CommonMem;
   aMemChunk := aShareMem.ChunkMem;
   if aShareMem.CacheMem <> nil then aCacheMemory := true
                                else aCacheMemory := false;
   for i:= 0 to 127 do aCache[i].Flags_Chain := 0; // free al pages
   aCacheUsed := 0;
   aCacheGarbageC := 0;

end;

//------------------------------------------------------------------------------
destructor  BTFileCache.Destroy;
begin

   inherited;
end;

//------------------------------------------------------------------------------
function    ReadChunk(chnk:longword):boolean;
begin

end;
//------------------------------------------------------------------------------
function    WriteChunk(chnk:longword):boolean;
begin

end;
//------------------------------------------------------------------------------
function    AddChunk(chnk:longword):boolean;
begin

end;
//------------------------------------------------------------------------------
function    Flush:boolean;
begin

end;
//------------------------------------------------------------------------------
function    Refresh:boolean;
begin

end;


end.
