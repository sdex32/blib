unit BJoyStick;

interface

uses Windows;

type
  MMRESULT = UINT;

{ joystick error return values }
const
  JOYERR_BASE            = 160;
  MAXPNAMELEN      =  32;    { max product name length (including nil) }
  MAXERRORLENGTH   = 256;    { max error text length (including nil) }
  MAX_JOYSTICKOEMVXDNAME = 260; { max oem vxd name length (including nil) }





  JOYERR_NOERROR        = 0;                  { no error }
  JOYERR_PARMS          = JOYERR_BASE+5;      { bad parameters }
  JOYERR_NOCANDO        = JOYERR_BASE+6;      { request not completed }
  JOYERR_UNPLUGGED      = JOYERR_BASE+7;      { joystick is unplugged }

{ constants used with TJoyInfo and TJoyInfoEx structure and MM_JOY* messages }
const
  JOY_BUTTON1         = $0001;
  JOY_BUTTON2         = $0002;
  JOY_BUTTON3         = $0004;
  JOY_BUTTON4         = $0008;
  JOY_BUTTON1CHG      = $0100;
  JOY_BUTTON2CHG      = $0200;
  JOY_BUTTON3CHG      = $0400;
  JOY_BUTTON4CHG      = $0800;

{ constants used with TJoyInfoEx }
  JOY_BUTTON5         = $00000010;
  JOY_BUTTON6         = $00000020;
  JOY_BUTTON7         = $00000040;
  JOY_BUTTON8         = $00000080;
  JOY_BUTTON9         = $00000100;
  JOY_BUTTON10        = $00000200;
  JOY_BUTTON11        = $00000400;
  JOY_BUTTON12        = $00000800;
  JOY_BUTTON13        = $00001000;
  JOY_BUTTON14        = $00002000;
  JOY_BUTTON15        = $00004000;
  JOY_BUTTON16        = $00008000;
  JOY_BUTTON17        = $00010000;
  JOY_BUTTON18        = $00020000;
  JOY_BUTTON19        = $00040000;
  JOY_BUTTON20        = $00080000;
  JOY_BUTTON21        = $00100000;
  JOY_BUTTON22        = $00200000;
  JOY_BUTTON23        = $00400000;
  JOY_BUTTON24        = $00800000;
  JOY_BUTTON25        = $01000000;
  JOY_BUTTON26        = $02000000;
  JOY_BUTTON27        = $04000000;
  JOY_BUTTON28        = $08000000;
  JOY_BUTTON29        = $10000000;
  JOY_BUTTON30        = $20000000;
  JOY_BUTTON31        = $40000000;
  JOY_BUTTON32        = $80000000;

{ constants used with TJoyInfoEx }
  JOY_POVCENTERED	= -1;
  JOY_POVFORWARD	= 0;
  JOY_POVRIGHT		= 9000;
  JOY_POVBACKWARD	= 18000;
  JOY_POVLEFT		= 27000;

  JOY_RETURNX		= $00000001;
  JOY_RETURNY		= $00000002;
  JOY_RETURNZ		= $00000004;
  JOY_RETURNR		= $00000008;
  JOY_RETURNU		= $00000010; { axis 5 }
  JOY_RETURNV		= $00000020; { axis 6 }
  JOY_RETURNPOV		= $00000040;
  JOY_RETURNBUTTONS	= $00000080;
  JOY_RETURNRAWDATA	= $00000100;
  JOY_RETURNPOVCTS	= $00000200;
  JOY_RETURNCENTERED	= $00000400;
  JOY_USEDEADZONE		= $00000800;
    JOY_RETURNALL  = (JOY_RETURNX or JOY_RETURNY or JOY_RETURNZ or
    JOY_RETURNR or JOY_RETURNU or JOY_RETURNV or
    JOY_RETURNPOV or JOY_RETURNBUTTONS);
  JOY_CAL_READALWAYS	= $00010000;
  JOY_CAL_READXYONLY	= $00020000;
  JOY_CAL_READ3		= $00040000;
  JOY_CAL_READ4		= $00080000;
  JOY_CAL_READXONLY	= $00100000;
  JOY_CAL_READYONLY	= $00200000;
  JOY_CAL_READ5		= $00400000;
  JOY_CAL_READ6		= $00800000;
  JOY_CAL_READZONLY	= $01000000;
  JOY_CAL_READRONLY	= $02000000;
  JOY_CAL_READUONLY	= $04000000;
  JOY_CAL_READVONLY	= $08000000;

{ joystick ID constants }
const
  JOYSTICKID1         = 0;
  JOYSTICKID2         = 1;

{ joystick driver capabilites }
  JOYCAPS_HASZ		= $0001;
  JOYCAPS_HASR		= $0002;
  JOYCAPS_HASU		= $0004;
  JOYCAPS_HASV		= $0008;
  JOYCAPS_HASPOV		= $0010;
  JOYCAPS_POV4DIR		= $0020;
  JOYCAPS_POVCTS		= $0040;

{ joystick device capabilities data structure }
type
  PJoyCapsA = ^TJoyCapsA;
  PJoyCapsW = ^TJoyCapsW;
  PJoyCaps = PJoyCapsW;
  tagJOYCAPSA = record
    wMid: Word;                  { manufacturer ID }
    wPid: Word;                  { product ID }
    szPname: array[0..MAXPNAMELEN-1] of AnsiChar;  { product name (NULL terminated AnsiString) }
    wXmin: UINT;                 { minimum x position value }
    wXmax: UINT;                 { maximum x position value }
    wYmin: UINT;                 { minimum y position value }
    wYmax: UINT;                 { maximum y position value }
    wZmin: UINT;                 { minimum z position value }
    wZmax: UINT;                 { maximum z position value }
    wNumButtons: UINT;           { number of buttons }
    wPeriodMin: UINT;            { minimum message period when captured }
    wPeriodMax: UINT;            { maximum message period when captured }
    wRmin: UINT;                 { minimum r position value }
    wRmax: UINT;                 { maximum r position value }
    wUmin: UINT;                 { minimum u (5th axis) position value }
    wUmax: UINT;                 { maximum u (5th axis) position value }
    wVmin: UINT;                 { minimum v (6th axis) position value }
    wVmax: UINT;                 { maximum v (6th axis) position value }
    wCaps: UINT;                 { joystick capabilites }
    wMaxAxes: UINT;	 	{ maximum number of axes supported }
    wNumAxes: UINT;	 	{ number of axes in use }
    wMaxButtons: UINT;	 	{ maximum number of buttons supported }
    szRegKey: array[0..MAXPNAMELEN - 1] of AnsiChar; { registry key }
    szOEMVxD: array[0..MAX_JOYSTICKOEMVXDNAME - 1] of AnsiChar; { OEM VxD in use }
  end;

  tagJOYCAPSW = record
    wMid: Word;                  { manufacturer ID }
    wPid: Word;                  { product ID }
    szPname: array[0..MAXPNAMELEN-1] of WideChar;  { product name (NULL terminated UnicodeString) }
    wXmin: UINT;                 { minimum x position value }
    wXmax: UINT;                 { maximum x position value }
    wYmin: UINT;                 { minimum y position value }
    wYmax: UINT;                 { maximum y position value }
    wZmin: UINT;                 { minimum z position value }
    wZmax: UINT;                 { maximum z position value }
    wNumButtons: UINT;           { number of buttons }
    wPeriodMin: UINT;            { minimum message period when captured }
    wPeriodMax: UINT;            { maximum message period when captured }
    wRmin: UINT;                 { minimum r position value }
    wRmax: UINT;                 { maximum r position value }
    wUmin: UINT;                 { minimum u (5th axis) position value }
    wUmax: UINT;                 { maximum u (5th axis) position value }
    wVmin: UINT;                 { minimum v (6th axis) position value }
    wVmax: UINT;                 { maximum v (6th axis) position value }
    wCaps: UINT;                 { joystick capabilites }
    wMaxAxes: UINT;	 	{ maximum number of axes supported }
    wNumAxes: UINT;	 	{ number of axes in use }
    wMaxButtons: UINT;	 	{ maximum number of buttons supported }
    szRegKey: array[0..MAXPNAMELEN - 1] of WideChar; { registry key }
    szOEMVxD: array[0..MAX_JOYSTICKOEMVXDNAME - 1] of WideChar; { OEM VxD in use }
  end;

  tagJOYCAPS = tagJOYCAPSW;
  TJoyCapsA = tagJOYCAPSA;
  TJoyCapsW = tagJOYCAPSW;
  TJoyCaps = TJoyCapsW;
  JOYCAPSA = tagJOYCAPSA;
  JOYCAPSW = tagJOYCAPSW;
  JOYCAPS = JOYCAPSW;

{ joystick information data structure }
type
  PJoyInfo = ^TJoyInfo;
  joyinfo_tag = record
    wXpos: UINT;                 { x position }
    wYpos: UINT;                 { y position }
    wZpos: UINT;                 { z position }
    wButtons: UINT;              { button states }
  end;
  TJoyInfo = joyinfo_tag;
  JOYINFO = joyinfo_tag;

  PJoyInfoEx = ^TJoyInfoEx;
  joyinfoex_tag = record
    dwSize: DWORD;		 { size of structure }
    dwFlags: DWORD;		 { flags to indicate what to return }
    wXpos: UINT;         { x position }
    wYpos: UINT;         { y position }
    wZpos: UINT;         { z position }
    dwRpos: DWORD;		 { rudder/4th axis position }
    dwUpos: DWORD;		 { 5th axis position }
    dwVpos: DWORD;		 { 6th axis position }
    wButtons: UINT;      { button states }
    dwButtonNumber: DWORD;  { current button number pressed }
    dwPOV: DWORD;           { point of view state }
    dwReserved1: DWORD;		 { reserved for communication between winmm & driver }
    dwReserved2: DWORD;		 { reserved for future expansion }
  end;
  TJoyInfoEx = joyinfoex_tag;
  JOYINFOEX = joyinfoex_tag;

{ joystick function prototypes }
function joyGetNumDevs: UINT; stdcall;
function joyGetDevCaps(uJoyID: UIntPtr; lpCaps: PJoyCaps; uSize: UINT): MMRESULT; stdcall;
function joyGetDevCapsA(uJoyID: UIntPtr; lpCaps: PJoyCapsA; uSize: UINT): MMRESULT; stdcall;
function joyGetDevCapsW(uJoyID: UIntPtr; lpCaps: PJoyCapsW; uSize: UINT): MMRESULT; stdcall;
function joyGetPos(uJoyID: UINT; lpInfo: PJoyInfo): MMRESULT; stdcall;
function joyGetPosEx(uJoyID: UINT; lpInfo: PJoyInfoEx): MMRESULT; stdcall;
function joyGetThreshold(uJoyID: UINT; lpuThreshold: PUINT): MMRESULT; stdcall;
function joyReleaseCapture(uJoyID: UINT): MMRESULT; stdcall;
function joySetCapture(Handle: HWND; uJoyID, uPeriod: UINT; bChanged: BOOL): MMRESULT; stdcall;
function joySetThreshold(uJoyID, uThreshold: UINT): MMRESULT; stdcall;


implementation

const
mmsyst = 'winmm.dll';

function joyGetDevCaps; external mmsyst name 'joyGetDevCapsW';
function joyGetDevCapsA; external mmsyst name 'joyGetDevCapsA';
function joyGetDevCapsW; external mmsyst name 'joyGetDevCapsW';
function joyGetNumDevs; external mmsyst name 'joyGetNumDevs';
function joyGetPos; external mmsyst name 'joyGetPos';
function joyGetPosEx; external mmsyst name 'joyGetPosEx';
function joyGetThreshold; external mmsyst name 'joyGetThreshold';
function joyReleaseCapture; external mmsyst name 'joyReleaseCapture';
function joySetCapture; external mmsyst name 'joySetCapture';
function joySetThreshold; external mmsyst name 'joySetThreshold';



end.
