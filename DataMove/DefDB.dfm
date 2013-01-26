object frDefDB: TfrDefDB
  Left = 475
  Top = 249
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = #25968#25454#24211#36830#25509#35774#32622
  ClientHeight = 351
  ClientWidth = 360
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lbDBtypeInSet: TLabel
    Left = 51
    Top = 22
    Width = 79
    Height = 18
    AutoSize = False
    Caption = #25968#25454#24211#31867#21035#65306' '
  end
  object lbDBConn: TLabel
    Left = 43
    Top = 195
    Width = 79
    Height = 22
    AutoSize = False
    Caption = #25968#25454#24211#25551#36848#65306
  end
  object cbDBType: TComboBox
    Left = 129
    Top = 17
    Width = 215
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 0
    OnChange = DBConfigChanged
    Items.Strings = (
      'SQL Server'
      'Oracle'
      'IBM DB2'
      'MSAccess')
  end
  object ledServerName: TLabeledEdit
    Left = 128
    Top = 47
    Width = 215
    Height = 21
    EditLabel.Width = 117
    EditLabel.Height = 13
    EditLabel.Caption = #26381#21153#22120#25110#32773#26381#21153#21517#65306'   '
    LabelPosition = lpLeft
    TabOrder = 1
    OnChange = DBConfigChanged
  end
  object ledDBName: TLabeledEdit
    Left = 128
    Top = 106
    Width = 215
    Height = 21
    EditLabel.Width = 60
    EditLabel.Height = 13
    EditLabel.Caption = #25968#25454#24211#21517#65306
    LabelPosition = lpLeft
    TabOrder = 2
    OnChange = DBConfigChanged
  end
  object ledUserName: TLabeledEdit
    Left = 128
    Top = 135
    Width = 215
    Height = 21
    EditLabel.Width = 48
    EditLabel.Height = 13
    EditLabel.Caption = #29992#25143#21517#65306
    LabelPosition = lpLeft
    TabOrder = 3
    OnChange = DBConfigChanged
  end
  object ledPassword: TLabeledEdit
    Left = 128
    Top = 165
    Width = 215
    Height = 21
    EditLabel.Width = 36
    EditLabel.Height = 13
    EditLabel.Caption = #23494#30721#65306
    LabelPosition = lpLeft
    TabOrder = 4
    OnChange = DBConfigChanged
  end
  object edDBConn: TMemo
    Left = 128
    Top = 192
    Width = 217
    Height = 113
    ReadOnly = True
    TabOrder = 5
  end
  object btnOK: TBitBtn
    Left = 176
    Top = 320
    Width = 75
    Height = 25
    Caption = #35774#32622
    Default = True
    TabOrder = 6
    OnClick = btnOKClick
  end
  object btnCancel: TBitBtn
    Left = 272
    Top = 320
    Width = 75
    Height = 25
    Caption = #21462#28040
    ModalResult = 2
    TabOrder = 7
  end
  object ledHostPort: TLabeledEdit
    Left = 128
    Top = 79
    Width = 215
    Height = 21
    EditLabel.Width = 63
    EditLabel.Height = 13
    EditLabel.Caption = #20027#26426':'#31471#21475#65306
    LabelPosition = lpLeft
    TabOrder = 8
    Text = '127.0.0.1:1521'
    OnChange = DBConfigChanged
  end
  object btnLoadMDBFile: TButton
    Left = 320
    Top = 104
    Width = 25
    Height = 25
    Caption = '...'
    TabOrder = 9
    Visible = False
    OnClick = btnLoadMDBFileClick
  end
  object loadAccess: TOpenDialog
    DefaultExt = 'mdb'
    Filter = 'Access'#25991#20214'|*.mdb|'#25152#26377#25991#20214'|*.*'
    Title = #25171#24320#39033#30446
    Left = 8
    Top = 8
  end
end
