unit BHTML5_matic;

interface

type
      BTHTML5_matic = class
         private
            PageTitle :String;
            PageName :String;
            PageText :Ansistring;
            PageJavaScript :AnsiString;
            PageCSS :AnsiString;
            PageBody :AnsiString;
            aInline :boolean;
            aCompress :boolean;
            aHTML5 :boolean;
            aTouch :boolean;
            function    _CompressCRLF(txt_in :Ansistring; rm :longword) :Ansistring;
            function    _CompressJS(txt_in :Ansistring) :Ansistring;
            procedure   _Reset(reset_flags :longword);
         public
            constructor Create;
            destructor  Destroy; override;
            procedure   BeginPage(const Page_Name :String; const Title :WideString);

            function    Build :longint;
            function    SaveToDir(PageDir :string) :boolean;


            property    GetHTML :Ansistring read PageText;
            property    GetJS :Ansistring read PageJavaScript;
            property    GetCSS :Ansistring read PageCSS;
            property    GetBODY :AnsiString read PageBody;
            property    Compress :boolean read aCompress write aCompress;
            property    HTML5 :boolean read aHTML5 write aHTML5;
      end;








implementation

uses BFileTools,
     BUnicode;

//------------------------------------------------------------------------------
procedure   BTHTML5_matic._Reset(reset_flags:longword);
begin
   if reset_Flags = 0 then
   begin
      aInline := false;
      aCompress := false;
      aHTML5 := true;
      aTouch := true;   /////////////////????todo
   end;
   PageTitle := 'untitle';
   PageName := 'untitle';
   PageJavaScript := '';
   PageCSS := '';
   PageText :='';
   PageBody := '';
end;

//------------------------------------------------------------------------------
constructor BTHTML5_matic.Create;
begin
   _Reset(0);
end;

//------------------------------------------------------------------------------
destructor  BTHTML5_matic.Destroy;
begin
   inherited;
end;

//------------------------------------------------------------------------------
procedure   BTHTML5_matic.BeginPage(const Page_Name :String; const Title :WideString);
begin
   _Reset(1);
   PageTitle := Unicode2UTF8(Title);
   PageName := AnsiString(Page_Name);
end;


//------------------------------------------------------------------------------
function    BTHTML5_matic._CompressCRLF(txt_in :ansistring; rm :longword) :ansistring;
var i,j:longword;
    c:ansichar;
begin
   Result := '';
   j := length(txt_in);
   for i := 1 to j do
   begin
      c := txt_in[i];
      if (c = #13) or (c = #10) then if rm = 0 then continue
                                               else if c = #13 then c := #32
                                                               else continue;
      Result := Result + c;
   end;
end;

//------------------------------------------------------------------------------
function    BTHTML5_matic._CompressJS(txt_in :Ansistring) :Ansistring;
begin
   Result := txt_in;
end;

//------------------------------------------------------------------------------
function    BTHTML5_matic.Build :longint;
begin
   Result := 0;  //ok
   if aCompress then PageJavaScript := _CompressJS(PageJavaScript);
//<link rel="shortcut icon" href="/MoI/img/mvr.ico" type="image/x-icon" />
   PageText := '<!DOCTYPE html>' +#13#10
   + '<!-- BHTML5-matic -->' +#13#10
   + '<html lang="en">' +#13#10
   + '<head>' +#13#10
   + '<meta name="Generator" content="BHTML Generator v2.0.0">' +#13#10
//      + '<meta name="description" content="">' +#13#10+
        // '<!-- Mobile-friendly viewport -->' +#13#10+
   + '<meta http-equiv="X-UA-Compatible" content="IE=9">' +#13#10
//      + '<meta http-equiv="X-UA-Compatible" content="IE=8">'
   + '<meta name="viewport" content="user-scalable=no, width=device-width, initial-scale=1, minimum-scale=1, maximum-scale=1">' +#13#10
//      + '<meta name="viewport" content="width=device-width, initial-scale=1.0">' +#13#10
   + '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">' +#13#10
   + '<meta http-equiv="Content-Style-Type" content="text/css">' +#13#10
   + '<meta http-equiv="Content-Script-Type" content="text/javascript">' +#13#10;
// '<!-- Style sheet link -->' +#13#10
   if aInline then
   begin
      PageText := Pagetext + '<style type="text/css">' +#13#10 + PageCSS + '</style>'+#13#10
                           + '<script type = "text/jscript" language="JScript" >'+#13#10
                           +  PageJavaScript + '</script>' +#13#10;
   end else begin
      PageText := Pagetext + '<link type="text/css" rel="stylesheet" href="css/'+PageName+'_style.css"/>' +#13#10
                           + '<script defer type="text/javascript" src="js/'+PageName+'_script.js"></script>' +#13#10;
                           //defer todo
   end;
   PageText := Pagetext +  '<title>'+PageTitle+'</title>' +#13#10+'</head>'+#13#10
   + '<body spellcheck="false" style="margin-top:0px; margin-right:0px; margin-bottom:0px; margin-left:0px;" onload="pmain__load()" onunload="pmain__unload()">' +#13#10;
//   + '<body spellcheck="false" topMargin="0" leftMargin="0" onload="pmain__load()" onunload="pmain__unload()">' +#13#10;
   if Length(PageBody) > 0 then PageText := Pagetext + PageBody;

   if aHTML5 then
   begin
      PageText := Pagetext + '<noscript>' +#13#10
      + '<div class=script_err><div class=script_err_txt>JavaScript is not enabled ' +#13#10
      + 'in your web browser, and this application requires JavaScript in order ' +#13#10
      + 'to run properly.  Please enable JavaScript in your browser and reload this ' +#13#10
      + 'page in order to run the application.</div></div>' +#13#10
      + '</noscript>' +#13#10;
   end;

   PageText := Pagetext + '</body>' +#13#10 + '</html>' +#13#10;
   if aCompress then PageText := _CompressCRLF(PageText,0);
end;

//------------------------------------------------------------------------------
function    BTHTML5_matic.SaveToDir(PageDir :string) :boolean;
var S,Page_name,D:string;
begin
   Result := false; // fault
   if aTouch then Build;

   Page_Name := PageName;
   CorrectDirChar(Page_Name);
   if NOT DirectoryExist(PageDir) then Exit;

   S:=string(PageDir+'\'+Page_Name+'.html');
   D:=ExtractFilePath(S);
   if NOT DirectoryExist(D) then CreateDir(D); // make sub folder if need

   if length(PageText) <> 0 then
   begin
      if FileSave(S,PageText) then
      begin
         if not aInline then
         begin
            if length(PageJavaScript) <> 0 then
            begin
               S:=string(PageDir+'\js\');
               if NOT DirectoryExist(S) then CreateDir(S);
//      Txt := '// BHTML5-matic JavaScript builder '+#13#10+PageJavaScript;
               S:=S + string(Page_Name+'_script.js');

               if not FileSave(S,PageJavaScript) then Exit;
            end;
            if length(PageCSS) <> 0 then
            begin
               S:=string(PageDir+'\css\');
               if NOT DirectoryExist(S) then CreateDir(S);
//         Txt := '/* BHTML5-matic CSS builder */'+#13#10+PageCSS;
               S:=S + string(Page_Name+'_style.css');
               if not FileSave(S,PageCSS) then Exit;
            end;
         end;
         Result := true; // Ok
      end;
   end;
end;





end.
