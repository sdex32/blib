unit BMessageQueue;

interface

uses Windows;


Type  BTMessageQueue = class
         private
            aErr :longint;
            cs : _RTL_CRITICAL_SECTION;
            hThread:longword;
            aCallBack :pointer;
            aCallBackData :longword;
            aStayInThread :boolean;
            aQueue :pointer;
            aBusy :boolean;
            aServer :boolean;
            aServerThreadsCnt :longword;
            aServerThreadsMax :longword;
            aPause :boolean;
         public
            constructor Create;
            destructor  Destroy; override;
            procedure   AddMessage(const mes :AnsiString); overload;
            procedure   AddMessage(data :pointer; data_len :longword); overload;
            procedure   SetMessageHandler(callback :pointer; callback_data :longword);
            property    GetLastError :longint read aErr;
      end;

      TMessageQueue_callback = function(cbdata:longword; data:pointer; data_len:longword) :longint; stdcall;




implementation

type tMsg = record
       Next    :pointer;
       DataLen :longword;
     end; // + Data at the end

type tSrv = record
        obj:BTMessageQueue;
        Msg:pointer;
     end;
type tSrvPtr = ^tSrv;

//------------------------------------------------------------------------------
function MessageServerExec(param:longword):longint; stdcall;
var obj:BTMessageQueue;
    d:pointer;
    executor :TMessageQueue_callback;
    dump:longword;
    Srv:tSrvPtr;
begin
   Srv := pointer(param);
   Obj := Srv.obj;
   d := pointer(longword(Srv.Msg) + sizeof(tMsg)); // get data pointer;
   executor := obj.aCallBack;
   if executor(obj.aCallBackData,d,tMsg(Srv.Msg^).DataLen) <> 0 then
   begin //error ops msg is deleted

   end;
   dec(obj.aServerThreadsCnt);
   ReallocMem(Srv.Msg,0); // free message
   ReallocMem(Srv,0);
   MessageServerExec := 0;
end;

function MessageQueueRunner(param:longword):longint; stdcall;
var obj:BTMessageQueue;
    msg:pointer;
    executor :TMessageQueue_callback;
    dump:longword;
    Srv:tSrvPtr;
    aSrv:tSrv;
    hThread:longword;
begin
   obj := pointer(param);
   executor := obj.aCallBack;
   if obj.aCallBack <> nil then
   repeat
      if obj.aPause then
      begin
         sleep(200);
         continue;
      end;
      if obj.aQueue <> nil then // there is a message in queue
      begin
         if obj.aServer then
         begin
            if obj.aServerThreadsCnt = obj.aServerThreadsMax then
            begin
               sleep(100);
               continue;
            end;
         end;

         EnterCriticalSection(obj.cs);
         msg := obj.aQueue; // get last insert
         obj.aQueue := tMsg(msg^).Next; // prepare next
         LeaveCriticalSection(obj.cs);

         aSrv.obj := obj;
         aSrv.Msg := msg;
         //execute
         if obj.aServer then
         begin
            Srv := nil;
            ReallocMem(Srv,sizeof(tSrvPtr));
            if Srv <> nil then
            begin
               Move(aSrv,Srv^,sizeof(tSrv));
               hThread := CreateThread (nil, 0, @MessageServerExec, Srv, 0, dump);
               if hThread <> 0 then
               begin
                  inc(obj.aServerThreadsCnt);
               end;
            end;
         end else begin
            MessageServerExec(longword(@aSrv));
         end;
      end else begin
         Sleep(100);
      end;

   until obj.aStayInThread;
   MessageQueueRunner := 0;
end;


//------------------------------------------------------------------------------
constructor BTMessageQueue.Create;
var dump :longword;
begin
   aBusy := false;
   aPause := false;
   aServer := false;
   aServerThreadsCnt := 0;
   aServerThreadsMax := 0;
   aErr := 0;
   aCallBack := nil;
   aCallBackdata := 0;
   aStayInThread := true;
   aQueue := nil;
   InitializeCriticalSection(cs);
   hThread := CreateThread (nil, 0, @MessageQueueRunner, self, 0, dump);
   if hThread = 0 then aErr := -1;
end;

//------------------------------------------------------------------------------
destructor  BTMessageQueue.Destroy;
begin
   aStayInThread := false;
   Closehandle(hThread);
   DeleteCriticalSection(cs);
   inherited;
end;

//------------------------------------------------------------------------------
procedure   BTMessageQueue.AddMessage(const mes :AnsiString);
begin
   AddMessage(@mes[1],length(mes));
end;

//------------------------------------------------------------------------------
procedure   BTMessageQueue.AddMessage(data :pointer; data_len :longword);
var p,a:pointer;
    pdata:pointer;
begin
   aErr := 0;
   if hThread <> 0 then
   begin
      p := nil;
      ReallocMem(p,data_len + sizeof(tMsg));
      if p = nil then
      begin
         aErr := -2;
         Exit;
      end;
      tMsg(p^).DataLen := data_len;
      tMsg(p^).Next := nil;
      pdata := pointer(longword(p) + sizeof(tMsg));
      Move(data,pdata,data_len); // copy data in message

      // Link in message queue list
      EnterCriticalSection(cs);
      aBusy := true;

         a := aQueue;
         if a <> nil then
         begin
            while tMsg(a^).Next <> Nil do a := tMsg(a^).Next; // find last
            tMsg(a^).Next := p; // link at the end
         end else begin
            aQueue := p; // link wirst
         end;

      aBusy := false;
      LeaveCriticalSection(cs);
   end else aErr := -3;
end;

//------------------------------------------------------------------------------
procedure   BTMessageQueue.SetMessageHandler(callback :pointer; callback_data :longword);
begin
   aCallBackData := callback_data;
   aCallBack := callback;
end;


end.
