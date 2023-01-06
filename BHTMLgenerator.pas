unit BHTMLgenerator;

interface

type

    BTHTMLdynItem = class
       private
          escchar     :char;
          addstyle    :string;
          ChildRender :string;
          Next        :pointer;
          function    _RenderStyle:string;
          function    _RenderAttr:string;
          function    _MyTextFormater(const the_txt:string; useParag:boolean=false; TableBld:boolean=false):string;

       public
          Tag         :string;
          Tag_type    :string;
          ItemType    :longword;
          Id          :string;
          Clss        :string;
          name        :string;
          Width       :longword;
          WidthPercent :boolean;
          Height      :longword;
          HeightPercent :boolean;
          X,Y         :longint;
          Xright      :longint;
          Ybottom     :longint; //use for anchor
          AbsolutePos :boolean;
          Txt         :string;
          Color       :longword;
          BkgColor    :longword;
          UseBkgColor :boolean;
          FontName    :string;
          FontSize    :longword;
          FontAttr    :longword;
          Border      :boolean;
          BorderStyle :longword;
          BorderSize  :longword;
          BorderColor :longword;
          BorderFrame :longword;
          Align       :longword;
          VAlign      :longword;
          SendClick   :boolean;
          ParentId    :string;
          EmbedStyle  :boolean;
          CenterVer   :boolean;
          CenterHor   :boolean;
          ForceNewLine :longword;
          UserTag     :string;    //not used
          MarginLeft  :longword;
          MarginRight :longword;
          MarginTop   :longword;
          MarginBottom :longword;
          Checked     :boolean;
          Disabled    :boolean;
          Visible     :boolean;
          ShowLines   :longword;
          Temp        :string;
          Multiselect :boolean;
          Sizeble     :boolean;
          JScript     :string; //onclic

          constructor Create(const the_id:string = ''); virtual;
          destructor  Destroy; override;
          function    Render:string; virtual;
          function    Load(const  data:ansistring):longint; virtual;
          function    Save:ansistring; virtual;
          function    SetPosition(Xpos,Ypos:longint; Absolute_Pos :boolean = true):BTHTMLdynItem;
          function    SetPositionRight(Xpos:longint; Absolute_Pos :boolean = true):BTHTMLdynItem;
          function    SetPositionBottom(Ypos:longint; Absolute_Pos :boolean = true):BTHTMLdynItem;
          function    SetSize(Xlng,Ylng:longword):BTHTMLdynItem;
          function    SetSizePercent(Xlng,Ylng:longword):BTHTMLdynItem;
          function    SetBorder(On_Off:boolean; Style,Size,Color:longword):BTHTMLdynItem;
          function    SetMargin(Left,Right,Top,Bottom:longword):BTHTMLdynItem;
          function    SetBackgroundColor(On_Off:boolean; Color:longword):BTHTMLdynItem;
          function    SetText(const the_text:string):BTHTMLdynItem;
          function    SetColor(The_Color:longword):BTHTMLdynItem;
          function    SetCenter(Horizontal,Vertical:boolean):BTHTMLdynItem;
          function    SetParentID(const ID:string):BTHTMLdynItem;
          function    SetOnClick(const Script:string):BTHTMLdynItem;
    end;




    BTHTMLdynPage = class
       private
          aItems :BTHTMLdynItem;
          aItemsCount:longword;
          aJSfile:string;
          aCSSfile:string;
          aTitle:string;
          aPageBackgroundColor :longword;
          aPageBackgroundstyle :longword;
          function    _GenerateCSS:longint;
          function    _GenerateJS:longint;
          function    _GetItem(value:longword):BTHTMLdynItem;
          procedure   _ClearItems;
          procedure   _FillChildRender(a:BTHTMLdynItem);
          procedure   _RenderItems(var html:string);
       public
          Title       :string;
          AppName     :string;
          SessionID   :string;
          FormID      :string;
          IconURL     :string;
          constructor Create;
          destructor  Destroy; override;
          procedure   Reset;
          function    Render(var html,css,js:ansistring; flags:longword = 0):longint;
          procedure   AddItem(obj:BTHTMLdynItem);
          function    AddCustom(const ID:string):BTHTMLdynItem;
          function    AddText(const ID,Txt:string):BTHTMLdynItem;
          function    AddLabel(const ID,Txt:string):BTHTMLdynItem;
          function    AddButton(const ID,Txt:string):BTHTMLdynItem;
          function    AddTextBox(const ID,Txt:string):BTHTMLdynItem;
          function    AddCheckBox(const ID,Txt:string; Checked:boolean):BTHTMLdynItem;
          function    AddRadioButton(const ID,Group,Txt:string; Checked:boolean):BTHTMLdynItem;
          function    AddListBox(const ID,Items,Selected:string; ShowLines:longword; multiselect:boolean=false):BTHTMLdynItem;
          function    AddDropDownListBox(const ID,Items,Selected:string; ShowLines:longword; multiselect:boolean=false):BTHTMLdynItem;
          function    AddLink(const ID,Txt,Url:string):BTHTMLdynItem;
          function    AddPassword(const ID:string):BTHTMLdynItem;
          function    AddMemo(const ID,Txt:string; sizeble:boolean=false):BTHTMLdynItem;
          function    AddDate(const ID,Date:string):BTHTMLdynItem;   //TODO ne boti
          function    AddImage(const ID,Src:string):BTHTMLdynItem;
          function    AddBox(const ID:string):BTHTMLdynItem;
          function    AddCanvas(const ID:string;Xlng,Ylng:longword):BTHTMLdynItem;
          function    AddHorizontalLine(const ID:string; Style,Size,Color:longword):BTHTMLdynItem;
          function    AddTime(const ID,Time:string):BTHTMLdynItem;
          function    AddTable(const ID,TableDescriptor:string):BTHTMLdynItem;


//AddShape
//Background page and object as picture !!


          function    Load(const  data:ansistring):longint;
          function    Save:ansistring;
          property    ItemsCount:longword read aItemsCount;
          property    Items[i:longword] :BTHTMLdynItem read _GetItem;
    end;

function  ImageToEmbedSrc(const File_name:string):string;


{ My text formater  ~ - special char   ~~ = ~
  ~B - bold
  ~b - bold off
  ~I - italic
  ~i - italic off
  ~U - underline
  ~u - underline off
  ~N - new line
  ~P - Paragraph
  ~Cxxxxxx - Color (in text hex) of text example ~CFF0000 = red
  ~Gxxxxxx - Background color (in text hex) of text
  ~Sx..x* - Fint size in pixel (note * is the end of data when data is not with fixed size
            x..x - no fixed size)
            example ~S14* this is font size 14
  ~Ax - Align 0 = none 1 = left  2 = center  3 = right  4 - jutify
  ~Fx..x* - Fonat name example ~FTimes New Roman*
  ~Dx..x* - Text indent in pixels
  ~Hx..x* - Height in pixels
  ~hx..x* - Height in percents
  ~Wx..x* - Width in pixels
  ~wx..x* - Width in percents
  ~Vx - Vertical align  0 = none 1 = left  2 = center  3 = right
            if c = 'R' then begin rst := true; incmd := false; end; //Reset to default
  ~Lx..x* - Line height !! real example ~L0.8*
  ~Ex..x* = Letter spacing in pixel int example  ~E-2* minus two or ~E5*

table specific when you describe a Table
  ~TR - Begining of row (if use above formating will work for whole row)
  ~TC - Begining of column (if use above formating will work for whole column)
  ~TD - column data   possible format are C S F G

  ~Mx..x*  Border x..x  x[1] = size in pixels from 1 to 9
                        x[2] = border style 0 = solid 1 = dashed 2 = ..
                        x[3..8] = color hex color
                        x[9..] if exists is border existans T-Top B-bottom L-left  R-Right
  example ~M10E0E0E0T* only top border solid 1px with color E0E0E0
}


implementation

uses BUnicode,BStrTools,BBase64,BFileTools;

var idsequence:longword;

//------------------------------------------------------------------------------
function    _ToHexRgb(val:longword):string;
begin
   if val > $FFFFFF then
   begin                                                         // WARNING
     Result := 'rgba('+ ToStr((val shr 16) and $FF) + ',' +      // CCS 3   rgba()
                        ToStr((val shr 8)  and $FF) + ',' +      // not all browser suport it
                        ToStr( val         and $FF) + ',' +
                        ToStrF( trunc( ((val shr 24) and $FF)) / 255,1,1) + ')';
   end else begin
     Result := '#'+ ToHex(val,6);
   end;
end;

//=================================================== P A G E ==================
constructor BTHTMLdynPage.Create;
begin
   aItems := nil;
   Reset;
end;

//------------------------------------------------------------------------------
destructor  BTHTMLdynPage.Destroy;
begin
   Reset;
   inherited;
end;

//------------------------------------------------------------------------------
procedure   BTHTMLdynPage._ClearItems;
var a,b:BTHTMLdynItem;
begin
   a := aItems;
   while a <> nil do
   begin
      b := a;
      a := a.Next;
      b.Free;
   end;
   aItems := nil;
end;

//------------------------------------------------------------------------------
procedure   BTHTMLdynPage.Reset;
begin
   idsequence := 0;
   aTitle := 'Unknown';
   aPageBackgroundColor := $FFFFFF;
   aPageBackgroundStyle := 1;
   aCSSfile := '';
   aJSfile := '';
   _ClearItems;
end;

//------------------------------------------------------------------------------
function    BTHTMLdynPage._GetItem(value:longword):BTHTMLdynItem;
var i :longword;
begin
   Result := aItems;
   if value > 0 then
   begin
      i := 0;
      while Result <> nil do
      begin
         inc(i);
         if i = value then break;
         Result := Result.Next;
      end;
   end;
end;

//------------------------------------------------------------------------------
procedure   BTHTMLdynPage.AddItem( obj :BTHTMLdynItem);
var a:BTHTMLdynItem;
begin
   if aItems = nil then
   begin
      aItems := obj;
   end else begin
      a := aItems;
      while a.Next <> nil do a := a.Next;
      a.Next := obj;
   end;
end;

//------------------------------------------------------------------------------
function    BTHTMLdynPage._GenerateCSS:longint;
var a:BTHTMLdynItem;
begin
   aCSSfile := '';
   Result := 0;
   // main page style
   if aPageBackgroundStyle <> 0 then
   begin
      aCSSfile := aCSSfile + 'body {';
      case aPageBackgroundStyle of
         1 : aCSSfile := aCSSfile + 'background-color:'+_ToHexRgb(aPageBackgroundColor)+';';  //# for hex or rgb() or rgba()
      end;
      aCSSfile := aCSSfile + 'font-family:Arial;';
      aCSSfile := aCSSfile + 'font-size:16px;';
      aCSSfile := aCSSfile + '}';
   end;
   //add Items style
   a := aItems;
   while a <> nil do
   begin
      if not a.EmbedStyle then
      begin
         aCSSfile := aCSSfile + ' .s'+a.Id + ' {'+ a._RenderStyle+'}';
      end;
      a := a.Next;
   end;


end;

//------------------------------------------------------------------------------
function    BTHTMLdynPage._GenerateJS:longint;
begin
   Result := 0;
end;

//------------------------------------------------------------------------------
procedure   BTHTMLdynPage._FillChildRender(a:BTHTMLdynItem); //recursion
var b:BTHTMLdynItem;
begin
   if a = nil then
   begin
      b := aItems;
      while b <> nil do
      begin
         _FillChildRender(b);
         b := b.Next;
      end;
   end else begin
      b := aItems;
      while b <> nil do
      begin
         if b.ParentID = a.ID then _FillChildRender(b);
         b := b.Next;
      end;
      b := aItems;
      while b <> nil do
      begin
         if b.ID = a.ParentID then b.ChildRender := a.Render;
         b := b.Next;
      end;
   end;
end;

//------------------------------------------------------------------------------
procedure   BTHTMLdynPage._RenderItems(var html:string);
var a:BTHTMLdynItem;
begin
   a := aItems; //clear child render
   while a <> nil do
   begin
      a.ChildRender := '';
      a := a.Next;
   end;

   _FillChildRender(nil); // fill child render

   a := aItems; // render all parents not children
   while a <> nil do
   begin
      if length(a.ParentId) = 0 then  html := html + a.Render;
      a := a.Next;
   end;
end;

//------------------------------------------------------------------------------
function    BTHTMLdynPage.Render(var html,css,js:ansistring; flags:longword = 0):longint;
var h:string;
begin
   Result := -1;
   if _GenerateCSS = 0 then
   begin
      if _GenerateJS = 0 then
      begin


      end else begin
         Result := -2;
      end;
   end else begin
      Result := -3;
   end;



   html := '<!DOCTYPE html><html>';
   html := html +'<head><meta content="text/html; charset=UTF-8" http-equiv="content-type"" >';
   html := html +'<title>'+ Unicode2UTF8(widestring(aTitle)) +'</title>';
   if length(aCSSfile) > 0 then
   begin
      html := html +'<style>'+ansistring(aCSSfile)+'</style>';
   end;

   html := html +'</head>';
   html := html +'<body topMargin="0" leftMargin="0">';

   _RenderItems(h);
   html := html + ansistring(h);

   if length(aJSfile) > 0  then
   begin
      html := html +'<script>'+ansistring(aJSfile)+'</script>';
   end;

   html := html +'</body></html>';
end;

//------------------------------------------------------------------------------
function    BTHTMLdynPage.Load(const  data:ansistring):longint;
begin
   Result := -1;

end;

//------------------------------------------------------------------------------
function    BTHTMLdynPage.Save:ansistring;
begin
   Result := '';

end;

//------------------------------------------------------------------------------
function    BTHTMLdynPage.AddCustom(const ID:string):BTHTMLdynItem;
begin
   Result := BTHTMLdynItem.Create(ID);
   AddItem(Result);
end;

//------------------------------------------------------------------------------
function    BTHTMLdynPage.AddText(const ID,Txt:string):BTHTMLdynItem;
begin
   Result := BTHTMLdynItem.Create(ID);
   Result.SetText(Txt);
   Result.ItemType := 2;
   AddItem(Result);
end;

//------------------------------------------------------------------------------
function    BTHTMLdynPage.AddLabel(const ID,Txt:string):BTHTMLdynItem;
begin
   Result := BTHTMLdynItem.Create(ID);
   Result.Txt := Txt;
   Result.ItemType := 1;
   AddItem(Result);
end;

//------------------------------------------------------------------------------
function    BTHTMLdynPage.AddButton(const ID,Txt:string):BTHTMLdynItem;
begin
   Result := BTHTMLdynItem.Create(ID);
   Result.Txt := Txt;
   Result.ItemType := 3;
   AddItem(Result);
end;

//------------------------------------------------------------------------------
function    BTHTMLdynPage.AddTextBox(const ID,Txt:string):BTHTMLdynItem;
begin
   Result := BTHTMLdynItem.Create(ID);
   Result.Txt := Txt;
   Result.ItemType := 6;
   AddItem(Result);
end;

//------------------------------------------------------------------------------
function    BTHTMLdynPage.AddCheckBox(const ID,Txt:string; Checked:boolean):BTHTMLdynItem;
begin
   Result := BTHTMLdynItem.Create(ID);
   Result.Txt := Txt;
   Result.ItemType := 4;
   Result.Checked := Checked;
   AddItem(Result);
end;

//------------------------------------------------------------------------------
function    BTHTMLdynPage.AddRadioButton(const ID,Group,Txt:string; Checked:boolean):BTHTMLdynItem;
begin
   Result := BTHTMLdynItem.Create(ID);
   Result.Txt := Txt;
   Result.ItemType := 5;
   Result.Checked := Checked;
   Result.Name := Group;
   AddItem(Result);
end;

//------------------------------------------------------------------------------
function    BTHTMLdynPage.AddListBox(const ID,Items,Selected:string; ShowLines:longword; multiselect:boolean=false):BTHTMLdynItem;
begin
   Result := BTHTMLdynItem.Create(ID);
   Result.Txt := Items;
   Result.ItemType := 8;
   if ShowLines < 2 then ShowLines := 2;
   Result.ShowLines := ShowLines;
   Result.Temp := Selected;
   Result.multiselect := Multiselect;
   AddItem(Result);
end;

//------------------------------------------------------------------------------
function    BTHTMLdynPage.AddDropDownListBox(const ID,Items,Selected:string; ShowLines:longword; multiselect:boolean=false):BTHTMLdynItem;
begin
   Result := BTHTMLdynItem.Create(ID);
   Result.Txt := Items;
   Result.ItemType := 8;
   Result.Temp := Selected;
   Result.multiselect := Multiselect;
   AddItem(Result);
end;

//------------------------------------------------------------------------------
function    BTHTMLdynPage.AddLink(const ID,Txt,Url:string):BTHTMLdynItem;
begin
   Result := BTHTMLdynItem.Create(ID);
   Result.Txt := Txt;
   Result.ItemType := 9;
   Result.Temp := Url;
   AddItem(Result);
end;

//------------------------------------------------------------------------------
function    BTHTMLdynPage.AddPassword(const ID:string):BTHTMLdynItem;
begin
   Result := BTHTMLdynItem.Create(ID);
   Result.ItemType := 7;
   AddItem(Result);
end;

//------------------------------------------------------------------------------
function    BTHTMLdynPage.AddMemo(const ID,Txt:string; sizeble:boolean=false):BTHTMLdynItem;
begin
   Result := BTHTMLdynItem.Create(ID);
   Result.ItemType := 10;
   Result.Txt := Txt;
   Result.Sizeble := sizeble;
   AddItem(Result);
end;

//------------------------------------------------------------------------------
function    BTHTMLdynPage.AddDate(const ID,Date:string):BTHTMLdynItem;
begin
   Result := BTHTMLdynItem.Create(ID);
   Result.ItemType := 11;
   Result.Txt := Date;
   AddItem(Result);
end;

//------------------------------------------------------------------------------
function    BTHTMLdynPage.AddTime(const ID,Time:string):BTHTMLdynItem;
begin
   Result := BTHTMLdynItem.Create(ID);
   Result.ItemType := 14;
   Result.Txt := Time;
   AddItem(Result);
end;

//------------------------------------------------------------------------------
function    BTHTMLdynPage.AddImage(const ID,Src:string):BTHTMLdynItem;
begin
   Result := BTHTMLdynItem.Create(ID);
   Result.ItemType := 12;
   Result.Txt := Src;
   AddItem(Result);
end;

//------------------------------------------------------------------------------
function    BTHTMLdynPage.AddBox(const ID:string):BTHTMLdynItem;
begin
   Result := BTHTMLdynItem.Create(ID);
   Result.ItemType := 2;
   AddItem(Result);
end;

//------------------------------------------------------------------------------
function    BTHTMLdynPage.AddCanvas(const ID:string; Xlng,Ylng:longword):BTHTMLdynItem;
begin
   Result := BTHTMLdynItem.Create(ID);
   Result.ItemType := 13;
   Result.Txt := 'Your browser does not support the HTML cancas tag';
   Result.Width := Xlng;
   Result.Height := Ylng;
   AddItem(Result);
end;


//------------------------------------------------------------------------------
function    BTHTMLdynPage.AddHorizontalLine(const ID:string; Style,Size,Color:longword):BTHTMLdynItem;
begin
   Result := BTHTMLdynItem.Create(ID);
   Result.ItemType := 2;
   Result.Border := true;
   Result.BorderStyle := Style;
   Result.BorderSize := Size;
   Result.BorderColor := Color;
   Result.Width := 100; // percent
   Result.WidthPercent := true;
   Result.BorderFrame := 1;
   AddItem(Result);
end;


//------------------------------------------------------------------------------
function    BTHTMLdynPage.AddTable(const ID,TableDescriptor:string):BTHTMLdynItem;
begin
   Result := BTHTMLdynItem.Create(ID);
   Result.ItemType := 15;
   Result.Txt := TableDescriptor;
   AddItem(Result);
end;


//=================================================== I T E M ==================
constructor BTHTMLdynItem.Create(const the_ID:string = '');
begin
   inc(idsequence);
   Next := nil;
   ItemType    := 0;
   tag         := '';
   tag_type    := '';
   ItemType    := 0;
   if length(the_ID) > 0  then Id := the_ID
                          else Id := 'id' + toStr(Idsequence);
   Clss        := '';
   name        := '';
   Width       := 0;
   WidthPercent := false;
   Height      := 0;
   HeightPercent := false;
   X           := -1;
   Y           := -1;
   Xright      := -1;
   Ybottom     := -1;

   AbsolutePos := false;
   Txt         := '';
   Color       := $000000;
   BkgColor    := $FFFFFF;
   UseBkgColor := false;
   FontName    := 'Arial';
   FontSize    := 16;
   FontAttr    := 0;
   Border      := false;
   BorderStyle := 0;
   BorderSize  := 1;
   BorderColor := $000000;
   Align       := 0;
   VAlign      := 0;
   SendClick   := false;
   ParentId    := '';
   EmbedStyle  := true;
   ChildRender := '';
   CenterVer   := false;
   CenterHor   := false;
   ForceNewLine := 0;
   UserTag     := '';
   addstyle    := '';
   escchar     := '~'; //#27;
   MarginLeft  := 0;
   MarginRight := 0;
   MarginTop   := 0;
   MarginBottom := 0;
   Checked     := false;
   Disabled    := false;
   ShowLines   := 0;
   Multiselect := false;
   Visible     := true;
   Sizeble     := true;
   BorderFrame := 0;
end;

//------------------------------------------------------------------------------
destructor  BTHTMLdynItem.Destroy;
begin
   inherited;
end;

//------------------------------------------------------------------------------
function    BTHTMLdynItem._RenderAttr:string;
begin
   Result := ' id="'+id+'"';
   if not EmbedStyle then Result := Result + ' class="s'+id+'"';
   if length(Name) > 0 then Result := Result + ' name="'+name+'"';


end;

//------------------------------------------------------------------------------
function    _HorAlign(i:longword):string;
begin
   Result := '';
   case i of
      1: Result := ' text-align:left;';
      2: Result := ' text-align:center;';
      3: Result := ' text-align:right;';
      4: Result := ' text-align:justify; text-justify:inter-word;';
   end;
end;

function    _VerAlign(i:longword):string;
begin
   Result := '';
   case i of
      1: Result := ' vertical-align:top;';
      2: Result := ' vertical-align:middle;';
      3: Result := ' vertical-align:bottom;';
   end;
end;


function    _BorderStyle(bt,i,bs,bc:longword):string;
begin
   Result := '';
   if (bt and 1) <> 0 then Result := Result + ' border-top:';
   if (bt and 2) <> 0 then Result := Result + ' border-bottom:';
   if (bt and 4) <> 0 then Result := Result + ' border-left:';
   if (bt and 8) <> 0 then Result := Result + ' border-right:';
   if length(Result) = 0 then Result := Result + ' border:'; //0
   case i of
      1:   Result := Result + ' dotted';
      2:   Result := Result + ' dashed';
      else Result := Result + ' solid'; //0
   end;
   Result := Result + ' ' + ToStr(bs)+'px';
   Result := Result + ' ' + _ToHexRgb(bc)+';'
end;

function    BTHTMLdynItem._RenderStyle:string;

   function _CountElem(a,b,c,d:longint):longint;
   begin
      Result := 0;
      if a > 0 then inc(Result);
      if b > 0 then inc(Result);
      if c > 0 then inc(Result);
      if d > 0 then inc(Result);
   end;

begin
   Result := '';
   if Border then Result := Result + _BorderStyle(0,BorderStyle,BorderSize,BorderColor);
   if Color <> 0  then           Result := Result + ' color:'+ _ToHexRgb(Color)+';';
   if UseBkgColor then           Result := Result + ' background-color:'+ _ToHexRgb(BkgColor)+';';
   if length(FontName) > 0 then  Result := Result + ' font-family:'+ FontName+';';
   if FontSize > 0 then          Result := Result + ' font-size:'+ ToStr(FontSize)+'px;';
   if FontAttr <> 0 then
   begin
      if (FontAttr and 1)<>0 then Result := Result + ' font-weight:bold;';
      if (FontAttr and 2)<>0 then Result := Result + ' font-style:italic;';
      if (FontAttr and 4)<>0 then Result := Result + ' font-style:underline;';
   end;
   if AbsolutePos then Result := Result + ' position:absolute;';   //position:relative; ????
   if CenterHor then
   begin
      Result := Result + ' left:50%; margin-left:-'+ToStr(Width div 2)+'px;';
   end else begin
      if AbsolutePos then
      begin
         if X >= 0      then  Result := Result + ' left:' + ToStr(X) + 'px;';
         if Xright >= 0 then  Result := Result + ' right:' + ToStr(Xright) + 'px;';  //???? TODO for - 10
      end;
   end;

   if CenterVer then begin
      Result := Result + ' top:50%; margin-top:-'+ToStr(Height div 2)+'px;';
   end else begin
      if AbsolutePos then
      begin
         if Y >= 0       then Result := Result + ' top:' + ToStr(Y) + 'px;';
         if Ybottom >= 0 then Result := Result + ' bottom:' + ToStr(Ybottom) + 'px;';
      end;
   end;
   if Width > 0 then
   begin
      Result := Result + ' width:'+ToStr(Width);
      if WidthPercent then Result := Result + '%;' else Result := Result + 'px;'
   end;
   if Height > 0 then
   begin
      Result := Result + ' height:'+ToStr(Height);
      if HeightPercent then Result := Result + '%;' else Result := Result + 'px;'
   end;
   if Align > 0 then Result := Result + _HorAlign(Align);
   if VAlign > 0 then Result := Result + _VerAlign(VAlign);
   if _CountElem(MarginLeft,MarginRight,MarginTop,MarginBottom) > 1 then
   begin
      Result := Result + ' margin:'+ToStr(MarginTop)+'px '+ToStr(MarginRight)+'px '+ ToStr(MarginBottom)+'px '+ToStr(MarginLeft)+'px;';
   end else begin
      if MarginLeft > 0 then Result := Result + ' margin-left:'+ToStr(MarginLeft)+'px;';
      if MarginRight > 0 then Result := Result + ' margin-right:'+ToStr(MarginRight)+'px;';
      if MarginTop > 0 then Result := Result + ' margin-top:'+ToStr(MarginTop)+'px;';
      if MarginBottom > 0 then Result := Result + ' margin-bottom:'+ToStr(MarginBottom)+'px;';
   end;
   if not visible then Result :=Result + ' visibility:hidden;';
   if not sizeble then Result := Result + ' resize:none;';


   Result := Result + addstyle; //additional
end;

//------------------------------------------------------------------------------

function    BTHTMLdynItem.Render:string;
var s,sv,styp,sname,sche,sdis,s1 :string;
    i,j:longword;
    bval,upar,lpack,lbox,tbl:boolean;
begin
   bval := false;
   upar := false;
   lpack := false;
   lbox := false;
   tbl := false;
   tag_type := '';
   s1 := ''; //Force Style

   case ItemType of
      1: tag:= 'label'; //Label
      2: begin tag:= 'div'; upar := true; end; //Text & Box
      3: begin tag:= 'button'; tag_type := 'button';  end; //Button
      4: begin tag:= 'label'; tag_type := 'checkbox'; lpack := true; end; //Check box
      5: begin tag:= 'label'; tag_type := 'radio'; lpack := true; end; //Radio
      6: begin tag:= 'input'; tag_type := 'text'; bval := true; end; //Edit
      7: begin tag:= 'input'; tag_type := 'password'; bval := true; end; //Password
      8: begin tag:= 'select'; lbox := true; end; //ListBox & DropDownListBox
      9: begin tag:= 'a'; end; //Link
     10: begin tag:= 'textarea'; end; // Memo
     11: begin tag:= 'input'; tag_type := 'text'; bval:=true; end;  //Date
     12: begin tag:= 'img'; end;  // Image
     13: begin tag:= 'canvas'; end; //Canvas
     14: begin tag:= 'input'; tag_type := 'time'; bval:=true; end;  //Time
     15: begin tag:= 'table'; tbl := true; s1 := ' border-collapse:collapse;'; end;
   end;

   if length(Tag_type) = 0 then styp  := '' else styp  := ' type="'+Tag_type+'"';
   if length(Name) = 0     then sname := '' else sname := ' name="'+Name+'"';
   if Checked              then sche := ' checked'  else sche := '';
   if Disabled             then sdis := ' disabled' else sdis := '';





   Result := '<' + Tag;

   if ItemType = 9 then Result := Result + ' href="'+Temp+'"';
   if ItemType = 11 then Result := Result + ' required pattern="##/##/####"'; //"\d{2}/\d{2}/\d{4}"';

   if (length(tag_type) > 0) and (not lpack) then Result := Result + styp;
   if (length(Name) > 0) and (not lpack)then Result := Result + sname;
   if ShowLines > 0  then Result := Result + ' size="'+ToStr(ShowLines)+'"';

   Result := Result + _RenderAttr +sdis;

   if ShowLines > 0  then Result := Result + ' size="'+ToStr(ShowLines)+'"';
   if multiselect then Result := Result + ' multiple';


   if EmbedStyle then
   begin
      s := _RenderStyle + s1;
      if length(s) > 0 then Result := Result + ' style="' + s + '"';
   end;

   if bval then
   begin
   sv := Txt
   end else sv := _MyTextFormater(Txt,upar,tbl);

   sv := string(Unicode2UTF8(widestring(sv)));
   if bval then
   begin
      Result := Result + ' value="'+ sv +'"';
      sv := '';
   end;

   if ItemType = 12 then
   begin
      Result := Result + ' src="'+Txt+'"';
      sv := '';
   end;

   if lpack then sv := '<input '+ styp + sname + sche + sdis + '/>' + sv;
   if lbox then
   begin
      sv := '';
      j := 0;
      repeat
         s1 := '';
         s := ParseStr(Txt,j,'|');
         inc(j);
         if j < length(Temp) then if Temp[j] = '1' then s1 := ' selected';
         i := length(s);
         if i <> 0 then sv := sv + '<option value="'+s+'"'+s1+'>'+s+'</option>';
      until i = 0;
   end;


   if (length(sv) + length(ChildRender)) > 0 then
   begin
      Result := Result + '>' + ChildRender + sv + '</'+Tag+'>';
   end else begin
      if ItemType = 2 then Result := Result + '></'+Tag+'>' //Div must have end to be used like Box
                      else Result := Result + '/>';
   end;


   for  i := 1 to  ForceNewLine do Result := Result + '<br>';
end;




//------------------------------------------------------------------------------
function    BTHTMLdynItem._MyTextFormater(const the_txt:string; useParag:boolean=false; TableBld:boolean=false):string;
var s,par,tmp,st,s1:string;
    i,j,acumolator,cmd,touch,col,k,m:longword;
    incmd,havestyle,bb,ii,uu,rst,parag,row:boolean;
    c:char;

    procedure _ClearPar(var a:string);
    begin
       if not TableBld then a := 'margin:0em;';
    end;

    procedure _ResetTStyle;
    begin
       if bb then begin s := s + '</b>'; bb := false; end;
       if ii then begin s := s + '</i>'; ii := false; end;
       if uu then begin s := s + '</u>'; uu := false; end;
    end;

    procedure _CloseRow;
    begin
       if row then
       begin
          Result := Result + '</tr>';
          row := false;
          s := '';
       end;
    end;
    procedure _CloseCol;
    begin
       if col = 2 then
       begin
          Result := Result + s + '</td>';
          s := '';
          col := 0;
          st := '';
          par := '';
       end;
    end;

begin
   Result := '';
   j := length(The_txt);
   if j > 0  then
   begin
      //init
      row := false;
      col := 0;
      bb := false;
      ii := false;
      uu := false;
      rst := false;
      touch := 0;
      s := '';
      st := '';
      _ClearPar(par);
      incmd := false;
      cmd := 0;
      acumolator := 0;
      havestyle := false;
      parag := false;
      tmp := '';

      for i := 1 to j do // char by char
      begin
         c := The_txt[i];
         if incmd then
         begin
            if acumolator > 0  then
            begin
               if c <> '*' then tmp := tmp + c;
               if (acumolator = 1) or (c = '*') then
               begin
                  st := '';
                  case cmd of
                     1 : st := st + ' color:#'+tmp+';';
                     2 : st := st + ' font-size:'+tmp+'px;';
                     3 : par := par + _HorAlign(ToVal(tmp));
                     4 : st := st + ' font-family:'+tmp+';';
                     5 : st := st + ' background-color:#'+tmp+';';
                     6 : par := par + ' text-indent:'+tmp+'px;';
                     7 : par := par + ' height:'+tmp+'px;';
                     8 : par := par + _VerAlign(ToVal(tmp)); // not working ??????? :(
                     9 : par := par + ' line-height:'+tmp+';';  //real value form font size 1.5 or 0.8 ...
                    10 : par := par + ' letter-spacing:'+tmp+'px;';  //5px -2px or negative
                    11 : par := par + ' width:'+tmp+'px;';
                    12 : par := par + ' height:'+tmp+'%;';
                    13 : par := par + ' width:'+tmp+'%;';
                    14 : begin   // Table TR TC TD
                           _CloseCol;
                           if c = 'R' then
                           begin
                              _CloseRow;
                           end;
                           if c = 'C' then
                           begin
                              if not row then
                              begin
                                 if length(par) > 0 then Result := Result + '<tr style="'+par+'">'
                                                    else Result := Result + '<tr>';
                                 s := '';
                                 st := '';
                                 par := '';
                                 row := true;
                              end;
                              col := 1;
                           end;
                           if c = 'D' then
                           begin
                              if col = 1 then
                              begin
                                 if length(par) > 0 then Result := Result + '<td style="'+par+'">'
                                                    else Result := Result + '<td>';
                                 s := '';
                                 st := '';
                                 par := '';
                                 col := 2;
                              end;
                           end;
                        end;

                     15 : begin
                           m := 0;
                           k := length(tmp);

                           if k >= 8 then
                           begin
                              if k > 8 then
                              begin
                                 s1 := midstr(tmp,9,k - 8);
                                 tmp := midstr(tmp,1,8);
                                 if pos('T',s1) <> 0 then m := m or 1;
                                 if pos('B',s1) <> 0 then m := m or 2;
                                 if pos('R',s1) <> 0 then m := m or 4;
                                 if pos('L',s1) <> 0 then m := m or 8;
                              end;
                              par := par + _BorderStyle(m,ToVal(MidStr(tmp,2,1)),ToVal(MidStr(tmp,1,1)),HexVal(midstr(tmp,3,6)));
                           end;
                        end;
                  end;
                  if TableBld then Par := Par + st;
                  if not TableBld then havestyle := true;
                  tmp := '';
                  acumolator := 0;
                  incmd := false;
                  continue;
               end;
               dec(acumolator);
               continue;
            end;


            if c = escchar then begin Parag := false; s := s + c; incmd := false; end;

            if c = 'C' then begin cmd := 1; touch := touch or 1; acumolator := 6; end;// color CFFFFFF
            if c = 'S' then begin cmd := 2; touch := touch or 2; acumolator := $FFFF; end; //Fontsize S12*  *-end of not constant acumolator
            if c = 'A' then begin cmd := 3; touch := touch or 4; acumolator := 1; end;// text align
            if c = 'F' then begin cmd := 4; touch := touch or 8; acumolator := $FFFF; end; //Font name FArial.
            if c = 'G' then begin cmd := 5; touch := touch or 16; acumolator := 6; end;// background color GFFFFFF
            if c = 'R' then begin rst := true; incmd := false; end; //Reset to default
            if c = 'D' then begin cmd := 6; touch := touch or 32; acumolator := $FFFF; end; //text indent
            if c = 'H' then begin cmd := 7; touch := touch or 64; acumolator := $FFFF; end; //Height
            if c = 'h' then begin cmd := 12; touch := touch or 64; acumolator := $FFFF; end; //Height
            if c = 'V' then begin cmd := 8; touch := touch or 128; acumolator := 1; end;// vertical align
            if c = 'L' then begin cmd := 9; touch := touch or 256; acumolator := $FFFF; end;// line height real 0.8 L1.5*
            if c = 'E' then begin cmd := 10; touch := touch or 512; acumolator := $FFFF; end; // later spacing -2* 5*
            if c = 'W' then begin cmd := 11; touch := touch or 1024; acumolator := $FFFF; end; //Width
            if c = 'w' then begin cmd := 13; touch := touch or 1024; acumolator := $FFFF; end; //Width
            if c = 'M' then begin cmd := 15; acumolator := $FFFF; end; //border
            // table

            if TableBld then
            begin
                if c = 'T' then begin cmd := 14; acumolator := 1; end;  //TR TC  TD
                // in TD posible C S F G

            end;

            if c = 'B' then begin s := s + '<b>';  incmd := false; bb := true;  end;  //bold
            if c = 'b' then begin s := s + '</b>'; incmd := false; bb := false; end;
            if c = 'I' then begin s := s + '<i>';  incmd := false; ii := true;  end; //italic
            if c = 'i' then begin s := s + '</i>'; incmd := false; ii := false; end;
            if c = 'U' then begin s := s + '<u>';  incmd := false; uu := true;  end;  //underline
            if c = 'u' then begin s := s + '</u>'; incmd := false; uu := false; end;
            if c = 'N' then begin s := s + '<br>'; incmd := false; end; //new line
            if c = 'P' then begin
                if UseParag then Result := Result + '<p style="'+par+'">'+s+'</p>'
                            else Result := Result + s;
                s := '';
                _ClearPar(par);
                parag := true;
                incmd := false;
                rst := true;
            end;

         end else begin
            // not cmd regulat char
            if c = escchar then
            begin
               incmd := true
            end else begin
               if havestyle then
               begin
                  if rst then
                  begin //Reset to default
                     _ResetTStyle;
                     _ClearPar(par);
                     if touch <> 0 then
                     begin


                     end;
                     rst := false;
                  end;
                  s := s + '<span style="'+st+'"/>';
                  havestyle := false;
                  st := '';
               end;
               Parag := false;
               s := s + c; //default adder
            end;
         end;
      end;
      if not parag then if UseParag then s := '<p style="'+par+'">'+s+'</p>';
      _CloseCol;
      _CloseRow;
      _ResetTStyle;
      Result := Result + s;
   end;
end;

//------------------------------------------------------------------------------
function    BTHTMLdynItem.Load(const  data:ansistring):longint;
begin
   Result := -1;
end;

//------------------------------------------------------------------------------
function    BTHTMLdynItem.Save:ansistring;
var s:string;
begin
   s := 'BDHI|'+ToStr(ItemType);
   Result := ansistring(s);
end;

//------------------------------------------------------------------------------
function    BTHTMLdynItem.SetPosition(Xpos,Ypos:longint; Absolute_Pos :boolean = true):BTHTMLdynItem;
begin
   X := Xpos;
   Y := Ypos;
   AbsolutePos := Absolute_Pos;
   Result := self;
end;

//------------------------------------------------------------------------------
function    BTHTMLdynItem.SetPositionRight(Xpos:longint; Absolute_Pos :boolean = true):BTHTMLdynItem;
begin
   Xright := Xpos;
   AbsolutePos := Absolute_Pos;
   Result := self;
end;

//------------------------------------------------------------------------------
function    BTHTMLdynItem.SetPositionBottom(Ypos:longint; Absolute_Pos :boolean = true):BTHTMLdynItem;
begin
   Ybottom := Ypos;
   AbsolutePos := Absolute_Pos;
   Result := self;
end;

//------------------------------------------------------------------------------
function    BTHTMLdynItem.SetSize(Xlng,Ylng:longword):BTHTMLdynItem;
begin
   Width := Xlng;
   if Width > 0 then WidthPercent := false;
   Height := Ylng;
   if Height > 0 then HeightPercent := false;
   Result := self;
end;

//------------------------------------------------------------------------------
function    BTHTMLdynItem.SetSizePercent(Xlng,Ylng:longword):BTHTMLdynItem;
begin
   Width := Xlng;
   if Width > 0 then WidthPercent := true;
   Height := Ylng;
   if Height > 0 then HeightPercent := true;
   Result := self;
end;

//------------------------------------------------------------------------------
function    BTHTMLdynItem.SetBorder(On_Off:boolean; Style,Size,Color:longword):BTHTMLdynItem;
begin
   Border := On_Off;
   BorderStyle := Style;
   BorderSize := Size;
   BorderColor := Color;
   Result := self;
end;

//------------------------------------------------------------------------------
function    BTHTMLdynItem.SetMargin(Left,Right,Top,Bottom:longword):BTHTMLdynItem;
begin
   marginLeft := left;
   marginRight := right;
   marginTop := top;
   marginBottom := bottom;
   Result := self;
end;

//------------------------------------------------------------------------------
function    BTHTMLdynItem.SetBackgroundColor(On_Off:boolean; Color:longword):BTHTMLdynItem;
begin
   UseBkgColor := On_Off;
   BkgColor := Color;
   Result := self;
end;

//------------------------------------------------------------------------------
function    BTHTMLdynItem.SetText(const the_text:string):BTHTMLdynItem;
begin
   Txt := the_text;
   Result := self;
end;

//------------------------------------------------------------------------------
function    BTHTMLdynItem.SetColor(The_Color:longword):BTHTMLdynItem;
begin
   Color := The_Color;
   Result := self;
end;

//------------------------------------------------------------------------------
function    BTHTMLdynItem.SetCenter(Horizontal,Vertical:boolean):BTHTMLdynItem;
begin
   CenterVer := Vertical;
   CenterHor := Horizontal;
   Result := self;
end;

//------------------------------------------------------------------------------
function    BTHTMLdynItem.SetParentID(const ID:string):BTHTMLdynItem;
begin
   ParentID := ID;
   Result := self;
end;

//------------------------------------------------------------------------------
function    BTHTMLdynItem.SetOnClick(const Script:string):BTHTMLdynItem;
begin

   Result := self;
end;

//==============================================================================
//------------------------------------------------------------------------------
function  ImageToEmbedSrc(const File_name:string):string;
var sa:ansistring;
begin
   Result := '';
   if FileLoad(File_name,sa) then
   begin
      Result := 'data:image/'+ ExtractFileExt(File_name) + ';base64,';
      Result := Result + string(BCodeBase64(sa));
   end;
end;

end.
