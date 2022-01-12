unit BTinyODBC;

interface

type
   BTTinyODBC = class;


   _TODBCResults = class
      private
         aFirstFetch:longword;
         aEOF :boolean;
         aPapa :BTTinyODBC;
         Statement :longword;
         aCcnt :longword;
         aRcnt :smallint;
         aTemp :ansistring;
         procedure _Reset;
      public
		     constructor Create(papa:BTTinyODBC);
         destructor Destroy; override;
         function Fetch:longint;
         function FieldAsString(i :longword): string;
         function FieldAsInteger(i :longword): longint;
         function FieldAsDouble(i :longword): double;
         function FieldAsBlob(i :longword): pchar;
         property ColumnsCount :longword read aCcnt;
	 end;


   BTTinyODBC = class
      private
         aTrans:longword;
         aResultSet :_TODBCresults;
         FSqlCode :integer;
         FSqlErrText :String;
         ODBCDLLHandle :longword;
         ODBCEnv :longword;
         ODBChandle :longword;
         Connected :boolean;
         procedure _ErrorHandle(res:longint);
         procedure _ClearError;
      public
         constructor Create;
         destructor  Destroy; override;
         procedure Open(const dsn,user,pwd :string);
         procedure Close;
         procedure Execute(const sql: String);
         procedure BeginTransaction;
         procedure Commit;
         procedure Rollback;
         procedure Prepare(const sql: string);
         procedure SetParam(param:longword; value: longint); overload;
         procedure SetParam(param:longword; value: string); overload;
         procedure SetParam(param:longword; value: double); overload;
         procedure SetParam(param:longword; blob: pchar; size: integer); overload;
         procedure ExecutePrepared;
         property  SqlCode :integer read FSqlCode;
         property  SqlErrText :String read FSqlErrText;
         property  Results :_TODBCresults read aResultSet;
   end;


implementation

uses Windows;

const
  SQL_HANDLE_ENV = 1;
  SQL_HANDLE_DBC = 2;
  SQL_HANDLE_STMT = 3;

  SQL_ATTR_ODBC_VERSION = 200;
  SQL_OV_ODBC3 = 3;

  SQL_SUCCESS  = 0;
  SQL_SUCCESS_WITH_INFO =  1;
  SQL_ERROR    = (-1);
  SQL_NO_DATA  =  100;
  SQL_NTS      = (-3);
  SQL_DROP     = 1;
  SQL_NO_TOTAL =   (-4);

  SQL_COMMIT = 0;
  SQL_ROLLBACK = 1;

  SQL_ATTR_AUTOCOMMIT = 102;
  SQL_AUTOCOMMIT_OFF = 0;
  SQL_AUTOCOMMIT_ON = 1;

  SQL_PARAM_INPUT = 1;

  SQL_CHAR          = 1;
  SQL_NUMERIC       = 2;
  SQL_DECIMAL       = 3;
  SQL_INTEGER       = 4;
  SQL_SMALLINT      = 5;
  SQL_FLOAT         = 6;
  SQL_REAL          = 7;
  SQL_DOUBLE        = 8;
  SQL_DATETIME      = 9;
  SQL_VARCHAR       = 12;
  SQL_TYPE_DATE     = 91;
  SQL_TYPE_TIME     = 92;
  SQL_TYPE_TIMESTAMP= 93;
  SQL_BINARY        = (-2);


var
SQLAllocHandle : function(typH,inH:longword; var outH:longword):Smallint; stdcall;
SQLFreeHandle : function(typH,inH:longword): Smallint; stdcall;
SQLFreeStmt : function(typH,inH:longword): Smallint; stdcall;
SQLSetEnvAttr : function(henv:longword; Atr:longword; val:pointer; vallen:longword):Smallint; stdcall;
SQLSetConnectAttr : function(hdbc:longword; Atr:longword; val:pointer; vallen:longword):Smallint; stdcall;
SQLConnect : function (hdbc:longword; szDSN:PCHAR; cbDSN:Smallint; szUID:PCHAR; cbUID:Smallint; szAuthStr:PCHAR; cbAuthStr:Smallint) :Smallint; stdcall;
SQLDisconnect : function (hdbc:longword) :Smallint; stdcall;
SQLExecDirect : function (hstmt:longword;  szSqlStr:PCHAR;  cbSqlStr:Integer) :Smallint; stdcall;
SQLPrepare : function (hstmt:longword; szDSN:PCHAR; cbDSN:longint) :Smallint; stdcall;
SQLExecute : function (hstmt:longword) :Smallint; stdcall;
SQLEndTran : function (hTyp,Hand:longword; CompletionType:longint) :Smallint; stdcall;


SQLSetParam : function (hstmt:longword;  ipar:Smallint;
                     fCType:Smallint;  fSqlType:Smallint;
                     cbColDef:Integer;  ibScale:Smallint;
                     var RGBValue:PCHAR;
                     var pcbValue:Integer) :SmallInt; stdcall;

SQLBindParameter : function (
               hstmt:longword;
               ipar:SMALLINT;
               fParamType:SMALLINT;
               fCType:SMALLINT;
               fSqlType:SMALLINT;
               cbColDef:INTEGER;
               ibScale:SMALLINT;
               rgbValue:POINTER;
               cbValueMax:INTEGER;
               pcbValue:INTEGER):Smallint; stdcall;

SQLRowCount : function  (hstmt:longword; var RowCountPtr: smallint) :SmallInt; stdcall;
SQLFetch : function (hstmt:longword) :Smallint; stdcall;
SQLGetData : function (hstmt:longword; ColNum:smallint; Typ:Smallint; data:pointer; dataLen:longword; StrLenRoInd:pointer) :SmallInt; stdcall;
SQLNumResultCols : function (hstmt:longword; var ColCnt:smallint) :SmallInt; stdcall;

//------------------------------------------------------------------------------
procedure   BTTinyODBC._ClearError;
begin
   FSqlCode := 0;
   FSqlErrText := '';
end;

procedure   BTTinyODBC._ErrorHandle(res:longint);
begin
   if res = SQL_SUCCESS_WITH_INFO then res := SQL_SUCCESS;
   FSqlCode := res;
   if res = 0 then Exit;
   if res = -1002 then FSqlErrText := 'odbc not connected';
   if res = 100 then FSqlErrTExt := 'no rows found';
end;

//------------------------------------------------------------------------------
constructor BTTinyODBC.Create;
begin
   _ClearError;
   ODBChandle := 0;
   Connected := false;
   aResultSet := nil;
   aTrans := 0;

   FSqlErrText := 'loading dll & init odbc';
   FSqlCode := -1000;
   ODBCDLLHandle := LoadLibrary('odbc32.dll');
   if ODBCDLLhandle <> 0 then
   begin
      SQLAllocHandle:=GetProcAddress (ODBCDLLHandle, 'SQLAllocHandle');
      SQLFreeHandle:=GetProcAddress (ODBCDLLHandle, 'SQLFreeHandle');
      SQLFreeStmt:=GetProcAddress (ODBCDLLHandle, 'SQLFreeStmt');
      SQLSetEnvAttr:=GetProcAddress (ODBCDLLHandle, 'SQLSetEnvAttr');
      SQLSetConnectAttr:=GetProcAddress (ODBCDLLHandle, 'SQLSetConnectAttr');
      SQLConnect := GetProcAddress (ODBCDLLHandle, 'SQLConnect');
      SQLDisconnect := GetProcAddress (ODBCDLLHandle, 'SQLDisconnect');
      SQLExecDirect:=GetProcAddress (ODBCDLLHandle, 'SQLExecDirect');
      SQLPrepare:=GetProcAddress (ODBCDLLHandle, 'SQLPrepare');
      SQLExecute:=GetProcAddress (ODBCDLLHandle, 'SQLExecute');
      SQLSetParam:=GetProcAddress (ODBCDLLHandle, 'SQLSetParam');
      SQLRowCount:=GetProcAddress (ODBCDLLHandle, 'SQLRowCount');
      SQLFetch:=GetProcAddress (ODBCDLLHandle, 'SQLFetch');
      SQLGetData:=GetProcAddress (ODBCDLLHandle, 'SQLGetData');
      SQLNumResultCols:=GetProcAddress (ODBCDLLHandle, 'SQLNumResultCols');
      SQLEndTran:=GetProcAddress (ODBCDLLHandle, 'SQLEndTran');
      SQLBindParameter:=GetProcAddress (ODBCDLLHandle, 'SQLBindParameter');

      if Assigned(SQLAllocHandle) and
         Assigned(SQLFreeHandle) and
         Assigned(SQLFreeStmt) and
         Assigned(SQLSetEnvAttr) and
         Assigned(SQLSetConnectAttr) and
         Assigned(SQLConnect) and
         Assigned(SQLDisconnect) and
         Assigned(SQLExecDirect) and
         Assigned(SQLPrepare) and
         Assigned(SQLExecute) and
         Assigned(SQLSetParam) and
         Assigned(SQLRowCount) and
         Assigned(SQLFetch) and
         Assigned(SQLGetData) and
         Assigned(SQLNumResultCols) and
         Assigned(SQLBindParameter) and
         Assigned(SQLEndTran) then
      begin
         _ErrorHandle(SQLAllocHandle(SQL_HANDLE_ENV,0,ODBCEnv));
         if FSqlCode = 0 then
         begin
            _ErrorHandle(SQLSetEnvAttr(ODBCEnv, SQL_ATTR_ODBC_VERSION, pointer(SQL_OV_ODBC3), 0));
            if FSQLCode  = 0 then
            begin

            _ErrorHandle(SQLAllocHandle(SQL_HANDLE_DBC,ODBCEnv, ODBCHandle));
            if FSQLCode = 0 then
            begin
              // SQLSetConnectAttr(ODBCHandle,SQL_LOGIN_TIMEOUT,

               aResultSet := _TODBCResults.Create(self);
               if assigned(aResultSet) then
               begin
                  _ClearError;
                  aResultSet._Reset;
               end;
            end;
            end;
         end;
      end;
   end;
end;

//------------------------------------------------------------------------------
destructor  BTTinyODBC.Destroy;
begin
   Close;
   if assigned(aResultSet) then aResultSet.Free;
   if ODBCHandle <> 0 then SQLFreeHandle(SQL_HANDLE_DBC,ODBCHandle);
   if ODBCEnv <> 0 then SQLFreeHandle(SQL_HANDLE_ENV,ODBCEnv);
   if ODBCDLLHandle <> 0 then FreeLibrary(ODBCDLLHandle);
   inherited;
end;

//------------------------------------------------------------------------------
procedure   BTTinyODBC.Close;
var res:longint;
begin
   if ODBChandle <> 0 then
   begin
      if Connected then
      begin
         Connected := false;
         res := SQLDisconnect(ODBCHandle);
         if SQL_SUCCESS <> res then
         begin //error connect
           _ErrorHandle(res);
           Exit;
         end;
      end;
   end;
end;

//------------------------------------------------------------------------------
procedure   BTTinyODBC.Open(const dsn,user,pwd :string);
var H,U,P :AnsiString;
    res:longint;
begin
   _ClearError;

   if ODBChandle <> 0 then
   begin
      if Connected then
      begin
         Connected := false;
         res := SQLDisconnect(ODBCHandle);
         if SQL_SUCCESS <> res then
         begin //error connect
           _ErrorHandle(res);
           Exit;
         end;
      end;
      H := AnsiString(dsn);
      U := AnsiString(user);
      P := AnsiString(pwd);
      res := SQLConnect(ODBCHandle,PChar(@H[1]),SQL_NTS,PChar(@U[1]),SQL_NTS,PChar(@P[1]),SQL_NTS);
      if SQL_SUCCESS <> res then
      begin //error connect
         _ErrorHandle(res);
      end else Connected := true;
      _ErrorHandle(SQLSetConnectAttr(ODBCHandle, SQL_ATTR_AUTOCOMMIT, pointer(SQL_AUTOCOMMIT_ON), 0));
   end else begin
      FSqlCode := -1001;
      FSqlErrText := 'odbc not initialized';
   end;
end;

//------------------------------------------------------------------------------
procedure   BTTinyODBC.Execute(const sql: String);
var res:longint;
    asql :AnsiString;
    ExecMode :longword;
    t:smallint;
begin
   asql := AnsiString(SQL);
   ExecMode := length(asql);
   _ClearError;
   if Connected then
   begin
      aResultSet._Reset;
      if FSqlCode = 0 then
      begin
         if ExecMode <> 0 then
         begin // Execute
            res := SQLExecDirect(aResultSet.Statement, PChar(@aSQL[1]), Length(aSQL));
         end else begin // Execute preapre
            res := SQLExecute(aResultSet.Statement);
         end;
         case res of
            SQL_SUCCESS,SQL_SUCCESS_WITH_INFO:
            begin
               _ErrorHandle(SQLFetch (aResultSet.Statement));
               if FSqlCode = 0 then aResultSet.aEOF := false; // have data
               SQLNumResultCols(aResultSet.Statement,t);
               aResultSet.aCcnt := t;
               SQLRowCount(aResultSet.Statement,aResultSet.aRcnt);
               aResultSet.aFirstFetch := 1; {0}
            end;
            SQL_NO_DATA:
            begin
               aResultSet.aFirstFetch := 100; {100}
            end
         end; //case
         _ErrorHandle(res);
      end;
   end else _ErrorHandle(-1002);
end;

//------------------------------------------------------------------------------
procedure   BTTinyODBC.BeginTransaction;
begin
//	Execute('begin');
   _ErrorHandle(SQLSetConnectAttr(ODBCHandle, SQL_ATTR_AUTOCOMMIT, pointer(SQL_AUTOCOMMIT_OFF), 0));
   if FSQLCode = 0 then aTrans := 1;
end;

//------------------------------------------------------------------------------
procedure   BTTinyODBC.Commit;
begin
//	Execute('commit');
   _ErrorHandle(SQLEndTran(SQL_HANDLE_DBC, ODBCHandle, SQL_COMMIT));
   if FSQLCode = 0 then aTrans := 0;
   if aTrans = 0 then
   begin
      _ErrorHandle(SQLSetConnectAttr(ODBCHandle, SQL_ATTR_AUTOCOMMIT, pointer(SQL_AUTOCOMMIT_ON), 0));
   end;
end;

//------------------------------------------------------------------------------
procedure   BTTinyODBC.Rollback;
begin
//	Execute('rollback');
   _ErrorHandle(SQLEndTran(SQL_HANDLE_DBC, ODBCHandle, SQL_ROLLBACK));
   if FSQLCode = 0 then aTrans := 0;
   if aTrans = 0 then
   begin
      _ErrorHandle(SQLSetConnectAttr(ODBCHandle, SQL_ATTR_AUTOCOMMIT, pointer(SQL_AUTOCOMMIT_ON), 0));
   end;
end;

//------------------------------------------------------------------------------
procedure   BTTinyODBC.Prepare(const sql: string);
var res:longint;
    asql :AnsiString;
begin
   asql := AnsiString(SQL);
   _ClearError;
   if Connected then
   begin
      aResultSet._Reset;
      if FSqlCode = 0 then
      begin
         res := SQLPrepare(aResultSet.Statement, PChar(@aSQL[1]), Length(aSQL));
         _ErrorHandle(res);
      end;
   end else _ErrorHandle(-1002);
end;

//------------------------------------------------------------------------------
procedure   BTTinyODBC.ExecutePrepared;
begin
   Execute('');
end;

//------------------------------------------------------------------------------
procedure    BTTinyODBC.SetParam(param:longword; value: longint);
begin
   SQLBindParameter(aResultSet.Statement,param,SQL_PARAM_INPUT,
                    SQL_INTEGER,SQL_INTEGER,0,0,@Value,0,0);
end;

//------------------------------------------------------------------------------
procedure    BTTinyODBC.SetParam(param:longword; value: string);
var a:ansistring;
begin
   a := AnsiString(value);
   SQLBindParameter(aResultSet.Statement,param,SQL_PARAM_INPUT,
                    SQL_CHAR,SQL_CHAR,0,0,@a[1],length(a),0);

end;

//------------------------------------------------------------------------------
procedure    BTTinyODBC.SetParam(param:longword; value: double);
begin
   SQLBindParameter(aResultSet.Statement,param,SQL_PARAM_INPUT,
                    SQL_DOUBLE,SQL_DOUBLE,0,0,@Value,0,0);

end;

//------------------------------------------------------------------------------
//	Caller must not free the blob while accessing the query.
//
procedure    BTTinyODBC.SetParam(param:longword; Blob: PChar; size: integer);
begin
   SQLBindParameter(aResultSet.Statement,param,SQL_PARAM_INPUT,
                    SQL_BINARY,SQL_BINARY,4,0,Blob,size,0); // 4-?
//to err get
end;


//------------------------------------------------------------------------------
constructor _TODBCResults.Create(papa:BTTinyODBC);
begin
   Statement := 0;
   aPapa := papa;
   _Reset;
end;

//------------------------------------------------------------------------------
destructor _TODBCResults.Destroy;
begin
   if Statement <> 0 then SQLFreeStmt(Statement, SQL_DROP);
   inherited;
end;

//------------------------------------------------------------------------------
procedure _TODBCResults._Reset;
begin
   if Statement <> 0  then
   begin
      aPapa._ErrorHandle(SQLFreeStmt(Statement, SQL_DROP));
   end;
   aPapa._ErrorHandle(SQLAllocHandle(SQL_HANDLE_STMT,aPapa.ODBCHandle,Statement)); //was SQLAllocStmt(aPapa.ODBCHandle,Statement));
   aEOF  := true; // no data
   aFirstFetch := 0;
end;

//------------------------------------------------------------------------------
function _TODBCResults.Fetch:longint;
begin
   if aFirstFetch = 0 then
   begin
      aEOF := true;
      aPapa._ErrorHandle(SQLFetch (Statement));
      if aPapa.FSqlCode  = 0 then aEOF := false; // have data
   end;
   aFirstFetch := 0;
   Fetch := aPapa.FSqlCode;
end;

//------------------------------------------------------------------------------
function _TODBCResults.FieldAsString(i:longword): string;
var data:AnsiString;
    returnlength:longword;
begin
   Result := '';
   if aEOF then Exit;
   aFirstFetch := 0;
   if i > aCcnt then Exit;
   SetLength(data,4096);
   aPapa._ErrorHandle(SQLGetData(Statement,i,SQL_CHAR,PChar(@data[1]),4096,@returnlength));
   if aPapa.SqlCode = 0 then
   begin
      if returnLength <= 4096 then SetLength(data,returnlength);
      Result := string(data);
   end;
end;

//------------------------------------------------------------------------------
function _TODBCResults.FieldAsInteger(i:longword): longint;
var data:longword;
    returnlength:longword;
begin
   Result := 0;
   if aEOF then Exit;
   aFirstFetch := 0;
   if i > aCcnt then Exit;
   aPapa._ErrorHandle(SQLGetData(Statement,i,SQL_INTEGER,PChar(@data),4,@returnlength));
   if aPapa.SqlCode = 0 then  Result := Data;
end;

//------------------------------------------------------------------------------
function _TODBCResults.FieldAsDouble(i:longword): double;
var data:double;
    returnlength:longword;
begin
   Result := 0;
   if aEOF then Exit;
   aFirstFetch := 0;
   if i > aCcnt then Exit;
   aPapa._ErrorHandle(SQLGetData(Statement,i,SQL_DOUBLE,PChar(@data),sizeof(double),@returnlength));
   if aPapa.SqlCode = 0 then  Result := Data;
end;

//------------------------------------------------------------------------------
function _TODBCResults.FieldAsBlob(i:longword): pchar;
var Buf:ansistring;
    P,D:pointer;
    rc,binLen,NumBytes,f:integer;
begin
   SetLength(Buf,8192);
   P := @Buf[1];
   aTemp := '';
   repeat
      rc := SQLGetData(Statement,i,SQL_BINARY,P,sizeof(P),@BinLen);
      if rc <> SQL_NO_DATA then
      begin
         NumBytes := BinLen;
         if (BinLen > 8192) or (BinLen = SQL_NO_TOTAL) then NumBytes := 8192;
         f := length(aTemp);
         SetLength(aTemp,f + NumBytes);
         D := @aTemp[f];
         Move(P^,D^,NumBytes);
      end;
   until rc = SQL_NO_DATA;
   Result := pchar(@aTemp[1]);
//TODO error handle

end;


end.
