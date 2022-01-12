unit BWinDSound;

interface

uses windows;

//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
// micro version of DSound.pas
// uses DSound.pas;

//const
// Direct Sound Component GUID {47D4D946-62E8-11cf-93BC-444553540000}
//  CLSID_DirectSound: TGUID =
//      (D1:$47d4d946;D2:$62e8;D3:$11cf;D4:($93,$bc,$44,$45,$53,$54,$00,$0));
//
//  IID_IDirectSound: TGUID =
//      (D1:$279AFA83;D2:$4981;D3:$11CE;D4:($A5,$21,$00,$20,$AF,$0B,$E5,$60));
//  IID_IDirectSoundBuffer: TGUID =
//      (D1:$279AFA85;D2:$4981;D3:$11CE;D4:($A5,$21,$00,$20,$AF,$0B,$E5,$60));

type
  PWaveFormatEx = ^TWaveFormatEx;
  TWAVEFORMATEX = packed record
    wFormatTag: Word;       { format type }
    nChannels: Word;        { number of channels (i.e. mono, stereo, etc.) }
    nSamplesPerSec: DWORD;  { sample rate }
    nAvgBytesPerSec: DWORD; { for buffer estimation }
    nBlockAlign: Word;      { block size of data }
    wBitsPerSample: Word;   { number of bits per sample of mono data }
    cbSize: Word;           { the count in bytes of the size of }
  end;

  TDSCBufferDesc = packed record
    dwSize: DWORD;
    dwFlags: DWORD;
    dwBufferBytes: DWORD;
    dwReserved: DWORD;
    lpwfxFormat: PWaveFormatEx;
  end;

  TDSBufferDesc = TDSCBufferDesc;

  TDSCaps = packed record
    dwSize: DWORD;
    dwFlags: DWORD;
    dwMinSecondarySampleRate: DWORD;
    dwMaxSecondarySampleRate: DWORD;
    dwPrimaryBuffers: DWORD;
    dwMaxHwMixingAllBuffers: DWORD;
    dwMaxHwMixingStaticBuffers: DWORD;
    dwMaxHwMixingStreamingBuffers: DWORD;
    dwFreeHwMixingAllBuffers: DWORD;
    dwFreeHwMixingStaticBuffers: DWORD;
    dwFreeHwMixingStreamingBuffers: DWORD;
    dwMaxHw3DAllBuffers: DWORD;
    dwMaxHw3DStaticBuffers: DWORD;
    dwMaxHw3DStreamingBuffers: DWORD;
    dwFreeHw3DAllBuffers: DWORD;
    dwFreeHw3DStaticBuffers: DWORD;
    dwFreeHw3DStreamingBuffers: DWORD;
    dwTotalHwMemBytes: DWORD;
    dwFreeHwMemBytes: DWORD;
    dwMaxContigFreeHwMemBytes: DWORD;
    dwUnlockTransferRateHwBuffers: DWORD;
    dwPlayCpuOverheadSwBuffers: DWORD;
    dwReserved1: DWORD;
    dwReserved2: DWORD;
  end;

  TDSBCaps = packed record
    dwSize: DWORD;
    dwFlags: DWORD;
    dwBufferBytes: DWORD;
    dwUnlockTransferRate: DWORD;
    dwPlayCpuOverhead: DWORD;
  end;

  //////////////////////////

  IDirectSound = interface;
  IDirectSoundBuffer = interface;

  IDirectSound = interface (IUnknown)
    ['{279AFA83-4981-11CE-A521-0020AF0BE560}']
    // IDirectSound methods
    function CreateSoundBuffer(const lpDSBufferDesc: TDSBufferDesc;
        var lpIDirectSoundBuffer: IDirectSoundBuffer;
        pUnkOuter: IUnknown) : HResult; stdcall;
    function GetCaps(var lpDSCaps: TDSCaps) : HResult; stdcall;
    function DuplicateSoundBuffer(lpDsbOriginal: IDirectSoundBuffer;
        var lpDsbDuplicate: IDirectSoundBuffer) : HResult; stdcall;
    function SetCooperativeLevel(hwnd: HWND; dwLevel: DWORD) : HResult; stdcall;
    function Compact: HResult; stdcall;
    function GetSpeakerConfig(var lpdwSpeakerConfig: DWORD) : HResult; stdcall;
    function SetSpeakerConfig(dwSpeakerConfig: DWORD) : HResult; stdcall;
    function Initialize(lpGuid: PGUID) : HResult; stdcall;
  end;

  IDirectSoundBuffer = interface (IUnknown)
    ['{279AFA85-4981-11CE-A521-0020AF0BE560}']
    // IDirectSoundBuffer methods
    function GetCaps(var lpDSCaps: TDSBCaps) : HResult; stdcall;
    function GetCurrentPosition
        (lpdwCapturePosition, lpdwReadPosition : PDWORD) : HResult;  stdcall;
    function GetFormat(lpwfxFormat: PWaveFormatEx; dwSizeAllocated: DWORD;
        lpdwSizeWritten: PWORD) : HResult;  stdcall;
    function GetVolume(var lplVolume: integer) : HResult;  stdcall;
    function GetPan(var lplPan: integer) : HResult;  stdcall;
    function GetFrequency(var lpdwFrequency: DWORD) : HResult;  stdcall;
    function GetStatus(var lpdwStatus: DWORD) : HResult;  stdcall;
    function Initialize(lpDirectSound: IDirectSound;
        var lpcDSBufferDesc: TDSBufferDesc) : HResult;  stdcall;
    function Lock(dwWriteCursor, dwWriteBytes: DWORD;
        var lplpvAudioPtr1: Pointer; var lpdwAudioBytes1: DWORD;
        var lplpvAudioPtr2: Pointer; var lpdwAudioBytes2: DWORD;
        dwFlags: DWORD) : HResult;  stdcall;
    function Play(dwReserved1,dwReserved2,dwFlags: DWORD) : HResult;  stdcall;
    function SetCurrentPosition(dwPosition: DWORD) : HResult;  stdcall;
    function SetFormat(const lpcfxFormat: TWaveFormatEx) : HResult;  stdcall;
    function SetVolume(lVolume: integer) : HResult;  stdcall;
    function SetPan(lPan: integer) : HResult;  stdcall;
    function SetFrequency(dwFrequency: DWORD) : HResult;  stdcall;
    function Stop: HResult;  stdcall;
    function Unlock(lpvAudioPtr1: Pointer; dwAudioBytes1: DWORD;
        lpvAudioPtr2: Pointer; dwAudioBytes2: DWORD) : HResult;  stdcall;
    function Restore: HResult;  stdcall;
  end;

const
  DS_OK = 0;

  DSBCAPS_PRIMARYBUFFER = $00000001;
  DSSCL_WRITEPRIMARY = $00000004;
  DSSCL_NORMAL = $00000001;






//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<




type
   BTWinDSound = class
      private
         DSoundDLL :longword;
         DirectSound: IDirectSound;
         DirectSoundBuffer: IDirectSoundBuffer;
         SecondarySoundBuffer: array [0..1] of IDirectSoundBuffer;
      public
         constructor Create(Handle:longword);
         destructor  Destroy; override;
//         procedure   SetVolume(hand, L, R:longword);
//         procedure   Pause(hand :longword);
//         procedure   Resume(hand :longword);
//         procedure   Close(hand :longword);
//         function    Play(shand :longword) :longword;
//         function    OpenRawSound(freq,chan,bits,vol,flg:longword; data,data2:pointer; bufsize:longword) :longword;
//         procedure   FreeSound(shand :longword);
//         procedure   AddCallback(shand :longword; CallBack:pointer; CB_param:longword);
//         function    GetChanCurBuff(hand:longword):longword;
   end;



implementation



var
   DirectSoundCreate : function ( lpGuid: PGUID; out ppDS: IDirectSound;
      pUnkOuter: IUnknown) : HResult; stdcall;



//------------------------------------------------------------------------------
constructor BTWinDSound.Create(Handle:longword);
var
  BufferDesc: TDSBUFFERDESC;
//  Caps: TDSBCaps;
  PCM: TWaveFormatEx;

begin
   DSoundDLL := LoadLibrary('DSound.dll');
   if DSoundDll <> 0 then
   begin
      DirectSoundCreate := GetProcAddress(DSoundDLL,'DirectSoundCreate');
      if DirectSoundCreate(nil, DirectSound, nil) = DS_OK then
      begin
//    raise Exception.Create('Failed to create IDirectSound object');
      // AppCreateWritePrimaryBuffer;
        FillChar(BufferDesc, SizeOf(TDSBUFFERDESC),0);
        FillChar(PCM, SizeOf(TWaveFormatEx),0);
        with BufferDesc do
        begin
          (*

   if Chan < 3 then
    begin
      PCM.wFormatTag := 1; //WAVE_FORMAT_PCM;
      PCM.cbSize := 0;
    end else
    begin
      PCM.wFormatTag := WAVE_FORMAT_EXTENSIBLE;
      PCM.cbSize := SizeOf(FormatExt) - SizeOf(FormatExt.Format);
      PCM.SubFormat := KSDATAFORMAT_SUBTYPE_PCM;
      if Chan = 2 then
         FormatExt.dwChannelMask := $3;
      if Chan = 6 then
        FormatExt.dwChannelMask := $3F;
      if Chan = 8 then
        FormatExt.dwChannelMask := $FF;
    end;
    FormatExt.Format.nChannels := Chan;
    FormatExt.Format.nSamplesPerSec := SR;
    FormatExt.Format.wBitsPerSample := BPS;
    FormatExt.Format.nBlockAlign := Chan*BPS shr 3;
    FormatExt.Format.nAvgBytesPerSec :=  SR*FormatExt.Format.nBlockAlign;
 //   FormatExt.wValidBitsPerSample := BPS;
//    FormatExt.wSamplesPerBlock := 0;
//   FormatExt.wReserved := 0;
//    FormatExt.SubFormat := 1;

            *)



           PCM.wFormatTag := 1 {WAVE_FORMAT_PCM};
           PCM.nChannels := 2;
           PCM.nSamplesPerSec:= 44100;
           PCM.nBlockAlign := 4;
           PCM.nAvgBytesPerSec :=PCM.nSamplesPerSec * PCM.nBlockAlign;
           PCM.wBitsPerSample := 16;
           PCM.cbSize := 0;
           dwSize := SizeOf(TDSBUFFERDESC);
           dwFlags := DSBCAPS_PRIMARYBUFFER;
           dwBufferBytes := 0;
           lpwfxFormat := nil;
        end;
        if DirectSound.SetCooperativeLevel(Handle,DSSCL_WRITEPRIMARY) = DS_OK then
        begin
           if DirectSound.CreateSoundBuffer(BufferDesc,DirectSoundBuffer,nil) = DS_OK then
           begin
              if DirectSoundBuffer.SetFormat(PCM) = DS_OK then
              begin
                 if DirectSound.SetCooperativeLevel(Handle,DSSCL_NORMAL) = DS_OK then
                 begin


                 end;
              end;
           end;
        end;




  //AppCreateWriteSecondaryBuffer(SecondarySoundBuffer[0], 22050, 8, False, 10);
  //AppCreateWriteSecondaryBuffer(SecondarySoundBuffer[1], 22050, 16, True, 1);
      end;
   end;
end;

//------------------------------------------------------------------------------
destructor  BTWinDSound.Destroy;
var i:longword;
begin
   if Assigned(DirectSoundBuffer) then  DirectSoundBuffer._Release;
   for i:=0 to 1 do
   if Assigned(SecondarySoundBuffer[i]) then   SecondarySoundBuffer[i]._Release;
   if Assigned(DirectSound) then  DirectSound._Release;
   if DSoundDll <> 0 then FreeLibrary(DSoundDLL);
   inherited;
end;



end.
