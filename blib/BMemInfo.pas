unit BMemInfo;

interface

function SystemInfo_TotalPhysMemMB:longword;
function SystemInfo_AvailPhysMemMB:longword;
function SystemInfo_GetProccesMem:longword;




implementation

uses windows; //,psapi;

type
  TMemoryStatusEx = packed record
    dwLength: longword;
    dwMemoryLoad: longword;
    ullTotalPhys: Int64;
    ullAvailPhys: Int64;
    ullTotalPageFile: Int64;
    ullAvailPageFile: Int64;
    ullTotalVirtual: Int64;
    ullAvailVirtual: Int64;
    ullAvailExtendedVirtual: Int64;
  end;
  TGlobalMemoryStatusEx = procedure(var lpBuffer: TMemoryStatusEx); stdcall;


procedure _GetPhysMem(var ms:TMemoryStatusEx);
var h:longword;
    gms : TGlobalMemoryStatusEx;
begin
   FillChar(ms,sizeof(TMemoryStatusEx),0);
   ms.dwLength := sizeof(TMemoryStatusEx);
   h := LoadLibrary('kernel32.dll'); //kernel32);
   if h <> 0 then
   begin
      gms := GetProcAddress(h, 'GlobalMemoryStatusEx');
      if assigned(gms) then gms(ms);
      FreeLibrary(h);
   end else ms.dwLength := 0;
end;

function SystemInfo_TotalPhysMemMB:longword;
var ms:TMemoryStatusEx;
begin
   Result := 0;
   _GetPhysMem(ms);
   if ms.dwLength <> 0 then Result := longword(ms.ullTotalPhys div (1024*1024));
end;

function SystemInfo_AvailPhysMemMB:longword;
var ms:TMemoryStatusEx;
begin
   Result := 0;
   _GetPhysMem(ms);
   if ms.dwLength <> 0 then Result := longword(ms.ullAvailPhys div (1024*1024));
end;

function SystemInfo_GetProccesMem:longword;
//var  PMC:_PROCESS_MEMORY_COUNTERS;
begin
//   PMC.cb:=sizeof(_PROCESS_MEMORY_COUNTERS);
//   GetProcessMemoryInfo(GetCurrentProcess,@PMC,sizeof(PMC));
//   Result := PMC.PeakWorkingSetSize;
end;

{  // Work only for delphi :( but perfect
function MemoryUsage:longword;
var st: TMemoryManagerState;
    sb: TSmallBlockTypeState;
begin
   GetMemoryManagerState(st);
   Result := st.TotalAllocatedMediumBlockSize + st.TotalAllocatedLargeBlockSize;
   for sb in st.SmallBlockTypeStates do
   begin
      Result := Result + sb.UseableBlockSize * sb.AllocatedBlockCount;
   end;
end;
 }

end.
