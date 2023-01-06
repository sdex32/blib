library BNistFile;


uses
  Windows,
  BStrTools in 'BStrTools.pas',
  BFileTools in 'BFileTools.pas';

const
      c_magic = $DE37AA45; // session magic test

      //work mode  VIS  EES_FP  EES_FI
      workMpde : array [1..3,1..10] of longword =
      //2.00
      //| 2.00
      //| |
      //| | |
      ((1,2,3,4,5,6,7,8,9,10),   // VIS
       (1,2,3,4,5,6,7,8,9,10),   // EES_FP
       (1,2,3,4,5,6,7,8,9,10));  // EES_FI




      // NIST constants
      //-------- Separators ----------
      fs = #28;   // file separator
      gs = #29;   // group separator
      rs = #30;   // record separator
      us = #31;   // unit saparetor
      //-----------TYPE1-------------     Transaction Record
      c_len1  :string = '1.001:';                    // Length
      c_ver1  :string = '1.002:0300';                // Version
      c_cnt1  :string = '1.003:';                    // Content   1.003:1 us 18 rs 2 us 17 gs
      c_tot1  :string = '1.004:';                    // Type of Transaction
      c_dat1  :string = '1.005:';                    // Date
      c_pri1  :string = '1.006:';                    // Priority        {not send}
      c_dai1  :string = '1.007:';                    // Destination agency identifier        BMS-VIS
      c_ori1  :string = '1.008:';                    // Originated agency identifier       BG/
      c_tcn1  :string = '1.009:';                    // Transaction control number    0000000000Z
      c_tcr1  :string = '1.010';                     // Transaction control reference     {not send}
      c_nsr1  :string = '1.011:';                    // Native scanning resolution
      c_ntr1  :string = '1.012:';                    // Transmiting resolution
      c_dom1  :string = '1.013:';                    // Domain name      INT-I us 4.22 gs
      c_gmt1  :string = '1.014:';                    // Greenwich mean time GMT  fs - last separator

      //-----------TYPE2-------------       User defined Description Text Record
      c_len2  :string = '2.001:';                    // Length
      c_idc2  :string = '2.002:00';                  // Image Designation character    gs 00 is same as 1.003 content
      c_sys2  :string = '2.003:';                    // System information       interpol 4.22 like 1.013
      c_dar2  :string = '2.004:';                    // Date of record
      c_mn12  :string = '2.012:';                    // Miscellaneous Identification Number (External ID)
      c_mn32  :string = '2.014:';                    // Miscellaneous Identification Number (Implementation Scenario ID)
      c_dpr2  :string = '2.019:';                    // Date Fingerprinted
      c_fpr2  :string = '2.083:';                    // Finger Present

      //----------TYPE 4--------------
      c_len4 :string = '4.001:';                    // Logical lrecord length
      c_idc4 :string = '4.002:';                    // Image Designation Character (IDC)
      c_imt4 :string = '4.003:';                    // Impression Type (IMP)
      c_fgp4 :string = '4.004:';                    // Finger Position (FGP)
      c_hll4 :string = '4.006:';                    // Horizontal Line Length (HLL)
      c_vll4 :string = '4.007:';                    // Vertical Line Length (VLL)
      c_gca4 :string = '4.008:';                    //  Greyscale Compression Algorithm (GCA)


type
   Nist_session = record
      magic:longword; // to check session
      work_mode:longword;
      cnt_group :longword;


      //NISTdata
//      len :string; //len 1.001 const
//      ver :string; //ver 1.002 const
//      cnt :string; //cnt 1.003 generated
      tot :string; //tot 1.004
      dat :string; //dat 1.005
//      pri :string; //pri 1.006 not used
      dai :string; //dai 1.007
      ori :string; //ori 1.008
      tcn :string; //tcn 1.009
//      tcr :string; //tcr 1.010 not used
      nsr :string; //nsr 1.011
      ntr :string; //ntr 1.012
      dom :string; //dom 1.013
      gmt :string; //gmt 1.014

      //-----------TYPE2-------------
//      len :string;  //len 2.001 const
//      idc :string;  //idc 2.002 const
      sys :string;    //sys 2.003
      dar :string;    //dar 2.004
      mn1 :string;    //mn1 2.012
      mn3 :string;    //mn3 2.014
      dpr :string;    //dpr 2.019
      fpr :string;    //fpr 2.083


      content_file :string;


      //-----------TYPE4------------

      imp :byte;
      isr :byte;
      hll :array [0..10] of integer;
      vll :array [0..10] of integer;
      gca :array [0..10] of integer;
      fp_image :array[0..10] of ansistring;
      fp_typ :array[0..10] of integer;
      fp_id  :array[0..10] of integer;
      //---------------------------------
      xml:string;
      t2_fpr:array[0..10] of string; //FingersMask
      the_nist:string;



    end;
    PNist_session = ^Nist_session;

//Transaction Control Number module 23 table
//1-A	9-J	  17-T
//2-B	10-K	18-U
//3-C	11-L	19-V
//4-D	12-M	20-W
//5-E	13-N	21-X
//6-F	14-P	22-Y
//7-G	15-Q	0-Z
//8-H	16-R
const                                  { 0   1   2   3   4   5   6   7   8  }
    module23 :array [0..22] of char  = ('Z','A','B','C','D','E','F','G','H',
                      {  9   10  11  12  13  14  15  16  17  18  19  20  21  22 }
                        'J','K','L','M','N','P','Q','R','T','U','V','W','X','Y');

var Year:int64;


//------------------------------------------------------------------------------
function BNistCreate:longword; stdcall; export;
var n:PNist_session;
    i:longword;
    ttt:_SystemTime;
    sd,sf:string;
begin
//   Result := 0;
   try
      new(n);
      n.magic := c_magic;

      for i := 0 to 9 do
      begin
         n.t2_fpr[i] := 'NA';
         n.hll[i] := 0;
         n.vll[i] := 0;
         n.gca[i] := 0;
         n.fp_image[i] := '';
      end;

      for i := 1 to 10 do n.fp_id[i] := 0;  // clear if for finger prints;

      n.cnt_group := 1; // for type 2     type 1 not in count    start from 00 id fro type 2

      // Fill some default values
      // current date CCYYMMDDHHMMSS'Z"
      GetLocalTime(ttt);
      sd := ToStrZlead(ttt.wYear,4)
          + ToStrZlead(ttt.wMonth,2)
          + ToStrZlead(ttt.wDay,2);
      sf := sd + ToStrZlead(ttt.wHour,2)
               + ToStrZlead(ttt.wMinute,2)
               + ToStrZlead(ttt.wSecond,2) + 'Z';
      // prepare global year for  Transaction Control Number
      // format is (YY * 10^8 + (8)n) Modulo 23
      i := ttt.wYear - (ttt.wYear div 100) * 100;
      Year := int64(i) * int64(100000000);

   // type 1 - Transaction record              Set deafult values
   //note: use #27 to test is field was filled
   //      len :string; //len 1.001 generated
   //      ver :string; //ver 1.002 const
   //      cnt :string; //cnt 1.003 generated this is the content of records in file
      n.tot := 'AVT'; //tot 1.004   see table in NistSetData
      n.dat := sd; //dat 1.005
   //      pri :string; //pri 1.006 not used   priority 1= super urgent  2 - 9 slow
      n.dai := #27; //dai 1.007
      n.ori := #27; //ori 1.008
      n.tcn := #27; //tcn 1.009
   //      tcr :string; //tcr 1.010 not used
      n.nsr := #27; //nsr 1.011
      n.ntr := #27; //ntr 1.012
      n.dom := 'INT-I' + us + '4.22'; //dom 1.013
      n.gmt := sf;  //gmt 1.014


   // Type 2  User defined Description Text Record
      //    len :string;   // len 2.001 generated
      //    idc :string;   // idc 2.002 const 00 same as conetnt 1.003
      n.sys := '0422';     // sys 2.003 interpol 4.22
      n.dar := sd;         // dar 2.004
      n.mn1 := #27;        // mn1 2.012
      n.mn3 := #27;        // mn3 2.014
      n.dpr := sd;         // dpr 2.019
      n.fpr := #27;        // fpr 2.083



 {
      // type 4
      n.imp := 0;
      n.isr := 0;
    }
      n.xml := '';



   Result := longword(n);
   except
      Result := 0;
   end;
end;

//------------------------------------------------------------------------------
function BNistSetData(hand:longword; field_id,sub_id:longword; data: pansichar):longint; stdcall; export;
var nd:PNist_session;
    s,sd:string;
    i64 :int64;
    i:integer;
begin
   Result := 0;
   try
      nd := nil;
      // todo data to s
      s := PZStrToStr(data);
      if hand <> 0 then nd := pointer(hand);
      if nd.magic = c_magic then
      begin
         case field_id  of
//<<<<< WORK MODE SET >>>>>>>>>>>>>>>>>>>>>>>>>>>>>
            0: begin  // Set XML
               nd.work_mode := 0;
               case StrToCase(UpperCase(s),['VIS','EES_FP','EES_FI']) of
               0: begin
                  nd.work_mode := 1;
                  // set defaults
                  nd.dai := 'BMS-VIS';
               end;
               1: begin
                  nd.work_mode := 2;
               end;
               2: begin
                  nd.work_mode := 3;
               end;
               else  // unknown mode
                  Result := 1;
               end;
            end;


            1: begin  // Set  not used yet
               nd.xml := s;
            end;


// <<<<<<<<<< TYPE 1 >>>>>>>>>>>>>>>>>>
//------------------------------------------------------------------------------
            2: begin  // Set Type 1 - Type Of Transaction
{
Incoming Types of Transactions
AVT	Authentication Verification Transaction   <------ AVT     set as default
NPS	Non-criminal Print-to-print Search
SIT	Search & Insert Transaction
ATP	Add To Print collection
UPR	Update Request
LRT	Link Record Transaction
DFP	Delete From Print collection
RBR	Retrieve BMS Record
QCT	Quality Control Transaction
Outgoing Types of Transactions
ERR	Error
QCR	Quality Control Response
RRR	Retrieve Record Response
SRE	Search Result
}
               nd.tot := s
            end;
//------------------------------------------------------------------------------
            3: begin  // Set Type 1 = Date and GMT
               // the format of the sting CCYYMMDDHHMMSS'Z'
               Result := -1;
               if length(s) = 15 then
               begin
                  if s[15] = 'Z' then
                  begin
                     sd := MidStr(s,1,8);
                     nd.dat := sd;
                     nd.gmt := s;
                     nd.dar := sd;
                     nd.dpr := sd;
                     Result := 0; // ok
                  end;
               end;
            end;
//------------------------------------------------------------------------------
            4: begin // set Destination Agency Identifier
{  possible values
   BMS-VIS   <- when you call VIS
}
               nd.dai := s;
            end;
//------------------------------------------------------------------------------
            5: begin // set Originating Agency Identifier
               nd.ori := 'BG/'+s;
            end;
//------------------------------------------------------------------------------
            6: begin // set Transaction Control Number
               // Need Serial number 8 Digits max
               //format is (YY * 10^8 + (8)n) Modulo 23
               Result := -2;
               val(s,i64,i);
               if i = 0 then
               begin
                  i64 := i64 + Year;
                  i := integer(i64 mod 23);
                  str(i64,s);
                  nd.tcn := s + module23[i];
                  Result := 0;
               end;
            end;
//------------------------------------------------------------------------------
            7: begin // set Native Scanning Resolution & Nominal Transmitting Resolution
               Result := -3;
               if s = '500' then   //inc = 25.4 milimeters
               begin
                  nd.nsr := '19.68';  // 500/25.4 = 19.6850393701
                  nd.ntr := '19.68';
                  Result := 0; //ok
               end else begin
                  if s = '1000' then
                  begin
                     nd.nsr := '39.37';  // 1000/25.4 = 39.3700787402
                     nd.ntr := '39.37';
                     Result := 0; // ok
                  end else begin
                      // out of EES scope
                     //todo to generate from string xx.xx

                  end;
               end;

            end;
//------------------------------------------------------------------------------
            8: begin // set Domain Name
{            for BMS-VIS is the one defined in the Interpol Implementation version 4.22b
             by default INT-I<US>4.22<GS> }
               nd.dom := s;
            end;

// <<<<<<<<<< TYPE 2 >>>>>>>>>>>>>>>>>>
//------------------------------------------------------------------------------
            9: begin // sys 2.003 interpol 4.22
{           default value 0422  version of the Interpol-implementation  }
               nd.sys := s;
            end;
            10: begin // Miscellaneous Identification Number (External ID)
{           2.0012 mn1
           Format:	(2)A(1)n(27)n
Allowable Value:	(2)A is one of the MS country codes
1(n) is set to the default value “0” for BMS-VIS and is foreseen
to be used in the EURODAC II implementation (i.e. the category).
(27)n is the CS-VIS Biometric Attachment ID (27 digits)
}
               nd.mn1 := 'BG'+s ;
            end;
            11: begin // Miscellaneous Identification Number (Implementation Scenario ID)
{           2.0014 mn3   possible values are:
   	BMS implementation Scenario
01	CS-VIS
02	SIS II-CS
03	EURODAC II
04	VIS extension for Partial Fingerprint
}
               nd.mn3 := s;
            end;
            12: begin // Finger Present
               nd.fpr :=  s;
            end;






   
         end;


      end;
   except
      Result := -1;
   end;
end;

//------------------------------------------------------------------------------
function BNistSetFinger(hand:longword; field_id:longword; data: pointer; len:longword):longint; stdcall; export;
var nd:PNist_session;
begin
   Result := 0;
   try
      nd := nil;
      if hand <> 0 then nd := pointer(hand);
      if nd.magic = c_magic then
      begin



         nd.fp_image[ field_id] := DataToStr(data,len);
      end;
   except
      Result := -1;
   end;

end;

//------------------------------------------------------------------------------
function BNistGenerate(hand:longword):longint; stdcall; export;
var nd:PNist_session;
    sz,i:longint;
    s,t,t1:string;
begin
   Result := 0; //Ok
   try
      if hand <> 0 then
      begin
         nd := pointer(hand);
         if nd.magic = c_magic then
         begin

            // generate TYPE 1 - Transaction record
            // ugly code but very clear
                                       //len 1.001:xxx(gs)
            s := c_ver1 + gs            //ver 1.002 (const) Version
                                       //cnt 1.003         Content
{               In formula:
(2)c0<US>(2)c1<RS>(2)c2<US>(2)c3<RS>(2)c4<US>(2)c5<RS>…(2)cn1<US>(2)cn<GS>
(2)c0: refers to the current record -> 1
(2)c1: contains the number of other records contained in the file-> e.g.4 (1 type-2 and 3 type-4)
(2)c2 identifies the next record type -> e.g.2 (type-2 record)
(2)c3: identifies the IDC from the record identified in (2)c2. ->e.g. 2
(2)c4: identifies the next record type -> e.g.4
(2)c5: identifies the IDC from the record identified in (2)c4 -> (e.g.3)
(2)cn-1: identifies the record type from the last record in the file-> e.g.4
(2)cn: identifies the IDC from the record identified in (2)cn-1 -> (e.g.5) }
                        {c0}             {c1}                 {c2}        {c3}
// create the file the count is all groups without 1 so 2+4+4+4+4 5 grpoups

               + c_cnt1 + '1' + us + ToStr(nd.cnt_group) + rs + '2' + us + '00' + rs + nd.content_file + gs
               + c_tot1 + nd.tot + gs   //tot 1.004         Type Of Transaction
               + c_dat1 + nd.dat + gs   //dat 1.005         Date
//             + nd.pri1 + gs   //pri 1.006 // not send
               + c_dai1 + nd.dai + gs   //dai 1.007         Destination Agency Identifier
               + c_ori1 + nd.ori + gs   //ori 1.008         Originated agency identifier
               + c_tcn1 + nd.tcn + gs   //tcn 1.009         Transaction control number
//             + nd.tcr1 + gs   //tcr 1.010 // not send
               + c_nsr1 + nd.nsr + gs   //nsr 1.011         Native Scanning Resolution     in (ppmm pixel per milimeter)
               + c_ntr1 + nd.ntr + gs   //ntr 1.012         Nominal Transmitting Resolution
               + c_dom1 + nd.dom + gs   //dom 1.013
               + c_gmt1 + nd.gmt + fs;  //gmt 1.014
            // calc length
            sz := length(s) + 7 {1.001:xxx(gs)};
            t := ToStr(sz);
            sz := sz + length(t);
            t1 := ToStr(sz); // if size from XX become XXX
            i := length(t1) - length(t);
            if i <> 0 then
            begin
               sz := sz + i;
               t1 := ToStr(sz);
            end;

            s := c_len1 + t1 + gs + s;
            // test for not filled fields
            if Pos(#27,s) <> 0 then
            begin
               Result := -2; // Error some input data is invalid or missed
               Exit;
            end;
            nd.the_nist := s; //copy T1


            // generate TYPE 2 - User defined description text
            s := c_idc2 + gs             //idc 2.002 const
               + c_sys2 + nd.sys + gs    //sys 2.003
               + c_dar2 + nd.dar + gs    //dar 2.004
               + c_mn12 + nd.mn1 + gs    //mn1 2.012
               + c_mn32 + nd.mn3 + gs    //mn3 2.014
               + c_dpr2 + nd.dpr + gs    //dpr 2.019
               + c_fpr2 + nd.fpr + fs;   //fpr 2.083
            sz := length(s) + 7 {2.002:xxx(gs)};
            t := ToStr(sz);
            sz := sz + length(t);
            t1 := ToStr(sz); // if size from XX become XXX
            i := length(t1) - length(t);
            if i <> 0 then
            begin
               sz := sz + i;
               t1 := ToStr(sz);
            end;

            s := c_len2 + t1 + gs + s;
            // test for not filled fields
            if Pos(#27,s) <> 0 then
            begin
               Result := -3; // Error some input data is invalid or missed
               Exit;
            end;
            nd.the_nist := nd.the_nist + s; //copy T2




            FileSave('d:\a.nist',ansistring(nd.the_nist));
         end;
      end;
   except
      Result := -1;
   end;

end;

//------------------------------------------------------------------------------
function BNistGetResult(hand:longword; mode:longword; data_ptr:pointer; len:longword):longint; stdcall; export;
var nd:PNist_session;
begin
   Result := 0;
   try
      if hand <> 0 then
      begin
         nd := pointer(hand);
         if nd.magic = c_magic then
         begin

         end;
      end;
   except
      Result := -1;
   end;
end;

//------------------------------------------------------------------------------
procedure BNistDestroy(hand:longword); stdcall; export;
var nd:PNist_session;
begin
   try
      if hand <> 0 then
      begin
         nd := pointer(hand);
         if nd.magic = c_magic then
         begin
            Dispose(nd);
         end
      end;
   except


   end;
end;


exports
    BNistCreate,
    BNistSetData,
    BNistSetFinger,
    BNistGenerate,
    BNistGetResult,
    BNistDestroy;

begin
end.
