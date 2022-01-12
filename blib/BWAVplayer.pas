unit BWAVplayer;

interface

uses BWinMMSound;

type
      BTWAVplayer = class
         private
            aWav_ofs  :longword;
            aWav_song :pointer;
            aWav_size :longword;
            aPlayer :BTWinMMSound;
            aNumChannels :longword;
            aSampleRate :longword;
            aBitsPerSample :longword;
            aSongHandle :longword;
         public
            constructor Create(Player :BTWinMMSound);
            destructor  Destroy; override;
            procedure   Play;
            procedure   Stop;
            procedure   Pause;
            procedure   Resume;
            procedure   SetVolume(vol :longword);
            function    OpenFromFile(wav_name :string):longint;
            function    OpenFromMemory(wav_song :pointer; wav_song_len:longword):longint;
      end;

implementation

uses windows;

//------------------------------------------------------------------------------
constructor BTWAVplayer.Create(Player :BTWinMMSound);
begin
   aPlayer := Player;
   aWav_size := 0;
   aWav_song := nil;
   aSongHandle := 0;
end;


//------------------------------------------------------------------------------
destructor  BTWAVplayer.Destroy;
begin
   aPlayer.Close(aSongHandle);
   if aWav_song <> nil then ReallocMem(aWav_song,0);
   inherited;
end;

//------------------------------------------------------------------------------
procedure   BTWAVplayer.Play;
begin
   if aSongHandle <> 0 then aPlayer.Play(aSongHandle);
end;

//------------------------------------------------------------------------------
procedure   BTWAVplayer.Stop;
begin
   if aSongHandle <> 0 then aPlayer.Stop(aSongHandle);
end;

//------------------------------------------------------------------------------
procedure   BTWAVplayer.Pause;
begin
   if aSongHandle <> 0 then aPLayer.Pause(aSongHandle);
end;

//------------------------------------------------------------------------------
procedure   BTWAVplayer.Resume;
begin
   if aSongHandle <> 0 then aPLayer.Resume(aSongHandle);
end;

//------------------------------------------------------------------------------
procedure   BTWAVplayer.SetVolume(vol :longword);
begin

end;



//------------------------------------------------------------------------------
function    BTWAVplayer.OpenFromFile(wav_name :string):longint;
var f:file of byte;
    info :TWin32FileAttributeData;
    i:longword;
begin
   if aWav_song <> nil then ReallocMem(aWav_song,0);
   Result := -1; //err
   assign(f,wav_name);
   {$I-}
   reset(f);
   {$I+}
   if IOResult = 0 then
   begin // file exist
      if GetFileAttributesEx(PChar(wav_name), GetFileExInfoStandard, @info) then
      begin
         aWav_size := info.nFileSizeLow; { mod is less dword }
         aWav_song := nil;
         ReallocMem(aWav_song,aWav_size);
         if aWav_song <> nil then
         begin
            blockread(f,aWav_song^,aWav_size,i);
            if aWav_size = i then
            begin
               Result := OpenFromMemory(aWav_song,aWav_size);
            end;
         end;
         system.close(f);
      end;
   end;
end;


//------------------------------------------------------------------------------
function wav_callback(b:longword; data:pointer; len:longword):longint; stdcall;
var obj:BTWavplayer;
    p:pointer;
    i:longword;
begin
   Result := 0; // play
   obj := BTWavPlayer(b);
   if obj <> nil then
   begin
      if obj.aWav_ofs >= obj.aWav_size then
      begin
         obj.aWav_ofs := 0;
         Result := 1;
//         obj.Stop;
         Exit;
      end;
      p := pointer(longword(obj.aWav_song) + obj.aWav_ofs);
      i := obj.aWav_size - obj.aWav_ofs + 1;
      if i < len then
      begin
         Move(p^,data^,i);
         data := pointer(longword(data)+i);
         FillChar(data^,len-i,0);  // rest with Zero silent
         len := i;
      end else
//            if i < len then len := i;
         Move(p^,data^,len); // normal
      inc(obj.aWav_ofs,len);
   end;
end;


function    BTWAVplayer.OpenFromMemory(wav_song :pointer; wav_song_len:longword):longint;
var sz:longword;
    p:pointer;
    ps,chunk,donech,pas:longword;
    flg,i:longword;


    function  Get_DW(ofs:longword):longword;
    begin
       Result := longword( pointer( longword(p) + ofs )^);
    end;

    function  Get_W(ofs:longword):longword;
    begin
       Result := word( pointer( longword(p) + ofs )^);
    end;

begin
   flg := 0; // PCM
   aWav_song := nil;
   aSongHandle := 0;
   Result := -1; //err
   if wav_song = nil then Exit;
   p := wav_song;
   ps := 0;
   donech := 0;
   pas := 0;
   if wav_song_len > 12 then
   begin
      if (get_DW(ps) = $46464952) and (get_DW(ps+8)=$45564157)  then //RIFF ,,, WAVE
      begin
         sz := get_DW(ps+4); // chunk size;
         if sz <= wav_song_len then
         begin
            ps := ps + 12;
            repeat
               chunk := get_DW(ps);
               sz := get_DW(ps + 4); // size
               if (donech = 1) and (chunk = $61746164) then  //data
               begin
                  aWav_size := sz - 8;
                  aWav_song := pointer(longword(p)+ps+8);
                  inc(donech);
                  break;
               end;
               if (donech = 0) and (chunk = $20746D66) then  //fmt
               begin
                  inc(donech);
                  i := get_W(ps +8); // Format
                  if i <> 1 then //PCM
                  begin
                     if (i = 3) then flg := 8 //IERR float
                                else Exit; //unknown
                  end;
                  aNumChannels := get_W(ps +10);
                  if aNumChannels > 2 then aNumChannels := 2; //Ops
                  aSampleRate  := get_DW(ps +12);
                  aBitsPerSample := get_W(ps +22);
               end;
               ps := ps + sz + 8; // add chunk + size;
               inc(pas);
            until (pas > 4) or (ps > wav_song_len);

            if donech = 2 then
            begin
               if aSongHandle <> 0 then aPlayer.Close(aSongHandle);
               aSongHandle := aPlayer.OpenRawSound(aSampleRate,aNumChannels,aBitsPerSample,255,flg,@Wav_Callback,longword(self));
               if aSongHandle <> 0 then Result := 0;
            end;
         end;
      end;
   end;
end;


end.
