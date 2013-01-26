unit OpenProject;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, ComCtrls;

type
  TfrOpenProject = class(TForm)
    rbtnNew: TRadioButton;
    rbtnOpen: TRadioButton;
    ledProjectWorkPath: TLabeledEdit;
    btnSetProjectPath: TBitBtn;
    ledProjectName: TLabeledEdit;
    btnOpenProject: TBitBtn;
    btnOK: TBitBtn;
    OpenProject: TOpenDialog;
    SaveProject: TSaveDialog;
    lvHistoryPorject: TListView;
    lbDBClickList: TLabel;
    procedure rbtnNewClick(Sender: TObject);
    procedure rbtnOpenClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnSetProjectPathClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnOpenProjectClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lvHistoryPorjectDblClick(Sender: TObject);
  private
    { Private declarations }
    procedure SaveHistoryPath(sFilePath: String);
  public
    m_bNewProject : boolean;
    m_sWorkPath,m_sProjectName : string;
    m_sCurPath : string;
    { Public declarations }
  end;

var
  frOpenProject: TfrOpenProject;

implementation
uses CommonFunc;
{$R *.dfm}
procedure TfrOpenProject.FormCreate(Sender: TObject);
begin
  m_bNewProject := true;
  btnSetProjectPath.Visible := true;
  btnOpenProject.Visible := false;
  m_sCurPath := '';
  m_sWorkPath := '';
  m_sProjectName := '';
end;

procedure TfrOpenProject.FormShow(Sender: TObject);
var
  sTemp,sFilePath : String;
  i ,nC ,nFC : integer;
  newItem : TListItem;
begin

  ledProjectWorkPath.Text := m_sWorkPath;
  ledProjectName.Text := m_sProjectName;
  // load history project
  nC := 0;
  lvHistoryPorject.Items.Clear;
  sTemp := TCommonFunc.GetRegKeyValue( '\Software\Centit\DataMove','filecount','N');

  nFC := StrToInt(sTemp);
  for i:=0 to nFC -1 do
  begin
    sFilePath := TCommonFunc.GetRegKeyValue('\Software\Centit\DataMove','file'+IntToStr(i));
    if(sFilePath<>'') and (sFilePath<>m_sCurPath) then
    begin
      newItem := lvHistoryPorject.Items.Add;
      Inc(nC);
      newItem.Caption := IntToStr(nC);
      newItem.SubItems.Add(sFilePath);
    end;
  end;
  if (length(m_sCurPath)>10) then
    rbtnOpen.Checked := true;
end;

procedure TfrOpenProject.rbtnNewClick(Sender: TObject);
begin
  m_bNewProject := true;
  btnSetProjectPath.Visible := true;
  btnOpenProject.Visible := false;
  m_sProjectName := '';
  ledProjectName.Text := m_sProjectName;
  btnOK.Caption := '新建';
end;

procedure TfrOpenProject.rbtnOpenClick(Sender: TObject);
begin
  m_bNewProject := false;
  btnSetProjectPath.Visible := false;
  btnOpenProject.Visible := true;
  btnOK.Caption := '打开';
end;

procedure TfrOpenProject.btnSetProjectPathClick(Sender: TObject);
var
  sFilePath,sExtName : String;
begin
  if not SaveProject.Execute then Exit;
  sFilePath := SaveProject.FileName;

  TCommonFunc.SplitFilePath(sFilePath,m_sWorkPath,m_sProjectName,sExtName);

  ledProjectWorkPath.Text := m_sWorkPath;
  ledProjectName.Text := m_sProjectName;
end;

procedure TfrOpenProject.btnOpenProjectClick(Sender: TObject);
var
  sFilePath,sExtName : String;
begin
  if not OpenProject.Execute then Exit;
  sFilePath := OpenProject.FileName;
  TCommonFunc.SplitFilePath(sFilePath,m_sWorkPath,m_sProjectName,sExtName);

  ledProjectWorkPath.Text := m_sWorkPath;
  ledProjectName.Text := m_sProjectName;
end;

procedure TfrOpenProject.SaveHistoryPath(sFilePath: String);
var
  sTemp : String;
   i ,j,nC : integer;
begin
  j:=0;
  if sFilePath<>'' then
  begin
    TCommonFunc.SetRegKeyValue('\Software\Centit\DataMove','file0',sFilePath);
    j:=1;
  end;

  if (length(m_sCurPath)>4) and (sFilePath<>m_sCurPath) then
  begin
    TCommonFunc.SetRegKeyValue('\Software\Centit\DataMove','file'+IntToStr(j),m_sCurPath);
    Inc(j);
  end;

  nC := lvHistoryPorject.Items.Count;
  for i:=0 to nC-1 do
  begin
    sTemp := lvHistoryPorject.Items[i].SubItems[0];
    if(sFilePath<>sTemp)  then
    begin
      TCommonFunc.SetRegKeyValue('\Software\Centit\DataMove','file'+IntToStr(j),sTemp);
      Inc(j);
    end;
  end;
  TCommonFunc.SetRegKeyValue('\Software\Centit\DataMove','filecount',IntToStr(j),'N');
end;

procedure TfrOpenProject.btnOKClick(Sender: TObject);
var
  sFilePath : String;
begin
  if(m_sWorkPath='') or (m_sProjectName='') then
  begin
    ShowMessage('请输入正确的项目路径和名称!');
    Exit;
  end;
  sFilePath := m_sWorkPath + '\'+ m_sProjectName+'.proj'; { + '\'+m_sProjectName}
  if ( sFilePath = m_sCurPath) then
  begin
    self.ModalResult := mrCancel;
    Exit;
  end;
  //Save Project Path to history
  SaveHistoryPath( sFilePath);
  self.ModalResult := mrOK;
end;

procedure TfrOpenProject.lvHistoryPorjectDblClick(Sender: TObject);
var
  sPorjectPath,sExtName : String;
begin
  if lvHistoryPorject.Selected = nil then Exit;
  sPorjectPath := lvHistoryPorject.Selected.SubItems[0];
  rbtnOpen.Checked := true;

  TCommonFunc.SplitFilePath(sPorjectPath,m_sWorkPath,m_sProjectName,sExtName);

  if not DirectoryExists(m_sWorkPath) then
  begin
    ShowMessage('项目文件丢失，请检查！');
    lvHistoryPorject.DeleteSelected;
    SaveHistoryPath('');
    Exit;
  end;


  frOpenProject.m_bNewProject := false;
  ledProjectWorkPath.Text := m_sWorkPath;
  ledProjectName.Text := m_sProjectName;
  SaveHistoryPath(sPorjectPath);
  self.ModalResult := mrOK;
end;

end.
