unit RunDataMap;

interface
uses SysUtils,ACTIVEX,CommDBM,DefDB;

type

  FieldMappingDesc = record
    m_LeftName,
    m_RightName : String;
    m_nColType : integer;
    m_IsKey  : boolean;
    m_IsNullable : boolean;
    m_DefaultValue : String;
    m_Order : integer;
  end;

  FieldMappingList = array of FieldMappingDesc;

  TableMapInfo = record
    m_InsertSql,
    m_UpdateSql,
    m_IsExistSql : String;
    m_SourceSql,
    m_DesTable,
    m_RowOptType : String;
    m_FieldCount : integer;  //配对的fieldCount
    m_PrameterSum : integer;  //insert语句和Update语句的参数个数
    m_DestFieldCount : integer;
    m_SouFieldCount : integer;
    m_FieldMap : FieldMappingList;
    m_KeyCount : integer;
    m_InsertFieldMap : array of integer;//记录字段在 insert语句中的顺序号
    m_UpdateFieldMap : array of integer;//记录字段在 update语句中的顺序号
    m_KeyFieldMap : array of integer;
    m_SqlBeforeLeft,
    m_SqlBeforeRight,
    m_SqlAfterRight,
    m_SqlAfterLeft,
    m_SqlErrorLeft,
    m_SqlErrorRight,
    m_SqlCompleteLeft,
    m_SqlCompleteRight : String;
    m_RepeatRun : boolean;
  end;

  TRunDataMap = class
  private
    m_souDM,m_destDM : TCommDB;
    m_sProjPath,m_sWorkPath,m_sLogName,m_sErrorData : String;
    m_LeftDBCfg,m_RightDBCfg : DBConfig;
    m_TabMap : TableMapInfo;

    function LoadFieldMapping(const sMFP : string):integer;
    procedure MakeSql ;

    procedure RunMap(const sMFP : string);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Run(const sPFP,sLogPath : string);
  end;

implementation
uses CommonFunc,DB,Classes,Windows,ADODB;

constructor TRunDataMap.Create;
begin
  m_souDM := TCommDB.Create(nil);
  m_destDM := TCommDB.Create(nil);
end;

destructor TRunDataMap.Destroy;
begin
  m_souDM.Free;
  m_destDM.Free;
end;


function TRunDataMap.LoadFieldMapping(const sMFP : string):integer;
var
  i,nC,strl:integer;
  sFormSql : String;
begin

  m_TabMap.m_SqlBeforeLeft := TCommonFunc.GetProfileValue('source','before_sql','',sMFP);
  m_TabMap.m_SqlAfterLeft := TCommonFunc.GetProfileValue('source','after_sql','',sMFP);
  m_TabMap.m_SqlBeforeRight := TCommonFunc.GetProfileValue('destination','before_sql','',sMFP);
  m_TabMap.m_SqlAfterRight := TCommonFunc.GetProfileValue('destination','after_sql','',sMFP);

  m_TabMap.m_SqlErrorLeft := TCommonFunc.GetProfileValue('source','error_sql','',sMFP);
  m_TabMap.m_SqlErrorRight := TCommonFunc.GetProfileValue('destination','error_sql','',sMFP);

  m_TabMap.m_SqlCompleteLeft := TCommonFunc.GetProfileValue('source','complete_sql','',sMFP);
  m_TabMap.m_SqlCompleteRight := TCommonFunc.GetProfileValue('destination','complete_sql','',sMFP);

  sFormSql := TCommonFunc.GetProfileValue('source','from_sql','',sMFP);
  //m_TabMap.m_SourceSql := TCommonFunc.GetProfileValue('source','query_sql','',sMFP);
  m_TabMap.m_DesTable := TCommonFunc.GetProfileValue('destination','source_name','',sMFP);
  m_TabMap.m_FieldCount := TCommonFunc.GetProfileInt('mapinfo','valid_column_count',0,sMFP);

  m_TabMap.m_DestFieldCount := TCommonFunc.GetProfileInt('mapinfo','right_column_count',0,sMFP);
  m_TabMap.m_SouFieldCount := TCommonFunc.GetProfileInt('mapinfo','left_column_count',0,sMFP);
  if(m_TabMap.m_DestFieldCount< m_TabMap.m_FieldCount) then// 兼容以前的版本
    m_TabMap.m_DestFieldCount := m_TabMap.m_FieldCount;

  m_TabMap.m_RowOptType := TCommonFunc.GetProfileValue('destination','row_opt','',sMFP);
  m_TabMap.m_RepeatRun  :=  TCommonFunc.GetProfileValue('source','repeat','no',sMFP) = 'yes';

  m_TabMap.m_SourceSql :=  'select ';


  nC :=m_TabMap.m_SouFieldCount;
  if nC>0 then
     m_TabMap.m_SourceSql :=  'select ' +  TCommonFunc.GetProfileValue('mapinfo','col'+IntToStr(1)+'_l_desc','',sMFP);

  for i:=2 to nC do
    m_TabMap.m_SourceSql := m_TabMap.m_SourceSql +', '+ TCommonFunc.GetProfileValue('mapinfo','col'+IntToStr(i)+'_l_desc','',sMFP);

  m_TabMap.m_SourceSql := m_TabMap.m_SourceSql +' '+ sFormSql;

  nC :=m_TabMap.m_DestFieldCount;
  SetLength(m_TabMap.m_FieldMap,nC+1);
  for i:=0 to nC-1 do
  begin
    m_TabMap.m_FieldMap[i].m_LeftName := TCommonFunc.GetProfileValue('mapinfo','col'+IntToStr(i+1)+'_l','',sMFP);
    m_TabMap.m_FieldMap[i].m_RightName := TCommonFunc.GetProfileValue('mapinfo','col'+IntToStr(i+1)+'_r','',sMFP);
    m_TabMap.m_FieldMap[i].m_nColType := TCommDB.GetInnerType(TCommonFunc.GetProfileValue('mapinfo','col'+IntToStr(i+1)+'_r_type','',sMFP));
    m_TabMap.m_FieldMap[i].m_Order := TCommonFunc.GetProfileInt('mapinfo','col'+IntToStr(i+1)+'_r_order',0,sMFP);
    m_TabMap.m_FieldMap[i].m_IsNullable := TCommonFunc.GetProfileValue('mapinfo','col'+IntToStr(i+1)+'_r_nullable','Y',sMFP) = 'Y';
    m_TabMap.m_FieldMap[i].m_DefaultValue :=Trim( TCommonFunc.GetProfileValue('mapinfo','col'+IntToStr(i+1)+'_r_default','',sMFP) );
    strl := length(m_TabMap.m_FieldMap[i].m_DefaultValue);
    if(strl>2) and (m_TabMap.m_FieldMap[i].m_DefaultValue[1]='[') and (m_TabMap.m_FieldMap[i].m_DefaultValue[strl]=']')
    then
       m_TabMap.m_FieldMap[i].m_DefaultValue := '''' + copy(m_TabMap.m_FieldMap[i].m_DefaultValue ,2,strl-2) +'''';

    m_TabMap.m_FieldMap[i].m_IsKey := TCommonFunc.GetProfileValue('mapinfo','col'+IntToStr(i+1)+'_r_key','N',sMFP)='Y';
  end;
  result := nC;

end;

procedure TRunDataMap.MakeSql;
var
  i,nKey,nCol,nC: integer;
  sUpdateSql,sWhere:String;
  sInsertSql,sValues:String;
  sIsExistSql:String;
  function SqlQuotedStr(str:String):String;
  var
    l : integer;
    tempStr : String;
  begin
    l := length(str);
    if (str[1]='''') or (str[1]='"') or ((str[1]='[') and (str[l]=']')) then
    begin
      tempStr := StringReplace( Copy(str,2,l-2) ,'''''','''',[rfReplaceAll]);
      result := QuotedStr(tempStr)
    end else
      result := str;
    {
    begin
      tempStr := QuotedStr(str);
      l := length(tempStr);
      result := Copy(tempStr,2,l-2);
    end;
    }
  end;


begin
  nKey := 0; nCol := 0;

  SetLength(m_TabMap.m_UpdateFieldMap,m_TabMap.m_FieldCount+1);
  SetLength(m_TabMap.m_InsertFieldMap,m_TabMap.m_FieldCount+1);

  m_TabMap.m_PrameterSum :=0;

  sInsertSql := 'insert into '+m_TabMap.m_DesTable+' (';
  sValues:='values(';

  sIsExistSql := 'select count(1) as isthere from ' +m_TabMap.m_DesTable;

  sUpdateSql := 'update '+m_TabMap.m_DesTable+' set ';
  sWhere:='';

  nC := m_TabMap.m_FieldCount;

  for i:=0 to nC-1 do
  begin
    if i>0 then
    begin
      sInsertSql := sInsertSql+',';
      sValues := sValues+',';
    end;

    sInsertSql := sInsertSql+ m_TabMap.m_FieldMap[i].m_RightName ;
    if '' = m_TabMap.m_FieldMap[i].m_DefaultValue then
    begin
      m_TabMap.m_InsertFieldMap[m_TabMap.m_PrameterSum] := i;
      m_TabMap.m_PrameterSum := m_TabMap.m_PrameterSum+1;
      sValues := sValues + ':prm'+IntToStr(i);
    end else
      sValues := sValues + m_TabMap.m_FieldMap[i].m_DefaultValue ;//SqlQuotedStr(m_TabMap.m_FieldMap[i].m_DefaultValue);// if
    //不能确定 m_TabMap.m_FieldMap[i].m_LeftName  是否是一个合法的字符串
    //在触发语句中的变量对应的左边的字段一定要是一个合法的字符串，否则无法运行 在定义对应关系时可以检查语句，不过这个难度较大且没有太大必要

    if m_TabMap.m_FieldMap[i].m_IsKey then
    begin
      if nKey>0 then
        sWhere :=  ' and ' + sWhere ;

      if '' = m_TabMap.m_FieldMap[i].m_DefaultValue then
      begin
        sWhere :=  m_TabMap.m_FieldMap[i].m_RightName+'=:prm'+IntToStr(i) + sWhere;
        Inc(nKey);
        m_TabMap.m_UpdateFieldMap[nC-nKey] := i;
      end else
        sWhere :=  m_TabMap.m_FieldMap[i].m_RightName+'='+m_TabMap.m_FieldMap[i].m_DefaultValue + sWhere;  //SqlQuotedStr

    end else
    begin
      if nCol>0 then
        sUpdateSql :=  sUpdateSql +',' ;

      if '' = m_TabMap.m_FieldMap[i].m_DefaultValue then
      begin
        sUpdateSql := sUpdateSql + m_TabMap.m_FieldMap[i].m_RightName+'=:prm'+IntToStr(i) ;
        m_TabMap.m_UpdateFieldMap[nCol] := i;
        Inc(nCol);
      end else
        sUpdateSql := sUpdateSql + m_TabMap.m_FieldMap[i].m_RightName+'='+m_TabMap.m_FieldMap[i].m_DefaultValue;//SqlQuotedStr();
    end;

  end;// end for

  //常量字段
  for i:=m_TabMap.m_FieldCount to m_TabMap.m_DestFieldCount-1 do
  begin
    if '' <> m_TabMap.m_FieldMap[i].m_DefaultValue then
    begin
      sInsertSql := sInsertSql+ ','+m_TabMap.m_FieldMap[i].m_RightName ;
      sValues := sValues + ','+ m_TabMap.m_FieldMap[i].m_DefaultValue; //SqlQuotedStr(
      if m_TabMap.m_FieldMap[i].m_IsKey then
      begin
        if nKey>0 then
          sWhere :=  ' and ' + sWhere ;
        sWhere :=  m_TabMap.m_FieldMap[i].m_RightName+'='+m_TabMap.m_FieldMap[i].m_DefaultValue + sWhere;  //SqlQuotedStr(

      end else
      begin
        if nCol>0 then
          sUpdateSql :=  sUpdateSql +',' ;
        sUpdateSql := sUpdateSql + m_TabMap.m_FieldMap[i].m_RightName+'='+m_TabMap.m_FieldMap[i].m_DefaultValue;   //SqlQuotedStr(
      end;
    end;
  end;


  m_TabMap.m_InsertSql := sInsertSql+') '+sValues+')';
  m_TabMap.m_UpdateSql := sUpdateSql+' where '+ sWhere;
  m_TabMap.m_IsExistSql := sIsExistSql + ' where '+ sWhere;

  if m_TabMap.m_PrameterSum < m_TabMap.m_FieldCount then
    for i:=0 to nKey-1 do
      m_TabMap.m_UpdateFieldMap[nCol+i] := m_TabMap.m_UpdateFieldMap[m_TabMap.m_FieldCount - nKey +i];

  m_TabMap.m_KeyCount := nKey;
  SetLength(m_TabMap.m_KeyFieldMap ,nKey +1);
  for i:=0 to nKey-1 do
    m_TabMap.m_KeyFieldMap[i] := m_TabMap.m_UpdateFieldMap[nCol+i];

end;

//运行一组对应关系迁移
procedure TRunDataMap.RunMap(const sMFP : string);
var
  sErrorData,sErrorFile,sLastErrorMsg:String;
  nMoved,nError,nFieldCount, preMoved,curMoved,preSucceed : integer;
  dtBeginMove,dtEndMove : TDateTime;

  bBL,bBR,bAR,bAL,bLE,bRE :boolean;

  procedure SetAdoParameter(exeQuery :TADOQuery; pn : integer; sn :integer);
  var
    ft :TFieldType;
    ms: TMemoryStream;
    //logsize : integer;
  begin
    ft := m_souDM.FieldType(sn);
    if ft = ftBCD then
      ft := ftFloat
    else if  (m_RightDBCfg.m_DBType = Oracle) and (m_TabMap.m_FieldMap[sn].m_nColType = 4 {clob}) then
      ft := ftMemo;
    exeQuery.Parameters[pn].DataType := ft;

    //判断是否为常量
    {if m_TabMap.m_FieldMap[sn].m_DefaultValue <> '' then
      m_destDM.ADOExecute.Parameters[pn].Value := m_TabMap.m_FieldMap[sn].m_DefaultValue
    else
    }
    if not m_souDM.FieldIsNull(sn) then
    begin
      if (ft in  [ftOraClob,ftMemo,ftBlob,ftOraBlob,ftVarBytes,  ftGraphic, ftFmtMemo])  then
      begin
        if m_souDM.FieldAsBlob(sn).BlobSize > 1 then
        begin
          ms:=TMemoryStream.Create;
          m_souDM.FieldAsBlob(sn).SaveToStream(ms);
          //ms.SaveToFile('D:\'+m_souDM.FieldName(sn)+'.txt');
          //logsize := ms.Size;
          //writeln( IntToStr(logsize));
          //logsize := m_souDM.FieldAsBlob(sn).BlobSize;
          //writeln( IntToStr(logsize));
          exeQuery.Parameters[pn].LoadFromStream(ms,ft);// .Value := m_souDM.FieldAsString(i)
          ms.Free;
        end;
      end else
        exeQuery.Parameters[pn].Value := m_souDM.Field(sn);
    end; //of not null
  end;


  procedure SetAdoParameter2(exeQuery :TADOQuery; pn : integer; sPN :String;nSqlType:integer);
  var
    sPrmName : String;
  begin
    sPrmName := UpperCase(sPN);

    if (sPrmName='TODAY') then
    begin
      exeQuery.Parameters[pn].DataType := ftDateTime;
      exeQuery.Parameters[pn].Value := now;
    end else if nSqlType <> 2 then
    begin
      if (nSqlType=1) and (sPrmName='SQL_ERROR_MSG') then
      begin
        exeQuery.Parameters[pn].DataType := ftString;
        exeQuery.Parameters[pn].Value := sLastErrorMsg;
      end else
      begin
        SetAdoParameter(exeQuery , pn , m_souDM.FieldNo(sPN) - 1 );
      end;
    end else // if nSqlType = 2 then
    {nMoved,nError}
    begin
      if sPrmName='SYNC_DATA_PIECES' then
      begin
        exeQuery.Parameters[pn].DataType := ftInteger;
        exeQuery.Parameters[pn].Value := nMoved + nError;
      end else if sPrmName='SUCCEED_PIECES' then
      begin
        exeQuery.Parameters[pn].DataType := ftInteger;
        exeQuery.Parameters[pn].Value := nMoved;
      end else if sPrmName='FAULT_PIECES' then
      begin
        exeQuery.Parameters[pn].DataType := ftInteger;
        exeQuery.Parameters[pn].Value := nError;
      end else if sPrmName='SYNC_BEGIN_TIME' then
      begin
        exeQuery.Parameters[pn].DataType := ftDateTime;
        exeQuery.Parameters[pn].Value := dtBeginMove;
      end else if sPrmName='SYNC_END_TIME' then
      begin
        exeQuery.Parameters[pn].DataType := ftDateTime;
        exeQuery.Parameters[pn].Value := dtEndMove;
      end;
    end;
  end;

  //执行 触发语句，存储过程
  procedure ExecTriggerSql(exeQuery :TADOQuery; sSql : String;nSqlType:integer);
  var
    i,nPC : integer;
    sPN : String;
  begin
    exeQuery.SQL.Clear;
    exeQuery.Parameters.Clear;
    exeQuery.SQL.Add(sSql);

    nPC := exeQuery.Parameters.Count;
    //获取对应的参数名称，根据名称找到对应的值
    for i:=0 to nPC-1 do
    begin
      sPN := exeQuery.Parameters[i].Name;
      SetAdoParameter2(exeQuery,i,sPN,nSqlType);
    end;
    exeQuery.ExecSQL;
  end;

  //执行数据迁移
  procedure ExeInsert;
  var
    i,nC:integer;
  begin
//    m_destDM.ADOQuery.Parameters.Clear;
//    m_destDM.ADOQuery.ParamCheck := true;
    nC := m_destDM.PrepareExecSql(m_destDM.ADOExecute , m_TabMap.m_InsertSql);

    for i:=0 to nC-1 do
      SetAdoParameter(m_destDM.ADOExecute,i,m_TabMap.m_InsertFieldMap[i]);
//    m_destDM.ADOQuery.ParamCheck := false;
    m_destDM.ADOExecute.ExecSql;

  end;

  procedure ExeUpdate;
  var
    i,nC:integer;
  begin
    nC := m_destDM.PrepareExecSql(m_destDM.ADOExecute , m_TabMap.m_UpdateSql);
    for i:=0 to nC-1 do
      SetAdoParameter(m_destDM.ADOExecute,i,m_TabMap.m_UpdateFieldMap[i]);

    m_destDM.ADOExecute.ExecSql;
  end;

  procedure ExeMoveData;
  var
    i,nRN,nPC,nC:integer;
  begin
    if m_TabMap.m_RowOptType = 'insert' then
      ExeInsert
    else if m_TabMap.m_RowOptType = 'update' then
      ExeUpdate
    else
    begin
      //判断是否存在记录，如果存在就更新，否则插入
      m_destDM.ADOExecute.SQL.Clear;
      m_destDM.ADOExecute.Parameters.Clear;
      m_destDM.ADOExecute.SQL.Add(m_TabMap.m_IsExistSql);

      nPC := m_destDM.ADOExecute.Parameters.Count;
      for i:=0 to nPC-1 do
      begin
        nRN := m_TabMap.m_KeyFieldMap[i];
        SetAdoParameter(m_destDM.ADOExecute,i,nRN);
      end; // end for

      nC := 0;
      m_destDM.ADOExecute.Open;
      if not m_destDM.ADOExecute.Eof then
        nC := m_destDM.ADOExecute.Fields[0].AsInteger;
      m_destDM.ADOExecute.Close;

      if nC>0 then
        ExeUpdate
      else
        ExeInsert;
    end;
  end;

  procedure WriteErrorLog(e:exception);
  var
    i:integer;
    sValue : String;
  begin

    TCommonFunc.WriteLogEx(m_sLogName,'记录 '+IntToStr(nMoved+nError)+' 被拒绝 :'+e.Message,true,true);
    sErrorData := '';
    for i:=0 to nFieldCount-1 do
    begin
      if m_souDM.FieldType(i) in  [ftBlob,ftOraBlob,ftOraClob,ftVarBytes, ftMemo, ftGraphic, ftFmtMemo] then
        sValue := 'lob'
      else
        sValue := m_souDM.FieldAsString(i);

      if (i>0) then
        sErrorData := sErrorData + ','+ sValue
      else
        sErrorData := sValue;
    end;
    //TCommonFunc.WriteLogEx(m_sLogName,sErrorData,true);
    TCommonFunc.WriteLogEx(sErrorFile,sErrorData,true);
    //writeln(sErrorData);
  end;

begin
  sErrorFile := m_sErrorData +'\'+ ExtractFileName(sMFP) +'.err';
  nMoved := 0;
  nError := 0;
  dtBeginMove := now;
  LoadFieldMapping(sMFP);

  if m_TabMap.m_FieldCount < 1 then
  begin
    TCommonFunc.WriteLogEx(m_sLogName,'没有有效的对应关系，只执行触发器代码。' ,true,true);
  end;

  if m_TabMap.m_FieldCount >0 then
    MakeSql;

  bBL := length(m_TabMap.m_SqlBeforeLeft) > 6;
  bBR := length(m_TabMap.m_SqlBeforeRight) > 6;
  bAR := length(m_TabMap.m_SqlAfterRight) > 6;
  bAL := length(m_TabMap.m_SqlAfterLeft) > 6;
  bLE := length(m_TabMap.m_SqlErrorLeft) > 6;
  bRE := length(m_TabMap.m_SqlErrorRight) > 6;

  TCommonFunc.WriteLogEx(m_sLogName,'开始迁移 '+sMFP +' ......' ,true,true);

  TCommonFunc.WriteLogEx(m_sLogName,'    '+m_TabMap.m_SourceSql ,true,false);

  if m_TabMap.m_FieldCount < 1 then
    TCommonFunc.WriteLogEx(m_sLogName,'没有有效的对应关系，只执行触发器代码。' ,true,true)
  else
    TCommonFunc.WriteLogEx(m_sLogName,'    '+m_TabMap.m_InsertSql ,true,false);


  if m_TabMap.m_FieldCount >0 then
  begin
    if m_TabMap.m_RowOptType = 'merge' then
      TCommonFunc.WriteLogEx(m_sLogName,'    '+m_TabMap.m_IsExistSql ,true,false);
    if m_TabMap.m_RowOptType <> 'insert' then
      TCommonFunc.WriteLogEx(m_sLogName,'    '+m_TabMap.m_UpdateSql ,true,false);
  end;

  if bBL then
    TCommonFunc.WriteLogEx(m_sLogName,m_TabMap.m_SqlBeforeLeft ,true,false);
  if bBR then
    TCommonFunc.WriteLogEx(m_sLogName,m_TabMap.m_SqlBeforeRight ,true,false);
  if bAR then
    TCommonFunc.WriteLogEx(m_sLogName,m_TabMap.m_SqlAfterRight ,true,false);
  if bAL then
    TCommonFunc.WriteLogEx(m_sLogName,m_TabMap.m_SqlAfterLeft ,true,false);
  if bLE then
    TCommonFunc.WriteLogEx(m_sLogName,m_TabMap.m_SqlErrorLeft ,true,false);
  if bRE then
    TCommonFunc.WriteLogEx(m_sLogName,m_TabMap.m_SqlErrorRight ,true,false);

  curMoved := 0;
  repeat
    preMoved := curMoved;
    curMoved := 0;
    try
      m_souDM.ADOQuery.SQL.Clear; //BDEQuery.SQL.Clear;
      m_souDM.ADOQuery.SQL.Add(m_TabMap.m_SourceSql); //BDEQuery.SQL.Add(sSqlSen);
      m_souDM.ADOQuery.Open;
    except
      on   e:exception   do
      begin
        TCommonFunc.WriteLogEx(m_sLogName,'查询语句出错 :'+e.Message,true,true);
        break;
      end;
    end;

    nFieldCount := m_souDM.FieldCount;
    preSucceed := nMoved;// 记录上次成功的条数，如果一个循环没有一条成功的则终止循环
    while not m_souDM.EndOfQuery do
    begin
      Inc(curMoved);
      try
        m_destDM.BeginTrans;
        m_souDM.BeginTrans;
        if bBL then ExecTriggerSql(m_souDM.ADOExecute,m_TabMap.m_SqlBeforeLeft,0);
        if bBR then ExecTriggerSql(m_destDM.ADOExecute,m_TabMap.m_SqlBeforeRight,0);

        if m_TabMap.m_FieldCount >0 then
          ExeMoveData;

        if bAR then ExecTriggerSql(m_destDM.ADOExecute,m_TabMap.m_SqlAfterRight,0);
        if bAL then ExecTriggerSql(m_souDM.ADOExecute,m_TabMap.m_SqlAfterLeft,0);

        m_destDM.CommitTrans; //逐条Commit
        m_souDM.CommitTrans;
        Inc(nMoved);
      except
        on   e:exception   do
        begin
          Inc(nError);
          sLastErrorMsg := e.Message;
          m_souDM.RollbackTrans;
          m_destDM.RollbackTrans;
          WriteErrorLog(e);
          try
            //写入错误消息，这部分SQL不捕获异常，如果有异常系统直接抛出异常，所以要确保这部分代码正确
            if bLE then ExecTriggerSql(m_souDM.ADOExecute,m_TabMap.m_SqlErrorLeft,1);
            if bRE then ExecTriggerSql(m_destDM.ADOExecute,m_TabMap.m_SqlErrorRight,1);
            //m_destDM.CommitTrans; //逐条Commit
            //m_souDM.CommitTrans;
          except
            on   e:exception   do
            begin
              sLastErrorMsg := e.Message;
              TCommonFunc.WriteLogEx(m_sLogName,'记录错误信息失败 :'+e.Message,true,true);
            end;
          end;// end of inner try
        end;//end of except
      end; // end of try
      m_souDM.NextRecord;
    end; // end of while
    TCommonFunc.WriteLogEx(m_sLogName,'已导出'+IntToStr(nMoved+nError)+'条记录，成功导入'+
                             IntToStr(nMoved)+'条记录，失败'+IntToStr(nError)+'条记录。',true,true);
  until (not m_TabMap.m_RepeatRun) or (curMoved < preMoved) or (preSucceed = nMoved) ;

  dtEndMove := now;

  //处理迁移触发器
  if length(m_TabMap.m_SqlCompleteLeft) > 6 then
    try
      ExecTriggerSql(m_souDM.ADOExecute,m_TabMap.m_SqlCompleteLeft,2);
    except
      on   e:exception   do
        TCommonFunc.WriteLogEx(m_sLogName,'记录迁移后数据源（左）事件：'+m_TabMap.m_SqlCompleteLeft+#13#10'   错误为：'+e.Message,true,true);
    end;

  if length(m_TabMap.m_SqlCompleteRight) > 6 then
    try
      ExecTriggerSql(m_destDM.ADOExecute,m_TabMap.m_SqlCompleteRight,2);
    except
      on   e:exception   do
        TCommonFunc.WriteLogEx(m_sLogName,'记录迁移后数据目标（右）事件：'+m_TabMap.m_SqlCompleteRight+#13#10'   错误为：'+e.Message,true,true);
    end;

end;

//运行所有的对应关系迁移
procedure TRunDataMap.Run(const sPFP ,sLogPath: string);
var
  nMapCount,i : integer;
  sMapFile,sTemp,sNow : String;
  label endfunc;
begin
  m_sProjPath := sPFP;
  m_sWorkPath := ExtractFileDir(m_sProjPath);
  if (sLogPath<>'') and DirectoryExists(sLogPath) then
  begin
    m_sLogName := sLogPath + '\Export.Log';
    m_sErrorData := sLogPath ; 
  end else
  begin
    sNow := FormatDatetime('yyyy_mm_dd_hh_nn_ss',now);
    CreateDirectory(PChar(m_sWorkPath+'\Datas\'+sNow),nil);
    m_sLogName := m_sWorkPath+'\Datas\' + sNow + '\Export.Log';
    m_sErrorData := m_sWorkPath+'\Datas\' + sNow ;
  end;

  TfrDefDB.LoadDBConfig( m_sProjPath,'source',m_LeftDBCfg );
  TfrDefDB.LoadDBConfig( m_sProjPath,'destination',m_RightDBCfg );
  // 链接源数据库
  m_souDM.SetDBSetting(m_LeftDBCfg.m_sDBConn);
  m_LeftDBCfg.m_bCanConnected := m_souDM.ConnectDB;
  // 链接目标数据库
  m_destDM.SetDBSetting(m_RightDBCfg.m_sDBConn);
  m_RightDBCfg.m_bCanConnected := m_destDM.ConnectDB;

  if(not m_RightDBCfg.m_bCanConnected) or (not m_LeftDBCfg.m_bCanConnected) then
  begin
//class  procedure WriteLogEx(sLogName,s:String;bNewLine:boolean=false;bShowTime:boolean=false);
    if (not m_LeftDBCfg.m_bCanConnected) then
      TCommonFunc.WriteLogEx(m_sLogName,'连接数据库 '+m_LeftDBCfg.m_sDBConn +' 失败!' ,true,true);
    if (not m_RightDBCfg.m_bCanConnected) then
      TCommonFunc.WriteLogEx(m_sLogName,'连接数据库 '+m_RightDBCfg.m_sDBConn +' 失败!' ,true,true);

    writeln('数据库连接失败');
    goto endfunc;
  end else
    writeln('数据库连接成功');
  //正对SQL Server的特殊处理 sqlserver.Execute 'SET ARITHABORT ON'
  if m_LeftDBCfg.m_DBType = SQLServer then
    m_souDM.ExecSql('SET ARITHABORT ON' );
  if m_RightDBCfg.m_DBType = SQLServer then
    m_destDM.ExecSql('SET ARITHABORT ON' );

  nMapCount := TCommonFunc.GetProfileInt('main','mapcount',0,m_sProjPath);

  for i:= 0 to nMapCount-1 do
  begin
    sMapFile :=  m_sWorkPath+'\MapInfo\Map' + IntToStr(i) + '.cfg';
    sTemp := TCommonFunc.GetProfileValue('main','run','no',sMapFile);
    if sTemp = 'yes' then
       RunMap(sMapFile);
  end;

  TCommonFunc.WriteLogEx(m_sLogName,'数据迁移完成!' ,true,true);
endfunc:
  m_destDM.Disconnect;
  m_souDM.Disconnect;
end;

end.


