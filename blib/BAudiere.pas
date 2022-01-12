unit BAudiere;

interface

const
   Audiere_FF_AUTODETECT = 0;
   Audiere_FF_WAV        = 1;
   Audiere_FF_OGG        = 2;
   Audiere_FF_FLAC       = 3;
   Audiere_FF_MP3        = 4; //.MP3 .MP2
   Audiere_FF_MOD        = 5; //.MOD .XM .S3M .IT


type
   _BTAudiereSoundItem = record
       InUse   :boolean;
       Play    :longword;
       Data    :pointer;
       DataLen :longword;
       Sample  :longword;
       Source  :longword;
       Stream  :longword;      //todo alll data fields
   end;

   BTAudiereSoundLibrary = class
      private
         Audiere    :boolean; // Dll is ready for work
         AudiereDLL :longword;
         aDevice    :longword;
         aSoundItems: array of _BTAudiereSoundItem;
         aSoundItemsCount :longword;
         function   _GetNewSoundItem :longword;
      public
         constructor Create(DllPath:string='');
         destructor  Destroy; override;
         function    LoadSoundFromFile(name:string):longword;
         function    LoadSoundFromMemory(data:pointer; DataLen,DataType:longword):longword;
         function    LoadRawSoundFromMemory(data:pointer; DataLen, FrameCount, ChannelCount, SampleRate:longword):longword;
         procedure   Play(sHand,Loop,Volume:longword);
         procedure   Stop(sHand:longword);
         procedure   SetVolume(sHand,Volume:longword);
         procedure   Pause(sHand,on_off:longword);
         procedure   FreeSound(sHand:longword);
         property    IsItInstaled :boolean read Audiere;
   end;



implementation


uses
  Windows;


const
  AudiereDllName = 'audiere.dll';

type
  { TAudiereFileFormat }
  TAudiereFileFormat = (
    FF_AUTODETECT,
    FF_WAV,
    FF_OGG,
    FF_FLAC,
    FF_MP3,
    FF_MOD
  );

  { TAudiereSeekMode  }
  TAudiereSeekMode = (
    Audiere_Seek_Begin,
    Audiere_Seek_Current,
    Audiere_Seek_End
  );

  { TAudiereSoundEffectType }
  TAudiereSoundEffectType = (
    Audiere_SoundEffectType_Single,
    Audiere_SoundEffectType_Multiple
  );

  { TAudiereSampleFormat }
  TAudiereSampleFormat = (
    Audiere_SampleFormat_U8,
    Audiere_SampleFormat_S16
  );

  { TAudiereRefCounted  }
  TAudiereRefCounted = class
  public
    procedure Ref;   virtual; stdcall; abstract;
    procedure UnRef; virtual; stdcall; abstract;
  end;

  { TAudiereFile }
  TAudiereFile = class(TAudiereRefCounted)
  public
    function Read(aBuffer: Pointer; aSize: Integer): Integer; virtual; stdcall; abstract;
    function Seek(aPosition: Integer; aSeekMode: TAudiereSeekMode): Boolean; virtual; stdcall; abstract;
    function Tell: Integer; virtual; stdcall; abstract;
  end;

  { TAudiereSampleSource }
  TAudiereSampleSource = class(TAudiereRefCounted)
  public
    procedure GetFormat(var aChannelCount: Integer; var aSampleRate: Integer; var aSampleFormat: TAudiereSampleFormat); virtual; stdcall; abstract;
    function  Read(aFrameCount: Integer; aBuffer: Pointer): Integer;  virtual; stdcall; abstract;
    procedure Reset; virtual; stdcall; abstract;
    function  IsSeekable: Boolean; virtual; stdcall; abstract;
    function  GetLength: Integer; virtual; stdcall; abstract;
    procedure SetPosition(Position: Integer); virtual; stdcall; abstract;
    function  GetPosition: Integer; virtual; stdcall; abstract;
  end;

  { TAudiereOutputStream }
  TAudiereOutputStream = class(TAudiereRefCounted)
  public
    procedure Play; virtual; stdcall; abstract;
    procedure Stop; virtual; stdcall; abstract;
    function  IsPlaying: Boolean; virtual; stdcall; abstract;
    procedure Reset; virtual; stdcall; abstract;
    procedure SetRepeat(aRepeat: Boolean); virtual; stdcall; abstract;
    function  GetRepeat: Boolean; virtual; stdcall; abstract;
    procedure SetVolume(aVolume: Single); virtual; stdcall; abstract;
    function  GetVolume: Single; virtual; stdcall; abstract;
    procedure SetPan(aPan: Single); virtual; stdcall; abstract;
    function  GetPan: Single; virtual; stdcall; abstract;
    procedure SetPitchShift(aShift: Single); virtual; stdcall; abstract;
    function  GetPitchShift: Single; virtual; stdcall; abstract;
    function  IsSeekable: Boolean; virtual; stdcall; abstract;
    function  GetLength: Integer; virtual; stdcall; abstract;
    procedure SetPosition(aPosition: Integer); virtual; stdcall; abstract;
    function  GetPosition: Integer; virtual; stdcall; abstract;
  end;

  { TAudiereAudioDevice }
  TAudiereAudioDevice = class(TAudiereRefCounted)
  public
    procedure Update; virtual; stdcall; abstract;
    function  OpenStream(aSource: TAudiereSampleSource): TAudiereOutputStream; virtual; stdcall; abstract;
    function  OpenBuffer(aSamples: Pointer; aFrameCount, aChannelCount, aSampleRate: Integer; aSampelFormat: TAudiereSampleFormat):  TAudiereOutputStream; virtual; stdcall; abstract;
  end;

  { TAudiereSampleBuffer }
  TAudiereSampleBuffer = class(TAudiereRefCounted)
  public
    procedure GetFormat(var ChannelCount: Integer; var aSampleRate: Integer; var aSampleFormat: TAudiereSampleFormat); virtual; stdcall; abstract;
    function  GetLength: Integer; virtual; stdcall; abstract;
    function  GetSamples: Pointer; virtual; stdcall; abstract;
    function  OpenStream: TAudiereSampleSource; virtual; stdcall; abstract;
  end;

  { TAudiereSoundEffect }
  TAudiereSoundEffect = class(TAudiereRefCounted)
  public
    procedure Play; virtual; stdcall; abstract;
    procedure Stop; virtual; stdcall; abstract;
    procedure SetVolume(aVolume: Single); virtual; stdcall; abstract;
    function  GetVolume: Single; virtual; stdcall; abstract;
    procedure SetPan(aPan: Single); virtual; stdcall; abstract;
    function  GetPan: Single; virtual; stdcall; abstract;
    procedure SetPitchShift(aShift: Single); virtual; stdcall; abstract;
    function  GetPitchShift: Single; virtual; stdcall; abstract;
  end;

{ --- Audiere Routines -------------------------------------------------- }
var
  AudiereGetVersion                  : function: PChar; stdcall;
  AudiereGetSupportedFileFormats     : function: PChar; stdcall;
  AudiereGetSupportedAudioDevices    : function : PChar; stdcall;
  AudiereGetSampleSize               : function(aFormat: TAudiereSampleFormat): Integer; stdcall;
  AudiereOpenDevice                  : function(const aName: PChar; const aParams: PChar): TAudiereAudioDevice; stdcall;
  AudiereOpenSampleSource            : function(const aFilename: PChar; aFileFormat: TAudiereFileFormat): TAudiereSampleSource; stdcall;
  AudiereOpenSampleSourceFromFile    : function(aFile: TAudiereFile; aFileFormat: TAudiereFileFormat): TAudiereSampleSource; stdcall;
  AudiereCreateTone                  : function(aFrequency: Double): TAudiereSampleSource; stdcall;
  AudiereCreateSquareWave            : function(aFrequency: Double): TAudiereSampleSource; stdcall;
  AudiereCreateWhiteNoise            : function: TAudiereSampleSource; stdcall;
  AudiereCreatePinkNoise             : function: TAudiereSampleSource; stdcall;
  AudiereOpenSound                   : function(aDevice: TAudiereAudioDevice; aSource: TAudiereSampleSource; aStreaming: LongBool): TAudiereOutputStream; stdcall;
  AudiereCreateSampleBuffer          : function(aSamples: Pointer; aFrameCount, aChannelCount, aSampleRate: Integer; aSampleFormat: TAudiereSampleFormat): TAudiereSampleBuffer; stdcall;
  AudiereCreateSampleBufferFromSource: function(aSource: TAudiereSampleSource): TAudiereSampleBuffer; stdcall;
  AudiereOpenSoundEffect             : function(aDevice: TAudiereAudioDevice; aSource: TAudiereSampleSource; aType: TAudiereSoundEffectType): TAudiereSoundEffect; stdcall;
  AudiereCreateMemoryFile            : function(aBuffer: Pointer; BufferSize: Integer): TAudiereFile; stdcall;



function _AudiereLoadDLL(var AudiereDLL:longword; DllPath:ansistring): Boolean;
begin
  Result := False;

  DllPath := DllPath + AudiereDllName;
  AudiereDLL := LoadLibrary(@DllPath[1]);
  if(AudiereDLL = 0) then
  begin
    Exit;
  end;

  @AudiereGetVersion                   := GetProcAddress(AudiereDLL, '_AdrGetVersion@0');
  @AudiereGetSupportedFileFormats      := GetProcAddress(AudiereDLL, '_AdrGetSupportedFileFormats@0');
  @AudiereGetSupportedAudioDevices     := GetProcAddress(AudiereDLL, '_AdrGetSupportedAudioDevices@0');
  @AudiereGetSampleSize                := GetProcAddress(AudiereDLL, '_AdrGetSampleSize@4');
  @AudiereOpenDevice                   := GetProcAddress(AudiereDLL, '_AdrOpenDevice@8');
  @AudiereOpenSampleSource             := GetProcAddress(AudiereDLL, '_AdrOpenSampleSource@8');
  @AudiereOpenSampleSourceFromFile     := GetProcAddress(AudiereDLL, '_AdrOpenSampleSourceFromFile@8');
  @AudiereCreateTone                   := GetProcAddress(AudiereDLL, '_AdrCreateTone@8');
  @AudiereCreateSquareWave             := GetProcAddress(AudiereDLL, '_AdrCreateSquareWave@8');
  @AudiereCreateWhiteNoise             := GetProcAddress(AudiereDLL, '_AdrCreateWhiteNoise@0');
  @AudiereCreatePinkNoise              := GetProcAddress(AudiereDLL, '_AdrCreatePinkNoise@0');
  @AudiereOpenSound                    := GetProcAddress(AudiereDLL, '_AdrOpenSound@12');
  @AudiereCreateSampleBuffer           := GetProcAddress(AudiereDLL, '_AdrCreateSampleBuffer@20');
  @AudiereCreateSampleBufferFromSource := GetProcAddress(AudiereDLL, '_AdrCreateSampleBufferFromSource@4');
  @AudiereOpenSoundEffect              := GetProcAddress(AudiereDLL, '_AdrOpenSoundEffect@12');
  @AudiereCreateMemoryFile             := GetProcAddress(AudiereDLL, '_AdrCreateMemoryFile@8');

  if not Assigned(AudiereGetVersion) then Exit;
  if not Assigned(AudiereGetSupportedFileFormats) then Exit;
  if not Assigned(AudiereGetSupportedAudioDevices) then Exit;
  if not Assigned(AudiereGetSampleSize) then Exit;
  if not Assigned(AudiereOpenDevice) then Exit;
  if not Assigned(AudiereOpenSampleSource) then Exit;
  if not Assigned(AudiereOpenSampleSourceFromFile) then Exit;
  if not Assigned(AudiereCreateTone) then Exit;
  if not Assigned(AudiereCreateSquareWave) then Exit;
  if not Assigned(AudiereCreateWhiteNoise) then Exit;
  if not Assigned(AudiereCreatePinkNoise) then Exit;
  if not Assigned(AudiereOpenSound) then Exit;
  if not Assigned(AudiereCreateSampleBuffer) then Exit;
  if not Assigned(AudiereCreateSampleBufferFromSource) then Exit;
  if not Assigned(AudiereOpenSoundEffect) then Exit;

  Result := True;
end;


//------------------------------------------------------------------------------
constructor BTAudiereSoundLibrary.Create(DllPath:string='');
begin
   Audiere := false;
   aSoundItemsCount := 0;

   if _AudiereLoadDLL(AudiereDLL,ansistring(DllPath)) then
   begin
      TAudiereAudioDevice(aDevice) := AudiereOpenDevice('', '');
      if Assigned(TAudiereAudioDevice(aDevice)) then
      begin
         TAudiereAudioDevice(aDevice).Ref;
         Audiere := true;
      end;
   end;
end;

//------------------------------------------------------------------------------
destructor  BTAudiereSoundLibrary.Destroy;
begin
   if Audiere then
   begin

      TAudiereAudioDevice(aDevice).UnRef;
   end;
   if AudiereDLL <> 0 then
   begin
      FreeLibrary(AudiereDLL);
      AudiereDLL := 0;
      Audiere := false;
   end;
   inherited;
end;

//------------------------------------------------------------------------------
function    BTAudiereSoundLibrary._GetNewSoundItem :longword;
var i:longword;
begin
  //danger alocation need errors handle
  if aSoundItemsCount > 0  then
  begin
     for i:= 1 to aSoundItemsCount do
     begin
        if aSoundItems[i].InUse = false then
        begin
           Result := i;
           Exit; // found first free get out
        end;
     end;
  end;
  inc(aSoundItemsCount);
  if longword(Length(aSoundItems)) <= aSoundItemsCount then
  begin
     SetLength(aSoundItems, Length(aSoundItems) + 16); //grow by 16
  end;
  Result := aSoundItemsCount;
end;

//------------------------------------------------------------------------------
function    BTAudiereSoundLibrary.LoadRawSoundFromMemory(data:pointer; DataLen, FrameCount, ChannelCount, SampleRate:longword):longword;
var i:longword;
begin
   Result := 0;
   if Audiere then
   begin
      i := _GetNewSoundItem;
      if i <> 0 then
      begin
         aSoundItems[i].InUse := true;
         aSoundItems[i].DataLen := DataLen;
         aSoundItems[i].Data := Data;
         aSoundItems[i].Play := 0;

         TAudiereSampleBuffer(aSoundItems[i].Source) :=
         AudiereCreateSampleBuffer(Data, DataLen, ChannelCount, SampleRate ,Audiere_SampleFormat_S16);
         if aSoundItems[i].Source <> 0 then
         begin
            TAudiereOutputStream(aSoundItems[i].Stream) :=
            AudiereOpenSound(TAudiereAudioDevice(aDevice), TAudiereSampleSource(aSoundItems[i].Source), True);
            if aSoundItems[i].Stream <> 0 then
            begin
               TAudiereOutputStream(aSoundItems[i].Stream).Ref;
               Result := i; //Ok
            end;
         end;
      end;
   end;
end;

//------------------------------------------------------------------------------
function    BTAudiereSoundLibrary.LoadSoundFromMemory(data:pointer; DataLen,DataType:longword):longword;
var i:longword;
begin
   Result := 0;
   if Audiere then
   begin
      i := _GetNewSoundItem;
      if i <> 0 then
      begin
         aSoundItems[i].InUse := true;
         aSoundItems[i].DataLen := DataLen;
         aSoundItems[i].Data := Data;
         aSoundItems[i].Play := 0;

         TAudiereFile(aSoundItems[i].Sample) :=
            AudiereCreateMemoryFile(aSoundItems[i].Data,aSoundItems[i].DataLen);
         if aSoundItems[i].Sample <> 0 then
         begin
            TAudiereSampleSource(aSoundItems[i].Source) :=
               AudiereOpenSampleSourceFromFile(TAudiereFile(aSoundItems[i].Sample),TAudiereFileFormat(DataType));
            if aSoundItems[i].Source <> 0 then
            begin
               TAudiereOutputStream(aSoundItems[i].Stream) :=
               AudiereOpenSound(TAudiereAudioDevice(aDevice), TAudiereSampleSource(aSoundItems[i].Source), True);
               if aSoundItems[i].Stream <> 0 then
               begin
                 TAudiereOutputStream(aSoundItems[i].Stream).Ref;
                 Result := i; //Ok
               end;
            end;
         end;
      end;
      if Result = 0 then  FreeSound(i);
   end;
end;

//------------------------------------------------------------------------------
function    BTAudiereSoundLibrary.LoadSoundFromFile(name:string):longword;
var sz:longword;
    p:pointer;
    f:file of byte;
    info :TWin32FileAttributeData;

begin
   Result := 0;
   if Audiere then
   begin
      if not GetFileAttributesEx(PChar(Name), GetFileExInfoStandard, @info) then Exit;
      Assign(f,name);
      {$I-}
      reset(f);
      {$I+}
      if IOResult <> 0 then
      begin
         Exit; // File not founr
      end;

      sz := info.nFileSizeLow or ( info.nFileSizeHigh shl 32);
      p := nil;
      ReallocMem(p,sz);
      BlockRead(f,p^,sz);
      System.Close(f);

      Result := LoadSoundFromMemory(p,sz,Audiere_FF_AUTODETECT);
   end;
end;

//------------------------------------------------------------------------------
procedure   BTAudiereSoundLibrary.Play(sHand,Loop,Volume:longword);
begin
   if Volume > 100 then Volume := 100;
   if Audiere then
   begin
      if (sHand > 0) and (sHand <= aSoundItemsCount) then
      begin
         if aSoundItems[sHand].InUse then
         begin
            if aSoundItems[sHand].Play <> 0 then Stop(sHand);
//            TAudiereOutputStream(aSoundItems[sHand].Stream).Ref;
            TAudiereOutputStream(aSoundItems[sHand].Stream).Reset;
            TAudiereOutputStream(aSoundItems[sHand].Stream).SetRepeat(boolean(Loop));
            TAudiereOutputStream(aSoundItems[sHand].Stream).SetVolume(Volume / 100);
            TAudiereOutputStream(aSoundItems[sHand].Stream).Play;
            aSoundItems[sHand].Play := 1;
         end;
      end;
   end;
end;

//------------------------------------------------------------------------------
procedure   BTAudiereSoundLibrary.Stop(sHand:longword);
var i:longword;
begin
   if Audiere then
   begin
      if (sHand > 0) and (sHand <= aSoundItemsCount) then
      begin
         if aSoundItems[sHand].Play <> 0 then
         begin
            TAudiereOutputStream(aSoundItems[sHand].Stream).Stop;
//            TAudiereOutputStream(aSoundItems[sHand].Stream).UnRef;
            aSoundItems[sHand].Play := 0;
         end;
      end;
      if sHand = 0 then // do it for all
      begin
         if aSoundItemsCount < 1 then Exit;
         for i := 1 to aSoundItemsCount do Stop(i); // call my self
      end;

   end;
end;

//------------------------------------------------------------------------------
procedure   BTAudiereSoundLibrary.SetVolume(sHand,Volume:longword);
begin
   if Volume > 100 then Volume := 100;
   if Audiere then
   begin
      if (sHand > 0) and (sHand <= aSoundItemsCount) then
      begin
         if (aSoundItems[sHand].InUse) and (aSoundItems[sHand].Play = 1) then
         begin
            TAudiereOutputStream(aSoundItems[sHand].Stream).SetVolume(Volume / 100);
         end;
      end;
   end;
end;

//------------------------------------------------------------------------------
procedure   BTAudiereSoundLibrary.Pause(sHand,on_off:longword);
var i :longword;
begin
   if on_off > 1 then on_off := 1;
   if Audiere then
   begin
      if sHand = 0 then // 0  do it for all
      begin
         if aSoundItemsCount < 1 then Exit;
         for i  := 1 to aSoundItemsCount do Pause(i,on_off);
      end;

      if (sHand > 0) and (sHand <= aSoundItemsCount) then
      begin
         if aSoundItems[sHand].InUse then
         begin
            if boolean(on_off) then //Pause ON
            begin
               if aSoundItems[sHand].Play = 2 then
               begin
                  TAudiereOutputStream(aSoundItems[sHand].Stream).Play;
                  aSoundItems[sHand].Play := 1;
               end;
            end else begin
               if aSoundItems[sHand].Play = 1 then
               begin
                  TAudiereOutputStream(aSoundItems[sHand].Stream).Stop;
                  aSoundItems[sHand].Play := 2;
               end;
            end;
         end;
      end;
   end;
end;

//------------------------------------------------------------------------------
procedure   BTAudiereSoundLibrary.FreeSound(sHand:longword);
var i:longword;
begin
   if Audiere then
   begin
      if sHand = 0 then // 0  do it for all
      begin
         if aSoundItemsCount < 1 then Exit;
         for i  := 1 to aSoundItemsCount do FreeSound(i);
      end;

      if (sHand > 0) and (sHand <= aSoundItemsCount) then
      begin
         if aSoundItems[sHand].InUse then
         begin
            if aSoundItems[sHand].Play <> 0 then Stop(sHand);
            TAudiereOutputStream(aSoundItems[sHand].Stream).UnRef;
            aSoundItems[sHand].InUse := false;
         end;
      end;
   end;
end;

end.
