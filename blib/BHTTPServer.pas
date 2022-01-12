unit BHTTPServer;

interface

//version 2.0  :) 2016-2020
{$IFNDEF FPC }
{$IFDEF RELEASE}
{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([]) }
{$ENDIF}
{$ENDIF}

{TODO main problem is not thread save !!!!! :(
      send big file by slpit the send in limited blocks  
}

uses Windows,
     BSocket,
     BNetTools, BLogFile,
     BFileTools, BStrTools, BHTTPget,
     BExecute, BBase64;


const
      FHTTPServer_Proc       = $00000001;
      FHTTPServer_CGI        = $00000002;
      FHTTPServer_Emul       = $00000004;
      FHTTPServer_ISAPI      = $00000008;
      FHTTPServer_Proxy      = $00000010;
      FHTTPServer_TailSrv    = $10000000;

type
      BTHTTP_Data = record
         RequestA :ansistring;
         Request :string;
         Status:Longword;

         RootDir :string;

         Verb :string;
         Url :string;
         Que :string;
         htmlver :string;
         Host :string;
         Port :string;

         Data :ansistring;


         RemIP :string;
//         HtmHead :ansistring;
         DataLen :longword;
         DataType :string;
         SrvPort :string;
         ExePath :string;
         UsrAgent :string;
         Accept :string;
         Auth :string;
         user :string;
         pwd :string;
         refer :string;
         upgr :string;
         wskey :string;
         conn :string;
         Header:ansistring;
         Response :ansistring;
      end;

      BTPageProc = function(data :BTHTTP_Data; UserParm :longword) :ansistring; stdcall;

      BTHTTPServerIni = record
         Flags        :longword;
         Port         :longword;
         RootDir      :string;
         cgiexeext    :string;  // format '.exe.cgi'
         cgirunext    :string;  // format '.php.dwp'
         cgirun       :string;  // format '.php=phprun.exe;.dwp=dwprun.exe;' same count as cgirunext !!
         ProxyPage    :string;  // format '/sdsd"#13/efefef/edfe#13' delimiter #13
         ProxyPass    :string;  // format 'http://10.10.156.192#13https://mmm.com:8088/ttt/#13'  delimiuter #13 same count as ProxyPage !!



         ProcPage :string;  // name must be '/page'
         Proc     :pointer;
         ProcParm :longword;
         WSExtProc:pointer;
         WSExtPrParm :longword;
      end;

      BTHTTPServer = class
         private
            aServer :BTSocketServer;
            aConfig :BTHTTPServerIni;
         public
            constructor Create;
            destructor  Destroy; override;
            function    Run( config :BTHTTPServerIni) :longint;
      end;



implementation


///////////// TINY WEB SERVER



const HTTP_VER       = 'HTTP/1.1';
      HTTP_OK        = ' 200 OK'+#13#10;
      HTTP_NOTFOUND  = ' 404 Not Found'+#13#10;
      HTTP_ERROR     = ' 503 Service Unavailable'+#13#10;
      HTTP_MOVED     = ' 301 Moved Permanently'+#13#10;


procedure _BuildEnv(var Dat :BTHTTP_Data; var EnvStr:string);

   procedure add(Name,value:string);
   begin
      EnvStr := EnvStr + Name + '=' + value + #0;
   end;
begin
   EnvStr := '';
   add('GATEWAY_INTERFACE','CGI/1.1');
   add('REMOTE_HOST',dat.host);
   add('REMOTE_ADDR',dat.RemIP);
   add('REQUEST_METHOD',dat.Verb);
   add('SCRIPT_NAME',dat.Url);
   add('QUERY_STRING',dat.Que);
   add('CONTENT_LENGTH',toStr(dat.DataLen));
   add('CONTENT_TYPE',dat.DataType);
   add('SERVER_PROTOCOL',HTTP_VER);
   add('SERVER_PORT',dat.SrvPort);
   add('SERVER_NAME','SAB labs - WS');
   add('SERVER_SOFTWARE','B_microHTML Server v1.0 2016');
   add('PATH_INFO',ExtractFile(dat.Url));
   add('PATH_TRANSLATED',dat.ExePath);
   add('HTTP_ACCEPT',dat.Accept);
   add('HTTP_USER_AGENT',dat.UsrAgent);
   add('HTTP_REFERER',dat.refer);
   add('USER_NAME',dat.user);
   add('USER_PASSWORD',dat.pwd);
   add('AUTH_TYPE',dat.Auth);
   add('REMOTE_IDENT',dat.pwd); //todo ?????
   add('REMOTE_USER',dat.user);
//      HTTP_COOKIE       :string;

   EnvStr := EnvStr + #0;
end;



function callback(const param:ansistring; var Response:ansistring; userparam:longword; var srv:BTSocketSession):longint; stdcall;
var a:BTHTTPServer;
    i,j,k,m,l,Err,TheVerb:longint;
    c:char;
    s,BasePath,TheHost,ExePath,Value:string;
    path:string;
    proc:BTPageProc;
    Dat :BTHTTP_Data;
    Line,Verb :string;
    HL,EL,EOF,FConKeep:longword;
    fext,fexe:string;
    env:ansistring;
    er:longint;
    cdel:char;
    doindexfile:boolean;
 //   Res : ansistring;


begin
//   Result := -1;
   Response := '';
   Err := 0;

   a := BTHTTPServer(userparam);

   dat.RequestA := param;
   dat.Request := string(dat.RequestA);
   dat.Status  := 404;
   dat.Response := '';

   dat.RootDir := a.aConfig.RootDir;
     i := length(a.aConfig.RootDir);
     if (dat.RootDir[i] = '/') or (dat.RootDir[i] = '\') then dat.RootDir := LeftStr(dat.RootDir,i-1);

   dat.Auth := '';
   dat.user := '';
   dat.pwd := '';
   dat.DataLen := 0;

   dat.SrvPort := ToStr(a.aConfig.Port);
   dat.RemIP := PZStrToStr(@srv.RemoteAdr[1]);



   doindexfile := false;

   TheVerb := 255; // something unknown
   FConKeep := 0;

   j := Length(dat.Request);
   if j > 4 then // just a number
   begin
      BDebug('d:\bdebug.log','HTTP server',srv.nSocket);
      BDebugs('d:\bdebug.log','request = '+dat.Request,srv.nSocket);
      // parse HTML header
      EL := 0;
      cdel := ' '; //on first row delimiter is ' '
      repeat


         Line := Trim(ParseStr(dat.Request,EL,#13)); // get header elements
   //      BDebugS('d:\bdebug.log','-1',srv.nSocket);
         Verb := UpperCase(ParseStr(Line,0,cdel));
   //      BDebugS('d:\bdebug.log','-2',srv.nSocket);
         i := StrToCase(Verb,[{0}'GET',{1}'POST',{2}'PUT',{3}'PATCH',{4}'DELETE',
                             {5}'HOST',{6}'CONNECTION',{7}'CONTENT-LENGTH',
                             {8}'CONTENT-TYPE',{9}'ACCEPT',{10}'USER-AGENT',{11}'AUTHORIZATION','REFERER']);

         Value := Trim(ParseStr(Line,1,cdel));
         cdel := ':'; // next delimiter is ':'
   //      BDebugS('d:\bdebug.log','Parse Verb = '+Verb,srv.nSocket);
   //      BDebugS('d:\bdebug.log','Parse Vlaue = '+Value,srv.nSocket);
         if i >= 0 then
         begin
            case i of
               0,1,2,3,4 : begin
                  TheVerb := i;
                  dat.Verb := Verb;
                  Value := HTTPDecode(Value);
                  if Pos('?',Value) <> 0 then
                  begin
                     dat.Url := ParseStr(Value,0,'?');
                     dat.Que := ParseStr(Value,1,'?');
                  end else begin
                     dat.Url := Value;
                     dat.Que := '';
                  end;
                  dat.htmlver := Trim(ParseStr(Line,2,' '));
                  s := ParseStr(dat.htmlver,0,'/'); // test fro HTTP only
                  if s <> 'HTTP' then
                  begin
                     Err := 1;
                  end;
               end;
               5: begin // HOST: www.best.com:50
                  TheHost := Value; // full
                  dat.Host := Value;
                  dat.Port := '80';
                  Verb := ParseStr(Line,2,':');
                  if length(Verb) > 0 then
                  begin
                     dat.Host := Trim(ParseStr(Line,1,':'));
                     dat.Port := Verb;
                  end;
               end;
               6: begin // CONNECTION    //TODO
                  if UpperCase(Value) = 'KEEP-ALIVE' then FConKeep := 1 and srv.sPerm; // set if it is permited
               end;
               7: begin // CONTENT_LENGTH
                  dat.DataLen := ToVal(Value);
                  if dat.DataLen = 0 then Err := 1;

               end;
               8: begin  // CONTENT-TYPE
                  dat.DataType := Value;
               end;
               9: begin  // ACCEPT
                  dat.Accept := Value;
               end;
               10: begin  // USER AGENT
                  dat.UsrAgent := Value;
               end;
               11: begin
                  if UpperCase(ParseStr(Value,0,' ')) = 'BASIC' then
                  begin
                     fext := string(BDecodeBase64(ansistring(ParseStr(Value,1,' '))));
                     dat.user := ParseStr(fext,1,':');
                     dat.pwd := ParseStr(fext,2,':');
                     if length(dat.user) <> 0 then dat.Auth := 'BASIC';
                  end;
               end;
            end;
         end else begin
            //NOP unknown verb
         end;
         inc(EL);
      until (length(Line) = 0);

      if dat.DataLen > 0 then // get data
      begin
         k := Pos(#13#10#13#10,dat.Request);
         if k > 0 then
         begin
            inc(k,4);
            if (k+longint(dat.DataLen)) <= j then
            begin
                  dat.Data := Copy(Param,k,dat.DataLen);
            end else Err := 1;
         end else Err := 1;
      end;

         BDebugS('d:\bdebug.log','Corect url',srv.nSocket);
      // parsing is finish tru to get result
      if Err = 0 then
      begin
         // URL correcor
         // RULES
         // the url must start with '/'
         // if no file extention

         if Pos(TheHost, dat.Url) <> 0 then
         begin    // if host is part ou url remove it  ? DID I NEED THIS
            i := length(TheHost);
            dat.Url := MidStr(dat.Url,i+1,length(dat.Url) - i);
         end;
         if dat.Url = '' then dat.Url := '/';  // is this possible
         if dat.Url[1] <> '/' then dat.Url := '/' + dat.Url;

         if dat.Url[length(dat.Url)] <> '/' then
         begin
            // test for redirection
            s := dat.RootDir + dat.Url;
            CorrectDirChar(s);
            if DirectoryExist(s) then
            begin
               dat.Url := dat.Url + '/';
               dat.Status := 301;
            end;
         end else begin
            doindexfile := true;
            dat.Url := dat.Url+'index.html' // auto ad index file
         end;
         fext := ExtractFileExt(dat.Url);
         if fext = 'map' then
         begin
            if Pos('.js.map',dat.URL) <> 0 then
            begin
             Response :=  'HTTP/1.0 403 Forbidden'+#13#10+
//                          'Connection: Close'
//Server: TinyWeb/1.94
                           'Content-Length: 72'+#13#10+
                           'Content-Type: text/html'+#13#10+#13#10+
                           '<HTML><TITLE>403 Forbidden</TITLE><BODY><H1>Forbidden</H1></BODY></HTML>';
               Result := 0;
               Exit;
            end;
         end;

         i := Length(dat.Url);
         while i > 0 do
         begin
            if Pos(dat.Url[i],'/') <> 0 then Break;
            Dec(i);
         end;
         basepath := Copy(dat.Url, 1, i);


         // try to execute NOW

         //try for proxy
         //TODO
         if (dat.Status = 404) and ((a.aConfig.Flags and FHTTPServer_Proxy) <> 0) then
         begin
{           i := 0;
            repeat
               path := ParseStr(a.aConfig.ProxyPage,i,#13);
               k := length(path);
               if (k>0) then
               begin



               end;
               inc(i);
            until k = 0; }

            if Pos('/pipi/',dat.URL) <> 0 then
            begin
              BasePath := 'al08:8000/'+RightStr(dat.Url,length(dat.Url) - 6);
              HTTP_Get(ansistring(BasePath),Response);
              dat.Status := 200; //todo

            end;

         end;

         //try by internal executor
         //TODO
         if (dat.Status = 404) and ((a.aConfig.Flags and // use page-proc methode
             (FHTTPServer_Proc or FHTTPServer_Emul)) <> 0 )then
         begin
            if (Pos(a.aConfig.procpage, BasePath) = 1)  // starts with
               or ((a.aConfig.Flags and FHTTPServer_Emul)<>0) then // emulation
            begin
               proc := BTPageProc(a.aConfig.Proc);
               if assigned(proc) then
               begin
                  Response := proc(dat, a.aConfig.ProcParm);
                  dat.Status := 200;
                  if length(Response) = 0  then dat.Status := 503; // semi error  //TODO
               end;
            end;
         end;

         // haveRes = 0 then try to execute by cgi
         if (dat.Status = 404) and ((a.aConfig.Flags and FHTTPServer_CGI) <> 0) then
         begin // cgi execute program
            if pos(fext, a.aConfig.cgiexeext) <> 0 then // test page .ext
            begin
               Path := a.aConfig.RootDir + dat.Url; // to be run
               CorrectDirChar(dat.ExePath);
               _BuildEnv(dat,s);
               Env := ansistring(s);
               er := ExecuteFile(Path,'', true,true,true,Env,dat.Data,Response);
               dat.Status := 202;
               if er <> 0 then dat.Status := 503;
               if length(Response) = 0  then dat.Status := 503; // semi error :(
               // to do error = 0 ok
            end else begin
               if pos(fext, a.aConfig.cgirunext) <> 0 then  //php
               begin
                  i := pos(fext+'=', a.aConfig.cgirun);
                  path := copy(a.aConfig.cgirun, i, longint(length(a.aConfig.cgirun)) - i + 1);
                  i := Pos(';',path);
                  ExePath := copy(path, 1, i - 1);
                  path := a.aConfig.RootDir + dat.Url;  // param passed to exe
                  CorrectDirChar(ExePath);
                  CorrectDirChar(path);
                  dat.ExePath := ExePath;
                  _BuildEnv(dat,s);
                  Env :=ansistring(s);
                  er := ExecuteFile(ExePath, path, true,true,true,Env,dat.Data,Response);
                  dat.Status := 200;
                  if er <> 0 then dat.Status := 503; //todo
                  if length(Response) = 0  then dat.Status := 503; // semi error :(
               end;
            end;
         end;

         //Try to execute by ISAPI
         if (dat.Status = 404) and ((a.aConfig.Flags and FHTTPServer_ISAPI) <> 0) then
         begin
         end;

         // normal web file get
         if dat.Status = 404 then
         begin  // get content from directory
            if theVerb = 0 then  // only GET for pure file access
            begin
         BDebugS('d:\bdebug.log','Get File',srv.nSocket);
               path := dat.RootDir + dat.Url;
               CorrectDirChar(path);
               if  FileLoadEx(path,Response) then dat.Status := 200;
               if  (dat.Status = 404) and doindexfile then // .html not found now try .htm
               begin
                  path := ChangeFileExt(path,'htm');
                  if  FileLoadEx(path,Response) then dat.Status := 200;
               end;
            end else Err := 1;
         end;

      end;
   end; // Ihave request


   // prepare the response

   if Err <> 0 then dat.Status := 503;

   dat.Header := HTTP_VER;


   case dat.Status of
      200: begin
              dat.Header := dat.Header + HTTP_OK;
           end;
      301: begin
              dat.Header := dat.Header + HTTP_MOVED;
              s := 'HTTP://'+dat.Host+':'+dat.Port+dat.URL;
              dat.Header := dat.Header + 'Location: '+ansistring(s)+#13#10;
              Response := '<head><title>Doc Moved</title></head><body>'+
                  '<h1>Object Moved</h1>New position <a HREF="'+ansistring(s)+'">here</a></body>';
           end;
      404: begin
              dat.Header := dat.Header + HTTP_NOTFOUND;
              Response := '<html><head><title>404 NOT FOUND</title></head><body>'+
                  '<h2> (404) The URL - '+ansistring(dat.Url)+' not found on the server</h2></body></html>';
           end;
      else begin // this inc 503
              dat.Header := dat.Header + HTTP_ERROR;
              Response := '<html><head><title>Big Error</title></head><body>'+
                  '<h2>Sorry some sort of undefined internal error :(</h2></body></html>';
              fConKeep := 0; // abort it
            end;
   end;

//      if Pos('CONTENT-TYPE:',UpperCase(string(Response))) = 0 then
//      begin

   //MIME
   s := '';
//      if Pos('CONTENT-TYPE:',UpperCase(string(Response))) = 0 then
//      begin
   m := 0;
   if fext = 'css' then  m := 1;
   if fext = 'js'  then  begin m := 3; fext := 'jscript'; end; //javascript
   if fext = 'json' then  m := 1;
   if fext = 'xml' then  m := 1;
   if fext = 'gif' then m := 2;
   if fext = 'png' then m := 2;
   if fext = 'ico' then m := 2;
   if fext = 'jpg' then m := 2;
   if fext = 'bmp' then m := 2;
   if fext = 'tiff' then m := 2;

   s := 'Content-Type: ';
   if m = 0  then s := s + 'text/html'; //; charset=utf-8';
   if m = 1  then s := s + 'text/' + fext;
   if m = 2  then s := s + 'image/' + fext;
   if m = 3  then s := s + 'text/plain'; //'application/' + fext;

   dat.Header := dat.Header + ansistring(s)+#13#10;

   i := length(Response);
   if i > 0 then s := 'Content-Length: ' + ToStr(i)
            else s := 'Content-Length: 0';  // is this possible //todo
   dat.Header := dat.Header + ansistring(s)+#13#10;


   if fConKeep = 1 then  s := 'Connection: Keep-Alive'
                   else  s := 'Connection: Close';
   dat.Header := dat.Header + ansistring(s)+#13#10;

   //         path := path + 'Date: Wed, 01 Jul 2020 10:27:21 GMT'+#13#10;
//   path := path + 'Last-Modified: Wed, 25 Dec 2019 19:51:58 GMT'+#13#10;
   dat.Header := dat.Header + 'Server: BTinyWeb'+#13#10;


   Response := dat.Header + #13#10 + Response;

   //if not keep alive connection then
   if fConKeep = 1 then srv.sMode := 1; // do not close  connection


   Result := 0;
end;



//------------------------------------------------------------------------------
constructor BTHTTPServer.Create;
begin
   aServer := BTSocketServer.Create;
end;

//------------------------------------------------------------------------------
destructor  BTHTTPServer.Destroy;
begin
   aServer.Disconnect;
   aServer.Free;
   inherited;
end;

//------------------------------------------------------------------------------
function    BTHTTPServer.Run(config:BTHTTPServerIni) :longint;
var aTail:boolean;
begin
   Result := -1;
   aConfig := config;
   aTail := false;
   if (aConfig.Flags and FHTTPServer_TailSrv)<> 0 then aTail := true;

   if aServer.Connect('0.0.0.0', aConfig.Port) = 0 then
   begin
      aServer.SetListener(@callback, longword(self),aTail);
      Result := 0;
   end;
end;


end.
