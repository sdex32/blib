unit BWEBSocketServer;

interface

type
      BTWEBSocketServerIni = record

      end;


      BTWEBSocketServer = class
         private
         public
            constructor Create;
            destructor  Destroy; override;
            procedure   Init( config :BTWEBSocketServerIni);
            procedure   Start;
            procedure   Stop;
      end;



implementation

//------------------------------------------------------------------------------
constructor BTWEBSocketServer.Create;
begin

end;

//------------------------------------------------------------------------------
destructor  BTWEBSocketServer.Destroy;
begin

   inherited;
end;

//------------------------------------------------------------------------------
procedure   BTWEBSocketServer.Init(config:BTWEBSocketServerIni);
begin

end;

//------------------------------------------------------------------------------
procedure   BTWEBSocketServer.Start;
begin

end;

//------------------------------------------------------------------------------
procedure   BTWEBSocketServer.Stop;
begin

end;


end.
