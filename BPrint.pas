unit BPrint;

interface

//Tiny printer tool

type  BTPrinter = class
         private
            aSysPrintersCnt :longword;
            aSysPrinters :array [1..32] of string;
            aPrintMode :longword;
            aPrinterName :string;
            aPrinterNameSize :longword;
            ahPrinter :nativeUInt;
            ahPrintDC :nativeUInt;
            aDriver :string;
            function    GetPageHeight: Integer;
            function    GetPageWidth: Integer;
         public
            constructor Create;
            destructor  Destroy; override;
            function    GetPrinters(var id:longword):string; // if id = 0 return total count
            procedure   UseDefaultPrinter;
            procedure   UsePrinter(id:longword);

            function    BeginPrinting(const title:string):nativeUInt; // handle to printer DC  auto new page
            procedure   EndPrinting;
            procedure   NewPage;
            procedure   Abort;
            property    PageHeight :integer read GetPageHeight;
            property    PageWidth :integer read GetPageWidth;
            property    PrinterDC :nativeUInt read ahPrintDC;
      end;



implementation

uses windows,winspool;

constructor BTPrinter.Create;
var cnt,F,L,i,infcnt:longword;
    buf:pointer;
    p:PPrinterInfo5;
begin
   aPrinterName := '';
   aSysPrintersCnt := 0;
   aPrintMode := 0;

   F := {PRINTER_ENUM_CONNECTIONS or} PRINTER_ENUM_LOCAL;
   L := 5;
   Cnt := 0;
   EnumPrinters(F, nil, L, nil, 0, Cnt, InfCnt);
   if cnt > 0 then
   begin
      aSysPrintersCnt := 0;
      Buf := nil;
      ReallocMem(Buf, Cnt);
      try
         if EnumPrinters(F, nil, L, Buf, Cnt, Cnt, InfCnt) then
         begin
            p := Buf;
            for i := 0 to infcnt - 1 do
            begin
              inc(aSysPrintersCnt);
              aSysPrinters[aSysPrintersCnt]:= string(p.pPrinterName);
              p := pointer(nativeUInt(p)+sizeof(TPrinterInfo5));
              if aSysPrintersCnt = 32 then break;
            end;
         end;
      except

      end;
      ReallocMem(buf,0); // free
   end;
end;

destructor  BTPrinter.Destroy;
begin
   EndPrinting;
   inherited;
end;

function    BTPrinter.GetPrinters(var id:longword):string; // if id = 0 return total count
begin
   Result := '';
   if id = 0 then id := aSysPrintersCnt
             else if id <= 32 then Result := aSysPrinters[id];
end;

procedure   BTPrinter.UsePrinter(id:longword);
begin
   if (id > 0) and (id <= 32) then aPrinterName := aSysPrinters[id];
end;


procedure   BTPrinter.UseDefaultPrinter;
begin
   SetLength(aPrinterName,255);
   aPrinterNameSize := 255;
   GetDefaultPrinter(@aPrinterName[1],@aPrinterNameSize);
end;


function    BTPrinter.BeginPrinting(const title:string):nativeUint; // handle to printer DC
var pinfo :PRINTER_INFO_2;
    w:longword;
    docinfo :TDocInfo;
    DevMode: TDeviceMode;
begin
   Result := 0;
   if aPrintMode = 0 then
   begin
      if OpenPrinter(@aPrinterName[1], ahPrinter, nil) then
      begin
         aDriver := 'WINSPOOL'+#0;
         w := 0;
         if GetPrinter(ahPrinter, 2, @pinfo, sizeof(pinfo), @w) then
         begin
            ClosePrinter(ahPrinter);
            FillChar(DevMode, sizeOf(DevMode), 0);
            DevMode.dmSize := sizeof(DevMode);
            DevMode.dmFields := DM_PAPERSIZE or DM_COPIES;
            DevMode.dmCopies := 1;
            DevMode.dmPaperSize := DMPAPER_A4;
            ahPrintDC := CreateDC(@aDriver,@aPrinterName[1],pinfo.pPortName,@DevMode);
            FillChar(docInfo, sizeOf(docInfo), 0);
            docinfo.cbSize := sizeof(docinfo);
            docinfo.lpszDocName := pchar(@title[1]);
            // SetAbortProc(ahPrintDC, AbortProc); //too complex
            StartDoc(ahPrintDC,docinfo);
            StartPage(ahPrintDC);
            aPrintMode := 1;
            Result := ahPrintDC;
         end;
      end;
   end;
end;


procedure   BTPrinter.EndPrinting;
begin
   if aPrintMode = 1 then
   begin
      EndPage(ahPrintDC);
      EndDoc(ahPrintDC);
      DeleteDc(ahPrintDC);
      aPrintMode := 0;
   end;
end;

procedure   BTPrinter.NewPage;
begin
   if aPrintMode = 1 then
   begin
      EndPage(ahPrintDC);
      StartPage(ahPrintDC);
   end;
end;

procedure   BTPrinter.Abort;
begin
   if aPrintMode = 1 then
   begin
      AbortDoc(ahPrintDC);
      DeleteDc(ahPrintDC);
      aPrintMode := 0;
   end;
end;

function    BTPrinter.GetPageHeight: Integer;
begin
   Result := GetDeviceCaps(ahPrintDC, VertRes);
end;

function    BTPrinter.GetPageWidth: Integer;
begin
   Result := GetDeviceCaps(ahPrintDC, HorzRes);
end;



end.
