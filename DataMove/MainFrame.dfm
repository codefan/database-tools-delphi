object frMainFrame: TfrMainFrame
  Left = 518
  Top = 190
  Width = 834
  Height = 542
  Caption = #25968#25454#36801#31227'-2013-1-6'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = muMain
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object panelTop: TPanel
    Left = 0
    Top = 0
    Width = 826
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    Ctl3D = True
    ParentCtl3D = False
    TabOrder = 0
    object ledLeftDB: TLabeledEdit
      Left = 80
      Top = 8
      Width = 257
      Height = 21
      EditLabel.Width = 63
      EditLabel.Height = 13
      EditLabel.Caption = #28304#25968#25454#24211#65306' '
      LabelPosition = lpLeft
      ReadOnly = True
      TabOrder = 0
    end
    object btnSetLeftDB: TBitBtn
      Left = 344
      Top = 6
      Width = 41
      Height = 25
      Caption = '...'
      TabOrder = 1
      OnClick = btnSetLeftDBClick
    end
    object ledRightDB: TLabeledEdit
      Left = 480
      Top = 8
      Width = 257
      Height = 21
      EditLabel.Width = 78
      EditLabel.Height = 13
      EditLabel.Caption = #30446#26631#25968#25454#24211#65306'  '
      LabelPosition = lpLeft
      ReadOnly = True
      TabOrder = 2
    end
    object btnSetRightDB: TBitBtn
      Left = 752
      Top = 6
      Width = 43
      Height = 25
      Caption = '...'
      TabOrder = 3
      OnClick = btnSetRightDBClick
    end
  end
  object panelBottom: TPanel
    Left = 0
    Top = 452
    Width = 826
    Height = 44
    Align = alBottom
    BevelOuter = bvNone
    Ctl3D = True
    ParentCtl3D = False
    TabOrder = 1
    object btnBuild: TBitBtn
      Left = 512
      Top = 8
      Width = 89
      Height = 25
      Caption = #29983#25104#33050#26412
      TabOrder = 0
      OnClick = muBuildClick
    end
    object btnExit: TBitBtn
      Left = 736
      Top = 8
      Width = 75
      Height = 25
      Caption = #36864#20986
      TabOrder = 1
      OnClick = muExitClick
    end
    object cbRunType: TComboBox
      Left = 376
      Top = 10
      Width = 129
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 2
      Text = #20165#29983#25104#33050#26412
      OnSelect = cbRunTypeSelect
      Items.Strings = (
        #20165#29983#25104#33050#26412
        #29992#33050#26412#36816#34892
        #29992#31243#24207#36816#34892)
    end
    object cbAutoMakeScript: TCheckBox
      Left = 616
      Top = 13
      Width = 113
      Height = 17
      Caption = #36864#20986#26102#29983#25104#33050#26412
      Checked = True
      State = cbChecked
      TabOrder = 3
    end
  end
  object pgMain: TPageControl
    Left = 0
    Top = 41
    Width = 826
    Height = 411
    ActivePage = tsMapInfo
    Align = alClient
    TabOrder = 2
    object tsMapInfo: TTabSheet
      Caption = #23545#24212#20851#31995
      object lvMapInfo: TListView
        Left = 0
        Top = 0
        Width = 818
        Height = 345
        Align = alClient
        Checkboxes = True
        Columns = <
          item
            Caption = #24207#21495
          end
          item
            Caption = #28304#25551#36848
            Width = 220
          end
          item
            Caption = #28304#31867#22411
            Width = 65
          end
          item
            Caption = #30446#26631#34920
            Width = 120
          end
          item
            Caption = #34920#25805#20316
            Width = 80
          end
          item
            Caption = #34892#25805#20316
            Width = 80
          end>
        GridLines = True
        HideSelection = False
        ReadOnly = True
        RowSelect = True
        TabOrder = 0
        ViewStyle = vsReport
        OnDblClick = muEditMapInfoClick
      end
      object plPage1Bottom: TPanel
        Left = 0
        Top = 345
        Width = 818
        Height = 38
        Align = alBottom
        BevelOuter = bvNone
        Ctl3D = True
        ParentCtl3D = False
        TabOrder = 1
        object btnNewMapInfo: TBitBtn
          Left = 536
          Top = 8
          Width = 75
          Height = 25
          Caption = #26032#24314
          TabOrder = 0
          OnClick = muNewMapInfoClick
        end
        object btnEditMapInfo: TBitBtn
          Left = 624
          Top = 8
          Width = 75
          Height = 25
          Caption = #32534#36753
          TabOrder = 1
          OnClick = muEditMapInfoClick
        end
        object btnDeleteMapInfo: TBitBtn
          Left = 712
          Top = 8
          Width = 75
          Height = 25
          Caption = #21024#38500
          TabOrder = 2
          OnClick = muDeleteMapInfoClick
        end
        object btnMoveTop: TBitBtn
          Left = 94
          Top = 9
          Width = 33
          Height = 25
          Hint = #32622#39030
          Caption = 'T'
          TabOrder = 3
          OnClick = btnMoveTopClick
        end
        object btnMoveUp: TBitBtn
          Left = 134
          Top = 9
          Width = 33
          Height = 25
          Hint = #19978#31227
          Caption = #8743
          TabOrder = 4
          OnClick = btnMoveUpClick
        end
        object btnMoveDown: TBitBtn
          Left = 174
          Top = 9
          Width = 33
          Height = 25
          Hint = #19979#31227
          Caption = #8744
          TabOrder = 5
          OnClick = btnMoveDownClick
        end
        object btnMoveBottom: TBitBtn
          Left = 214
          Top = 9
          Width = 33
          Height = 25
          Hint = #32622#24213' '
          Caption = #8869
          TabOrder = 6
          OnClick = btnMoveBottomClick
        end
      end
    end
    object tsPretreatment: TTabSheet
      Caption = #36801#31227#21069#21518#22788#29702
      ImageIndex = 1
      object panel2Bottom: TPanel
        Left = 0
        Top = 144
        Width = 818
        Height = 239
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 0
        object panel2BottomTop: TPanel
          Left = 0
          Top = 0
          Width = 818
          Height = 41
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 0
          object lbLeftAfterExport: TLabel
            Left = 8
            Top = 16
            Width = 137
            Height = 17
            AutoSize = False
            Caption = #23548#20986#21518#22788#29702
          end
          object lbRightAfterImport: TLabel
            Left = 432
            Top = 16
            Width = 137
            Height = 17
            AutoSize = False
            Caption = #23548#20837#21518#22788#29702
          end
        end
        object edLeftAfterExport: TMemo
          Left = 0
          Top = 41
          Width = 433
          Height = 198
          Align = alLeft
          ScrollBars = ssBoth
          TabOrder = 1
        end
        object edRightAfterImport: TMemo
          Left = 433
          Top = 41
          Width = 385
          Height = 198
          Align = alClient
          ScrollBars = ssBoth
          TabOrder = 2
        end
      end
      object panel2Top: TPanel
        Left = 0
        Top = 0
        Width = 818
        Height = 41
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 1
        object lbLeftBeforeExport: TLabel
          Left = 8
          Top = 16
          Width = 137
          Height = 17
          AutoSize = False
          Caption = #23548#20986#21069#22788#29702
        end
        object lbRightBeforeImport: TLabel
          Left = 432
          Top = 16
          Width = 137
          Height = 17
          AutoSize = False
          Caption = #23548#20837#21069#22788#29702
        end
      end
      object edLeftBeforeExport: TMemo
        Left = 0
        Top = 41
        Width = 433
        Height = 103
        Align = alLeft
        ScrollBars = ssBoth
        TabOrder = 2
      end
      object edRightBeforeImport: TMemo
        Left = 433
        Top = 41
        Width = 385
        Height = 103
        Align = alClient
        ScrollBars = ssBoth
        TabOrder = 3
      end
    end
  end
  object muMain: TMainMenu
    Left = 16
    Top = 448
    object muFile: TMenuItem
      Caption = #25991#20214'(&F)'
      object muNew: TMenuItem
        Caption = #26032#24314'/'#25171#24320'(&N)'
        ShortCut = 16462
        OnClick = muNewClick
      end
      object muExit: TMenuItem
        Caption = #36864#20986'(&X)'
        OnClick = muExitClick
      end
    end
    object muEdit: TMenuItem
      Caption = #32534#36753'(&E)'
      object muNewMapInfo: TMenuItem
        Caption = #26032#24314#26144#23556'(&A)'
        ShortCut = 16472
        OnClick = muNewMapInfoClick
      end
      object muEditMapInfo: TMenuItem
        Caption = #32534#36753#26144#23556'(&K)'
        ShortCut = 16459
        OnClick = muEditMapInfoClick
      end
      object muDeleteMapInfo: TMenuItem
        Caption = #21024#38500#26144#23556'(%D)'
        ShortCut = 16430
        OnClick = muDeleteMapInfoClick
      end
      object muEditSplit: TMenuItem
        Caption = '-'
      end
      object muBuild: TMenuItem
        Caption = #29983#25104#33050#26412'(&R)'
        ShortCut = 16466
        OnClick = muBuildClick
      end
    end
    object muHelp: TMenuItem
      Caption = #24110#21161'(&H)'
      object muAbout: TMenuItem
        Caption = #20851#20110'(&A)'
        OnClick = muAboutClick
      end
    end
  end
end
