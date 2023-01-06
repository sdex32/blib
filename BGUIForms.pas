unit BGUIForms;

interface

uses BGUICore;


const
   GFT_WINDOW         = 0; //common
   GFT_BUTTON         = 1;
   GFT_LABEL          = 2;
   GFT_CHECKBOX       = 3;
   GFT_RADIOBOX       = 4;
   GFT_EDITBOX        = 5;
   GFT_LISTBOX        = 6;
   GFT_DROPDAWN       = 7;
   GFT_MEMO           = 8;
   GFT_SCROLLBARV     = 9;
   GFT_SCROLLBARH     = 10;
   GFT_SHAPE          = 11;





//procedure   RegisterGUIForms(core :BTGUIcore; DrawCtx:pointer);



implementation


const FrameBorder_size = 1;
      FrameTitle_Size = 8 + FrameBorder_size;

//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
function    draw_WINDOW(id,win,a,b:longword):longword; stdcall;
var DrawCtx:pointer;
    DrawWin:PBTGUI_Object;
begin
   DrawWin := PBTGUI_Object(win);
//   DrawCtx := DrawWin.DrawCtx;

   Result := 0;
   case id of
     DRF_GETCXPOS : Result := FrameBorder_size;  // return client area
     DRF_GETCYPOS : Result := FrameTitle_size;   // recalc by  Frame dimentions
     DRF_GETCXLNG : Result := DrawWin.Xlng - (FrameBorder_size * 2);
     DRF_GETCYLNG : Result := DrawWin.Ylng - (FrameBorder_size + FrameTitle_size);
   end;
end;

//------------------------------------------------------------------------------
function    proc_WINDOW(winID,msg,p1,p2:longword):longword; stdcall;
begin
   Result := 0;
end;

//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
function    draw_BUTTON(id,win,a,b:longword):longword; stdcall;
var DrawCtx:pointer;
    DrawWin:PBTGUI_Object;
begin
   DrawWin := PBTGUI_Object(win);
//   DrawCtx := DrawWin.DrawCtx;

   Result := 0;
   case id of
     DRF_GETCXPOS : Result := 0;
     DRF_GETCYPOS : Result := 0;
     DRF_GETCXLNG : Result := DrawWin.Xlng;
     DRF_GETCYLNG : Result := DrawWin.Ylng;
   end;
end;

//------------------------------------------------------------------------------
function    proc_BUTTON(winID,msg,p1,p2:longword):longword; stdcall;
begin
   Result := 0;
end;

//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH
function    draw_LABEL(id,win,a,b:longword):longword; stdcall;
var DrawCtx:pointer;
    DrawWin:PBTGUI_Object;
begin
   DrawWin := PBTGUI_Object(win);
//   DrawCtx := DrawWin.DrawCtx;

   Result := 0;
   case id of
     DRF_GETCXPOS : Result := 0;
     DRF_GETCYPOS : Result := 0;
     DRF_GETCXLNG : Result := DrawWin.Xlng;
     DRF_GETCYLNG : Result := DrawWin.Ylng;
   end;
end;

//------------------------------------------------------------------------------
function    proc_LABEL(winID,msg,p1,p2:longword):longword; stdcall;
begin
   Result := 0;
end;



  (*
procedure   RegisterGUIForms(core :BTGUIcore; DrawCtx:pointer);
begin
   core.CreateClass('WINDOW',@Draw_WINDOW,DrawCtx, @Proc_WINDOW);
   core.CreateClass('BUTTON',@Draw_BUTTON,DrawCtx, @Proc_BUTTON);
   core.CreateClass('LABEL' ,@Draw_LABEL ,DrawCtx, @Proc_LABEL );
end;
   *)

end.
