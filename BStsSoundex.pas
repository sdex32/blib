unit BStsSoundex;

interface

function GyrillicToLat(const in_str:string):string;

function StrKey_Soundex(const AStr:string):string;


implementation

uses BStrTools;

function GyrillicToLat(const in_str:string):string;
var i:longword;
    c:char;
begin
   Result := '';
   for i := 1 to length(in_str) do
   begin
      // only for BULGARIAN Cyrillic
      c := in_str[i];
      // to upcase
      if (longword(c) >= $430) and (longword(c)  <= $44F)  then c := char(longword(c) - $20);
      case c of
        'À' : Result := Result + 'A';
        'Á' : Result := Result + 'B';
        'Â' : Result := Result + 'V';
        'Ã' : Result := Result + 'G';
        'Ä' : Result := Result + 'D';
        'Å' : Result := Result + 'E';
        'Æ' : Result := Result + 'ZH';
        'Ç' : Result := Result + 'Z';
        'È' : Result := Result + 'I';
        'É' : Result := Result + 'Y';
        'Ê' : Result := Result + 'K';
        'Ë' : Result := Result + 'L';
        'Ì' : Result := Result + 'M';
        'Í' : Result := Result + 'N';
        'Î' : Result := Result + 'O';
        'Ï' : Result := Result + 'P';
        'Ð' : Result := Result + 'R';
        'Ñ' : Result := Result + 'S';
        'Ò' : Result := Result + 'T';
        'Ó' : Result := Result + 'U';
        'Ô' : Result := Result + 'F';
        'Õ' : Result := Result + 'H';
        'Ö' : Result := Result + 'TS';
        '×' : Result := Result + 'CH';
        'Ø' : Result := Result + 'SH';
        'Ù' : Result := Result + 'SHT';
        'Ú' : Result := Result + 'Y';
        'Ü' : Result := Result + 'Y';
        'Þ' : Result := Result + 'YU';
        'ß' : Result := Result + 'YA';   // end of the word by rule IA
      end;
   end;


end;


//------------------------------------------------------------------------------
// SoundEX
// 'A','E','I','O','U',' ','H','W','Y' ->  do nothing
// 'B','F','P','V':                  ch := '1';
// 'C','G','J','K','Q','S','X','Z':  ch := '2';
// 'D','T':                          ch := '3';
// 'L':                              ch := '4';
// 'M','N':                          ch := '5';
// 'R':                              ch := '6';
//
//                                          A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
const C_Soundex_val:array[0..25] of byte = (0,1,2,3,0,1,2,0,0,2,2,4,5,5,0,1,2,6,2,3,0,1,0,2,0,2);
function StrKey_Soundex(const AStr:string):string;
var i,j,k:longword;
    c,lc :char;
    instr:string;
begin
  Result := '';
  instr := Trim(UpperCase(Astr));
  j := length(instr);
  if j > 0 then
  begin
     k := 0;
     c := ' ';
     for i := 1 to j do
     begin
        lc := c;
        c := Upcase(instr[i]);
        if lc <> #32 then
        begin
           if (lc >= #$41) and (lc <= #$5A) then
           begin
              if i = 1 then
              begin
                 Result := c;
                 inc(k);
              end else begin
                 c := char(48 {0} + C_Soundex_val[longword(c)]);
                 if c <> '0' then
                 begin
                    if c <> lc then
                    begin
                       Result := Result + c;
                       inc(k);
                       if k = 4 then break;
                    end;
                 end;
              end;
           end else begin
              //error
           end;
        end;
     end;
  end;
end;


//------------------------------------------------------------------------------
// Metaphone

{a=pointer to input string
 lg=max length of return string
 res=pointer to buffer to place result string in - must be lg+1 bytes long}

function StrKey_MetaphoneKey(const AStr : String): String;
var
  b, c, d, e : string;
  inp, outp : string;
  vowels, frontv, varson, dbl : string;
  excppair, nxtltr : string;
  t, ii, jj, lng, lastchr : integer;
  curltr, prevltr, nextltr, nextltr2, nextltr3 : char;
  vowelafter, vowelbefore, frontvafter, silent, hard : boolean;
  alphachr : string;
  lg : Integer;
begin
  inp:=UpperCase(Trim(AStr));
  lg:=Length(inp);
{  showmessage(inp);}
  vowels:='AEIOU';
  frontv:='EIY';
  varson:='CSPTG';
  dbl:='.';  {Lets us allow certain letters to be doubled}
  excppair:='AGKPW';
  nxtltr:='ENNNR';
  alphachr:='ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  {Remove non-alpha characters}
  outp:='';
  for t:=1 to length(inp) do
    if pos(inp[t],alphachr)>0 then outp:=outp+inp[t];

  inp:=outp;
  outp:='';

  if length(inp)=0 then begin
    Result:='';
    exit;
  end;

  {Check rules at beginning of word}
  if length(inp)>1 then begin
    b:=inp[1];
    c:=inp[2];
    ii:=pos(excppair,b);
    jj:=pos(nxtltr,c);
    if (ii=jj) and (ii>0) then
      inp:=copy(inp,2,length(inp)-1);
  end;

  if inp[1]='X' then inp[1]:='S';

  if (length(inp)>2) and (copy(inp,1,2)='WH') then
    inp:='W'+copy(inp,3,length(inp)-2);

  if (length(inp)>1) and (inp[length(inp)]='S') then
    inp:=copy(inp,1,length(inp)-1);

  ii:=0;
  repeat
    ii:=ii+1;
    {Main Loop!}

    silent:=false;
    hard:=false;
    curltr:=inp[ii];
    vowelbefore:=false;
    prevltr:=' ';
    if ii>1 then begin
      prevltr:=inp[ii-1];
      if pos(prevltr,vowels)>0 then
        vowelbefore:=true;
    end;

    if ((ii=1) and (pos(curltr,vowels)>0)) then begin
      outp:=outp+curltr;
      continue;
    end;

    vowelafter:=false;
    frontvafter:=false;
    nextltr:=' ';
    if ii<length(inp) then begin
      nextltr:=inp[ii+1];
      if pos(nextltr,vowels)>0 then vowelafter:=true;
      if pos(nextltr,frontv)>0 then frontvafter:=true;
    end;

    {Skip double letters EXCEPT ones in variable double}
    if pos(curltr,dbl)=0 then
      if curltr=nextltr then
        continue;

    nextltr2:=' ';
    if (length(inp)-ii)>1 then
      nextltr2:=inp[ii+2];

    nextltr3:=' ';
    if (length(inp)-ii)>2 then
      nextltr3:=inp[ii+3];

    case curltr of

      'B' : begin
              silent:=false;
              if (ii=length(inp)) and (prevltr='M') then
                silent:=true;
              if not silent then outp:=outp+curltr;
            end;

      'C' : begin
              if not ((ii>2) and (prevltr='S') and frontvafter) then
                if ((ii>1) and (nextltr='I') and (nextltr2='A')) then
                  outp:=outp+'X'
                else
                  if frontvafter then begin
                    outp:=outp+'S';
                  end else begin
                    if ((ii>2) and (prevltr='S') and (nextltr='H')) then begin
                      outp:=outp+'K';
                    end else begin
                      if nextltr='H' then begin
                        if ((ii=1) and (pos(nextltr2,vowels)=0)) then
                          outp:=outp+'K'
                        else
                          outp:=outp+'X';
                      end else begin
                        if prevltr='C' then
                          outp:=outp+'C'
                        else
                          outp:=outp+'K';
                      end;
                    end;
                  end;
              end;

      'D' : begin
              if ((nextltr='G') and (pos(nextltr2,frontv)>0)) then
                outp:=outp+'J'
              else
                outp:=outp+'T';
            end;

      'G' : begin
              silent:=false;
              if ((ii<length(inp)) and (nextltr='H') and (pos(nextltr2,vowels)=0)) then
                silent:=true;
              if ((ii=length(inp)-4) and (nextltr='N') and (nextltr2='E') and
                (nextltr3='D')) then silent:=true
              else if ((ii=length(inp)-2) and (nextltr='N')) then silent:=true;
              if (prevltr='D') and frontvafter then silent:=true;
              if prevltr='G' then
                hard:=true;

              if not silent then begin
                if frontvafter and (not hard) then
                  outp:=outp+'J'
                else
                  outp:=outp+'K';
              end;

            end;

      'H' : begin
              silent:=false;
              if pos(prevltr,varson)>0 then silent:=true;
              if vowelbefore and (not vowelafter) then silent:=true;

              if not silent then outp:=outp+curltr;
            end;


      'F', 'J', 'L', 'M', 'N', 'R' : outp:=outp+curltr;

      'K' : if prevltr<>'C' then outp:=outp+curltr;

      'P' : if nextltr='H' then outp:=outp+'F' else outp:=outp+'P';

      'Q' : outp:=outp+'K';

      'S' : begin
              if ((ii>2) and (nextltr='I') and ((nextltr2='O') or (nextltr2='A'))) then
                outp:=outp+'X';
              if (nextltr='H') then
                outp:=outp+'X'
              else
                outp:=outp+'S';
            end;

      'T' : begin
              if ((ii>0) and (nextltr='I') and ((nextltr2='O') or (nextltr2='A'))) then
                outp:=outp+'X';
              if nextltr='H' then begin
                if ((ii>1) or (pos(nextltr2,vowels)>0)) then
                  outp:=outp+'0'
                else
                  outp:=outp+'T';
              end else
                if not ((ii<length(inp)-3) and (nextltr='C') and (nextltr2='H')) then
                  outp:=outp+'T';
            end;

      'V' : outp:=outp+'F';

      'W', 'Y' : if (ii<length(inp)-1) and vowelafter then outp:=outp+curltr;

      'X' : outp:=outp+'KS';

      'Z' : outp:=outp+'S';

    end;

  until (length(outp)>lg-1) or (ii>length(inp));

  Result:=outp;
end;


function StringInStrings(const AStr : String; ASearch : Array of String): Boolean;
var
  i : Integer;
begin
  Result:=False;
  for I := Low(ASearch) to High(ASearch) do
  begin
    result:=ASearch[i]=AStr;
    if Result then
      break;
  end;
end;

function CharInSet(A : char; ASearch : Array of Char): Boolean;
var
  i : Integer;
begin
  Result:=False;
  for I := Low(ASearch) to High(ASearch) do
  begin
    result:=ASearch[i]=A;
    if Result then
      break;
  end;
end;

type
  TDoubleMetaphoneAnswer = record
    Primary : String;
    Secondary : String;
  end;

function DoubleMetaPhoneKeys(const AStr : String): TDoubleMetaphoneAnswer;
var
	original : String;
	primary	: String;
	secondary  : String;
	len	: integer;
	last	 	: integer;
	current	: integer;
	strcur1	: Char;
	strnext1 : Char;
	strprev1 : Char;
	SlavoGermanic : Boolean;
  s : String;
begin


	SlavoGermanic	:= False;
  primary 		:= '';
	secondary 	:= '';
	current 		:= 1;
	len		  := length(s);
	last	 	    :=  len;

	original 		:= Trim(s)+' ';

	if Pos('W',original) + Pos('K',original) + Pos('CZ',original) + POS('WITZ',original) <> 0 then
		SlavoGermanic := True;

	//skip this at beginning of word
  if StringInStrings(Copy(original, 1, 2),['GN','KN','PN','WR','PS']) then
	 	current := current + 1;

	//Initial 'X' is pronounced 'Z' e.g. 'Xavier'
	if copy(original, 1, 1) = 'X' then
	begin
		primary := primary + 'S';//'Z' maps to 'S'
		secondary := secondary + 'S';
		current := current + 1;
	end;

	if StringInStrings(copy(original, 1, 1), ['A', 'E', 'I', 'O', 'U', 'Y']) then
	begin
		primary := primary + 'A';  // all init vowels now map to 'A'
		secondary := secondary + 'A';
		current := current + 1;
	end;

	while current <= len do
	begin
		if length(primary) >= 5 then break;

		strcur1 := copy(original, current, 1)[1];
		strnext1 := copy(original, (current + 1), 1)[1];
		strprev1 := copy(original, (current - 1), 1)[1];

		if CharInSet(strcur1,  ['A', 'E', 'I', 'O', 'U', 'Y', ' ', '''', '-']) then
			current := current + 1
		else
		if strcur1 = 'B' then   //  '-mb', e.g. 'dumb', already skipped over ...
		begin
			primary := primary + 'P';
			secondary := secondary + 'P';

			if strnext1 = 'B' then
				current := current + 2
			else
				current := current + 1;
		end
		else
		if strcur1 = '?' then
		begin
			primary := primary + 'S';
			secondary := secondary + 'S';
			current := current + 1;
		end
		else
		if strcur1 = 'C' then
		begin
			if strnext1 = 'H' then
			begin
				if copy(original, current, 4) = 'CHIA' then	//  italian 'chianti'
				begin
					primary := primary + 'K';
					secondary := secondary + 'K';
				end
				else
				begin
					if (current > 1)   //find 'michael'
						and (copy(original, current, 4) = 'CHAE') then
					begin
						 primary := primary + 'K';
						 secondary := secondary + 'X';
					end
					else
					begin
            if (current = 1) //		 greek roots e.g. 'chemistry', 'chorus'
							and (
                   StringInStrings(copy(original, current + 1, 5),['HARAC','HARIS'])
								or StringInStrings(copy(original, current + 1, 3),['HOR','HYM','HIA','HEM'])
							)
							and (copy(original, 1, 5) <> 'CHORE') then
						begin
							primary := primary + 'K';
							secondary := secondary + 'K';
						end
						else
						begin
							if 	(	StringInStrings(copy(original, 1, 4), ['VAN ', 'VON '])	// germanic, greek, or otherwise 'ch' for 'kh' sound
									or (copy(original, 1, 3) = 'SCH'
								)
								or StringInStrings( copy(original, current - 2, 6) , ['ORCHES', 'ARCHIT', 'ORCHID']) //	 'architect' but not 'arch', orchestra', 'orchid'
								or StringInStrings(copy(original, current + 2, 1) , ['T', 'S'])
								or 	(	CharInSet(strprev1,['A','O','U','E'])
											or (current = 1)
										)
									and StringInStrings(copy(original, current + 2, 1),['L','R','N','M','B','H','F','V','W',' ']) //	 e.g. 'wachtler', 'weschsler', but not 'tichner'
								) then
							begin
								primary := primary + 'K';
								secondary := secondary + 'K';
							end
							else
							begin
								if (current > 1) then
								begin
									if copy(original, 1, 2) = 'MC' then // e.g. 'McHugh'
									begin
										primary := primary + 'K';
										secondary := secondary + 'K';
									end
									else
									begin
										primary := primary + 'X';
										secondary := secondary + 'K';
									end
								end
								else
								begin
									primary := primary + 'X';
									secondary := secondary + 'X';
								end
							end
						end
					end
				end;
				current := current + 2;
			end //ch logic
			else
			begin
				if (strnext1 = 'C') //	 double 'C', but not McClellan'
					and not((current = 1)
							and (copy(original, 1, 1) = 'M')
						) then
				begin
					if StringInStrings(copy(original, current + 2, 1), ['I','E','H'])	// 'bellocchio' but not 'bacchus'
						and (copy(original, current + 2, 2) <> 'HU') then
					begin
						if (	(current = 2)	// 'accident', 'accede', 'succeed'
								and (strprev1 = 'A')
							)
							or StringInStrings(copy(original, current - 1, 5), ['UCCEE', 'UCCES']) then
						begin
							primary := primary + 'KS';
							secondary := secondary + 'KS';
						end
						else
						begin	// 'bacci', 'bertucci', other italian
							primary := primary + 'X';
							secondary := secondary + 'X';
							// e.g. 'focaccia' if copy(original, current, 4) := 'CCIA'
						end;
						current := current + 3;
					end
					else
					begin
						primary := primary + 'K'; //	 Pierce's rule
						secondary := secondary + 'K';
						current := current + 2;
					end
				end
				else
				begin
					if CharInSet(strnext1 ,  ['K','G','Q']) then
					begin
						primary := primary + 'K';
						secondary := secondary + 'K';
						current := current + 2;
					end
					else
					begin
						if CharInSet(strnext1 ,  ['I','E','Y']) then
						begin
							if StringInStrings(copy(original, current, 3), ['CIO','CIE','CIA'])	then // italian vs. english
							begin
								primary := primary + 'S';
								secondary := secondary + 'X';
							end
							else
							begin
								primary := primary + 'S';
								secondary := secondary + 'S';
							end;
							current := current + 2;
						end
						else
						begin
							if (strnext1 = 'Z') //	 e.g. 'czerny'
								and (copy(original, current -2, 4) <> 'WICZ') then
							begin
								primary := primary + 'S';
								secondary := secondary + 'X';
								current := current + 2;
							end
							else
							begin
								if (current > 2)  //  various gremanic
									and not StringInStrings(copy(original, current - 2,1) , ['A', 'E', 'I', 'O', 'U', 'Y'])
									and (copy(original, current - 1, 3) = 'ACH')
									and ((copy(original, current + 2, 1) <> 'I')
										and ((copy(original, current + 2, 1) <> 'E')
											or StringInStrings(copy(original, current - 2, 6), ['BACHER', 'MACHER'])
										)
									) then
								begin
									primary := primary + 'K';
									secondary := secondary + 'K';
									current := current + 2;
								end
								else
								begin
									if (current = 1) // special case 'caesar'
										and (copy(original, current, 6) = 'CAESAR') then
									begin
										primary := primary + 'S';
										secondary := secondary + 'S';
										current := current + 2;
									end
									else
									begin	// final else
										primary := primary + 'K';
										secondary := secondary + 'K';

										if StringInStrings(copy(original, current + 1, 2) , [' C',' Q',' G']) then //	 name sent in 'mac caffrey', 'mac gregor'
											current := current + 3
										else
										 	current := current + 1;
									end
								end
							end
						end
					end
				end
			end
		end
		else

		if strcur1 = 'D' then
		begin
			if strnext1 = 'G' then
			begin
				if StringInStrings(copy(original, current + 2, 1) , ['I','E','Y']) then
				begin
					primary := primary + 'J'; //	 e.g. 'edge'
					secondary := secondary + 'J';
					current := current + 3;
				end
				else
				begin
					primary := primary + 'TK'; //	 e.g. 'edgar'
					secondary := secondary + 'TK';
					current := current + 2;
				end
			end
			else
			begin
				if StringInStrings(copy(original, current, 2) , ['DT','DD']) then
				begin
					primary := primary + 'T';
					secondary := secondary + 'T';
					current := current + 2;
				end
				else
				begin
					primary := primary + 'T';
					secondary := secondary + 'T';
					current := current + 1;
				end
			end
		end
		else

		if strcur1 = 'F' then
		begin
			primary := primary + 'F';
			secondary := secondary + 'F';
			if (strnext1 = 'F') then
				current := current + 2
			else
				current := current + 1
		end
		else

		if strcur1 = 'G' then
		begin
			if (strnext1 = 'H') then
			begin
				if (current > 1)
					and not CharInSet(strprev1 ,['A', 'E', 'I', 'O', 'U', 'Y']) then
				begin
					primary := primary + 'K';
					secondary := secondary + 'K';
				end
				else
				begin

					if 	not(	((current > 2) //	 Parker's rule (with some further refinements) - e.g. 'hugh'
								and StringInStrings(copy(original, current - 2, 1) , ['B','H','D'])
							)	// e.g. 'bough'
							or ((current > 3)
								and StringInStrings(copy(original, current - 3, 1), ['B','H','D'])
							)	// e.g. 'broughton'
							or ((current > 4)
								and StringInStrings(copy(original, current - 4, 1), ['B','H'])
						)	) then
					begin
						if (current > 3)	//	 e.g. 'laugh', 'McLaughlin', 'cough', 'gough', 'rough', 'tough'
							and (strprev1 = 'U')
							and StringInStrings(copy(original, current - 3, 1) ,['C','G','L','R','T']) then
						begin
							primary := primary + 'F';
							secondary := secondary + 'F';
						end
						else
						begin
							if (current > 1)
								and (strprev1 <> 'I') then
							begin
								primary := primary + 'K';
								secondary := secondary + 'K';
							end
							else
							begin
								if (current < 4) then
								begin
									if (current = 1) then //	 'ghislane', 'ghiradelli'
									begin
										if (copy(original, current + 2, 1) = 'I') then
										begin
											primary := primary + 'J';
											secondary := secondary + 'J';
										end
										else
										begin
											primary := primary + 'K';
											secondary := secondary + 'K';
										end
									end
								end
							end
						end
					end
				end;
				current := current + 2;
			end
			else
			begin
				if (strnext1 = 'N') then
				begin
					if (current = 1)
						and StringInStrings(copy(original, 1,1) , ['A', 'E', 'I', 'O', 'U', 'Y'])
						and not SlavoGermanic then
					begin
						primary := primary + 'KN';
						secondary := secondary + 'N';
					end
					else
					begin
						// not e.g. 'cagney'
						if (copy(original, current + 2, 2) = 'EY')
							and (strnext1 <> 'Y')
							and not SlavoGermanic then
						begin
							primary := primary + 'N';
							secondary := secondary + 'KN';
						end
						else
						begin
							primary := primary + 'KN';
							secondary := secondary + 'KN';
						end
					end;
					current := current + 2;
				end
				else
				begin
					if (copy(original, current + 1, 2) = 'LI') //	 'tagliaro'
						and not SlavoGermanic then
					begin
						primary := primary + 'KL';
						secondary := secondary + 'L';
						current := current + 2;
					end
					else
					begin
						if (current = 1) //		 -ges-, -gep-, -gel- at beginning
							and ((strnext1 = 'Y')
								or StringInStrings(copy(original, current + 1, 2) , ['ES','EP','EB','EL','EY','IB','IL','IN','IE', 'EI','ER'])
							) then
						begin
							primary := primary + 'K';
							secondary := secondary + 'J';
							current := current + 2;
						end
						else
						begin
							if ((copy(original, current + 1, 2) = 'ER') //	 -ger-, -gy-
								or (strnext1 = 'Y')
								)
							 	and not StringInStrings(copy(original, 1, 6) ,['DANGER','RANGER','MANGER'])
							 	and not CharInSet(strprev1, ['E', 'I'])
							 	and not StringInStrings(copy(original, current - 1, 3) , ['RGY','OGY']) then
							begin
								primary := primary + 'K';
								secondary := secondary + 'J';
								current := current + 2;
							end
							else
							begin
								if CharInSet(strnext1, ['E','I','Y'])	// italian e.g. 'biaggi'
									or StringInStrings(copy(original, current -1, 4), ['AGGI','OGGI']) then
								begin
									if (StringInStrings(copy(original, 1, 4), ['VAN ', 'VON '])  //	 obvious germanic
										or (copy(original, 1, 3) = 'SCH')
										)
										or (copy(original, current + 1, 2) = 'ET') then
									begin
										primary := primary + 'K';
										secondary := secondary + 'K';
									end
									else
									begin
										// always soft if french ending
										if copy(original, current + 1, 4) = 'IER ' then
										begin
											primary := primary + 'J';
											secondary := secondary + 'J';
										end
										else
										begin
											primary := primary + 'J';
											secondary := secondary + 'K';
										end
									end;
									current := current + 2;
								end
								else
								begin //	 other options exausted call it k sound
									primary := primary + 'K';
									secondary := secondary + 'K';
									if (strnext1 = 'G') then
										current := current + 2
									else
										current := current + 1;
								end
							end
						end
					end
				end
			end
		end
		else

		if strcur1 = 'H' then
		begin
			if ((current = 1) // 	 only keep if first & before vowel or btw. 2 vowels
					or CharInSet(strprev1, ['A', 'E', 'I', 'O', 'U', 'Y'])
				)
				and  CharInSet(strnext1, ['A', 'E', 'I', 'O', 'U', 'Y']) then
			begin
				primary := primary + 'H';
				secondary := secondary + 'H';
				current := current + 2;
			end
			else
				current := current + 1;
		end
		else

		if strcur1 = 'J' then
		begin
			if (copy(original, current, 4) = 'JOSE') //	 obvious spanish, 'jose', 'san jacinto'
				or (copy(original, 1, 4) = 'SAN ') then
			begin
				if ((current = 1)
					and (copy(original, current + 4, 1) = ' ')
					)
					or (copy(original, 1, 4) = 'SAN ') then
				begin
					primary := primary + 'H';
					secondary := secondary + 'H';
				end
				else
				begin
					primary := primary + 'J';
					secondary := secondary + 'H';
				end;

				current := current + 1;
			end
			else
			begin
				if current = 1 then
				begin
					primary := primary + 'J'; //  Yankelovich/Jankelowicz
					secondary := secondary + 'A';
					current := current + 1;
				end
				else
				begin
					if CharInSet(strprev1, ['A', 'E', 'I', 'O', 'U', 'Y']) //  spanish pron. of .e.g. 'bajador'
						and not SlavoGermanic
						and CharInSet(strnext1, ['A','O']) then
					begin
						primary := primary + 'J';
						secondary := secondary + 'H';
						current := current + 1;
					end
					else
					begin
						if (current = last) then
						begin
							primary := primary + 'J';
//							secondary := secondary + '';
							current := current + 1;
						end
						else
						begin
							if charinSet(strnext1, ['L','T','K','S','N','M','B','Z'])
								and not CharInSet(strprev1, ['S','K','L']) then
							begin
								primary := primary + 'J';
								secondary := secondary + 'J';
								current := current + 1;
							end
							else
							begin
								if (strnext1 = 'J') then // it could happen
									current := current + 2
								else
									current := current + 1
							end
						end
					end
				end
			end
		end
		else

		if strcur1 = 'K' then
		begin
			primary := primary + 'K';
			secondary := secondary + 'K';

			if (strnext1 = 'K') then
				current := current + 2
			else
				current := current + 1
		end
		else

		if strcur1 = 'L' then
		begin
			if (strnext1 = 'L') then
			begin
				if ((current = (len - 3) ) //	 spanish e.g. 'cabrillo', 'gallegos'
					and StringInStrings(copy(original, current - 1, 4) , ['ILLO','ILLA','ALLE'])
					)
					or ((StringInStrings(copy(original, last - 1, 2), ['AS','OS'])
							or StringInStrings(copy(original, last, 1) , ['A','O'])
						)
						and (copy(original, current - 1, 4) = 'ALLE')
					) then
					primary := primary + 'L' //	Alternate is silent
				else
				begin
					primary := primary + 'L';
					secondary := secondary + 'L';
				end;
        current := current + 2;
			end
			else
			begin
				current := current + 1;
				primary := primary + 'L';
				secondary := secondary + 'L';
			end
		end
		else

		if strcur1 = 'M' then
		begin
			primary := primary + 'M';
			secondary := secondary + 'M';

			if (copy(original, current - 1, 3) = 'UMB')
					and ((current + 1 = last)
						or (copy(original, current + 2, 2) = 'ER')
					)  //	 'dumb', 'thumb'
				or (strnext1 = 'M') then
				current := current + 2
			else
				current := current + 1
		end
		else

		if CharInSet(strcur1 , ['N','?']) then
		begin
			primary := primary + 'N';
			secondary := secondary + 'N';

			if CharInSet(strnext1, ['N','?']) then
				current := current + 2
			else
				current := current + 1
		end
		else

		if strcur1 = 'P' then
		begin
			if (strnext1 = 'H') then
			begin
				current := current + 2;
				primary := primary + 'F';
				secondary := secondary + 'F';
			end
			else
			begin
		//	 also account for 'campbell' and 'raspberry'
				if CharInSet(strnext1, ['P','B']) then
					current := current + 2
				else
				begin
					current := current + 1;
					primary := primary + 'P';
					secondary := secondary + 'P';
				end
			end
		end
		else

		if strcur1 = 'Q' then
		begin
			primary := primary + 'K';
			secondary := secondary + 'K';

			if (strnext1 = 'Q') then
				current := current + 2
			else
				current := current + 1
		end
		else

		if strcur1 = 'R' then
		begin
			if (current = last) //	 french e.g. 'rogier', but exclude 'hochmeier'
				and not SlavoGermanic
				and (copy(original, current - 2, 2) = 'IE')
				and not StringInStrings(copy(original, current - 4, 2) , ['ME','MA']) then
				secondary := secondary + 'R'// primary := primary + ''
			else
			begin
				primary := primary + 'R';
				secondary := secondary + 'R';
			end;

			if (strnext1 = 'R') then
			begin
				if copy(original, current, 3) = 'RRI' then // alternate Kerrigan, Corrigan
					secondary := secondary + 'R';

				current := current + 2;
			end
			else
				current := current + 1;
		end
		else

		if strcur1 = 'S' then
		begin
			if StringInStrings(copy(original, current - 1, 3), ['ISL','YSL']) then // special cases 'island', 'isle', 'carlisle', 'carlysle'
				current := current + 1 //	silent s
			else
			begin
				if copy(original, current, 2) = 'SH' then
				begin
//					 germanic
					if StringInSTrings(copy(original, current + 1, 4), ['HEIM','HOEK','HOLM','HOLZ']) then
					begin
						primary := primary + 'S';
						secondary := secondary + 'S';
					end
					else
					begin
						primary := primary + 'X';
						secondary := secondary + 'X';
					end;

					current := current + 2;
				end
				else
				begin




//					 italian & armenian
					if StringInStrings( copy(original, current, 3) , ['SIO','SIA'])
						or (copy(original, current, 4) = 'SIAN') then
					begin
						if not SlavoGermanic then
						begin
							primary := primary + 'S';
							secondary := secondary + 'X';
						end
						else
						begin
							primary := primary + 'S';
							secondary := secondary + 'S';
						end;

						current := current + 3;
					end
					else
					begin
						if ((current = 1)			 //		 german & anglicisations, e.g. 'smith' match 'schmidt', 'snider' match 'schneider'
								and charInSet(strnext1, ['M','N','L','W']) //	 also, -sz- in slavic language altho in hungarian it is pronounced 's'
							)
							or (strnext1 = 'Z') then
						begin
							primary := primary + 'S';
							secondary := secondary + 'X';

							if strnext1 = 'Z' then
								current := current + 2
							else
								current := current + 1
						end
						else
						begin
							if copy(original, current, 2) = 'SC' then
							begin
								if copy(original, current + 2, 1) = 'H' then //	 Schlesinger's rule
								begin
									if StringInStrings(copy(original, current + 3, 2), ['OO','ER','EN','UY','ED','EM']) then//	 dutch origin, e.g. 'school', 'schooner'
									begin
										if StringInStrings(copy(original, current + 3, 2), ['ER','EN']) then//	 'schermerhorn', 'schenker'
										begin
											primary := primary + 'X';
											secondary := secondary + 'SK';
										end
										else
										begin
											primary := primary + 'SK';
											secondary := secondary + 'SK';
										end;

										current := current + 3
									end
									else
									begin
										if (current = 1)
											and not StringInStrings(copy(original, 3,1) , ['A', 'E', 'I', 'O', 'U', 'Y'])
											and (copy(original, current + 3, 1) <> 'W') then
										begin
											primary := primary + 'X';
											secondary := secondary + 'S';
										end
										else
										begin
											primary := primary + 'X';
											secondary := secondary + 'X';
										end;

										current := current + 3
									end
								end
								else
								begin
									if StringInStrings(copy(original, current + 2, 1) , ['I','E','Y']) then
									begin
										primary := primary + 'S';
										secondary := secondary + 'S';
									end
									else
									begin
										primary := primary + 'SK';
										secondary := secondary + 'SK';
									end;
									current := current + 3
								end
							end
							else
							begin
								if (current = 1)		// special case 'sugar-'
									and (copy(original, current, 5) = 'SUGAR') then
								begin
									primary := primary + 'X';
									secondary := secondary + 'S';
									current := current + 1;
								end
								else
								begin
									if (current = last) 	// french e.g. 'resnais', 'artois'
										and StringInStrings(copy(original, current - 2, 2) , ['AI','OI']) then
										secondary := secondary + 'S' //primary := primary + ''
									else
									begin
										primary := primary + 'S';
										secondary := secondary + 'S';
									end;

									if CharInSet(strnext1, ['S','Z']) then
										current := current + 2
									else
										current := current + 1
								end
							end
						end
					end
				end
			end
		end
		else

		if strcur1 = 'T' then
		begin
			if copy(original, current, 4) = 'TION' then
			begin
				primary := primary + 'X';
				secondary := secondary + 'X';
				current := current + 3;
			end
			else
				if StringInStrings(copy(original, current, 3), ['TIA','TCH']) then
				begin
					primary := primary + 'X';
					secondary := secondary + 'X';
					current := current + 3;
				end
				else
					if (copy(original, current, 2) = 'TH')
						or (copy(original, current, 3) = 'TTH') then
					begin
						if StringInStrings(copy(original, current + 2, 2), ['OM','AM'])	// special case 'thomas', 'thames' or germanic
							or StringInStrings(copy(original, 1, 4), ['VAN ','VON '])
							or (copy(original, 1, 3) = 'SCH') then
						begin
							primary := primary + 'T';
							secondary := secondary + 'T';
						end
						else
						begin
							primary := primary + '0';
							secondary := secondary + 'T';
						end;
						current := current + 2
					end
					else
					begin
						if CharInSet(strnext1, ['T','D']) then
						begin
							current := current + 2;
							primary := primary + 'T';
							secondary := secondary + 'T';
						end
						else
						begin
							current := current + 1;
							primary := primary + 'T';
							secondary := secondary + 'T';
						end
					end
		end
		else

		if strcur1 = 'V' then
			if (strnext1 = 'V') then
				current := current + 2
			else
			begin
				current := current + 1;
				primary := primary + 'F';
				secondary := secondary + 'F';
			end
		else

		if strcur1 = 'W' then
		begin
		 //	 can also be in middle of word
			if copy(original, current, 2) = 'WR' then
			begin
				primary := primary + 'R';
				secondary := secondary + 'R';
				current := current + 2;
			end
			else
				if (current = 1)
					and (CharInSet(strnext1, ['A', 'E', 'I', 'O', 'U', 'Y'])
						or (copy(original, current, 2) = 'WH')
					) then
				begin
					if CharInSet(strnext1, ['A', 'E', 'I', 'O', 'U', 'Y']) then //	 Wasserman should match Vasserman
					begin
						primary := primary + 'A';
						secondary := secondary + 'F';
						current := current + 1;
					end
					else
					begin
						primary := primary + 'A'; //	 need Uomo to match Womo
						secondary := secondary + 'A';
						current := current + 1;
					end
				end
				else
					if ((current = last) // Arnow should match Arnoff
							and CharInSet(strprev1, ['A', 'E', 'I', 'O', 'U', 'Y'])
						)
					 	or StringInStrings(copy(original, current - 1, 5), ['EWSKI','EWSKY','OWSKI','OWSKY'])
					 	or (copy(original, 0, 3) = 'SCH') then
					begin
						secondary := secondary + 'F'; //	primary := primary + ''
						current := current + 1;
					end
					else
						if StringInStrings(copy(original, current, 4), ['WICZ','WITZ']) then //  polish e.g. 'filipowicz'
						begin
							primary := primary + 'TS';
							secondary := secondary + 'FX';
							current := current + 4;
						end
						else
							current := current + 1; //	 else skip it
		end
		else

		if strcur1 = 'X' then
		begin
			if not ((current = last) //	 french e.g. breaux
				and (StringInStrings(copy(original, current - 3, 3), ['IAU', 'EAU'])
				 	or StringInStrings(copy(original, current - 2, 2), ['AU', 'OU'])
				)
			) then
			begin
				primary := primary + 'KS';
				secondary := secondary + 'KS';
			end; //	else skip it

			if CharInSet(strnext1, ['C','X']) then
				current := current + 2
			else
				current := current + 1
		end
		else

		if strcur1 = 'Z' then
		begin
			if (strnext1 = 'Z') then
			begin
				primary := primary + 'S';
				secondary := secondary + 'S';
				current := current + 2;
			end
			else
			begin
				if (strnext1 = 'H') then  // chinese pinyin e.g. 'zhao'
				begin
					primary := primary + 'J';
					secondary := secondary + 'J';
					current := current + 2;
				end
				else
				begin
					if (StringInStrings(copy(original, current + 1, 2), ['ZO', 'ZI', 'ZA']))
							or (SlavoGermanic
								and ((current > 1)
									and (strprev1 <> 'T')
								)
							) then
					begin
						primary := primary + 'S';
						secondary := secondary + 'TS';
					end
					else
					begin
						primary := primary + 'S';
						secondary := secondary + 'S';
					end
				end;
				current := current + 1
			end
		end
		else
			current := current + 1;
	end;
  Result.Primary:=primary;
  Result.Secondary:=secondary;
end;


end.
