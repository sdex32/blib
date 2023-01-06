unit BSQLite;
//
//	Class wrapper for SQLite 3 functions.      version 0.5 beta
//
// ToDo utf8 to my library
//
// How to use
//
// 1111.................
//with db.Query('select f1,f2 from tbl where f1>0') do begin
//  while not Eof do begin
//    writeln(FieldAsInt(0), FieldAsString(1));
//    Next;
//  end;
//  Free;
//end;
//
// 2222.................
// db.Execute('delete from tbl where f1=0');
//
// 3333.................
// db.Prepare('insert into tbl(f1,f2) values(?,?)');
// db.SetParam(123);
// db.SetParam('abc');
// db.RunSQL;

interface

type

	TSqliteQueryResults = class;

	TSqliteDatabase = class
	private
		Fhandle: pointer;
		Fstmt: pointer;
		Fparam: integer;
    FSqlCode: integer;
    FSqlErrText: String;
//		procedure RaiseError(const sql: string);
		procedure FinalizeSQL;
    procedure Check(const ErrCode: Integer);
    function  CheckHandle:boolean;
	public
		constructor Create;
		destructor Destroy; override;
		procedure Open(const FileName: string);
		procedure Execute(const sql: String);  //utf8 ready
		procedure BeginTransaction;
		procedure Commit;
		procedure Rollback;
//		function Like(const field, pattern: string; simulate: boolean): string;
		function  Query(const sql: string): TSqliteQueryResults;
		procedure Prepare(const sql: string);
		procedure SetParam(value: int64); overload;
		procedure SetParam(value: string); overload;
		procedure SetParam(value: currency); overload;
		procedure SetParam(blob: pchar; size: integer); overload;
		procedure RunSQL;
		function  GetLastInsertRowID: int64;
    property  SqlCode :integer read FSqlCode;
    property  SqlErrText :String read FSqlErrText;
	end;

	TSqliteQueryResults = class
	private
		Fdb: TSqliteDatabase;
		Fstmt: pointer;
		Feof: boolean;

	public
		constructor Create(db: TSqliteDatabase; const sql: string);
		destructor Destroy; override;
		procedure Next;
		function Eof: boolean;
		function FieldAsString(i: integer): string;
		function FieldAsInteger(i: integer): int64;
		function FieldAsDouble(i: integer): double;
		function FieldAsBlob(i: integer): pchar;
		function FieldSize(i: integer): integer;
    function FieldName(i: integer): string;
	end;



implementation


const
	SQLITE_DONE = 101;

type
	TPCharArray = array [0..(MaxLongint div sizeOf(PChar))-1] of PChar;
	PPCharArray = ^TPCharArray;

function  sqlite3_open(filename: pAnsichar; var db: pointer): integer; cdecl; external 'sqlite3.dll';
function  sqlite3_close(db: pointer): integer; cdecl; external 'sqlite3.dll';
function  sqlite3_exec(db: pointer; sql: pansichar; callback: pointer; userdata: pchar; errmsg: pansichar): integer; cdecl; external 'sqlite3.dll';
procedure sqlite3_free(ptr: pchar); cdecl; external 'sqlite3.dll';
function  sqlite3_prepare(db: pointer; sql: pansichar; nBytes: integer; var stmt: pointer; var ztail: pchar): integer; cdecl; external 'sqlite3.dll';
function  sqlite3_step(stmt: pointer): integer; cdecl; external 'sqlite3.dll';
function  sqlite3_finalize(stmt: pointer): integer; cdecl; external 'sqlite3.dll';
function  sqlite3_errmsg(db: pointer): pansichar; cdecl; external 'sqlite3.dll';
function  sqlite3_errcode(db: pointer): integer; cdecl; external 'sqlite3.dll';
function  sqlite3_get_table(db: pointer; sql: pchar; var result: PPCharArray; var RowCount: Cardinal; var ColCount: Cardinal; var errmsg: pchar): integer; cdecl; external 'sqlite3.dll';
procedure sqlite3_free_table(table: PPCharArray); cdecl; external 'sqlite3.dll';
function  sqlite3_last_insert_rowid(db: pointer): int64; cdecl; external 'sqlite3.dll';
procedure sqlite3_interrupt(db: pointer); cdecl; external 'sqlite3.dll';

function  sqlite3_column_count(stmt: pointer): integer; cdecl; external 'sqlite3.dll';
function  sqlite3_column_name(stmt: pointer; ColNum: integer): pchar; cdecl; external 'sqlite3.dll';
function  sqlite3_column_type(stmt: pointer; col: integer): integer; cdecl; external 'sqlite3.dll';
function  sqlite3_column_bytes(stmt: pointer; col: integer): integer; cdecl; external 'sqlite3.dll';
function  sqlite3_column_blob(stmt: pointer; col: integer): pointer; cdecl; external 'sqlite3.dll';
function  sqlite3_column_double(stmt: pointer; col: integer): double; cdecl; external 'sqlite3.dll';
function  sqlite3_column_int(stmt: pointer; col: integer): integer; cdecl; external 'sqlite3.dll';
function  sqlite3_column_int64(stmt: pointer; col: integer): Int64; cdecl; external 'sqlite3.dll';
function  sqlite3_column_text(stmt: pointer; col: integer): pchar; cdecl; external 'sqlite3.dll';
function  sqlite3_bind_blob(stmt: pointer; param: integer; blob: pointer; size: integer; freeproc: pointer): integer; cdecl; external 'sqlite3.dll';
function  sqlite3_bind_text(stmt: pointer; param: integer; text: PChar; size: integer; freeproc: pointer): integer; cdecl; external 'sqlite3.dll';
function  sqlite3_bind_int64(stmt: pointer; param: integer; value: int64): integer; cdecl; external 'sqlite3.dll';
function  sqlite3_bind_double(stmt: pointer; param: integer; value: double): integer; cdecl; external 'sqlite3.dll';

function StrToUTF8(const S: WideString): AnsiString;
begin
  //TODO Result := UTF8Encode(S);
end;

function UTF8ToStr(const S: PAnsiChar): WideString;
begin
 //TODO Result := UTF8ToWideString(S);
end;

constructor TSqliteDatabase.Create;
begin
   FSqlCode := 0;
   FHandle := nil;
end;

procedure   TSqliteDatabase.Open(const FileName: string);
begin
  FSqlCode :=0;
  FSqlErrText := '';
	if sqlite3_open(PAnsiChar(StrToUTF8(FileName)), Fhandle) = 0 then
  begin
 // 	Execute('pragma synchronous = off');
//	  Execute('pragma temp_store = memory');
  end else begin
    FSqlCode := -300;
    Fhandle := nil;
  end;
end;

destructor TSqliteDatabase.Destroy;
begin
  if CheckHandle then
  begin
     FinalizeSQL;
   	 sqlite3_close(Fhandle);
  end;
  inherited;
end;

//------------------------------------------------------------------------------
procedure TSQLiteDatabase.Check(const ErrCode: Integer);
begin
  FSQLcode := 0;
  FSqlErrText := '';
  if ErrCode <> 0 {SQLITE_OK} then
  begin
     FSQLcode := sqlite3_errcode(FHandle) * -1;
     FSqlErrText := UTF8ToStr(sqlite3_errmsg(FHandle));
  end;
  if ErrCode = 12 {SQLITE_NOTFOUND} then
  begin
   FSQLcode := 100;
   FSqlErrText := 'Not found';
  end;
end;

function TSQLiteDatabase.CheckHandle:boolean;
begin
  FSQLcode := 0; // set no error for all
  Result := true;
  if FHandle = nil then
  begin
     FSQLcode := -302;
     Result := false;
  end;
end;

procedure TSqliteDatabase.Execute(const sql: String);
begin
  if CheckHandle then
  Check(sqlite3_exec(FHandle, PAnsiChar(StrToUTF8(SQL)), nil, nil, nil));

//	CompileSQL(sql);
//	RunSQL;
end;

procedure TSqliteDatabase.BeginTransaction;
begin
	Execute('begin');
end;

procedure TSqliteDatabase.Commit;
begin
	Execute('commit');
end;

procedure TSqliteDatabase.Rollback;
begin
	Execute('rollback');
end;

procedure TSqliteDatabase.Prepare(const sql: string);
var
	IgnoreNextStmt: Pchar;
begin
	FinalizeSQL;
	Check(sqlite3_prepare(Fhandle, PAnsiChar(StrToUTF8(SQL)), -1, Fstmt, IgnoreNextStmt));
	if FSqlCode = 0 then Fparam := 1;
end;

procedure TSqliteDatabase.RunSQL;
begin
	Check(sqlite3_step(Fstmt));
end;

procedure TSqliteDatabase.FinalizeSQL;
begin
	if Assigned(Fstmt) then
		sqlite3_finalize(Fstmt);
	Fstmt := nil;
end;

procedure TSqliteDatabase.SetParam(value: int64);
begin
	sqlite3_bind_int64(Fstmt, Fparam, value);
	Inc(Fparam);
end;

procedure TSqliteDatabase.SetParam(value: string);
begin
	sqlite3_bind_text(Fstmt, Fparam, Pchar(value), Length(value), nil);
	Inc(Fparam);
end;

procedure TSqliteDatabase.SetParam(value: currency);
begin
	sqlite3_bind_double(Fstmt, Fparam, value);
	Inc(Fparam);
end;

//	Caller must not free the blob while accessing the query.
//
procedure TSqliteDatabase.SetParam(Blob: PChar; size: integer);
begin
	sqlite3_bind_blob(Fstmt, Fparam, Blob, Size, nil);
	Inc(Fparam);
end;


////	LIKE operator isn't indexed, so simulate = true for faster result.
////
//function TSqliteDatabase.Like(const field, pattern: string; simulate: boolean): string;
//begin
//	if simulate
//		then result := Format('%s between ''%s'' and ''%sz''', [field, pattern, pattern])
//		else result := Format('%s like ''%s%%''', [field, pattern]);
//end;

function TSqliteDatabase.GetLastInsertRowID: int64;
begin
	result := sqlite3_last_insert_rowid(Fhandle);
end;

//	Caller must free the returned object.
//
function TSqliteDatabase.Query(const sql: string): TSqliteQueryResults;
begin
	result := TSqliteQueryResults.Create(self, sql);
end;


//	Query result access functions.
//
constructor TSqliteQueryResults.Create(db: TSqliteDatabase; const sql: string);
var
	IgnoreNextStmt: Pchar;
begin
//	inherited Create;
  IgnoreNextStmt := nil;
	Fdb := db;
	Fdb.Check(sqlite3_prepare(Fdb.Fhandle,  PAnsiChar(StrToUTF8(SQL)), -1, Fstmt, IgnoreNextStmt));
  if Fdb.SqlCode = 0 then Next;
end;

destructor TSqliteQueryResults.Destroy;
begin
	sqlite3_finalize(Fstmt);
	inherited Destroy;
end;

procedure TSqliteQueryResults.Next;
begin
	Feof := sqlite3_step(Fstmt) = SQLITE_DONE;
  if Feof then
  begin
    Fdb.FSqlCode := 100;
    Fdb.FSqlErrText := 'Not found';
  end;
end;

function TSqliteQueryResults.Eof: boolean;
begin
	result := Feof;
end;

function TSqliteQueryResults.FieldAsInteger(i: integer): int64;
begin
	result := sqlite3_column_int64(Fstmt, i);
end;

function TSqliteQueryResults.FieldAsDouble(i: integer): double;
begin
	result := sqlite3_column_double(Fstmt, i)
end;

function TSqliteQueryResults.FieldAsString(i: integer): string;
var
	size: integer;
  res:string;
begin
	size := FieldSize(i);
	SetLength(res, size);
	System.Move(sqlite3_column_text(Fstmt, i)^, PChar(res)^, size);
  result := Utf8toStr(pAnsiChar(@res[1]));
end;

//	Use FieldSize() to get the size of the blob.
//
function TSqliteQueryResults.FieldAsBlob(i: integer): pchar;
begin
	result := sqlite3_column_blob(Fstmt, i);
end;

function TSqliteQueryResults.FieldSize(i: integer): integer;
begin
	result := sqlite3_column_bytes(Fstmt, i);
end;

function TSqliteQueryResults.FieldName(i: integer): string;
begin
	  Result := UTF8ToStr(pAnsiChar(sqlite3_column_name(Fstmt, i)));
end;

end.


