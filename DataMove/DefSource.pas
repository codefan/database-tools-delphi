unit DefSource;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,DefDB, StdCtrls, ExtCtrls;

type
  PFieldDesc = ^FieldDesc;
  FieldDesc = record
    m_ColName ,
    m_ColDesc ,
    m_ColType : String;
    m_IsNullable : boolean;
    m_DefaultValue : String;
    m_ColOrder : integer;
  end;
  FieldList = array of FieldDesc;

  PDataSource = ^DataSource;
  DataSource = record
    m_IsTable : boolean;
    m_SourceName : String;
    m_FieldCount : Integer;
    m_FieldList : FieldList;
    m_QuerySql : String;
    m_FromSql : String;
    m_sTableOpt,
    m_sRowOpt : String;
    m_sOptBefore,
    m_sOptAfter,
    m_sOptError,
    m_sOptComplete : String;
  end;

  TfrDefSource = class(TForm)
    edQuery: TMemo;
    plTop: TPanel;
    ledDBConn: TLabeledEdit;
    ledSourceName: TLabeledEdit;
    cbDateToChar: TCheckBox;
    rbtnQuery: TRadioButton;
    rbntTabOrderByName: TRadioButton;
    rbtnTable: TRadioButton;
    lbSourceDesc: TLabel;
    plBottom: TPanel;
    btnOK: TButton;
    cbSelectTab: TComboBox;
    btnRefreshTab: TButton;
    procedure rbtnTableClick(Sender: TObject);
    procedure rbtnQueryClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cbSelectTabSelect(Sender: TObject);
    procedure btnRefreshTabClick(Sender: TObject);
  private
    { Private declarations }
    m_bOnlyTable : boolean;
    procedure FOnlyAcceptTable(const bC : boolean);
  public
    { Public declarations }
    m_pDBCfg : PDBConfig;
    m_DataSource : DataSource;
    property OnlyAcceptTable :boolean write  FOnlyAcceptTable;
    class function GetSqlSelectSen(const sSql : string;var sFrom : String ;var sFields : FieldList) : integer;
  end;

var
  frDefSource: TfrDefSource;

implementation

uses CommonFunc,CommDBM;
{$R *.dfm}

procedure TfrDefSource.btnRefreshTabClick(Sender: TObject);
var
  sQueryTab : String;
  lTableName:TStrings;
  i: integer;
begin
  // 测试连接并例举所有系统表和视图
  case m_pDBCfg^.m_DBType of
  SQLServer:
    begin
      sQueryTab := 'SELECT name FROM  sysobjects WHERE xtype in (''U'',''V'') order by name';
    end;
  Oracle:
    begin
      sQueryTab := 'select tname from tab order by tname';
    end;
  DB2:
   begin
      sQueryTab := 'select name from sysibm.systables where CREATOR=USER order by name';
    end;
  end;
  cbSelectTab.Clear;
  self.Cursor := crSQLWait;

  CltDMConn.SetDBSetting(m_pDBCfg^.m_sDBConn);
  m_pDBCfg^.m_bCanConnected := CltDMConn.ConnectDB;

  if m_pDBCfg^.m_bCanConnected then
  begin
    cbSelectTab.AddItem('--请选择--',nil);
    if m_pDBCfg.m_DBType <> MSAccess then
    begin
      CltDMConn.QueryDB(sQueryTab);
      while not CltDMConn.EndOfQuery  do
      begin
        cbSelectTab.AddItem(CltDMConn.FieldAsString(0),nil);
        CltDMConn.NextRecord;
      end;
      CltDMConn.CloseQuery;
    end else
    begin
      lTableName:=TStringList.Create;
      CltDMConn.ADOConn.GetTableNames(lTableName,true);
      for i:=0 to lTableName.Count-1 do
      begin
        if (lTableName.Strings[i]<>'MSysACEs')
          and (lTableName.Strings[i]<>'MSysObjects')
          and (lTableName.Strings[i]<>'MSysQueries')
          and (lTableName.Strings[i]<>'MSysRelationships') then
        cbSelectTab.AddItem(lTableName.Strings[i],nil);
      end;
    end;
    CltDMConn.Disconnect;
  end else
    cbSelectTab.AddItem('不能连接到数据库',nil);
  cbSelectTab.ItemIndex := 0;

  self.Cursor := crDefault;
end;

procedure TfrDefSource.FormShow(Sender: TObject);
begin
  //SetLength(m_FieldList,0);
  m_DataSource.m_FieldCount := 0;
  ledDBConn.Text := m_pDBCfg^.m_sDBConn;
  if m_DataSource.m_IsTable then
    rbtnTable.Checked := true
  else
    rbtnQuery.Checked := true;
  //rbtnQuery.Checked := not m_DataSource.m_IsTable;
  ledSourceName.Text := m_DataSource.m_SourceName;
  edQuery.Text := m_DataSource.m_QuerySql;

  // 测试连接并例举所有系统表和视图
  if m_pDBCfg^.m_bCanConnected then
    btnRefreshTabClick(Sender)
  else
    cbSelectTab.AddItem('不能连接到数据库',nil);
end;

procedure TfrDefSource.FOnlyAcceptTable(const bC : boolean);
begin
  m_bOnlyTable := bC;
  if bC then
  begin
    rbtnTable.Checked := true;
    rbtnQuery.Enabled := false;
    edQuery.ReadOnly := true;
    edQuery.Color := clInfoBK;
  end else
  begin
    rbtnQuery.Enabled := true;
    edQuery.ReadOnly := false;
    edQuery.Color := clWindow;
  end;
end;

procedure TfrDefSource.rbtnTableClick(Sender: TObject);
begin
  edQuery.Enabled := false;
end;

procedure TfrDefSource.rbtnQueryClick(Sender: TObject);
begin
  edQuery.Enabled := true;
end;

procedure TfrDefSource.btnOKClick(Sender: TObject);
var
  sTestSql,sQueryCol,sColDesc,sColType,sFromSql : String;
  bRes ,getColumn: boolean;
  i, nFC : integer;

  function GetTestSql : String;
  var
    sResSql,sTempSql: String;
  begin
    sResSql := m_DataSource.m_QuerySql;

    if m_DataSource.m_IsTable then
    begin
      case m_pDBCfg^.m_DBType of
        SQLServer:
        begin
          sResSql := 'select top 1 * from '+m_DataSource.m_SourceName;
        end;
        Oracle:
        begin
          sResSql := 'select * from '+m_DataSource.m_SourceName+' where rownum<1';
        end;
        DB2:
        begin
          sResSql := 'select * from '+m_DataSource.m_SourceName+' fetch first 1 row only';
        end;
        MSAccess:
        begin
          sResSql := 'select top 1 * from '+m_DataSource.m_SourceName;
        end;
      end;
    end else
    begin
      case m_pDBCfg^.m_DBType of
        SQLServer:
        begin
          sTempSql := trim(m_DataSource.m_QuerySql);
          sResSql := 'select top 1 a.* from ('+sTempSql+') a';
        end;
        Oracle:
        begin
          sResSql := 'select a.* from ('+m_DataSource.m_QuerySql+') a where rownum<1';
        end;
        DB2:
        begin
          sResSql := 'select a.* from ('+m_DataSource.m_QuerySql+') a fetch first 1 row only';
        end;
        MSAccess:
        begin
          sTempSql := trim(m_DataSource.m_QuerySql);
          sResSql := 'select top 1 a.* from ('+sTempSql+') a';
        end;
      end;
    end;
    result := sResSql;
  end;

  function GetTableName(sTableName:String):String;
  var
    i,nL : integer;
  begin
    nL := length(sTableName);
    result:='';
    for i:=1 to nL do
      if sTableName[i] = '.' then
        result:=''
      else
        result:= result+sTableName[i];
  end;
begin
  m_DataSource.m_IsTable := rbtnTable.Checked or rbntTabOrderByName.Checked;
  m_DataSource.m_SourceName := Trim( ledSourceName.Text);
  m_DataSource.m_QuerySql := StringReplace( StringReplace(edQuery.Text,#13,' ',[rfReplaceAll]),#10,' ',[rfReplaceAll]);
  if m_DataSource.m_SourceName = '' then
  begin
    ShowMessage('请输入数据源名称!');
    Exit;
  end;
  // 测试语句
  // 数据库测试 ——可以连接时
  self.Cursor := crSQLWait;

  if m_pDBCfg^.m_bCanConnected then
  begin
    CltDMConn.SetDBSetting(m_pDBCfg^.m_sDBConn);
    m_pDBCfg^.m_bCanConnected := CltDMConn.ConnectDB;

    bRes := false;
    nFC := 0;

    getColumn := false;
    if m_pDBCfg^.m_bCanConnected then
    begin

      if m_DataSource.m_IsTable then
      begin
        m_DataSource.m_QuerySql := 'select * from '+m_DataSource.m_SourceName;
        m_DataSource.m_FromSql := 'from ' + m_DataSource.m_SourceName;
      end;

      if (m_pDBCfg^.m_DBType<> MSAccess) and m_DataSource.m_IsTable then
      begin
        case m_pDBCfg^.m_DBType of
        SQLServer:
          begin
            sQueryCol := 'SELECT  a.name, c.name AS typename,a.length,a.xprec,a.xscale,'+
                              'case a.isnullable when 1 then ''Y'' else ''N'' end as NULLABLE,a.colorder '+
                         'FROM  syscolumns a INNER JOIN '+
                                'sysobjects b ON a.id = b.id INNER JOIN '+
                                'systypes c ON a.xtype = c.xtype '+
                          'WHERE (b.xtype in (''U'',''V'')) and c.name <>''SYSNAME'' and upper(b.name)='+
                            QuotedStr( UpperCase(GetTableName(m_DataSource.m_SourceName)) ) ;
            if rbntTabOrderByName.Checked then
              sQueryCol := sQueryCol+ ' order by a.name'
            else
              sQueryCol := sQueryCol+ ' order by a.colid';
          end;
        Oracle:
          begin
            sQueryCol := 'select COLUMN_NAME,DATA_TYPE,DATA_LENGTH,NVL(DATA_PRECISION,DATA_LENGTH),DATA_SCALE,NULLABLE,DATA_DEFAULT '+
                  'from USER_TAB_COLUMNS where TABLE_NAME='+QuotedStr(UpperCase(m_DataSource.m_SourceName)) ;
                  //' and owner='+QuotedStr(UpperCase(m_pDBCfg^.m_sUserName)) +
            if rbntTabOrderByName.Checked then
              sQueryCol := sQueryCol+ ' order by COLUMN_NAME'
            else
              sQueryCol := sQueryCol+ ' order by column_id';
          end;
        DB2:
         begin
            sQueryCol := 'select a.name,a.coltype,a.length, a.length as precision ,a.scale,a.nulls as NULLABLE '+
                  'from sysibm.systables b , sysibm.syscolumns a '+
                  'where b.name=a.tbname and b.creator=a.tbcreator and '+
                    'a.tbname= '+QuotedStr(UpperCase(m_DataSource.m_SourceName)) ;
                  //' and a.tbcreator='+QuotedStr(UpperCase(m_pDBCfg^.m_sUserName)) +
            if rbntTabOrderByName.Checked then
              sQueryCol := sQueryCol+ ' order by a.name'
            else
              sQueryCol := sQueryCol+ ' order by a.COLNO';
          end;
        end;

        bRes := CltDMConn.QueryDB(sQueryCol);
        if bRes then
        begin
          SetLength(m_DataSource.m_FieldList,CltDMConn.ReordCount+1);
          sTestSql := 'select ';
          while not CltDMConn.EndOfQuery  do
          begin

            sColDesc := CltDMConn.FieldAsString(0);
            sColType := UpperCase(CltDMConn.FieldAsString(1));

            m_DataSource.m_FieldList[nFC].m_ColName := sColDesc;

            if cbDateToChar.Checked and (
                (sColType='DATE') or (sColType='TIME') or (sColType='DATETIME') or (sColType='TIMESTAMP') ) then
            begin
              case m_pDBCfg^.m_DBType of
              SQLServer:
                begin
                  sColDesc := 'convert(varchar(20),'+sColDesc+',20) as '+ sColDesc;
                  m_DataSource.m_FieldList[nFC].m_ColOrder := CltDMConn.FieldAsInt('colorder') ;
                end;
              Oracle:
                sColDesc := 'to_char('+sColDesc+',''YYYY-MM-DD HH24:MI:SS'') as '+ sColDesc;
              DB2:
                sColDesc := 'to_char('+sColDesc+',''YYYY-MM-DD HH24:MI:SS'') as '+ sColDesc;
              end;
            end;

            if (not m_bOnlyTable) and (m_pDBCfg.m_DBType = Oracle) and (sColType='CLOB') then
            begin
              sColType := 'BLOB';
              sColDesc := 'CENTIT_LOB.ClobToBlob('+sColDesc+') as '+ sColDesc;
            end;

            m_DataSource.m_FieldList[nFC].m_ColDesc := sColDesc;
            m_DataSource.m_FieldList[nFC].m_ColType :=
               TCommDB.GetTypeDesc(sColType,
                           CltDMConn.FieldAsInt(2),
                           CltDMConn.FieldAsInt(3),
                           CltDMConn.FieldAsInt(4));
            m_DataSource.m_FieldList[nFC].m_IsNullable := CltDMConn.FieldAsString('NULLABLE')='Y';
            m_DataSource.m_FieldList[nFC].m_ColOrder := nFC+1;

            if nFC = 0 then
              sTestSql := sTestSql+sColDesc
            else
              sTestSql := sTestSql+', '+sColDesc;

            CltDMConn.NextRecord;
            Inc(nFC);
          end; //end while
          m_DataSource.m_QuerySql := sTestSql+' from '+m_DataSource.m_SourceName;
          m_DataSource.m_FromSql := 'from ' + m_DataSource.m_SourceName;
          CltDMConn.CloseQuery;
          getColumn := nFC > 0;
        end;  // connect success
        
        m_DataSource.m_FieldCount := nFC;
      end;// of m_DataSource.m_IsTable

      if not getColumn then
      begin
        nFC := GetSqlSelectSen(m_DataSource.m_QuerySql, sFromSql ,m_DataSource.m_FieldList);
        if nFC>0 then
           m_DataSource.m_FromSql := sFromSql;

        sTestSql := GetTestSql;
        bRes := CltDMConn.QueryDB(sTestSql);
        if bRes then
        begin
          if (m_pDBCfg^.m_DBType<> MSAccess) and (nFC <> -1) and (nFC <> CltDMConn.FieldCount) then
          begin
            ShowMessage('解释语句出错，请和codefan@sina.com联系，并附上你输入的SQL语句！');
            SetLength(m_DataSource.m_FieldList,CltDMConn.FieldCount+1);
          end;
          nFC := CltDMConn.FieldCount;
          SetLength(m_DataSource.m_FieldList,nFC+1);
          sTestSql := 'select ';
          for i:=0 to nFC-1 do
          begin
            m_DataSource.m_FieldList[i].m_ColName := CltDMConn.FieldName(i);
            m_DataSource.m_FieldList[i].m_ColType := CltDMConn.FieldTypeDesc(i);//CltDMConn.FieldType(i));
            m_DataSource.m_FieldList[i].m_ColDesc := CltDMConn.FieldName(i);
            m_DataSource.m_FieldList[i].m_IsNullable := FALSE;
            m_DataSource.m_FieldList[i].m_ColOrder := i+1;

            if i = 0 then
              sTestSql := sTestSql+ CltDMConn.FieldName(i)
            else
              sTestSql := sTestSql+','+CltDMConn.FieldName(i);

          end;
          CltDMConn.CloseQuery;
          m_DataSource.m_FieldCount := nFC;
        end;
        if ( (m_pDBCfg^.m_DBType = MSAccess)  and m_DataSource.m_IsTable ) or (nFC < 0) then
        begin
          m_DataSource.m_QuerySql := sTestSql +' '+ m_DataSource.m_FromSql;
          if m_pDBCfg^.m_DBType = MSAccess then
             m_DataSource.m_IsTable := false;
        end;
      end;
      CltDMConn.Disconnect;
    end;
    self.Cursor := crDefault;
    if (not bRes) or (nFC = 0) then
    begin
      ShowMessage('查询语句格式不正确！');
      Exit;
    end;

    edQuery.Text :=  m_DataSource.m_QuerySql;
  end else
  begin
    if not m_DataSource.m_IsTable then
    begin
      //sStrs := TStringList.Create;
      nFC := GetSqlSelectSen(m_DataSource.m_QuerySql,sFromSql,m_DataSource.m_FieldList);
      m_DataSource.m_FromSql := sFromSql;
      self.Cursor := crDefault;
      if nFC < 0 then
      begin
        ShowMessage('查询语句格式不正确！');
        Exit;
      end;
      m_DataSource.m_FieldCount := nFC;
    end;
  end;
  // 手动测试   ——不可以连接时
  self.Cursor := crDefault;
  self.ModalResult := mrOK;
end;

//简单的 select 部分分割，对语法的检查很弱，
//如果要严格的检查语法请连接数据库
class function TfrDefSource.GetSqlSelectSen(const sSql : string;var sFrom : String ; var sFields : FieldList) : integer;
var
  i,nPos,nStr,nLeftBracket:Integer;
  nFieldBegin,nFieldEnd : integer;
  sTemp,sWord,sField : String;
  sStrs,sFieldDescs : TStrings;
begin
  sTemp := sSql;
  nPos := 1;
  sStrs := TStringList.Create;
  sFieldDescs := TStringList.Create;
  result := -1;
  nStr := 0;
  sWord := TCommonFunc.GetAWord(sSql,nPos,false,false);
  nLeftBracket := 0;
  if (CompareText (sWord,'select') <> 0) then Exit;

  nFieldBegin := nPos;
  sWord := TCommonFunc.GetAWord(sSql,nPos,false,false);
  while (sWord <> '') and (LowerCase(sWord) <> 'from') do
  begin
    sField := sWord;
    nFieldEnd := nPos;

    if( sWord = '(') then Inc(nLeftBracket)
    else if( sWord = ')') then Dec(nLeftBracket);

    sWord := TCommonFunc.GetAWord(sSql,nPos,false,false);
    while ( (nLeftBracket >0 ) or ( (sWord<>',') and (CompareText(LowerCase(sWord),'from')<>0) ) ) and (sWord <> '') do
    begin
      if (nLeftBracket = 0) and (CompareText(LowerCase(sWord),'end')<>0) then
      // 这个太复杂不能追求太完美，解决办法是联机操作
        sField := sWord
      else
        sField := sField + ' '+ sWord;

      nFieldEnd := nPos;
      if( sWord = '(') then Inc(nLeftBracket)
      else if( sWord = ')') then Dec(nLeftBracket);
      if nLeftBracket < 0
        then Exit;
      sWord := TCommonFunc.GetAWord(sSql,nPos,false,false);
    end;


    sStrs.Add(sField);
    sFieldDescs.Add(Trim( Copy(sSql,nFieldBegin,nFieldEnd-nFieldBegin)));
    Inc(nStr);

    nFieldBegin := nPos;
    if (sWord=',') then
      sWord := TCommonFunc.GetAWord(sSql,nPos,false,false);
  end;

  sFrom := 'from '+ Trim(Copy(sSql,nPos,length(sSql)+1-nPos));

  SetLength(sFields,nStr+1);
  for i:=0 to nStr-1 do
  begin
    sFields[i].m_ColName := sStrs[i];
    sFields[i].m_ColDesc := sFieldDescs[i];
    sFields[i].m_ColType :='';
    sFields[i].m_IsNullable := false;
    sFields[i].m_DefaultValue :='';
    sFields[i].m_ColOrder := i+1;
  end;

  if LowerCase(sWord) <> 'from' then
    nStr := 0;

  if nLeftBracket <> 0 then
    Exit;
  result := nStr;

end;

procedure TfrDefSource.cbSelectTabSelect(Sender: TObject);
begin
  //录入表名
  if cbSelectTab.ItemIndex>0 then
  begin
    ledSourceName.Text := cbSelectTab.Text;
    rbtnTable.Checked := true;
  end;
end;


end.
