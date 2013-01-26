program DataMoving;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  ACTIVEX,
  shellapi,
  CommDBM in '..\Common\CommDBM.pas' {CommDB: TDataModule},
  SvrConfig in '..\Common\SvrConfig.pas',
  RunDataMap in 'RunDataMap.pas',
  DefDB in '..\DataMove\DefDB.pas' {frDefDB},
  CommonFunc in '..\Common\CommonFunc.pas';

var
  //souDM,destDM : TCommDB;
  sHint,sFilePath,sRunPath,sLogPath :String;
  runer : TRunDataMap;
begin
  { TODO -oUser -cConsole Main : Insert code here }
  sRunPath := ExtractFilePath(ParamStr(0));
  if ParamCount>0 then
    sHint := LowerCase(ParamStr(1));

  if ParamCount>1 then
    sFilePath := ParamStr(2)
  else
    sFilePath := 'D:\centit\Controls\DataBase\Execute\TestDemo\Demo.proj';


  if (sHint='-e') or (sHint='/e') or (sHint='e') then
  begin
    ShellExecute(0, 'open', PChar(sRunPath + 'DataMove.exe'), PChar(sFilePath), PChar(sRunPath), 0);
    Exit;
  end else if (sHint='-r') or (sHint='/r') or (sHint='r') then
  begin
    if  (FileExists(sFilePath)) then //(ParamCount>1) and
    begin
      sLogPath := '';
      if ParamCount>2 then
        sLogPath := ParamStr(3);

      CoInitialize(nil);//CoInitialize;
      svrInfo := TSvrInfo.Create;
      Writeln('开始运行 '+ sFilePath+' ...' );
      runer := TRunDataMap.Create;
      runer.Run(sFilePath,sLogPath);
      runer.Destroy;
      CoUninitialize;
      Writeln('运行 '+ sFilePath+' 结束' );
      Exit;
    end else
      Writeln('项目文件'+ sFilePath+'找不到，请输入正确的脚本项目文件路径。' );
  end;
  //show helper

  Writeln('/e porject_file_path 编辑对应关系');
  Writeln('/r porject_file_path 运行数据迁移');

end.
