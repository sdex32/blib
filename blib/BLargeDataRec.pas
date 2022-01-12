unit BLargeDataRec;

interface

var wreads,wwrites:longword;  // for debug
var creads,cwrites:longword;  // for debug

//!CAUTION! can reach exception out of memory

{ TODO
   kasha vubste ne raboti


}

// !!WARNING !! dont change this values
// optimal page swap size $800000;  = 8388608    8192*1024
// cache memory 1Gb 1024*1024*1024 =  1073741824
// if you change this you have to change aCache !!! :(

const LDR_ChunkSize = $1000; // 4096 dont change that tested for best performance

             LDR_CacheChunkCnt = 1; //just to pass compiler

{ !!NOTE!!   all buf chunks start from 0 (zero) }

type  BTLDR_CacheArr = array [0..0] of longword;
      PBTLDR_CacheArr = ^BTLDR_CacheArr;

      BTLDR_Session = record
         Next :pointer;
         aFileHandle:longword;
         aCacheUsage :array[0..( LDR_CacheChunkCnt-1) ]of longword;
         aCacheTables :array[0..31] of pointer; //32GBmax
         aCache :PBTLDR_CacheArr;
         aCacheUsed :longword;
         aCacheCap  :longword;
         aDataSize :longword;        // user data record size
         aDataInChunk :longword;     // count of data inside chunk
         aChunksCount :longword;     // total used chunks
         aRecCount :longword;        // count of user data records = FirstCapacity
         aRecCapacity :longword;     // max capacity of user data rec
         aCacheGarbageC :longword;
         aCacheGarbageN :longword;

         aCurChunk :longword;        // index of cur chunk in use
         aFlushed :boolean;          // all chunks are flushed to disk
         aFileName :string[80];      // file name of page file
      end;
      PBTLDR_Session = ^BTLDR_Session;

      BTLargeDataRecord = class
         private

            agMemoryBuf      :pointer;  // 1Gb global memory
            agUseCacheMemory :boolean;  // uses cache memory
            agCacheChunkCnt  :longword; // count of chunks in cache
            agMemoryPtr      :pointer;  // pointer to cur chunk
            agCacheShift     :longword;
            agCacheMask      :longword;


            aCurrentDir      :string;
            aSessions        :PBTLDR_Session;   // linked list of states
            aCurSession      :PBTLDR_Session; // state in use
            function    _ReadChunk(chnk:longword):boolean;
            function    _WriteChunk(chnk:longword; flushed:boolean):boolean;
            function    _GetRecCount:longword;

         public
            constructor Create(use_cache:boolean);
            destructor  Destroy; override;
            function    Init(const FName:string; DataSize,FirstCapacity:longword; var LDR_ID:longword):boolean; //true ok

            function    NewRec:longword; //index
            function    GetRec(indx:longword):pointer;

            function    Flush:boolean;
            function    ReLoad(LDR_ID:longword):boolean;

            property    GetRecCount :longword read _GetRecCount;
      end;


implementation




uses BFileTools, BStrTools, BMemInfo, Windows;

const  CachFileExt = 'B1D';

//------------------------------------------------------------------------------
constructor BTLargeDataRecord.Create(use_cache:boolean);
var MemBufSize:longword;
    i:longword;
    s,s1:string;
begin
(*
   // clear old cache files for all sessions
   aCurrentDir := GetCurrentDir;
   GetDirList(aCurrentDir,'*.'+CachFileExt,'',s,0);
   i := 0;
   if length(s)>0  then
   begin
      repeat
         s1:=ParseStr(s,i,';');
         inc(i);
         if length(s1) <> 0 then
         begin
            FileDelete(s1);
         end else i := 0;
      until i = 0
   end;

   //init variables
 //  aStates := nil; // still no states
 //  aCurState := nil;


   //try to alloc buffers
   agMemoryBuf := nil;
   MemBufSize := $40000000;  // 1Gb for cache work for 32 bit OS
   agUseCacheMemory := false;
   if use_cache then
   begin
      if SystemInfo_TotalPhysMemMB > 3000 then // you must have good machine 3g at least free
      begin
         ReallocMem(agMemoryBuf, MemBufSize); // use cache many chunks
         if agMemoryBuf = nil then
         begin
            MemBufSize := MemBufSize div 2; // try small
            ReallocMem(agMemoryBuf, MemBufSize);
         end;
         if agMemoryBuf <> nil then agUseCacheMemory := true; // we have cahce
      end;
   end;
   if agMemoryBuf = nil then  // no mem for cache alloc one chunk only
   begin
      MemBufSize := LDR_ChunkSize;
      ReallocMem(agMemoryBuf, MemBufSize);  // kust one chunk
   end;


   agCacheChunkCnt := MemBufSize div LDR_ChunkSize;

   agCacheShift := 0; // calculate shift and mash for page cahce adressing
   agCacheMask := 0;
   i := agCacheChunkCnt;
   while i <> 0 do
   begin
     i := i shr 1;
     inc(agCacheShift);
     agCacheMask := (agCacheMask shl 1) or 1;
   end;

   agMemoryPtr := agMemoryBuf;
   *)
end;

//------------------------------------------------------------------------------
destructor  BTLargeDataRecord.Destroy;
//var a:PBTLDR_State;
begin
   (*
//   if aMemChunk <> nil then ReallocMem(aMemChunk,0);
   if agMemoryBuf <> nil then ReallocMem(agMemoryBuf,0);
   while (aStates<>nil) do
   begin
      FileDelete(aStates.aFileName);


      CloseHandle(aStates.aFileHandle);
      a := PBTLDR_State(aStates.Next);
      ReallocMem(aStates,0);
      aStates := a;
   end;
   Inherited;
   *)
end;

//------------------------------------------------------------------------------
function    BTLargeDataRecord._ReadChunk(chnk:longword):boolean;
var i,p,f :longword;
    mem :pointer;
begin
   (*
   inc(creads);
   Result := false;
   with aCurState^ do
   begin
      aCache := aCacheTables[chnk shr agCacheShift];
      p := chnk and agCacheMask;
      if i <> $FFFFFFFF then
      begin

      end;




      mem := agMemoryPtr;
      if agUseCacheMemory then
      begin
         aCache := aCacheTables[chnk shr agCacheShift];
         if aCache <> nil then
         begin
            p := chnk and agCacheMask;
            i := aCache[p]; //page
            if i <> $FFFFFFFF then
            begin
               // all ready in memory
               agMemoryPtr := pointer(longword(agMemoryBuf) + i * LDR_ChunkSize);
               Result := true;
               Exit;
            end else begin
               // mem is not loaded from disk
               f := $FFFFFFFF;
               for i:= 0 to LDR_CacheChunkCnt-1 do
               begin
                  if aCacheUsage[i] = $FFFFFFFF then
                  begin
                     f := i;
                     break;
                  end;
               end;
               if f <> $FFFFFFFF then
               begin
                  aCache[p] := f;
                  aCacheUsage[f] := p;
                  mem := pointer(longword(agMemoryBuf) + f * LDR_ChunkSize);
               end else begin
                  //error
               end;


            end;
         end else begin
           //error
           Exit;
         end;
      end;
         inc(wreads);
      SetFilePointer(aFileHandle,chnk*LDR_ChunkSize,nil,FILE_BEGIN);
      ReadFile(aFileHandle,mem^,LDR_ChunkSize,i,nil);
      if i = LDR_ChunkSize then
      begin
         Result := true;
         agMemoryPtr := mem;
      end;
   end;
   *)
end;
//------------------------------------------------------------------------------
function    BTLargeDataRecord._WriteChunk(chnk:longword; flushed:boolean):boolean;
var i,p :longword;
    mem:pointer;
begin
   (*
   inc(cwrites);
   Result := false;
   with aCurState^ do
   begin
      mem := agMemoryPtr;
      if agUseCacheMemory then
      begin
         aCache := aCacheTables[chnk shr agCacheShift];
         if aCache <> nil then
         begin
            I := chnk and agCacheMask;
            if i <> $FFFFFFFF then
            begin
               if flushed then
               begin
                  Result := true;
                  Exit;
               end;
               mem := pointer(longword(agMemoryBuf) + i * LDR_ChunkSize);
            end else begin
               //error
               Exit;
            end;
         end else begin
           //error
           Exit;
         end;
      end;
         inc(wwrites);

      SetFilePointer(aFileHandle,chnk*LDR_ChunkSize,nil,FILE_BEGIN);
      WriteFile(aFileHandle,mem^,LDR_ChunkSize,i,nil);
      if i = LDR_ChunkSize then
      begin
         Result := true;
         agMemoryPtr := mem;
      end;

   end;
   *)
end;

//------------------------------------------------------------------------------
function    BTLargeDataRecord._GetRecCount:longword;
begin
   Result := 0;
   (*
   if aCurState <> nil then Result := aCurState.aRecCount;
   *)
end;

//------------------------------------------------------------------------------
function    BTLargeDataRecord.Init(const FName:string; DataSize,FirstCapacity:longword; var LDR_ID:longword):boolean; //true ok
var i,j : longword;
//    a,p:PBTLDR_State;
    pas:pansichar;
    fnas:ansistring;
begin
   (*
   Result := false; //fail

   if agMemoryBuf = nil then Exit;
   if FirstCapacity = 0 then Exit;


 //  Flush; // flush current state if exist

   // create new state
   p := nil;
   ReallocMem(p,sizeof(BTLDR_State));
   if p = nil then Exit;
   LDR_ID := longword(p); // send handle to user
   p.Next := nil;
   // link it
   if aStates <> nil then
   begin
      a := aStates;
      while(a.Next <> nil) do a := a.Next;
      a.Next := p;
   end else aStates := p;
   aCurState := p;

   // calc vaues for cur state
   with aCurState^ do
   begin

      aCurChunk := 0;
      aRecCount := 0;

      aDataSize := DataSize;
      if aDataSize > LDR_ChunkSize then Exit;
      aDataInChunk := LDR_ChunkSize div aDataSize;  // How many data rec in one chunk
      aChunksCount := (FirstCapacity div aDataInChunk) + 1; // How many i will need for first time
      aRecCapacity := aChunksCount * aDataInChunk;
      aFlushed := false;

   //   aCacheGarbageN := 0;
   //   aCacheGarbageC := 0;  //was 1



      aFileName := FName;
      if FileExist(aFileName) then FileDelete(aFileName); // clear old
      if FileExist(aFileName) then Exit; // file still exist

      fnas := ansistring(aFileName)+#0;
      pas := @fnas[1];
//      aFileHandle := CreateFile(pas,GENERIC_READ or GENERIC_WRITE, 0, nil,
//                     CREATE_NEW,
//                     FILE_FLAG_RANDOM_ACCESS,
////                     FILE_FLAG_DELETE_ON_CLOSE
//                     //FILE_ATTRIBUTE_NORMAL,
//                     0);

      for i := 0 to 31 do aCacheTables[i] := 0;

      aCache := nil;
      aCacheUsed := 0;
      aCacheCap := 0;
      if agUseCacheMemory then
      begin
         //todo if first > 1Gb
         ReallocMem(aCache,LDR_CacheChunkCnt * sizeof(longword));
         if aCache <> nil then
         begin
            aCacheCap := LDR_CacheChunkCnt;
            aCacheTables[0] := aCache; //clear cache table
            for i:= 0 to LDR_CacheChunkCnt-1 do
            begin
               aCache[i] := $FFFFFFFF;
               aCacheUsage[i] := $FFFFFFFF;
            end;
            aCacheUsage[0] := 0;
            aCache[0] := 0; // cur chunk is in cache 0
         end else begin
            //error //todo

         end;
      end;



      for i := 1 to FirstCapacity do
      begin
         if NewRec = 0 then
         begin
            //Error
         end;
      end;



      // clear memory
//      if agUseCacheMemory then FillChar(agMemoryPtr^,LDR_CacheSize,0)
//                      else FillChar(agMemoryPtr^,LDR_ChunkSize,0);
{
FillChar(agMemoryPtr^,LDR_ChunkSize,0);

      for i := 0 to aChunksCount - 1 do
      begin
         if not _WriteChunk(i) then Exit;

//         if agUseCacheMemory then
//         begin // fill cache buffer        //todo meaby no need to slow use dynamics??
//            if aChunksCount <= 128 then j := aChunksCount
//                                   else j := 128;
//            for i := 1 to j do if not _ReadChunk(i) then exit;
//         end;
//         aCurChunk := 1;
//         if not _ReadChunk(aCurChunk) then exit;
      end;

      aCurChunk := 0;
      }
      Result := true; //Ok
   end;
   *)
end;

//------------------------------------------------------------------------------
function    BTLargeDataRecord.NewRec:longword; //index
var p:pointer;
begin
   (*
   Result := 0;
   if agMemoryBuf = nil then Exit;
   if aCurState <> nil then with aCurState^ do
   begin
      if (aRecCount + 1) > aRecCapacity then
      begin
         // add one more chunk
         if not _WriteChunk(aChunksCount,true) then exit;
         inc(aChunksCount);
         aRecCapacity := aRecCapacity + aDataInChunk;
      end;
      inc(aRecCount);
      Result := aRecCount;
      p := GetRec(Result);
      if p <> nil then
      begin
         FillChar(p^,aDataSize,0); // reset new element
      end else Result := 0;
   end;
   *)
end;

//------------------------------------------------------------------------------
function    BTLargeDataRecord.GetRec(indx:longword):pointer;
var chunk:longword;
begin
   (*
   Result := nil;
   if agMemoryBuf = nil then Exit;
   if aCurState <> nil then with aCurState^ do
   begin
      aFlushed := false;
      if (indx > aRecCount) then Exit;
      chunk := (indx div aDataInChunk);
      if chunk <> aCurChunk then
      begin
         if not _WriteChunk(aCurChunk,false) then exit;
         if not _ReadChunk(Chunk) then exit;
         aCurChunk := Chunk;
      end;
      Result := pointer(longword(agMemoryPtr) + (indx mod aCurState.adataInChunk)*aCurState.aDataSize);
   end;
   *)
end;

//------------------------------------------------------------------------------
function    BTLargeDataRecord.Flush:boolean;
var  i,j:longword;
begin
  (*
   Result := false;
   if agMemoryBuf = nil then Exit;
   if aCurState <> nil then with aCurState^ do
   begin
      if not aFlushed then
      begin
         if agUseCacheMemory then
         begin
         {
         for i := 0 to 127 do
         begin
            j := aCache[i].page;
            if j <> 0 then
            begin  // put this page in Cache
               agMemoryPtr := pointer(longword(agMemoryBuf) + (i)*ChunkSize);
               if not FileWriteBlock(aFileName,(j-1)*aChunkSize,agMemoryPtr,aChunkSize) then exit;
            end;
         end;}
         end else begin
            if not _WriteChunk(aCurChunk,true) then Exit;
         end;
         Result := true;
         aFlushed := true;
      end else Result := true;
   end;
   *)
end;

//------------------------------------------------------------------------------
function    BTLargeDataRecord.ReLoad(LDR_ID:longword):boolean;
var // a:PBTLDR_State;
    i,j:longword;
begin
(*
   Result := false;
   a := aStates;
   while (a <> nil) do
   begin
      if longword(a) = LDR_ID then Result := true;
      a := a.Next;
   end;
   if Result then
   begin
      Flush; // flush cur state
      Result := false; // for exit
      aCurState := pointer(LDR_ID);
      with aCurState^ do
      begin
          {
         for i := 0 to 127 do
         begin
            j := aCache[i].page;
            if j <> 0 then
            begin  // put this page in Cache
               agMemoryPtr := pointer(longword(agMemoryBuf) + (i)*ChunkSize);
               if not FileReadBlock(aFileName,(j-1)*aChunkSize,agMemoryPtr,aChunkSize) then exit;
            end;
         end;
         }
         aFlushed := false;
         Result := true;
      end;
   end;
   *)
end;



end.
