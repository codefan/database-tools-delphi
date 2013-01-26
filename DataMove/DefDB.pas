unit DefDB;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons;

type
  DATABASETYPE = (SQLServer, Oracle, DB2, MSAccess);
  RETURN_SQL_TYPE = (SQL_QUERY, SQL_MDL, SQL_DDL);
  COLDATATYPE = (CT_NONE,CT_NUM, CT_CHAR, CT_STRING,CT_DATE,CT_TIME,CT_DATETIME);
  PDBConfig = ^DBConfig;
  DBConfig = record
    m_DBType : DATABASETYPE;
    m_sServerName,
    m_sDBName,
    m_sUserName,
    m_sPassword,
    m_sHostPort,
    m_sJdbcUrl,
    m_sDBConn : String;
    m_bCanConnected:boolean;
  end;

  TfrDefDB = class(TForm)
    cbDBType: TComboBox;
    lbDBtypeInSet: TLabel;
    ledServerName: TLabeledEdit;
    ledDBName: TLabeledEdit;
    ledUserName: TLabeledEdit;
    ledPassword: TLabeledEdit;
    edDBConn: TMemo;
    lbDBConn: TLabel;
    btnOK: TBitBtn;
    btnCancel: TBitBtn;
    ledHostPort: TLabeledEdit;
    btnLoadMDBFile: TButton;
    loadAccess: TOpenDialog;
    procedure DBConfigChanged(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnLoadMDBFileClick(Sender: TObject);
  private
    { Private declarations }
    bChangeConn : boolean;
  public
    { Public declarations }
    m_DBConfig : DBConfig;
    class procedure SaveDBConfig(const sfilepath,scatalog : String; const dbcfg : DBConfig);
    class procedure LoadDBConfig(const sfilepath,scatalog : String; var dbcfg : DBConfig);
  end;

var
  frDefDB: TfrDefDB;

implementation

uses CommonFunc,CommDBM;
{$R *.dfm}
procedure TfrDefDB.FormShow(Sender: TObject);
begin
  bChangeConn := false;
  ledServerName.Text := m_DBConfig.m_sServerName;
  ledDBName.Text := m_DBConfig.m_sDBName;
  ledUserName.Text := m_DBConfig.m_sUserName;
  ledPassword.Text := m_DBConfig.m_sPassword;
  ledHostPort.Text := m_DBConfig.m_sHostPort;
  cbDBType.ItemIndex := Ord(m_DBConfig.m_DBType);
  ledDBName.Width := 215;
  btnLoadMDBFile.Visible := false;
  if(cbDBType.ItemIndex=1)then
    ledDBName.EditLabel.Caption := 'Oracle SID：'
  else if(cbDBType.ItemIndex=3) then
  begin
    ledDBName.EditLabel.Caption := '数据文件名：';
    ledDBName.Width := 187;
    btnLoadMDBFile.Visible := true;
  end else
    ledDBName.EditLabel.Caption := '数据库名： ';

  edDBConn.Lines.Clear;
  edDBConn.Lines.Add('oledb：');
  edDBConn.Lines.Add(m_DBConfig.m_sDBConn);
  edDBConn.Lines.Add('jdbc url：');
  edDBConn.Lines.Add(m_DBConfig.m_sJdbcUrl);
  //ledDBName.Enabled := m_DBConfig.m_DBType = SQLServer;
  bChangeConn := true;
end;

procedure TfrDefDB.DBConfigChanged(Sender: TObject);
var
  nSel : Integer;
begin
  if not bChangeConn then Exit;

  nSel := cbDBType.ItemIndex;
  ledDBName.Width := 215;
  btnLoadMDBFile.Visible := false;
  //  DATABASETYPE = (SQLServer, Oracle, MSAccess, DB2);
  if(nSel=1)then
    ledDBName.EditLabel.Caption := 'Oracle SID：'
  else if(nSel=3)then
  begin
    ledDBName.EditLabel.Caption := '数据文件名：';
    ledDBName.Width := 187;
    btnLoadMDBFile.Visible := true;
  end else
    ledDBName.EditLabel.Caption := '数据库名： ';

  m_DBConfig.m_sServerName := Trim(ledServerName.Text);
  m_DBConfig.m_sDBName := Trim(ledDBName.Text);
  m_DBConfig.m_sUserName := Trim(ledUserName.Text);
  m_DBConfig.m_sPassword := Trim(ledPassword.Text);
  m_DBConfig.m_sHostPort := Trim(ledHostPort.Text);

  case nSel of
    0:  begin
          m_DBConfig.m_DBType := SQLServer;
          m_DBConfig.m_sDBConn := 'Provider=SQLOLEDB.1;Password='+m_DBConfig.m_sPassword+';Persist Security Info=True;'+
                       'User ID='+m_DBConfig.m_sUserName+';Initial Catalog='+m_DBConfig.m_sDBName+';Data Source='+m_DBConfig.m_sServerName;

          m_DBConfig.m_sJdbcUrl :='jdbc:sqlserver://'+ m_DBConfig.m_sHostPort+';databaseName='+m_DBConfig.m_sDBName;
          //Provider=SQLNCLI.1;Password=2centit13;Persist Security Info=True;User ID=sa;Initial Catalog=test;Data Source=192.168.1.12
          //Provider=SQLOLEDB.1;Password=2centit13;Persist Security Info=True;User ID=sa;Initial Catalog=test;Data Source=192.168.1.12
        end;
    1:  begin
          m_DBConfig.m_DBType := Oracle;
          m_DBConfig.m_sDBConn := 'Provider=OraOLEDB.Oracle.1;Password='+m_DBConfig.m_sPassword+';Persist Security Info=True;'+
                       'User ID='+m_DBConfig.m_sUserName+';Data Source='+m_DBConfig.m_sServerName;
          m_DBConfig.m_sJdbcUrl :='jdbc:oracle:thin:@'+ m_DBConfig.m_sHostPort+':'+m_DBConfig.m_sDBName;
        end;
    2:  begin
          m_DBConfig.m_DBType := DB2;
          m_DBConfig.m_sDBConn := 'Provider=IBMDADB2.1;Password='+m_DBConfig.m_sPassword+';Persist Security Info=True;'+
                       'User ID='+m_DBConfig.m_sUserName+';Data Source='+m_DBConfig.m_sServerName;//Location="";Extended Properties=""
          m_DBConfig.m_sJdbcUrl :='jdbc:db2://'+ m_DBConfig.m_sHostPort+'/'+m_DBConfig.m_sDBName;
        end;
    3:  begin
          m_DBConfig.m_DBType := MSAccess;
          m_DBConfig.m_sDBConn := 'Provider=Microsoft.Jet.OLEDB.4.0;Data Source='+ m_DBConfig.m_sDBName +';Persist Security Info=False';
          if m_DBConfig.m_sPassword<>'' then
            m_DBConfig.m_sDBConn := m_DBConfig.m_sDBConn +';Jet OLEDB:Database Password='+m_DBConfig.m_sPassword;
          m_DBConfig.m_sJdbcUrl := //'jdbc:odbc:driver={MicrosoftAccessDriver(*.mdb)};DBQ='
            'jdbc:odbc:Driver={Microsoft Access Driver (*.mdb, *.accdb)};DBQ=' + m_DBConfig.m_sDBName;
        end;
  end;
  edDBConn.Lines.Clear;
  edDBConn.Lines.Add('oledb：');
  edDBConn.Lines.Add(m_DBConfig.m_sDBConn);
  edDBConn.Lines.Add('jdbc url：');
  edDBConn.Lines.Add(m_DBConfig.m_sJdbcUrl);
end;

procedure TfrDefDB.btnOKClick(Sender: TObject);
begin
  if (m_DBConfig.m_DBType <> MSAccess) and (m_DBConfig.m_sServerName='') then
  begin
    ShowMessage('请输入服务器名称！');
    ledServerName.SetFocus;
    Exit;
  end;
  if (m_DBConfig.m_DBType = SQLServer) and (m_DBConfig.m_sDBName='') then
  begin
    if(cbDBType.ItemIndex=1)then
      ShowMessage('请输入数据库名称！')
    else
      ShowMessage('请输入Oracle SID！');
    ledDBName.SetFocus;
    Exit;
  end;
  {
  if(m_DBConfig.m_sHostPort='') then
  begin
    ShowMessage('请输入主机地址和端口，例如127.0.0.1:1521！');
    ledHostPort.SetFocus;
    Exit;
  end;
  }
  if (m_DBConfig.m_DBType <> MSAccess) and (m_DBConfig.m_sUserName='') then
  begin
    ShowMessage('请输入用户名！');
    ledUserName.SetFocus;
    Exit;
  end;
  if (m_DBConfig.m_DBType <> MSAccess) and (m_DBConfig.m_sPassword='') then
  begin
    ShowMessage('请输入密码！');
    ledPassword.SetFocus;
    Exit;
  end;

  self.Cursor := crHourGlass;
  //m_sDBConn := edDBConn.Text;
  CltDMConn.SetDBSetting(m_DBConfig.m_sDBConn);
  m_DBConfig.m_bCanConnected := CltDMConn.ConnectDB;
  self.Cursor := crDefault;
  if m_DBConfig.m_bCanConnected then
  begin
    CltDMConn.Disconnect;
    ShowMessage('连接测试成功！');
  end else
  begin
    if MessageBox( self.Handle, '连接测试失败，是否要重新设置数据库连接？', '连接测试' , MB_YESNO	) = IDYES then
      Exit;
  end;
  self.ModalResult := mrOK;
end;

class procedure TfrDefDB.SaveDBConfig(const sfilepath,scatalog : String; const dbcfg : DBConfig);
begin
  case dbcfg.m_DBType of
    SQLServer:  TCommonFunc.SetProfileValue(scatalog,'database_type','SQL Server',sfilepath);
    MSAccess:  TCommonFunc.SetProfileValue(scatalog,'database_type','MSAccess',sfilepath);
    DB2: TCommonFunc.SetProfileValue(scatalog,'database_type','DB2',sfilepath);
    Oracle: TCommonFunc.SetProfileValue(scatalog,'database_type','Oracle',sfilepath);
  end;

  TCommonFunc.SetProfileValue(scatalog,'server',dbcfg.m_sServerName,sfilepath);
  TCommonFunc.SetProfileValue(scatalog,'database',dbcfg.m_sDBName,sfilepath);
  TCommonFunc.SetProfileValue(scatalog,'hostport',dbcfg.m_sHostPort,sfilepath);
  TCommonFunc.SetProfileValue(scatalog,'user',dbcfg.m_sUserName,sfilepath);
  TCommonFunc.SetProfileValue(scatalog,'password',dbcfg.m_sPassword,sfilepath);
  TCommonFunc.SetProfileValue(scatalog,'conn',dbcfg.m_sDBConn,sfilepath);
  TCommonFunc.SetProfileValue(scatalog,'jdbcurl',dbcfg.m_sJdbcUrl,sfilepath);
end;

class procedure TfrDefDB.LoadDBConfig(const sfilepath,scatalog : String; var dbcfg : DBConfig);
var
  sDBType : String;
begin
  sDBType := TCommonFunc.GetProfileValue(scatalog,'database_type','',sfilepath);
  dbcfg.m_DBType := SQLServer;
  if sDBType='Oracle' then
    dbcfg.m_DBType := Oracle
  else if sDBType='SQL Server' then
    dbcfg.m_DBType := SQLServer
  else if sDBType='MSAccess' then
    dbcfg.m_DBType := MSAccess
  else if sDBType='DB2' then
    dbcfg.m_DBType := DB2;

  dbcfg.m_sServerName := TCommonFunc.GetProfileValue(scatalog,'server','',sfilepath);
  dbcfg.m_sHostPort := TCommonFunc.GetProfileValue(scatalog,'hostport','',sfilepath);
  dbcfg.m_sDBName := TCommonFunc.GetProfileValue(scatalog,'database','',sfilepath);
  dbcfg.m_sUserName := TCommonFunc.GetProfileValue(scatalog,'user','',sfilepath);
  dbcfg.m_sPassword := TCommonFunc.GetProfileValue(scatalog,'password','',sfilepath);
  dbcfg.m_sDBConn := TCommonFunc.GetProfileValue(scatalog,'conn','',sfilepath);
  dbcfg.m_sJdbcUrl := TCommonFunc.GetProfileValue(scatalog,'jdbcurl','',sfilepath);
  dbcfg.m_bCanConnected := true;//false; 设置为 true 程序会自动测试是否可以连接
end;

procedure TfrDefDB.btnLoadMDBFileClick(Sender: TObject);
var
  sFilePath : String;
begin
  if not loadAccess.Execute then Exit;
  sFilePath := loadAccess.FileName;
  ledDBName.Text := sFilePath; 
end;

end.
