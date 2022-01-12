unit BTinySoap;

interface

uses BUnicode,BTinyXML,BBase64,BSocket;
(*
    Input param is concats #27(ESC) terminated params
    all data is 8bit utf-8
	  0 - host name or ip address
    1 - port
    2 - service  (must start with /packagename/servicename)
    3 - add to http header ( with delimiter 13,10 )
    4 - SOAP Action
    5 - Basic Auth user
    6 - Basic Auth pwd
    7 - add to soap header ( with delimiter 13,10 )
    8 - name space for methode
    9 - methode name
   10 - soap envelope name spaces   !soap! ns
   11 - count of params
   +0 - type
   +1 - argument name
   +2 - value   (step by 3)

   Flags
   $1 -
   $2 - Decorate and UnDecorate xml  < = ;lt; > = ;gt;
   $4 - Use type in param definition
   $8 - Use name space of methode for param name
*)

function SoapCall( req :AnsiString; var aFlags:longint) :AnsiString;
function SoapCallW( req :WideString; var aFlags:longint) :WideString;


implementation

uses winsock,windows;


function parse_str(instr:AnsiString; ind:longword; delim:AnsiString) :AnsiString;
var  i,j,k : longword;
     c:AnsiChar;
begin
   result := '';
   if instr = '' then Exit;
   j := length(instr);
   i := 0;
   k := 0;
   while i < j do
   begin
      inc(i);
      c := instr[i];
      if Pos(c,delim) <> 0 then
      begin
         if k = ind then break;
         inc(k);
         continue;
      end;
      if k = ind then result := result + c;
   end;
end;



//------------------------------------------------------------------------------
// data must be in 8Bit UTF-8 format
function SoapCall( req :AnsiString; var aFlags:longint) :AnsiString;
var
  aAddress:AnsiString;
  aSOAPmes:AnsiString;
  aSOAPenv:AnsiString;
  aTemp:Ansistring;
  aAuth:AnsiString;
  iPort,iCount,iC,SoapSize,i  :longword;
  aNET:BTSocketClient;
  laFlags:longint;
begin
   Result := '';
   laFlags := aFlags;

   aNET := BTSocketClient.Create;
   if not assigned(aNET) then
   begin
      aFlags := -1;
      Exit;
   end;

   aTemp := Parse_Str(req,1,#27); //  port
   val(string(aTemp),iPort,ic);

   aTemp := Parse_Str(req,11,#27); //  Count
   val(string(aTemp),iCount,ic);

   // SOAP envelop --------------------------------------------------

   aSOAPenv := '<?xml version="1.0" encoding="UTF-8"?>'+#13#10;
   aTemp := Parse_Str(req,10,#27); //  soap name spaces
   if length(aTemp) <> 0 then
   begin
      aSOAPenv := aSOAPenv + '<soap:Envelope '+aTemp+' >'+#13#10;
   end else begin
      if (aFlags and 1) <> 0 then
      begin // with type
         aSOAPenv := aSOAPenv + '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">'+#13#10;

//      aSOAPenv := aSOAPenv + '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">'+#13#10;
//      aSOAPenv := aSOAPenv + '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">'+#13#10;
      end else begin
         aSOAPenv := aSOAPenv + '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope">'+#13#10;
      end;
   end;

   aTemp := Parse_Str(req,7,#27); //soap header extention
   if length(aTemp) > 0  then
   begin
      aSOAPenv := aSOAPenv + '<soap:Header>'+#13#10;
      aSOAPenv := aSOAPenv + aTemp;
      aSOAPenv := aSOAPenv +  '</soap:Header>'+#13#10;
   end;

   aSOAPenv := aSOAPenv +  '<soap:Body>'+#13#10;
   aTemp := Parse_Str(req,9,#27); //methode name
   if length(aTemp) > 0  then
   begin // no function
      aSOAPenv := aSOAPenv +  '<m:';
      aSOAPenv := aSOAPenv + aTemp;
      aSOAPenv := aSOAPenv + ' xmlns:m="';
      aTemp := Parse_Str(req,8,#27); //name space
      aSOAPenv := aSOAPenv + aTemp;
      aSOAPenv := aSOAPenv +  '">'+#13#10;
   end;

   if iCount > 0 then
   begin
      for ic := 1 to iCount do
      begin
         // <m:StockName>IBM</m:StockName>
         if (aFlags and 8) <> 0 then aSOAPenv := aSOAPenv + '<m:' // with name space
                                else aSOAPenv := aSOAPenv + '<'; // name without namespace
         aTemp := Parse_Str(req,12 + 1 + (ic - 1)*3,#27); //arg name
         aSOAPenv := aSOAPenv + aTemp;
         if (aFlags and 4) <> 0 then
         begin // with type
            aSOAPenv := aSOAPenv + ' xsi:type="xsd:';
            aTemp := Parse_Str(req,12 + 0 + (ic - 1)*3,#27); //arg type
            aSOAPenv := aSOAPenv + aTemp;
            aSOAPenv := aSOAPenv + '">';
         end else begin
            aSOAPenv := aSOAPenv + '>';
         end;
         aTemp := Parse_Str(req,12 + 2 + (ic - 1)*3,#27); //arg value
         if (aFlags and 2) <> 0 then aTemp := XML_Decorate(aTemp);
         aSOAPenv := aSOAPenv + aTemp;
         if (aFlags and 8) <> 0 then  aSOAPenv := aSOAPenv + '</m:'
                                else  aSOAPenv := aSOAPenv + '</';
         aTemp := Parse_Str(req,12 + 1 + (ic - 1)*3,#27); //arg name
         aSOAPenv := aSOAPenv + aTemp;
         aSOAPenv := aSOAPenv + '>'+#13#10;
      end;
   end else begin
      aTemp := Parse_Str(req,12 + 2 ,#27); //arg value
      aSOAPenv := aSOAPenv + aTemp;  // pass value totaly
   end;

   aTemp := Parse_Str(req,9,#27); //methode name end of methode
   if length(aTemp) > 0  then
   begin
      aSOAPenv := aSOAPenv + '</m:' + aTemp + '>'+#13#10;
   end;

   aSOAPenv := aSOAPenv +'</soap:Body>'+#13#10+'</soap:Envelope>'+#13#10;

   // HTTP header ----------------------------------------------------------

   aSOAPmes := 'POST http://';
   aAddress := Parse_Str(req,0,#27); // Address
   aSOAPmes := aSOAPmes + aAddress;
   aAddress := aAddress + #0;
   aSOAPmes := aSOAPmes + ':';
   aTemp := Parse_Str(req,1,#27); // port
   aSOAPmes := aSOAPmes + aTemp;
   aTemp := Parse_Str(req,2,#27); // Service
   aSOAPmes := aSOAPmes + aTemp;
   aSOAPmes := aSOAPmes + ' HTTP/1.1'+#13#10;

   aSOAPmes := aSOAPmes + 'Content-Type: text/xml; charset=utf-8'+#13#10;

   aSOAPmes := aSOAPmes + 'Host: ';
   aTemp := Parse_Str(req,0,#27); // Address
   aSOAPmes := aSOAPmes + aTemp;
   aSOAPmes := aSOAPmes + ':';
   aTemp := Parse_Str(req,1,#27); // port
   aSOAPmes := aSOAPmes + aTemp;
   aSOAPmes := aSOAPmes + #13#10;

   aSOAPmes := aSOAPmes + 'User-Agent: TinySOAP 1.0'+#13#10;

   aTemp := Parse_Str(req,4,#27); // SOAPaction
   if length(aTemp) > 0 then
   begin
      aSOAPmes := aSOAPmes + 'SOAPAction: "' + aTemp + '"'+#13#10;
   end;

   aAuth := Parse_Str(req,5,#27); // Auth user
   if length(aAuth) > 0  then
   begin
      atemp := Parse_Str(req,6,#27); // Auth pwd
      aAuth := aAuth + ':' + aTemp;
      aSOAPmes := aSOAPmes + 'Authorization: Basic ' + BCodeBase64(aAuth) + #13#10;
   end;

   aTemp := Parse_Str(req,3,#27); // HTTPheader extention
   aSOAPmes := aSOAPmes + aTemp;

   aSOAPmes := aSOAPmes + 'Content-Length: ';
   str(length(aSOAPenv),aTemp);
   aSOAPmes := aSOAPmes + aTemp;
   aSOAPmes := aSOAPmes + #13#10;

   aSOAPmes := aSOAPmes + 'Connection: Keep-Alive'+#13#10;

   aSOAPmes := aSOAPmes + 'Pragma: no-cache'+#13#10#13#10;

   aSOAPmes := aSOAPmes + aSOAPenv ;

   soapsize := length(aSOAPmes);
   //Buff := @aSOAPmes[1];

   // NETWORK PART -------------------------------------------------------

   // prepare error
   aFlags := 0;

   //aSize := 0;

   aNET.Connect(string(aAddress),iPort);
   if aNet.GetlastError = 0 then
   begin
      aNET.SendReceive(@aSOAPmes[1],soapsize);
      if aNet.GetlastError = 0 then
      begin
         if aNET.GetReadSize > 0 then
         begin
            SetLength(aAddress,aNET.GetReadSize);
            Move(aNET.GetReadPTR^,(@aAddress[1])^,aNET.GetReadSize);
         end;
      end;
   end else begin
      aFlags := -3; // connection problem
      Exit;
   end;
   aNET.Disconnect;
   aNET.Free;

   // remove SOAP envelop -----------------------------------------

   aFlags := -4; // no data
   if length(aAddress) > 1 then
   begin
      aFlags := -5; // no http header
      ic := Pos(#13#10#13#10,aAddress); // Get the end of http header
      if ic <> 0 then
      begin
         aFlags := -100; // bad response
         i := Pos('200 OK',aAddress);
         if (i > 0) and (i < ic) then
         begin
            i := Pos('Content-Length',aAddress);
            if (i > 0)  and (i > ic) then i := 0; // not part of the header
            // get the http data
            inc(ic,4);
            aSOAPmes := Copy(aAddress, ic, longword(length(aAddress)) - ic + 1);
            if i = 0 then // no content length thre is chunks  hex size .... 1310 data 1310
            begin
               aAddress := '';
               i := Pos(#13#10,aSOAPmes); // Get chunk end
               while (i<>0) do
               begin
//TODO no test for length  no test for content length
                  inc(i,2);
                  aSOAPenv := Copy(aSOAPmes,i,length(aSOAPmes) - i + 1);
                  i := Pos(#13#10,aSOAPenv); // Get data end
                  aAddress := aAddress + Copy(aSOAPenv,1,i-1);
                  inc(i,2);
                  aSoapMes := Copy(aSOAPenv,i,length(aSOAPenv) - i + 1);
                  i := Pos(#13#10,aSOAPmes); // Get chunk end
               end;
               aSOAPmes := aAddress;
            end;

            if (laFlags and 2) <> 0 then aSOAPmes := XML_UnDecorate(aSOAPmes);
            // ready to parse soap envelope
            aAddress := Parse_Str(req,9,#27); // methode name
            aTemp := '/Envelope/Body/'+aAddress +'Response';
            aAuth := aTemp; // save only to response

            ic := Pos(aAddress+'Return',aSOAPmes);
            if ic = 0  then
            begin
               ic := Pos(aAddress+'return',aSOAPmes);
               if ic = 0 then
               begin
                  aTemp := aTemp + '/'+aAddress+'return';
               end;
            end else begin
               aTemp := aTemp + '/'+aAddress+'Return';
            end;

            if ic <> 0 then
            begin
               ic := 0; // first test for ..Response/return
               Result := TinyXML_Parse(aSOAPmes,aTemp,longint(ic));
               if length(Result) > 0 then aFlags := 0; //OK
            end;
            if aFlags <> 0 then
            begin
               ic := 0; // then only ..Response
               Result := TinyXML_Parse(aSOAPmes,aAuth,longint(ic));
               if length(Result) > 0 then aFlags := 0; //OK
            end;
            if ic <> 0  then
            begin
               aFlags := longint(ic) - 1000; // XML parse error
               Result := '';
            end;
         end;
      end;
   end;
end;

//------------------------------------------------------------------------------
function SoapCallW( req :WideString; var aFlags:longint) :WideString;
begin
   Result := UTF82Unicode( SoapCall( Unicode2UTF8(req),aFlags ) );
end;

end.
