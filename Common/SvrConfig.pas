unit SvrConfig;

interface
uses SysUtils,CommonFunc,Classes;

type
  TSvrInfo = class
  constructor Create;
  public
    sDBConn :String;
    //webserverice
    sUrl : string;
    sUserID : string;
    sAppVersion : string;
  end;

var
  svrInfo : TSvrInfo;

implementation

constructor TSvrInfo.Create;
begin
  sDBConn := 'Provider=OraOLEDB.Oracle.1;Password=jlwater;Persist Security Info=True;User ID=jlwater;Data Source=centora';
  sDBConn := TCommonFunc.GetProfileValue('DBCFG','CONN',sDBConn,'.\Config.ini');
end;

end.
