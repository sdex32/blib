unit BCgiSoapServer;

interface

uses BCgi, BStrTools, BTinyXML, BNetTools, BLogFile, BHTTPServer;

const GateName :AnsiString = 'awsGate';   // WebService methode
      GateParam = 'sparam';               // WebService param name

type
      BTWebServer_callback = function(in_str:ansistring; userdata:longword):ansistring;



// to be used from CGI
function  CgiWebService_Response (var parstr :BTCGI_data; callback :pointer; userdata :longword ):longint; stdcall;
// to be used from HTTPServer proc call
function  HTTPproc_WebService_Response (var dat :BTHTTP_Data; callback :pointer; userdata :longword ):ansistring; stdcall;


implementation

//------------------------------------------------------------------------------
function  HTTPproc_WebService_Response (var dat :BTHTTP_Data; callback :pointer; userdata :longword ):ansistring; stdcall;
var cgi:BTCGI_Data;
begin
   // I need only this
   cgi.SCRIPT_NAME := dat.Url;
   cgi.REMOTE_HOST := dat.host;
   cgi.QUERY_STRING := dat.Que;
   if length(dat.Que) = 0 then cgi.QUERY_STRING := dat.Data;

   cgi.RESPONSE := '';
   CgiWebService_Response(cgi,callback,userdata);
   Result := cgi.RESPONSE;
end;

//------------------------------------------------------------------------------
function CgiWebService_Response (var parstr :BTCGI_data; callback :pointer; userdata :longword ):longint; stdcall;
var i :longint;
  //  Buffer :array [0..64] of Ansichar;
    ip :AnsiString;
    ErrText :Ansistring;
    Err :longint;
    Env :AnsiString;  // Envelop
    Sparam :AnsiString;
    doit :BTWebServer_callback;

begin
   Err := 0;
   Errtext := '';

   parstr.RES_CONTENT_TYPE := 'TEXT/XML';

   if MidStr(parstr.REMOTE_HOST,1,9) = 'localhost' then  // change local host with ip address
   begin
      ip := ansistring(Net_GetLocalIPaddress); // get local ip
   end else begin
      ip := AnsiString(parstr.REMOTE_HOST);
   end;

//   get program name
//   appname := ExtractFile(ParamStr(0));
//    appname :=  //todo  what to do ????
   if parstr.SCRIPT_NAME[1] <> '/' then parstr.SCRIPT_NAME := '/' + parstr.SCRIPT_NAME;

   if err = 0 then
   begin
   if Trim(LowerCase(parstr.QUERY_STRING)) = 'wsdl' then
   begin
      // WSDL request
      parstr.RESPONSE := '<?xml version="1.0" encoding="utf-8"?>' +
                          '<definitions xmlns="http://schemas.xmlsoap.org/wsdl/"'+
                          ' xmlns:xs="http://www.w3.org/2001/XMLSchema"'+
                          ' name="'+ parstr.SCRIPT_NAME +'"'+
                          ' targetNamespace="http://tempuri.org/"'+
                          ' xmlns:tns="http://tempuri.org/"'+
                          ' xmlns:soap="http://schemas.xmlsoap.org/wsdl/soap/"'+
                          ' xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/"'+
                          ' xmlns:mime="http://schemas.xmlsoap.org/wsdl/mime/">'+
                          '<message name="'+GateName+'0Request">'+
                          '<part name="'+GateParam+'" type="xs:string"/>' +
                          '</message>' +
                          '<message name="'+GateName+'0Response">' +
                          '<part name="return" type="xs:string"/>' +
                          '</message>' +
                          '<portType name="IeGate">' +
                          '<operation name="'+GateName+'">' +
                          '<input message="tns:'+GateName+'0Request"/>' +
                          '<output message="tns:'+GateName+'0Response"/>' +
                          '</operation>' +
                          '</portType>' +
                          '<binding name="IeGatebinding" type="tns:IeGate">' +
                          '<soap:binding style="rpc" transport="http://schemas.xmlsoap.org/soap/http"/>' +
                          '<operation name="'+GateName+'">' +
                          '<soap:operation soapAction="urn:eGateIntf-IeGate#'+GateName+'" style="rpc"/>' +
                          '<input>' +
                          '<soap:body use="encoded" encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" namespace="urn:eGateIntf-IeGate"/>' +
                          '</input>' +
                          '<output>' +
                          '<soap:body use="encoded" encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" namespace="urn:eGateIntf-IeGate"/>' +
                          '</output>' +
                          '</operation>' +
                          '</binding>' +
                          '<service name="IeGateservice">' +
                          '<port name="IeGatePort" binding="tns:IeGatebinding">' +
                          '<soap:address location="http://' + ip + parstr.SCRIPT_NAME + '"/>' +
                          '</port>' +
                          '</service>' +
                          '</definitions>' ;

   end else begin
         if Length(Trim(parstr.QUERY_STRING)) = 0  then
         begin
            // empty return Tittle
            ErrText := 'No request';
            Err := -1;
         end else begin
         // Calling
         // real part of the program -------------------------------------------
            i := 0;
            Env := TinyXML_Parse(AnsiString(parstr.QUERY_STRING),'/Envelope',i);
            if Env <> '' then
            begin
               i := 0;
               sparam := TinyXML_Parse(Env,'/Body/'+AnsiString(GateName)+'/'+AnsiString(GateParam),i);

               if callback <> nil then
               begin
                  doit := callback;
                  env := doit(sparam,userdata);
//                  Env := sparam + 'Hello';
               end else begin
                  env := 'Nil call object';
               end;

               parstr.RESPONSE := '<?xml version="1.0" encoding="utf-8"?>' +
                                '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"' +
                                ' xmlns:xsd="http://www.w3.org/2001/XMLSchema"' +
                                ' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"' +
                                ' xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/">' +
                                '<SOAP-ENV:Body SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">' +
                            		'<NS1:'+GateName+'Response xmlns:NS1="urn:eGateIntf-IeGate">' +
                             		'<return xsi:type="xsd:string">' +
                                Env +
                                '</return>' +
                            		'</NS1:'+GateName+'Response>' +
                              	'</SOAP-ENV:Body>' +
                                '</SOAP-ENV:Envelope>';
            end else begin
               // not an soap envelope
               Err := -1;
               ErrText := 'Invalid Soap request';
            end;
         end;
   end;
   end;  //error

   if Err <> 0 then
   begin
      parstr.RESPONSE := '<?xml version="1.0" encoding="UTF-8" ?>' +
                          '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
                          '<soapenv:Body>' +
                          '<soapenv:Fault>' +
                          '<faultcode>soapenv:Server.userException</faultcode>' +
                          '<faultstring>Exception: in '+GateName+'</faultstring>' +
                          '<detail>'+ErrText+'</detail>' +
                          '</soapenv:Fault>' +
                          '</soapenv:Body>' +
                          '</soapenv:Envelope>' ;
   end;

   Result := Err;

end;



end.
