object frDefField: TfrDefField
  Left = 711
  Top = 240
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = #23383#27573#23450#20041
  ClientHeight = 255
  ClientWidth = 577
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object optHint: TLabel
    Left = 8
    Top = 208
    Width = 305
    Height = 41
    AutoSize = False
    Caption = #24120#37327#20540#22914#26524#26159#23383#31526#20018#35831#29992' [ ] '#25324#36215#26469#65292#19981#35201#29992'""'#25110#32773#8216#8217#65292#13#22240#20026'ini'#37197#32622#25991#20214#35835#21462#26102#20250#33258#21160#21435#25481#24341#21495#12290
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object ledDestFieldName: TLabeledEdit
    Left = 104
    Top = 114
    Width = 457
    Height = 21
    EditLabel.Width = 75
    EditLabel.Height = 13
    EditLabel.Caption = #30446#26631#23383#27573#21517#65306' '
    LabelPosition = lpLeft
    TabOrder = 0
  end
  object ledDestFieldType: TLabeledEdit
    Left = 104
    Top = 147
    Width = 457
    Height = 21
    EditLabel.Width = 87
    EditLabel.Height = 13
    EditLabel.Caption = #30446#26631#23383#27573#31867#22411#65306' '
    LabelPosition = lpLeft
    TabOrder = 1
  end
  object ledDefaultValue: TLabeledEdit
    Left = 104
    Top = 178
    Width = 457
    Height = 21
    EditLabel.Width = 94
    EditLabel.Height = 26
    EditLabel.Caption = #24120#37327'('#20248#20808#32423#39640#13#20110#23545#24212#20851#31995')      '
    EditLabel.Font.Charset = DEFAULT_CHARSET
    EditLabel.Font.Color = clRed
    EditLabel.Font.Height = -11
    EditLabel.Font.Name = 'MS Sans Serif'
    EditLabel.Font.Style = [fsBold]
    EditLabel.ParentFont = False
    LabelPosition = lpLeft
    TabOrder = 2
  end
  object ledSouFieldName: TLabeledEdit
    Left = 104
    Top = 17
    Width = 457
    Height = 21
    EditLabel.Width = 63
    EditLabel.Height = 13
    EditLabel.Caption = #28304#23383#27573#21517#65306' '
    LabelPosition = lpLeft
    TabOrder = 3
  end
  object ledSouFieldType: TLabeledEdit
    Left = 104
    Top = 82
    Width = 457
    Height = 21
    EditLabel.Width = 75
    EditLabel.Height = 13
    EditLabel.Caption = #28304#23383#27573#31867#22411#65306' '
    LabelPosition = lpLeft
    TabOrder = 4
  end
  object ledSouFieldDesc: TLabeledEdit
    Left = 104
    Top = 50
    Width = 457
    Height = 21
    EditLabel.Width = 75
    EditLabel.Height = 13
    EditLabel.Caption = #28304#23383#27573#25551#36848#65306' '
    LabelPosition = lpLeft
    TabOrder = 5
  end
  object btnCancel: TBitBtn
    Left = 360
    Top = 215
    Width = 89
    Height = 26
    Caption = #21462#28040
    ModalResult = 2
    TabOrder = 6
  end
  object btnOK: TBitBtn
    Left = 467
    Top = 215
    Width = 89
    Height = 26
    Caption = #30830#23450
    TabOrder = 7
    OnClick = btnOKClick
  end
end
