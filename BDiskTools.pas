unit BDiskTools;

interface

function DiskFree (Drive :byte) :Int64;
function DiskSize (Drive :byte) :Int64;
function DiskType (Drive :byte) :longword;
function DiskLetter (Drive :byte) :char;
function DiskDrive (Disk :char) :byte;
function DiskReady (Drive :byte) :boolean;

{  DiskType result

DRIVE_UNKNOWN     = 0;
DRIVE_NO_ROOT_DIR = 1;
DRIVE_REMOVABLE   = 2;
DRIVE_FIXED       = 3;
DRIVE_REMOTE      = 4;
DRIVE_CDROM       = 5;
DRIVE_RAMDISK     = 6;

BUS_UNKNOWN       = 0;
BUS_SCSI          = $10000;
BUS_ATAPI         = $20000;
BUS_ATA           = $30000;
BUS_1394          = $40000;
BUS_SSA           = $50000;
BUS_FIBRE         = $60000;
BUS_USB           = $70000;
BUS_RAID          = $80000;
BUS_ISCSI         = $90000;
BUS_SAS           = $A0000;
BUS_SATA          = $B0000;
BUS_SD            = $C0000;
BUS_MMC           = $D0000;
BUS_VIRTUAL       = $E0000;
BUS_FILEVIRTUAL   = $F0000;
}


implementation

uses windows;

//------------------------------------------------------------------------------
function _InternalGetDiskSpace(Drive: Byte;
  var TotalSpace, FreeSpaceAvailable: Int64): Bool;
var
  RootPath: array[0..4] of Char;
  RootPtr: PChar;
begin
  Result := false;
//  RootPtr := nil;
  if Drive > 0 then
  begin
    RootPath[0] := Char(Drive + $40);
    RootPath[1] := ':';
    RootPath[2] := '\';
    RootPath[3] := #0;
    RootPtr := RootPath;
//{$IFDEF FPC }
//  Result := GetDiskFreeSpaceEx(RootPtr, FreeSpaceAvailable, TotalSpace, nil);
//{$ELSE}
    Result := GetDiskFreeSpaceEx(RootPtr, FreeSpaceAvailable, TotalSpace, nil);
  end;
//{$ENDIF}
end;

function DiskFree (Drive :Byte) :Int64;
var  TotalSpace: Int64;
begin
  if not _InternalGetDiskSpace(Drive, TotalSpace, Result) then  Result := -1;
end;

//------------------------------------------------------------------------------
function DiskSize(Drive :Byte) :Int64;
var
  FreeSpace: Int64;
begin
  if not _InternalGetDiskSpace(Drive, Result, FreeSpace) then
    Result := -1;
end;


//------------------------------------------------------------------------------
function DiskLetter (Drive :byte) :char;
begin
   Result := '@';
   if (Drive > 0) and (Drive <27) then
   begin
      Result := char($40 + Drive);
   end;
end;

//------------------------------------------------------------------------------
function DiskDrive (Disk :char) :byte;
begin
   Result := 0;
   if (byte(Disk) > $40) and (byte(Disk) < $5B) then Result := byte(Disk) - $40;
end;

//------------------------------------------------------------------------------
function DiskReady (Drive :byte) :boolean;
begin
   Result := DiskSize(Drive) <> -1;
end;

//------------------------------------------------------------------------------
const
  IOCTL_STORAGE_QUERY_PROPERTY =  $002D1400;

type
  STORAGE_QUERY_TYPE = (PropertyStandardQuery = 0, PropertyExistsQuery, PropertyMaskQuery, PropertyQueryMaxDefined);
  TStorageQueryType = STORAGE_QUERY_TYPE;

  STORAGE_PROPERTY_ID = (StorageDeviceProperty = 0, StorageAdapterProperty);
  TStoragePropertyID = STORAGE_PROPERTY_ID;

STORAGE_PROPERTY_QUERY = packed record
    PropertyId: STORAGE_PROPERTY_ID;
    QueryType: STORAGE_QUERY_TYPE;
    AdditionalParameters: array [0..9] of AnsiChar;
  end;
  TStoragePropertyQuery = STORAGE_PROPERTY_QUERY;

STORAGE_BUS_TYPE = (BusTypeUnknown = 0, BusTypeScsi, BusTypeAtapi, BusTypeAta,
                    BusType1394, BusTypeSsa, BusTypeFibre, BusTypeUsb,
                    BusTypeRAID, BusTypeiScsi, BusTypeSas, BusTypeSata,
                    BusTypeSd, BusTypeMmc, BusTypeVirtual, BusTypeFileBackedVirtual,
                    BusTypeMaxReserved = $7F);
  TStorageBusType = STORAGE_BUS_TYPE;

STORAGE_DEVICE_DESCRIPTOR = packed record
    Version: DWORD;
    Size: DWORD;
    DeviceType: Byte;
    DeviceTypeModifier: Byte;
    RemovableMedia: Boolean;
    CommandQueueing: Boolean;
    VendorIdOffset: DWORD;
    ProductIdOffset: DWORD;
    ProductRevisionOffset: DWORD;
    SerialNumberOffset: DWORD;
    BusType: STORAGE_BUS_TYPE;
    RawPropertiesLength: DWORD;
    RawDeviceProperties: array [0..0] of AnsiChar;
  end;
  TStorageDeviceDescriptor = STORAGE_DEVICE_DESCRIPTOR;

function DiskType (Drive :byte) :longword;
var drv:string;
    Query: TStoragePropertyQuery;
    dwBytesReturned: DWORD;
    Buffer: array [0..1023] of Byte;
    sdd: TStorageDeviceDescriptor absolute Buffer;
    H: longword;
begin
   drv:='C:\'+#0;
   drv[1]:=char(DiskLetter(Drive));
   Result := GetDriveType(Pchar(drv));
   if Result <> 0 then
   begin
      drv :=  '\\.\C:';
      drv[5]:=char(DiskLetter(Drive));
      H := CreateFile(PChar(drv), 0, FILE_SHARE_READ or FILE_SHARE_WRITE, nil,
                            OPEN_EXISTING, 0, 0);
      if H <> INVALID_HANDLE_VALUE then
      begin
         dwBytesReturned := 0;
         FillChar(Query, SizeOf(Query), 0);
         FillChar(Buffer, SizeOf(Buffer), 0);
         sdd.Size := SizeOf(Buffer);
         Query.PropertyId := StorageDeviceProperty;
         Query.QueryType := PropertyStandardQuery;
         if DeviceIoControl(H, IOCTL_STORAGE_QUERY_PROPERTY, @Query, SizeOf(Query),
                            @Buffer, SizeOf(Buffer), dwBytesReturned, nil) then
         Result := Result or  (longword(sdd.BusType) shl 16);
//         if sdd.BusType = BusTypeUsb then result := Result or $10000;
         CloseHandle(H);
      end;
   end;
end;




end.
