unit JLWDBM;
// update by codefan at 2006-09-06 09:24
interface

uses
  SysUtils, Classes, DB, ADODB,Variants, DBTables;

const
  IS_BDE = false;
  SINGLETON = false;
type
  SDBSetting = record
    DBSys     :String;
    DBConnStr :String;
    DBUser    :String;
    DBPwd     :String;
  end;

  TCommDB = class(TDataModule)
    ADOQuery: TADOQuery;
    ADOConn: TADOConnection;
//    BDEQuery: TQuery;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
{$if Defined(SINGLETON)}
    bSelfConn : boolean;
{$if IS_BDE}
    BDEConn: TDatabase;
{$else}
    ADOConn2: TADOConnection;
{$ifend}
{$ifend}
  public
    function  ConnectDB:boolean;
    procedure Disconnect;
    function  IsConnected:boolean;
    function  IsQueryOpen:boolean;
    procedure SetDBSetting(dbPrm:SDBSetting); overload;
    procedure SetDBSetting(const sConn,sUser,sPwd:string); overload;
  public
    function  QueryDB(sSqlSen:String):boolean; overload;
    function  QueryDB(sSqlSen:String;slPrmList:TStrings):boolean;  overload;
    function  QueryDB(sSqlSen:String;oleVPrm:OleVariant):boolean;  overload;
    procedure CloseQuery;

    function  QueryDBNotOpen(oleVPrm:OleVariant):boolean;

    function  Field(nIndex:Integer):Variant;overload;
    function  Field(sFieldName:String):Variant;overload;
    function  FieldIsNull(nIndex:Integer):boolean;overload;
    function  FieldIsNull(sFieldName:String):boolean;overload;
    function  FieldAsString(nIndex:Integer):String;overload;
    function  FieldAsString(sFieldName:String):String;overload;
    function  FieldAsInt(nIndex:Integer):Integer;overload;
    function  FieldAsInt(sFieldName:String):Integer;overload;
    function  FieldAsFloat(nIndex:Integer):real;overload;
    function  FieldAsFloat(sFieldName:String):real;overload;
    function  FieldAsDatetime(nIndex:Integer):TDatetime;overload;
    function  FieldAsDatetime(sFieldName:String):TDatetime;overload;
    function  FieldAsBlob(nIndex:Integer):TBlobField;overload;
    function  FieldAsBlob(sFieldName:String):TBlobField;overload;
    function  FieldByInd(nIndex:Integer):TField;
    function  FieldByName(sFieldName:String):TField;

    procedure Edit;
    procedure Post;

    function  ReordCount:Integer;
    procedure NextRecord;
    function  EndOfQuery:boolean;

    procedure ExecSql(sSqlSen:String); overload;
    procedure ExecSql(sSqlSen:String;slPrmList:TStrings); overload;
    procedure ExecSql(sSqlSen:String;oleVPrm:OleVariant); overload;
    procedure ExecBatchSql(sSqlSen:String;oleVPrm:OleVariant;
              nSqlSum:integer; nPrmSum:integer); overload;
    procedure ExecBatchSql(sSqlSen:String; slPrmList:TStrings; nSPrmSum:integer;
              oleVPrm:OleVariant;nSqlSum:integer; nPrmSum:integer); overload;
    function  ExecSqlS(sSqlSens:TStrings):boolean;
    function  ExecSqlSOle(sSqls:OleVariant):string;

    function  BeginTrans:boolean;
    function  CommitTrans:boolean;
    function  RollbackTrans:boolean;

    function  QueryDataSet:TDataSet;
  end;

implementation

uses CommonFunc,SvrConfig,Windows;
{$if Defined(SINGLETON)}
var
  nDMCount : integer = 0;
  nDMConnect : integer = 0;
{$if IS_BDE}
  GlobalBDEConn: TDatabase=nil;
{$else}
  GlobalADOConn: TADOConnection=nil;
{$ifend}
{$ifend}

{$R *.dfm}

procedure TCommDB.DataModuleCreate(Sender: TObject);
begin
{$if Defined(SINGLETON)}
{$if IS_BDE}
  if (nDMCount=0) or (GlobalBDEConn = nil) then
  begin
    GlobalBDEConn := TDatabase.Create(nil);
    GlobalBDEConn.AliasName :='njzlscs63';
    GlobalBDEConn.DatabaseName := 'NJZLSCS_BDE_GLOBAL';
    GlobalBDEConn.LoginPrompt := false;
    GlobalBDEConn.Params.Clear;
    GlobalBDEConn.Params.Add('USER NAME=jlwater');
    GlobalBDEConn.Params.Add('PASSWORD=jlwater');
  end;
  BDEConn := GlobalBDEConn;
  BDEQuery.DatabaseName:= BDEConn.DatabaseName;
{$else}
  if (nDMCount=0) or (GlobalADOConn = nil) then
  begin
    GlobalADOConn := TADOConnection.Create(nil);
    GlobalADOConn.ConnectionString := svrInfo.sDBConn;
    GlobalADOConn.LoginPrompt := False;
  end;
  ADOConn := GlobalADOConn;
  ADOQuery.Connection := ADOConn;
{$ifend}
  InterlockedIncrement(nDMCount);
  bSelfConn := false;
{$else}   // not singleton
{$if IS_BDE}
  BDEConn.AliasName :='njzlscs63';
  BDEConn.DatabaseName := 'NJZLSCS_BDE_GLOBAL';
  BDEConn.LoginPrompt := false;
  BDEConn.Params.Clear;
  BDEConn.Params.Add('USER NAME=jlwater');
  BDEConn.Params.Add('PASSWORD=jlwater');
  BDEQuery.DatabaseName:= BDEConn.DatabaseName;
{$else}
  ADOConn.ConnectionString := svrInfo.sDBConn;
  ADOConn.LoginPrompt := False;
  ADOQuery.Connection := ADOConn;
{$ifend}
{$ifend}
end;

procedure TCommDB.DataModuleDestroy(Sender: TObject);
begin
{$if Defined(SINGLETON)}
  if bSelfConn then
    Disconnect;
  InterlockedDecrement(nDMCount);
{$if IS_BDE}
  if nDMCount=0 then
  begin
    if GlobalBDEConn.Connected then
      GlobalBDEConn.Close;
    GlobalBDEConn.Free;
    GlobalBDEConn := nil;
  end;
{$else}
  if nDMCount=0 then
  begin
    if GlobalADOConn.Connected then
      GlobalADOConn.Close;
    GlobalADOConn.Free;
    GlobalADOConn := nil;
  end;
{$ifend}
{$else}

{$if IS_BDE}
  if BDEConn.Connected then
    Disconnect;
{$else}
  if ADOConn.Connected then
    Disconnect;
{$ifend}

{$ifend}
end;

procedure TCommDB.SetDBSetting(dbPrm:SDBSetting);
begin
  SetDBSetting(dbPrm.DBConnStr,dbPrm.DBUser,dbPrm.DBPwd);
end;

procedure TCommDB.SetDBSetting(const sConn,sUser,sPwd:string);
var
  bIsConnect : boolean;
begin
{$if IS_BDE}
  bIsConnect := BDEConn.Connected;
  if bIsConnect then
    BDEConn.Close;
  BDEConn.Params.Clear;
  BDEConn.AliasName :='njzlscs63'; // sConn
  BDEConn.Params.Add('USER NAME=jlwater'); // sUser
  BDEConn.Params.Add('PASSWORD=jlwater'); // sPwd
  BDEConn.LoginPrompt:=False;
  if bIsConnect then
    BDEConn.open;
{
  BDEConn.AliasName :=sConn;
  BDEConn.Params.Add('USER NAME='+sUser);
  BDEConn.Params.Add('PASSWORD='+sPwd);
}
{$else}
  bIsConnect := ADOConn.Connected;
  if bIsConnect then
    ADOConn.Close;
  ADOConn.ConnectionString:=sConn;
  ADOConn.LoginPrompt:=False;
  if bIsConnect then
    ADOConn.open;
{$ifend}
end;

function TCommDB.ConnectDB:boolean;
var
  bRes:boolean;
begin
  try
{$if Defined(SINGLETON)}
{$if Defined(IS_BDE)}
    if (nDMConnect=0) or (not GlobalBDEConn.Connected) then
      GlobalBDEConn.Open;
{$else}
    if (nDMConnect=0) or (not GlobalADOConn.Connected) then
      GlobalADOConn.Open;
{$ifend}
    if not bSelfConn then
    begin
      InterlockedIncrement(nDMConnect);
      bSelfConn := true;
    end;
{$else}
{$if IS_BDE}
    BDEConn.Open;
{$else}
    ADOConn.Open; //
{$ifend}
{$ifend}
    bRes := true;
  except
    bRes := false;
  end;
  result := bRes;
end;

procedure TCommDB.Disconnect;
begin
{$if Defined(SINGLETON)}
  if bSelfConn then
  begin
    InterlockedDecrement(nDMConnect);
    bSelfConn := false;
  end;
{$if IS_BDE}
  if BDEQuery.Active then
    BDEQuery.Close;
  if (nDMConnect=0) and (GlobalBDEConn.Connected) then
    GlobalBDEConn.Close;
{$else}
  if ADOQuery.Active then
    ADOQuery.Close;
  if (nDMConnect=0) and (GlobalADOConn.Connected) then
    GlobalADOConn.Close;
{$ifend}
{$else}
{$if IS_BDE}
  if BDEQuery.Active then
    BDEQuery.Close;
   BDEConn.Close;
{$else}
  if ADOQuery.Active then
    ADOQuery.Close;
  ADOConn.Close;
{$ifend}
{$ifend}
end;

function  TCommDB.IsConnected:boolean;
begin
{$if IS_BDE}
  result := BDEConn.Connected;
{$else}
  result := ADOConn.Connected;
{$ifend}
end;

function  TCommDB.IsQueryOpen:boolean;
begin
{$if IS_BDE}
  result := BDEQuery.Active;
{$else}
  result := ADOQuery.Active;
{$ifend}
end;

function  TCommDB.QueryDataSet:TDataSet;
begin
{$if IS_BDE}
  result := BDEQuery;
{$else}
  result := ADOQuery;
{$ifend}
end;

procedure TCommDB.ExecSql(sSqlSen:String);
begin
{$if IS_BDE}
  BDEConn.Execute(sSqlSen);
{$else}
  ADOConn.Execute(sSqlSen);
{$ifend}
end;

procedure TCommDB.ExecSql(sSqlSen:String;slPrmList:TStrings);
var
  i,nPC:integer;
{$if false}  //for debug
  ntemp,nPrmNo,nEPos : integer;
  sDesSql,sWord:String;
begin
  sDesSql := sSqlSen;
  nPrmNo := 0;
  ntemp := Pos(':', sDesSql);
  while ntemp > 0 do
  begin
    nEPos := ntemp+1;
    sWord := TCommonFunc.GetAWord(sDesSql,nEPos);
    if Pos(sWord[1],'csdCSD')>0 then
      sDesSql :=  Copy( sDesSql,1,ntemp -1) + QuotedStr(slPrmList[nPrmNo]) +
                Copy( sDesSql,nEPos,length(sDesSql)-nEPos+1)
    else
      sDesSql :=  Copy( sDesSql,1,ntemp -1) + slPrmList[nPrmNo] +
                Copy( sDesSql,nEPos,length(sDesSql)-nEPos+1);

    Inc(nPrmNo);
    ntemp := Pos(':', sDesSql);
  end;
  ADOQuery.SQL.Clear; //BDEQuery.SQL.Clear;
  ADOQuery.Parameters.Clear;
  ADOQuery.SQL.Add(sDesSql); //BDEQuery.SQL.Add(sSqlSen);
  ADOQuery.ExecSQL; //BDEQuery.Open;
{$else}
begin
{$if IS_BDE}
  BDEQuery.SQL.Clear;
  BDEQuery.Params.Clear;
  BDEQuery.SQL.Add(sSqlSen);
  nPC := BDEQuery.Params.Count;
  for i:=0 to nPC-1 do
    BDEQuery.Params[i].Value := slPrmList[i];
  BDEQuery.ExecSQL;
{$else}
  ADOQuery.SQL.Clear;
  ADOQuery.Parameters.Clear;
  ADOQuery.SQL.Add(sSqlSen);
  nPC := ADOQuery.Parameters.Count;
  for i:=0 to nPC-1 do
    ADOQuery.Parameters[i].Value := slPrmList[i];
  ADOQuery.ExecSQL; 
{$ifend}

{$ifend}
end;

procedure TCommDB.ExecSql(sSqlSen:String;oleVPrm:OleVariant);
var
  i,nPC:integer;
begin
{$if IS_BDE}
  BDEQuery.SQL.Clear;
  BDEQuery.Params.Clear;
  BDEQuery.SQL.Add(sSqlSen);
  nPC := BDEQuery.Params.Count;
  for i:=0 to nPC-1 do
    BDEQuery.Params[i].Value := oleVPrm[i];
  BDEQuery.ExecSQL;
{$else}
  ADOQuery.SQL.Clear; //BDEQuery.SQL.Clear;
  ADOQuery.Parameters.Clear;
  ADOQuery.SQL.Add(sSqlSen); //BDEQuery.SQL.Add(sSqlSen);
  nPC := ADOQuery.Parameters.Count;
  for i:=0 to nPC-1 do
    ADOQuery.Parameters[i].Value := oleVPrm[i];
  ADOQuery.ExecSQL; //BDEQuery.Open;
{$ifend}
end;

function TCommDB.QueryDB(sSqlSen:String):boolean;
var
  bRes:boolean;
begin
  try
{$if IS_BDE}
    BDEQuery.SQL.Clear;
    BDEQuery.SQL.Add(sSqlSen);
    BDEQuery.Open;
{$else}
    ADOQuery.SQL.Clear; //BDEQuery.SQL.Clear;
    ADOQuery.SQL.Add(sSqlSen); //BDEQuery.SQL.Add(sSqlSen);
    ADOQuery.Open; //BDEQuery.Open;
{$ifend}
    bRes := true;
  except
    bRes := false;
  end;
  result := bRes;
end;

function  TCommDB.QueryDB(sSqlSen:String;slPrmList:TStrings):boolean;
var
  bRes:boolean;
  i,nPC:integer;
begin
  try
{$if IS_BDE}
    BDEQuery.SQL.Clear;
    BDEQuery.Params.Clear;
    BDEQuery.SQL.Add(sSqlSen);
    nPC := slPrmList.Count;
    for i:=0 to nPC-1 do
      BDEQuery.Params[i].Value := slPrmList[i];
    BDEQuery.Open;
{$else}
    ADOQuery.SQL.Clear;
    ADOQuery.Parameters.Clear;
    ADOQuery.SQL.Add(sSqlSen);
    nPC := slPrmList.Count;
    for i:=0 to nPC-1 do
      ADOQuery.Parameters[i].Value := slPrmList[i];
    ADOQuery.Open; 
{$ifend}
    bRes := true;
  except
    bRes := false;
  end;
  result := bRes;
end;


function  TCommDB.QueryDB(sSqlSen:String;oleVPrm:OleVariant):boolean;
var
  bRes:boolean;
  i,nPC:integer;
begin
  try
{$if IS_BDE}
    BDEQuery.SQL.Clear;
    BDEQuery.Params.Clear;
    BDEQuery.SQL.Add(sSqlSen);
    nPC := BDEQuery.Params.Count;
    for i:=0 to nPC-1 do
      BDEQuery.Params[i].Value := oleVPrm[i];
    BDEQuery.Open;
{$else}
    ADOQuery.SQL.Clear; //BDEQuery.SQL.Clear;
    ADOQuery.Parameters.Clear;
    ADOQuery.SQL.Add(sSqlSen); //BDEQuery.SQL.Add(sSqlSen);
    nPC := ADOQuery.Parameters.Count;
    for i:=0 to nPC-1 do
      ADOQuery.Parameters[i].Value := oleVPrm[i];
    ADOQuery.Open; //BDEQuery.Open;
{$ifend}
    bRes := true;
  except
    bRes := false;
  end;
  result := bRes;
end;

procedure TCommDB.ExecBatchSql(sSqlSen:String;oleVPrm:OleVariant;
              nSqlSum:integer; nPrmSum:integer);
var
  i,j:integer;
begin
{$if IS_BDE}
  BDEQuery.SQL.Clear;
  BDEQuery.Params.Clear;
  BDEQuery.SQL.Add(sSqlSen);
  for i:=0 to nSqlSum-1 do
  begin
    for j:=0 to nPrmSum-1 do
      BDEQuery.Params[j].Value := oleVPrm[i][j];
    BDEQuery.ExecSQL;
  end;
{$else}
  ADOQuery.SQL.Clear; //BDEQuery.SQL.Clear;
  ADOQuery.Parameters.Clear;
  ADOQuery.SQL.Add(sSqlSen); //BDEQuery.SQL.Add(sSqlSen);
  for i:=0 to nSqlSum-1 do
  begin
    for j:=0 to nPrmSum-1 do
      ADOQuery.Parameters[j].Value := oleVPrm[i][j];
    ADOQuery.ExecSQL; //BDEQuery.Open;  JLWDB.Disconnect;
  end;
{$ifend}
end;

procedure TCommDB.ExecBatchSql(sSqlSen:String; slPrmList:TStrings; nSPrmSum:integer;
          oleVPrm:OleVariant;nSqlSum:integer; nPrmSum:integer);
var
  i,j:integer;
begin
{$if IS_BDE}
  BDEQuery.SQL.Clear;
  BDEQuery.Params.Clear;
  BDEQuery.SQL.Add(sSqlSen);
  for j:=0 to nSPrmSum-1 do
    BDEQuery.Params[j].Value := slPrmList[j];

  for i:=0 to nSqlSum-1 do
  begin
    for j:= 0 to  nPrmSum-1 do
      BDEQuery.Params[nSPrmSum+j].Value := oleVPrm[i][j];
    BDEQuery.ExecSQL;
  end;
{$else}
  ADOQuery.SQL.Clear; //BDEQuery.SQL.Clear;
  ADOQuery.Parameters.Clear;
  ADOQuery.SQL.Add(sSqlSen); //BDEQuery.SQL.Add(sSqlSen);
  for j:=0 to nSPrmSum-1 do
    ADOQuery.Parameters[j].Value := slPrmList[j];
  for i:=0 to nSqlSum-1 do
  begin
    for j:=0 to nPrmSum-1 do
      ADOQuery.Parameters[nSPrmSum+j].Value := oleVPrm[i][j];
    ADOQuery.ExecSQL; //BDEQuery.Open;  JLWDB.Disconnect;
  end;
{$ifend}
end;

function  TCommDB.QueryDBNotOpen(oleVPrm:OleVariant):boolean;
var
  bRes:boolean;
  i,nPC:integer;
begin
  try
{$if IS_BDE}
    BDEQuery.SQL.Clear;
    BDEQuery.Params.Clear;
    BDEQuery.SQL.Add(oleVPrm[0]);
    nPC := BDEQuery.Params.Count;
    for i:=0 to nPC-1 do
      BDEQuery.Params[i].Value := oleVPrm[i+1];
//    BDEQuery.Open;
{$else}
    ADOQuery.SQL.Clear; //BDEQuery.SQL.Clear;
    ADOQuery.Parameters.Clear;
    ADOQuery.SQL.Add(oleVPrm[0]); //BDEQuery.SQL.Add(sSqlSen);
    nPC := ADOQuery.Parameters.Count;
    for i:=0 to nPC-1 do
      ADOQuery.Parameters[i].Value := oleVPrm[i+1];
{$ifend}
    bRes := true;
  except
    bRes := false;
  end;
  result := bRes;
end;

procedure TCommDB.CloseQuery;
begin
{$if IS_BDE}
  BDEQuery.Close;
{$else}
  ADOQuery.Close; //
{$ifend}
end;

function  TCommDB.Field(nIndex:Integer):Variant;
begin
{$if IS_BDE}
  result := BDEQuery.Fields[nIndex].Value;
{$else}
  result := ADOQuery.Fields[nIndex].Value;//
{$ifend}
end;

function  TCommDB.Field(sFieldName:String):Variant;
begin
{$if IS_BDE}
  result := BDEQuery.FieldByName(sFieldName).Value;
{$else}
  result := ADOQuery.FieldByName(sFieldName).Value;//
{$ifend}
end;

function  TCommDB.FieldIsNull(nIndex:Integer):boolean;
begin
{$if IS_BDE}
  result := BDEQuery.Fields[nIndex].IsNull;
{$else}
  result := ADOQuery.Fields[nIndex].IsNull;
{$ifend}
end;

function  TCommDB.FieldIsNull(sFieldName:String):boolean;
begin
{$if IS_BDE}
  result := BDEQuery.FieldByName(sFieldName).IsNull;
{$else}
  result := ADOQuery.FieldByName(sFieldName).IsNull;
{$ifend}
end;

function  TCommDB.FieldAsString(nIndex:Integer):String;
begin
{$if IS_BDE}
  result := trim( BDEQuery.Fields[nIndex].AsString);
{$else}
  result := trim( ADOQuery.Fields[nIndex].AsString);
{$ifend}  // 
end;

function  TCommDB.FieldAsString(sFieldName:String):String;
begin
{$if IS_BDE}
  result := Trim(BDEQuery.FieldByName(sFieldName).AsString);
{$else}
  result := Trim(ADOQuery.FieldByName(sFieldName).AsString);
{$ifend}
end;

function  TCommDB.FieldAsInt(nIndex:Integer):Integer;
begin
{$if IS_BDE}
  result := BDEQuery.Fields[nIndex].AsInteger;
{$else}
  if ADOQuery.Fields[nIndex].IsNull then
    result :=0
  else
    result := ADOQuery.Fields[nIndex].AsInteger;
{$ifend}
end;

function  TCommDB.FieldAsInt(sFieldName:String):Integer;
begin
{$if IS_BDE}
  result := BDEQuery.FieldByName(sFieldName).AsInteger;
{$else}
  if ADOQuery.FieldByName(sFieldName).IsNull then
    result :=0
  else
    result := ADOQuery.FieldByName(sFieldName).AsInteger;
{$ifend}
end;

function  TCommDB.FieldAsFloat(nIndex:Integer):real;
begin
{$if IS_BDE}
  result := BDEQuery.Fields[nIndex].AsFloat;
{$else}
  if ADOQuery.Fields[nIndex].IsNull then
    result :=0
  else
    result := ADOQuery.Fields[nIndex].AsFloat;
{$ifend}
end;

function  TCommDB.FieldAsFloat(sFieldName:String):real;
begin
{$if IS_BDE}
  result := BDEQuery.FieldByName(sFieldName).AsFloat;
{$else}
  if ADOQuery.FieldByName(sFieldName).IsNull then
    result :=0
  else
    result := ADOQuery.FieldByName(sFieldName).AsFloat;
{$ifend}
end;

function  TCommDB.FieldAsDatetime(nIndex:Integer):TDatetime;
begin
{$if IS_BDE}
  result := BDEQuery.Fields[nIndex].AsDateTime;
{$else}
  result := ADOQuery.Fields[nIndex].AsDateTime;
{$ifend}
end;

function  TCommDB.FieldAsDatetime(sFieldName:String):TDatetime;
begin
{$if IS_BDE}
  result := BDEQuery.FieldByName(sFieldName).AsDateTime;
{$else}
  result := ADOQuery.FieldByName(sFieldName).AsDateTime;
{$ifend}
end;

function  TCommDB.FieldAsBlob(nIndex:Integer):TBlobField;
begin
{$if IS_BDE}
  result := BDEQuery.Fields[nIndex] as TBlobField;
{$else}
  result := ADOQuery.Fields[nIndex] as TBlobField;
{$ifend}
end;

function  TCommDB.FieldAsBlob(sFieldName:String):TBlobField;
begin
{$if IS_BDE}
  result := BDEQuery.FieldByName('FormContent') as TBlobField;
{$else}
  result := ADOQuery.FieldByName('FormContent') as TBlobField;
{$ifend}
end;

function  TCommDB.FieldByInd(nIndex:Integer):TField;
begin
{$if IS_BDE}
  result := BDEQuery.Fields[nIndex];
{$else}
  result := ADOQuery.Fields[nIndex];
{$ifend}
end;

function  TCommDB.FieldByName(sFieldName:String):TField;
begin
{$if IS_BDE}
  result := BDEQuery.FieldByName('FormContent');
{$else}
  result := ADOQuery.FieldByName('FormContent');
{$ifend}
end;

function  TCommDB.ReordCount:Integer;
begin
{$if IS_BDE}
  result := BDEQuery.RecordCount;
{$else}
  result := ADOQuery.RecordCount;
{$ifend}
end;

procedure TCommDB.NextRecord;
begin
{$if IS_BDE}
  BDEQuery.Next;
{$else}
  ADOQuery.Next;
{$ifend}
end;

function  TCommDB.EndOfQuery:boolean;
begin
{$if IS_BDE}
  result := BDEQuery.Eof;
{$else}
  result := ADOQuery.Eof;
{$ifend}
end;

procedure TCommDB.Edit;
begin
{$if IS_BDE}
  BDEQuery.Edit;
{$else}
  ADOQuery.Edit;
{$ifend}
end;

procedure TCommDB.Post;
begin
{$if IS_BDE}
  BDEQuery.Post;
{$else}
  ADOQuery.Post;
{$ifend}
end;

function  TCommDB.ExecSqlS(sSqlSens:TStrings):boolean;
var
  bRes:boolean;
  i,nL:integer;
begin
  bRes := false;
{$if IS_BDE}
  try
    BDEConn.StartTransaction;
    nl := sSqlSens.Count;
    for i:=0 to nl-1 do
      BDEConn.Execute(sSqlSens[i]);
    BDEConn.Commit;
    bRes := true;
  except
    if BDEConn.InTransaction then
      BDEConn.Rollback;
  end;
{$else}
  try
    ADOConn.BeginTrans;
    nl := sSqlSens.Count;
    for i:=0 to nl-1 do
      ADOConn.Execute(sSqlSens[i]);
    ADOConn.CommitTrans;
    bRes := true;
  except
    if ADOConn.InTransaction then
      ADOConn.RollbackTrans;
  end;
{$ifend}
  result := bRes;
end;

function  TCommDB.ExecSqlSOle(sSqls:OleVariant):string;
var
  i,nL:integer;
begin
  result := '';
{$if IS_BDE}
  try
    BDEConn.StartTransaction;
    nl := VarArrayHighBound(sSqls,1);
    for i:=0 to nl-1 do
      BDEConn.Execute(sSqls[i]);
    BDEConn.Commit;
  except on e:exception do
  begin
    if BDEConn.InTransaction then
      BDEConn.Rollback;
    result:=e.Message;
  end;
  end;
{$else}
  try
    ADOConn.BeginTrans;
    nl := VarArrayHighBound(sSqls,1);
    for i:=0 to nl do
      ADOConn.Execute(sSqls[i]);
    ADOConn.CommitTrans;
  except on e:exception do
  begin
    if ADOConn.InTransaction then
      ADOConn.RollbackTrans;
    result:=e.Message;
  end;
  end;
{$ifend}
end;

function  TCommDB.BeginTrans:boolean;
begin
{$if IS_BDE}
  if BDEConn.InTransaction then
    result := false
  else
  begin
    BDEConn.StartTransaction;
    result := true;
  end;
{$else}
  if ADOConn.InTransaction then
    result := false
  else
  begin
    ADOConn.BeginTrans;
    result := true;
  end;
{$ifend}
end;

function  TCommDB.CommitTrans:boolean;
begin
{$if IS_BDE}
  if BDEConn.InTransaction then
  begin
    BDEConn.Commit;
    result := true;
  end else
    result := false;
{$else}
  if ADOConn.InTransaction then
  begin
    ADOConn.CommitTrans;
    result := true;
  end else
    result := false;
{$ifend}
end;

function  TCommDB.RollbackTrans:boolean;
begin
{$if IS_BDE}
  if BDEConn.InTransaction then
  begin
    BDEConn.Rollback;
    result := true;
  end else
    result := false;
{$else}
  if ADOConn.InTransaction then
  begin
    ADOConn.RollbackTrans;
    result := true;
  end else
    result := false;
{$ifend}
end;

end.
