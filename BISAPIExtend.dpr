library BISAPIExtend;


uses
  Windows;

const
   HSE_LOG_BUFFER_LEN        =  80;
   HSE_MAX_EXT_DLL_NAME_LEN  = 256;
   HSE_REQ_SEND_RESPONSE_HEADER = 3;

type
   PHSE_VERSION_INFO = ^HSE_VERSION_INFO;
   HSE_VERSION_INFO = packed record
      dwExtensionVersion: longword;
      lpszExtensionDesc: array [0..HSE_MAX_EXT_DLL_NAME_LEN-1] of Char;
   end;


   TGetServerVariableProc = function ( hConn: longword;
                                      VariableName: PChar;
                                      Buffer: Pointer;
                                      var Size: longword ): BOOL; stdcall;

   TWriteClientProc = function ( ConnID: longword;
                                Buffer: Pointer;
                                var Bytes: longword;
                                dwReserved: longword ): boolean; stdcall;

   TReadClientProc  = function ( ConnID: longword;
                                Buffer: Pointer;
                                var Size: longword ): boolean; stdcall;

   TServerSupportFunctionProc = function ( hConn: longword;
                                          HSERRequest: longword;
                                          Buffer: Pointer;
                                          var Size: longword;
                                          var DataType: longword ): boolean; stdcall;

   PEXTENSION_CONTROL_BLOCK = ^TEXTENSION_CONTROL_BLOCK;
   TEXTENSION_CONTROL_BLOCK = packed record
      cbSize: longword;                    // size of this struct.
      dwVersion: longword;                 // version info of this spec
      ConnID: longword;                 // Context number not to be modified!
      dwHttpStatusCode: longword;          // HTTP Status code
             // null terminated log info specific to this Extension DLL
      lpszLogData: array [0..HSE_LOG_BUFFER_LEN-1] of Char;
      lpszMethod: PChar;                // REQUEST_METHOD
      lpszQueryString: PChar;           // QUERY_STRING
      lpszPathInfo: PChar;              // PATH_INFO
      lpszPathTranslated: PChar;        // PATH_TRANSLATED
      cbTotalBytes: longword;              // Total bytes indicated from client
      cbAvailable: longword;               // Available number of bytes
      lpbData: Pointer;                 // pointer to cbAvailable bytes
      lpszContentType: PChar;           // Content type of client data

      GetServerVariable: TGetServerVariableProc;
      WriteClient: TWriteClientProc;
      ReadClient: TReadClientProc;
      ServerSupportFunction: TServerSupportFunctionProc;
  end;

const
   ISAPIExtention_name : ansistring = 'My ISAPI Extention'+#0;


//------------------------------------------------------------------------------
function GetExtensionVersion(pVer:PHSE_VERSION_INFO):longword; stdcall; export;
var s,d:pointer;
begin
   pVer.dwExtensionVersion := $00010000;
   s := @ISAPIExtention_name[1];
   d := @pVer.lpszExtensionDesc[0];
   Move(s^,d^,length(ISAPIExtention_name));
   Result := 1;
end;

//------------------------------------------------------------------------------
function HttpExtensionProc(pEcb:PEXTENSION_CONTROL_BLOCK):longword; stdcall; export;
var buff:ansistring;
    buffsize,p:longword;
begin
//   // Header
//   buff := 'Content-type: text/html'+#13#10#13#10;
//   buffsize := 0;
//   p := longword(@buff[1]);;
//   pEcb.ServerSupportFunction(pEcb.ConnID, HSE_REQ_SEND_RESPONSE_HEADER, Nil, buffsize, p);
   //Body
   buff :=  '<html>' +
            '<head><title>This is my output page!</title></head>' +
            '<body bgcolor=#FFFFFF>Hello World! Output from ISAPI Extension. rakkimk@hotmail.com </body>' +
            '</html>';
   buffsize:= length(buff);
   pEcb.WriteClient(pEcb.ConnID, @buff[1], buffsize, 0);

   Result := 1;
end;

//------------------------------------------------------------------------------
function TerminateExtension(dwFlags: longword): boolean; stdcall; export;
begin
   Result := true;
end;



exports
TerminateExtension,
HttpExtensionProc,
GetExtensionVersion;

begin
end.

(*   :) How to install ISAPI extention on II7
          1. On server ISAPI and CGI restrictions add [dll] and allow execution
          2. Create Application pool for[dll] directory and anble 32 bit mode in advanced options
          3. Create site test with this application pool
          4. handler mapping add isapi module   
          5. call server  host/test/isapi.dll
*)
