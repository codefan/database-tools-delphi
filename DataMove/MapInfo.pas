unit MapInfo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, Buttons, ExtCtrls,DefDB,DefSource;
const
  TableOptEnum :Array[0..2] of String=('none','create','replace');
  RowOptEnum :Array[0..2] of String=('insert','update','merge');
type
  TfrMapInfo = class(TForm)
    pgMain: TPageControl;
    tsMapInfo: TTabSheet;
    panelTop: TPanel;
    btnDefSource: TBitBtn;
    ledDestination: TLabeledEdit;
    btnDefDestination: TBitBtn;
    tsScript: TTabSheet;
    edLeftScript: TMemo;
    edRightScript: TMemo;
    panelScriptTop: TPanel;
    lbLeftScript: TLabel;
    ledSource: TLabeledEdit;
    lbRightScript: TLabel;
    tableOpt: TRadioGroup;
    rowOpt: TRadioGroup;
    pcMapInfo: TPageControl;
    TabSheet1: TTabSheet;
    tsPretreatment: TTabSheet;
    lvMapInfo: TListView;
    optHint: TMemo;
    ledBeforeOptLeft: TLabeledEdit;
    ledBeforeOptRight: TLabeledEdit;
    ledAfterOptRight: TLabeledEdit;
    ledAfterOptLeft: TLabeledEdit;
    panelBottom: TPanel;
    btnSetFieldInfo: TBitBtn;
    btnSouTop: TBitBtn;
    cbRepeatRun: TCheckBox;
    btnSouUp: TBitBtn;
    btnSouDown: TBitBtn;
    btnSouBottom: TBitBtn;
    btnSouDelete: TBitBtn;
    btnDesTop: TBitBtn;
    btnDesUp: TBitBtn;
    btnDesDown: TBitBtn;
    btnDesBottom: TBitBtn;
    btnDesDelete: TBitBtn;
    ledErrorRight: TLabeledEdit;
    ledErrorLeft: TLabeledEdit;
    plOK: TPanel;
    btnCancel: TBitBtn;
    btnOK: TBitBtn;
    optCompleteHint: TMemo;
    ledTransCompleteLeft: TLabeledEdit;
    ledTransCompleteRight: TLabeledEdit;
    btnCheckSetting: TBitBtn;
    cbAutoCheck: TCheckBox;
    btnAddDestField: TBitBtn;
    procedure btnDefSourceClick(Sender: TObject);
    procedure btnDefDestinationClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnSouTopClick(Sender: TObject);
    procedure btnSetFieldInfoClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure pgMainChange(Sender: TObject);
    procedure ledDestNoKeyPress(Sender: TObject; var Key: Char);
    procedure lvMapInfoSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure btnSouUpClick(Sender: TObject);
    procedure btnSouDownClick(Sender: TObject);
    procedure btnSouBottomClick(Sender: TObject);
    procedure btnSouDeleteClick(Sender: TObject);
    procedure btnDesTopClick(Sender: TObject);
    procedure btnDesUpClick(Sender: TObject);
    procedure btnDesDownClick(Sender: TObject);
    procedure btnDesBottomClick(Sender: TObject);
    procedure btnDesDeleteClick(Sender: TObject);
    procedure btnCheckSettingClick(Sender: TObject);
    procedure btnAddDestFieldClick(Sender: TObject);
  private
    { Private declarations }
    m_sWorkPath,m_sMapFile,m_sMapName: String;
    procedure DeleteSouField(nInd :integer);
    procedure DeleteDestField(nInd :integer);
    function CheckFieldType : String;
    function CheckSql : String;
    procedure MakeSourceSql;
    procedure MakeDestSql;
    function GetLastSou:integer;
    function GetLastDest:integer;
    procedure ChangeSouField(const nInd : integer; const nD : integer);
    procedure ChangeDesField(const nInd : integer; const nD : integer);
    procedure MakeScript;overload;
  public
    { Public declarations }
    m_LeftDef,m_RightDef : DataSource;
    m_pLeftDBCfg,
    m_pRightDBCfg : PDBConfig;

    procedure SetMapInfo(const sWorkPath,sMapName:string);
    procedure LoadMapinfo(const sFilePath:string);overload;
    function SaveMapinfo(const sFilePath:string):boolean;
    class procedure LoadMapinfo(const sFilePath:string;pLeftDef,pRightDef :PDataSource);overload;
    class procedure MakeScript(sWorkPath,sMapName:string; pLeftDB,pRightDB: PDBConfig;
                var sExport,sImport:String);overload;

  end;

var
  frMapInfo: TfrMapInfo;

implementation

uses CommonFunc,StrUtils,CommDBM,DefField;
{$R *.dfm}

procedure TfrMapInfo.FormShow(Sender: TObject);
begin
  lvMapInfo.Items.Clear;
  //如果是编辑对应信息则需要读取相关信息
  LoadMapinfo(m_sMapFile);
  pgMain.ActivePageIndex := 0;
  pcMapInfo.ActivePageIndex := 0;
end;

procedure TfrMapInfo.LoadMapinfo(const sFilePath:string);
var
  i,nC : integer;
  sTemp : String;
  newItem : TListItem;
begin
  LoadMapinfo(sFilePath, @m_LeftDef, @m_RightDef);



  ledSource.Text := m_LeftDef.m_SourceName;
  ledDestination.Text := m_RightDef.m_SourceName;

  for i:=0 to 2 do
    if m_RightDef.m_sTableOpt = TableOptEnum[i] then
      tableOpt.ItemIndex :=i;
  for i:=0 to 2 do
    if m_RightDef.m_sRowOpt = RowOptEnum[i] then
      rowOpt.ItemIndex :=i;

  cbRepeatRun.Checked := TCommonFunc.GetProfileValue('source','repeat','no',sFilePath) = 'yes';
  ledBeforeOptLeft.Text := m_LeftDef.m_sOptBefore;
  ledBeforeOptRight.Text := m_RightDef.m_sOptBefore;
  ledAfterOptRight.Text := m_RightDef.m_sOptAfter;
  ledAfterOptLeft.Text := m_LeftDef.m_sOptAfter;
  ledErrorRight.Text := m_RightDef.m_sOptError;
  ledErrorLeft.Text := m_LeftDef.m_sOptError;
  ledTransCompleteLeft.Text := m_LeftDef.m_sOptComplete;
  ledTransCompleteRight.Text := m_RightDef.m_sOptComplete;

  // mapinfo
  sTemp := TCommonFunc.GetProfileValue('mapinfo','column_count','0',sFilePath);
  try
    nC := StrToInt(sTemp);
  except
    nC := 0;
  end;

  for i:=0 to nC-1 do
  begin
    newItem := lvMapInfo.Items.Add;
    newItem.Caption := IntToStr(i+1);
    newItem.SubItems.Add(TCommonFunc.GetProfileValue('mapinfo','col'+IntToStr(i+1)+'_l','',sFilePath));
    newItem.SubItems.Add(TCommonFunc.GetProfileValue('mapinfo','col'+IntToStr(i+1)+'_l_type','',sFilePath));
    newItem.SubItems.Add(TCommonFunc.GetProfileValue('mapinfo','col'+IntToStr(i+1)+'_r','',sFilePath));
    newItem.SubItems.Add(TCommonFunc.GetProfileValue('mapinfo','col'+IntToStr(i+1)+'_r_type','',sFilePath));
    newItem.SubItems.Add(TCommonFunc.GetProfileValue('mapinfo','col'+IntToStr(i+1)+'_r_nullable','Y',sFilePath));
    newItem.SubItems.Add(TCommonFunc.GetProfileValue('mapinfo','col'+IntToStr(i+1)+'_r_default','',sFilePath));
    newItem.SubItems.Add(TCommonFunc.GetProfileValue('mapinfo','col'+IntToStr(i+1)+'_r_order','',sFilePath));
    newItem.SubItems.Add(TCommonFunc.GetProfileValue('mapinfo','col'+IntToStr(i+1)+'_l_desc','',sFilePath));

    sTemp := TCommonFunc.GetProfileValue('mapinfo','col'+IntToStr(i+1)+'_r_key','N',sFilePath);
    newItem.Checked := sTemp='Y';
  end;

  MakeSourceSql;
  MakeDestSql;
end;

class procedure TfrMapInfo.LoadMapinfo(const sFilePath:string;pLeftDef,pRightDef :PDataSource);
var
  sTemp : String;
begin
  // load source
  sTemp := TCommonFunc.GetProfileValue('source','type','query_sql',sFilePath);
  pLeftDef^.m_IsTable := sTemp = 'table';
  pLeftDef^.m_SourceName := TCommonFunc.GetProfileValue('source','source_name','',sFilePath);
  pLeftDef^.m_QuerySql := TCommonFunc.GetProfileValue('source','query_sql','',sFilePath);
  pLeftDef^.m_sOptBefore := TCommonFunc.GetProfileValue('source','before_sql','',sFilePath);
  pLeftDef^.m_sOptAfter := TCommonFunc.GetProfileValue('source','after_sql','',sFilePath);
  pLeftDef^.m_sOptError := TCommonFunc.GetProfileValue('source','error_sql','',sFilePath);
  pLeftDef^.m_sOptComplete := TCommonFunc.GetProfileValue('source','complete_sql','',sFilePath);

  pLeftDef^.m_FromSql := TCommonFunc.GetProfileValue('source','from_sql','',sFilePath);
  // load destination
  sTemp := TCommonFunc.GetProfileValue('destination','type','query_sql',sFilePath);
  pRightDef^.m_IsTable := sTemp = 'table';

  pRightDef^.m_SourceName := TCommonFunc.GetProfileValue('destination','source_name','',sFilePath);
  pRightDef^.m_QuerySql := TCommonFunc.GetProfileValue('destination','query_sql','',sFilePath);
  pRightDef^.m_sOptBefore := TCommonFunc.GetProfileValue('destination','before_sql','',sFilePath);
  pRightDef^.m_sOptAfter := TCommonFunc.GetProfileValue('destination','after_sql','',sFilePath);
  pRightDef^.m_sOptError := TCommonFunc.GetProfileValue('destination','error_sql','',sFilePath);
  pRightDef^.m_sOptComplete := TCommonFunc.GetProfileValue('destination','complete_sql','',sFilePath);
  pRightDef^.m_FromSql := TCommonFunc.GetProfileValue('destination','from_sql','',sFilePath);

  sTemp := TCommonFunc.GetProfileValue('destination','table_opt','none',sFilePath);  // table Opt Row Opt
  pRightDef^.m_sTableOpt := sTemp;//='yes';
  sTemp := TCommonFunc.GetProfileValue('destination','row_opt','insert',sFilePath);
  pRightDef^.m_sRowOpt := sTemp;//='yes';

end;


procedure TfrMapInfo.SetMapInfo(const sWorkPath,sMapName:string);
begin
  m_sMapFile := sWorkPath + '\MapInfo\'+sMapName+'.cfg';
  m_sWorkPath := sWorkPath;
  m_sMapName := sMapName;
  LoadMapinfo(m_sMapFile);
end;

function TfrMapInfo.SaveMapinfo(const sFilePath:string):boolean;
var
  i,nC,nVC,nKeyC : integer;
begin
  //在触发语句中的变量对应的左边的字段一定要是一个合法的字符串，否则无法运行
  //此处可以检查语句合法型，并检查参数是否匹配，但这个难度较大且没有太大必要

  m_LeftDef.m_sOptBefore := ledBeforeOptLeft.Text;
  m_RightDef.m_sOptBefore := ledBeforeOptRight.Text;
  m_RightDef.m_sOptAfter := ledAfterOptRight.Text;
  m_LeftDef.m_sOptAfter := ledAfterOptLeft.Text;
  m_RightDef.m_sOptError := ledErrorRight.Text;
  m_LeftDef.m_sOptError := ledErrorLeft.Text;
  m_LeftDef.m_sOptComplete := ledTransCompleteLeft.Text;
  m_RightDef.m_sOptComplete := ledTransCompleteRight.Text;

  // save source
  if m_LeftDef.m_IsTable then
    TCommonFunc.SetProfileValue('source','type','table',sFilePath)
  else
    TCommonFunc.SetProfileValue('source','type','query_sql',sFilePath);

  TCommonFunc.SetProfileValue('source','source_name',m_LeftDef.m_SourceName,sFilePath);
  TCommonFunc.SetProfileValue('source','query_sql',m_LeftDef.m_QuerySql,sFilePath);
  TCommonFunc.SetProfileValue('source','before_sql',m_LeftDef.m_sOptBefore,sFilePath);
  TCommonFunc.SetProfileValue('source','after_sql',m_LeftDef.m_sOptAfter,sFilePath);
  TCommonFunc.SetProfileValue('source','error_sql',m_LeftDef.m_sOptError,sFilePath);
  TCommonFunc.SetProfileValue('source','complete_sql',m_LeftDef.m_sOptComplete,sFilePath);

  TCommonFunc.SetProfileValue('source','from_sql',m_LeftDef.m_FromSql,sFilePath);
  if cbRepeatRun.Checked then
    TCommonFunc.SetProfileValue('source','repeat','yes',sFilePath)
  else
    TCommonFunc.SetProfileValue('source','repeat','no',sFilePath);

  // save destination
  if m_RightDef.m_IsTable then
    TCommonFunc.SetProfileValue('destination','type','table',sFilePath)
  else
    TCommonFunc.SetProfileValue('destination','type','query_sql',sFilePath);

  TCommonFunc.SetProfileValue('destination','source_name',m_RightDef.m_SourceName,sFilePath);
  TCommonFunc.SetProfileValue('destination','query_sql',m_RightDef.m_QuerySql,sFilePath);
  TCommonFunc.SetProfileValue('destination','before_sql',m_RightDef.m_sOptBefore,sFilePath);
  TCommonFunc.SetProfileValue('destination','after_sql',m_RightDef.m_sOptAfter,sFilePath);
  TCommonFunc.SetProfileValue('destination','error_sql',m_RightDef.m_sOptError,sFilePath);
  TCommonFunc.SetProfileValue('destination','complete_sql',m_RightDef.m_sOptComplete,sFilePath);
  TCommonFunc.SetProfileValue('destination','from_sql',m_RightDef.m_FromSql,sFilePath);
  ///TCommonFunc.SetProfileValue('destination','insert_sql',m_RightDef.m_QuerySql,sFilePath);

  m_RightDef.m_sTableOpt := TableOptEnum[tableOpt.ItemIndex];// cbtnCreateTable.Checked;    // table Opt Row Opt
  TCommonFunc.SetProfileValue('destination','table_opt',m_RightDef.m_sTableOpt,sFilePath);
  m_RightDef.m_sRowOpt := RowOptEnum[rowOpt.ItemIndex];
  TCommonFunc.SetProfileValue('destination','row_opt',m_RightDef.m_sRowOpt,sFilePath);

  // mapinfo
  //nC := lvMapInfo.Items.Count;

  nC := lvMapInfo.Items.Count;
  TCommonFunc.SetProfileValue('mapinfo','column_count',IntToStr(nC),sFilePath);
  nVC := 0;
  nKeyC := 0;
  for i:=0 to nC-1 do
  begin
    TCommonFunc.SetProfileValue('mapinfo','col'+IntToStr(i+1)+'_l',lvMapInfo.Items[i].SubItems[0],sFilePath);
    TCommonFunc.SetProfileValue('mapinfo','col'+IntToStr(i+1)+'_l_desc',lvMapInfo.Items[i].SubItems[7],sFilePath);
    TCommonFunc.SetProfileValue('mapinfo','col'+IntToStr(i+1)+'_l_type',lvMapInfo.Items[i].SubItems[1],sFilePath);
    TCommonFunc.SetProfileValue('mapinfo','col'+IntToStr(i+1)+'_r',lvMapInfo.Items[i].SubItems[2],sFilePath);
    TCommonFunc.SetProfileValue('mapinfo','col'+IntToStr(i+1)+'_r_type',lvMapInfo.Items[i].SubItems[3],sFilePath);
    TCommonFunc.SetProfileValue('mapinfo','col'+IntToStr(i+1)+'_r_nullable',lvMapInfo.Items[i].SubItems[4],sFilePath);
    TCommonFunc.SetProfileValue('mapinfo','col'+IntToStr(i+1)+'_r_default',lvMapInfo.Items[i].SubItems[5],sFilePath);
    TCommonFunc.SetProfileValue('mapinfo','col'+IntToStr(i+1)+'_r_order',lvMapInfo.Items[i].SubItems[6],sFilePath);
    if lvMapInfo.Items[i].Checked then
    begin
      TCommonFunc.SetProfileValue('mapinfo','col'+IntToStr(i+1)+'_r_key','Y',sFilePath);
      Inc(nKeyC);
    end else
      TCommonFunc.SetProfileValue('mapinfo','col'+IntToStr(i+1)+'_r_key','N',sFilePath);

    if (lvMapInfo.Items[i].SubItems[0] <> '') and  (lvMapInfo.Items[i].SubItems[2] <> '') then
      Inc(nVC)
  end;
  
  TCommonFunc.SetProfileValue('mapinfo','valid_column_count',IntToStr(nVC),sFilePath);
  TCommonFunc.SetProfileValue('mapinfo','left_column_count',IntToStr(GetLastSou+1),sFilePath);
  TCommonFunc.SetProfileValue('mapinfo','right_column_count',IntToStr(GetLastDest+1),sFilePath);
  // script
  if (rowOpt.ItemIndex>0) and (nKeyC<1) then
  begin
    ShowMessage('更新或者合并操作必需设定目标表的主键；'#13#10'请点击list中的checkbox来设定目标表的主键。');
    result := false;
  end else
    result := true;
end;

procedure TfrMapInfo.btnDefSourceClick(Sender: TObject);
var
  i,nFC,nC : integer;
  newItem : TListItem;
begin
  frDefSource.m_pDBCfg := m_pLeftDBCfg;
  frDefSource.m_DataSource := m_LeftDef;
  frDefSource.OnlyAcceptTable := false;
  if frDefSource.ShowModal = mrOK then
  begin
    //lvMapInfo.Items.Clear;
    m_LeftDef := frDefSource.m_DataSource;
    ledSource.Text := m_LeftDef.m_SourceName;

    nFC := m_LeftDef.m_FieldCount;
    //nTC := frDefSource.m_FieldTypeList.Count;

    nC := lvMapInfo.Items.Count;
    i := 0;
    while (i<nFC) and (i<nC) do
    begin
      lvMapInfo.Items[i].SubItems[0] := m_LeftDef.m_FieldList[i].m_ColName;
      lvMapInfo.Items[i].SubItems[1] := m_LeftDef.m_FieldList[i].m_ColType;
      lvMapInfo.Items[i].SubItems[7] := m_LeftDef.m_FieldList[i].m_ColDesc;
      Inc(i);
    end;

    while (i<nFC) do
    begin
      newItem := lvMapInfo.Items.Add;
      newItem.Caption := IntToStr(i+1);
      newItem.SubItems.Add(m_LeftDef.m_FieldList[i].m_ColName);
      newItem.SubItems.Add(m_LeftDef.m_FieldList[i].m_ColType);

      newItem.SubItems.Add('');
      newItem.SubItems.Add('');
      newItem.SubItems.Add('');
      newItem.SubItems.Add('');
      newItem.SubItems.Add('');
      newItem.SubItems.Add(m_LeftDef.m_FieldList[i].m_ColDesc);
      Inc(i);
    end;

    while (i<nC) do
    begin
      Dec(nC);
      if lvMapInfo.Items[nC].SubItems[2] = '' then
        lvMapInfo.Items.Delete(nC)
      else
      begin
        lvMapInfo.Items[i].SubItems[0] := '';
        lvMapInfo.Items[i].SubItems[1] := '';
        lvMapInfo.Items[i].SubItems[7] := '';
      end;
    end;

  end;
end;

procedure TfrMapInfo.btnDefDestinationClick(Sender: TObject);
var
  i,nFC,nC : integer;
  newItem : TListItem;
begin
  if m_RightDef.m_QuerySql = '' then
    m_RightDef.m_IsTable := true;
    
  frDefSource.m_pDBCfg := m_pRightDBCfg;
  frDefSource.m_DataSource := m_RightDef;

  frDefSource.OnlyAcceptTable := true;
  if frDefSource.ShowModal = mrOK then
  begin
    m_RightDef := frDefSource.m_DataSource;
    ledDestination.Text := m_RightDef.m_SourceName;

    nFC := m_RightDef.m_FieldCount;
    nC := lvMapInfo.Items.Count;
    i := 0;
    while (i<nFC) and (i<nC) do
    begin
      lvMapInfo.Items[i].SubItems[2] := m_RightDef.m_FieldList[i].m_ColName;
      lvMapInfo.Items[i].SubItems[3] := m_RightDef.m_FieldList[i].m_ColType;

      if m_RightDef.m_FieldList[i].m_IsNullable then
        lvMapInfo.Items[i].SubItems[4] := 'Y'
      else
        lvMapInfo.Items[i].SubItems[4] := 'N';
      lvMapInfo.Items[i].SubItems[5] := '';
      lvMapInfo.Items[i].SubItems[6] :=IntToStr(m_RightDef.m_FieldList[i].m_ColOrder);

      Inc(i);
    end;

    while (i<nFC) do
    begin
      newItem := lvMapInfo.Items.Add;
      newItem.Caption := IntToStr(i+1);

      newItem.SubItems.Add('');
      newItem.SubItems.Add('');

      newItem.SubItems.Add(m_RightDef.m_FieldList[i].m_ColName);
      newItem.SubItems.Add(m_RightDef.m_FieldList[i].m_ColType);

      if m_RightDef.m_FieldList[i].m_IsNullable then
        newItem.SubItems.Add('Y')
      else
        newItem.SubItems.Add('N');
      newItem.SubItems.Add('');
      newItem.SubItems.Add( IntToStr( m_RightDef.m_FieldList[i].m_ColOrder) );
      newItem.SubItems.Add('');
      Inc(i);
    end;

    while (i<nC) do
    begin
      Dec(nC);
      if lvMapInfo.Items[nC].SubItems[0] = '' then
        lvMapInfo.Items.Delete(nC)
      else
      begin
        lvMapInfo.Items[i].SubItems[2] := '';
        lvMapInfo.Items[i].SubItems[3] := '';
        lvMapInfo.Items[i].SubItems[4] := '';
        lvMapInfo.Items[i].SubItems[5] := '';
        lvMapInfo.Items[i].SubItems[6] := '';
      end;
    end;

  end;
end;


procedure TfrMapInfo.lvMapInfoSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  btnSetFieldInfo.Enabled := lvMapInfo.Selected <> nil;
end;

procedure TfrMapInfo.btnOKClick(Sender: TObject);
var
  sError : String;
begin
  if not SaveMapinfo(m_sMapFile) then
    exit;

//检测字段类型匹配设置 和 SQL 语句
  if cbAutoCheck.Checked then
  begin
    sError := CheckFieldType + CheckSql;
    if sError<>'' then
    begin
      if MessageBox( self.Handle, PChar(sError +'是否忽略以上问题？'), '合法性检测' , MB_YESNO	) <> IDYES then
        Exit;
    end;
  end;

  MakeScript;

  self.ModalResult := mrOK;
end;

procedure TfrMapInfo.MakeScript;
var
  sExport,sImport : String;

begin
  MakeScript(m_sWorkPath,m_sMapName, m_pLeftDBCfg,  m_pRightDBCfg,sExport,sImport);

  if m_pLeftDBCfg.m_DBType = SQLServer then
  begin
    edLeftScript.Lines.LoadFromFile(m_sWorkPath+'\Script\'+m_sMapName+'_l.Fmt');
    edLeftScript.Lines.Insert(0,'');
    edLeftScript.Lines.Insert(0,sExport);
  end else
    edLeftScript.Text := sExport;

  // Mak Import Script
  case m_pRightDBCfg.m_DBType of
    SQLServer:
      edRightScript.Lines.LoadFromFile(m_sWorkPath+'\Script\'+m_sMapName+'_r.Fmt');
    Oracle:
      edRightScript.Lines.LoadFromFile(m_sWorkPath+'\Script\'+m_sMapName+'.ctl');
  end;
  edRightScript.Lines.Insert(0,'');
  edRightScript.Lines.Insert(0,sImport);
end;

class procedure TfrMapInfo.MakeScript(sWorkPath,sMapName:string; pLeftDB,pRightDB: PDBConfig;
                var sExport,sImport:String);
var
  leftDef,rightDef : DataSource;
  sTemp ,sMapFile, sColName,sColDesc,sColType,sColTypeDesc: string;
  nColLen : integer;

  function SplitterType(sTypeDesc:string; var sType:string):integer;
  var
    nPos,nPos2 : integer;
  begin
    result := 0;
    nPos := Pos('(',sTypeDesc);
    if nPos <= 1 then
    begin
      sType := UpperCase(sTypeDesc);
      if (sType='DATETIME') or (sType='DATE') or (sType='TIME') then
        result := 24; // 日期的默认长度为24 yyyy-mm-dd hh:mi:ss.sss
      Exit;
    end;

    sType := UpperCase(Copy(sTypeDesc,1,nPos-1));
    nPos2 := PosEx(',', sTypeDesc, nPos+1);
    if nPos2=0 then
      nPos2 := PosEx(')',sTypeDesc,nPos+1);
    if nPos2 = 0 then
      nPos2 := length( sTypeDesc);

    try
      result := StrToInt(Copy(sTypeDesc,nPos+1,nPos2-nPos-1));
    except
    end;
  end;

  procedure CreateFmtFile(sSspect : String);
  var
    ii,nCC : integer;
    fmtFile: textFile;
  begin
    AssignFile(fmtFile,sWorkPath+'\Script\'+sMapName+'_'+sSspect+'.Fmt');  // '.\login.log'
    Rewrite(fmtFile);
    writeln(fmtFile,'9.0'); // sqlserver 2005
    //6       SQLCHAR       0       0       "\t"     6     t_ntext                                  Chinese_PRC_CI_AS
    sTemp := TCommonFunc.GetProfileValue('mapinfo','valid_column_count','0',sMapFile);
    try
      nCC := StrToInt(sTemp);
    except
      nCC := 0;
    end;

    writeln(fmtFile,IntToStr(nCC));
    for ii:=0 to nCC-1 do
    begin
      sColName := TCommonFunc.GetProfileValue('mapinfo','col'+IntToStr(ii+1)+'_'+sSspect,'',sMapFile);
      sColTypeDesc := TCommonFunc.GetProfileValue('mapinfo','col'+IntToStr(ii+1)+'_'+sSspect+'_type','',sMapFile);
      nColLen := SplitterType(sColTypeDesc,sColType) ;//从 sColType 获得长度
      sTemp := Copy(IntToStr(ii+1)+'          ',1,8)+ 'SQLCHAR       ';
      if (sColType='TEXT') or (sColType='IMAGE') or (sColType='BLOB') or (sColType='CLOB') then
        sTemp := sTemp +'0       '+ Copy(IntToStr(nColLen)+'          ',1,8)
        // LOB字段 是否需要前缀长度
        // sql server 的前缀长度数字是 二进制的不是文本
      else
        sTemp := sTemp +'0       '+ Copy(IntToStr(nColLen)+'          ',1,8);

      if (ii=nCC-1) then
        sTemp := sTemp +'"#@\r\n" '
      else
        sTemp := sTemp +'"@&,@"   ';

      if sSspect='r' then
        sTemp := sTemp + Copy( TCommonFunc.GetProfileValue('mapinfo','col'+IntToStr(ii+1)+'_r_order','',sMapFile) +'        ',1,6)
      else
        sTemp := sTemp + Copy(IntToStr(ii+1)+'        ',1,6);

      sTemp := sTemp + Copy(sColName+'                                         ',1,41);
      if (sColType='CHAR') or (sColType='VARCHAR') or (sColType='VARCHAR2') or (sColType='BLOB') or
         (sColType='CLOB') or (sColType='NCHAR') or (sColType='NVARCHAR') or (sColType='BYTE') or
         (sColType='BIT') or (sColType='BINARY') then
        sTemp := sTemp + 'Chinese_PRC_CI_AS'
      else
        sTemp := sTemp +  '""';  //Chinese_PRC_CI_AS
      writeln(fmtFile,sTemp);
    end;

    CloseFile(fmtFile);
  end;

  procedure CreateCtlFile(sSspect : String);
  var
    ii,nCC : integer;
    ctlFile: textFile;
  begin
    AssignFile(ctlFile,sWorkPath+'\Script\'+sMapName+'.ctl');  // '.\login.log'
    Rewrite(ctlFile);

    writeln(ctlFile,'LOAD DATA ');
    writeln(ctlFile,'INFILE '''' "str x''23400D0A''"');
    writeln(ctlFile,'APPEND INTO TABLE ' + rightDef.m_SourceName); // + ' ' );
    writeln(ctlFile,'FIELDS TERMINATED BY ''@&,@'' OPTIONALLY ENCLOSED BY ''"''');
    writeln(ctlFile,'(');

    sTemp := TCommonFunc.GetProfileValue('mapinfo','valid_column_count','0',sMapFile);
    try
      nCC := StrToInt(sTemp);
    except
      nCC := 0;
    end;

    for ii:=0 to nCC-1 do
    begin
      sColName := TCommonFunc.GetProfileValue('mapinfo','col'+IntToStr(ii+1)+'_'+sSspect,'',sMapFile);
      sColTypeDesc := TCommonFunc.GetProfileValue('mapinfo','col'+IntToStr(ii+1)+'_'+sSspect+'_type','',sMapFile);

      nColLen := SplitterType(sColTypeDesc,sColType) ;//从 sColType 获得长度
      sColDesc :=  sColName;
      // 判断类型
      if (sColType='DATE') or (sColType='DATETIME') or (sColType='TIME') or (sColType='TIMESTAMP')  then
        sColDesc := sColDesc +' "to_date(substr(:'+sColName+',1,19),''YYYY-MM-DD HH24:MI:SS'')" '
      else if (sColType='BLOB') or (sColType='CLOB') then
        sColDesc := sColDesc +  ' char(64000000) '
        //' VARCHARC(8,65000000) ' 如果有前缀长度则需要用 VARCHARC
      else if nColLen>200 then  // 判断长度
        sColDesc := sColDesc + ' CHAR('+IntToStr(nColLen+1)+') ';

      if (ii <> nCC-1) then
        sColDesc := sColDesc +',';

      writeln(ctlFile,sColDesc);
    end;
    writeln(ctlFile,')');

    CloseFile(ctlFile);
  end;
begin
  sMapFile :=  sWorkPath+'\MapInfo\'+sMapName+'.cfg';
  LoadMapinfo(sMapFile,@leftDef,@rightDef);

  case pLeftDB^.m_DBType of
    SQLServer:
    begin
      CreateFmtFile('l');
      //bcp export
      sExport := 'bcp "'+leftDef.m_QuerySql+'" queryout %workPath%\'+sMapName+'.dat '+
                 ' -f %scriptPath%\'+sMapName+'_l.fmt -o %workPath%\'+ sMapName +'_Export.log' +
                 ' -S '+ pLeftDB^.m_sServerName+' -U '+pLeftDB^.m_sUserName +' -P '+pLeftDB^.m_sPassword ;
    end;
    Oracle:
    begin
      //sqluldr export
      sExport :='sqluldr user=' + pLeftDB.m_sUserName+'/'+pLeftDB.m_sPassword +'@'+pLeftDB.m_sServerName+
               ' query="'+leftDef.m_QuerySql+'" file=%workPath%\'+sMapName+'.dat '+
                'field="@&,@" record="#@^r^n" > %workPath%\'+ sMapName +'_Export.log';
    end;
  end;

  // Mak Import Script
  case pRightDB^.m_DBType of
    SQLServer:
    begin
      //create file %scriptPath%\sMapName.fmt
      //bcp test.dbo.billdocform format nul -f C:\Map1.fmt -c -S 192.168.1.12 -U sa -P sa
      CreateFmtFile('r');
      //bcp import
      sImport := 'bcp '+rightDef.m_SourceName+' in %workPath%\'+sMapName+'.dat' +
                ' -f %scriptPath%\'+sMapName+'_r.fmt -o %workPath%\'+ sMapName +'_Import.log'+
                ' -S '+pRightDB^.m_sServerName +' -U '+pRightDB^.m_sUserName +' -P '+pRightDB^.m_sPassword;
      //bcp "sfcs.dbo.BILLDOCFORM2" in "C:\d.txt"  -f "C:\f.txt" -S 192.168.1.84 -U sa -P sa   end;
    end;
    
    Oracle:
    begin
      //create file %scriptPath%\sMapName.ctl
      CreateCtlFile('r');

      // sql load
      sImport := 'sqlldr '+ pRightDB^.m_sUserName+'/'+pRightDB^.m_sPassword+'@'+pRightDB^.m_sServerName+
                ' control=%scriptPath%\'+sMapName+'.ctl data=%workPath%\'+ sMapName+'.dat'+
                ' bad=%workPath%\'+ sMapName+'.bad'+
                ' log=%workPath%\'+ sMapName +'_Import.log';

      //sqlldr import
    end;
  end;
end;

procedure TfrMapInfo.pgMainChange(Sender: TObject);
begin
  SaveMapinfo(m_sMapFile);
  if pgMain.ActivePage = tsScript then
  begin
    MakeScript;
    //show  Script
  end;
end;

procedure TfrMapInfo.ledDestNoKeyPress(Sender: TObject; var Key: Char);
begin
  if not (key in ['0'..'9',char(VK_BACK),#13]) then
    key := #0;
end;

function TfrMapInfo.GetLastSou:integer;
var
  nC,i,nS : integer;
begin
  nC := lvMapInfo.Items.Count;
  nS := -1;
  for i:=nC-1 downto 0 do
    if lvMapInfo.Items[i].SubItems[0] <> '' then
    begin
      nS := i;
      break;
    end;
  result := nS;
end;

function TfrMapInfo.GetLastDest:integer;
var
  nC,i,nS : integer;
begin
  nC := lvMapInfo.Items.Count;
  nS := -1;
  for i:=nC-1 downto 0 do
    if lvMapInfo.Items[i].SubItems[2] <> '' then
    begin
      nS := i;
      break;
    end;
  result := nS;
end;

procedure TfrMapInfo.ChangeSouField(const nInd : integer;const nD : integer);
var
  curItem,DesItem : TListItem;
  i,nC,nS : integer;
  sTemps : array [0..8] of String;
begin
  curItem := lvMapInfo.Items[nInd];// .Selected;
  nC := nInd ;//lvMapInfo.ItemIndex;
  if nC = nD then
    exit;

  for i:= 0 to 7 do
    sTemps[i] := curItem.SubItems[i];

  repeat
    if nD > nC then
      nS := nC+1
    else
      nS := nC-1;
    curItem := lvMapInfo.Items[nC];
    DesItem := lvMapInfo.Items[nS];

    curItem.SubItems[0] := DesItem.SubItems[0];
    curItem.SubItems[1] := DesItem.SubItems[1];
    curItem.SubItems[7] := DesItem.SubItems[7];
    nC := nS;

  until nS=nD;
  curItem := lvMapInfo.Items[nC];
  curItem.SubItems[0] := sTemps[0];
  curItem.SubItems[1] := sTemps[1];
  curItem.SubItems[7] := sTemps[7];
  curItem.Selected := true;
end;

procedure TfrMapInfo.ChangeDesField(const nInd : integer;const nD : integer);
var
  curItem,DesItem : TListItem;
  i,nC,nS : integer;
  nCChecked : Boolean;
  sTemps : array [0..8] of String;
begin
  curItem := lvMapInfo.Items[nInd];//Selected;
  nC := nInd;//lvMapInfo.ItemIndex;
  if nC = nD then
    exit;

  for i:= 2 to 6 do
    sTemps[i] := curItem.SubItems[i];
  nCChecked := curItem.Checked;
  repeat
    if nD > nC then
      nS := nC+1
    else
      nS := nC-1;
    curItem := lvMapInfo.Items[nC];
    DesItem := lvMapInfo.Items[nS];
    for i:= 2 to 6 do
      curItem.SubItems[i] := DesItem.SubItems[i];
    curItem.Checked := DesItem.Checked;
    nC := nS;

  until nS=nD;
  curItem := lvMapInfo.Items[nC];
  for i:= 2 to 6 do
    curItem.SubItems[i] := sTemps[i];
   curItem.Checked := nCChecked;
   curItem.Selected := true;
//   lvMapInfo.
end;

procedure TfrMapInfo.MakeSourceSql;
var
  i,nS : integer;
begin
  nS := GetLastSou;

  if nS<0 then
    Exit;
  m_LeftDef.m_QuerySql := 'select '+lvMapInfo.Items[0].SubItems[7] ;
  for i:=1 to nS do
    m_LeftDef.m_QuerySql := m_LeftDef.m_QuerySql +', '+ lvMapInfo.Items[i].SubItems[7] ;

  m_LeftDef.m_QuerySql := m_LeftDef.m_QuerySql +' '+ m_LeftDef.m_FromSql;
  m_LeftDef.m_IsTable := false;
end;


procedure TfrMapInfo.btnSouTopClick(Sender: TObject);
var
  nC : integer;
begin
  if (lvMapInfo.Selected = nil) or (lvMapInfo.Selected.SubItems[0]='') then
    Exit;
  nC := lvMapInfo.Selected.Index;
  if (nC = 0) then
    Exit;
  ChangeSouField(nC,0);
  MakeSourceSql;
end;

procedure TfrMapInfo.btnSouUpClick(Sender: TObject);
var
  nC : integer;
begin
  if (lvMapInfo.Selected = nil) then
    Exit;
  nC := lvMapInfo.Selected.Index;
  if (nC = 0) or (lvMapInfo.Selected.SubItems[0]='') then
    Exit;
  ChangeSouField(nC, nC-1);
  MakeSourceSql;
end;

procedure TfrMapInfo.btnSouDownClick(Sender: TObject);
var
  nC,nS : integer;
begin
  if (lvMapInfo.Selected = nil) or (lvMapInfo.Selected.SubItems[0]='') then
    Exit;

  nS := GetLastSou;
  nC := lvMapInfo.Selected.Index;
  if nC = nS then
    Exit;

  ChangeSouField(nC, nC+1);
  MakeSourceSql;
end;

procedure TfrMapInfo.btnSouBottomClick(Sender: TObject);
var
  nC,nS : integer;
begin
  if (lvMapInfo.Selected = nil) or (lvMapInfo.Selected.SubItems[0]='') then
    Exit;

  nS := GetLastSou;
  nC := lvMapInfo.Selected.Index;
  if nC = nS then
    Exit;

  ChangeSouField(nC,nS);
  MakeSourceSql;
end;


procedure TfrMapInfo.DeleteSouField(nInd :integer);
var
  nS : integer;
  endItem : TListItem;
begin
  nS := GetLastSou;
  if nInd < nS then
    ChangeSouField(nInd,nS);

  endItem := lvMapInfo.Items[nS];
  if endItem.SubItems[2] = '' then
    lvMapInfo.Items.Delete(nS)
  else
  begin
    endItem.SubItems[0] := '';
    endItem.SubItems[1] := '';
    endItem.SubItems[7] := '';
  end;

end;

procedure TfrMapInfo.btnSouDeleteClick(Sender: TObject);
var
  preSel : integer;
begin
  if (lvMapInfo.Selected = nil) or (lvMapInfo.Selected.SubItems[0]='') then
    Exit;
  preSel := lvMapInfo.Selected.Index;
  DeleteSouField( preSel );
  if(lvMapInfo.Items.Count >0) then
  begin
    if(preSel>=lvMapInfo.Items.Count) then
      preSel := lvMapInfo.Items.Count -1;
    lvMapInfo.Items[preSel].Selected := true;
  end;
  MakeSourceSql;
end;


procedure TfrMapInfo.MakeDestSql;
var
  i,nS : integer;
begin
  nS := GetLastDest;
  if nS<0 then
    Exit;

  m_RightDef.m_QuerySql := 'select '+lvMapInfo.Items[0].SubItems[2] ;
  for i:=1 to nS do
    m_RightDef.m_QuerySql := m_RightDef.m_QuerySql +', '+ lvMapInfo.Items[i].SubItems[2] ;

  m_RightDef.m_QuerySql := m_RightDef.m_QuerySql +' '+ m_RightDef.m_FromSql;
  m_RightDef.m_IsTable := false;
end;

procedure TfrMapInfo.btnDesTopClick(Sender: TObject);
var
  nC : integer;
begin
  if (lvMapInfo.Selected = nil) then
    Exit;
  nC := lvMapInfo.Selected.Index;
  if (nC = 0) or (lvMapInfo.Selected.SubItems[2]='') then
    Exit;
  ChangeDesField(nC,0);
  MakeDestSql;
end;

procedure TfrMapInfo.btnDesUpClick(Sender: TObject);
var
  nC : integer;
begin
  if (lvMapInfo.Selected = nil) then
    Exit;
  nC := lvMapInfo.Selected.Index;
  if (nC = 0) or (lvMapInfo.Selected.SubItems[2]='') then
    Exit;
  ChangeDesField(nC,nC-1);
  MakeDestSql;
end;

procedure TfrMapInfo.btnDesDownClick(Sender: TObject);
var
  nC,nS : integer;
begin
  if (lvMapInfo.Selected = nil) or  (lvMapInfo.Selected.SubItems[2]='') then
    Exit;

  nS := GetLastDest;
  nC := lvMapInfo.Selected.Index;
  if nC = nS then
    Exit;

  ChangeDesField(nC,nC+1);
  MakeDestSql;
end;

procedure TfrMapInfo.btnDesBottomClick(Sender: TObject);
var
  nC,nS : integer;
begin
  if (lvMapInfo.Selected = nil) or  (lvMapInfo.Selected.SubItems[2]='') then
    Exit;

  nS := GetLastDest;

  nC := lvMapInfo.Selected.Index;
  if nC = nS then
    Exit;

  ChangeDesField(nC,nS);
  MakeDestSql;
end;


procedure TfrMapInfo.btnSetFieldInfoClick(Sender: TObject);
var
  curItem : TListItem;
  bHaveSou,bHaveDest,bSouDelete,bDestDelete,bSouInsert,bDestInsert : boolean;
  nC,nLastSou,nLastDest,nCurInd : integer;
begin
  // 设定字段名 和属性
  if lvMapInfo.Selected = nil then Exit;
  curItem := lvMapInfo.Selected;
  nCurInd := curItem.Index;

  if not assigned( frDefField) then
    Application.CreateForm(TfrDefField, frDefField);

  frDefField.m_SouFieldName := curItem.SubItems[0];
  frDefField.m_SouFieldType := curItem.SubItems[1];
  frDefField.m_SouFieldDesc := curItem.SubItems[7];
  frDefField.m_DestFieldName := curItem.SubItems[2];
  frDefField.m_DestFieldType := curItem.SubItems[3];
  frDefField.m_DefaultValue := curItem.SubItems[5];

  frDefField.m_bEditDest := true; // tableOpt.ItemIndex > 0;
  bHaveSou := curItem.SubItems[0]<> '';
  bHaveDest := curItem.SubItems[2]<> '';
  bSouDelete := false;
  bDestDelete := false;
  bSouInsert := false;
  bDestInsert := false;


  if frDefField.ShowModal = mrOK then
  begin
    if bHaveSou and (frDefField.m_SouFieldName='') then
    begin
      DeleteSouField( curItem.Index ); //删除源
      bSouDelete := true;
      bHaveSou := false;
    end else if not bHaveSou and (frDefField.m_SouFieldName<>'') then
    begin
      nLastSou := GetLastSou + 1;
      bSouInsert := true;
      lvMapInfo.Items[nLastSou].SubItems[0] := frDefField.m_SouFieldName;
      lvMapInfo.Items[nLastSou].SubItems[1] := frDefField.m_SouFieldType;
      lvMapInfo.Items[nLastSou].SubItems[7] := frDefField.m_SouFieldDesc;

    end else if bHaveSou and (frDefField.m_SouFieldName<>'') then
    begin
      curItem.SubItems[0] := frDefField.m_SouFieldName;
      curItem.SubItems[1] := frDefField.m_SouFieldType;
      curItem.SubItems[7] := frDefField.m_SouFieldDesc;
    end;

    //if tableOpt.ItemIndex>0 then // edit Dest
    //begin
      if bHaveDest and  (frDefField.m_DestFieldName='') then
      begin
        DeleteDestField( curItem.Index ); //删除目标
        bDestDelete := true;
        bHaveDest := false;
      end else if not bHaveDest and  (frDefField.m_DestFieldName<>'') then
      begin
        nLastDest := GetLastDest + 1;
        bDestInsert := true;

        lvMapInfo.Items[nLastDest].SubItems[2] := frDefField.m_DestFieldName;
        lvMapInfo.Items[nLastDest].SubItems[3] := frDefField.m_DestFieldType;
        lvMapInfo.Items[nLastDest].SubItems[4] := 'Y';
        lvMapInfo.Items[nLastDest].SubItems[5] := frDefField.m_DefaultValue;
        lvMapInfo.Items[nLastDest].SubItems[6] := IntToStr(curItem.Index);
      end else if bHaveDest and  (frDefField.m_DestFieldName<>'') then
      begin
        curItem.SubItems[2] := frDefField.m_DestFieldName;
        curItem.SubItems[3] := frDefField.m_DestFieldType;
        curItem.SubItems[5] := frDefField.m_DefaultValue;
      end;

      if bDestDelete and  bHaveSou then
         ChangeSouField(nCurInd,GetLastSou)
      else if  bDestInsert and  bHaveSou then
         ChangeSouField(nCurInd,GetLastDest);

    //end;

    if bSouDelete and  bHaveDest then
       ChangeDesField(nCurInd,GetLastDest)
    else if bSouInsert and  bHaveDest then
       ChangeDesField(nCurInd,GetLastSou);

    nC := lvMapInfo.Items.Count-1;
    if (lvMapInfo.Items[nC].SubItems[0] ='') and (lvMapInfo.Items[nC].SubItems[2] = '') then
      lvMapInfo.Items.Delete(nC-1);

    MakeDestSql;
    MakeSourceSql;
  end; //mrOK
end;

procedure TfrMapInfo.DeleteDestField(nInd :integer);
var
  nS : integer;
  endItem : TListItem;
begin
  if (lvMapInfo.Selected = nil) or  (lvMapInfo.Selected.SubItems[2]='') then
    Exit;

  nS := GetLastDest;

  if nInd < nS then
    ChangeDesField(nInd,nS);

  endItem := lvMapInfo.Items[nS];
  if endItem.SubItems[0] = '' then
    lvMapInfo.Items.Delete(nS)
  else
  begin
    endItem.SubItems[2] := '';
    endItem.SubItems[3] := '';
    endItem.SubItems[4] := '';
    endItem.SubItems[5] := '';
    endItem.SubItems[6] := '';
  end;

end;

procedure TfrMapInfo.btnDesDeleteClick(Sender: TObject);
var
  preSel : integer;
begin
  if (lvMapInfo.Selected = nil) or  (lvMapInfo.Selected.SubItems[2]='') then
    Exit;

  preSel := lvMapInfo.Selected.Index;
  DeleteDestField( preSel);

  if(lvMapInfo.Items.Count >0) then
  begin
    if(preSel>=lvMapInfo.Items.Count) then
      preSel := lvMapInfo.Items.Count -1;
    lvMapInfo.Items[preSel].Selected := true;
  end;
  MakeDestSql;
end;

function TfrMapInfo.CheckFieldType : String;
var
  sErrorMsg:String;
  i,nC,lt,rt : integer;
begin
  sErrorMsg := '';
  nC := lvMapInfo.Items.Count;
  for i:=0 to nC-1 do
  begin
    if (lvMapInfo.Items[i].SubItems[0] <> '') and  (lvMapInfo.Items[i].SubItems[2] <> '') then
    begin
      if Trim(lvMapInfo.Items[i].SubItems[5]) ='' then // 不是常量才需要检查
      begin
        lt := TCommDB.GetInnerType(lvMapInfo.Items[i].SubItems[1]);
        rt := TCommDB.GetInnerType(lvMapInfo.Items[i].SubItems[3]);
        if(m_pLeftDBCfg.m_DBType =Oracle) and (lt=4) then
          sErrorMsg := sErrorMsg +'第'+IntToStr(i+1)+'行 '+lvMapInfo.Items[i].SubItems[1] +' 类型为CLOB，字段可能被截断，请用CENTIT_LOB.ClobToBlob转换为Blob'#13#10
        else if ((lt<>5) or (rt<>4)) and ( (rt<>lt)  or (lt=0) ) then
          sErrorMsg := sErrorMsg +'第'+IntToStr(i+1)+'行 '+lvMapInfo.Items[i].SubItems[1] +' 和 '+lvMapInfo.Items[i].SubItems[3]+' 不匹配'#13#10;
      end;
    end;
    { else
      if lvMapInfo.Items[i].SubItems[2] <> '' then
      begin
        if Trim(lvMapInfo.Items[i].SubItems[5]) =''then
          sErrorMsg := sErrorMsg +'第'+IntToStr(i+1)+'行 '+lvMapInfo.Items[i].SubItems[2] +' 没有对应的值'#13#10;
      end;
    }
  end;
  if sErrorMsg<>'' then
    sErrorMsg := sErrorMsg + #13#10;
  for i:=0 to nC-1 do
  begin
    if (lvMapInfo.Items[i].SubItems[0] <> '') and  (lvMapInfo.Items[i].SubItems[2] <> '') then
    begin
       if lvMapInfo.Items[i].SubItems[0] <> lvMapInfo.Items[i].SubItems[2] then
          sErrorMsg := sErrorMsg +'第'+IntToStr(i+1)+'行 '+lvMapInfo.Items[i].SubItems[0] +' 和 '+lvMapInfo.Items[i].SubItems[2]+' 名称不一致,请确认。'#13#10;
    end;
  end;

  result := sErrorMsg;
end;

{
    m_LeftDef,m_RightDef : DataSource;
    m_pLeftDBCfg,
    m_pRightDBCfg : PDBConfig;
}
function TfrMapInfo.CheckSql : String;
var
  sErrorMsg:String;
  sSqlSen : String;

  function CheckPrm(sParameterName : String ; nSqlType: integer): boolean;
  var
    sPrmName,sFieldName :  String;
    i,nIC : Integer;
  begin
    sPrmName := UpperCase(Trim(sParameterName));
    result := false;
    if sPrmName='TODAY' then
        result := true      
    else if (nSqlType=1) and (sPrmName='SQL_ERROR_MSG')then
      result := true
    else if nSqlType=2 then
    begin
      if sPrmName='SYNC_DATA_PIECES' then
        result := true
      else if sPrmName='SUCCEED_PIECES' then
        result := true
      else if sPrmName='FAULT_PIECES' then
        result := true
      else if sPrmName='SYNC_BEGIN_TIME' then
        result := true
      else if sPrmName='SYNC_END_TIME' then
        result := true;
    end;

    if nSqlType<>2 then
    begin
      nIC := lvMapInfo.Items.Count;
      for i:=0 to nIC-1 do
      begin
        sFieldName :=UpperCase(Trim(lvMapInfo.Items[i].SubItems[0]));
        if sPrmName=sFieldName then
          result := true;
      end;
    end;
  end;

  function testSql(sSql:String;nSqlType: integer):String;
  var
    i,nC : integer;
    sPN : String;
  begin
    result := '';
    try
      nC := CltDMConn.PrepareExecSql(sSql);
      for i:=0 to nC-1 do
      begin
        sPN := CltDMConn.ADOQuery.Parameters[i].Name;
        if not CheckPrm(sPN,nSqlType) then
          result := result + '参数: '+ sPN +' 找不到对应的字段'#13#10;
      end;
      //CltDMConn.ADOQuery.Close;
    except
      on   e:exception   do
        result := e.Message + #13#10;
    end;
  end;
begin
  sErrorMsg := '';

  self.Cursor := crSQLWait;
  CltDMConn.SetDBSetting(m_pLeftDBCfg^.m_sDBConn);
  m_pLeftDBCfg^.m_bCanConnected := CltDMConn.ConnectDB;
  if m_pLeftDBCfg^.m_bCanConnected then
  begin
    sSqlSen := Trim(ledBeforeOptLeft.Text);
    if Length(sSqlSen)> 6 then
      sErrorMsg := sErrorMsg + testSql(sSqlSen,0);
    sSqlSen := Trim(ledAfterOptLeft.Text);
    if Length(sSqlSen)> 6 then
      sErrorMsg := sErrorMsg + testSql(sSqlSen,0);
    sSqlSen := Trim(ledErrorLeft.Text);
    if Length(sSqlSen)> 6 then
      sErrorMsg := sErrorMsg + testSql(sSqlSen,1);
    sSqlSen := Trim(ledTransCompleteLeft.Text);
    if Length(sSqlSen)> 6 then
      sErrorMsg := sErrorMsg + testSql(sSqlSen,2);

    CltDMConn.Disconnect;
  end else
    sErrorMsg := sErrorMsg+ '数据源无法连接'#1310;

  CltDMConn.SetDBSetting(m_pRightDBCfg^.m_sDBConn);
  m_pRightDBCfg^.m_bCanConnected := CltDMConn.ConnectDB;
  if m_pRightDBCfg^.m_bCanConnected then
  begin
    sSqlSen := Trim(ledBeforeOptRight.Text);
    if Length(sSqlSen)> 6 then
      sErrorMsg := sErrorMsg + testSql(sSqlSen,0);
    sSqlSen := Trim(ledAfterOptRight.Text);
    if Length(sSqlSen)> 6 then
      sErrorMsg := sErrorMsg + testSql(sSqlSen,0);
    sSqlSen := Trim(ledErrorRight.Text);
    if Length(sSqlSen)> 6 then
      sErrorMsg := sErrorMsg + testSql(sSqlSen,1);
    sSqlSen := Trim(ledTransCompleteRight.Text);
    if Length(sSqlSen)> 6 then
      sErrorMsg := sErrorMsg + testSql(sSqlSen,2);

    CltDMConn.Disconnect;
  end else
    sErrorMsg := sErrorMsg+ '数据目标无法连接'#1310;

  self.Cursor := crDefault;
  result := sErrorMsg;
end;

procedure TfrMapInfo.btnCheckSettingClick(Sender: TObject);
var
  sError : String;
begin
//检测字段类型匹配设置
  if pcMapInfo.ActivePageIndex = 0 then
    sError := CheckFieldType
//检测SQL语法
  else
    sError := CheckSql;
  if sError<>'' then
    ShowMessage(sError)
  else
    ShowMessage('没有发现可疑的问题。');
end;

procedure TfrMapInfo.btnAddDestFieldClick(Sender: TObject);
var
  nC,nDC : integer;
  newItem : TListItem;
begin
  //只有目标字段已经达到最大行了才可以
  nC := lvMapInfo.Items.Count;
  nDC := GetLastDest+1;
  if(nC=nDC)then
  begin
    newItem := lvMapInfo.Items.Add;
    newItem.Caption := IntToStr(nC+1);

    newItem.SubItems.Add('');
    newItem.SubItems.Add('');

    newItem.SubItems.Add('new field');
    newItem.SubItems.Add('new type');
    newItem.SubItems.Add('Y');
    newItem.SubItems.Add('');
    newItem.SubItems.Add( IntToStr(nC+1) );
    newItem.SubItems.Add('');
  end;
  lvMapInfo.ItemIndex := nDC;
  btnSetFieldInfoClick(Sender);
end;

end.
