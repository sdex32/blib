unit BOpenGLdraw2D;

interface

uses Windows,dglOpenGL;




type  BTGLColor = record

      end;

      BTOpenGLdraw2D = class
         private

            wnd_h :longword;
            wnd_dc :longword;
            glrctx :HGLRC;
            Xlng,Ylng :longword;
            Pen_R,Pen_G,Pen_B,Pen_A :single;
            Brush_R,Brush_G,Brush_B,Brush_A :single;


            procedure   _Resize(X_lng,Y_lng :longword);
         public
            constructor Cretae;
            destructor  Destroy; override;

            function    InitSurface(wnd_hand :longword; X_lng,Y_lng :longword; AntiAlias :boolean = true) :boolean;
            procedure   ResizeSurface( X_lng,Y_lng :longword);

            procedure   BeginRender(clear :boolean = true);
            procedure   FinishRender;

            procedure   SetSysClearColor(r, g, b, a :single); overload;
            procedure   SetSysClearColor(rgba :longword); overload;
            procedure   SetSysClearColor(r, g, b, a :longword); overload;

            procedure   SetColor(r, g, b, a :single); overload;
            procedure   SetColor(rgba :longword); overload;
            procedure   SetColor(r, g, b, a :longword); overload;

            procedure   SetPenColor(r, g, b, a :single); overload;
            procedure   SetPenColor(rgba :longword); overload;
            procedure   SetPenColor(r, g, b, a :longword); overload;

            procedure   SetBrushColor(r, g, b, a :single); overload;
            procedure   SetBrushColor(rgba :longword); overload;
            procedure   SetBrushColor(r, g, b, a :longword); overload;

            procedure   Line(x1, y1, x2, y2: Single);
            procedure   Rectangle(x1, y1, x2, y2: Single);
            procedure   FillRectangle(x1, y1, x2, y2: Single; border:boolean=true);


procedure   Point(x1, y1: single); overload;
procedure   Point(x1, y1: longint); overload;
procedure   PointSize(Size: single);
procedure   PointSmooth(Enable: Boolean);


            procedure  Bar(x1, y1, x2, y2 :single);
procedure   DrawBitmap(bmp_hand: longword; bx,by,x, y: longint); //;  xZoom: Single = 1.0; yZoom: Single = 1.0);
procedure BuildTexture(bmp_hand,bx,by:longword; var texId: GLuint); // Creates Texture From A Bitmap File
procedure DeleteTexture(texId: GLuint);
procedure DrawBitmapa(bmp_hand,bx,by: longword; x, y: longint);

      end;


implementation



//------------------------------------------------------------------------------
constructor BTOpenGLdraw2D.Cretae;
begin
   wnd_dc := 0;
   glrctx := 0;

end;

//------------------------------------------------------------------------------
destructor  BTOpenGLdraw2D.Destroy;
begin
   if wnd_dc <> 0  then ReleaseDC(wnd_h,wnd_dc);
   if glrctx <>0  then wglDeleteContext(glrctx);

   inherited;
end;

//------------------------------------------------------------------------------
procedure   BTOpenGLdraw2D._Resize(X_lng,Y_lng:longword);
begin
   Xlng := X_lng;
   Ylng := Y_lng;
   glViewport(0, 0, X_lng, Y_lng);
   glMatrixMode(GL_PROJECTION);
   glLoadIdentity();
   glOrtho (0, X_lng, Y_lng, 0, -100,100 );
   glMatrixMode(GL_MODELVIEW);
   glLoadIdentity;
end;

//------------------------------------------------------------------------------
function    BTOpenGLdraw2D.InitSurface(wnd_hand:longword; X_lng,Y_lng:longword; AntiAlias:boolean = true):boolean;
var
  nPixelFormat: Integer;
  pfd: TPixelFormatDescriptor;
begin
   Result := false; //fail
   wnd_h := wnd_hand;
   wnd_dc := GetDc(wnd_hand);

   FillChar(pfd, SizeOf(pfd), 0);
    // With pfd do begin
   pfd.nVersion := 1;
   pfd.nSize := sizeof(pfd);
   pfd.dwFlags := PFD_DRAW_TO_WINDOW or
                  PFD_SUPPORT_OPENGL or
                  PFD_DOUBLEBUFFER;
   pfd.iPixelType := PFD_TYPE_RGBA;
   pfd.cColorBits := 32;  ///??? 24 or 32
   pfd.cDepthBits := 16;
   pfd.iLayerType := PFD_MAIN_PLANE;
//  if (AAFormat > 0) then
//   nPixelFormat := AAFormat
//  else
   nPixelFormat := ChoosePixelFormat(wnd_dc, @pfd);
   SetPixelFormat(wnd_dc, nPixelFormat, @pfd);

   glrctx := wglCreateContext(wnd_dc);
   ActivateRenderingContext(wnd_dc, glrctx);

//    resize(width,height);
   wglMakeCurrent(wnd_dc,glrctx);
   _Resize(X_lng,Y_lng);


     glDisable(GL_CULL_FACE);
   glDisable(GL_LIGHTING);
   glDisable(GL_FOG);
   glDisable(GL_COLOR_MATERIAL);
   glDisable(GL_DEPTH_TEST);
   glDisable(GL_TEXTURE_1D);
   glDisable(GL_TEXTURE_2D);
   glDisable(GL_TEXTURE_3D);
    glDisable(GL_TEXTURE_CUBE_MAP_ARB);


   glEnable(GL_ALPHA_TEST);
   glEnable(GL_BLEND);
   glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
   glShadeModel(GL_SMOOTH);
// SetTextStyle('Courier New',12);
// DrawFrameCount:=0;
 //glGenFramebuffersEXT(1, @FrameBuffer);
// toFrameBufer:=false;
// VBOSprite:=TVBOSprite.Create;

 //glEnable(GL_MULTISAMPLE_ARB);
   wglMakeCurrent(0, 0);
end;

//------------------------------------------------------------------------------
procedure   BTOpenGLdraw2D.ResizeSurface(X_lng,Y_lng:longword);
begin
   wglMakeCurrent(wnd_dc,glrctx);
   _Resize(X_lng,Y_lng);
   wglMakeCurrent(0, 0);
end;

//------------------------------------------------------------------------------
procedure   BTOpenGLdraw2D.BeginRender(clear :boolean = true);
begin
//QueryPerformanceCounter(StartDrawTime);
   wglMakeCurrent(wnd_dc,glrctx);
   if clear then glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
   glLoadIdentity;
end;

//------------------------------------------------------------------------------
procedure   BTOpenGLdraw2D.FinishRender;
begin
  // VBOSprite.Draw;
   glFlush();
   swapBuffers(wnd_dc);
   wglMakeCurrent(0, 0);
end;

procedure BTOpenGLdraw2D.Bar(x1, y1, x2, y2:single);
begin
   glBegin(GL_QUADS);
   glVertex3d(x1,y1,0);
   glVertex3d(x1,y2,0);
   glVertex3d(x2,y2,0);
   glVertex3d(x2,y1,0);
   glEnd();
end;

//------------------------------------------------------------------------------
procedure   BTOpenGLdraw2D.SetColor(r, g, b, a: single);
begin
   glColor4f(r,g,b,a);
end;

//------------------------------------------------------------------------------
procedure   BTOpenGLdraw2D.SetColor(rgba :longword);
var sr,sg,sb,sa:single;
begin
   sa := ((rgba shr 24) and $FF) / 255;
   sb := ((rgba shr 16) and $FF) / 255;
   sg := ((rgba shr  8) and $FF) / 255;
   sr := ( rgba         and $FF) / 255;
   glColor4f(sr,sg,sb,sa);
end;

//------------------------------------------------------------------------------
procedure   BTOpenGLdraw2D.SetColor(r, g, b, a :longword);
var sr,sg,sb,sa:single;
begin
   sa := (r and $FF) / 255;
   sb := (g and $FF) / 255;
   sg := (b and $FF) / 255;
   sr := (a and $FF) / 255;
   glColor4f(sr,sg,sb,sa);
end;

//------------------------------------------------------------------------------
procedure   BTOpenGLdraw2D.SetSysClearColor(r, g, b, a: single);
begin
   wglMakeCurrent(wnd_dc,glrctx);
   glClearColor(r,g,b,a);
   wglMakeCurrent(0,0);
end;

//------------------------------------------------------------------------------
procedure   BTOpenGLdraw2D.SetSysClearColor(rgba :longword);
begin
   SetSysClearColor(rgba and $FF, (rgba shr 8) and $FF, (rgba shr 16) and $FF, (rgba shr 24) and $FF);
end;

//------------------------------------------------------------------------------
procedure   BTOpenGLdraw2D.SetSysClearColor(r, g, b, a :longword);
begin
   SetSysClearColor((r and $FF)/255, (g and $FF)/255, (b and $FF)/255, (a and $FF)/255);
end;



procedure   BTOpenGLdraw2D.Point(x1, y1: single);
begin
  glBegin(GL_POINTS);
   glVertex3d(x1,y1,0);
  glEnd();
end;

procedure   BTOpenGLdraw2D.Point(x1, y1: longint);
begin
  glBegin(GL_POINTS);
   glVertex3d(x1,y1,0);
  glEnd();
end;

procedure   BTOpenGLdraw2D.PointSize(Size: single);
begin
 glPointSize(Size);
end;
procedure   BTOpenGLdraw2D.PointSmooth(Enable: Boolean);
begin
 If enable then
  glEnable(GL_POINT_SMOOTH)
 else
  glDisable(GL_POINT_SMOOTH);
end;

//------------------------------------------------------------------------------
procedure   BTOpenGLdraw2D.SetPenColor(r, g, b, a :single);
begin
   Pen_R := r;  Pen_G := g;  Pen_B := b;   Pen_A := a;
end;

//------------------------------------------------------------------------------
procedure   BTOpenGLdraw2D.SetPenColor(rgba :longword);
begin
   SetPenColor(rgba and $FF, (rgba shr 8) and $FF, (rgba shr 16) and $FF, (rgba shr 24) and $FF);
end;

//------------------------------------------------------------------------------
procedure   BTOpenGLdraw2D.SetPenColor(r, g, b, a :longword);
begin
   SetPenColor((r and $FF)/255, (g and $FF)/255, (g and $FF)/255, (a and $FF)/255);
end;

//------------------------------------------------------------------------------
procedure   BTOpenGLdraw2D.SetBrushColor(r, g, b, a :single);
begin
   Brush_R := r;  Brush_G := g;  Brush_B := b;   Brush_A := a;
end;

//------------------------------------------------------------------------------
procedure   BTOpenGLdraw2D.SetBrushColor(rgba :longword);
begin
   SetBrushColor(rgba and $FF, (rgba shr 8) and $FF, (rgba shr 16) and $FF, (rgba shr 24) and $FF);
end;

//------------------------------------------------------------------------------
procedure   BTOpenGLdraw2D.SetBrushColor(r, g, b, a :longword);
begin
   SetBrushColor((r and $FF)/255, (g and $FF)/255, (b and $FF)/255, (a and $FF)/255);
end;

//------------------------------------------------------------------------------
procedure   BTOpenGLdraw2D.Line(x1, y1, x2, y2: Single);
begin
   glBegin(GL_LINES);
   glColor4f(Pen_R, Pen_G, Pen_B, Pen_A);
   glVertex2f(x1, y1);
   glVertex2f(x2, y2);
   glEnd;
end;

//------------------------------------------------------------------------------
procedure   BTOpenGLdraw2D.Rectangle(x1, y1, x2, y2: Single);
begin
   glBegin(GL_LINE_LOOP);
   glColor4f(Pen_R, Pen_G, Pen_B, Pen_A);
   glVertex2f(x1, y1);
   glVertex2f(x2, y1);
   glVertex2f(x2, y2);
   glVertex2f(x1, y2);
   glEnd;
end;

//------------------------------------------------------------------------------
procedure   BTOpenGLdraw2D.FillRectangle(x1, y1, x2, y2: Single; border:boolean=true);
begin
   glColor4f(Brush_R, Brush_G, Brush_B, Brush_A);
//   glRectf(x1, y1, x2, y2);
   glBegin(GL_QUADS);
   glVertex2f(x1,y1);
   glVertex2f(x1,y2);
   glVertex2f(x2,y2);
   glVertex2f(x2,y1);
   glEnd();

   if border then Rectangle(x1,y1,x2,y2);
end;


//------------------------------------------------------------------------------
procedure   BTOpenGLdraw2D.DrawBitmap(bmp_hand: longword; bx,by,x, y: longint); //;  xZoom: Single = 1.0; yZoom: Single = 1.0);
var
   bmpInfo: BITMAP;
begin
   GetObject(bmp_Hand, SizeOf(bmpInfo), @bmpInfo);
//   glPixelZoom(xZoom, yZoom);
//   glPushMatrix;
//   glLoadIdentity;
   glRasterPos2i(x, y+by);
   glDrawPixels(bx, by, GL_BGR, GL_UNSIGNED_BYTE, bmpInfo.bmBits);
//   glPopMatrix;

end;

procedure BTOpenGLdraw2D.BuildTexture(bmp_hand,bx,by:longword; var texId: GLuint); // Creates Texture From A Bitmap File
var
   bmpInfo: BITMAP;
begin
   GetObject(bmp_hand, SizeOf(bmpInfo), @bmpInfo);
   glGenTextures(1, @texId);          // Create The Texture
   glPixelStorei(GL_PACK_ALIGNMENT, 1);
   // Typical Texture Generation Using Data From The Bitmap
   glBindTexture(GL_TEXTURE_2D, texId);        // Bind To The Texture ID
   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR); // Linear Min Filter
   glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR); // Linear Mag Filter
   glTexImage2D(GL_TEXTURE_2D, 0, 4{GL_BGRA}, bx, by, 0, GL_BGR, GL_UNSIGNED_BYTE, bmpInfo.bmBits);

end;

procedure BTOpenGLdraw2D.DeleteTexture(texId: GLuint);
begin
   glDeleteTextures(1, @texId);

end;


procedure   BTOpenGLdraw2D.DrawBitmapa(bmp_hand,bx,by: longword; x, y: longint);
var
   tex: GLuint;
begin
   glColor3f(1.0, 1.0, 1.0);
   glDisable(GL_BLEND);
   glEnable(GL_TEXTURE_2D);
   BuildTexture(bmp_hand,bx,by, tex);

   glBegin(GL_QUADS);
   glTexCoord2f(0.0, 0.0); glVertex3i(x, y, 0);
   glTexCoord2f(1.0, 0.0); glVertex3f(x + bx, y, 0);
   glTexCoord2f(1.0, 1.0); glVertex3f(x + bx, y + by, 0);
   glTexCoord2f(0.0, 1.0); glVertex3f(x, y + by, 0);
   glEnd;

   glDeleteTextures(1, @tex);
   glDisable(GL_TEXTURE_2D);
   glEnable(GL_BLEND);

end;







end.
