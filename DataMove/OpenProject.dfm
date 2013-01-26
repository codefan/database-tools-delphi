object frOpenProject: TfrOpenProject
  Left = 529
  Top = 207
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = #26032#24314'/'#25171#24320#39033#30446
  ClientHeight = 345
  ClientWidth = 497
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lbDBClickList: TLabel
    Left = 16
    Top = 109
    Width = 129
    Height = 13
    AutoSize = False
    Caption = #21452#20987#21015#34920#25171#24320#21382#21490#39033#30446
  end
  object rbtnNew: TRadioButton
    Left = 128
    Top = 16
    Width = 113
    Height = 17
    Caption = #26032#24314
    Checked = True
    TabOrder = 0
    TabStop = True
    OnClick = rbtnNewClick
  end
  object rbtnOpen: TRadioButton
    Left = 304
    Top = 16
    Width = 113
    Height = 17
    Caption = #25171#24320#29616#26377#39033#30446
    TabOrder = 1
    OnClick = rbtnOpenClick
  end
  object ledProjectWorkPath: TLabeledEdit
    Left = 80
    Top = 48
    Width = 409
    Height = 21
    EditLabel.Width = 63
    EditLabel.Height = 13
    EditLabel.Caption = #39033#30446#36335#24452#65306' '
    LabelPosition = lpLeft
    ReadOnly = True
    TabOrder = 2
  end
  object btnSetProjectPath: TBitBtn
    Left = 296
    Top = 78
    Width = 97
    Height = 25
    Caption = #35774#32622#39033#30446#36335#24452
    TabOrder = 3
    OnClick = btnSetProjectPathClick
  end
  object ledProjectName: TLabeledEdit
    Left = 80
    Top = 80
    Width = 201
    Height = 21
    EditLabel.Width = 63
    EditLabel.Height = 13
    EditLabel.Caption = #39033#30446#21517#31216#65306' '
    LabelPosition = lpLeft
    ReadOnly = True
    TabOrder = 4
  end
  object btnOpenProject: TBitBtn
    Left = 296
    Top = 78
    Width = 97
    Height = 25
    Caption = #25171#24320#29616#26377#39033#30446
    TabOrder = 5
    OnClick = btnOpenProjectClick
  end
  object btnOK: TBitBtn
    Left = 408
    Top = 78
    Width = 81
    Height = 25
    Caption = #30830#23450
    TabOrder = 6
    OnClick = btnOKClick
  end
  object lvHistoryPorject: TListView
    Left = 16
    Top = 128
    Width = 473
    Height = 209
    Columns = <
      item
        Caption = #24207#21495
      end
      item
        Caption = #39033#30446#36335#24452
        Width = 400
      end>
    GridLines = True
    HideSelection = False
    ReadOnly = True
    RowSelect = True
    TabOrder = 7
    ViewStyle = vsReport
    OnDblClick = lvHistoryPorjectDblClick
  end
  object OpenProject: TOpenDialog
    DefaultExt = 'proj'
    Filter = #25968#25454#36801#31227#39033#30446'|*.proj'
    Title = #25171#24320#39033#30446
    Left = 40
    Top = 8
  end
  object SaveProject: TSaveDialog
    DefaultExt = 'proj'
    Filter = #25968#25454#36801#31227#39033#30446'|*.proj|'#25152#26377#25991#20214'|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Title = #26032#24314#39033#30446
    Left = 8
    Top = 8
  end
end
