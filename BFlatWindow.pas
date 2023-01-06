unit BFlatWindow;

interface

function  EnterWindows:longint;
procedure LeaveWindows;

procedure SetWindowCaption(Caption:pchar);
procedure SetWindowPosition(Xpos,Ypos:longint);
procedure GetWindowPosition(var Xpos,Ypos:longint);
procedure SetWindowSize(Xlng,Ylng:longint);
procedure SetWindowClientSize(Width,Height:longint);
procedure GetWindowClientSize(var Width,Height:longint);
procedure SetWindowMaximaze(how:longword);
procedure SetWindowBorder(Border:longword);
procedure SetWindowCursor(Cursor:longword);
procedure SetWindowIcon(Icon:longword);
procedure SetWindowBackground(BK:longword);
function  GetScreenXlng:longword;
function  GetScreenYlng:longword;
function  GetScreenBPP:longword;
procedure RePaintWindow;
function  GetWindowDC:longword;
function  GetWindowHandle:longword;
procedure SetWindowEvent(Eventnum,Eventptr,UserParam:longword);

function  Mouse_GetXpos:longword;
function  Mouse_GetYpos:longword;
function  Mouse_GetButtons:longword;
procedure Mouse_Get(var Buttons,Xpos,Ypos:longword);
procedure Mouse_GetDiff(var Xdif,Ydif:longint);
procedure Mouse_SetPosition(Xpos,Ypos:longword);
function  TestKey(akey:longword):boolean;
function  KeyPressed:boolean;
function  GetKey:word;
procedure FlushKeys;
function  WaitKeyGet:word;
procedure WaitKey;
function  KeyHit(VK:longword):longword;

procedure GDI_DrawPicBuffer(Xpos,Ypos,Xlng,Ylng,Bpp,SXlng,SYlng,SrcPtr:longword);





function  AddImage(Xpos,Ypos,Xlng,Ylng:longword; FileName: string; BtnProc:pointer; UserParam:longword):longword;
function  AddButton(Xpos,Ypos,Xlng,Ylng:longword; BtnName: string; BtnProc:pointer; UserParam:longword):longword;
function  AddLabel(Xpos,Ypos,Xlng,Ylng:longword; BtnName: string):longword;
function  AddCheckBox(Xpos,Ypos,Xlng,Ylng:longword; BtnName: string; BoolPtr:pointer; InitValue:boolean):longword;
function  AddEditBox(Xpos,Ypos,Xlng,Ylng:longword; aText:pointer):longword;

procedure Ctrl_SetText(Hand:longword; NewText: string);
procedure Ctrl_Enable(Hand:longword; Enabled: boolean);




implementation

uses BFlatWinObj;


var FW : BTFlatWinObj;


function  EnterWindows:longint;
begin
   FW := BTFlatWinObj.Create(0);
   Result := FW.GetLastError;
end;

procedure LeaveWindows;
begin
   if assigned(FW) then FW.Free;
end;

procedure SetWindowCaption(Caption:pchar);
begin
   if assigned(FW) then FW.SetWindowCaption(Caption);
end;

procedure SetWindowPosition(Xpos,Ypos:longint);
begin
   if assigned(FW) then FW.SetWindowPosition(Xpos,Ypos);
end;

procedure GetWindowPosition(var Xpos,Ypos:longint);
begin
   if assigned(FW) then FW.GetWindowPosition(Xpos,Ypos);
end;

procedure SetWindowSize(Xlng,Ylng:longint);
begin
   if assigned(FW) then FW.SetWindowSize(Xlng,Ylng);
end;

procedure SetWindowClientSize(Width,Height:longint);
begin
   if assigned(FW) then FW.SetWindowClientSize(Width,Height);
end;

procedure GetWindowClientSize(var Width,Height:longint);
begin
   Width := 0;
   Height := 0;
   if assigned(FW) then FW.GetWindowClientSize(Width,Height);
end;

procedure SetWindowMaximaze(how:longword);
begin
   if assigned(FW) then FW.SetWindowMaximaze(how);
end;

procedure SetWindowBorder(Border:longword);
begin
   if assigned(FW) then FW.SetWindowBorder(Border);
end;

procedure SetWindowCursor(Cursor:longword);
begin
   if assigned(FW) then FW.SetWindowCursor(Cursor);
end;

procedure SetWindowIcon(Icon:longword);
begin
   if assigned(FW) then FW.SetWindowIcon(Icon);
end;

procedure SetWindowBackground(BK:longword);
begin
   if assigned(FW) then FW.SetWindowBackground(BK);
end;

function  GetScreenXlng:longword;
begin
   Result := 0;
   if assigned(FW) then Result := FW.GetScreenXlng;
end;

function  GetScreenYlng:longword;
begin
   Result := 0;
   if assigned(FW) then Result := FW.GetScreenYlng;
end;

function  GetScreenBPP:longword;
begin
   Result := 0;
   if assigned(FW) then Result := FW.GetScreenBPP;
end;

procedure RePaintWindow;
begin
   if assigned(FW) then FW.RePaintWindow;
end;

function  GetWindowDC:longword;
begin
   Result := 0;
   if assigned(FW) then Result := FW.GetWindowDC;
end;

function  GetWindowHandle:longword;
begin
   Result := 0;
   if assigned(FW) then Result := FW.GetWindowHandle;
end;


procedure SetWindowEvent(Eventnum,Eventptr,UserParam:longword);
begin
   if assigned(FW) then FW.SetWindowEvent(Eventnum,Eventptr,UserParam);
end;

function  Mouse_GetXpos:longword;
begin
   Result := 0;
   if assigned(FW) then Result := FW.Mouse_GetXpos;
end;

function  Mouse_GetYpos:longword;
begin
   Result := 0;
   if assigned(FW) then Result := FW.Mouse_GetYpos;
end;

function  Mouse_GetButtons:longword;
begin
   Result := 0;
   if assigned(FW) then Result := FW.Mouse_GetButtons;
end;

procedure Mouse_Get(var Buttons,Xpos,Ypos:longword);
begin
   Buttons := 0;
   Xpos := 0;
   Ypos := 0;
   if assigned(FW) then FW.Mouse_Get(Buttons,Xpos,Ypos);
end;

procedure Mouse_GetDiff(var Xdif,Ydif:longint);
begin
   Xdif := 0;
   Ydif := 0;
   if assigned(FW) then FW.Mouse_GetDiff(Xdif,Ydif);
end;

procedure Mouse_SetPosition(Xpos,Ypos:longword);
begin
   if assigned(FW) then FW.Mouse_SetPosition(Xpos,Ypos);
end;

function  TestKey(akey:longword):boolean;
begin
   Result := false;
   if assigned(FW) then Result := FW.TestKey(akey);
end;

function  KeyPressed:boolean;
begin
   result := false;
   if assigned(FW) then Result := FW.KeyPressed;
end;

function  GetKey:word;
begin
   Result := 0;
   if assigned(FW) then Result := word(FW.GetKey);
end;

procedure FlushKeys;
begin
   if assigned(FW) then FW.FlushKeys;
end;

function  WaitKeyGet:word;
begin
   Result := 0;
   if assigned(FW) then Result := word(FW.WaitKeyGet);
end;

procedure WaitKey;
begin
   if assigned(FW) then FW.WaitKey;
end;

function  KeyHit(VK:longword):longword;
begin
   Result := 0;
   if assigned(FW) then Result := FW.KeyHit(VK);
end;

procedure GDI_DrawPicBuffer(Xpos,Ypos,Xlng,Ylng,Bpp,SXlng,SYlng,SrcPtr:longword);
begin
   if assigned(FW) then FW.GDI_DrawPicBuffer(Xpos,Ypos,Xlng,Ylng,Bpp,SXlng,SYlng,SrcPtr);
end;



{
function  InitWindowCtrl:longword;  //back competabilyty
begin
   Result := 0;
end;
 }

function  AddImage(Xpos,Ypos,Xlng,Ylng:longword; FileName: string; BtnProc:pointer; UserParam:longword):longword;
begin
   Result := 0;
   if assigned(FW) then Result := FW.AddImage(Xpos,Ypos,Xlng,Ylng,FileName,BtnProc,UserParam);
end;

function  AddButton(Xpos,Ypos,Xlng,Ylng:longword; BtnName: string; BtnProc:pointer; UserParam:longword):longword;
begin
   Result := 0;
   if assigned(FW) then Result := FW.AddButton(Xpos,Ypos,Xlng,Ylng,BtnName,BtnProc,UserParam);
end;

function  AddLabel(Xpos,Ypos,Xlng,Ylng:longword; BtnName: string):longword;
begin
   Result := 0;
   if assigned(FW) then Result := FW.AddLabel(Xpos,Ypos,Xlng,Ylng,BtnName);
end;

function  AddCheckBox(Xpos,Ypos,Xlng,Ylng:longword; BtnName: string; BoolPtr:pointer; InitValue:boolean):longword;
begin
   Result := 0;
   if assigned(FW) then Result := FW.AddCheckBox(Xpos,Ypos,Xlng,Ylng,BtnName,BoolPtr,InitValue);
end;

function  AddEditBox(Xpos,Ypos,Xlng,Ylng:longword; aText:pointer):longword;
begin
   Result := 0;
   if assigned(FW) then Result := FW.AddEditBox(Xpos,Ypos,Xlng,Ylng,aText);
end;


procedure Ctrl_SetText(Hand:longword; NewText: string);
begin
   if assigned(FW) then FW.Control_SetText(Hand,NewText);
end;

procedure Ctrl_Enable(Hand:longword; Enabled: boolean);
begin
   if assigned(FW) then FW.Control_Enabled(Hand,Enabled);
end;


end.
