unit NBFlatWinCtrl;

interface

uses NBFlatWin;



function  InitWindowCtrl:longword;

function  AddButton(Xpos,Ypos,Xlng,Ylng:longword; BtnName: string; BtnProc:pointer):longword;
function  AddLabel(Xpos,Ypos,Xlng,Ylng:longword; BtnName: string):longword;
function  AddCheckBox(Xpos,Ypos,Xlng,Ylng:longword; BtnName: string; BoolPtr:pointer; InitValue:boolean):longword;
function  AddEditBox(Xpos,Ypos,Xlng,Ylng:longword; aText:pointer):longword;


procedure Ctrl_SetText(Hand:longword; NewText: string);


implementation

uses Windows,Messages;

var EnterCtrl :longword;
    wnd :longword;
    oldwndp:longword;

function _WindowProc(aWindow: HWnd; AMessage: UINT; aWParam : WPARAM;
                    aLParam: LPARAM): LRESULT; stdcall;

var res:longint;
    obj:longword;
    id,n:longword;
    apt:longword;
    pr : procedure;
    bo : ^boolean;
    papa:longword;
    s:string;
    so:^string;
begin
   res := 0;

   papa := GetProp(aWindow,'fw_ctrlpapa');

   case aMessage of
   WM_COMMAND:
      begin
         id := aWParam and $FF;
         apt := 0;
         if aLParam <> 0 then apt := GetProp(alParam,'fw_cbf1');
         case id of
           1: begin//Button///////////////////////////////////
                 if apt <> 0 then
                 begin
                    pr := pointer(apt);
                    pr; //call procedure of button
                 end;
              end;
           3: begin//CheckBox/////////////////////////////////
                 if apt <> 0 then
                 begin
                    bo := pointer(apt);
                    if (SendMessage(alParam, BM_GETCHECK, 0, 0) = BST_CHECKED )
                    then bo^ := true else bo^ := false;
                 end;
              end;
           4: begin//EditBox//////////////////////////////////
                 if apt <> 0 then
                 begin
                    so := pointer(apt);
                    case HiWord(aWParam) of
                       en_change:
                       begin
                          n:=GetWindowTextLength(alParam);
                          SetLength(s,n+1);
                          GetWindowText(alParam,pansichar(@s[1]),n+1);
                          string(so^) := pansichar(@s[1]);
                       end;
                    end;
                 end;
              end;
         end;
         if id <> 4 then SetFocus(papa);

      end;

   end;

   if res = 0 then
   begin
       obj := GetProp(aWindow,'fw_ctrlwinp');
       if obj <> 0 then res := CallWindowProc(pointer(Obj), aWindow, AMessage, aWParam, aLParam)
                   else res := DefWindowProc(aWindow, AMessage, aWParam, aLParam);
   end;
   _WindowProc := res;

end;


function InitWindowCtrl:longword;
begin
   wnd := GetWindowHandle;
   oldwndp := GetWindowLong(wnd,GWL_WNDPROC);  // change wnd proc
   SetProp(wnd,'fw_ctrlwinp',oldwndp);
   SetProp(wnd,'fw_ctrlpapa',wnd);
   SetWindowLong(wnd,GWL_WNDPROC,dword(@_WindowProc));
   EnterCtrl := 1;
   InitWindowCtrl := 1;
end;

//------------------------------------------------------------------------------
function _DoCtrl(CtrlType:string; CtrlFlag,CtrlID:longword; Xpos,Ypos,Xlng,Ylng:longword; CtrlName: string; CallbK:longword):longword;
var res:longword;
begin
   CtrlType := CtrlType + #0;
   CtrlName := CtrlName + #0;
   res := CreateWindowEx(0,
                   PCHAR(CtrlType),
                   PCHAR(CtrlName),
                   WS_CHILD or WS_VISIBLE or CtrlFlag,
                   Xpos, Ypos,
                   Xlng, Ylng,
                   wnd,
                   hmenu(CtrlID),
                   0,nil);
   if res <> 0 then
   begin
      if CallBk <> 0 then SetProp(res,'fw_cbf1',CallBk);  // set call back value
      SetFocus(wnd);
   end;
   _DoCtrl := res;
end;

//------------------------------------------------------------------------------
function AddButton(Xpos,Ypos,Xlng,Ylng:longword; BtnName: string; BtnProc:pointer):longword;
begin
   if EnterCtrl = 0 then begin AddButton := 0; Exit; end;
   AddButton := _DoCtrl('Button',BS_PUSHBUTTON,1,Xpos,Ypos,Xlng,Ylng,BtnName,longword(BtnProc));
end;

//------------------------------------------------------------------------------
function AddLabel(Xpos,Ypos,Xlng,Ylng:longword; BtnName: string):longword;
begin
   if EnterCtrl = 0 then begin AddLabel := 0; Exit; end;
   AddLabel := _DoCtrl('Static',SS_LEFT,2,Xpos,Ypos,Xlng,Ylng,BtnName,0);
end;

//------------------------------------------------------------------------------
function AddCheckBox(Xpos,Ypos,Xlng,Ylng:longword; BtnName: string; BoolPtr:pointer; InitValue:boolean):longword;
var res:longword;
begin
   if EnterCtrl = 0 then begin AddCheckBox := 0; Exit; end;
   res := _DoCtrl('Button',BS_AUTOCHECKBOX,3,Xpos,Ypos,Xlng,Ylng,BtnName,longword(BoolPtr));
   if res <> 0 then
   begin
     if InitValue then SendMessage(res,BM_SETCHECK,BST_CHECKED,0);
     if BoolPtr <> nil then boolean(BoolPtr^) := InitValue;
   end;
   AddCheckBox := res;
end;

//------------------------------------------------------------------------------
function  AddEditBox(Xpos,Ypos,Xlng,Ylng:longword; aText:pointer):longword;
var Txt:string;
begin
   if EnterCtrl = 0 then begin AddEditBox := 0; Exit; end;
   Txt := string(aText^);
   AddEditBox := _DoCtrl('edit',WS_CHILD or ES_AUTOHSCROLL or ES_LEFT or WS_BORDER,4,Xpos,Ypos,Xlng,Ylng,Txt,longword(aText));

end;





//------------------------------------------------------------------------------
procedure Ctrl_SetText(Hand:longword; NewText: string);
begin
   if EnterCtrl = 0 then Exit;
   NewText := NewText + #0;
   SetWindowText(Hand,pchar(NewText));
   InvalidateRect(Wnd,nil,true);
   UpdateWindow(Wnd);
end;


begin
   EnterCtrl := 0;
end.
