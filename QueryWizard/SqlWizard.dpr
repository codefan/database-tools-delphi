program SqlWizard;

uses
  Forms,
  QueryWizard in 'QueryWizard.pas' {frQueryWizard},
  CommDBM in '..\Common\CommDBM.pas' {CommDB: TDataModule},
  SvrConfig in '..\Common\SvrConfig.pas',
  CommonFunc in '..\Common\CommonFunc.pas';

{$R *.res}

begin
  Application.Initialize;
  svrInfo := TSvrInfo.Create;
  Application.CreateForm(TCommDB, CltDMConn);
  Application.CreateForm(TfrQueryWizard, frQueryWizard);
  Application.Run;
end.
