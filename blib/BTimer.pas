unit BTimer;
{$APPTYPE GUI }

/// if FPC is not defined DELPHI usage
{$IFDEF FPC }
{$MODE DELPHI }

{*********** CODE GENRATION ****************}
{$DEBUGINFO OFF }
{$ASMMODE INTEL }
{ $ STACKFRAMES OFF } // after version 1.0.10 this is auto
{$GOTO ON }
{$S- } {** stop stack check ** }
{$INLINE ON }
{$MACRO ON }
{$SMARTLINK ON }
{$TYPEINFO ON }

{*********** OUTPUT MESSAGES ***************}
{$HINTS ON }
{$NOTES ON }
{$WARNINGS ON }

{$ELSE }
{**** DELPHI }
{$APPTYPE GUI}
{$DEBUGINFO OFF}
{$OPTIMIZATION ON}
{$RANGECHECKS OFF}
{$OVERFLOWCHECKS OFF}

{$ENDIF}

interface

   uses windows;

function  BeginTimer(Time_delay:dword):dword;
procedure WaitTimer(The_timer:dword);
function  TimerReady(The_timer:dword):boolean;
procedure Delay(Delay_time:dword);
function  FramesPerSecond(The_Timer:dword):single;  // Use BeginTimer(0)

implementation
(*//////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
///  WNDSYS (TIMER)   versin 2.7a     last touch 17.10.2003
///
///  < <    T I M E R    D R I V E R    > >
///


export
   BeginTimer,
   WaitTimer,
   TimerReady,
   Delay,

to implementation

function  BeginTimer(Time_delay:dword):dword;
 external 'wndsys.dll' name 'BeginTimer';

procedure WaitTimer(The_timer:dword);
 external 'wndsys.dll' name 'WaitTimer';

function  TimerReady(The_timer:dword):boolean;
 external 'wndsys.dll' name 'TimerReady';

procedure Delay(Delay_time:dword);
 external 'wndsys.dll' name 'Delay';

*)

function FramesPerSecond(The_Timer:dword):single;  // Use BeginTimer(0)
begin
   The_Timer := (GetTickCount - The_Timer);
   if The_Timer > 0 then FRamesPerSecond := 1000 / The_Timer
                    else FRamesPerSecond := 1000;
end;

function BeginTimer(Time_delay:dword):dword;
begin
   BeginTimer := GetTickCount + Time_delay;
end;

procedure WaitTimer(The_timer:dword);
var amsg : MSG;
begin
   while GetTickCount < The_timer do // T = 0; was
   begin
{$IFDEF FPC}
      if GetMessage(@amsg,0,0,0) = true then
      begin
         TranslateMessage(@amsg);
         DispatchMessage(@amsg);
{$ELSE}
      if GetMessage(amsg,0,0,0) = true then
      begin
         TranslateMessage(amsg);
         DispatchMessage(amsg);
{$ENDIF}
      end;
   end;
end;

function  TimerReady(The_timer:dword):boolean;
begin
   if The_timer <= GetTickCount
   then TimerReady := true
   else TimerReady := false ;
end;

procedure Delay(Delay_time:dword);
var t:dword;
begin
   t := BeginTimer(Delay_time);
   WaitTimer(t);
end;

(*  Timer ----------------------


type
     Proctype = procedure;

Const
     RunTimerFreq = 5 ; { 200 Hz }
     RunTimerHand = 1203;
     MAX_TIMERS   = 4;
Var
     RunTimerHandle : dword;


//VOID CALLBACK TimerProc(
//  HWND hwnd,         // handle to window
//  UINT uMsg,         // WM_TIMER message
//  UINT_PTR idEvent,  // timer identifier
//  DWORD dwTime       // current system time
//);

   Timers_Status     : array [0..MAX_TIMERS] of byte;
   Timers_Ticks      : array [0..MAX_TIMERS] of dword;
   Timers_Events     : array [0..MAX_TIMERS] of procedure;



procedure TimerProc_CB(hw:HWND; msg:UINT; id,Ticks:dword); 
var indx:dword;
begin
//  if AppActive then
//  begin
     for indx := 0 to MAX_TIMERS do
     begin
        if ( Timers_Status[indx] = 1 ) then
        begin
           if Timers_Ticks[indx] <= Ticks then
           begin
              Timers_Status[indx] := 0;
              Timers_Events[indx];
           end;
        end;
     end;
//  end;
end;


function  CreateTimer(TicksPerSecond:dword; ProcHandle:proctype):dword;
var indx :integer;
    done :dword;
    F    :dword;
begin
   if TicksPerSecond > 200 then TicksPerSecond := 200;
   F := round((1/real(TicksPerSecond))*1000);
   done := 0;
   for indx:= 0 to MAX_TIMERS do
   begin
      if Timers_Status[indx] = 0 then
      begin
         Timers_Status[indx] := 1;
         Timers_Ticks[indx]  := GetTickCount + F;
         Timers_Events[indx] := ProcHandle;
         done := indx;
         break;  { find done }
      end;
   end;
   CreateTimer := done;
end;

  NOTE put this in
  WM_CREATE
     RunTimerHandle := SetTimer(h_wnd,RunTimerHand,RunTimerFreq,TimerProc_CB);
  WM_DESTROY
     KillTimer(h_wnd,RunTimerHandle);
  use this to INIT timers
   for i:= 0 to MAX_TIMERS do Timers_Status[i] := 0;

*)


end.
