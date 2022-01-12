unit BTinyXML;

interface

// NOTE working only with AnsiString for 8but UTF8 format

function  TinyXML_Parse ( in_XML :AnsiString; in_Search :AnsiString; var aFlags :longint ) :AnsiString;
function  TinyXML_Parse2(const in_XML:AnsiString; const in_Search:AnsiString; var aFlags:longint ) :AnsiString;

function  XML_Document ( RootName, Value :AnsiString) :AnsiString;
function  XML_AddNode ( Name, Attribute, data :AnsiString) :AnsiString;
function  XML_DoAttribute ( Name, value :AnsiString) :AnsiString;
function  XML_DoCDATA ( value :AnsiString) :AnsiString;
function  XML_Decorate ( value :AnsiString) :AnsiString;
function  XML_UnDecorate ( value :AnsiString) :AnsiString;



implementation

// XML READER //////////////////////////////////////////////////////////////////

//------------------------------------------------------------------------------
procedure _Push(var Stack,TagName,Last_Pop:AnsiString);
var _i,_j,_f,_d:longword;
    temp:AnsiString;
begin
   // test last pop and tog for series
   _j := length(TagName);
   _f := length(Last_pop); // could have series xxx:2
   if _f >= _j then
   begin
      _d := 0;
      for _i := 1 to _j do if TagName[_i] = Last_pop[_i] then inc(_d);
      if _d = _j then // same
      begin
         if _f >_j then // allready have series
         begin
            inc(_j); // bypass ':'
            Temp := '';
            for _i := _j to _f do Temp := Temp + Last_Pop[_i];
            val(string(Temp),_i,_j);
            inc(_i);
            str(_i,Temp);
            TagName := TagName + ':' + Temp;
         end else begin
            TagName := TagName + ':2';
         end;
      end;
   end;
   Stack := Stack  + '/' +TagName;
end;

procedure _Pop(var Stack,Last_Pop:AnsiString);
var _i,_j,_f:longword;
begin
   _j := length(Stack);
   _f := 0;
   for _i := 1 to _j do if Stack[_i] = '/' then _f := _i; // get last marker
   Last_pop := '';
   if _f > 0 then
   begin
      Last_pop := Copy(Stack,_f + 1, _j - _f);
      Stack := Copy(Stack,1, _f - 1);
   end;
end;


const Preserve_namespace = $00000001;


function  TinyXML_Parse2(const in_XML:AnsiString; const in_Search:AnsiString; var aFlags:longint ) :AnsiString;
var c,opc:ansichar;
    xSize,ofs,err,mode,i,j,wrdcnt,lastpopindx,cut:longint;
    tmp,data,stack,lastpop,tag,thetag,res,path,enc:ansistring;
    Search:ansistring;
    Attr_need,series,closetag,delm,gottag,fillRes:boolean;
    Attr:ansistring;

    procedure _cutter(i:longint);
    begin
       if length(res) >= i then Res := Copy(Res,1,length(Res)-i);
    end;

    function _pusht(t:ansistring):boolean;
    var s:shortstring;
    begin
       Result := false;
       if t = lastpop then
       begin
          if lastpopindx >= 1 then
          begin
             str(lastpopindx + 1,s);
             t := t + '[' + s + ']';
          end;
       end;
       stack := stack + '/' + t;
       Path := Path + #28 + Stack + #29 + 'AAAABBBB';
       if stack = search then Result := true;
    end;

    procedure _popt(t:ansistring);
    var _i,_j,_f:longint;
        s:shortstring;
    begin
       if (not Attr_need) and GotTag and (TheTag = Stack) then
       begin
          err :=0; // found
          _cutter(cut);
       end;
       _j := length(Stack);
       _f := 0;
       for _i := 1 to _j do if Stack[_i] = '/' then _f := _i; // get last marker
       lastpop := '';
       lastpopindx := 1;
       if _f > 0 then
       begin
          lastpop := Copy(Stack,_f + 1, _j - _f);
          _j := pos('[',string(lastpop));
          if _j <> 0 then
          begin
             s := Copy(lastpop,_j+1,length(lastpop)-_j-1);
             val(string(s),lastpopindx,_i);
             lastpop := Copy(lastpop,1,_j-1);
          end;
          Stack := Copy(Stack,1, _f - 1);
       end;
       if lastpop <> t then err := -2;
    end;

    function _peek(s:AnsiString):boolean;
    var _j,_k,_t:longint;
    begin
       Result := false;
       _j := length(s);
       _t := 0;
       if (ofs + _j) <= xSize then
          for _k := 1 to _j do if in_xml[ofs + _k] = s[_k] then inc(_t);
       if _t = _j then
       begin
          if Fillres then Res := Res + s;
          inc(ofs,_j);
          Result := true;
       end;
    end;

// rules ater < no space just name fo tag
begin
   err := 100;  //not found
   Result := '';
   Res := '';
   Path := '';
   Enc := '';

   // Adjust search pattern
   tmp := '';
   Search := '';
   Attr := '';
   Attr_need := false;
   series := false;
   i := length(in_Search);
   if i < 2 then
   begin
      Exit;
   end else begin    // Adust search data
      for j:=1 to i do
      begin
         c := in_Search[j];
         // test for good chars
         //TODO
         if c = '\' then c:= '/';
         if (j = 1) and (c <> '/') then Search := '/'; //put first if not exist
         if c = '.' then
         begin
            if Attr_need then err := -1; // morw that one attr is error
            Attr_need := true;
            continue;
         end;
         if Attr_need  then Attr := Attr + c
                       else begin
                          if c = '[' then series := true; // open
                          if series then tmp := tmp + c;
                          Search := Search + c;
                          if series and (c = ']')then
                          begin
                             if tmp = '[1]' then // remove series by 1
                             begin
                                tmp := Copy(Search,1,length(Search)-3);
                                Search := tmp;
                             end;
                             tmp := '';
                             series := false;
                          end;
                       end;
      end;
   end;


   //parser
   xSize := length(in_XML);
   mode := 0;
   tmp := '';
   ofs := 0;
   delm := false;
   opc := #0;
   data := '';
   lastpop := '';
   lastpopindx := 1;
   GotTag := false;
   TheTag := '';
   FillRes := false;
   cut := 0;
   wrdcnt := 0;
   closetag := false;
   while  (ofs < xSize) and (err=100) do
   begin
      inc(ofs);
      inc(cut);
      c := in_XML[ofs];

      {
      if (mode=0) and (c = '&') then begin tmp := ''; mode := 1; end;
      if (mode=1) then
      begin
         if c = ';' then
         begin
            if tmp = '&amp'  then c := '&';
            if tmp = '&lt'   then c := '<';
            if tmp = '&gt'   then c := '>';
            if tmp = '&quot' then c := '"';
            if tmp = '&apos' then c := '''';
            if tmp = '&#39'  then c := '''';
            tmp := '';
            mode := 0;
         end else begin
            tmp := tmp + c;
            continue;
         end;
      end;
      }

      if FillRes then Res := Res + c;

      if mode = 5 then
      begin
         tmp := tmp + c;
         if (c = '?') and _peek('>') then mode := 0;
         if (c = '-') and _peek('->') then mode := 0;
         if mode = 0 then // extract encoding
         begin

            tmp := '';
         end;
         continue;
      end;

      if mode = 6 then
      begin
         if (c = ']') and _peek(']>') then
         begin
            _cutter(3);
            mode := 0;
         end;
         continue;
      end;

      if mode = 4 then
      begin
         if opc = #0 then
         begin
            if (c = '''') or (c = '"') then opc := c;
//test is not delimiter error
            continue;
         end else begin
            if c <> opc then data := data + c
                        else begin
                           Path := Path + #28 + Stack + '.' + tmp + #29 + 'AAAABBBB';
                           //BBBB = ofs   AAAA = ofs - length(data) + 1
                           if GotTag and Attr_need and (tmp = attr) then
                           begin
                              Result := data;
                              err := 0;
                           end else begin
                              data := '';
                              opc := #0;
                              mode := 2; // still in tag this is attribute
                           end;
                        end;
         end;
         continue;
      end;

      if (mode=0) and (c = '<') then
      begin
         cut := 1;
         tmp := '';
         mode := 2; // tag start
         wrdcnt := 0;
         delm := false;
         closetag := false;
         continue; //next char is the tag name no space by rule
      end;
      if (mode=2) then
      begin //TAG name read - open
         if c = '?' then mode := 5;// encoding <? .... ?>
         if (c = '!') then
         begin
            if _peek('--') then mode := 5; //comment  <!-- .... -->
            if _peek('[CDATA[') then
            begin
               _cutter(9);
               mode := 6; //cdata   <![CDATA[ .... ]]>
            end;
         end;

         if c = '/' then //closing tag is opening
         begin
            if _peek('>') then // force close of open tag
            begin
               _popt(tag);
               mode := 0;
            end else begin
               closetag := true;
            end;
            continue;
         end;


         if (not closetag) and (c = '=') then // attribute
         begin
            mode := 4;
            continue;
         end;

         //acumulate tag name
         if (c = ' ') or (c = #13) or (c = #10) or (c = #9) or (c = '>') then
         begin
            if wrdcnt = 0 then
            begin
               tag := tmp;
               if closetag then _popt(tag)
                           else if _pusht(tag)then
                                begin
                                   GotTag := true;
                                   TheTag := Stack;
                                end;
            end;
            inc(wrdcnt);
            delm := true;
            if c <> '>' then continue;
         end;
         if ((aFlags and preserve_namespace) = 0) and (c = ':') then
         begin
            tmp := ''; // ignore name space
            continue;
         end;
         if delm then
         begin
            tmp := '';
            delm := false;
         end;
         if c = '>' then
         begin
            if GotTag then FillRes := true;
            mode := 0;
         end;
         tmp := tmp + c;
         continue;
      end;
   end;

 //  if length(stack) <> 0  then err := -3;
   if err = 0 then Result := Res;
   if aFlags = 2 then Result := Path;
   if (aFlags and 4) <> 0 then Result := XML_UnDecorate(Result);


   aFlags := err;
end;


//------------------------------------------------------------------------------
function  TinyXML_Parse(in_XML:AnsiString; in_Search:AnsiString; var aFlags:longint ) :AnsiString;
var
    i,j,m:longword;
    intag:longword;
    bSize:longword;
    c,last_c,first_c,last_read:AnsiChar;
    err:longint;
    Tag:Ansistring;
    TagName:Ansistring;
    tag_space:longword;
    Stack:AnsiString;
    Temp:AnsiString;
    pusher:longword;
    Attr_need :boolean;
    Attr:AnsiString;
    Search:AnsiString;
    done:longword;
    attr_read:longword;
    Last_pop:AnsiString;
    Acumolator:longword;
    FillOn:longint;
    cdata:longword;
    newtag:AnsiString;
    Data:AnsiString;

    function _peek(s:AnsiString):boolean;
    var _j,_k,_t:longword;
    begin
       Result := false;
       _j := length(s);
       _t := 0;
       if (i + _j) <= bSize then
          for _k := 1 to _j do if in_xml[i + _k ] = s[_k] then inc(_t);
       if _t = _j then Result := true;
    end;

begin
   // Inits
   Result := '';
   Acumolator := 0;
   Last_pop := '';
   Stack := '';
   Tag := '';
   tag_space := 0;
   TagName := '';
   Data := '';
   first_c := #0;
   last_c := #0;
   Attr_need := false;
   Search := '';
   done := 0;
   Attr := ' '; //one space before attribute
   attr_read := 0;
   FillOn := 0;
   cdata := 0;
   newtag := '';
   last_read := #0;

   Result := '';
   if in_XML = '' then Exit;
   bSize := length(in_XML);

   i := length(in_Search);
   if i < 2 then
   begin
      Exit;
   end else begin    // Adust search data
      for j:=1 to i do
      begin
         c := in_Search[j];
         if c = '\' then c:= '/';
         if (j = 1) and (c <> '/') then Search := '/'; //put first if not exist
         if c = '.' then begin Attr_need := true; continue; end;
         if Attr_need  then Attr := Attr + c
                       else Search := Search + c;
      end;
   end;

   //Begin parsing ----------------------------------------
   // note the data must be in 8bit utf-8 format
   intag := 0;
   i := 0; // to bypass first inc
   err := 0;
   while  (i < bSize) and (err=0) do
   begin
      inc(i);
      c := in_XML[i];
      (*
      if cdata = 0 then
      begin
         if Acumolator = 1 then
         begin
         Temp := Temp + c;
         if c = ';' then Acumolator := 0;
            if Temp = '&amp;'  then c := '&';
            if Temp = '&lt;'   then c := '<';
            if Temp = '&gt;'   then c := '>';
            if Temp = '&quot;' then c := '"';
            if Temp = '&apos;' then c := '''';
            if Temp = '&#39;'  then c := '''';
         end;
         if c = '&' then begin Acumolator := 1; Temp := '&'; end;
         if Acumolator = 1 then continue;
      end;
      *)
      // clear blanks
      if (last_read = '>') and (i < bSize) then
      begin
         j := 1;
         m := i;
         while  (m < bSize)  do
         begin
            last_read := in_XML[m];
            if last_read = '<' then break;
            if not (last_read in [#13,#10,' ']) then begin j := 0; break; end;
            inc(m);
         end;
         if j = 1 then
         begin
            i := m - 1;
            continue;
         end;
      end;

      if cdata > 0 then
      begin    // copy data without parsing
         if (FillOn > 0) and (not Attr_Need) then begin Data := Data + c; FillOn := 2; end;
         if  c = ']' then if _Peek(']>') then cdata := 2;
         if cdata < 5 then dec(cdata);
         continue;
      end;

      if c = '<' then  // Begin tag;
      begin
         newtag := '';
         if intag = 0 then intag := 1
                      else err := -3;
         cdata := 0;
         if _peek('![CDATA[') then cdata := 5;
         Tag := '';
         tag_space := 0;
         TagName := '';
         First_c := #0;
         if FillOn = 0 then continue
                       else First_c := #1;
      end; // begin tag end

      if c = '>' then  // End tag;
      begin
         if intag = 1 then intag := 0
                      else err := -4;
         pusher := 1;
         if first_c = '!' then pusher := 0; // comment
         if first_c = '?' then pusher := 0; // coding
         if first_c = '/' then // end tag
         begin
            // get data if need
            if Stack = Search then
            begin
               // scip from result acumolated new tag
               j := length(newtag);
               Data := Copy(Data,1,longword(length(Data)) - j);
               done := 1;
               break;
            end;
            // Data := ''; // close tag clear for next load
            _Pop(Stack,Last_Pop);;
         end else begin
            if pusher = 1 then
            begin
               _Push(Stack,TagName,Last_Pop);
               // Get attribute data if need
               if (Stack = Search) then
               begin
                  last_read := '>';
                  FillOn := 1;
                  if Attr_need then
                  begin
                     done := 1;
                     break;
                  end;
               end;
               if last_c = '/' then _Pop(Stack,Last_Pop); // one tag no data
            end;
         end;
         if FillOn < 2 then continue;
      end;  // end tag end

      //proceed tag and data
      if intag = 1 then
      begin
         // get tag name and acumulate tag data
         if first_c = #0 then first_c := c;
         if first_c <> #1 then
         begin
         last_c := c;
         Tag := Tag + c;
         if c = #32 then
         begin
           tag_space := 1;
           Temp := '';  //One space
         end;
         if tag_space = 0 then
         begin
            if c = ':' then TagName := '' // if name space then clear
                       else TagName := TagName + c;
         end;
         end;
         if first_c = #1 then first_c := #0;
         if attr_need then
         begin
            Temp := Temp + c;
            if (Temp = Attr) and (Attr_read = 0) then Attr_read := 1;
         end;
         if (c = '"') and (attr_read = 3) then attr_read := 4;
         if attr_read = 3 then  Data := Data + c;
         if (c = '=') and (attr_read = 1) then attr_read := 2;
         if (c = '"') and (attr_read = 2) then attr_read := 3;
         newtag := newtag + c;
      end;

      last_read := c;

      if (FillOn > 0) and (not Attr_Need) then
      begin
         if cdata = 0 then
         begin
            if Acumolator = 1 then
            begin
            Temp := Temp + c;
            if c = ';' then Acumolator := 0;
               if Temp = '&amp;'  then c := '&';
               if Temp = '&lt;'   then c := '<';
               if Temp = '&gt;'   then c := '>';
               if Temp = '&quot;' then c := '"';
               if Temp = '&apos;' then c := '''';
               if Temp = '&#39;'  then c := '''';
            end;
            if c = '&' then begin Acumolator := 1; Temp := '&'; end;
            if Acumolator = 1 then continue;
         end;

         Data := Data + c;
         FillOn := 2;
      end;

   end; // main loop

   if err <> 0 then aFlags := err;
   if done = 1 then
   begin
      if Pos('<![CDATA[',string(Data)) = 1 then // begin with cdata
      begin
         Result := Copy(Data,10,longword(length(Data)) - 12);
      end else begin
         Result := data;
      end;
   end;
end;




// XML WRITER //////////////////////////////////////////////////////////////////

//------------------------------------------------------------------------------
function XML_DoAttribute(Name,value:AnsiString):AnsiString;
begin
   Result := ' ' + Name + '="'+ value +'"';
end;

//------------------------------------------------------------------------------
function XML_AddNode(Name,Attribute,data:AnsiString):AnsiString;
begin
   if data = '' then
   begin
      Result := '<'+Name+Attribute+'/>';
   end else begin
      Result := '<'+Name+Attribute+'>'+data+'</'+Name+'>';
   end;
end;

//------------------------------------------------------------------------------
function XML_DoCDATA(value:AnsiString):AnsiString;
begin
   Result := '<![CDATA['+value+']]>';
end;

//------------------------------------------------------------------------------
function XML_Document(RootName,Value:AnsiString):AnsiString;
begin
   Result := '<?xml version="1.0" encoding="UTF-8"?><'+Rootname+'>'+value+'</'+RootName+'>';
end;

//------------------------------------------------------------------------------
function  XML_Decorate ( value :AnsiString) :AnsiString;
var i,k:longword;
    c:ansichar;
begin
   Result := '';
   i := Length(value);
   for k:= 1 to i do
   begin
      c := value[k];
      if c = #9 then continue;
      if c = #13 then continue;
      if c = #10 then continue;
      if c = '<' then begin Result := Result + '&lt;'; continue; end;
      if c = '>' then begin Result := Result + '&gt;'; continue; end;
      Result := Result + c;
   end;
end;

//------------------------------------------------------------------------------
function  XML_UnDecorate ( value :AnsiString) :AnsiString;
var i,k,Acumolator:longword;
    c:ansichar;
    Temp,s:AnsiString;
    ii,ii2:integer;
begin
   Result := '';
   Temp:='';
   i := Length(value);
   Acumolator := 0;
   for k:= 1 to i do
   begin
      c := value[k];
      if Acumolator = 1 then
      begin
         Temp := Temp + c;
         if c = ';' then Acumolator := 0;
         if Temp = '&amp;'  then c := '&';
         if Temp = '&lt;'   then c := '<';
         if Temp = '&gt;'   then c := '>';
         if Temp = '&quot;' then c := '"';
         if Temp = '&apos;' then c := '''';
         if (Acumolator = 0) and (length(temp) > 3) and (Temp[1]='&') and (Temp[2]='#') then // &# Dec val ;
         begin
            s := Copy(Temp,3,length(Temp)-3);
            val(string(s),ii,ii2);
            if ii = 0 then ii:=32;
            c := ansichar(ii);
         end;
         if (Acumolator = 0) and (length(temp) > 4) and (Temp[1]='&') and (Temp[2]='#') and (Temp[3]='x')then // &#x HEXval ;
         begin
            s := Copy(Temp,4,length(Temp)-4);
            //TODO
         end;
      end;
      if c = '&' then begin Acumolator := 1; Temp := '&'; end;
      if Acumolator = 1 then continue;
      Result := Result + c;
   end;
end;

end.
