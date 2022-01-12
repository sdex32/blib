unit BDate;

interface

uses Windows;

{ using windows structure _SYSTEMTIME
  _SYSTEMTIME = record   packed
  wYear :word;     //1601 through 30827
  wMonth :word;    //1-12
  wDayOfWeek :word;   //Sun-0 Mon-1 Tue-2 ... Fri-5 Sat-6
  wDay :word;      //1-31
  wHour :word;      //0-23
  wMinute :word;    //0-59
  wSecond :word;    //0-59
  wMilliseconds :word; //0-999

  Note SetDate can be use to test date,
  SetDate(Date,0,0,0) = today
}

function  SetDate(var D:_SYSTEMTIME; Year,Month,Day:longword):boolean;  // (Date,0,0,0) = today
function  GetToday:_SYSTEMTIME;
procedure SetRelativeDays(var Base:_SystemTime; Days:longint);
function  GetDaysBetween(date1,Date2:_SYSTEMTIME):longint;
procedure SetRelativeHours(var Base:_SystemTime; Hours:longint);
function  GetHoursBetween(date1,Date2:_SYSTEMTIME):longint;
procedure SetRelativeMinutes(var Base:_SystemTime; Minutes:longint);
function  GetMinutesBetween(date1,Date2:_SYSTEMTIME):longint;
function  IsLeapYear(Year: longword): Boolean;
function  DateToStr(D:_SYSTEMTIME; DateMask:string = '$D/$M/$YYY'):string;
function  StrToDate(var D:_SYSTEMTIME; const data_str:string):boolean;



implementation

uses BStrTools;

//------------------------------------------------------------------------------
procedure SetRelativeDays(var Base:_SystemTime; Days:longint);
var ft:_FILETIME;
begin
   SystemTimeToFIleTime(base,ft);
   int64(ft) := int64(ft) + int64(Days) * int64(24*60*60)*int64(10000000);
   FileTimeToSystemTime(ft,base);
end;

//------------------------------------------------------------------------------
function GetDaysBetween(date1,Date2:_SYSTEMTIME):longint;
var ft1,ft2:_FILETIME;
begin
   SystemTimeToFIleTime(date1,ft1);
   SystemTimeToFIleTime(date2,ft2);
   Result :=longint((int64(ft1)-int64(ft2)) div int64(24*60*60)*int64(10000000));
end;

//------------------------------------------------------------------------------
procedure SetRelativeHours(var Base:_SystemTime; Hours:longint);
var ft:_FILETIME;
begin
   SystemTimeToFIleTime(base,ft);
   int64(ft) := int64(ft) + int64(Hours) * int64(60*60)*int64(10000000);
   FileTimeToSystemTime(ft,base);
end;

//------------------------------------------------------------------------------
function GetHoursBetween(date1,Date2:_SYSTEMTIME):longint;
var ft1,ft2:_FILETIME;
begin
   SystemTimeToFIleTime(date1,ft1);
   SystemTimeToFIleTime(date2,ft2);
   Result :=longint((int64(ft1)-int64(ft2)) div int64(60*60)*int64(10000000));
end;

//------------------------------------------------------------------------------
procedure SetRelativeMinutes(var Base:_SystemTime; Minutes:longint);
var ft:_FILETIME;
begin
   SystemTimeToFIleTime(base,ft);
   int64(ft) := int64(ft) + int64(Minutes) * int64(60)*int64(10000000);
   FileTimeToSystemTime(ft,base);
end;

//------------------------------------------------------------------------------
function GetMinutesBetween(date1,Date2:_SYSTEMTIME):longint;
var ft1,ft2:_FILETIME;
begin
   SystemTimeToFIleTime(date1,ft1);
   SystemTimeToFIleTime(date2,ft2);
   Result :=longint((int64(ft1)-int64(ft2)) div int64(60)*int64(10000000));
end;

//------------------------------------------------------------------------------
function IsLeapYear(Year: longword): Boolean;
begin
  Result := False;
  if ((Year div 4) = 0) and (not ((Year div 100) = 0)) or
     ((Year div 400) = 0) then
      Result := True;
end;

const MaxD:array[1..12] of longword = (31,28,31,30,31,30,31,31,30,31,30,31);
//------------------------------------------------------------------------------
function SetDate(var D:_SYSTEMTIME; Year,Month,Day:longword):boolean;
var dd:longword;
    ft:_FILETIME;
begin
   Result := false;
   FillChar(D,sizeof(_SYSTEMTIME),0);
   if (Year > 1600) and (Year < 30000) then
   begin
      D.wYear := Year;
      if (Month > 0) and (Month<13) then
      begin
         D.wMonth := Month;
         dd := MaxD[Month];
         if IsLeapYear(Year) and (Month = 2) then inc(dd);
         if (Day>0) and (Day<=dd) then
         begin
            D.wDay := Day;
            D.wHour := 12;
            SystemTimeToFileTime(D,ft);
            FileTimeToSystemTime(ft,D);  // to fill day of week
            Result := true;
         end;
      end;
   end;
   if (Year = 0) and (Month = 0) and (Day = 0) then
   begin
      GetLocalTime(d);
      Result := true;
   end;
end;

//------------------------------------------------------------------------------
function GetToday:_SYSTEMTIME;
begin
   GetLocalTime(Result);
end;

//------------------------------------------------------------------------------
function DateToStr(D:_SYSTEMTIME; DateMask:string = '$D/$M/$YYY'):string;
var r:string;
    i:longword;
begin
   { work only with specific format
      year    $YYYY  = 1920
              $Y     = 20   from 1920
              $y     = 1920
      month   $M     = 04
              $m     = 4    small char = no leading zero
      day     $D,$d
      Hour    @H,@h
      Minute  @M,@m
   }

   //s := DateMask;
   i := Pos('$D',DateMask);
   if i <> 0 then
   begin
      r := ToStrZlead(D.wDay,2);
      DateMask[i] := r[1];
      DateMask[i+1] := r[2];
   end;
   i := Pos('$d',DateMask);
   if i <> 0 then
   begin
      r := ToStr(D.wDay);
      DateMask:= ReplaceString(DateMask,'$d',r,0);
   end;

   i := Pos('$M',DateMask);
   if i <> 0 then
   begin
      r := ToStrZlead(D.wMonth,2);
      DateMask[i] := r[1];
      DateMask[i+1] := r[2];
   end;
   i := Pos('$m',DateMask);
   if i <> 0 then
   begin
      r := ToStr(D.wMonth);
      DateMask:= ReplaceString(DateMask,'$m',r,0);
   end;

   r := ToStrZlead(D.wYear,4);
   i := Pos('$YYY',DateMask);
   if i <> 0 then
   begin
      DateMask[i] := r[1];
      DateMask[i+1] := r[2];
      DateMask[i+2] := r[3];
      DateMask[i+3] := r[4];
   end else begin
      i := Pos('$Y',DateMask);
      if i <> 0 then
      begin
         DateMask[i] := r[3];
         DateMask[i+1] := r[4];  // last two digits
      end;
   end;
   i := Pos('$y',DateMask);
   if i <> 0  then
   begin
      r := ToStr(D.wYear);
      DateMask:= ReplaceString(DateMask,'$y',r,0);
   end;

   i := Pos('@H',DateMask);
   if i <> 0 then
   begin
      r := ToStrZlead(D.wHour,2);
      DateMask[i] := r[1];
      DateMask[i+1] := r[2];
   end;
   i := Pos('@h',DateMask);
   if i <> 0 then
   begin
      r := ToStr(D.wHour);
      DateMask:= ReplaceString(DateMask,'@h',r,0);
   end;

   i := Pos('@M',DateMask);
   if i <> 0 then
   begin
      r := ToStrZlead(D.wMinute,2);
      DateMask[i] := r[1];
      DateMask[i+1] := r[2];
   end;
   i := Pos('@m',DateMask);
   if i <> 0 then
   begin
      r := ToStr(D.wMinute);
      DateMask:= ReplaceString(DateMask,'@m',r,0);
   end;

   Result := DateMask;
end;

//------------------------------------------------------------------------------
function StrToDate(var D:_SYSTEMTIME; const data_str:string):boolean;
var s:string;
//    mm,dd,yyy,h,m:longword;
    w:longword;
begin
   Result := false;
   FillChar(D,sizeof(_SYSTEMTIME),0);
   s := TrimIn(data_str);


   if length(s) >=10 then
   begin
      // 1234567890
      // dd/mm/yyyy
      s := TrimIn(data_str);
      Result := SetDate(D,toVal(MidStr(s,7,4)),toVal(MidStr(s,4,2)),toVal(MidStr(s,1,2)));
       if Result then
      begin
         // test for (space) HH:MM
         s := ParseStr(s,1,' ');
         if length(s) = 5 then
         begin
            w := ToVal(midStr(s,1,2));
            if w <=23 then
            begin
               D.wHour := word(w);
               w := ToVal(midStr(s,4,2));
               if w <=59 then
               begin
                  D.wMinute := word(w);
               end else Result := false;
            end else Result := false;
         end;
      end;
   end;
end;



end.

