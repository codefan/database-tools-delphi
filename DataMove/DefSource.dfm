object frDefSource: TfrDefSource
  Left = 627
  Top = 246
  Width = 631
  Height = 494
  Caption = #25968#25454#28304#23450#20041
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
  object edQuery: TMemo
    Left = 0
    Top = 121
    Width = 623
    Height = 304
    Align = alClient
    TabOrder = 0
  end
  object plTop: TPanel
    Left = 0
    Top = 0
    Width = 623
    Height = 121
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object lbSourceDesc: TLabel
      Left = 4
      Top = 100
      Width = 60
      Height = 13
      Caption = #26597#35810#35821#21477#65306
    end
    object ledDBConn: TLabeledEdit
      Left = 80
      Top = 16
      Width = 521
      Height = 21
      EditLabel.Width = 75
      EditLabel.Height = 13
      EditLabel.Caption = #25968#25454#24211#36830#25509#65306' '
      LabelPosition = lpLeft
      ReadOnly = True
      TabOrder = 0
    end
    object ledSourceName: TLabeledEdit
      Left = 80
      Top = 72
      Width = 297
      Height = 21
      EditLabel.Width = 74
      EditLabel.Height = 13
      EditLabel.Caption = #21517#31216'/'#34920#21517#65306'   '
      LabelPosition = lpLeft
      TabOrder = 1
    end
    object cbDateToChar: TCheckBox
      Left = 336
      Top = 48
      Width = 145
      Height = 17
      Caption = #23558#26085#26399#36716#25442#20026#23383#31526#20018
      TabOrder = 2
    end
    object rbtnQuery: TRadioButton
      Left = 488
      Top = 48
      Width = 89
      Height = 17
      Caption = #26597#35810
      TabOrder = 3
      OnClick = rbtnQueryClick
    end
    object rbntTabOrderByName: TRadioButton
      Left = 200
      Top = 48
      Width = 129
      Height = 17
      Caption = #34920','#23383#27573#23433#21517#31216#25490#24207
      TabOrder = 4
      OnClick = rbtnTableClick
    end
    object rbtnTable: TRadioButton
      Left = 80
      Top = 48
      Width = 113
      Height = 17
      Caption = #34920','#23383#27573#33258#28982#25490#24207
      Checked = True
      TabOrder = 5
      TabStop = True
      OnClick = rbtnTableClick
    end
    object cbSelectTab: TComboBox
      Left = 392
      Top = 72
      Width = 169
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 6
      OnSelect = cbSelectTabSelect
    end
    object btnRefreshTab: TButton
      Left = 568
      Top = 70
      Width = 33
      Height = 23
      Caption = #21047#26032
      TabOrder = 7
      OnClick = btnRefreshTabClick
    end
  end
  object plBottom: TPanel
    Left = 0
    Top = 425
    Width = 623
    Height = 42
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    object btnOK: TButton
      Left = 525
      Top = 10
      Width = 75
      Height = 25
      Caption = #30830#23450
      TabOrder = 0
      OnClick = btnOKClick
    end
  end
end
