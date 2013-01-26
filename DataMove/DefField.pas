unit DefField;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls;

type
  TfrDefField = class(TForm)
    ledDestFieldName: TLabeledEdit;
    ledDestFieldType: TLabeledEdit;
    ledDefaultValue: TLabeledEdit;
    ledSouFieldName: TLabeledEdit;
    ledSouFieldType: TLabeledEdit;
    ledSouFieldDesc: TLabeledEdit;
    btnCancel: TBitBtn;
    btnOK: TBitBtn;
    optHint: TLabel;
    procedure btnOKClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    m_SouFieldName,
    m_SouFieldDesc,
    m_SouFieldType,
    m_DestFieldName,
    m_DestFieldType,
    m_DefaultValue :String;

    m_bEditDest : Boolean;
  end;

var
  frDefField: TfrDefField;

implementation

{$R *.dfm}
uses CommonFunc;

procedure TfrDefField.FormCreate(Sender: TObject);
begin
  m_bEditDest := false;
end;

procedure TfrDefField.FormShow(Sender: TObject);
begin
  ledSouFieldName.Text := m_SouFieldName;
  ledSouFieldType.Text := m_SouFieldType;
  ledSouFieldDesc.Text := m_SouFieldDesc;
  ledDestFieldName.Text := m_DestFieldName;
  ledDestFieldType.Text := m_DestFieldType;
  ledDefaultValue.Text := m_DefaultValue;

  if m_bEditDest then
  begin
    ledDestFieldName.ReadOnly := false;
    ledDestFieldType.ReadOnly := false;
    ledDestFieldName.Color := clInfoBk;//clWindow;
    ledDestFieldType.Color := clInfoBk;//clWindow;
  end else
  begin
    ledDestFieldName.ReadOnly := true;
    ledDestFieldType.ReadOnly := true;
    ledDestFieldName.Color := clInfoBk;
    ledDestFieldType.Color := clInfoBk;
  end;
end;

procedure TfrDefField.btnOKClick(Sender: TObject);
var
  nPos,nComma,nLeftBracket:Integer;
  sWord,sLastWord : String;
begin
  m_SouFieldName := trim(ledSouFieldName.Text);
  m_SouFieldType := trim(ledSouFieldType.Text);
  m_SouFieldDesc := trim(ledSouFieldDesc.Text);
  m_DestFieldName := trim(ledDestFieldName.Text);
  m_DestFieldType := trim(ledDestFieldType.Text);
  m_DefaultValue := trim(ledDefaultValue.Text);

  nPos := 1;
  nComma := 0;
  nLeftBracket := 0;

  if (m_SouFieldName = '') and (m_SouFieldDesc <> '') then
  begin
    ShowMessage('请输入源字段名。');
    exit;
  end;

  if (m_SouFieldName <> '') and (m_SouFieldDesc = '') then
  begin
    ShowMessage('请输入源字段描述。');
    exit;
  end;

  if m_bEditDest then
  begin
    if (m_DestFieldName = '') and (m_DestFieldType <> '') then
    begin
      ShowMessage('请输入目标字段名。');
      exit;
    end;
    if (m_DestFieldName <> '') and (m_DestFieldType = '') then
    begin
      ShowMessage('请输入目标字段类型。');
      exit;
    end;
  end;

  if (m_SouFieldName <> '') and (m_SouFieldDesc <> '') then
  begin
    sWord := TCommonFunc.GetAWord(m_SouFieldDesc,nPos,false,false);
    while ( sWord <> '') do
    begin
      sLastWord := sWord;
      if (nLeftBracket = 0) and (sWord=',') then
        nComma := nComma+1;

      if (nLeftBracket>=0) and ( sWord = '(') then Inc(nLeftBracket)
      else if( sWord = ')') then Dec(nLeftBracket);

      sWord := TCommonFunc.GetAWord(m_SouFieldDesc,nPos,false,false);
    end;
    if (nLeftBracket<>0) or (nComma>0) then
    begin
      ShowMessage('字段描述不符合语法，请检查。');
      exit;
    end;

    if upperCase(sLastWord)<>upperCase(m_SouFieldName) then
    begin
      ledSouFieldDesc.Text:= m_SouFieldDesc+' as '+ m_SouFieldName;
      ShowMessage('字段描述和字段名不符，系统已经帮你更改。'#13#10'更正后的语句可能不符合语法，请检查。');
      exit;
    end;
  end;
  
  self.ModalResult := mrOK;
end;

end.
