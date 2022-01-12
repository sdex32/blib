unit BDataPool;

interface

type  BTDataPool = class  // ALL in 1   (Stack, Stream, ItemsList(TDB))
         private
            aStackOrigin:longword;
            aStackOfs   :longword;
            aTDBsearchDown:boolean;
            aTDBstart   :longword;
            aTDBend     :longword;
            aKeyDataSize:longword;
            aOnlyDataSize:longword;
            aOldPosition:longword;
            aPosition   :longword;
            aPool       :pointer;
            aPoolSize   :longword;
            aPoolCap    :longword;
            aItemsCount :longword;
            aStack      :array [1..128] of longword;
            aStackPos   :longword;
            function    _add(sz:longword):longword;
            function    _GeterTDB(mode:longword; var id:longword; var Key:string; var DSize:longword; var Data:pointer):longint;
         public
            constructor Create;
            destructor  Destroy; override;
            procedure   Reset;
            function    AddItem(item_size :longword):longword;

            // stream functions
            function    SeekEx(new_position:longword):longword;
            function    Seek(new_position:longint):longword;
            function    SeekEnd:longword;

            procedure   WriteByte(value:byte);
            procedure   WriteWord(value:word);
            procedure   WriteLongword(value:longword);
            procedure   WriteShortint(value:shortint);
            procedure   WriteSmallint(value:smallint);
            procedure   WriteLongint(value:longint);
            procedure   WriteInteger(value:integer);
            procedure   WriteBoolean(value:boolean);
            procedure   WriteChar(value:char);
            procedure   WriteAnsistring(const value:ansistring; addlen:boolean = true);
            procedure   WriteString(const value:string; addlen:boolean = true);
            procedure   WriteLine(const value:string);
            procedure   WriteData(data:pointer; size:longword);

            function    ReadByte:byte;
            function    ReadWord:word;
            function    ReadLongword:longword;
            function    ReadShortInt:shortint;
            function    ReadSmallInt:smallint;
            function    ReadLongInt:longint;
            function    ReadInteger:integer;
            function    ReadBoolean:boolean;
            function    ReadChar:char;
            function    ReadAnsistring:ansistring;
            function    ReadString:string;
            function    ReadAnsiLine:ansistring;
            function    ReadLine:string;
            procedure   ReadData(data:pointer; size:longword);

            // in memory database table TINY DATA BASE
            procedure   SetTDBItemSize(KeySize,DataSize:longword);
            procedure   SetTDBscope(StartPosition,EndPosition:longword); //danger
            procedure   SetTDBsearchDirection(up:boolean);
            function    FetchTDB(row:longword; var id:longword; var Key,Data:string):longint;
            procedure   InsertTDB(id:longword; const Key,Data:string); overload;
            procedure   InsertTDB(id:longword; const Key:string; Data:pointer); overload;
            function    SelectTDB(Key:string; var id:longword; var Data:string):longint; overload;
            function    SelectTDB(Key:string; var id:longword; var Data:pointer; refData:boolean=true):longint; overload;
            function    SelectTDB(id:longword; var Key,Data:string):longint; overload;
            function    SelectTDB(id:longword; var Key:string; var Data:pointer; refData:boolean=true):longint; overload;

            procedure   PushPosition;
            procedure   PopPosition;

            // stack function
            procedure   PushData(Data:pointer; len:longword);
            procedure   PopData(var Data:pointer; len:longword; refData:boolean=true);

            // disk operations
            function    WriteToFile(file_name:string):longint;
            function    ReadFromFile(file_name:string):longint;

            function    GetPtr(an_ofs:longword):pointer; // call dynamicaly
            property    Pool:pointer read aPool;
            property    PoolSize:longword read aPoolSize;
            property    Position:longword read aPosition;
            property    OldPosition:longword  read aOldPosition;
            property    ItemsCount:longword read aItemsCount;
      end;





implementation





//------------------------------------------------------------------------------
constructor BTDataPool.Create;
begin
   aKeyDataSize := 0;
   aOnlyDataSize := 0;
   aTDBstart := 0;
   aTDBend := 0;
   aTDBsearchDown := false;
   aPoolCap := 0;
   aPool := nil;
   Reset;
end;



//------------------------------------------------------------------------------
destructor  BTDataPool.Destroy;
begin
   if aPool <> nil then ReallocMem(aPool,0);
   inherited;
end;

//------------------------------------------------------------------------------
procedure   BTDataPool.Reset;
begin
   aStackOrigin := $FFFFFFFF;
   aStackOfs := $FFFFFFFF;
   aPosition := 0;
   aPoolSize := 0;
   aItemsCount := 0;
   aStackPos := 0;
end;

//------------------------------------------------------------------------------
procedure   BTDataPool.PushPosition;
begin
   inc(aStackPos);
   if aStackPos > 128 then aStackPos := 128;
   aStack[aStackPos]:=aPoolSize;
end;

//------------------------------------------------------------------------------
procedure   BTDataPool.PopPosition;
begin
   if aStackPos = 0 then Exit;
   aPoolSize := aStack[aStackPos];
   dec(aStackPos);
end;

//------------------------------------------------------------------------------
function    BTDataPool._add(sz:longword):longword;
var l:longword;
begin
   Result := aPoolSize;
   l := aPoolSize + sz;
   if l > aPoolCap then
   begin
      l := ((l div 8192)+1)*8192;
      inc(aPoolCap,l);
      ReallocMem(aPool,aPoolCap);
   end;
   if aPool = nil then Result := 0
                  else inc(aPoolSize,sz); // next pool position
end;

//------------------------------------------------------------------------------
function    BTDataPool.AddItem(item_size :longword):longword;
begin
   Result := 0;
   if (aPosition + item_size) >= aPoolSize then _add(item_size);
   if aPool <> nil then
   begin
      Result := aPosition;
      aOldPosition := Result;
      inc(aPosition,item_size);
      inc(aItemsCount);
   end;
end;

//------------------------------------------------------------------------------
function    BTDataPool.SeekEx(new_position:longword):longword;
begin
   Result := aPosition;
   if new_position < aPoolSize then
   begin
      aOldPosition := aPosition;
      aPosition := new_position;
   end;
end;

//------------------------------------------------------------------------------
function    BTDataPool.Seek(new_position:longint):longword; // relative
var a:longint;
begin
   a := longint(aposition) + new_position;
   if a < 0 then a := 0;
   Result := SeekEx(a);
end;

//------------------------------------------------------------------------------
function    BTDataPool.SeekEnd:longword;
begin
   Result := aPosition;
   aOldPosition := Result;
   aPosition := aPoolSize - 1;
end;

//------------------------------------------------------------------------------
procedure   BTDataPool.WriteByte(value:byte);
begin
   WriteData(@value,sizeof(byte));
end;

//------------------------------------------------------------------------------
procedure   BTDataPool.WriteWord(value:word );
begin
   WriteData(@value,sizeof(word));
end;

//------------------------------------------------------------------------------
procedure   BTDataPool.WriteLongword(value:longword);
begin
   WriteData(@value,sizeof(longword));
end;

//------------------------------------------------------------------------------
procedure   BTDataPool.WriteShortInt(value:shortint);
begin
   WriteData(@value,sizeof(shortint));
end;

//------------------------------------------------------------------------------
procedure   BTDataPool.WriteSmallInt(value:smallint);
begin
   WriteData(@value,sizeof(smallint));
end;

//------------------------------------------------------------------------------
procedure   BTDataPool.WriteLongint(value:longint);
begin
   WriteData(@value,sizeof(longint));
end;

//------------------------------------------------------------------------------
procedure   BTDataPool.WriteInteger(value:integer);
begin
   WriteData(@value,sizeof(integer));
end;

//------------------------------------------------------------------------------
procedure   BTDataPool.WriteBoolean(value:boolean);
begin
   if value then WriteByte(1) else WriteByte(0);
end;

//------------------------------------------------------------------------------
procedure   BTDataPool.WriteChar(value:char);
begin
   WriteData(@value,sizeof(char));
end;

//------------------------------------------------------------------------------
procedure   BTDataPool.WriteAnsistring(const value:ansistring; addlen:boolean = true);
begin
   if addlen then WriteLongword(length(value));
   WriteData(@value[1],length(value));
end;

//------------------------------------------------------------------------------
procedure   BTDataPool.WriteString(const value:string; addlen:boolean = true);
begin
   if addlen then WriteLongword(length(value));
   WriteData(@value[1],length(value)*sizeof(char));
end;

//------------------------------------------------------------------------------
procedure   BTDataPool.WriteLine(const value:string);
begin
   WriteData(@value[1],length(value)*sizeof(char));
   WriteByte(13);
   WriteByte(10);
end;

//------------------------------------------------------------------------------
procedure   BTDataPool.WriteData(data:pointer; size:longword);
var p:pointer;
begin
   p := GetPtr(AddItem(size));
   if p <> nil then
   begin
      move(data^,p^,size);
   end;
end;

//------------------------------------------------------------------------------
function    BTDataPool.ReadByte:byte;
begin
   ReadData(@Result,sizeof(byte));
end;

//------------------------------------------------------------------------------
function    BTDataPool.ReadWord:word;
begin
   ReadData(@Result,sizeof(word));
end;

//------------------------------------------------------------------------------
function    BTDataPool.ReadLongword:longword;
begin
   ReadData(@Result,sizeof(longword));
end;

//------------------------------------------------------------------------------
function    BTDataPool.ReadShortInt:shortint;
begin
   ReadData(@Result,sizeof(shortint));
end;

//------------------------------------------------------------------------------
function    BTDataPool.ReadSmallInt:smallint;
begin
   ReadData(@Result,sizeof(smallint));
end;

//------------------------------------------------------------------------------
function    BTDataPool.ReadLongint:longint;
begin
   ReadData(@Result,sizeof(longint));
end;

//------------------------------------------------------------------------------
function    BTDataPool.ReadInteger:integer;
begin
   ReadData(@Result,sizeof(integer));
end;

//------------------------------------------------------------------------------
function    BTDataPool.ReadBoolean:boolean;
var b:byte;
begin
   ReadData(@b,sizeof(byte));
   if b = 1 then Result := true else Result := false;
end;

//------------------------------------------------------------------------------
function    BTDataPool.ReadChar:char;
begin
   ReadData(@Result,sizeof(char));
end;

//------------------------------------------------------------------------------
function    BTDataPool.ReadAnsistring:ansistring;
var w:longword;
begin
   ReadData(@w,sizeof(longword));
   Setlength(result,w);
   ReadData(@Result[1],w);
end;

//------------------------------------------------------------------------------
function    BTDataPool.ReadString:string;
var w:longword;
begin
   ReadData(@w,sizeof(longword));
   Setlength(result,w);
   ReadData(@Result[1],w*sizeof(char));
end;

//------------------------------------------------------------------------------
function    BTDataPool.ReadAnsiLine:ansistring;
var b:byte;
begin
   Result := '';
   while aPosition < aPoolSize do
   begin
      b := ReadByte;
      if b = 13 then
      begin
         ReadByte; //10
         break;
      end;
      Result := Result + ansichar(b);
   end;
end;

//------------------------------------------------------------------------------
function    BTDataPool.ReadLine:string;
var c:char;
begin
   Result := '';
   while aPosition < aPoolSize do
   begin
      c := ReadChar;
      if c = #13 then
      begin
         ReadChar; //10
         break;
      end;
      Result := Result + c;
   end;
end;

//------------------------------------------------------------------------------
procedure   BTDataPool.ReadData(data:pointer; size:longword);
var p:pointer;
begin
   p := GetPtr(aPosition);
   if (p <> nil) and (data <> nil) then
   begin
      move(p^,data^,size);
      aOldPosition := aPosition;
      inc(aPosition,size);
   end;
end;

//------------------------------------------------------------------------------
procedure   BTDataPool.SetTDBItemSize(KeySize,DataSize:longword);
begin
   aOnlyDataSize := DataSize;
   aKeyDataSize := 16 + KeySize*sizeof(char) + DataSize*sizeof(char);
end;

//------------------------------------------------------------------------------
procedure   BTDataPool.SetTDBsearchDirection(up:boolean);
begin
   if up then aTDBsearchDown := false
         else aTDBsearchDown := true;
end;

//------------------------------------------------------------------------------
procedure   BTDataPool.SetTDBscope(StartPosition,EndPosition:longword);
begin
   if StartPosition < EndPosition then
   begin
      if StartPosition < aPoolSize then aTDBstart := StartPosition;
      if EndPosition < aPoolSize then aTDBend := EndPosition;
   end;
end;

//------------------------------------------------------------------------------
function _Hash(const s:string):longword;
var i,w:longword;
begin
   w := length(s);
   Result := 2166136261;
   for i := 1 to w do Result := (Result xor Ord(s[i])) * 16777619;
end;

//------------------------------------------------------------------------------
procedure   BTDataPool.InsertTDB(id:longword; const Key,Data:string);
var w:longword;
begin
   w := aOnlyDataSize;
   aOnlyDataSize := length(data);
   InsertTDB(id,Key,@Data[1]);
   aOnlyDataSize := w;
end;

//------------------------------------------------------------------------------
procedure   BTDataPool.InsertTDB(id:longword; const Key:string; Data:pointer);
var p,d:pointer;
    w:longword;
begin
   if aKeyDataSize <> 0 then
   begin
      w := length(Key);
      if (aOnlyDataSize + w + 12) <= aKeyDataSize then
      begin
         p := GetPtr(AddItem(aKeyDataSize));
         if p<> nil then
         begin
            FillChar(p^,aKeyDataSize,0);
            longword(p^) := id;
            p := pointer(longword(p) + 4);

            longword(p^) := _Hash(Key);
            p := pointer(longword(p) + 4);

            longword(p^) := w;
            p := pointer(longword(p) + 4);
            w := w*sizeof(char);
            d := @Key[1];
            move(d^,p^,w);
            p := pointer(longword(p) + w);

            w := aOnlyDataSize;
            longword(p^) := w;
            p := pointer(longword(p) + 4);
            w := w*sizeof(char);
            move(Data^,p^,w);
         end;
      end;
   end;
end;


//------------------------------------------------------------------------------
function    BTDataPool.FetchTDB(row:longword; var id:longword; var Key,Data:string):longint;
var i,ii,k:longword;
    p,d:pointer;
begin
   Result := -1;
   if aPool <> nil then
   begin
      try
         Result := 100;
         i := aTDBstart;
         if i + aKeyDataSize > aPoolSize then Exit;
         if aTDBend = 0 then ii := aPoolSize
                        else ii := aTDBend;
         if aTDBsearchDown then i := ii - aKeyDataSize;

         if aTDBsearchDown then dec(i,row*aKeyDataSize)
                           else inc(i,row*aKeyDataSize);

         if (i < ii) and ( i >= aTDBstart) then
         begin
            p:=pointer(longword(aPool)+i);
            id :=longword(p^);
            p :=pointer(longword(p)+8);
            k := longword(p^);
            SetLength(Key,k);
            k := k*sizeof(char);
            p :=pointer(longword(p)+4);
            d := @Key[1];
            move(p^,d^,k);
            p := pointer(longword(p) + k);
            k := longword(p^);
            SetLength(Data,k);
            k := k*sizeof(char);
            p := pointer(longword(p)+4);
            d := @Data[1];
            move(p^,d^,k);
            Result := 0;
         end;
      except
         Result := -1;
      end;
   end;
end;

//------------------------------------------------------------------------------
function    BTDataPool._GeterTDB(mode:longword; var id:longword; var Key:string; var DSize:longword; var Data:pointer):longint;
var w,i,ii,k,m,s_id,s_hs:longword;
    p,d:pointer;
    r:longint;
    s:string;
begin
   Result := -1;
   s_hs := _Hash(key);
   s_id := id;
   id := 0;
   if mode = 0 then Key := '';
   if aPool <> nil then
   begin
      try
         r := 100;
         i := aTDBstart;
         if i + aKeyDataSize > aPoolSize then Exit;
         if aTDBend = 0 then ii := aPoolSize
                        else ii := aTDBend;
         if aTDBsearchDown then i := ii - aKeyDataSize;


         while (i < ii) and ( i >= aTDBstart) do
         begin
            w := 0;
            p:=pointer(longword(aPool)+i);
            if aTDBsearchDown then dec(i,aKeyDataSize)
                              else inc(i,aKeyDataSize);

            m :=longword(p^);
            p:=pointer(longword(p)+4);
            k :=longword(p^);
            if mode = 0 then
            begin
               if m = s_id then w := 1;
            end else begin
               if k = s_hs then w := 1;
            end;

            if w = 1 then
            begin
               p :=pointer(longword(p)+4);
               k := longword(p^);
               SetLength(s,k);
               k := k*sizeof(char);
               p :=pointer(longword(p)+4);
               d :=@s[1];
               move(p^,d^,k);
               if mode = 0 then
               begin
                  Key := s;
               end else begin
                  if Key <> s then continue;
               end;
               p := pointer(longword(p) + k);
               Dsize := longword(p^);
               Data :=pointer(longword(p)+4);
               id := m;
               r := 0;
               break;
            end else begin
               continue;
            end;
         end;
         Result := r;
      except

      end;
   end;
end;

//------------------------------------------------------------------------------
function    BTDataPool.SelectTDB(Key:string; var id:longword; var Data:string):longint;
var D,p:pointer;
    S:longword;
begin
   Data := '';
   S:=0;
   Result := _GeterTDB(1,id,Key,S,D);
   if Result = 0 then
   begin
      SetLength(data,s);
      p :=@Data[1];
      move(d^,p^,s*sizeof(char));
   end;
end;

//------------------------------------------------------------------------------
function    BTDataPool.SelectTDB(id:longword; var Key,Data:string):longint;
var D,p:pointer;
    S:longword;
begin
   Data := '';
   S:=0;
   Result := _GeterTDB(0,id,Key,S,D);
   if Result = 0 then
   begin
      SetLength(data,s);
      p := @Data[1];
      move(d^,p^,s*sizeof(char));
   end;
end;

//------------------------------------------------------------------------------
function    BTDataPool.SelectTDB(Key:string; var id:longword; var Data:pointer; refData:boolean=true):longint;
var D:pointer;
    S:longword;
begin
   if refData then Data := nil;
   Result := _GeterTDB(1,id,Key,S,D);
   if Result = 0 then if not refData then move(d^,data^,aOnlyDataSize) else Data := d;
end;

//------------------------------------------------------------------------------
function    BTDataPool.SelectTDB(id:longword; var Key:string; var Data:pointer; refData:boolean=true):longint;
var D:pointer;
    S:longword;
begin
   if refData then Data := nil;
   Result := _GeterTDB(0,id,Key,S,D);
   if Result = 0 then if not refData then move(d^,data^,aOnlyDataSize) else Data := d;
end;

//------------------------------------------------------------------------------
function    BTDataPool.GetPtr(an_ofs:longword):pointer; // call dynamicaly
begin
   if aPool = nil then Result := nil
                  else begin
                          if an_ofs < aPoolCap then
                             Result := pointer(longword(aPool) + an_ofs)
                          else Result := nil;
                  end;
end;

//------------------------------------------------------------------------------
function    BTDataPool.WriteToFile(file_name:string):longint;
var f:file of byte;
begin
   Result := -1;
   system.Assign(f,file_name);
   {$I-}
   rewrite(f);
   {$I+}
   if IOResult = 0 then
   begin
      BlockWrite(f,aPool^,aPoolSize);
      CloseFile(f);
      Result := 0;
   end;
end;


//------------------------------------------------------------------------------
function    BTDataPool.ReadFromFile(file_name:string):longint;
var f:file of byte;
    l,w:longword;
begin
   Result := -1;
   system.Assign(f,file_name);
   {$I-}
   system.reset(f);
   {$I+}
   if IOResult = 0 then
   begin
      l := system.FileSize(f);
      if aPoolSize < l then addItem(l - PoolSize);
      self.Reset;
      BlockRead(f,aPool^,l,w);
      aPoolSize := l;
      CloseFile(f);
      if l = w then Result := 0;
   end;
end;


//------------------------------------------------------------------------------
procedure   BTDataPool.PushData(Data:pointer; len:longword);
begin
   if aStackOrigin = $FFFFFFFF then aStackOrigin := aPosition;  // first
   aStackOfs := aPosition;
   WriteLongword(len);
   WriteData(Data,len);
end;

//------------------------------------------------------------------------------
procedure   BTDataPool.PopData(var Data:pointer; len:longword; refData:boolean=true);
var l:longword;
begin
   if refData then Data := nil;
   if aStackOfs <> $FFFFFFFF then
   begin

      aPosition := aStackOfs;
      l := ReadLongword;
      if l <> len then Exit;
      if refData then Data := GetPtr(aposition+4)
                 else ReadData(data,len);
      dec(longint(aStackOfs),len+4);
      if longint(aStackOfs) < longint(aStackOrigin) then
      begin
         aStackOrigin := $FFFFFFFF;
         aStackPos := $FFFFFFFF;
      end;

   end;
end;












type  BTStrPoolData = record
         Hash:longword;
         Value:string;
      end;
      BTStrPool = array of BTStrPoolData;

      BTStringPool = class
         private
            aPool     :BTStrPool;
            aCount    :longword;
            aCapacity :longword;
            function    _Hash(const s:string):longword;
            procedure   _Grow;

         public
            constructor Create;
            destructor  Destroy; override;
            procedure   Reset;
            function    Add(const s:string; overwrite:boolean=false):longword;
            function    Get(id:longword):string;
            procedure   Modify(id:longword; const s:string);
            property    Count:longword read aCount;
            property    Pool:BTStrPool read aPool; // start from zero
      end;

//TOOLS
type  _TR_DW_Byte = record
         case integer of
           0 : (DW:longword);
           1 : (A,B,C,D :byte);
           2 : (S:single);
      end;

function   LongwordToStr(d:longword):string;
begin
   Result := #1#2#1#1#32#32#32#32;
   Result[5] :=  char(_TR_DW_Byte(d).A);
   Result[6] :=  char(_TR_DW_Byte(d).B);
   Result[7] :=  char(_TR_DW_Byte(d).C);
   Result[8] :=  char(_TR_DW_Byte(d).D);
end;

function   SingleToStr(d:single):string;
begin
   Result := #1#3#1#1#32#32#32#32;
   Result[5] :=  char(_TR_DW_Byte(d).A);
   Result[6] :=  char(_TR_DW_Byte(d).B);
   Result[7] :=  char(_TR_DW_Byte(d).C);
   Result[8] :=  char(_TR_DW_Byte(d).D);
end;



//------------------------------------------------------------------------------
constructor BTStringPool.Create;
begin
   Reset;
   aCapacity := 0;
end;

//------------------------------------------------------------------------------
destructor  BTStringPool.Destroy;
begin
   Reset;
   inherited;
end;

//------------------------------------------------------------------------------
procedure   BTStringPool.Reset;
begin
   SetLength(aPool,0);
   aCount := 0;
end;

//------------------------------------------------------------------------------
function    BTStringPool._Hash(const s:string):longword;
var i:longword;
begin
   Result := Length(s);
   for i := 1 to Result do Result := (Result xor Ord(s[i])) * 16777619;
end;

//------------------------------------------------------------------------------
procedure   BTStringPool._Grow;
begin
   inc(aCount);
   if aCount > aCapacity then
   begin
      inc(aCapacity,32);
      SetLength(aPool, aCapacity);
   end;
end;

//------------------------------------------------------------------------------
function    BTStringPool.Add(const s:string; overwrite:boolean=false):longword;
var i,h:longword;
begin
   Result := 0;
   h := _Hash(s);
   if overwrite then
   begin
      for i := 1 to aCount do
      begin
         if aPool[i-1].hash = h then if aPool[i-1].value = s then Result := i;
      end;
      if Result <> 0 then Exit;
   end;
   _Grow;
   Result := aCount;
   aPool[Result-1].hash := h;
   aPool[Result-1].value := s;
end;

//------------------------------------------------------------------------------
function    BTStringPool.Get(id:longword):string;
begin
   Result := '';
   if (id > 0) and (id <= aCount)  then Result := aPool[id-1].value;
end;

//------------------------------------------------------------------------------
procedure   BTStringPool.Modify(id:longword; const s:string);
begin
   if (id > 0) and (id <= aCount) then
   begin
      aPool[id-1].Hash := _Hash(s);
      aPool[id-1].value := s;
   end;
end;














type  BTIdntData = record
         NHash:longword;
         Flag:longword;
         Typ:longword;
         Name:string;
         Value:string;
         Value2:string;
         Data:longword;
         Data2:longword;
      end;
      BTIdntPool = array of BTIdntData;

      BTIdentPool = class
         private
            aPool       :BTIdntPool;
            aCount      :longword;
            aCapacity   :longword;
            aStack      :array [1..128] of longword;
            aStackPos   :longword;
            function    _Hash(const s:string):longword;
         public
            constructor Create;
            destructor  Destroy; override;
            procedure   Reset;
            procedure   Push;  //scope sub function
            procedure   Pop;
            function    Add(const Name:string):longint;
            function    Find(const Name:string):longint;
            function    Get(const Name:string):longint; //if not fing then add
//            function    AddConst(const Name:string):longint;

(*

       WM          WM                  WMWMWMWM                    WMWM
         WM      WM              WMWMWMWMWMWMWMWMWMWM            WMWMWMWM
       WMWMWMWMWMWMWM          WMWMWMWMWMWMWMWMWMWMWMWM        WMWMWMWMWMWM
     WMWM  WMWMWM  WMWM        WMWMWM    WMWM    WMWMWM      WMWM  WMWM  WMWM
   WMWMWMWMWMWMWMWMWMWMWM      WMWMWMWMWMWMWMWMWMWMWMWM      WMWMWMWMWMWMWMWM
   WM  WMWMWMWMWMWMWM  WM          WMWMWM    WMWMWM            WM  WMWM  WM
   WM  WM          WM  WM        WMWM    WMWM    WMWM        WM            WM
         WMWM  WMWM                WMWM        WMWM            WM        WM


*)



            property    Count:longword read aCount;
            property    Pool:BTIdntPool read aPool; // start from zero
      end;

//------------------------------------------------------------------------------
constructor BTIdentPool.Create;
begin
   Reset;
   aCapacity := 0;
end;

//------------------------------------------------------------------------------
destructor  BTIdentPool.Destroy;
begin
   Reset;
   inherited;
end;

//------------------------------------------------------------------------------
procedure   BTIdentPool.Reset;
begin
   SetLength(aPool,0);
   aCount := 0;
   aStackPos := 0;
end;

//------------------------------------------------------------------------------
function    BTIdentPool._Hash(const s:string):longword;
var i:longword;
begin
   Result := Length(s);
   for i := 1 to Result do Result := (Result xor Ord(s[i])) * 16777619;
end;

//------------------------------------------------------------------------------
procedure   BTIdentPool.Push;
begin
   if aStackPos < 128 then
   begin
      inc(aStackPos);
      aStack[aStackPos] := aCount;
   end;
end;

//------------------------------------------------------------------------------
procedure   BTIdentPool.Pop;
begin
   if aStackPos > 0  then
   begin
      aCount := aStack[aStackPos];
      dec(aStackPos);
   end;
end;

//------------------------------------------------------------------------------
function    BTIdentPool.Add(const Name:string):longint;
begin
   //Grow functionm --
   inc(aCount);
   if aCount > aCapacity then
   begin
      inc(aCapacity,32);
      SetLength(aPool, aCapacity);  // realloc
   end;
   //-----------------

   //todo error handle

   Result := aCount - 1;
   aPool[Result].NHash := _Hash(Name);
   aPool[Result].Name := Name;
   aPool[Result].Flag := 0;
   aPool[Result].Typ := 0;
   aPool[Result].Value := '';
   aPool[Result].Value2 := '';
   aPool[Result].Data := 0;
   aPool[Result].Data2 := 0;
end;

//------------------------------------------------------------------------------
function    BTIdentPool.Find(const Name:string):longint;
var h,i:longword;
begin
   Result := -1; // not found
   h := _Hash(Name);
   if aCount > 0 then
   begin
      for i := aCount - 1 downto 0 do
      begin
         if aPool[i].NHash = h then
            if aPool[i].Name = Name then
            begin
               Result := i;
               break;
            end;
      end;
   end;
end;

//------------------------------------------------------------------------------
function    BTIdentPool.Get(const Name:string):longint; //if not fing then add
begin
   Result:=Find(Name);
   if Result < 0 then Result := Add(Name);
end;



end.
