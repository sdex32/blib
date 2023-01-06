unit BMicroDX;
{ Demo FrameWork for Software Draw on D3D  in  32 bit RGB }
{ ! WARNING !  only full screen mode :(   }


{ $ DEFINE USED3D9}
interface


procedure MicroDX(Xres,Yres:longword; cb : pointer );

(* Programers GUIDE ------------------------------------------------------------

 How to use

program test_microDX;

uses
  Windows,
  BMicroDX;

{$R *.res}

function DrawFrame(a,Source,pitch:longword):longword; stdcall;
var i,j,c:longword;
begin
   for i:= 0 to 639 do // Clear screen
   for j:= 0 to 479 do
   begin
     c := Source + j*Pitch + i*4;
     longword(pointer(c)^) := $00;
   end;

   for i:= 1 to 200 do
   begin
     c := Source + i*Pitch + i*4;
     longword(pointer(c)^) := $FF00FF;

   end;
   //------------------------------------------------------- exit control
   DrawFrame := GetAsyncKeyState(VK_ESCAPE);
end;

begin
  MicroDX(640,480,@DrawFrame);
end.

*)


implementation /////////////////////////////////////////////////////////////////


//uses Windows;
type Dword = longword;
const
   WS_POPUP = DWORD($80000000);
   WS_BORDER = $800000;
   WS_SYSMENU = $80000;
   WS_POPUPWINDOW = (WS_POPUP or WS_BORDER or WS_SYSMENU);
function CreateWindowEx(dwExStyle: DWORD; lpClassName: PChar;
  lpWindowName: PChar; dwStyle: DWORD; X, Y, nWidth, nHeight: Integer;
  hWndParent: DWORD; hMenu: DWORD; hInstance: DWORD; lpParam: Pointer): DWORD;
  stdcall; external 'user32.dll' name 'CreateWindowExA';
function ShowCursor(bShow: boolean): Integer; stdcall;  external 'user32.dll' name 'ShowCursor';
{the end of my Windows.pas}

{$IFNDEF USED3D9}


function _Direct3DCreate8(a: LongWord): longword; stdcall; external 'd3d8.dll' name 'Direct3DCreate8';

procedure MicroDX(Xres,Yres:longword; cb : pointer );
var d3d,d3,bb:longword;
    awnd,i,done: longword;
    devparam : array [ 0..12 ] of longword;
    LockedRect : array [0..1] of longword; // 0-pitch 1-addres
    CreateDev :function(a,b,c,d,e,f,g:longword):longword; stdcall;   //15 from D3D
    GetBackBuffer :function(a,b,c,d:longword):longword; stdcall;   //16 from Device
    LockRect :function(a,b,c,d:longword):longword; stdcall;  //9 from surface
    UnLockRect :function(a:longword):longword; stdcall;      //10 from surface
    Present :function(a,b,c,d,e:longword):longword; stdcall;      //15 from Device  DO NOT CARE RET CODE
    CallBackProc :function(h_wnd,Screen,Pitch:longword): longword; stdcall; //
begin
    CallBackProc := cb;

    awnd := CreateWindowEx(0,'Edit',nil,WS_POPUPWINDOW,0,0,0,0,0,0,0,nil);
//Windowed    awnd := CreateWindowEx(0,'Edit',nil,WS_POPUPWINDOW,10,10,Xres,Yres,0,0,0,nil);
    ShowCursor(false);
//Windowed ShowWindow(aWnd, SW_SHOW);
    d3d := _Direct3DCreate8(220);
    CreateDev := pointer(pointer(longword(pointer(d3d)^)+15*4)^);
    d3 := 0;
    for i:= 0 to 12 do devparam[i] := 0;
    // 7 set to 1 to windowed mode for DEBUG
 devparam[7] := 1;
    devparam[0] := Xres;
    devparam[1] := Yres;
    devparam[2] := 22; //21=argb 22=xrgb
    devparam[5] := 2;  // swap effect flip
    devparam[6] := awnd;
    devparam[10] := 1; // lockable back surface

    CreateDev(d3d,0,1,awnd,$20,longword(@devparam),longword(@d3));

    GetBackBuffer := pointer(pointer(  longword(   (pointer(d3)^)  )+16*4)^);
    Present := pointer(pointer(  longword(   (pointer(d3)^)  )+15*4)^);
    GetBackBuffer(d3,0,0,longword(@bb));

    LockRect := pointer(pointer(  longword(   (pointer(bb)^)  )+9*4)^);
    UnLockRect := pointer(pointer(  longword(   (pointer(bb)^)  )+10*4)^);
    done := 0;
    repeat
       if LockRect(bb,longword(@LockedRect),0,0) = 0 then
       begin
          done := CallBackProc(awnd,LockedRect[1],LockedRect[0]);
          UnLockRect(bb);
          Present(d3,0,0,0,0);
       end;
   until done <> 0; //(GetAsyncKeyState(VK_ESCAPE) <> 0)
end;

{$ELSE}

function _Direct3DCreate9(a: LongWord): longword; stdcall; external 'd3d9.dll' name 'Direct3DCreate9';

procedure MicroDX(Xres,Yres:longword; cb : pointer );
var d3d,d3,bb:longword;
    awnd,i,done: longword;
    j:longint;
    devparam : array [ 0..13 ] of longword;
    LockedRect : array [0..1] of longword; // 0-pitch 1-addres
    CreateDev :function(a,b,c,d,e,f,g:longword):longword; stdcall;
    GetBackBuffer :function(a,b,c,d,e:longword):longword; stdcall;
    LockRect :function(a,b,c,d:longword):longword; stdcall;
    UnLockRect :function(a:longword):longword; stdcall;
    Present :function(a,b,c,d,e:longword):longword; stdcall;
    CallBackProc :function(h_wnd,Screen,Pitch:longword): longword; stdcall; //
begin
    CallBackProc := cb;

    awnd := CreateWindowEx(0,'Edit',nil,WS_POPUPWINDOW,0,0,0,0,0,0,0,nil);
//Windowed    awnd := CreateWindowEx(0,'Edit',nil,WS_POPUPWINDOW,10,10,Xres,Yres,0,0,0,nil);
    ShowCursor(false);
//Windowed    ShowWindow(aWnd, SW_SHOW);
    d3d := _Direct3DCreate9(32 or $80000000);
    CreateDev := pointer(pointer(longword(pointer(d3d)^)+16*4)^);
    d3 := 0;
    for i:= 0 to 13 do devparam[i] := 0;
    // 7 set to 1 to windowed mode for DEBUG
//Windowed
//devparam[8] := 1;
    devparam[0] := Xres;
    devparam[1] := Yres;
    devparam[2] := 22; //21=argb 22=xrgb
    devparam[6] := 2; // swap effect flip
    devparam[7] := awnd;
    devparam[11] := 1; // lockable backbuffer

    CreateDev(d3d,0,1,awnd,$20,longword(@devparam),longword(@d3));

    GetBackBuffer := pointer(pointer(  longword(   (pointer(d3)^)  )+18*4)^);
    Present := pointer(pointer(  longword(   (pointer(d3)^)  )+17*4)^);
    GetBackBuffer(d3,0,0,0,longword(@bb));

    LockRect := pointer(pointer(  longword(   (pointer(bb)^)  )+5*4)^);
    UnLockRect := pointer(pointer(  longword(   (pointer(bb)^)  )+6*4)^);
    done := 0;
    repeat
       j := LockRect(bb,longword(@LockedRect),0,0);
       if j = 0 then
       begin
          done := CallBackProc(awnd,LockedRect[1],LockedRect[0]);
          UnLockRect(bb);
          Present(d3,0,0,0,0);
       end;
   until done <> 0; //(GetAsyncKeyState(VK_ESCAPE) <> 0)
end;
{$ENDIF}

end.
