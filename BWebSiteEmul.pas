unit BWebSiteEmul;

interface

uses BHTTPServer;

type  BTWebSiteEmul = class
         private
            aQuery :string;
            aWebRoot :pointer;
            aWebRootSize :longword;
            aTopPos :longword;
            function    _SetContent(  PageUrl: string; on_off:boolean) :longint;
            function    _TestCapacity(sz:longword):boolean;
            function    _UrlAdjust(var url:string):ansistring;
         public
            constructor Create;
            destructor  Destroy; override;
            function    AddContent( PageUrl :string; Data :pointer; DataLen :longword) :longint;
            function    AddContentStr( PageUrl :string; const Data :ansistring) :longint;
            function    AddContentEx( PageUrl :string; Proc :pointer; ProcParm :longword) :longint;
            function    GetContent( PageUrl: string; var Response:ansistring ) :longint;
            function    DisableContent( PageUrl: string ):longint;
            function    EnableContent( PageUrl: string ):longint;
            property    GetTotalMemAlloc :longword read aWebRootSize;
            property    GetTotalMemUsed  :longword read aTopPos;
      end;


  function WebPageProc(data :BTHTTP_Data; UserParm :longword) :ansistring; stdcall;


implementation


uses BStrTools, BHash;

type arr_dw = array [0..8] of longword;
     GenPageProc = function ( GenParm :longword; Query :ansistring; var Resonse :ansistring) :longint;

//------------------------------------------------------------------------------
constructor BTWebSiteEmul.Create;
begin
   aWebRoot := nil;
   aWebRootSize := $10000;
   ReallocMem(aWebRoot,aWebRootSize);
   aTopPos := 0;
end;

//------------------------------------------------------------------------------
destructor  BTWebSiteEmul.Destroy;
begin
   if aWebRoot <> nil then ReallocMem(aWebRoot,0);

   inherited;
end;


// content structure
// tag size :longword  -- total size
// flags    :longword
// url hash :longword
// url size :longword
// Data size / proc :longword;
// nop       / procparm :longword;
// the url  :char..char
// data     : byte..byte

//------------------------------------------------------------------------------
function    BTWebSiteEmul._TestCapacity(sz:longword):boolean;
begin
   Result := true;
   if (aTopPos + sz + 6*4) > aWebRootSize then
   begin // no place realloc
      inc(aWebRootSize,$10000);
      ReallocMem(aWebRoot,aWebRootSize);
      if aWebRoot = nil then Result := false;
   end;
end;

//------------------------------------------------------------------------------
function    BTWebSiteEmul._UrlAdjust(var url:string):ansistring;
begin
   url :=  ReplaceChar(Url,'\','/'); // make all /
   if url[1] <> '/' then url := '/' + url;
   Result := ansistring(url);
end;

//------------------------------------------------------------------------------
function    BTWebSiteEmul.AddContent( PageUrl :string; Data :pointer; DataLen :longword) :longint;
var p:^arr_dw;
    sz:longword;
    s:ansistring;
    ps,pd:pointer;
begin
   Result := -1; // fail
   if aWebRoot <> nil then
   begin
      s := _UrlAdjust(PageUrl);
      sz := DataLen + longword(Length(s));
      if _TestCapacity(sz) then
      begin
         p := pointer(longword(aWebRoot) + aTopPos);
         p^[0] := sz + 6*4; // Total Size  .1
         p^[1] := 1;        // Flags       .2   1=Stored in webroot
         p^[2] := FNV1aHash(s); // Url hash  .3
         p^[3] := length(s);    // Url size  .4
         p^[4] := DataLen;      // DataLen   .5
         p^[5] := 0;            // NOP       .6
         pd := pointer(longword(p) + 6*4);
         ps := @s[1];
         Move(ps^,pd^,p^[3]);   // The Url   .x bytes
         pd := pointer(longword(pd) + p^[3]); // by pass url x bytes
         ps := Data;
         Move(ps^,pd^,DataLen);   // Data
         inc(aTopPos, p^[0]);   // adjust next free position
         Result := 0; //ok
      end;
   end;
end;

//------------------------------------------------------------------------------
function    BTWebSiteEmul.AddContentStr( PageUrl :string; const Data :ansistring) :longint;
begin
   if aWebRoot <> nil then
   begin
      Result := AddContent( PageUrl, @Data[1], length(Data) );
   end else Result := -1;
end;

//------------------------------------------------------------------------------
function    BTWebSiteEmul.AddContentEx( PageUrl :string; Proc :pointer; ProcParm :longword) :longint;
var p:^arr_dw;
    sz:longword;
    s:ansistring;
begin
   Result := -1; //fail
   if aWebRoot <> nil then
   begin
      s := _UrlAdjust(PageUrl);
      sz := Length(s);
      if _TestCapacity(sz) then
      begin
         p := pointer(longword(aWebRoot) + aTopPos);
         p^[0] := sz + 6*4; // Total Size  .1
         p^[1] := 2;        // Flags       .2  2= Will be generated dinamicaly
         p^[2] := FNV1aHash(s); // Url hash  .3
         p^[3] := length(s);    // Url size  .4
         p^[4] := longword(Proc);// proc     .5
         p^[5] := ProcParm;      // procparm .6
         inc(aTopPos, p^[0]);   // adjust next free position
         result := 0; //ok
      end;
   end;
end;

//------------------------------------------------------------------------------
function    BTWebSiteEmul.GetContent( PageUrl: string; var Response:ansistring ) :longint;
var p:^arr_dw;
    s,url:ansistring;
    h:longword;
    cp :longword;
    ps,pd:pointer;
    prc :GenPageProc;
begin
   Result := 100; //not found
   Response := '';
   if aWebRoot <> nil then
   begin
      cp := 0;
      s := _UrlAdjust(PageUrl);
      h := FNV1aHash(s);
      p := aWebRoot;
      repeat
         if (p^[1] and $80000000) <> 0 then // not disabled content
         begin
            if p^[2] = h then // same hash
            begin
               if p^[3] = longword(length(s)) then //same size
               begin
                  // get the url
                  SetLength(url,p^[3]);
                  ps := pointer(longword(p)+6*4);
                  pd := @Url[1];
                  Move(ps^,pd^,p^[3]);
                  if s = Url then
                  begin
                     if p^[1] = 1 then
                     begin // get content from webroot
                        SetLength(Response,p^[4]);
                        ps := pointer(longword(p)+6*4+p^[3]);
                        pd := @Response[1];
                        Move(ps^,pd^,p^[4]);
                        Result := 0;
                     end else begin
                        // Generate content dynamicaly
                        prc := GenPageProc(p^[4]);
                        Result := prc(p^[5],aQuery,Response);
                     end;
                  end;
               end;
            end;
         end;
         p := pointer(longword(p)+p^[0]);
         cp := cp + p^[0];
      until cp >= aTopPos;
   end else Result := -1;
end;

//------------------------------------------------------------------------------
function    BTWebSiteEmul._SetContent(  PageUrl: string; on_off:boolean) :longint;
var p:^arr_dw;
    s,url:ansistring;
    h:longword;
    cp :longword;
    ps,pd:pointer;
begin
   Result := 100; //not found
   if aWebRoot <> nil then
   begin
      cp := 0;
      s := _UrlAdjust(PageUrl);
      h := FNV1aHash(s);
      p := aWebRoot;
      repeat
         if p^[2] = h then // same hash
         begin
            if p^[3] = longword(length(s)) then //same size
            begin
               // get the url
               SetLength(url,p^[3]);
               ps := pointer(longword(p)+6*4);
               pd := @Url[1];
               Move(ps^,pd^,p^[3]);
               if s = Url then
               begin
                  if on_off then
                  begin
                     // enable
                     p^[1] := p^[1] and $7FFFFFFF;
                  end else begin
                     //disable
                     p^[1] := p^[1] and $80000000;
                  end;
                  Result := 0;
               end;
            end;
         end;
         p := pointer(longword(p)+p^[0]);
         cp := cp + p^[0];
      until cp >= aTopPos;
   end else Result := -1;
end;

//------------------------------------------------------------------------------
function    BTWebSiteEmul.DisableContent( PageUrl: string ):longint;
begin
   Result := _SetContent(PageUrl,false);
end;

//------------------------------------------------------------------------------
function    BTWebSiteEmul.EnableContent( PageUrl: string ):longint;
begin
   Result := _SetContent(PageUrl,true);
end;

//------------------------------------------------------------------------------
function WebPageProc(data :BTHTTP_Data; UserParm :longword) :ansistring; stdcall;
var obj:BTWebSiteEmul;
begin
   Result :='';
   if UserParm <> 0 then
   begin
      obj := BTWebSiteEmul(UserParm);
      obj.aQuery := data.Que;
      if length(data.Que) = 0 then obj.aQuery := data.Data;
      if obj.GetContent(string(data.Url),Result) < 0 then
      begin // some error
         Result := 'Content-Type:text/html; charset=utf-8'+#13#10#13#10+
         '<html><head><title>WebRoot ERROR</title></head><body>'+
         '<h2> Some Error on WebRoot Emulator Sorry :(</h2></body></html>'
      end;
   end;
end;


end.
