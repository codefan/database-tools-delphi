unit MainFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ComCtrls, StdCtrls, Buttons, ExtCtrls,DefDB;

type
  TfrMainFrame = class(TForm)
    muMain: TMainMenu;
    muFile: TMenuItem;
    muEdit: TMenuItem;
    muHelp: TMenuItem;
    muNew: TMenuItem;
    muExit: TMenuItem;
    muAbout: TMenuItem;
    muNewMapInfo: TMenuItem;
    muEditMapInfo: TMenuItem;
    muDeleteMapInfo: TMenuItem;
    muEditSplit: TMenuItem;
    muBuild: TMenuItem;
    panelTop: TPanel;
    panelBottom: TPanel;
    ledLeftDB: TLabeledEdit;
    btnSetLeftDB: TBitBtn;
    ledRightDB: TLabeledEdit;
    btnSetRightDB: TBitBtn;
    btnBuild: TBitBtn;
    btnExit: TBitBtn;
    pgMain: TPageControl;
    tsMapInfo: TTabSheet;
    tsPretreatment: TTabSheet;
    lvMapInfo: TListView;
    panel2Bottom: TPanel;
    panel2BottomTop: TPanel;
    lbLeftAfterExport: TLabel;
    lbRightAfterImport: TLabel;
    edLeftAfterExport: TMemo;
    edRightAfterImport: TMemo;
    panel2Top: TPanel;
    lbLeftBeforeExport: TLabel;
    lbRightBeforeImport: TLabel;
    edLeftBeforeExport: TMemo;
    edRightBeforeImport: TMemo;
    cbRunType: TComboBox;
    cbAutoMakeScript: TCheckBox;
    plPage1Bottom: TPanel;
    btnNewMapInfo: TBitBtn;
    btnEditMapInfo: TBitBtn;
    btnDeleteMapInfo: TBitBtn;
    btnMoveTop: TBitBtn;
    btnMoveUp: TBitBtn;
    btnMoveDown: TBitBtn;
    btnMoveBottom: TBitBtn;
    procedure FormShow(Sender: TObject);
    procedure muNewClick(Sender: TObject);
    procedure btnSetLeftDBClick(Sender: TObject);
    procedure btnSetRightDBClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure muExitClick(Sender: TObject);
    procedure muNewMapInfoClick(Sender: TObject);
    procedure muEditMapInfoClick(Sender: TObject);
    procedure muDeleteMapInfoClick(Sender: TObject);
    procedure muBuildClick(Sender: TObject);
    procedure cbRunTypeSelect(Sender: TObject);
    procedure btnMoveTopClick(Sender: TObject);
    procedure btnMoveUpClick(Sender: TObject);
    procedure btnMoveDownClick(Sender: TObject);
    procedure btnMoveBottomClick(Sender: TObject);
    procedure muAboutClick(Sender: TObject);

  private
    m_hasProject : boolean;
    { Private declarations }
    m_sWorkPath,m_sProjectName,m_sRunPath : string;
    m_LeftDBCfg,m_RightDBCfg : DBConfig;
    procedure CopyStaticFile;
    procedure LoadProject;
    procedure SaveProject;
    procedure MakScript;
    procedure MoveMapInfoPos(const nD : integer);

  public
    procedure SetProject(const sFilePath: string);
    { Public declarations }
  end;

var
  frMainFrame: TfrMainFrame;

implementation

uses OpenProject,MapInfo,CommonFunc,shellapi;
{$R *.dfm}
procedure TfrMainFrame.FormCreate(Sender: TObject);
begin
  m_hasProject := false;
  m_sRunPath := ExtractFileDir(Application.ExeName);
  m_sWorkPath := '';
  m_sProjectName := '';
end;

procedure TfrMainFrame.CopyStaticFile;
begin
  if not DirectoryExists(m_sWorkPath+'\MapInfo') then
    CreateDirectory(PChar(m_sWorkPath+'\MapInfo'),nil);
  if not DirectoryExists(m_sWorkPath+'\Script') then
    CreateDirectory(PChar(m_sWorkPath+'\Script'),nil);
  if not DirectoryExists(m_sWorkPath+'\Datas') then
    CreateDirectory(PChar(m_sWorkPath+'\Datas'),nil);

  //if not FileExists(m_sWorkPath+'\DataMoving.exe') then
  Copyfile(PChar(m_sRunPath+'\DataMoving.exe'),PChar(m_sWorkPath+'\DataMoving.exe'),false);
  //if not FileExists(m_sWorkPath+'\DataMoving1.bat') then
  Copyfile(PChar(m_sRunPath+'\DataMoving1.bat'),PChar(m_sWorkPath+'\DataMoving1.bat'),false);
  //if not FileExists(m_sWorkPath+'\DataMoving2.bat') then
  Copyfile(PChar(m_sRunPath+'\DataMoving2.bat'),PChar(m_sWorkPath+'\DataMoving2.bat'),false);
  if not FileExists(m_sWorkPath+'\sqluldr.exe') then
    Copyfile(PChar(m_sRunPath+'\sqluldr.exe'),PChar(m_sWorkPath+'\sqluldr.exe'),false);

end;

procedure TfrMainFrame.SetProject(const sFilePath: string);
var
  sExtName,sWorkPath,sProjectName : string;
begin
  TCommonFunc.SplitFilePath(sFilePath,sWorkPath,sProjectName,sExtName);
  if sExtName<>'proj' then
    Exit;
  if FileExists( sFilePath) then
  begin
    m_sWorkPath := sWorkPath;
    m_sProjectName := sProjectName;
    m_hasProject := true;
    LoadProject;
  end else
  begin
    m_sWorkPath := sWorkPath;
    m_sProjectName := sProjectName;
    m_hasProject := true;
    CopyStaticFile;
  end;

end;

procedure TfrMainFrame.FormShow(Sender: TObject);
begin
  if not m_hasProject then
    PostMessage(self.Handle,WM_COMMAND,2,0);
  //2 为菜单编号，从上向下从左向右
  //muNew.perform(WM_COMMAND,0,0);
end;

procedure TfrMainFrame.muNewClick(Sender: TObject);
begin
  if not assigned( frOpenProject) then
    Application.CreateForm(TfrOpenProject, frOpenProject);

  if m_hasProject then
    frOpenProject.m_sCurPath := m_sWorkPath + '\'+ m_sProjectName+'.proj';
  frOpenProject.m_sWorkPath := m_sWorkPath;
  frOpenProject.m_sProjectName := m_sProjectName;
  if frOpenProject.ShowModal <> mrOK then
  begin
    if m_hasProject then
      Exit;
    Application.Terminate;
    Exit;
  end;
  
  if m_hasProject then
    SaveProject;

  m_hasProject := true;
  m_sWorkPath := frOpenProject.m_sWorkPath;
  m_sProjectName := frOpenProject.m_sProjectName;

  self.Caption := m_sWorkPath + '\'+ m_sProjectName+'.proj';

  // MapInfo Script Tools
  if(frOpenProject.m_bNewProject) then
  begin
    CopyStaticFile;

    //清空对应关系列表
    ledLeftDB.Text := '';
    ledRightDB.Text := '';
    lvMapInfo.Items.Clear;
    edLeftBeforeExport.Lines.Clear;
    edLeftAfterExport.Lines.Clear;
    edRightBeforeImport.Lines.Clear;
    edRightAfterImport.Lines.Clear;
  end else
    LoadProject;

  pgMain.ActivePageIndex := 0;
end;

procedure TfrMainFrame.LoadProject;
var
  nMapCount,i : integer;
  sProjFile, sMapFile, sTemp : String;
  newItem : TListItem;
begin
  sProjFile := m_sWorkPath+'\'+m_sProjectName+'.proj';
  //Load DB Config
  frDefDB.LoadDBConfig( sProjFile,'source',m_LeftDBCfg );
  ledLeftDB.Text := m_LeftDBCfg.m_sDBConn;
  frDefDB.LoadDBConfig( sProjFile,'destination',m_RightDBCfg );
  ledRightDB.Text := m_RightDBCfg.m_sDBConn;
  //Load MapInfo
  lvMapInfo.Items.Clear;
  nMapCount := TCommonFunc.GetProfileInt('main','mapcount',0,sProjFile);
  for i:= 0 to nMapCount-1 do
  begin
    sMapFile :=  m_sWorkPath+'\MapInfo\Map' + IntToStr(i) + '.cfg';
    newItem := lvMapInfo.Items.Add;
    newItem.Caption := IntToStr(i+1);
    sTemp := TCommonFunc.GetProfileValue('source','source_name','',sMapFile);
    newItem.SubItems.Add(sTemp);
    sTemp := TCommonFunc.GetProfileValue('source','type','query_sql',sMapFile);
    newItem.SubItems.Add(sTemp);

    sTemp := TCommonFunc.GetProfileValue('destination','source_name','',sMapFile);
    newItem.SubItems.Add(sTemp);
    sTemp := TCommonFunc.GetProfileValue('destination','table_opt','none',sMapFile);
    newItem.SubItems.Add(sTemp);
    sTemp := TCommonFunc.GetProfileValue('destination','row_opt','insert',sMapFile);
    newItem.SubItems.Add(sTemp);

    sTemp := TCommonFunc.GetProfileValue('main','run','no',sMapFile);
    newItem.Checked := sTemp = 'yes';
  end;
  // prepare run script
  try
    if FileExists(m_sWorkPath+'\Script\before_export.sql') then
      edLeftBeforeExport.Lines.LoadFromFile(m_sWorkPath+'\Script\before_export.sql');
  except
    edLeftBeforeExport.Lines.Clear;
  end;
  try
    if FileExists(m_sWorkPath+'\Script\after_export.sql') then
      edLeftAfterExport.Lines.LoadFromFile(m_sWorkPath+'\Script\after_export.sql');
  except
    edLeftAfterExport.Lines.Clear;
  end;
  try
    if FileExists(m_sWorkPath+'\Script\before_import.sql') then
      edRightBeforeImport.Lines.LoadFromFile(m_sWorkPath+'\Script\before_import.sql');
  except
    edRightBeforeImport.Lines.Clear;
  end;
  try
    if FileExists(m_sWorkPath+'\Script\after_import.sql') then
      edRightAfterImport.Lines.LoadFromFile(m_sWorkPath+'\Script\after_import.sql');
  except
    edRightAfterImport.Lines.Clear;
  end;
end;

procedure TfrMainFrame.SaveProject;
var
  i,nC :integer;
  sMapFile : String;
  procedure CheckQuit(sqlMemo : TMemo);
  var
    j,nLC : integer;
  begin
    nLC := sqlMemo.Lines.Count;
    j := nLC;
    while (j>0) and (Trim(sqlMemo.Lines[j-1])='') do dec(j);
    if j=0 then Exit;
    if LowerCase(copy(Trim(sqlMemo.Lines[j-1]),1,4)) = 'quit' then Exit;
    if j = nLC then
      sqlMemo.Lines.Add('quit')
    else
      sqlMemo.Lines[j] := 'quit';
  end;

  procedure CheckGo(sqlMemo : TMemo);
  var
    j,nLC : integer;
  begin
    nLC := sqlMemo.Lines.Count;
    j := nLC;
    while (j>0) and (Trim(sqlMemo.Lines[j-1])='') do dec(j);
    if j=0 then Exit;
    if LowerCase(Trim(sqlMemo.Lines[j-1])) = 'go' then Exit;
    if j = nLC then
      sqlMemo.Lines.Add('go')
    else
      sqlMemo.Lines[j] := 'go';
  end;

  procedure DeleteScriptFile(sFileName : String);
  begin
    if not FileExists(sFileName) then
      Exit;

    if FileExists(sFileName+'.bak') then
      DeleteFile(sFileName+'.bak');
    RenameFile(sFileName,sFileName+'.bak');
  end;
begin
  // 检查Oracle脚本的最后一行是不是 Quit, 没有就添加
  if m_LeftDBCfg.m_DBType = Oracle then
  begin
    CheckQuit(edLeftBeforeExport);
    CheckQuit(edLeftAfterExport);
  end else if m_LeftDBCfg.m_DBType = SQLServer then
  begin
    CheckGo(edLeftBeforeExport);
    CheckGo(edLeftAfterExport);
  end;

  if m_RightDBCfg.m_DBType = Oracle then
  begin
    CheckQuit(edRightBeforeImport);
    CheckQuit(edRightAfterImport);
  end else if m_LeftDBCfg.m_DBType = SQLServer then
  begin
    CheckGo(edRightBeforeImport);
    CheckGo(edRightAfterImport);
  end;

  if trim( edLeftBeforeExport.Text) <> '' then
    edLeftBeforeExport.Lines.SaveToFile(m_sWorkPath+'\Script\before_export.sql')
  else
    DeleteScriptFile(m_sWorkPath+'\Script\before_export.sql');

  if trim( edLeftAfterExport.Text) <> '' then
    edLeftAfterExport.Lines.SaveToFile(m_sWorkPath+'\Script\after_export.sql')
  else
    DeleteScriptFile(m_sWorkPath+'\Script\after_export.sql');

  if trim( edRightBeforeImport.Text) <> '' then
    edRightBeforeImport.Lines.SaveToFile(m_sWorkPath+'\Script\before_import.sql')
  else
    DeleteScriptFile(m_sWorkPath+'\Script\before_import.sql');

  if trim( edRightAfterImport.Text) <> '' then
    edRightAfterImport.Lines.SaveToFile(m_sWorkPath+'\Script\after_import.sql')
  else
    DeleteScriptFile(m_sWorkPath+'\Script\after_import.sql');

  nC := lvMapInfo.Items.Count;
  for i:= 0 to nC-1 do
  begin
    sMapFile :=  m_sWorkPath+'\MapInfo\Map' + IntToStr(i) + '.cfg';
    if lvMapInfo.Items[i].Checked then
      TCommonFunc.SetProfileValue('main','run','yes',sMapFile)
    else
      TCommonFunc.SetProfileValue('main','run','no',sMapFile);
  end;



end;

procedure TfrMainFrame.btnSetLeftDBClick(Sender: TObject);
begin
  if not assigned( frDefDB) then
    Application.CreateForm(TfrDefDB, frDefDB);

  frDefDB.m_DBConfig := m_LeftDBCfg;

  if frDefDB.ShowModal <> mrOK then
    Exit;
  m_LeftDBCfg := frDefDB.m_DBConfig;
  frDefDB.SaveDBConfig( m_sWorkPath+'\'+m_sProjectName+'.proj','source',m_LeftDBCfg );
  ledLeftDB.Text := m_LeftDBCfg.m_sDBConn;
end;

procedure TfrMainFrame.btnSetRightDBClick(Sender: TObject);
begin
  if not assigned( frDefDB) then
    Application.CreateForm(TfrDefDB, frDefDB);

  frDefDB.m_DBConfig := m_RightDBCfg;

  if frDefDB.ShowModal <> mrOK then
    Exit;
  m_RightDBCfg := frDefDB.m_DBConfig;
  frDefDB.SaveDBConfig( m_sWorkPath+'\'+m_sProjectName+'.proj','destination',m_RightDBCfg );
  ledRightDB.Text := m_RightDBCfg.m_sDBConn;
end;

procedure TfrMainFrame.muExitClick(Sender: TObject);
begin
  CopyStaticFile;
  SaveProject;
  if cbAutoMakeScript.Checked then
    MakScript;

  Application.Terminate;
end;

procedure TfrMainFrame.muNewMapInfoClick(Sender: TObject);
var
  nC : integer;
  curItem : TListItem;
begin
  //to add new MapInfo
  frMapInfo.m_pLeftDBCfg := @m_LeftDBCfg;
  frMapInfo.m_pRightDBCfg := @m_RightDBCfg;
  nC := lvMapInfo.Items.Count;
  frMapInfo.SetMapInfo(m_sWorkPath,'Map'+IntToStr(nC));
  if frMapInfo.ShowModal = mrOK then
  begin
    curItem :=  lvMapInfo.Items.Add;
    curItem.Caption := IntToStr(nC+1);

    curItem.SubItems.Add(frMapInfo.m_LeftDef.m_SourceName);
    
    if frMapInfo.m_LeftDef.m_IsTable then
      curItem.SubItems.Add('table')
    else
      curItem.SubItems.Add('query_sql');

    curItem.SubItems.Add(frMapInfo.m_RightDef.m_SourceName);
    curItem.SubItems.Add(frMapInfo.m_RightDef.m_sTableOpt);
    curItem.SubItems.Add(frMapInfo.m_RightDef.m_sRowOpt);

    TCommonFunc.SetProfileValue('main','mapcount',IntToStr(nC+1),m_sWorkPath+'\'+m_sProjectName+'.proj');
  end;
end;

procedure TfrMainFrame.muEditMapInfoClick(Sender: TObject);
var
  nC : integer;
  curItem : TListItem;
begin
  //to Edit new MapInfo
  if lvMapInfo.Selected = nil then Exit;
  curItem :=  lvMapInfo.Selected;
  frMapInfo.m_pLeftDBCfg := @m_LeftDBCfg;
  frMapInfo.m_pRightDBCfg := @m_RightDBCfg;
  nC := lvMapInfo.ItemIndex;
  frMapInfo.SetMapInfo( m_sWorkPath,'Map'+IntToStr(nC));
  if frMapInfo.ShowModal = mrOK then
  begin
    curItem.SubItems[0] := frMapInfo.m_LeftDef.m_SourceName;// .m_QuerySql;
    if frMapInfo.m_LeftDef.m_IsTable then
      curItem.SubItems[1] := 'table'
    else
      curItem.SubItems[1] := 'query_sql';

    curItem.SubItems[2] := frMapInfo.m_RightDef.m_SourceName;

    curItem.SubItems[3] := frMapInfo.m_RightDef.m_sTableOpt;
    curItem.SubItems[4] := frMapInfo.m_RightDef.m_sRowOpt;
  end;
end;

procedure TfrMainFrame.muDeleteMapInfoClick(Sender: TObject);
var
  i,nCur,nC : integer;
begin
  //to Edit new MapInfo
  if lvMapInfo.Selected = nil then Exit;
  nCur := lvMapInfo.ItemIndex;
  nC := lvMapInfo.Items.Count;

  if FileExists( m_sWorkPath+'\MapInfo\Map'+IntToStr(nCur)+'.cfg.bak') then
    DeleteFile( m_sWorkPath+'\MapInfo\Map'+IntToStr(nCur)+'.cfg.bak');
  RenameFile(m_sWorkPath+'\MapInfo\Map'+IntToStr(nCur)+'.cfg',m_sWorkPath+'\MapInfo\Map'+IntToStr(nCur)+'.cfg.bak');

  for i:=nCur to nC-2 do
  begin
    RenameFile(m_sWorkPath+'\MapInfo\Map'+IntToStr(i+1)+'.cfg',m_sWorkPath+'\MapInfo\Map'+IntToStr(i)+'.cfg');
    lvMapInfo.Items[i].Caption := IntToStr(i);
  end;
  lvMapInfo.Items.Delete(nCur);
  TCommonFunc.SetProfileValue('main','mapcount',IntToStr(nC-1),m_sWorkPath+'\'+m_sProjectName+'.proj');
end;

procedure TfrMainFrame.MakScript;
var
  sExport,sImport,sTemp : string;
  i,nC : integer;
  exportFile,importFile,movingFile: textFile;
begin

  AssignFile(exportFile,m_sWorkPath+'\Script\export.bat');
  Rewrite(exportFile);
  AssignFile(importFile,m_sWorkPath+'\Script\import.bat');
  Rewrite(importFile);
  AssignFile(movingFile,m_sWorkPath+'\Script\Moving.bat');
  Rewrite(movingFile);

  if FileExists(m_sWorkPath+'\Script\before_export.sql') then
  begin
    case m_LeftDBCfg.m_DBType of
    SQLServer:
      sTemp := 'sqlcmd -U '+m_LeftDBCfg.m_sUserName +' -P '+m_LeftDBCfg.m_sPassword+
               ' -S '+m_LeftDBCfg.m_sServerName+' -d '+m_LeftDBCfg.m_sDBName+
               ' -i %scriptPath%\before_export.sql -o %workPath%\before_export.log';
    Oracle:
      //sqluldr export
      sTemp :='sqlplus '+m_LeftDBCfg.m_sUserName +'/'+m_LeftDBCfg.m_sPassword+'@'+m_LeftDBCfg.m_sServerName +
              ' @%scriptPath%\before_export.sql > %workPath%\before_export.log';
    end;
    writeln(exportFile,sTemp);
    writeln(movingFile,sTemp);
  end;
  if FileExists(m_sWorkPath+'\Script\before_import.sql') then
  begin
    case m_RightDBCfg.m_DBType of
    SQLServer:
      sTemp := 'sqlcmd -U '+m_RightDBCfg.m_sUserName +' -P '+m_RightDBCfg.m_sPassword+
               ' -S '+m_RightDBCfg.m_sServerName+' -d '+m_RightDBCfg.m_sDBName+
               ' -i %scriptPath%\before_import.sql -o %workPath%\before_import.log';
    Oracle:
      //sqluldr export
      sTemp :='sqlplus '+m_RightDBCfg.m_sUserName +'/'+m_RightDBCfg.m_sPassword+'@'+m_RightDBCfg.m_sServerName +
              ' @%scriptPath%\before_import.sql > %workPath%\before_import.log';
    end;
    writeln(importFile,sTemp);
    writeln(movingFile,sTemp);
  end;
  (*
  要添加创建表的脚本， 并在 importFile 和 movingFile 之前用  sqlcmd 或者 sqlplus 执行
  codefan@sina.com 2011-11-15
  *)

  nC := lvMapInfo.Items.Count;
  for i:=0 to nC-1 do
  begin
    if lvMapInfo.Items[i].Checked then
    begin
      TfrMapInfo.MakeScript(m_sWorkPath,'Map'+IntToStr(i),@m_LeftDBCfg,@m_RightDBCfg,sExport,sImport);
      writeln(exportFile,sExport);
      writeln(importFile,sImport);
    end;
  end;

  sTemp := '%projPath%DataMoving.exe -r %projPath%'+m_sProjectName+'.proj %workPath%';
  writeln(movingFile,sTemp);
  
  if FileExists(m_sWorkPath+'\Script\after_export.sql') then
  begin
    case m_LeftDBCfg.m_DBType of
    SQLServer:
      sTemp := 'sqlcmd -U '+m_LeftDBCfg.m_sUserName +' -P '+m_LeftDBCfg.m_sPassword+
               ' -S '+m_LeftDBCfg.m_sServerName+' -d '+m_LeftDBCfg.m_sDBName+
               ' -i %scriptPath%\after_export.sql -o %workPath%\after_export.log';
    Oracle:
      //sqluldr export
      sTemp :='sqlplus '+m_LeftDBCfg.m_sUserName +'/'+m_LeftDBCfg.m_sPassword+'@'+m_LeftDBCfg.m_sServerName +
              ' @%scriptPath%\after_export.sql > %workPath%\after_export.log';
    end;
    writeln(exportFile,sTemp);
    writeln(movingFile,sTemp);
  end;

  if FileExists(m_sWorkPath+'\Script\after_import.sql') then
  begin
    case m_RightDBCfg.m_DBType of
    SQLServer:
      sTemp := 'sqlcmd -U '+m_RightDBCfg.m_sUserName +' -P '+m_RightDBCfg.m_sPassword+
               ' -S '+m_RightDBCfg.m_sServerName+' -d '+m_RightDBCfg.m_sDBName+
               ' -i %scriptPath%\after_import.sql -o %workPath%\after_import.log';
    Oracle:
      //sqluldr export
      sTemp :='sqlplus '+m_RightDBCfg.m_sUserName +'/'+m_RightDBCfg.m_sPassword+'@'+m_RightDBCfg.m_sServerName +
              ' @%scriptPath%\after_import.sql > %workPath%\after_import.log';
    end;
    writeln(importFile,sTemp);
    writeln(movingFile,sTemp);
  end;

  CloseFile(exportFile);
  CloseFile(importFile);
  CloseFile(movingFile);
end;

procedure TfrMainFrame.muBuildClick(Sender: TObject);
begin
  // save script
  CopyStaticFile;
  SaveProject;
  MakScript;
  //to build new MapInfo

  if cbRunType.ItemIndex = 1 then
     ShellExecute(0, 'open', PChar('"'+m_sWorkPath + '\DataMoving1.bat"'),
                          nil,
                          PChar(m_sWorkPath), SW_SHOW)
  else  if cbRunType.ItemIndex = 2 then
     ShellExecute(0, 'open', PChar('"'+m_sWorkPath + '\DataMoving2.bat"'),
                          nil,
                          PChar('"'+ m_sWorkPath +'"'), SW_SHOW);
  {ShellExecute(0, 'open', PChar(m_sRunPath + '\DataMoving1.bat'),
                          PChar('-r "'+m_sWorkPath + '\'+ m_sProjectName+'.proj"'),
                          PChar(m_sRunPath + '\'), 0);
  }
end;

procedure TfrMainFrame.cbRunTypeSelect(Sender: TObject);
begin
  case cbRunType.ItemIndex of
    1: btnBuild.Caption := '运行脚本';
    2: btnBuild.Caption := '运行程序';
  else
    btnBuild.Caption := '生成脚本';
  end;
end;

procedure TfrMainFrame.MoveMapInfoPos(const nD : integer);
var
  curItem,DesItem : TListItem;
  i,nC,nS : integer;
  nCChecked : Boolean;
  sTemps : array [0..8] of String;
begin
  curItem := lvMapInfo.Selected;
  nC := lvMapInfo.ItemIndex;
  if (curItem=nil) or (nC = nD) or (nD<0) or (nD>=lvMapInfo.Items.Count) then
    Exit;

  for i:= 0 to 4 do
    sTemps[i] := curItem.SubItems[i];
  nCChecked := curItem.Checked;

  RenameFile(m_sWorkPath+'\MapInfo\Map'+IntToStr(nC)+'.cfg',m_sWorkPath+'\MapInfo\MapTmp.cfg');

  repeat
    if nD > nC then
      nS := nC+1
    else
      nS := nC-1;

    curItem := lvMapInfo.Items[nC];
    DesItem := lvMapInfo.Items[nS];
    for i:= 0 to 4 do
      curItem.SubItems[i] := DesItem.SubItems[i];
    curItem.Checked := DesItem.Checked;
    RenameFile(m_sWorkPath+'\MapInfo\Map'+IntToStr(nS)+'.cfg',m_sWorkPath+'\MapInfo\Map'+IntToStr(nC)+'.cfg');
    nC := nS;
  until nS=nD;

  curItem := lvMapInfo.Items[nC];
  for i:= 0 to 4 do
    curItem.SubItems[i] := sTemps[i];
  curItem.Checked := nCChecked;
  RenameFile(m_sWorkPath+'\MapInfo\MapTmp.cfg',m_sWorkPath+'\MapInfo\Map'+IntToStr(nC)+'.cfg');

  curItem.Selected := true;
end;

procedure TfrMainFrame.btnMoveTopClick(Sender: TObject);
begin
  MoveMapInfoPos(0);
end;

procedure TfrMainFrame.btnMoveUpClick(Sender: TObject);
begin
   MoveMapInfoPos(lvMapInfo.ItemIndex-1);
end;

procedure TfrMainFrame.btnMoveDownClick(Sender: TObject);
begin
   MoveMapInfoPos(lvMapInfo.ItemIndex+1);
end;

procedure TfrMainFrame.btnMoveBottomClick(Sender: TObject);
begin
   MoveMapInfoPos(lvMapInfo.Items.Count-1);
end;

procedure TfrMainFrame.muAboutClick(Sender: TObject);
begin
  ShowMessage('更新日期2012-8-31'#13#10'  1，更新select语句太长不能保持到ini中的bug。'+
   #13#10'  2，更新了默认值无法生效的bug。' +
   #13#10'  3，添加了可以没有目标表只有触发器的特性。'+
   #13#10'更新日期2013-1-6'#13#10'  1，添加了对Access的支持。');
end;

end.
