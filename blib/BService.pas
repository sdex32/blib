unit BService;

interface

{$IFDEF FPC}
{$mode delphi}  //procedure=pointer
{$ENDIF}

// warning all proc are without params
procedure Execute_Service(SrvName_ansiStr,proc:pointer; SleepTime:longword;
                          oninstall,onuninstall,onstart,onstop:pointer);

//------------------------------------------------------------------------------
implementation

//todo_add events start stop

uses windows,
     //winsvc,
//     BLogFile,
     BExecute,
     BFileTools;

// my local windows unit
function StartServiceCtrlDispatcher(servicetable:pointer):boolean; stdcall; external 'advapi32.dll' name 'StartServiceCtrlDispatcherA';
function RegisterServiceCtrlHandler(lpServiceName,lpHandlerProc:pointer):longint; stdcall; external 'advapi32.dll' name 'RegisterServiceCtrlHandlerA';
function SetServiceStatus(hServiceStatus,lpServiceStatus:longword):boolean; stdcall; external 'advapi32.dll' name 'SetServiceStatus';



var  Service_Table :record
        Service_Name :pointer;
        Service_Ptr :pointer;
     end;
     g_StatusHandle :longword;
     g_ServiceStopEvent :longword;
     g_ServiceName :AnsiString;
     g_SleepInterval :longword;
     g_Callback :pointer;
     g_onStart :pointer;
     g_onStop :pointer;
     g_ServiceStatus :record
        dwServiceType :longword;
        dwCurrentState :longword;
        dwControlsAccepted :longword;
        dwWin32ExitCode :longword;
        dwServiceSpecificExitCode :longword;
        dwCheckPoint :longword;
        dwWaitHint :longword;
     end;
//     Log:BTLogFile;


function ServiceWorkerThread (lpParam:longword):longint; stdcall;
var Caller:procedure;
begin
   while (WaitForSingleObject(g_ServiceStopEvent, 0) <> WAIT_OBJECT_0) do
   begin

      //* Perform main service function here

//      bDebug('acc.log','service',0);
//       log.log('Servi working .......',0);

      if g_CallBack <> nil then
      begin
//      bDebug('acc.log','doit',0);
        Caller := g_CallBack;
        Caller; //do it
      end;
      //  Simulate some work by sleeping
      Sleep(g_SleepInterval);
   end;
   Result := ERROR_SUCCESS;
end;

procedure ServiceCtrlHandler(CtrlCode:longword); stdcall;
begin
   if CtrlCode = $00000001 then  //SERVICE_CONTROL_STOP
   begin
//       log.log('Service ctr',0);
      if (g_ServiceStatus.dwCurrentState <> $00000004 {SERVICE_RUNNING}) then Exit;
      //* Perform tasks neccesary to stop the service here

      g_ServiceStatus.dwControlsAccepted := 0;
      g_ServiceStatus.dwCurrentState := $00000003; //SERVICE_STOP_PENDING;
      g_ServiceStatus.dwWin32ExitCode := 0;
      g_ServiceStatus.dwCheckPoint := 4;

      if SetServiceStatus (g_StatusHandle, longword(@g_ServiceStatus)) = false then
      begin
//         log.log('error 11',0);
         //Error
         Exit;
      end;

      // This will signal the worker thread to start shutting down
      SetEvent (g_ServiceStopEvent);
   end;
end;

procedure ServiceMain(argc,argv:longword); stdcall;
var hThread,dump:longword;
    Caller:procedure;
begin
//log.log('Service main entry',0);
//log.log(g_ServiceName,0);

   g_StatusHandle := RegisterServiceCtrlHandler (@g_ServiceName, @ServiceCtrlHandler);

   if (g_StatusHandle = 0) then
   begin
//      Log.Log('err7',0);
      //error My Sample Service: ServiceMain: RegisterServiceCtrlHandler returned error"));
      halt;
   end;

   // Tell the service controller we are starting
   g_ServiceStatus.dwServiceType := $00000010; //SERVICE_WIN32_OWN_PROCESS;
   g_ServiceStatus.dwCurrentState := $00000002; //SERVICE_START_PENDING;
   g_ServiceStatus.dwControlsAccepted := 0;
   g_ServiceStatus.dwWin32ExitCode := 0;
   g_ServiceStatus.dwServiceSpecificExitCode := 0;
   g_ServiceStatus.dwCheckPoint := 0;
   g_ServiceStatus.dwWaitHint := 0;

   if SetServiceStatus (g_StatusHandle, longword(@g_ServiceStatus)) = false then
   begin
      //Error
//      Log.Log('err6',0);
      Exit;
   end;

   //* Perform tasks neccesary to start the service here

   // Create stop event to wait on later.
   g_ServiceStopEvent := CreateEvent (Nil, TRUE, FALSE, Nil);
   if g_ServiceStopEvent = 0 then
   begin
      //error create event
      g_ServiceStatus.dwControlsAccepted := 0;
      g_ServiceStatus.dwCurrentState := $00000001; //SERVICE_STOPPED;
      g_ServiceStatus.dwWin32ExitCode := GetLastError;
      g_ServiceStatus.dwCheckPoint := 1;
      if SetServiceStatus (g_StatusHandle, longword(@g_ServiceStatus)) = false then
      begin
//        Log.Log('err5',0);
         //error
         Exit;
      end;
   end;

   // Tell the service controller we are started
   g_ServiceStatus.dwControlsAccepted := $00000001; //SERVICE_ACCEPT_STOP;
   g_ServiceStatus.dwCurrentState := $00000004; //SERVICE_RUNNING;
   g_ServiceStatus.dwWin32ExitCode := 0;
   g_ServiceStatus.dwCheckPoint := 0;

   if SetServiceStatus (g_StatusHandle, longword(@g_ServiceStatus)) = false then
   begin
//      Log.Log('err4',0);
      //error
      Exit;
   end;

   if g_OnStart <> nil then
   begin
      Caller := g_OnStart;
      Caller;
   end;

   // Start the thread that will perform the main task of the service
   hThread := CreateThread (nil, 0, @ServiceWorkerThread, nil, 0, dump);

   // Wait until our worker thread exits effectively signaling that the service needs to stop
   WaitForSingleObject (hThread, INFINITE);

   //* Perform any cleanup tasks
   CloseHandle (g_ServiceStopEvent);

   if g_OnStop <> nil then
   begin
      Caller := g_OnStop;
      Caller;
   end;


   g_ServiceStatus.dwControlsAccepted := 0;
   g_ServiceStatus.dwCurrentState := $00000001; //SERVICE_STOPPED;
   g_ServiceStatus.dwWin32ExitCode := 0;
   g_ServiceStatus.dwCheckPoint := 3;

   if SetServiceStatus (g_StatusHandle, longword(@g_ServiceStatus)) = false then
   begin
//         Log.Log('err3',0);
      //error
      Exit;
   end;

//Log.Log('Service main ei=xit',0);
end;

procedure Execute_Service(SrvName_ansiStr,proc:pointer; SleepTime:longword;
                          oninstall,onuninstall,onstart,onstop:pointer);
var done:longword;
    s:string;
    ds:AnsiString;
    Caller:procedure;
//    scmanager :longword;
//    scservice :longword;
//    c:Service_Status;
begin
   g_ServiceName := pansistring(SrvName_ansiStr)^;
   g_SleepInterval := SleepTime;
   g_Callback := proc;
   ds := ansistring(GetMyFileName)+#0;
   done := 0;

//   Log := BTlogFile.Create('ass.log');

   GetDir(0, s);
   if paramcount > 0  then
   begin

      if paramstr(1) = '-?' then
      begin
         Writeln('use -install, -unintsall, -start, -stop');
         Halt;
      end;

//      scmanager := OpenSCManager(nil,nil,SC_MANAGER_CREATE_SERVICE);// or SC_MANAGER_CONNECT); //SC_MANAGER_ALL_ACCESS);
//      if scmanager <> 0  then
//      begin

         if paramstr(1) = '-install' then
         begin
            if onInstall <> nil then
            begin
               Caller := onInstall;
               Caller; // execute on Install
            end;

            s :=' create "'+string(g_ServiceName)+'" start= auto binPath= '+GetMyFileName;


//            scservice := CreateServiceA(scmanager,@g_ServiceName[1],@g_ServiceName[1],
//                           SERVICE_CHANGE_CONFIG, //GENERIC_WRITE, //SERVICE_ALL_ACCESS,
//                           SERVICE_WIN32_OWN_PROCESS,
//                           SERVICE_DEMAND_START,
//                           SERVICE_ERROR_NORMAL,
//                           @ds[1],nil,nil,nil,nil,nil);
//            if scservice <> 0 then done := 1;
//            CloseServiceHandle(scservice);
         end;


         if paramstr(1) = '-uninstall' then
         begin
            if onUnInstall <> nil then
            begin
               Caller := onUnInstall;
               Caller; //Execute UnIntstall
            end;

            s:=' delete "'+string(g_ServiceName)+'"';


//            scservice := OpenServiceA(scmanager,@g_ServiceName[1],SERVICE_CHANGE_CONFIG); //GENERIC_WRITE); //SERVICE_ALL_ACCESS);
//
//            if scservice <> 0 then
//            begin
//               DeleteService(scservice);
//               done := 1;
//            end;
//            CloseServiceHandle(scservice);
         end;

         if paramstr(1) = '-start' then
         begin
         s:=' start "'+string(g_ServiceName)+'"';
//            scservice := OpenServiceA(scmanager,@g_ServiceName[1],SERVICE_CHANGE_CONFIG);
//
//            if scservice <> 0 then
//            begin
//               ControlService(scservice,SERVICE_CONTROL_CONTINUE,c);
//               done := 1;
//            end;
//            CloseServiceHandle(scservice);
         end;

         if paramstr(1) = '-stop' then
         begin
         s:=' stop "'+string(g_ServiceName)+'"';
//            scservice := OpenServiceA(scmanager,@g_ServiceName[1],SERVICE_CHANGE_CONFIG);
//
//            if scservice <> 0 then
//            begin
//               ControlService(scservice,SERVICE_CONTROL_STOP,c);
//               done := 1;
//            end;
//            CloseServiceHandle(scservice);
         end;


      //      if done =1 then ExecuteFile('sc',s,true,false,true,'','',ds);
//      CloseServiceHandle(scmanager);
//      end;

      ds := ansistring(s);
      if RunAsAdmin(0,'sc',ds) then done := 1;


      if done = 1 then Writeln('status: success')
                  else Writeln('execute as administrator');

      halt;
   end;



//log.log(g_ServiceName,0);
   g_OnStart := onStart;
   g_OnStop := onStop;
   Service_Table.Service_Name := @g_ServiceName;
   Service_Table.Service_Ptr := @ServiceMain;
   if StartServiceCtrlDispatcher(@Service_Table) = false then
   begin
//      Log.Log('err1',0);
      //Error
      halt;
   end;
//   Log.Log('exit exec service ',0);
end;





end.
