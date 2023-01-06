unit BHTTPRequest;

interface

//TODO string all type optimize

//add to header if need user and password
// head := head + 'Authorization: Basic '+BCodeBase64(usr+':'+pwd)+#13#10;

{$DEFINE USE_WINHTTP} //WinInet is not good for service and multi tread servers

type  HTTP_Request_CBSTR = record
         Flags:longword;
         TheCallBack:function(UserParm,TotalSize,BlockSize:longword; BlockData:pointer):longint; stdcall;
         UserParm:longword;
      end;


function HTTP_Request(const ASrv :AnsiString; APort :longword; const AUrl,ASoapAct,aAddHead,AData :AnsiString; var aResponse :Ansistring; blnSSL :Boolean = False; reserved:longword = 0) :longint;

implementation

uses windows;

//wininet extrac ---------------
type
  HINTERNET = Pointer;

{$IFDEF USE_WINHTTP}
function WinHTTPOpen(lpszAgent: PWideChar; dwAccessType: DWORD;
  lpszProxy, lpszProxyBypass: PWideChar; dwFlags: DWORD): HINTERNET; stdcall; external 'winhttp.dll' name 'WinHttpOpen';
function WinHTTPConnect(hInet: HINTERNET; lpszServerName: PWideChar;
  nServerPort: Word;  dwReserved: DWORD): HINTERNET; stdcall; external 'winhttp.dll' name 'WinHttpConnect';
function WinHTTPOpenRequest(hConnect: HINTERNET; lpszVerb: PWideChar;
  lpszObjectName: PWideChar; lpszVersion: PWideChar; lpszReferrer: PWideChar;
  lplpszAcceptTypes: PLPSTR; dwFlags: DWORD): HINTERNET; stdcall; external 'winhttp.dll' name 'WinHttpOpenRequest';
function WinHttpAddRequestHeaders(hRequest: HINTERNET; lpszHeaders: PWideChar;
  dwHeadersLength: DWORD; dwModifiers: DWORD): BOOL; stdcall; external 'winhttp.dll' name 'WinHttpAddRequestHeaders';
function WinHTTPSendRequest(hRequest: HINTERNET; lpszHeaders: PWideChar;
  dwHeadersLength: DWORD; lpOptional: Pointer;
  dwOptionalLength: DWORD; dwTotalLen :DWORD; dwContext:DWORD_PTR ): BOOL; stdcall; external 'winhttp.dll' name 'WinHttpSendRequest';
function WinHTTPReciveResponse(HRequest: HINTERNET; lpReserved:pointer): BOOL; stdcall; external 'winhttp.dll' name 'WinHttpReceiveResponse';
function WinHTTPQueryDataAvailable(HRequest: HINTERNET; var BytesAvailible:DWORD): BOOL; stdcall; external 'winhttp.dll' name 'WinHttpQueryDataAvailable';
function WinHTTPQueryHeaders(HRequest: HINTERNET; dwInfoLevel :DWORD;
     pwszName:pointer;  lpBuffer :pointer; var lpdwBuufLen:DWORD; lpdwIndex: pointer): BOOL; stdcall; external 'winhttp.dll' name 'WinHttpQueryHeaders';
function WinHTTPReadData(HRequest :HINTERNET; lpBuffer:Pointer;
   dwNumberOfBytesToRead: DWORD; var lpdwNumberOfBytesRead: DWORD): BOOL; stdcall; external 'winhttp.dll' name 'WinHttpReadData';
function WinHTTPCloseHandle(hInet: HINTERNET): BOOL; stdcall; external 'winhttp.dll' name 'WinHttpCloseHandle';
function WinHTTPSetOption(hInet: HINTERNET; dwOption:DWORD; lpBuffer:pointer;  dbBuffLen:DWORD): BOOL; stdcall; external 'winhttp.dll' name 'WinHttpSetOption';

function WinHTTPSetTimeouts(hInet: HINTERNET; ResolveTimeout,ConnectTimeout, SendTimeout, ReceiveTimeout :longint): BOOL; stdcall; external 'winhttp.dll' name 'WinHttpSetTimeouts';

{$ELSE}
function InternetOpen(lpszAgent: PAnsiChar; dwAccessType: DWORD;
  lpszProxy, lpszProxyBypass: PAnsiChar; dwFlags: DWORD): HINTERNET; stdcall; external 'wininet.dll' name 'InternetOpenA';
function InternetConnect(hInet: HINTERNET; lpszServerName: PAnsiChar;
  nServerPort: Word; lpszUsername: PAnsiChar; lpszPassword: PAnsiChar;
  dwService: DWORD; dwFlags: DWORD; dwContext: DWORD): HINTERNET; stdcall; external 'wininet.dll' name 'InternetConnectA';
function HttpOpenRequest(hConnect: HINTERNET; lpszVerb: PAnsiChar;
  lpszObjectName: PAnsiChar; lpszVersion: PAnsiChar; lpszReferrer: PAnsiChar;
  lplpszAcceptTypes: PLPSTR; dwFlags: DWORD;
  dwContext: DWORD): HINTERNET; stdcall; external 'wininet.dll' name 'HttpOpenRequestA';
function HttpAddRequestHeaders(hRequest: HINTERNET; lpszHeaders: PAnsiChar;
  dwHeadersLength: DWORD; dwModifiers: DWORD): BOOL; stdcall; external 'wininet.dll' name 'HttpAddRequestHeadersA';
function HttpSendRequest(hRequest: HINTERNET; lpszHeaders: PAnsiChar;
  dwHeadersLength: DWORD; lpOptional: Pointer;
  dwOptionalLength: DWORD): BOOL; stdcall; external 'wininet.dll' name 'HttpSendRequestA';
function InternetReadFile(hFile: HINTERNET; lpBuffer: Pointer;
  dwNumberOfBytesToRead: DWORD; var lpdwNumberOfBytesRead: DWORD): BOOL; stdcall; external 'wininet.dll' name 'InternetReadFile';
function InternetCloseHandle(hInet: HINTERNET): BOOL; stdcall; external 'wininet.dll' name 'InternetCloseHandle';
function HttpQueryInfo(hRequest: HINTERNET; dwInfoLevel: DWORD;  lpvBuffer: Pointer; var lpdwBufferLength: DWORD; var lpdwReserved: DWORD): BOOL; stdcall;  external 'wininet.dll' name 'HttpQueryInfoA';
{$ENDIF}

//   var ger:longint;

function HTTP_Request(const ASrv :AnsiString; APort :longword; const AUrl,ASoapAct,aAddHead,AData :AnsiString; var aResponse :Ansistring; blnSSL :Boolean = False; reserved:longword = 0) :longint;
var
   herr:boolean;
   aBuffer     : Array[0..8191] of byte; //8192 bytes

   wMethod     : WideString;
   wURL        : WideString;
   wHeader     : WideString;
   wSrv        : WideString;
{$IFNDEF USE_WINHTTP}
   sHeader     : AnsiString;
{$ENDIF}

   BufStr      : AnsiString;
   sMethod     : AnsiString;
   aT1,aT2,aT3 : Ansistring;
   BytesRead,i : longword;
   pSession    : HINTERNET;
   pConnection : HINTERNET;
   pRequest    : HINTERNET;
//  parsedURL   : TStringArray;
   flags,Cflags: DWord;
   Status,j,m  :longword;
   len,index   :longword;
   SActionHave :boolean;
   CTypeHave   :boolean;
   sp,dp       :pointer;
   ger:longint;
begin
  //ParsedUrl := ParseUrl(AUrl);

   Result := -900;  // http errors are 100-599
{$IFDEF USE_WINHTTP}
   pSession := WinHttpOpen(nil, 0 {WINHTTP_ACCESS_TYPE_DEFAULT_PROXY}, nil, nil, 0);
{$ELSE}
   pSession := InternetOpen(nil, 0 {INTERNET_OPEN_TYPE_PRECONFIG}, nil, nil, 0);
{$ENDIF}

   // WinHTTPSetTimeouts(pSession,5000,2000,5000,15000);

   if aPort = 443 then blnSSL := true; //force on this port

   if Assigned(pSession) then
   begin
      if blnSSL then
      begin
         flags := $00800000 {INTERNET_FLAG_SECURE};// or $00400000 {INTERNET_FLAG_KEEP_CONNECTION};
         if APort = 0 then APort := 443;
      end else begin
         flags := 0;
         if APort = 0 then APort := 80;
      end;

{$IFDEF USE_WINHTTP}
      WinHTTPSetTimeouts(pSession,60000,60000,60000,60000);
{$ENDIF}

      wSrv := WideString(aSrv);
{$IFDEF USE_WINHTTP}
      pConnection := WinHttpConnect(pSession, PWideChar(wSrv), APort, 0);
{$ELSE}
      pConnection := InternetConnect(pSession, PAnsiChar(aSrv), APort, nil{usr}, nil{pwd}, 3{INTERNET_SERVICE_HTTP}, flags, 0);
{$ENDIF}
      if Assigned(pConnection) then
      begin

         // Header to be add  automatic add Content length and header post get na dhost
         wHeader := 'User-Agent: Bogi' + #13#10;

         SActionHave := false;
         CTypeHave := false;
         if length(aAddHead) > 0 then
         begin
            aT1 := aAddHead;
            repeat
              i := Pos(#13#10,string(aT1));
              if i > 0 then
              begin
                 aT2 := Copy(at1,1,i-1);
                 m := length(aT2);
                 aT3 := aT2;
                 for j :=1 to m do aT3[j] := UpCase(aT3[j]);
                 if Pos('CONTENT-TYPE',string(aT3)) <> 0 then CTypeHave := true;
                 if Pos('SOAPACTION',string(aT3)) <> 0 then SActionHave := true;
                 wHeader := wHeader + widestring(aT2) +#13#10;
                 aT1 := Copy(aT1,i+2,length(aT1)-2);
              end;
            until i = 0;
         end;
//         if length(aAddHead) > 0 then sHeader := sHeader + aAddHead; // must have #13#10

         BufStr := '';
         if Length(AData) = 0 then
         begin
            sMethod := 'GET'
         end else begin
            sMethod := 'POST';
            if length(ASoapAct) < 1 then BufStr := 'text/plain' //txt' - old
            else begin
               if not SActionHave then wHeader := wHeader + 'SOAPAction: '+widestring(aSoapAct)+#13#10;
               BufStr := 'text/xml' //new is application/xml
            end
         end;

         if (length(BufStr) > 0) and not CTypeHave then wHeader := wHeader + 'Content-Type: '+ WideString(BufStr) +'; charset=UTF-8'+#13#10;



         if (flags and $00800000) <> 0 then // to use self signet certificates
         begin
            cflags := flags or $00001000 {INTERNET_FLAG_IGNORE_CERT_CN_INVALID }
                            or $00002000 {INTERNET_FLAG_IGNORE_CERT_DATE_INVALID }
                            or $00000080 {SECURITY_FLAG_IGNORE_REVOCATION }
                            or $00000200 {SECURITY_FLAG_IGNORE_CERT_WRONG_USAGE }
                            or $00000100;{SECURITY_FLAG_IGNORE_UNKNOWN_CA }
         end else cflags := 0;

//         flags := flags or $04000000; //INTERNET_FLAG_DONT_CACHE ???? did I need this

         wMethod := WideString(sMethod);
         wURL := WideString(aURL);
{$IFDEF USE_WINHTTP}
         pRequest := WinHTTPOpenRequest(pConnection, PWideChar(wMethod), PWideChar(wURL), nil, nil, nil,  flags);  //WINHTTP_FLAG_SECURE = $00800000;         pRequest := WinHTTPOpenRequest(pConnection, PWideChar(wMethod), PWideChar(wURL), nil, nil, nil,  flags);  //WINHTTP_FLAG_SECURE = $00800000;
{$ELSE}
         pRequest := HTTPOpenRequest(pConnection, PAnsiChar(sMethod), PAnsiChar(aURL), nil, nil, nil, cflags, 0);
{$ENDIF}
         ger  := GetLastError;
         if Assigned(pRequest) or (ger = 0)then
         begin


{$IFDEF USE_WINHTTP}
            if cflags <> 0 then WinHttpSetOption(pRequest, 31 {WINHTTP_OPTION_SECURITY_FLAGS},@cflags,sizeof(cflags));
{$ENDIF}

{$IFDEF USE_WINHTTP}
            herr := WinHttpAddRequestHeaders(pRequest, PWideChar(@wHeader[1]), Length(wHeader),$20000000 {HTTP_ADDREQ_FLAG_ADD});
{$ELSE}
            sHeader := ansistring(wHeader);
            herr := HttpAddRequestHeaders(pRequest, PAnsiChar(@sHeader[1]), Length(sHeader),$20000000 {HTTP_ADDREQ_FLAG_ADD});
{$ENDIF}
            // $80000000 {HTTP_ADDREQ_FLAG_REPLACE});
            // $20000000 {HTTP_ADDREQ_FLAG_ADD});
            if herr then
            begin
{$IFDEF USE_WINHTTP}
               if WinHTTPSendRequest(pRequest, nil, 0, Pointer(AData), Length(AData),Length(AData),0) then
{$ELSE}
               if HTTPSendRequest(pRequest, nil, 0, Pointer(AData), Length(AData)) then
{$ENDIF}
               begin
                  len := sizeof(Status);

{$IFDEF USE_WINHTTP}
                  herr := WinHTTPReciveResponse(pRequest, nil);
{$ENDIF}
                  index := 0;
                  if herr then
                  begin
{$IFDEF USE_WINHTTP}
                     WinHttpQueryHeaders(pRequest, 19 {WINHTTP_QUERY_STATUS_CODE} or $20000000 {WINHTTP_QUERY_FLAG_NUMBER},
                     nil {WINHTTP_HEADER_NAME_BY_INDEX} ,@Status, len, nil);
                     {WINHTTP_QUERY_CONTENT_LENGTH = 5}
{$ELSE}
                     HttpQueryInfo(pRequest, 19 {HTTP_QUERY_STATUS_CODE} or $20000000 {HTTP_QUERY_FLAG_NUMBER},
                     @Status, len, index );
{$ENDIF}

                     if Status = 200 then  // HTTP status 200 = OK
                     begin
{$IFDEF USE_WINHTTP}
                        WinHttpQueryHeaders(pRequest, 5 {WINHTTP_QUERY_CONTENT_LENGTH} or $20000000 {WINHTTP_QUERY_FLAG_NUMBER},
                        nil {WINHTTP_HEADER_NAME_BY_INDEX} ,@Status, len, nil);
{$ELSE}
                        HttpQueryInfo(pRequest, 5 {WINHTTP_QUERY_CONTENT_LENGTH} or $20000000 {HTTP_QUERY_FLAG_NUMBER},
                        @Status, len, index );
{$ENDIF}
                        // I have the content size in Status
                        aResponse := '';
                        repeat
                           // get response size
{$IFDEF USE_WINHTTP}
                           index := 0;
                           if WinHTTPQueryDataAvailable(pRequest,index) then
                           begin
                              if index > 0 then
                              begin
                                 SetLength(BufStr,index);
                                 if WinHTTPReadData(pRequest,@BufStr[1], index, BytesRead) then
                                 begin
                                    if BytesRead > 0 then
                                    begin
                                       if reserved <> 0 then
                                       begin

                                       end else begin
                                          SetLength(BufStr,BytesRead);
                                          j := length(aResponse);

                                          SetLength(aResponse,j + BytesRead);
                                          sp := @BufStr[1];
                                          dp := @aResponse[j+1];
                                          Move(sp^,dp^,BytesRead);
//                                          aResponse := aResponse + BufStr;
                                       end;
                                    end;
                                 end;
                              end;
                           end;
{$ELSE}
                           InternetReadFile(pRequest, @aBuffer, SizeOf(aBuffer), BytesRead);
                           index := BytesRead;

                           if index > 0 then
                           begin
//                              WinHTTPReadData(pRequest,@aBuffer, SizeOf(aBuffer), BytesRead);
                              if reserved <> 0 then
                              begin

                              end else begin
                                 SetLength(BufStr,BytesRead);
                                 for i := 0 to BytesRead - 1 do BufStr[i+1] := AnsiChar(aBuffer[i]);
                                 aResponse := aResponse + BufStr;
                              end;
//                              if Status >= index then dec(Status,index) else Status := 0;
//                           end else begin
//                              if Status <> 0 then Dec(Status);
                           end;
{$ENDIF}
                        until (index = 0); // all is read

              //          aResponse := aResponse + #0;
                        Result := 0; //OK
                     end else begin
                        Result := {Result +} longint(status) * -1; // resp status
                     end;
                  end else begin
                     Result := - ( GetLastError * 1000 ); // receive response
                  end;
               end else begin
                  Result := - ( GetLastError * 1000 );  // send request
               end;
            end else begin
               Result := - ( GetLastError * 1000 ); // http req header add
            end;
{$IFDEF USE_WINHTTP}
            WinHTTPCloseHandle(pRequest);
{$ELSE}
            InternetCloseHandle(pRequest);
{$ENDIF}
         end;
{$IFDEF USE_WINHTTP}
         WinHTTPCloseHandle(pConnection);
{$ELSE}
         InternetCloseHandle(pConnection);
{$ENDIF}

      end;
{$IFDEF USE_WINHTTP}
      WinHTTPCloseHandle(pSession);
{$ELSE}
      InternetCloseHandle(pSession);
{$ENDIF}

   end;

(*

   Result := -1;

   pSession := InternetOpen(nil, 0 {INTERNET_OPEN_TYPE_PRECONFIG}, nil, nil, 0);

   if Assigned(pSession) then
   begin
      if blnSSL then
      begin
         flags := $00800000 {INTERNET_FLAG_SECURE};// or $00400000 {INTERNET_FLAG_KEEP_CONNECTION};
         if APort = 0 then APort := 443;
      end else begin
         flags := 3 {INTERNET_SERVICE_HTTP}; // or $00400000 {INTERNET_FLAG_KEEP_CONNECTION};
         if APort = 0 then APort := 80;
      end;

  //TODO    WinHTTPSetTimeouts(pSession,2000,5000,5000,5000);
      pConnection := InternetConnect(pSession, PAnsiChar(aSrv), APort, nil{usr}, nil{pwd}, 3{INTERNET_SERVICE_HTTP}, flags, 0);

      if Assigned(pConnection) then
      begin

         // Header to be add  automatic add Content length and header post get na dhost
         sHeader := 'User-Agent: Bogi' + #13#10;

         SActionHave := false;
         CTypeHave := false;
         if length(aAddHead) > 0 then
         begin
            aT1 := aAddHead;
            repeat
              i := Pos(#13#10,string(aT1));
              if i > 0 then
              begin
                 aT2 := Copy(at1,1,i-1);
                 m := length(aT2);
                 aT3 := aT2;
                 for j :=1 to m do aT3[j] := UpCase(aT3[j]);
                 if Pos('CONTENT-TYPE',string(aT3)) <> 0 then CTypeHave := true;
                 if Pos('SOAPACTION',string(aT3)) <> 0 then SActionHave := true;
                 sHeader := sHeader + aT2 +#13#10;
                 aT1 := Copy(aT1,i+2,length(aT1)-2);
              end;
            until i = 0;
         end;
//         if length(aAddHead) > 0 then sHeader := sHeader + aAddHead; // must have #13#10

         BufStr := '';
         if Length(AData) = 0 then
         begin
            sMethod := 'GET'
         end else begin
            sMethod := 'POST';
            if length(ASoapAct) < 1 then BufStr := 'text/txt'
            else begin
               if not SActionHave then sHeader := sHeader + 'SOAPAction: '+aSoapAct+#13#10;
               BufStr := 'text/xml'
            end
         end;

         if (length(BufStr) > 0) and not CTypeHave then sHeader := sHeader + 'Content-Type: '+ BufStr +'; charset=UTF-8'+#13#10;


         if (flags and $00800000) <> 0 then // to use self signet certificates
         begin
            flags := flags or $00001000 {INTERNET_FLAG_IGNORE_CERT_CN_INVALID }
                           or $00002000 {INTERNET_FLAG_IGNORE_CERT_DATE_INVALID }
                           or $00000080 {SECURITY_FLAG_IGNORE_REVOCATION }
                           or $00000100; {SECURITY_FLAG_IGNORE_UNKNOWN_CA }
         end;

         flags := flags or $04000000;

         pRequest := HTTPOpenRequest(pConnection, PAnsiChar(sMethod), PAnsiChar(aURL), nil, nil, nil, flags, 0);

         if Assigned(pRequest) then
         begin

            herr := HttpAddRequestHeaders(pRequest, PAnsiChar(@sHeader[1]), Length(sHeader),$20000000 {HTTP_ADDREQ_FLAG_ADD});
            //$80000000 {HTTP_ADDREQ_FLAG_REPLACE});
            //$20000000 {HTTP_ADDREQ_FLAG_ADD});

            if HTTPSendRequest(pRequest, nil, 0, Pointer(AData), Length(AData)) then
            begin
               //Status := '000';
               len := sizeof(Status);
               index := 0;
               HttpQueryInfo(pRequest, 19 {HTTP_QUERY_STATUS_CODE} or $20000000 {HTTP_QUERY_FLAG_NUMBER},
                             @Status, len, index );
               if Status = 200 then  // HTTP status 200 = OK
               begin
                  aResponse := '';
                  while InternetReadFile(pRequest, @aBuffer, SizeOf(aBuffer), BytesRead) do
                  begin
                     if (BytesRead = 0) then Break;
                     SetLength(BufStr,BytesRead);
                     for i := 0 to BytesRead - 1 do BufStr[i+1] := AnsiChar(aBuffer[i]);
                     aResponse := aResponse + BufStr;
                  end;

                  aResponse := aResponse + #0;
                  Result := 0; //OK
               end else begin
                  Result := longint(status) * -1;
               end;
            end else begin
               Result := - ( GetLastError * 1000 );
            end;
            InternetCloseHandle(pRequest);
         end;
         InternetCloseHandle(pConnection);
      end;
      InternetCloseHandle(pSession);
   end;

*)


end;

end.
