program DataMove;
uses
  Forms,
  Dialogs,
  MainFrame in 'MainFrame.pas' {frMainFrame},
  OpenProject in 'OpenProject.pas' {frOpenProject},
  MapInfo in 'MapInfo.pas' {frMapInfo},
  DefSource in 'DefSource.pas' {frDefSource},
  DefDB in 'DefDB.pas' {frDefDB},
  CommDBM in '..\Common\CommDBM.pas' {CommDB: TDataModule},
  SvrConfig in '..\Common\SvrConfig.pas',
  DefField in 'DefField.pas' {frDefField},
  CommonFunc in '..\Common\CommonFunc.pas';

{$R *.res}
begin
  Application.Initialize;
  Application.Title := '数据迁移工具';
  svrInfo := TSvrInfo.Create;
  Application.CreateForm(TCommDB, CltDMConn);
  Application.CreateForm(TfrMainFrame, frMainFrame);
  Application.CreateForm(TfrOpenProject, frOpenProject);
  Application.CreateForm(TfrMapInfo, frMapInfo);
  Application.CreateForm(TfrDefSource, frDefSource);
  Application.CreateForm(TfrDefDB, frDefDB);
  Application.CreateForm(TfrDefField, frDefField);
  if ParamCount>0 then
    frMainFrame.SetProject(ParamStr(1));

  Application.Run;
end.
