unit BByteCode;

interface

type  BTByteCode = class
         private
            aCode       :pointer;
            aCodeSize   :longword;
            aCodePos    :longword;
            aCodeCnt    :longword;
            aData       :pointer;
            aDataSize   :longword;
            aDataPos    :longword;
            aDataCnt    :longword;
         public
            constructor Create;
            destructor  Destroy; override;
            procedure   Reset;
            property    CodeOffset :longword read aCodePos;
      end;


implementation

type Byte_arr = array [0..0] of byte;
     PByte_arr = ^Byte_arr;


//------------------------------------------------------------------------------
constructor BTByteCode.Create;
begin
   aCode := nil;
   aCodeSize := 0;
   aData := nil;
   aDataSize := 0;
   Reset;
end;

//------------------------------------------------------------------------------
destructor  BTByteCode.Destroy;
begin
   if aCode <> nil then ReallocMem(aCode,0);
   if aData <> nil then ReallocMem(aData,0);
   inherited;
end;

//------------------------------------------------------------------------------
procedure   BTByteCode.Reset;
begin
   aCodePos := 0;
   aCodeCnt := 0;
   aDataPos := 0;
   aDataCnt := 0;
end;



end.
