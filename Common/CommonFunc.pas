unit CommonFunc;

interface
uses SysUtils,Windows,IniFiles,Classes,Registry,Forms,
     Variants;
type
  TObjPointer = class(TObject)
    pData:Pointer;
    constructor Create(p:Pointer=nil);
  end;
  TObjString = class(TObject)
    str:String;
    constructor Create(s:String='');
  end;
  TObjInt = class(TObject)
    tag:Integer;
    constructor Create(i:Integer=0);
  end;

  TCommonFunc = class
  public
    class function GetRegKeyValue(sKeyPath:String;sKeyName:String;nValueType:char='S';rootKey:HKEY=Windows.HKEY_LOCAL_MACHINE):String;
    class function SetRegKeyValue(sKeyPath:String;sKeyName:String;sValue:String;nValueType:char='S';rootKey:HKEY=Windows.HKEY_LOCAL_MACHINE):boolean;

    class function GetProfileValue(sSection:String;sKeyName:String;sDefaultValue:String;sIniFileName:String):String;
    class function GetProfileInt(sSection:String;sKeyName:String;sDefaultValue:Integer;sIniFileName:String):Integer;
    class function SetProfileValue(sSection:String;sKeyName:String;sValue:String;sIniFileName:String):boolean;

    class	function IsNumber(const sValue:String):boolean;
    class	function IsNumberArray(const sValue:String):boolean;
    class	function IsTrue(const sValue:String):boolean;
		class	function TrimDateString(const sDateStr:String):String;
		class	function IsDate(const sDateStr:String):boolean;

    class function GetAWord(const strSource:String;var startPos:integer;bXPath:boolean=false;bEraseQM:boolean=true):String;
		class	function NextCode(const sCode:String):String;
		class	function NextCodeEx(const sCode:String):String;
		class	function FormatTableField(const sTableField:String):String;//Multi Table
    class function SplitString(const sValue:String;const sSplitStr:String;var sStrs:TStrings) : integer;
    class function SplitFilePath(const sFilePath:String;var sDirectory:String;var sFileName:String;var sFileExt:String) : boolean;

    class function GetPYIndex(const szHanzi:string):char;
    class function GetPYABIndex(const szHanzi:string):string;
    class procedure SaveStrToFile(var sContent:string;sFilename:String);

    class function  DataToStr(fromData:real;DotDigit:integer):string; //小数保存函数，只舍不进

    class function  FloatCompare(fDataSource,fDatadest:double;DotDigit:integer):integer;//浮点数比较大小

    class function  InnerMatch(const sCheckType,sInputBankAccounts,sFormatBankAccounts:string):Boolean;///银行网点匹配

    class  procedure WriteLog(sLogName,s:String;bNewLine:boolean=false;bShowTime:boolean=false);
    class  procedure WriteLogEx(sLogName,s:String;bNewLine:boolean=false;bShowTime:boolean=false);

    class function DataValueToString(sDataValue:string;nLength:integer):string;Overload;
    class function DataValueToString(nDataValue:integer;nLength:integer):string;Overload;
    class function DataValueToString(dDataValue:double;nLength:integer):string;Overload;
    class function DataValueToString(nDataValue:int64;nLength:integer):string;Overload;
    class function GetSpaceString(nCount:integer):string;
    class function GetZeroString(nCount:integer):string;
    class function intvaluetostring(nDataValue:integer;nLength:integer):string;
    class function GetMatchString(sMatch:String):string;
  end;

  TSQLPrm = class
  public
    class function IntToPrm(const nPrm:integer):TStrings;
    class function FloatToPrm(const fPrm:real):TStrings;
    class function DateToPrm(const dtDate:TDateTime):TStrings;

    class function StrToPrm(const sPrm:String):TStrings;overload;
    class function StrToPrm(const sPrm,sPrm2:String):TStrings;overload;
    class function StrToPrm(const sPrm,sPrm2,sPrm3:String):TStrings;overload;
    class function StrToPrm(const sPrm,sPrm2,sPrm3,sPrm4:String):TStrings;overload;
    class function StrToPrm(const sPrm,sPrm2,sPrm3,sPrm4,sprm5:String):TStrings;overload;
    class function StrToPrm(const sPrm,sPrm2,sPrm3,sPrm4,sprm5,sprm6:String):TStrings;overload;
    class function StrToPrm(const sPrm,sPrm2,sPrm3,sPrm4,sprm5,sprm6,sprm7:String):TStrings;overload;
    class function StrToPrm(const sPrm,sPrm2,sPrm3,sPrm4,sprm5,sprm6,sprm7,sprm8:String):TStrings;overload;
    class function StrToPrm(const sPrm,sPrm2,sPrm3,sPrm4,sprm5,sprm6,sprm7,sprm8,sprm9:String):TStrings;overload;
    class function IntToVaiant(const nPrm:integer; const VAL:integer=1):OleVariant;
    class function FloatToVaiant(const fPrm:real; const VAL:integer=1):OleVariant;
    class function StrToVaiant(const sPrm: String; const VAL:integer=1):OleVariant;
  end;


implementation

uses Math;

constructor TObjPointer.Create(p:Pointer=nil);
begin
  pData := p;
end;

constructor TObjString.Create(s:String='');
begin
  str := s;
end;

constructor TObjInt.Create(i:Integer=0);
begin
  tag := i;
end;

class function TCommonFunc.GetRegKeyValue(sKeyPath:String;sKeyName:String;nValueType:char='S';rootKey:HKEY=Windows.HKEY_LOCAL_MACHINE):String;
var
	tReg:Tregistry;
begin
	if nValueType='N' then
    result := '0'
  else
    result := '';

	tReg:=Tregistry.Create;
  tReg.RootKey:=rootKey;
  try
    if tReg.OpenKey(sKeyPath,false) then
    begin
      case nValueType of
      'S':
        result := tReg.ReadString(sKeyName);
      'N':
        result := IntToStr(tReg.ReadInteger(sKeyName));
      'F':
        result := FloatToStr(tReg.ReadFloat(sKeyName));
      'D':
        result := DateToStr(tReg.ReadDateTime(sKeyName));
      'L':
        result := IntToStr(tReg.GetDataSize(sKeyName));
      end;
    end;
  except
  end;
  tReg.Free;
end;

class function TCommonFunc.SetRegKeyValue(sKeyPath:String;sKeyName:String;sValue:String;nValueType:char='S';rootKey:HKEY=Windows.HKEY_LOCAL_MACHINE):boolean;
var
	tReg:Tregistry;
begin
	result := false;
	tReg:=Tregistry.Create;
  tReg.RootKey:=rootKey;
  if tReg.OpenKey(sKeyPath,true) then
  begin
  	case nValueType of
    'S':
      tReg.WriteString(sKeyName,sValue);
    'N':
    	tReg.WriteInteger(sKeyName,StrToInt(sValue));
    'F':
    	tReg.WriteFloat(sKeyName,StrToFloat(sValue));
    'D':
    	tReg.WriteDateTime(sKeyName,StrToDate(sValue));
    end;
    result := true;
  end;
  tReg.Free;
end;

class function TCommonFunc.GetProfileValue(sSection:String;sKeyName:String;sDefaultValue:String;sIniFileName:String):String;
var
  iniFIle:TIniFile;
begin
  iniFIle := TIniFIle.Create(sIniFileName);
  result := iniFile.ReadString(sSection,sKeyName,sDefaultValue);
  iniFile.Free;
end;

class function TCommonFunc.GetProfileInt(sSection:String;sKeyName:String;sDefaultValue:Integer;sIniFileName:String):Integer;
var
  iniFIle:TIniFile;
  sRes : String;
begin
  iniFIle := TIniFIle.Create(sIniFileName);
  sRes := iniFile.ReadString(sSection,sKeyName,IntToStr(sDefaultValue));
  iniFile.Free;
  try
    if sRes <> '' then
      result := StrToInt(sRes)
    else
      result:=0;
  except
    result := 0;
  end;
end;

class function TCommonFunc.SetProfileValue(sSection:String;sKeyName:String;sValue:String;sIniFileName:String):boolean;
var
  iniFIle:TIniFile;
begin
  iniFIle := TIniFIle.Create(sIniFileName);
  iniFile.WriteString(sSection,sKeyName,sValue);
  iniFIle.Free;
  result := true;
end;

class procedure TCommonFunc.SaveStrToFile(var sContent:string;sFilename:String);
var
  tfFile: textFile;
begin
  AssignFile(tfFile,sFilename);
  rewrite(tfFile);
  write(tfFile,sContent);
  CloseFile(tfFile);
end;

class	function TCommonFunc.IsNumberArray(const sValue:String):boolean;
var
  j,sl,dotCount:integer;
  sTmpV:String;
  bRes:boolean;
begin
  sTmpV := Trim(sValue);
  sl := length(sTmpV);
  if sl=0 then
  begin
  	result := false;
    Exit;
  end;
  bRes := true;
  dotCount := 0;
  for j:=1 to sl do
  begin
    if sTmpV[j]='.' then
      Inc(dotCount)
    else if sTmpV[j]=',' then
    begin
      if dotCount=1 then
        dotCount := 0;
    end else
    begin
      if not (sTmpV[j] in ['0'..'9']) then
        bRes := false;
    end;
  end;
  if dotCount>1 then bRes := false;
  result := bRes;
end;

class	function TCommonFunc.IsNumber(const sValue:String):boolean;
var
  j,sl,dotCount:integer;
  sTmpV:String;
  bRes:boolean;
begin
  sTmpV := Trim(sValue);
  sl := length(sTmpV);
  if sl=0 then
  begin
  	result := false;
    Exit;
  end;
  bRes := true;
  dotCount := 0;
  for j:=1 to sl do
  begin
    if sTmpV[j]='.' then
      Inc(dotCount)
    else
    begin
      if not (sTmpV[j] in [',','0'..'9']) then
        bRes := false;
    end;
  end;
  if dotCount>1 then bRes := false;
  result := bRes;
end;

class	function TCommonFunc.IsTrue(const sValue:String):boolean;
begin
	result := IsNumber(sValue) and (sValue<>'0');
end;

class	function TCommonFunc.TrimDateString(const sDateStr:String):String;
var
  j,sl:Integer;
  sTmp2 : String;
  bDot : boolean;
begin
  sl := length(sDateStr);
  sTmp2:='';
  bDot := false;
  for j:=1 to sl do
    if sDateStr[j] in ['0'..'9'] then
    begin
      if bDot then
      begin
        sTmp2 := sTmp2 + '-';
        bDot := false;
      end;
      sTmp2 := sTmp2 + sDateStr[j];
    end else if sTmp2<>'' then
      bDot := true;
  result := sTmp2;
end;

class	function TCommonFunc.IsDate(const sDateStr:String):boolean;
var
  j,sl:Integer;
  sTmp : String;
  nP : integer;
begin
  sl := length(sDateStr);
  result := false;
  if(sl<8) then Exit;

  nP := 0;
  for j:=1 to sl do
  begin
    if sDateStr[j] = '-' then
    begin
      if nP=0 then
      begin
        if j<>5 then Exit;
      end else
      if nP=1 then
      begin
        if (j<7) or (j>=sl) then Exit;
        sTmp := Copy(sDateStr,6,j-6);
        if (StrToInt(sTmp) > 12) or (StrToInt(sTmp) < 0) then
          Exit;
        sTmp := Copy(sDateStr,j+1,sl-j);
        if (StrToInt(sTmp) > 31) or (StrToInt(sTmp) < 0) then
          Exit;
        result := true;
        Exit;
      end;
      Inc(nP);
    end;
  end;
end;

class function TCommonFunc.GetAWord(const strSource:String;var startPos:integer;
                                      bXPath:boolean=false;bEraseQM:boolean=true):String;
var
  sl,bp,cl :Integer;
  //sRes : String;
begin
  sl := length(strSource);
	while((startPos <= sl ) and ((strSource[startPos] = ' ')
                            or (strSource[startPos] = chr(9))
                            or (strSource[startPos] = chr(10))
                            or (strSource[startPos] = chr(13)) )) do Inc(startPos);
	bp := startPos;
	if(startPos > sl) then
  begin
    result :='';
    Exit;
  end;

	if( ((strSource[startPos]>='0') and (strSource[startPos]<='9'))
        or (strSource[startPos]= '.') 
		  //or ( (strSource[startPos]= '-') or (strSource[startPos]= '+' ) )
      ) then
  begin
		Inc(startPos);

		while ( (startPos <= sl)  and (
				( (strSource[startPos]>='0') and (strSource[startPos]<='9') ) or
				( (strSource[startPos]>='a') and (strSource[startPos]<='z') ) or
				( (strSource[startPos]>='A') and (strSource[startPos]<='Z') ) or
				  (strSource[startPos]='.') )
				  ) do Inc(startPos);
		//bAcceptOpt = true;
	end else if (( (strSource[startPos]>='a') and (strSource[startPos]<='z')) or
			      	((strSource[startPos]>='A') and (strSource[startPos]<='Z')) or
				      (strSource[startPos]='_')  or
              ( bXPath and ( (strSource[startPos]='/') or (strSource[startPos]='@') )) ) then
  begin
		Inc(startPos);
		while ( (startPos <= sl)  and
              (
				        ( (strSource[startPos]>='0') and (strSource[startPos]<='9')) or
				        ( (strSource[startPos]>='a') and (strSource[startPos]<='z')) or
				        ( (strSource[startPos]>='A') and (strSource[startPos]<='Z')) or
				        ( strSource[startPos]='_') or
                ( bXPath and ( (strSource[startPos]='/') or (strSource[startPos]='@') )) 
              )
				  ) do Inc(startPos);
//		bAcceptOpt = true;
	end else
  begin
		//bAcceptOpt = false;
		case(strSource[startPos]) of
		'<':
    begin
			Inc(startPos);
			if (startPos<=sl) and ((strSource[startPos] = '=') or (strSource[startPos] = '>')) then Inc(startPos);
    end;
		'>',
		'=',
		'!':
    begin
			Inc(startPos);
			if((startPos<=sl) and (strSource[startPos] = '=')) then Inc(startPos);
    end;
		'|':
    begin
			Inc(startPos);
			if((startPos<=sl) and (strSource[startPos] = '|')) then Inc(startPos);
    end;
		'&':
    begin
			Inc(startPos);
			if((startPos<=sl) and (strSource[startPos] = '&')) then Inc(startPos);
    end;
		'"':
    begin
			Inc(startPos);
			while (startPos <= sl) and (strSource[startPos] <> '"') do Inc(startPos);
			if(startPos <= sl) then Inc(startPos);
			//bAcceptOpt = true;
    end;
		'''':
    begin
			Inc(startPos);
			while(startPos <= sl) and (strSource[startPos] <> '''') do Inc(startPos);
			if(startPos <= sl) then Inc(startPos);
			//bAcceptOpt = true;
    end;
		')':
			//bAcceptOpt = true;
			Inc(startPos);
		else //"+-*/"
			Inc(startPos);
		end;
	end;

	cl := startPos-bp;
  if cl>0 then
  begin
    if bEraseQM and (cl>3)  and (strSource[bp] = strSource[bp+cl-1]) and
        (  (strSource[bp] ='''') or (strSource[bp] ='"') ) then
      result := Copy(strSource,bp+1,cl-2)
    else
      result := Copy(strSource,bp,cl);
  end else
    result := '';
end;

class	function TCommonFunc.NextCode(const sCode:String):String;
var
  i,nSL:Integer;
  sRes : String;
begin
  nSL := length(sCode);
  sRes := sCode;
  for i:= nSL downto 1 do
  begin
    if sRes[i] in ['0'..'8','A'..'Y','a'..'Y'] then
    begin
      //sRes[i] := chr(ord(sRes[i])+1);
      Inc(sRes[i]);
      break;
    end;
    if sRes[i]='9' then sRes[i]:='0';
    if sRes[i]='Z' then sRes[i]:='A';
    if sRes[i]='z' then sRes[i]:='a';
  end;
  result :=sRes;
end;

class	function TCommonFunc.NextCodeEx(const sCode:String):String;
var
  i,nSL:Integer;
  sRes : String;
begin
  nSL := length(sCode);
  sRes := sCode;
  for i:= nSL downto 1 do
  begin
    if sRes[i] in ['0'..'8','A'..'Y','a'..'Y'] then
    begin
      //代码的最后两位不能有 4 //高淳的需求
      Inc(sRes[i]);
      if (sRes[i] = '4') and (i>nSL-2) then
        sRes[i]:='5';
      break;
    end;
    if sRes[i]='9' then sRes[i]:='0';
    if sRes[i]='Z' then sRes[i]:='A';
    if sRes[i]='z' then sRes[i]:='a';
  end;
  result :=sRes;
end;

class	function TCommonFunc.FormatTableField(const sTableField:String):String;//Multi Table
var
  sRes : String;
  bMultiTable:boolean;
begin
  bMultiTable := Pos(',',sTableField)>0;
  if bMultiTable then
  begin
    sRes := StringReplace(sTableField, ',',''',''', [rfReplaceAll]);
    sRes := 'in ('''+sRes+''')';
  end else
    sRes := '='''+sTableField+'''';
  result := sRes;
end;

class function TCommonFunc.SplitString(const sValue:String;const sSplitStr:String;var sStrs:TStrings) : integer;
var
  nPos,sL,sSubL,nStr:Integer;
  sTemp,sWord:String;
begin
  sTemp := sValue;
  sL := length(sValue);
  sSubL := length(sSplitStr);
  nStr := 0;
  nPos := pos(sSplitStr,sTemp);
  while nPos > 0 do
  begin
    if nPos>1 then
    begin
      sWord := Copy (sTemp,1,nPos-1);
      sStrs.Add(sWord);
      Inc(nStr);
    end;
    if sL-nPos < sSubL then
    begin
      sTemp := '';
      nPos := 0;
    end else
    begin
      sTemp := Copy(sTemp,nPos+sSubL,sL-nPos-sSubL+1);
      nPos := pos(sSplitStr,sTemp);
    end;
  end;
  if sTemp<>'' then
  begin
    sStrs.Add(sTemp);
    Inc(nStr);
  end;
  result := nStr;
end;

class function TCommonFunc.SplitFilePath(const sFilePath:String;var sDirectory:String;var sFileName:String;var sFileExt:String) : boolean;
var
  nPos,sL,dotPos:Integer;
begin
  sL := length(sFilePath);
  nPos := sL;
  result := true;
  while (nPos > 0) and (sFilePath[nPos]<>'.') do
    Dec(nPos);
  sFileExt :=  Copy(sFilePath,nPos+1,sL-nPos);
  dotPos :=  nPos;
  if nPos=0 then
    result := false;
  while (nPos > 0) and (sFilePath[nPos]<>'\') and (sFilePath[nPos]<>'/') do
    Dec(nPos);
  sFileName :=  Copy(sFilePath,nPos+1,dotPos-nPos-1);
  if nPos=0 then
    result := false;
  sDirectory :=  Copy(sFilePath,1,nPos-1);
end;

class function TCommonFunc.GetPYIndex(const szHanzi:string):char;
begin
  case WORD(szHanzi[1]) shl 8 + WORD(szHanzi[2]) of
    $B0A1..$B0C4 : result := 'A';
    $B0C5..$B2C0 : result := 'B';
    $B2C1..$B4ED : result := 'C';
    $B4EE..$B6E9 : result := 'D';
    $B6EA..$B7A1 : result := 'E';
    $B7A2..$B8C0 : result := 'F';
    $B8C1..$B9FD : result := 'G';
    $B9FE..$BBF6 : result := 'H';
    $BBF7..$BFA5 : result := 'J';
    $BFA6..$C0AB : result := 'K';
    $C0AC..$C2E7 : result := 'L';
    $C2E8..$C4C2 : result := 'M';
    $C4C3..$C5B5 : result := 'N';
    $C5B6..$C5BD : result := 'O';
    $C5BE..$C6D9 : result := 'P';
    $C6DA..$C8BA : result := 'Q';
    $C8BB..$C8F5 : result := 'R';
    $C8F6..$CBF9 : result := 'S';
    $CBFA..$CDD9 : result := 'T';
    $CDDA..$CEF3 : result := 'W';
    $CEF4..$D1B8 : result := 'X';
    $D1B9..$D4D0 : result := 'Y';
    $D4D1..$D7F9 : result := 'Z';
  else
    result := '-';//szHanzi[1];
  end;
end;

class function TCommonFunc.GetPYABIndex(const szHanzi:string):string;
var
  i, sl:integer;
  strRes : string;
  wdCharInd : WORD;
  hzWord : string;
begin
	sl := length(szHanzi);
	strRes := '';
  hzWord := '123';
  i:=1;
	while i <= sl do
  begin
		wdCharInd := WORD(szHanzi[i]);
		if wdCharInd < 128 then
    begin
			strRes := strRes + szHanzi[i];
			Inc(i);
		end else
    begin
      hzWord[1] := szHanzi[i];
      hzWord[2] := szHanzi[i+1];
			strRes := strRes + GetPYIndex(hzWord);
			i := i + 2;
		end;
	end;
	result := UpperCase(strRes);
end;

class function TCommonFunc.GetSpaceString(nCount: integer): string;
var
  i:integer;
  sResult:string ;
begin
  sResult:='';
  for i:=1 to nCount do
  begin
    sResult:=sResult+' ';
  end;
  Result:=sResult;
end;

class function TCommonFunc.GetZeroString(nCount: integer): string;
var
  i:integer;
  sResult:string;
begin
  sResult:='';
  for i:=1 to nCount do
  begin
    sResult:=sResult+'0';
  end;
  Result:=sResult;
end;

class function TCommonFunc.DataValueToString(sDataValue: string;
  nLength: integer): string;
var
  str:string;
  nCount:integer;
begin
  str:=trim(sDataValue);
  nCount:=Length(str);
  if nCount < nLength then
    Result:=str+GetSpaceString(nLength-length(str))
  else if nCount > nLength then
    Result:=copy(str,1,nLength)
  else
    Result := str;
end;

class function TCommonFunc.DataValueToString(nDataValue,
  nLength: integer): string;
var
  str:string;
  strLen : integer;
begin
  str:=trim(IntToStr(nDataValue));
  strLen := Length(str);
  if strLen<=nLength then
  begin
    Result:=str+GetSpaceString(nLength-strLen);
  end
  else
    Result:=copy(str,1,nLength);
end;

class function TCommonFunc.DataValueToString(dDataValue: double;
  nLength: integer): string;
var
  str:string;
  strLen,nInt,nFrac : integer;
  bNegative : boolean;
begin
  bNegative := dDataValue < 0;
  if bNegative then
    nInt := Round( dDataValue * -1000.0)
  else
    nInt := Round( dDataValue * 1000.0);
  nFrac := nInt mod 1000;
  nInt := nInt div 1000;
  str := '0000'+ IntToStr(nFrac);
  if bNegative then
    str := '-'+IntToStr(nInt)+'.'+Copy(str,length(str)-2,3)
  else
    str := IntToStr(nInt)+'.'+Copy(str,length(str)-2,3);

  strLen := Length(str);
  if strLen<=nLength then
  begin
    Result:=str+GetSpaceString(nLength-strLen);
  end
  else
    Result:=copy(str,1,nLength);
end;


/// TSQLPrm

class function TSQLPrm.IntToPrm(const nPrm:integer):TStrings;
begin
  result := TStringList.Create;
  result.Add(IntToStr(nPrm));
end;
class function TSQLPrm.FloatToPrm(const fPrm:real):TStrings;
begin
  result := TStringList.Create;
  result.Add(FloatToStr(fPrm));
end;
class function TSQLPrm.DateToPrm(const dtDate:TDateTime):TStrings;
begin
  result := TStringList.Create;
  result.Add(FormatDatetime('yyyy-mm-dd',dtDate));
end;
class function TSQLPrm.StrToPrm(const sPrm:String):TStrings;
begin
  result := TStringList.Create;
  result.Add(sPrm);
end;
class function TSQLPrm.StrToPrm(const sPrm,sPrm2:String):TStrings;
begin
  result := TStringList.Create;
  result.Add(sPrm);
  result.Add(sPrm2);
end;
class function TSQLPrm.StrToPrm(const sPrm,sPrm2,sPrm3:String):TStrings;
begin
  result := TStringList.Create;
  result.Add(sPrm);
  result.Add(sPrm2);
  result.Add(sPrm3);
end;
class function TSQLPrm.StrToPrm(const sPrm,sPrm2,sPrm3,sPrm4:String):TStrings;
begin
  result := TStringList.Create;
  result.Add(sPrm);
  result.Add(sPrm2);
  result.Add(sPrm3);
  result.Add(sPrm4);
end;
class function TSQLPrm.StrToPrm(const sPrm,sPrm2,sPrm3,sPrm4,sprm5:String):TStrings;
begin
  result := TStringList.Create;
  result.Add(sPrm);
  result.Add(sPrm2);
  result.Add(sPrm3);
  result.Add(sPrm4);
  result.Add(sPrm5);
end;

class function TSQLPrm.StrToPrm(const sPrm,sPrm2,sPrm3,sPrm4,sprm5,sprm6:String):TStrings;
begin
  result := TStringList.Create;
  result.Add(sPrm);
  result.Add(sPrm2);
  result.Add(sPrm3);
  result.Add(sPrm4);
  result.Add(sPrm5);
  result.Add(sPrm6);
end;

class function TSQLPrm.StrToPrm(const sPrm,sPrm2,sPrm3,sPrm4,sprm5,sprm6,sprm7:String):TStrings;
begin
  result := TStringList.Create;
  result.Add(sPrm);
  result.Add(sPrm2);
  result.Add(sPrm3);
  result.Add(sPrm4);
  result.Add(sPrm5);
  result.Add(sPrm6);
  result.Add(sPrm7);
end;

class function TSQLPrm.StrToPrm(const sPrm,sPrm2,sPrm3,sPrm4,sprm5,sprm6,sprm7,sPrm8:String):TStrings;
begin
  result := TStringList.Create;
  result.Add(sPrm);
  result.Add(sPrm2);
  result.Add(sPrm3);
  result.Add(sPrm4);
  result.Add(sPrm5);
  result.Add(sPrm6);
  result.Add(sPrm7);
  result.Add(sPrm8);
end;


class function TSQLPrm.StrToPrm(const sPrm,sPrm2,sPrm3,sPrm4,sprm5,sprm6,sprm7,sPrm8,sprm9:String):TStrings;
begin
  result := TStringList.Create;
  result.Add(sPrm);
  result.Add(sPrm2);
  result.Add(sPrm3);
  result.Add(sPrm4);
  result.Add(sPrm5);
  result.Add(sPrm6);
  result.Add(sPrm7);
  result.Add(sPrm8);
  result.Add(sPrm9);
end;

class function TSQLPrm.IntToVaiant(const nPrm:integer;const VAL:integer=1):OleVariant;
begin
  result := VarArrayCreate([0, VAL], varVariant);
  result[0] := nPrm;
end;

class function TSQLPrm.FloatToVaiant(const fPrm:real;const VAL:integer=1):OleVariant;
begin
  result := VarArrayCreate([0, VAL], varVariant);
  result[0] := fPrm;
end;

class function TSQLPrm.StrToVaiant(const sPrm:String;const VAL:integer=1):OleVariant;
begin
  result := VarArrayCreate([0, VAL], varVariant);
  result[0] := sPrm;
end;

{ TBillFunc }


//只舍不进
class function TCommonFunc.DataToStr(fromData: real;
  DotDigit: integer): string;
var
  temp : string;
  nPos : integer;
 // i:integer;
begin
  if DotDigit=0 then
   result := IntToStr(Round(fromData))
  else
    begin
      temp := FloatToStr(fromData);
      nPos := Pos('.',temp);
      if nPos>0 then
      begin
        if Length(temp)-nPos>DotDigit then
        begin
          temp := Copy(temp,1,npos+DotDigit);
        end;
      end;
      FmtStr(temp,'%.'+IntToStr(DotDigit)+'f',[strtofloat(temp)]);
      result := temp;
    end;

end;

class function TCommonFunc.InnerMatch(const sCheckType,sInputBankAccounts,sFormatBankAccounts: string): Boolean;
var
  bRes:Boolean;
  sBankAcc,sFormatBankAcc:string;
begin
   if sCheckType='1' then/// 银行格式匹配
   begin
     sBankAcc:=copy(sInputBankAccounts,1,6);
     sFormatBankAcc:=copy(sFormatBankAccounts,1,6);
   end else
   if sCheckType='2' then /// 营行网点匹配
   begin
     sBankAcc:=copy(sInputBankAccounts,7,2);
     sFormatBankAcc:=copy(sFormatBankAccounts,7,2);
   end;
   if sBankAcc<>sFormatBankAcc then
     bRes:=false
   else
     bRes:=true;
   Result:=bRes;  
end;

class procedure TCommonFunc.WriteLogEx(sLogName, s: String; bNewLine,
  bShowTime: boolean);
var
  sTime:String;
  tfFile: textFile;
begin

  if FileExists(sLogName) then  // '.\login.log'
  begin
    AssignFile(tfFile, sLogName); //  '.\login.log'
    Append(tfFile);
  end else
  begin
    AssignFile(tfFile,sLogName);  // '.\login.log'
    Rewrite(tfFile);
  end;
  if bShowTime then
  begin
    sTime := FormatDatetime('hh:nn:ss :',Now);
    write( sTime );
    write(tfFile,sTime);
  end;
  if bNewLine then
  begin
    writeln(tfFile,s);
    writeln( s );
  end else
  begin
    write(tfFile,s);
    write( s );
  end;
  CloseFile(tfFile);
end;

class procedure TCommonFunc.WriteLog(sLogName, s: String; bNewLine,
  bShowTime: boolean);
var
  sTime,sLogPath:String;
  tfFile: textFile;
begin
  sLogPath:=ExtractFilePath(Application.ExeName) + 'logs\';
  if not DirectoryExists(sLogPath) then createdir(sLogPath);
  if FileExists(sLogPath + sLogName) then  // '.\login.log'
  begin
    AssignFile(tfFile,sLogPath + sLogName); //  '.\login.log'
    Append(tfFile);
  end else
  begin
    AssignFile(tfFile,sLogPath + sLogName);  // '.\login.log'
    Rewrite(tfFile);
  end;
  if bShowTime then
  begin
    sTime := FormatDatetime('hh:nn:ss :',Now);
    write(tfFile,sTime);
  end;
  if bNewLine then
    writeln(tfFile,s)
  else
    write(tfFile,s);
  CloseFile(tfFile);
end;

class function TCommonFunc.FloatCompare(fDataSource, fDatadest: double;
  DotDigit: integer): integer;
begin
  if RoundTo((fDataSource-fDatadest),-DotDigit)>0 then
    Result:=1//大于
  else if RoundTo((fDataSource-fDatadest),-DotDigit)<0 then
    Result:=2//小于
  else
    Result:=0;//等于
end;

class function TCommonFunc.intvaluetostring(nDataValue,
  nLength: integer): string;
var
  str:string;
  strLen : integer;
begin
  str:=trim(IntToStr(nDataValue));
  strLen := Length(str);
  if strLen<=nLength then
  begin
    Result:=GetzeroString(nLength-strLen)+str;
  end
  else
    Result:=copy(str,1,nLength);
end;

class function TCommonFunc.DataValueToString(nDataValue: int64;
  nLength: integer): string;
var
  str:string;
  strLen : integer;
begin
  str:=trim(IntToStr(nDataValue));
  strLen := Length(str);
  if strLen<=nLength then
  begin
    Result:=str+GetSpaceString(nLength-strLen);
  end
  else
    Result:=copy(str,1,nLength);
end;

class function TCommonFunc.GetMatchString(sMatch:String):string;
var
  sRes:String;
  i,sL:integer;
  preChar,curChar:Char;
begin
  sRes :='%'; preChar := '%';
  sL := length(sMatch);
  for i:=1 to sL do
  begin
    curChar := sMatch[i];
    if (curChar=' ') or (curChar=#9) then
    begin
       curChar := '%';
       if preChar <> '%' then
          sRes := sRes+curChar;
    end else
    begin
      sRes := sRes+curChar;
    end;
    preChar := curChar;
  end;
  if preChar <> '%' then
    sRes := sRes+'%';
  result := sRes;
end;

end.
