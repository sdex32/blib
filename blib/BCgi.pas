unit BCgi;

interface


type
   BTCGI_Data = record
      AUTH_TYPE         :string;
      CONTENT_TYPE      :string;
      CONTENT_LENGTH    :string;
      GATEWAY_INTERFACE :string;
      PATH_INFO         :string;
      PATH_TRANSLATED   :string;
      REMOTE_ADDR       :string;
      REMOTE_HOST       :string;
      REMOTE_IDENT      :string;
      REMOTE_USER       :string;
      REQUEST_METHOD    :string;
      SCRIPT_NAME       :string;
      SERVER_NAME       :string;
      SERVER_PORT       :string;
      SERVER_PROTOCOL   :string;
      SERVER_SOFTWARE   :string;
      HTTP_ACCEPT       :string;
      HTTP_USER_AGENT   :string;
      HTTP_REFERER      :string;
      HTTP_COOKIE       :string;
      QUERY_STRING      :string;

      RESPONSE          :ansistring;
      RES_CONTENT_TYPE  :ansistring;
   end;


   CGI_exe_proc = function(var parstr :BTCGI_Data; userData :pointer ):longint; stdcall;




procedure CGI_Execute(call_back :CGI_exe_proc; userdata :pointer);



implementation

uses Windows,
     BStrTools,
     BStrings, // did i need this
//     BUnicode,
     BLogFile;


function GetEnvA(lpName: LPCSTR; lpBuffer: LPSTR; nSize: DWORD): DWORD; stdcall; external kernel32 name 'GetEnvironmentVariableA';

function _Env(Input: AnsiString): string;  //-- get enviroment variable
var
  OutputSize: integer;
  so:Ansistring;
  pc:pansichar;
begin
  result := '';
  OutputSize := 1;
  SetLength(so, OutputSize);
  // Get buffer size to hold environment variable plus null terminator

  OutputSize := GetEnvA(pansichar(@Input[1]), pansichar(@so[1]), OutputSize);
  if OutputSize > 0 then
  begin
     SetLength(so, OutputSize + 1);
    // Get environment variable
    if GetEnvA(pansichar(@Input[1]), pansichar(@so[1]), OutputSize) > 0 then
    begin
       so[OutputSize] := #0;
       pc := @so[1]; // fake delphi to read to zero of the string
       result := string(pc);
    end;
  end;
end;


procedure _DecodeRequest(AText: string; var List: BTStrings);
var
   i,j: Integer;
   Line: string;
begin
   Line :='';
   List.Clear;
   i := 0;
   j := Length(AText);
   if j > 0 then
   begin
      while i <= j do
      begin
         Inc(i);
         if AText[i] = '%' then
         begin
            if i + 2 > j then break; // error
            Line:= Line + Chr( HexVal(  Copy(AText, i + 1, 2)  ) );
            i := i + 2;
            continue;
         end;
         if AText[i] = '+' then  Line:= Line + ' ';
         if AText[i] = '&' then
         begin  // separator
            List.Add(Line);
            Line:= '';
            continue
         end;
         Line := Line + AText[i];
      end;
   end;
   if Line <> '' then List.Add(Line);
end;



procedure  _ErrorHTML(var dat:BTCGI_Data; const ErrorTxt:string);
begin
   with dat do
   begin
  	  RESPONSE := ansistring(
  	  '<HTML><HEAD><TITLE>B-CGI program interface</TITLE></HEAD>'+
  	  '<BODY>'+
  	  '<h1>Sorry small problem in ' + ErrorTxt + '</h1>' +
  	  '<h1>List of environment variables</h1>' +
   	  '<br>B-CGI program interface module' +
  	  '<br>AUTH_TYPE=' + AUTH_TYPE +
  	  '<br>CONTENT_LENGTH=' + CONTENT_LENGTH +
  	  '<br>CONTENT_TYPE=' + CONTENT_TYPE +
  	  '<br>GATEWAY_INTERFACE=' + GATEWAY_INTERFACE +
  	  '<br>PATH_INFO=' + PATH_INFO +
  	  '<br>PATH_TRANSLATED=' + PATH_TRANSLATED +
  	  '<br>REMOTE_ADDR=' + REMOTE_ADDR +
  	  '<br>REMOTE_HOST=' + REMOTE_HOST +
  	  '<br>REMOTE_IDENT=' + REMOTE_IDENT +
  	  '<br>REMOTE_USER=' + REMOTE_USER +
  	  '<br>REQUEST_METHOD=' + REQUEST_METHOD +
  	  '<br>SCRIPT_NAME=' + SCRIPT_NAME +
  	  '<br>SERVER_NAME=' + SERVER_NAME +
  	  '<br>SERVER_PORT=' + SERVER_PORT +
  	  '<br>SERVER_PROTOCOL=' + SERVER_PROTOCOL +
  	  '<br>SERVER_SOFTWARE=' + SERVER_SOFTWARE +
  	  '<br>HTTP_ACCEPT=' + HTTP_ACCEPT +
  	  '<br>HTTP_USER_AGENT=' + HTTP_USER_AGENT +
  	  '<br>HTTP_REFERER=' + HTTP_REFERER +
  	  '<br>HTTP_COOKIE=' + HTTP_COOKIE +
      '<br>QUERY_STRING=' + QUERY_STRING +
  	  '</BODY></HTML>');
   end;
end;


procedure CGI_Execute(call_back :CGI_exe_proc; userdata :pointer );
var
   CGI_data :BTCGI_data;
   // temp vars
   fFullResponse :AnsiString;
   hCon :longword;
   i,j :longword;
begin
   if not assigned(call_back) then Exit;
   

   with CGI_data do
   begin

      RESPONSE := '';

      AUTH_TYPE         := _Env('AUTH_TYPE');
	  	CONTENT_TYPE      := _Env('CONTENT_TYPE');
		  CONTENT_LENGTH    := _Env('CONTENT_LENGTH');
      GATEWAY_INTERFACE := _Env('GATEWAY_INTERFACE');
      PATH_INFO         := _Env('PATH_INFO');
      PATH_TRANSLATED   := _Env('PATH_TRANSLATED');
      REMOTE_ADDR       := _Env('REMOTE_ADDR');
      REMOTE_HOST       := _Env('REMOTE_HOST');
   	  REMOTE_IDENT      := _Env('REMOTE_IDENT');
      REMOTE_USER       := _Env('REMOTE_USER');
      REQUEST_METHOD    := _Env('REQUEST_METHOD');
      SCRIPT_NAME       := _Env('SCRIPT_NAME');
      SERVER_NAME       := _Env('SERVER_NAME');
      SERVER_PORT       := _Env('SERVER_PORT');
      SERVER_PROTOCOL   := _Env('SERVER_PROTOCOL');
      SERVER_SOFTWARE   := _Env('SERVER_SOFTWARE');
      HTTP_ACCEPT       := _Env('HTTP_ACCEPT');
      HTTP_USER_AGENT   := _Env('HTTP_USER_AGENT');
      HTTP_REFERER      := _Env('HTTP_REFERER');
      HTTP_COOKIE       := _Env('HTTP_COOKIE');

      REQUEST_METHOD := UpperCase(REQUEST_METHOD);
  		if REQUEST_METHOD = 'GET' then
      begin
			   QUERY_STRING := _Env('QUERY_STRING');
			   CONTENT_LENGTH := ToStr(length(QUERY_STRING));
		  end else begin
         if REQUEST_METHOD = 'POST' then
         begin
        	  QUERY_STRING := '';
      			i := ToVal(CONTENT_LENGTH);
       			if (i > 0) then
            begin
       				// We have to read the exact amount of characters
			        // as there may be more data on the standard input
              SetLength(QUERY_STRING,i);
              hCon := GetStdHandle(STD_INPUT_HANDLE);
              ReadFile(hCon,pointer(@QUERY_STRING[1])^,i,j,nil);
              CloseHandle(hCon);
    				end;
				    QUERY_STRING := QUERY_STRING + #0; //todo did i need this
		     end else begin
  		      // UNKNOWN Method
      			QUERY_STRING := '';
         end;
      end;

      RES_CONTENT_TYPE := 'TEXT/HTML';
      i := call_back(CGI_data, userdata);
      if i <> 0 then _ErrorHTML(CGI_Data,'user proc :)');

      fFullResponse := 'CONTENT-TYPE: ' + RES_CONTENT_TYPE+ #13#10;
      // if cookie to set then
//   fFullResponse := fFullResponse + 'Set-Cookie: %s=%s' #13#10
      fFullResponse := fFullResponse + #13#10 + RESPONSE +#13#10;

      hCon := GetStdHandle(STD_OUTPUT_HANDLE);
      WriteFile(hCon,pointer(@fFullResponse[1])^,length(fFullResponse),j,nil);
      CloseHandle(hCon); //todo did i need it
   end;
end;

end.
