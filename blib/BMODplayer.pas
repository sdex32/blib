unit BMODplayer;

interface

uses BWinMMSound;

const mod_max_ch = 8; { MAX. MOD-CHANNELS }


type  mod_instrument = packed record
                    name    : array[0..21]of char;
                    length  : word;
                    finetune: byte;
                    def_vol : byte;
                    loop_start : word;
                    loop_length: word;
                   end;
      mod_header = packed record
                    song_name  : array[0..19]of char;
                    instrument : array[1..31]of mod_instrument;
                    song_length: byte;
                    ciaa_speed : byte;
                    song_arrangement : array[0..127]of byte;
                    modtype : array[0..3]of char;
                   end;
      my_mod_note = record
                    instrumentnr : byte;
                    toneheight : word;
                    effect : byte;
                    op : byte;
                   end;
      org_mod_note = packed record
                    instrumentnr : byte;
                    toneheight : byte;
                    effect : byte;
                    op : byte;
                   end;





type
      BTMODplayer = class
         private
            sbvolslide : array[1..mod_max_ch]of longint;
            sbportamento, sbportamentonote : array[1..mod_max_ch]of longint;
            sbtoneheight : array[1..mod_max_ch]of word; //todo
            sbarpeggiopos, sbarpeggio0, sbarpeggio1, sbarpeggio2 : array[1..mod_max_ch]of longint;

            mod_pat_row :longword;
            mod_mom_pat :longword;
            mod_arrangement_pos :longword;
            mod_BPM :longword;
            mod_num_ticks :longword;
            mod_ticks :longword;
            mod_timercalls :longword;




            TimerFreq :longword;      { TIMER FREQUENCY in Hz}


            mod_sam :array[1..31] of pointer; { SAMPLE-DATA }
            mod_pat :array[0..63,0..63,1..mod_max_ch]of my_mod_note; { MAX. 64 PATTERNS … 64 LINES … MOD_MAX_CH CHANNELS }
            mod_h :^mod_header;
            mod_master_vol :longint;
            mod_num_pat :longword; { NUMBER OF MOD-PATTERNS/MOD-CHANNELS }
            mod_num_ch :longword;
            mod_size :longword;
            mod_song :pointer;
            mod_work :boolean; // run
            aPlayer :BTWinMMSound;
            procedure _SetChannelRate(chan,rate : longword);
 //           procedure _MOD2Mem(mod_name : string);
         public
            constructor Create(Player :BTWinMMSound);
            destructor  Destroy; override;
            procedure   Play;
            procedure   Stop;
            procedure   Pause;
            procedure   Resume;
            procedure   SetVolume(vol :longword);
            function    OpenFromFile(mod_name :string):longint;
            function    OpenFromMemory(song :pointer; song_len:longword):longint;
      end;


implementation

uses windows;

{/// MOD Player

   sbMod v.0.1.2
   (C)2K-1 by CARSTEN WAECHTER aka THE TOXIC AVENGER/AINC.
   http://www.uni-ulm.de/~s_cwaech/
   modifyed by SDEX32
}

const
     VolumeData : array [0..15] of longword =
(              //  VOLUME divider 16:16
  $7FFF0000,  // 0   Mute
  $00100000,  // 1             15
  $00078000,  // 2             7.5  .5*65536/10 = 8000h
  $00050000,  // 3             5
  $0003C000,  // 4             3.75 .75*65536/100 = C000h
  $00030000,  // 5             3
  $00028000,  // 6             2.5
  $000223D7,  // 7             2.14 .14*65536/100 = 23D7h
  $0001E147,  // 8  Half       1.88 .88           = E147
  $0001AB85,  // 9             1.67 .67           = AB85
  $00018000,  // 10            1.5                = 8000
  $00015C28,  // 11            1.36 .36           = 5C28
  $00014000,  // 12            1.25               = 4000
  $00012666,  // 13            1.15 .15           = 2666
  $000111EB,  // 14            1.07 .07           = 11EB
  $00010000  // 15 Max Sound  1
);


      mod_max_vol =16; { MAX. MOD-VOLUME }

      MaxVolume   =63;

      mod_notes : array[0..60]of word=($36,$39,$3C,$40,$43,$47,$4C,$55,
                                       $5A,$5F,$65,$6B,$71,$78,$7F,$87,
                                       $8F,$97,$A0,$AA,$B4,$BE,$CA,$D6,
                                       $E2,$F0,$FE,$10D,$11D,$12E,$140,
                                       $153,$168,$17D,$194,$1AC,$1C5,$1E0,
                                       $1FC,$21A,$23A,$25C,$280,$2A6,$2D0,
                                       $2FA,$328,$358,$386,$3C1,$3FA,$436,
                                       $477,$4BB,$503,$54F,$5A0,$5F5,$650,
                                       $6B0,$6B0);
      FixedPointShift  = 16;
      SampleRate    :longword = 44100;





//------------------------------------------------------------------------------
procedure BTMODplayer._SetChannelRate(chan,rate : longword);
begin
 //todo  aPlayer.ChannelData.wkhz := ((3579364 div rate) shl FixedPointShift) div SampleRate;
end;

type
//   wary=array[0..0] of word;
   bary=array[0..0] of byte;


FUNCTION  GetNote(rate : word) : longint; { I DON'T KNOW IF THIS ONE IS ALRIGHT }
 Var v : longint;
BEGIN
  if (rate<=mod_notes[0]) then begin getnote:=0; exit; end;
  if (rate>=mod_notes[59]) then begin getnote:=59; exit; end;

  for v:=0 to 59 do
   if (rate=mod_notes[v]) or (rate<mod_notes[v+1]) then begin getnote:=v; exit; end;
END;

type MMvol = array [0..15] of dword;

procedure MODT(a:longword); stdcall;
 Var continue : boolean;
     MasterVol:^MMVol;
     ch : longword;
     obj:BTMODplayer;
 Label oncemore;
begin
  if a = 0 then exit;
  (*
  obj := pointer(a);
  if not obj.mod_work then exit;

  MasterVol:=@VolumeData;

  wsoundfreq := 44100 div 150; // to do next call;

  inc(obj.mod_timercalls,(((obj.mod_BPM*2) div 5) shl FixedPointShift) div obj.timerfreq); { TO BE INDEPENDENT OF THE TIMERFREQUENCY }

  oncemore:

  if (obj.mod_timercalls<=1 shl FixedPointShift) then exit;

  dec(obj.mod_timercalls,1 shl FixedPointShift);

  inc(obj.mod_ticks);

  if (obj.mod_ticks < obj.mod_num_ticks) then
  begin
     for ch:=1 to obj.mod_num_ch+1 do
     begin
        with wsound[ch] do
        begin

           if (obj.sbvolslide[ch]>0) then
           begin     { VOLUME SLIDE FX }
              inc(wvol,obj.sbvolslide[ch]);
              if (wvol>obj.mod_max_vol) then
              begin
                 wvol:=obj.mod_max_vol;
                 obj.sbvolslide[ch]:=0;
              end;
           end;

           if (obj.sbvolslide[ch]<0) then
           begin
              if (longint(wvol)+obj.sbvolslide[ch]<0) then
              begin
                 wvol:=0;
                 obj.sbvolslide[ch]:=0;
              end
              else inc(wvol,obj.sbvolslide[ch]);
           end;

           if (obj.sbportamento[ch]<>0) then
           begin  { PORTAMENTO FX }
              inc(obj.sbtoneheight[ch],obj.sbportamento[ch]);
              if (obj.sbportamentonote[ch]>0) then
              begin
                 if ((obj.sbtoneheight[ch]<obj.sbportamentonote[ch]) and
                     (obj.sbportamento[ch]<0)) or
                     ((obj.sbtoneheight[ch]>obj.sbportamentonote[ch]) and
                     (obj.sbportamento[ch]>0)) then
                 begin
                    obj.sbtoneheight[ch]:=obj.sbportamentonote[ch];
                    obj.sbportamento[ch]:=0;
                 end;
              end;
              if (obj.sbtoneheight[ch]<$36) then
              begin
                 obj.sbtoneheight[ch]:=$36;
                 obj.sbportamento[ch]:=0;
              end;
              obj._setchannelrate(ch,obj.sbtoneheight[ch]);
           end;

           if (obj.sbarpeggiopos[ch]>0) then
           begin  { ARPEGGIO FX }
              inc(obj.sbarpeggiopos[ch]);
              case (obj.sbarpeggiopos[ch] mod 3) of
                 0 : obj._setchannelrate(ch,obj.sbarpeggio2[ch]);
                 1 : obj._setchannelrate(ch,obj.sbarpeggio0[ch]);
                 2 : obj._setchannelrate(ch,obj.sbarpeggio1[ch]);
              end;
           end;

           Wvol := (( Wvol shl 16 ) div MasterVol^[obj.mod_master_vol] ) and $F;
        end; {with }
     end; { for }

     goto oncemore
  end;

  obj.mod_ticks:=0;
  continue:=false;

  for ch:=1 to obj.mod_num_ch do
  begin
     with obj.mod_pat[obj.mod_mom_pat,obj.mod_pat_row,ch] do
     begin
        with wsound[ch] do
        begin

           if (toneheight>0) and (effect<>3) then
           begin { FREQUENCY CHANGED }
              obj._setchannelrate(ch,toneheight);
              obj.sbtoneheight[ch]:=toneheight;
              obj.sbportamento[ch]:=0;
              obj.sbarpeggiopos[ch]:=0;
              obj.sbportamentonote[ch]:=0;
           end;

           if (instrumentnr>0) then
           begin { INSTRUMENT CHANGED }
              wsnd := dword(obj.mod_sam[instrumentnr]);
              wlen := obj.mod_h.instrument[instrumentnr].length;
              wbps := 8; {8bit simples }
              wvol := obj.mod_h.instrument[instrumentnr].def_vol*obj.mod_max_vol div MaxVolume;
              wofs := 0;
              wint := 0;

              if (obj.mod_h.instrument[instrumentnr].loop_length=0) then
              begin
                 wlop := 0; { LOOP ? }
              end else begin
                 wlop := 1; { yes loop }
                 wlpb :=obj.mod_h.instrument[instrumentnr].loop_start;
                 wlpe :=(obj.mod_h.instrument[instrumentnr].loop_length+obj.mod_h.instrument[instrumentnr].loop_start);
              end;

              obj.sbportamento[ch]:=0;
              obj.sbarpeggiopos[ch]:=0;
              obj.sbportamentonote[ch]:=0;
              obj.sbvolslide[ch]:=0;

              winuse := 1;
           end;

           case effect of
              0  : if (op>0) then
                   begin { ARPEGGIO .. DON'T KNOW IF THIS ONES ALRIGHT }
                      obj.sbarpeggiopos[ch]:=1;
                      obj.sbarpeggio0[ch]:=obj.sbtoneheight[ch];
                      if obj.sbarpeggio0[ch]<$36 then obj.sbarpeggio0[ch]:=$36;
                      if (getnote(obj.sbtoneheight[ch])-longint(op shr 4)<0) then obj.sbarpeggio1[ch]:=$36
                       else obj.sbarpeggio1[ch]:=mod_notes[getnote(obj.sbtoneheight[ch])-longint(op shr 4)];
                      if (getnote(obj.sbtoneheight[ch])-longint(op and $0F)<0) then obj.sbarpeggio2[ch]:=$36
                       else obj.sbarpeggio2[ch]:=mod_notes[getnote(obj.sbtoneheight[ch])-longint(op and $0F)];
                   end;
              1  : obj.sbportamento[ch]:=-op; { PORTAMENTO }
              2  : obj.sbportamento[ch]:=op;
              3  : if (toneheight>0) then   { PORTAMENTO TO NOTE }
                      if (obj.sbtoneheight[ch]<toneheight) then begin obj.sbportamento[ch]:=op; sbportamentonote[ch]:=toneheight; end
                        else begin obj.sbportamento[ch]:=-op; obj.sbportamentonote[ch]:=toneheight; end;
              9  : wofs:=(op shl 8); { SAMPLE-POSITION CHANGE }
          5,6,10 : if (op shr 4=0) then obj.sbvolslide[ch]:=-op else obj.sbvolslide[ch]:=op shr 4; { VOLUME SLIDE }
              11 : begin { POSITION JUMP }
                      obj.mod_pat_row:=0;
                      obj.mod_arrangement_pos:=op;
                      if obj.mod_arrangement_pos>=obj.mod_h.song_length then obj.mod_arrangement_pos:=0;
                      obj.mod_mom_pat:=obj.mod_h.song_arrangement[obj.mod_arrangement_pos];
                      continue:=true;
                   end;
              12 : wvol:=op*obj.mod_max_vol div MaxVolume; { VOLUME CHANGE }
              13 : begin { PATTERN BREAK }
                      obj.mod_pat_row:=op;
                      inc(obj.mod_arrangement_pos);
                      if obj.mod_arrangement_pos>=obj.mod_h.song_length then obj.mod_arrangement_pos:=0;
                      obj.mod_mom_pat:=obj.mod_h.song_arrangement[obj.mod_arrangement_pos];
                      continue:=true;
                   end;
              15 : if (op<=31) then obj.mod_num_ticks:=op else obj.mod_BPM:=op; { SET SPEED }
              14 : case (op shr 4) of
                    1  : begin { FINE PORTAMENTO }
                            dec(obj.sbtoneheight[ch],op and $0F);
                            if (obj.sbtoneheight[ch]<$36) then obj.sbtoneheight[ch]:=$36;
                            obj._setchannelrate(ch,obj.sbtoneheight[ch]);
                         end;
                    2  : begin
                            inc(obj.sbtoneheight[ch],op and $0F);
                            obj._setchannelrate(ch,obj.sbtoneheight[ch]);
                         end;
                    10 : begin { FINE VOLUME SLIDE }
                            inc(wvol,op and $0F);
                            if (wvol>mod_max_vol) then wvol:=obj.mod_max_vol;
                         end;
                    11 : if (longint(wvol)-longint(op and $0F)<0) then wvol:=0 else dec(wvol,op and $0F);
                    end; { case }
               end; { case }

            Wvol := (( Wvol shl 16 ) div MasterVol^[obj.mod_master_vol] ) and $F;
          end; { with wsounr }
     end;  { with mod }
  end; { for }

  if continue = false then
  begin
     inc(obj.mod_pat_row);
     if (obj.mod_pat_row>63) then
     begin
        obj.mod_pat_row:=0;
        inc(obj.mod_arrangement_pos);
        if obj.mod_arrangement_pos>=obj.mod_h.song_length then obj.mod_arrangement_pos:=0;
        obj.mod_mom_pat:=obj.mod_h.song_arrangement[obj.mod_arrangement_pos];
     end;
  end;

  goto oncemore
  *)
END;





//------------------------------------------------------------------------------
constructor BTMODplayer.Create(Player :BTWinMMSound);
begin
   aPlayer := Player;
   mod_work := false;
   mod_song := nil;
end;


//------------------------------------------------------------------------------
destructor  BTMODplayer.Destroy;
begin
   if mod_song <> nil then ReallocMem(mod_song,0);
   inherited;
end;

//------------------------------------------------------------------------------
procedure   BTMODplayer.Play;
begin
//   aPlayer.block8 := true;
   mod_arrangement_pos:=0;
   mod_mom_pat := mod_h.song_arrangement[0];
   mod_pat_row :=0;

   mod_BPM :=125;
   mod_num_ticks :=6;
   mod_ticks:=0;

   mod_timercalls :=0;
   timerfreq := 150;
   mod_work := true;
//   aPlayer.SetCallBack(150,@modt,longword(self));
end;

//------------------------------------------------------------------------------
procedure   BTMODplayer.Stop;
begin
  mod_work := false;
//  aPlayer.block8 := false;
//  aPlayer.SetCallBack(0,nil,0);
end;

//------------------------------------------------------------------------------
procedure   BTMODplayer.Pause;
begin
   mod_work := false;
end;

//------------------------------------------------------------------------------
procedure   BTMODplayer.Resume;
begin
   mod_work := true;
end;

//------------------------------------------------------------------------------
procedure   BTMODplayer.SetVolume(vol :longword);
begin
   if vol > 255 then vol := 255;
   mod_master_vol := (vol div 16) and $F;
end;

//------------------------------------------------------------------------------
function    BTMODplayer.OpenFromFile(mod_name :string):longint;
var f:file of byte;
    info :TWin32FileAttributeData;
    i:longword;
begin
   if mod_song <> nil then ReallocMem(mod_song,0);
   Result := -1; //err
   assign(f,mod_name);
   {$I-}
   reset(f);
   {$I+}
   if IOResult = 0 then
   begin // file exist
      if GetFileAttributesEx(PChar(mod_name), GetFileExInfoStandard, @info) then
      begin
         mod_size := info.nFileSizeLow; { mod is less dword }
         mod_song := nil;
         ReallocMem(mod_song,mod_size);
         if mod_song <> nil then
         begin
            blockread(f,mod_song^,mod_size,i);
            if mod_size = i then
            begin
               Result := OpenFromMemory(mod_song,mod_size);
            end;
         end;
         system.close(f);
      end;
   end;
end;


//------------------------------------------------------------------------------
function    BTMODplayer.OpenFromMemory(song :pointer; song_len:longword):longint;
var
     bu:^bary;
     v,v2,v3 : longint;
     note : org_mod_note;
     pt,pt2 : pointer;
     w:longint;
//     b:byte;
//     st:string;
begin

   mod_h := song;

   for v:=1 to 31 do with mod_h^ do
   begin
      instrument[v].length := swap(instrument[v].length) *2;
      instrument[v].loop_start := swap(instrument[v].loop_start) *2;
      instrument[v].loop_length := swap(instrument[v].loop_length) *2;
      if instrument[v].def_vol > MaxVolume then instrument[v].def_vol := MaxVolume;
   end; { CONVERSION OF AMIGA-WORDS }

   if (mod_h.modtype='6CHN') then mod_num_ch:=6
    else if (mod_h.modtype='8CHN') then mod_num_ch:=8
     else if (mod_h.modtype='12CH') then mod_num_ch:=12
      else if (mod_h.modtype='16CH') then mod_num_ch:=16
       else mod_num_ch:=4; { NUMBER OF CHANNELS }

   mod_num_pat := mod_size - sizeof(mod_h);
   for v:=1 to 31 do dec(mod_num_pat, mod_h.instrument[v].length);
   { CALCULATE NUM. OF PATTERNS }
   mod_num_pat := mod_num_pat div (sizeof(org_mod_note)*64*mod_num_ch);

   { READ PATTERNS }
   // blockread(f,pt^,mod_num_pat*64*mod_num_ch*sizeof(org_mod_note));
   pt2 := pointer(longword(song) + sizeof(mod_h));

   for v:=0 to mod_num_pat-1 do
    for v2:=0 to 63 do
     for v3:=1 to mod_num_ch do begin
       move(pt2^,note,sizeof(note));
       pt2 := pointer(longword(pt2) + sizeof(note));
       mod_pat[v,v2,v3].instrumentnr:=(note.instrumentnr and $F0) + (note.effect shr 4);
       mod_pat[v,v2,v3].toneheight:=((note.instrumentnr and $0F) shl 8) + note.toneheight;
       mod_pat[v,v2,v3].effect:=note.effect and $0F;
       mod_pat[v,v2,v3].op:=note.op;
   end; { CONVERSION OF DUMB NOTE-FORMAT TO USEFUL FORMAT }

   //move to need point
   pt := pointer(longword(song) + sizeof(mod_h) + mod_num_pat*64*mod_num_ch*sizeof(org_mod_note));

   for v:=1 to 31 do
   begin
      if mod_h.instrument[v].length > 0 then
      begin
         mod_sam[v] := pt;
         pt := pointer(longword(pt) + mod_h.instrument[v].length); // to next
         bu := mod_sam[v];
         for v2 := 0 to mod_h.instrument[v].length - 1 do
         begin
            bu^[v2] := smallint(bu[v2]) + 128;
         end;
      end;
   end; { READ SAMPLES }
end;



end.
