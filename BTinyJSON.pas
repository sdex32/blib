unit BTinyJSON;

interface


//call back function
// input flag = $80000000 use Callback in_search = pointer to CB
// the object will begin with '/'
type TinyJSON_CB = procedure(user:longword; const Obj,Value:string); stdcall;
// output aFlags = error of parsing  0 = no error

function  TinyJSON_Parse (const  in_JSON :String; in_Search :String; var aFlags :longint; res,user :longword ) :String;




implementation



procedure _PushObject(var Stack :String; Element :String);
begin
   Stack := Stack + '/' + Element
end;

procedure _PushArray(var Stack :String);
begin
   Stack := Stack + '[1]';
end;

procedure _PushInc(var Stack :String);
var i,j,m,mc :longword;
    c :char;
    dt:shortstring;
begin
   i := length(Stack);
   dt := '';
   if i > 0 then
   begin
      for j:= i downto 1 do
      begin
         c := Stack[j];
         if (j <> i) and ( c <> '[')  then dt := shortstring(c + string(dt));     //todo tova dali raboti
         if c = '[' then
         begin
            SetLength(Stack,j-1);
            val(string(dt),m,mc);
            inc(m);
            str(m,dt);
            Stack := Stack + '[' + string(dt) + ']';
            Break;
         end;
      end;
   end;

end;


procedure _Pop(var Stack :String; ar:longword);
var i,j :longword;
    c :char;
begin
   i := length(Stack);
   c := '/';
   if ar = 1 then c := '[';
   if i > 0 then
   begin
      for j:= i downto 1 do
      begin
         if Stack[j] = c then
         begin
            SetLength(Stack,j-1);
            Break;
         end;
      end;
   end;
end;


// serach format   /object/object[1][2]/object

function  TinyJSON_Parse (const in_JSON :String; in_Search :String; var aFlags :longint; res,user:longword ) :String;
var i,j,len,ipos :longword;
    c :Char;
    Search,Stack,Data :String;
    instr :longword;
    iner,bypass :longword;
    err :longint;
    StateStack,Dump :String;
    SSCapacity,SSpos:longword;
    CB:TinyJSON_CB;
    useCB:boolean;
    havehex,hexval:longword;

    procedure SkipBlankAndRead;
    begin
       c := in_JSON[ipos];
       if instr = 0 then
       begin
          while (ansichar(c) in [#1..#32]) and (ipos <=len) do
          begin
             inc(ipos);
             c := in_JSON[ipos];
          end;
       end;
    end;

    // Object  =  { "string" : value [, "s":v] }
    //   SState   O WZ     z    V   v          o
    //              W -wait " to sart Z
    // Value   = Object,array,string,number,true,false,null
    //            O  o  A   a S    s N    r t x  f x  n x
    // Array   =  [ Value  [, v] ]
    //   SState   A V            v

    procedure _PushSS(state:Char);
    begin
       inc(SSpos);
       if SSpos > SSCapacity then
       begin
          SetLength(Dump,1024);
          inc(SScapacity,1024);
          StateStack := StateStack + Dump;
       end;
       StateStack[SSpos] := state;
    end;


begin
   Result := '';

   CB := nil;
   useCB := false;
   if (aFlags and $80000000) <> 0  then // use callback
   begin
      useCB := true;
      CB := TinyJSON_CB(pointer(res));
      if res  = 0 then
      begin
         aFlags := -322;
         Exit;
      end;
   end;


   Stack := '';
   Search := '';
   instr := 0;
   err := 0;
   aFlags := 100; // not found
   SSpos := 0;
   SSCapacity := 1024;
   SetLength(StateStack, SSCapacity);
   hexval := 0;
   havehex := 0;



   i := length(in_Search);
   if i < 2 then
   begin
      if not useCB then
      begin
         aFlags := -1; // no data
         Exit;
      end;
   end else begin    // Adust search data
      for j:=1 to i do
      begin
         c := in_Search[j];
         if c = '\' then c:= '/';
         if (j = 1) and (c <> '/') then Search := '/'; //put first if not exist
         if (j = i) and (c = '/') then
         begin
            if not useCB then
            begin
               aFlags := -2; //  '/' in end
               Exit;
            end;
         end;
         Search := Search + c;
      end;
   end;

   iner := 0;
   ipos := 1;
   bypass := 0;
   len := length(in_JSON);
   while (ipos <=len) and (err = 0) do
   begin
      SkipBlankAndRead;
      inc(ipos);
      if havehex <> 0 then
      begin
         C:= UpCase(C);
         if C < 'A'  then hexval := (hexval shl 4) or longword(byte(C) - 48 {0})
                     else hexval := (hexval shl 4) or longword(byte(C) - 55 {A=65 it is 10 so -65+10 = 55});
         dec(havehex);
         if havehex <> 0 then continue;
         C:= char(hexval);
      end;

      if (SSpos = 0) and (c = '{') then
      begin
         _PushSS('O'); //OBject begin
         continue;
      end;
      if StateStack[SSpos] = 'O' then
      begin
         dec(ipos);
         _PushSS('W');
         continue;
      end;
      if StateStack[SSpos] = 'W' then
      begin
         if C = '"' then
         begin
            StateStack[SSpos] := 'Z';
            instr := 1;
            Data := '';
         end else begin aFlags := -3; Exit; end;
         continue;
      end;
      if ansichar(StateStack[SSpos]) in ['S','Z'] then
      begin // Acumulate string
         if (bypass=0) and (c = '"') then
         begin // end of string
            instr := 0;
            if StateStack[SSpos] = 'Z' then
            begin
               _PushObject(Stack,Data);
               StateStack[SSpos] := 'z';
               continue;
            end else begin
               StateStack[SSpos] := 's';

               if useCB then CB(User,Stack,Data);
               if Stack = Search then
               begin
                  aFlags := 0;
                  Result := Data;
                  Exit;
               end;
            end;
         end;
         if (bypass = 0) and (c ='\') then
         begin
            bypass := 1; continue;
         end;
         if bypass = 1 then
         begin  //   " , \ , /  pass auto
            if c = 'b' then c := #8;  // back space
            if c = 'f' then c := #12; // form feed
            if c = 't' then c := #9;  // tab
            if c = 'n' then c := #10; // line feed
            if c = 'r' then c := #13; // carrige return
            bypass := 0; // use once;
            if c = 'u' then //u 4 hex
            begin
               havehex := 4;
               hexval := 0;
               continue;
            end;
         end;
         Data := Data + c;
         continue;
      end;
      if StateStack[SSpos] = 'z' then
      begin
         if C = ':' then
         begin
            StateStack[SSpos] := 'V';
            continue;
         end else begin aFlags := -4; Exit; end;
      end;
      if StateStack[SSpos] = 'V' then
      begin
         if c = '"' then
         begin
            instr := 1;
            _PushSS('S');
            Data := '';
         end;
         if c = '{' then
         begin
            _PushSS('O');
         end;
         if c = '[' then
         begin
            _PushSS('A');
         end;
         if ansichar(c) in ['f','n','t'] then
         begin
            Data := c;
            _PushSS(c);
            iner := 1;
         end;
         if ansichar(c) in ['-','0'..'9'] then
         begin
            Data := c;
            _PushSS('N');
         end;
         continue;
      end;
      if ansichar(StateStack[SSpos]) in ['a','o','r','s','x'] then
      begin // end of value element
         dec(SSpos,2); //pop value type and value
         if c = ',' then // more elements
         begin
            if StateStack[SSpos] = 'O' then
            begin
               _PushSS('W'); // wait for Z
               _Pop(Stack,0);
            end;
            if StateStack[SSpos] = 'A' then
            begin
               _PushSS('V');
               _PushInc(Stack);
            end;
            continue;
         end;
         if (c = '}') and (StateStack[SSpos] = 'O') then
         begin
            _Pop(Stack,0);
            dec(SSpos);
            if SSpos <> 0  then  // nested obj
            begin
               StateStack[SSpos] := 'o';
               inc(SSpos);
               StateStack[SSpos] := 'o';
            end;
            if SSpos = 0 then Exit; // end of objects
         end else begin
             if (c = ']') and (StateStack[SSpos] = 'A') then
             begin
                StateStack[SSpos] := 'a';
                StateStack[SSpos-1] := 'a';
                i := 0;
                if StateStack[SSpos-2] = 'A' then i := 1; // nested array pop
                _Pop(Stack,i);
             end else begin
                 aFlags := -5; Exit;
             end;
         end;
         continue;
      end;
      if ansichar(StateStack[SSpos]) in ['f','n','t'] then
      begin
         inc(iner);
         Data := Data + c;
         if iner = 4 then
         begin
            i := 0;
            if (Data = 'true') then i := 1;
            if (Data = 'null') then i := 1;
            if (Data = 'fals') then
            begin
               if iPos <= len then
               begin
                  c := in_JSON[ipos];
                  inc(ipos);
                  Data := Data + c;
                  if c = 'e' then i := 1;
               end;
            end;

            if useCB then CB(User,Stack,Data);
            if Stack = Search then
            begin
               aFlags := 0;
               Result := Data;
               Exit;
            end;
            StateStack[SSpos] := 'x';
            if i = 0 then begin aFlags := -6; Exit; end;
         end;
         continue;
      end;
      if StateStack[SSpos] = 'N' then
      begin
         dec(ipos); // corection
         while (ansichar(c) in ['0'..'9']) and (ipos <= len) do
         begin
            Data := Data + c;
            inc(ipos);
            if (ipos <= len) then c := in_JSON[ipos];
         end;
         if c = '.' then
         begin
            Data := Data + c;
            inc(ipos);
            i := 0;
            if (ipos <= len) then c := in_JSON[ipos];
            while (ansichar(c) in ['0'..'9']) and (ipos <= len) do
            begin
               Data := Data + c;
               inc(ipos);
               if (ipos <= len) then c := in_JSON[ipos];
               inc(i);
            end;
            if i = 0 then begin aFlags := -7; Exit; end;
         end;
         if ansichar(c) in ['e','E'] then
         begin
            i := 0;
            Data := Data + c;
            inc(ipos);
            if (ipos <= len) then c := in_JSON[ipos];
            if ansichar(c) in ['-','+'] then
            begin
               Data := data + c;
               inc(ipos);
               if (ipos <= len) then c := in_JSON[ipos];
            end;
            while (ansichar(c) in ['0'..'9']) and (ipos <= len) do
            begin
               Data := Data + c;
               inc(ipos);
               if (ipos <= len) then c := in_JSON[ipos];
               inc(i);
            end;
            if i = 0 then begin aFlags := -7; Exit; end;
         end;

         if useCB then CB(User,Stack,Data);
         if Stack = Search then
         begin
            aFlags := 0;
            Result := Data;
            Exit;
         end;
         StateStack[SSpos] := 'x';
         continue;
      end;
      if StateStack[SSpos] = 'A' then
      begin
         dec(ipos);
         _PushSS('V');
         _PushArray(Stack);
         continue;
      end;

   end;
end;

end.
