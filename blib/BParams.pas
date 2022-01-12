unit BParams;

interface

function CmdParamExist(pattern:string; casesense:boolean=false):longint;
function CmdParamExistAndGet(pattern:string; var Res:string; casesense:boolean=false; resdelimiter:char='|'):longint;
function CmdParamText(excludebegin:string; delimiter:char; var Res:string; casesense:boolean=false; resdelimiter:char='|'):longint;


implementation

uses BStrTools;

function CmdParamExist(pattern:string; casesense:boolean=false):longint;
var i:longword;
    s:string;
begin
   Result := 0;
   if ParamCount > 0  then
   begin
      if not casesense then pattern := UpperCase(pattern);
      for i := 1 to ParamCount do
      begin
         if not casesense then s := UpperCase(ParamStr(i))
                          else s := ParamStr(i);
         if s = pattern then  inc(Result);
      end;
   end;
end;

function CmdParamExistAndGet(pattern:string; var Res:string; casesense:boolean=false; resdelimiter:char='|'):longint;
var i:longword;
    s:string;
begin
   Result := 0;
   Res := '';
   if ParamCount > 0  then
   begin
      if not casesense then pattern := UpperCase(pattern);
      for i := 1 to ParamCount do
      begin
         if not casesense then s := UpperCase(ParamStr(i))
                          else s := ParamStr(i);
         if Pos(pattern,s) = 1 then
         begin
            if length(Res) > 0 then Res := Res + resdelimiter;
            Res := Res + RightStr(s,length(s)-length(pattern));
            inc(Result);
         end;
      end;
   end;
end;

function CmdParamText(excludebegin:string; delimiter:char; var Res:string; casesense:boolean=false; resdelimiter:char='|'):longint;
var i:longword;
    j:longint;
    b:boolean;
    s,p:string;
begin
   Result := 0;
   Res := '';
   if ParamCount > 0  then
   begin
      if not casesense then excludebegin := UpperCase(excludebegin);
      for i := 1 to ParamCount do
      begin
         if not casesense then s := UpperCase(ParamStr(i))
                          else s := ParamStr(i);
         j := 0;
         b := false;
         repeat
            p := ParseStr(excludebegin,j,delimiter);
            if length(p) > 0  then
            begin
               inc(j);
               b := false;
               if Pos(p,s) = 1 then b := true;
               if p = s then b := true;


            end else j := -1;
         until (j < 0) or b;
               if not b then
               begin
                  if length(Res) > 0 then Res := Res + resdelimiter;
                  Res := Res + s;
                  inc(Result);
               end;
      end;
   end;
end;

end.
