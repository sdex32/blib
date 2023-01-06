unit BHTMLgenerator;
{
  todo
     utf8encode to  unicode2utf8 my lib
     shape is bad in not absolute mode
     table
     java script   ajax
}
interface

type  BTHTML_Element = record
         hash        : longword;
         id          : string[16]; //objectname
         Xpos, Ypos  : longint;
         Xlng, ylng  : longint;
         FillColor   : longword;
         txt         : longword;
         txt_len     : longword;
         BorderStyle : longword;
         BorderColor : longword;
         BorderWidth : longword;
         Style       : longword;
         typ         : longword;
         align       : longword;
         Color       : longword;
         FormFont    : string[128];
         reserved    : longword;
         AutoScroll  : longword;
         Parent      : longword;
         AbsMode     : boolean;

      end;
      BTHTML_Elements = array[0..0] of BTHTML_Element;
      PBTHTML_Elements = ^BTHTML_Elements;

      BTHTML_Doc = class
       private
         aList       : PBTHTML_Elements;
         aCount      : longword;
         aCapacity   : longword;
         aError      : longint;
         aFormElements : longword;
         aFontsDef   : string;
         aDefaultFnt : string;
         aStringPool : string;
         aForms      : boolean;
         aAJAX       : boolean;
         aScript     : string;
         aSID        : string; //session ID
         aAbsoluteMode : boolean;
         aTitle      : string;
         aPageBackCl : longword;
         aPageEnc    : string;
         aPagePic    : string;
         aPagePicF   : longword;
         aFntDef     : longword;
         outputs     : ansistring;
         procedure   _WriteExpLn(s:string);
         procedure   _GrowList;
         procedure   _Reset;
         function    _InsertDefault(name:string; x,y,w,h:longint):longword;
         function    _GetNew:longword;
         procedure   _GenObject(papa:longword );
         procedure   _AddStrPool(pid:longword; var s:string);

       public
         property    Text:AnsiString read outputs;
         property    AbsoluteMode:boolean read aAbsoluteMode write aAbsoluteMode;
         Constructor Create;
         Destructor  Destroy; override;
         function    Generate:pchar;
         function    SaveToFile(fname:string):longint;

         function    CreateTextFont(name:string; size,color:longword; bold,italic:boolean):string;

         procedure   BeginPage(name:string; BackColor:longword; BackPicName:string; BackPicFlags,SessionID:longword; script:string);

         function    AddRectangle(name:string; x,y,w,h:longint) :longword;
         function    AddText(name:string; x,y,w,h:longint; deffnt,txt:string) :longword;
         function    AddPicture(name:string; x,y,w,h:longint; filename,relpath:string) :longword;
         function    AddButton(name:string; x,y,w,h:longint; caption,script:string) :longword;
         function    AddPictureButton(name:string; x,y,w,h:longint; filename,relpath,script:string) :longword;
         function    AddEditBox(name:string; x,y,w,h:longint; txt,script:string; pwd:boolean) :longword;
         function    AddCheckBox(name:string; x,y,w,h:longint; txt,script:string; radio:boolean) :longword;
         function    AddTextBox(name:string; x,y,w,h:longint; txt,script:string; Scroll:boolean) :longword;
         function    AddFileUpload(name:string; x,y,w,h:longint; script:string) :longword;
         function    AddComboBox(name:string; x,y,w,h:longint; txt,script:string;  ListBoxElCnt,Selected :longword) :longword;
         function    AddTable(name:string; x,y,w,h:longint; txt,script:string) :longword;


         procedure   SetFillColor(hand:longword; col:longword);
         procedure   SetColor(hand:longword; col:longword);
         procedure   SetBorder(hand:longword; col,st,wdth:longword);
         procedure   SetPos(hand:longword; x,y:longint);
         procedure   SetSize(hand:longword; w,h:longint);
         procedure   SetAlign(hand:longword; a:longword);
         procedure   SetCenter(hand:longword; on_off:boolean);
         procedure   SetFont(hand:longword; Fname:string; fsize,fbold,fitalic,funderline:longword);
         procedure   SetInsideParent(hand:longword; parent_hand:longword);
         function    GetByName(name:string) :longword;


         function    Scripter(meta_txt:string):string;



//AddHiperlink
//AddTable important
//Export
//Import
//GetValue

//TODO   scripter
//       FileUpload


      end;

      BTHTML_TableBuilder = class
       private
         aTable :string;
         aTableWidth :longword;
         aTableHeight :longword;
       public
         Constructor Create;
         Destructor  Destroy; override;
         property GetTable :string read aTable;
         property GetWidth :longword read aTableWidth;
         property GetHeight :longword read aTableHeight;
      end;


(*
---AJAX---example---
<!DOCTYPE html>
<html>
<head>
<script>
function loadXMLDoc(url)
{
var xmlhttp;
var txt,x,xx,i;
if (window.XMLHttpRequest)
  {// code for IE7+, Firefox, Chrome, Opera, Safari
  xmlhttp=new XMLHttpRequest();
  }
else
  {// code for IE6, IE5
  xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
  }
xmlhttp.onreadystatechange=function()
  {
  if (xmlhttp.readyState==4 && xmlhttp.status==200)
    {
    txt="<table border='1'><tr><th>Title</th><th>Artist</th></tr>";
    //variant 2  txt=xmlhttp.responseText
    x=xmlhttp.responseXML.documentElement.getElementsByTagName("CD");
    for (i=0;i<x.length;i++)
      {
      txt=txt + "<tr>";
      xx=x[i].getElementsByTagName("TITLE");
        {
        try
          {
          txt=txt + "<td>" + xx[0].firstChild.nodeValue + "</td>";
          }
        catch (er)
          {
          txt=txt + "<td> </td>";
          }
        }
      xx=x[i].getElementsByTagName("ARTIST");
        {
        try
          {
          txt=txt + "<td>" + xx[0].firstChild.nodeValue + "</td>";
          }
        catch (er)
          {
          txt=txt + "<td> </td>";
          }
        }
      txt=txt + "</tr>";
      }
    txt=txt + "</table>";
    document.getElementById('txtCDInfo').innerHTML=txt;
    }
  }
xmlhttp.open("GET",url,true);
xmlhttp.send();
}
</script>
</head>
<body>

<div id="txtCDInfo">
<button onclick="loadXMLDoc('cd_catalog.xml')">Get CD info</button>
</div>

</body>
</html>
*)


function HTML_TableBuilder():string;

implementation

uses BStrTools, Windows, BBase64, BFileTools;


Constructor BTHTML_TableBuilder.Create;
begin
   aTableWidth := 300;
   aTableHeight := 120;
   aTable := '<table>Hallo</table>';
end;

Destructor  BTHTML_TableBuilder.Destroy;
begin

   inherited;
end;





//------------------------------------------------------------------------------
Constructor BTHTML_Doc.Create;
begin
   aList := nil;
   aCapacity := 0;
   _Reset;
   _GrowList;
end;

//------------------------------------------------------------------------------
Destructor  BTHTML_Doc.Destroy;
begin


  inherited;
end;

//------------------------------------------------------------------------------
procedure BTHTML_Doc._Reset;
begin
   aError := 0;
   aCount := 0;
   aTitle := 'Untitled';
   aPageBackCl := $FFFFFF;
   aPageEnc := 'utf-8';
   aPagePicF := 0;
   aFormElements := 0;
   aFontsDef := '';
   aFntDef := 0;
   aDefaultFnt := CreateTextFont('Arial',13,0,false,false);  // btfnt1
   outputs := '';
   aStringPool := '';
   aForms := false;
   aAJAX := true; //false;
   aScript := '';
   aAbsoluteMode := true; //true;
   Randomize;
end;

//------------------------------------------------------------------------------
procedure BTHTML_Doc._GrowList;
begin
   aError := 0;
   aCapacity := aCapacity + 64;
   ReallocMem(aList, aCapacity * SizeOf(BTHTML_Element));
   if aList = nil then aError := -2;
end;

//------------------------------------------------------------------------------
function  CalcHash(s:string):longword;
var i:integer;
const  //FNV-1a hash
    FNV_offset_basis = 2166136261;
    FNV_prime = 16777619;
begin
   result := FNV_offset_basis;
   for i := 1 to length(s) do
      result := (result xor byte(s[i])) * FNV_prime;
end;

//------------------------------------------------------------------------------
function  BTHTML_Doc.GetByName(name:string):longword;
var i,l:longword;
begin
   Result := 0;
   l := CalcHash(name);
   if aCount > 0  then
   begin
      for i:= 1  to aCount  do
      begin
         if aList[i].hash = l then
         begin
            if string(aList[i].id) = name then
            begin
               Result := i;
               Break;
            end;
         end;
      end;
   end;
end;

//------------------------------------------------------------------------------
function _swapcolor(col:longword):longword;
begin
   Result := (col and $FF00FF00) or ((col and $FF )shl 16) or ((col and $FF0000)shr 16);
end;

procedure BTHTML_Doc.BeginPage(name:string; BackColor:longword; BackPicName:string; BackPicFlags,SessionID:longword; script:string);
begin
   _Reset;
   aTitle := name;
   aPageBackCl := _swapcolor(BackColor);
   aPageEnc := 'utf-8';
   aPagePic := BackPicName;
   aPagePicF := BackPicFlags;
   if SessionID = 0 then aSID := ToHex(random($FFFF),4) + ToHex(random($FFFF),4)
                    else aSID := ToHex(SessionID,8);
end;

//------------------------------------------------------------------------------
function  BTHTML_Doc._GetNew:longword;
begin
   inc(aCount);
   if aCount > aCapacity then _GrowList;
   Result := aCount; // start from 1
end;

//------------------------------------------------------------------------------
function  BTHTML_Doc._InsertDefault(name:string; x,y,w,h:longint):longword;
var pid:longword;
begin
   pid := _GetNew;
   Result := 0;
   if aError <> 0 then Exit;
   Result := pid;

   aList[pid].hash := CalcHash(name);
   aList[pid].id := ShortString(name);
   aList[pid].typ := 0;
   aList[pid].Xpos := x;
   aList[pid].Ypos := y;
   aList[pid].Xlng := w;
   aList[pid].Ylng := h;
   aList[pid].FillColor := $FF000000; //rgb(128,128,128);
   aList[pid].BorderStyle := 0;
   aList[pid].BorderColor := 0;
   aList[pid].BorderWidth := 1;
   aList[pid].Style := 0;
   aList[pid].txt := 0;
   aList[pid].txt_len := 0;
   aList[pid].Align := 0; // left;
   aList[pid].Color := $FF000000;
   aList[pid].FormFont := 'font-family:Arial; font-size:14px;';
   aList[pid].reserved := 0;
   aList[pid].AutoScroll := 0;
   aList[pid].Parent := 0;
   aList[pid].AbsMode := AbsoluteMode;
end;

//------------------------------------------------------------------------------
function    BTHTML_Doc.AddRectangle(name:string; x,y,w,h:longint) :longword;
begin
   Result := 0;
   if aList = nil then Exit;
   Result := _InsertDefault(name,x,y,w,h);
   aList[Result].FillColor := $00E0E0E0;  // gray
   aList[Result].Color := 0;
end;

//------------------------------------------------------------------------------
procedure  _AdjustRelPath(var relpath:string);
var l:longword;
    c:char;
begin
   l := length(relpath);
   if l> 0 then
   begin
      c := relpath[l];
      if (c <> '\') or (c <> '/') then relpath := relpath + '/';
   end;
end;

//------------------------------------------------------------------------------
function  BTHTML_Doc.AddPicture(name:string; x,y,w,h:longint; filename,relpath:string) :longword;
var fn,s:string;
    pid:longint;
    d:ansiString;
begin
   // get picture name only;
   Result := 0;
   if aList = nil then Exit;
   fn := '';

   if relpath = 'base64' then  // input image inside the html
   begin                       // not working for all browsers
      relpath := 'data:image/'+ ExtractFileExt(filename) + ';base64,';
      FileLoad(FileName,d);
      relpath := relpath + BCodeBase64(d);
   end else begin
      fn := ExtractFile(filename);
      _AdjustrelPath(relpath);
   end;

//   s := 'src="'+relpath+fn+'" border=0 width='+ToStr(w)+' height='+ToStr(h);
   s := 'src="'+relpath+fn+'" width='+ToStr(w)+' height='+ToStr(h);

   pid := _InsertDefault(name,x,y,w,h);
   if aError <> 0  then Exit;

   _AddStrPool(pid,s);
   aList[pid].typ := 2;

   Result := pid;
end;

//------------------------------------------------------------------------------
procedure BTHTML_Doc._AddStrPool(pid:longword; var s:string);
var i:longword;
begin
   i := Length(aStringPool)+ 1;
   aStringPool := aStringPool + s;
   aList[pid].txt := i;
   aList[pid].txt_len := length(s);
end;

//------------------------------------------------------------------------------
function BTHTML_Doc.AddText(name:string; x,y,w,h:longint; deffnt,txt:string) :longword;
var pid:longword;
    i,l,SC,m:longint;
    s,s1,s2:string;
    fB,fI,fU,SP,NP:boolean;

   procedure AdderEvent;
   var f:longint;
   begin
      if i > l then Exit;
      if txt[i] = '~' then
      begin
         s := s + '~';     //DOUBLE ~~ = ~
         Exit;
      end;
      if txt[i] = 'N' then
      begin
         s := s + '<br>';  // new line
         Exit;
      end;
      if txt[i] = 'P' then
      begin
         NP := true; // ne paragraph
         inc(i);
         Exit;
      end;


      // before new event close all opan events
      if fU then s := s + '</u>';
      if fI then s := s + '</i>';
      if fB then s := s + '</b>';

      //analyze event
      SP := false;
      s1 := '';
      if txt[i] = 'C' then begin //color  format: RRGGBB (hex)
                              if i + 6 <= l then
                              begin
                                 s2 := '000000';
                                 for f := 1 to 6 do s2[f] := txt[i+f];
                                 SP := true;
                                 s1 := s1 + ' style="color:#'+s2+';"';
                                 inc(i,6);
                              end;
                           end;
      if txt[i] = 'S' then begin //size  format: XXXpx (dec) end with px
                              s2 := '';
                              f := 1;
                              while ((f+i)<=l) do
                              begin
                                 s2 := s2 + txt[f+i];
                                 if txt[f+i] = 'x' then break;
                                 inc(f);
                              end;
                              if f > 1 then
                              begin
                                 if (txt[f+i] = 'x') and (txt[f+i-1] = 'p') then
                                 begin
                                    inc(i,f);
                                    SP := true;
                                    s1 := s1 + ' style="font-size:'+s2+';"';
                                 end;
                              end;
                           end;
      if txt[i] = 'F' then begin //font  format: name.  dot in the end
                              s2 := '';
                              f := 1;
                              while ((f+i)<=l) do
                              begin
                                 if txt[f+i] = '.' then break;
                                 s2 := s2 + txt[f+i];
                                 inc(f);
                              end;
                              if f > 1 then
                              begin
                                 if txt[f+i] = '.' then
                                 begin
                                    inc(i,f);
                                    SP := true;
                                    if s2 = 'def' then s2 := 'btfnt1';
                                    s1 := s1 + ' class="'+s2+'"';
                                 end;
                              end;
                           end;


      if txt[i] = 'B' then if not fB then fB := true;
      if txt[i] = 'b' then if fB then fB := false;

      if txt[i] = 'I' then if not fI then fI := true;
      if txt[i] = 'i' then if fI then fI := false;

      if txt[i] = 'U' then if not fU then fU := true;
      if txt[i] = 'u' then if fU then fU := false;

      if txt[i] = 'R' then // reset
      begin
         fB := false;
         fI := false;
         fU := false;
      end;

      //restore existing events and add new
      s2 := '';

      if fB then s2 := s2 + '<b>';
      if fI then s2 := s2 + '<i>';
      if fU then s2 := s2 + '<u>';

      if SP then
      begin
         s1 := '<span'+s1+'>';
         inc(SC); // span count
      end;
      s := s + s1 + s2;
   end;

begin
   Result := 0;
   if aList = nil then Exit;
   pid := _InsertDefault(name,x,y,w,h);
   aList[pid].FillColor := $FF000000;  // transparent
   if deffnt = '' then deffnt := 'btfnt1';
   i := 1;

   s := '&nbsp;';
   l := length(txt);
   if l > 0 then
   begin
      s := '';

      repeat
         fB := false;
         fI := false;
         fU := false;
         SP := false;
         SC := 0;
         NP := false;

         s := s + '<p class="'+deffnt+'">';
         while i <= l do
         begin
            if txt[i] = '~' then   // new event
            begin
               inc(i); //Bypass this
               AdderEvent;
               if NP then break;
            end else begin
               s := s + txt[i];
            end;
            inc(i);
         end;
         if fU then s := s + '</u>';
         if fI then s := s + '</i>';
         if fB then s := s + '</b>';

         if SC > 0 then
         begin
            for m := 1 to SC do s := s + '</span>';
         end;
         s := s + '</p>';
      until i > l;
   end;
   _AddStrPool(pid,s);
   aList[pid].typ := 1;
   Result := pid;
end;

//------------------------------------------------------------------------------
function  BTHTML_Doc.CreateTextFont(name:string; size,color:longword; bold,italic:boolean):string;
var s:string;
begin
   inc(aFntDef);
   Result := 'btfnt'+ToStr(aFntDef);
   s := '.'+Result+' { font: ';        //css set font by one pass
   if italic then s := s + 'italic ';
   if bold then s := s + 'bold ';
   s := s + toStr(size)+'px/'+tostr(size*2)+'px "'+name+'" , sarif; color: '+ToHex(_swapcolor(color),6)+'}'+#13#10;
   aFontsDef := aFontsDef + s;
end;

//------------------------------------------------------------------------------
procedure BTHTML_Doc.SetInsideParent(hand:longword; parent_hand:longword);
begin
   if (parent_hand = 0) or (parent_hand > aCount) then Exit;
   if (hand = 0) or (hand > aCount) then Exit;
   aList[hand].Parent := parent_hand;
//   aList[parent_hand].HaveChild := true;
end;

//------------------------------------------------------------------------------
procedure BTHTML_Doc.SetPos(hand:longword; x,y:longint);
begin
   if (hand = 0) or (hand > aCount) then Exit;
   aList[hand].Xpos := x;
   aList[hand].Ypos := y;
end;

//------------------------------------------------------------------------------
procedure BTHTML_Doc.SetSize(hand:longword; w,h:longint);
begin
   if (hand = 0) or (hand > aCount) then Exit;
   aList[hand].Xlng := w;
   aList[hand].Ylng := h;
end;

//------------------------------------------------------------------------------
procedure BTHTML_Doc.SetCenter(hand:longword; on_off:boolean);
begin
   if (hand = 0) or (hand > aCount) then Exit;
//   aList[hand].Center := on_off;
end;

//------------------------------------------------------------------------------
procedure BTHTML_Doc.SetAlign(hand:longword; a:longword);
begin
   if (hand = 0) or (hand > aCount) then Exit;
   aList[hand].align := a;
end;

//------------------------------------------------------------------------------
procedure   BTHTML_Doc.SetFillColor(hand:longword; col:longword);
begin
   if (hand = 0) or (hand > aCount) then Exit;
   aList[hand].FillColor := _swapcolor(col);
end;

//------------------------------------------------------------------------------
procedure   BTHTML_Doc.SetColor(hand:longword; col:longword);
begin
   if (hand = 0) or (hand > aCount) then Exit;
   aList[hand].Color := _swapcolor(col);
end;

//------------------------------------------------------------------------------
procedure BTHTML_Doc.SetBorder(hand:longword; col,st,wdth:longword);
begin
   if (hand = 0) or (hand > aCount) then Exit;
   aList[hand].BorderStyle := st;
   aList[hand].BorderColor := _swapcolor(Col);
   aList[hand].BorderWidth := wdth;
end;

//------------------------------------------------------------------------------
procedure BTHTML_Doc.SetFont(hand:longword; Fname:string; fsize,fbold,fitalic,funderline:longword);
begin
   if (hand = 0) or (hand > aCount) then Exit;
   aList[hand].FormFont := 'font-family:'+ShortString(fname)+'; font-size:'+tostr(fsize)+'px;';
   if fbold = 1 then aList[hand].FormFont := aList[hand].FormFont + ' font-weight:bold;';
   if fitalic = 1 then aList[hand].FormFont := aList[hand].FormFont + ' font-style:italic;';
end;

//------------------------------------------------------------------------------
function   BTHTML_Doc.AddButton(name:string; x,y,w,h:longint; caption,script:string) :longword;
var pid:longword;
begin
   Result := 0;
   if aList = nil then Exit;
   pid := _InsertDefault(name,x,y,w,h);
   if aError <> 0  then Exit;
   aList[pid].typ :=  $F00 + 1;  // button
   aList[pid].align := 1; // center;
   _AddStrPool(pid,caption);
   aScript  := aScript + 'function '+name+'_onclk()'+#13#10+'{ var id="'+name+'"; '+script + ' }'+#13#10;
   aForms := true;
   Result := pid;
end;

//------------------------------------------------------------------------------
function   BTHTML_Doc.AddPictureButton(name:string; x,y,w,h:longint; filename,relpath,script:string) :longword;
var pid:longword;
begin
   Result :=0;
   if aList = nil then Exit;
   pid := _InsertDefault(name,x,y,w,h);
   if aError <> 0  then Exit;
   aList[pid].typ :=  $F00 + 2;  // picture button

   _AdjustrelPath(relpath);
   //todo
   relpath  := relpath +  ExtractFile(filename);

   _AddStrPool(pid,relpath);
   aScript  := aScript + 'function '+name+'_onclk()'+#13#10+'{ var id="'+name+'"; '+script + ' }'+#13#10;
   aForms := true;
   Result := pid;
end;

//------------------------------------------------------------------------------
function   BTHTML_Doc.AddEditBox(name:string; x,y,w,h:longint; txt,script:string; pwd :boolean) :longword;
var pid:longword;
begin
   Result := 0;
   if aList = nil then Exit;
   pid := _InsertDefault(name,x,y,w,h);
   if aError <> 0  then Exit;
   if not pwd then  aList[pid].typ :=  $F00 + 3  // editbox
              else  aList[pid].typ :=  $F00 + 7; // pwd

   aList[pid].BorderStyle := 1;
   _AddStrPool(pid,txt);
   aScript  := aScript + 'function '+name+'_onchg()'+#13#10+'{ var id="'+name+'"; '+script + ' }'+#13#10;
   aForms := true;
   Result := pid;
end;

//------------------------------------------------------------------------------
function   BTHTML_Doc.AddCheckBox(name:string; x,y,w,h:longint; txt,script:string; radio:boolean) :longword;
var pid:longword;
begin
   //NOTE   if txt = 'on' then checked at the begining
   Result := 0;
   if aList = nil then Exit;
   pid := _InsertDefault(name,x,y,w,h);
   if aError <> 0  then Exit;
   aList[pid].typ :=  $F00 + 4;  // checkbox
   aList[pid].BorderStyle := 0;
   if radio then aList[pid].Reserved := 1;
   _AddStrPool(pid,txt);
   aScript  := aScript + 'function '+name+'_onchg()'+#13#10+'{ var id="'+name+'"; '+script + ' }'+#13#10;
   aForms := true;
   Result := pid;
end;

//------------------------------------------------------------------------------
function   BTHTML_Doc.AddTextBox(name:string; x,y,w,h:longint; txt,script:string; Scroll:boolean) :longword;
var pid:longword;
begin
   Result := 0;
   if aList = nil then Exit;
   pid := _InsertDefault(name,x,y,w,h);
   if aError <> 0  then Exit;
   aList[pid].typ :=  $F00 + 5;  // text
   if Scroll then aList[pid].AutoScroll := 1;

   _AddStrPool(pid,txt);
   aScript  := aScript + 'function '+name+'_onclk()'+#13#10+'{ var id="'+name+'"; '+script + ' }'+#13#10;
   aForms := true;
   Result := pid;
end;

//------------------------------------------------------------------------------
function   BTHTML_Doc.AddFileUpload(name:string; x,y,w,h:longint; script:string) :longword;
var pid:longword;
begin
   Result := 0;
   if aList = nil then Exit;
   pid := _InsertDefault(name,x,y,w,h);
   if aError <> 0  then Exit;
   aList[pid].typ :=  $F00 + 6;  // file upload
//   _AddStrPool(pid,txt);
   aScript  := aScript + 'function '+name+'_onclk()'+#13#10+'{ var id="'+name+'"; '+script + ' }'+#13#10;
   aForms := true;
   Result := pid;
end;

//------------------------------------------------------------------------------
function   BTHTML_Doc.AddComboBox(name:string; x,y,w,h:longint; txt,script:string; ListBoxElCnt,Selected :longword) :longword;
var pid,i,j,m,el:longword;
    s:string;
    itm,v:string;
    c:char;
begin
   Result := 0;
   if aList = nil then Exit;
   pid := _InsertDefault(name,x,y,w,h);
   if aError <> 0  then Exit;
   aList[pid].typ := 3;  // Combo Box
   aList[pid].reserved := 1;               // if ListBoxElCnt = 0 then Brop Down List Box
   if ListBoxElCnt  > 1 then aList[pid].reserved := ListBoxElCnt; // list box size of element more that 1
   j := length(txt);
   m := 0;
   itm := '';
   v := '';
   s := '';
   for i :=1 to j do
   begin
      c := txt[i];
      if c = '|' then
      begin
         inc(m);
         if m = 2 then
         begin
            el := ToVal(v);
            s := s + '<option value="'+v+'"';
            if Selected = el then s := s + ' selected="true"';
            s := s + '>'+itm+'</option>'+#13#10;
            itm := '';
            v := '';
            m := 0;
         end;
      end else begin
         if m = 0 then itm := itm + c;
         if m = 1 then v := v + c;
      end;
   end;
   _AddStrPool(pid,s);
   aScript  := aScript + 'function '+name+'_onchg()'+#13#10+'{ var id="'+name+'"; '+script + ' }'+#13#10;
   aForms := true;
   Result := pid;
end;


function   BTHTML_Doc.AddTable(name:string; x,y,w,h:longint; txt,script:string) :longword;
var pid:longword;
begin
   Result := 0;
   if aList = nil then Exit;
   pid := _InsertDefault(name,x,y,w,h);
   if aError <> 0  then Exit;
   aList[pid].typ :=  4;
   aList[pid].BorderStyle := 1; // have border
   _AddStrPool(pid,txt);
   aScript  := aScript + 'function '+name+'_onclk()'+#13#10+'{ var id="'+name+'"; '+script + ' }'+#13#10;
   aForms := true;
   Result := 0;
end;


//------------------------------------------------------------------------------
procedure BTHTML_Doc._WriteExpLn(s:string);
begin
   outputs := outputs + ansistring(s);
end;

//------------------------------------------------------------------------------

type  ScripStr = record
         meta_txt :string;
         parse_ofs:longword;
         parse_limit:longword;

      end;


function GetToken(const meta_txt :string;
                  var   parse_ofs:longword;
                  const parse_limit:longword;
                  var   token     :string)    :longword;
var c:char;
begin
   result := 0;
   token := '';
   repeat
      c:=meta_txt[parse_ofs];
      if not (c in [' ',#9,#13,#10,',']) then token := token + c;
      inc(parse_ofs);
   until (c in [' ',',',')','(']) or (parse_ofs > parse_limit);
   if length(token) > 0 then
   begin
      Result := 1;
      if token = ')' then Result := 2;
   end;
end;


procedure parser(const meta_txt :string;
                 var   parse_ofs:longword;
                 const parse_limit:longword);
                 var   script   :string;
                 var   now_doing:longword;
var ii,doit :longword;
    token: string;
begin
   ii := GetToken(meta_txt,parse_ofs,parse_limit,token);
   if ii = 1 then
   begin
      if token = 'GOTO(' then
      begin
          GetToken(meta_txt,parse_ofs,parse_limit,token); // URL to navigate

      end;
      if token = 'LOAD(' then
      begin

      end;
      if token = 'GET(' then
      begin

      end;
      if token = 'SET(' then
      begin
          GetToken(meta_txt,parse_ofs,parse_limit,token); // var,obj name

      end;
      if token = 'IF(' then
      begin

      end;
   end;


end;



function  BTHTML_Doc.Scripter(meta_txt:string):string;
var s,st:string;
    token,value:string;
    parse_ofs:longword;
    parse_limit:longword;
    prog:string;
    i,navigate:longword;
    c:char;
(*
    function GetToken:longword;
    begin
       result := 0;
       token := '';
       st := '';
       repeat
          c:=meta_txt[parse_ofs];
          if not c in [' ',#9,#13,#10,','] then st := st + c;
          inc(parse_ofs);
       until (c in [' ',',',')','(']) or (parse_ofs > parse_limit);
       if length(st) > 0 then
       begin
          token := st;
          Result := 1;
          if st = ')' then Result := 2;
       end;
    end;


    procedure parser;
    var ii :longword;
    begin
       ii := GetToken;
       if ii = 1 then
       begin
          if token = 'GOTO(' then
          begin

          end;
          if token = 'LOAD(' then
          begin

          end;
          if token = 'GET(' then
          begin

          end;
          if token = 'SET(' then
          begin

          end;
          if token = 'IF(' then
          begin

          end;


       end;

    end;

*)
begin
(*
   // SYNTAX  VERB(id,params,...)
   // PRAGMA(SID,ID) ??? kakvo sum iskal
   //
   // GOTO(page,value,..,GET(id),..,GET(name),..)
   // LOAD(EL:id,..,page,PARAM:value,..,GET:id,..,VAR:name,..) {AJAX}
   // IF(GET:id expr value,[true],[false]) IF(VAR:name,....   did i need that
   // SET(id,value) SET(id,GET:id) SET(name,...)  SET(...,expr)
   // GET(id)   GET(name)
   // JSCRIPT(text)
   //
   // DOWNLOAD, UPLOAD
   // oste

   s := '';
   if length(meta_txt) > 0 then
   begin
      meta_txt := trim(meta_txt);
      navigate := 0;
      params:='';
      parse_ofs := 1;
      parse_limit := length(meta_txt);
      s := s + 'var st="?SID="+sid+"&ID="+id; ';
      while true do
      begin
         parser;
         if Token = 'GOTO' then
         begin
            s := s + 'st="'+value+'"+st; ';
            navigate := 1;
         end;
         if Token = 'PARAM' then s := s + 'st=st+"&PAR='+value+'"; ';
         if Token = 'GET' then s := s + 'st=st+"&'+value+'="+'+value+'.value; ';
         if parse_ofs > parse_limit then break;
      end;
      if navigate = 1 then s := s + 'window.navigate(st); ';


   end;
   Result := s;
   *)
end;

//------------------------------------------------------------------------------
procedure BTHTML_Doc._GenObject(papa:longword );
var i,m:longword;
    s,st,ust:string;
    hc,vc:boolean;
//TODO optimize s = s+
begin
   if aCount > 0 then
   begin
      for i:= 1 to aCount  do
      begin
         if aList[i].Parent = papa then  // draw only mine
         begin

         if (aList[i].typ and $F00) = $F00  then // Form objects
         begin
            s := #13#10'<input';
            m := aList[i].typ and $FF;  // forms id
            if m = 1 then s := s + ' type="button"';
            if m = 2 then s := s + ' type="image"';
            if m = 3 then s := s + ' type="text"';
            if m = 4 then if aList[i].reserved = 0 then s := s + ' type="checkbox"'
                                                   else s := s + ' type="radio"';
            if m = 5 then s := #13#10'<textarea';  // special object DROPDOWN BOX
            if m = 6 then s := s + ' type="file"';
            if m = 7 then s := s + ' type="password"';

            s := s + ' name="'+aList[i].id+'"';
            if m in [1,2,5,6] then
               s := s + ' onclick="'+aList[i].id+'_onclk()"';
            if m in [3,4,7] then
               s := s + ' onchange="'+aList[i].id+'_onchg()"' ;
            st := Copy(aStringPool,aList[i].txt,aList[i].txt_len);
            if m = 2 then  s := s + ' src="'+st+'" ';
            if (m = 4) and (st = 'on') then s := s + ' checked';
            if (m <> 5) then s := s + ' value="'+st+'" ';
            s := s + ' maxLength="2147483647"';
//            s := s + ' '+ aList[i].FormFont+' ' ;
         end else begin
            s := #13#10'<div';
         end;

         if aList[i].Xpos = $FFFF then hc := true else hc := false;
         if aList[i].Ypos = $FFFF then vc := true else vc := false;

         // begin STYLE attirbute
         s := s + ' id="' + aList[i].id + '" style="';

         if aList[i].AbsMode then
         begin
            s := s + ' position:absolute;';
//            if aList[i].HaveChild then s := s + ' position:relative;'
//                                  else s := s + ' position:absolute;';
            if hc then s := s + ' left:50%; margin-left:-' + toStr(aList[i].Xlng div 2) + 'px;';
            if vc then s := s + ' top:50%; margin-top:-' + toStr(aList[i].Ylng div 2) + 'px;';

            if not hc then
            begin
               if aList[i].Xpos >= 0 then s := s + ' left:' + toStr(aList[i].Xpos) + 'px;'
                                     else s := s + ' right:' + toStr(aList[i].Xpos * -1) + 'px;';
            end;
            if not vc then
            begin
               if aList[i].Ypos >= 0 then s := s + ' top:' + toStr(aList[i].Ypos) + 'px;'
                                     else s := s + ' bottom:' + toStr(aList[i].Ypos * -1) + 'px;';
            end;
         end;
         if aList[i].Xlng > 0 then s := s + ' width:' +toStr(aList[i].Xlng)+'px;'
                              else s := s + ' width:99.5%;';
         if aList[i].Ylng > 0 then s := s + ' height:' +toStr(aList[i].Ylng)+ 'px;'
                              else s := s + ' height:99.5%;';

         if aList[i].AutoScroll = 0 then  s := s + ' overflow:hidden;'
                                    else  s := s + ' overflow:auto;';



         if (aList[i].FillColor and $FF000000) = 0 then
         begin // not trnasparent fill color
            s := s + ' background-color:#' + toHex(aList[i].FillColor and $FFFFFF,6)+'; ';
         end;
         if (aList[i].Color and $FF000000) = 0 then
         begin // not trnasparent fill color
            s := s + ' color:#' + toHex(aList[i].Color and $FFFFFF,6)+'; ';
         end;

         if aList[i].BorderStyle <> 0 then
         begin
            s := s + ' border:#' + toHex(aList[i].BorderColor and $FFFFFF,6)+' '+toStr(aList[i].BorderWidth)+'px ';
            if aList[i].BorderStyle = 1 then s := s + 'solid; ';
            if aList[i].BorderStyle = 2 then s := s + 'dashed; ';
            if aList[i].BorderStyle = 3 then s := s + 'dotted; ';
         end;

         if aList[i].align = 0 then  s := s + ' text-align:left;';
         if aList[i].align = 1 then  s := s + ' text-align:center;';
         if aList[i].align = 2 then  s := s + ' text-align:right;';

         s := s + ' '+ aList[i].FormFont;

         s := s + ' z-index:'+toStr(i)+';" '; // end style with " //100

         st := '';
         ust := '';
         if aList[i].txt_len <> 0 then //have some text
         begin
            st := Copy(aStringPool,aList[i].txt,aList[i].txt_len);
            ust := UTF8Encode(st)
         end;

         if (aList[i].typ and $F00) = $F00  then
         begin
            m := aList[i].typ and $FF;  // forms id
            if (m = 5)  then
            begin  // drop down box
//               st := Copy(aStringPool,aList[i].txt,aList[i].txt_len);
//               s := S + '>' +  UTF8Encode(st) + '</textarea>';
               s := S + '>' +  ust + '</textarea>';
            end else begin
               s := s + '/>';
            end;
            _WriteExpLn(s);
         end else begin
            s := s + '>';
            if aList[i].typ  = 0 then
            begin  // shape
               if length(ust) = 0 then  s := s + '&nbsp;'
                                  else  s := s + ust;
            end;
            if aList[i].typ  in [1,4] then // text + table
            begin  // text
//               st := Copy(aStringPool,aList[i].txt,aList[i].txt_len);
//               s := s +  UTF8Encode(st);
               s := s + ust;
            end;
            if aList[i].typ  = 2 then
            begin  // picture
//               st := Copy(aStringPool,aList[i].txt,aList[i].txt_len);
               s := s + '<img '+st+' >'
            end;
            if aList[i].typ  = 3 then
            begin  // Combo  box inside div
//               st := Copy(aStringPool,aList[i].txt,aList[i].txt_len);
               s := s +'<select name="'+string(aList[i].id)+
                       '" size="'+toStr(aList[i].reserved)+
                       '" id="'+string(aList[i].id)+
                       '" onchange="'+string(aList[i].id)+
                       '_onchg()"' +#13#10;
               s := s + 'style="position:absolute;left:0px;top:0px;width:100%;height:100%;border-width:0px;'+
                       string(aList[i].FormFont)+'">'+#13#10;
               s := s + st;
               s := s + '</select>'+#13#10;
            end;

            // look for child
//            mm := 0;
//            for ii := 1 to aCount do
//            begin
//               if aList[ii].Parent = i then mm := i;
//            end;
//            if mm <> 0 then
            _WriteExpLn(s);
            _GenObject(i);


            s := '</div>';
            _WriteExpLn(s);
         end;


//         _WriteExpLn(s);
         end;
       end;
   end;
end;

function  BTHTML_Doc.Generate:pchar;
var s,st:string;
//TODO optimize s = s+
begin
   result := Nil;
   outputs := '';
   _WriteExpLn('<!DOCTYPE html>');
//   _WriteExpLn('<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">');
   _WriteExpLn('<html><head>');
   _WriteExpLn('<meta http-equiv="Content-Type" content="text/html; charset='+aPageEnc+'">'); //utf-8
   _WriteExpLn('<meta name="Generator" content="BHTML Generator v1">');
   _WriteExpLn('<title>' + UTF8Encode(aTitle) + '</title>'+#13#10);
   s :=     '<style type="text/css">' +#13#10;
   s := s + 'body' + #13#10;
   s := s + '{' + #13#10;
   s := s + '   background-color: #'+ToHex(aPageBackCl,6)+';' + #13#10;
   if aPagePicF <> 0  then
   begin
      s := s + '   background-image: url("'+aPagePic+'");' +#13#10;     // can have back color and picture
      case ((aPagePicF and $6) shr 1) of
         0: s := s + '   background-image: repeat;'+#13#10;
         1: s := s + '   background-image: repeat-x;'+#13#10;
         2: s := s + '   background-image: repeat-y;'+#13#10;
         3: s := s + '   background-image: no-repeat;'+#13#10;
      end;
      if (aPagePicF and $8) <> 0 then s := s + '   background-attachment: fixed;'+#13#10; // not scrolled with text
      if (aPagePicF and $F0) <> 0 then
      begin
         st := '';
         if (aPagePicF and $10) <> 0 then st := st + ' right';
         if (aPagePicF and $20) <> 0 then st := st + ' left';
         if (aPagePicF and $40) <> 0 then st := st + ' top';
         if (aPagePicF and $80) <> 0 then st := st + ' bottom';
         s := s + '   background-position '+st+';'+#13#10;
      end;
      //todo some margins
   end;
   s := s + '   color: #000000;' + #13#10;
   s := s + '}' + #13#10;
//   s := s + '.hcentr { margin-left:auto; margin-right:auto; }'+#13#10;
//   s := s + '.hcentr { left:50%; transform: translatex(-50%);}'+#13#10;
//   s := s + '.vcentr { top:50%; transform:translatey(-50%);}'+#13#10;
   s := s + aFontsDef;
   // center absolute #id { margine -height/2px 0 0 -width/2px
   s := s + '</style>' + #13#10;
   _WriteExpLn(s);
   _WriteExpLn('</head>');

   _WriteExpLn('<body topMargin="0" leftMargin="0">');

   if aForms then
   begin
      s := #13#10+'<script type = "text/jscript" language="JScript" >'+#13#10
           + 'var sid="'+ aSID + '";' + #13#10;
//      aScript := _Scripter(aScript); // translate to java script
      if aAJAX then
      begin
        s := s + 'function loadAJAXDat(url,elem)'+#13#10+
        '{ var xmlhttp; var txt;'+#13#10+
        'if (window.XMLHttpRequest){'+#13#10+ // code for IE7+, Firefox, Chrome, Opera, Safari
        'xmlhttp=new XMLHttpRequest();'+
        '}else{'+#13#10+  // code for IE6, IE5
        'xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");}'+#13#10+
        'xmlhttp.onreadystatechange=function()'+#13#10+
        '{if (xmlhttp.readyState==4 && xmlhttp.status==200)'+#13#10+
        '{txt=xmlhttp.responseText;'+#13#10+
        // for xml response
        //    x=xmlhttp.responseXML.documentElement.getElementsByTagName("CD");
        // for (i=0;i<x.length;i++)
        // .. xx=x[i].getElementsByTagName("TITLE");
        'document.getElementById(elem).innerHTML=txt;}}'+#13#10+
        'xmlhttp.open("GET",url,true); xmlhttp.send(); }'+#13#10;  //POST , GET to get content of file from url 
      end;
      s := s + aScript +'</script>';
      _WriteExpLn(s);
   end;

   _GenObject(0);

   _WriteExpLn(#13#10+'</body></html>');

   outputs := outputs + #0;
end;

//------------------------------------------------------------------------------
function  BTHTML_Doc.SaveToFile(fname:string):longint;
var f:file of byte;
    i:longword;
begin
  // Generate;
  // do it with BFileTools
   system.Assign(f,fname);
   Rewrite(f);
   for i := 1 to length(outputs) do write(f,byte(outputs[i]));

//   system.blockwrite(f,outputs,length(outputs));
   Close(f);
   result := 0;
end;





function HTML_TableBuilder():string;
begin

   Result := '<table>asdasd</table>';
end;



////////////////////////////////////////////////////////////////////////////////
//
//  I N T E R F A C E
//
////////////////////////////////////////////////////////////////////////////////

//------------------------------------------------------------------------------
function BTHTML_Generate(hdoc:longword):pchar; stdcall; export;
var doc:BTHTML_Doc;
begin
   result := Nil;
   if hdoc = 0 then exit;
   doc := BTHTML_Doc(hdoc);
   result := doc.Generate;
end;

//------------------------------------------------------------------------------
function BTHTML_BeginDoc:longword; stdcall; export;
var temp:BTHTML_Doc;
begin
   result := 0;
   temp := BTHTML_Doc.Create;
   if assigned(temp) then result := Longword(temp)
end;

//------------------------------------------------------------------------------
procedure BTHTML_FinishDoc(hdoc:longword); stdcall; export;
var doc:BTHTML_Doc;
begin
   if hdoc = 0 then exit;
   doc := BTHTML_Doc(hdoc);
   doc.Free;
end;

//------------------------------------------------------------------------------
function BTHTML_SaveToFile(hdoc:longword; Fname:pchar):longint; stdcall; export;
var doc:BTHTML_Doc;
begin
   result := 0;
   if hdoc = 0 then exit;
   doc := BTHTML_Doc(hdoc);
   result := doc.SaveToFile(Fname);
end;







end.
