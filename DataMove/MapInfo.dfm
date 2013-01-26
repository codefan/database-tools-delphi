object frMapInfo: TfrMapInfo
  Left = 422
  Top = 274
  Width = 863
  Height = 585
  Caption = #23545#24212#20851#31995
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
  object pgMain: TPageControl
    Left = 0
    Top = 0
    Width = 855
    Height = 517
    ActivePage = tsMapInfo
    Align = alClient
    TabOrder = 0
    OnChange = pgMainChange
    object tsMapInfo: TTabSheet
      Caption = #23545#24212#20851#31995
      object panelTop: TPanel
        Left = 0
        Top = 0
        Width = 847
        Height = 74
        Align = alTop
        BevelOuter = bvNone
        Ctl3D = True
        ParentCtl3D = False
        TabOrder = 0
        object ledSource: TLabeledEdit
          Left = 128
          Top = 8
          Width = 217
          Height = 21
          EditLabel.Width = 93
          EditLabel.Height = 13
          EditLabel.Caption = #24038'('#25968#25454#28304')'#23450#20041#65306' '
          LabelPosition = lpLeft
          TabOrder = 0
        end
        object btnDefSource: TBitBtn
          Left = 352
          Top = 6
          Width = 33
          Height = 25
          Caption = '...'
          TabOrder = 1
          OnClick = btnDefSourceClick
        end
        object ledDestination: TLabeledEdit
          Left = 128
          Top = 48
          Width = 217
          Height = 21
          EditLabel.Width = 108
          EditLabel.Height = 13
          EditLabel.Caption = #21491'('#25968#25454#30446#26631')'#23450#20041':     '
          LabelPosition = lpLeft
          TabOrder = 2
        end
        object btnDefDestination: TBitBtn
          Left = 352
          Top = 46
          Width = 33
          Height = 25
          Caption = '...'
          TabOrder = 3
          OnClick = btnDefDestinationClick
        end
        object tableOpt: TRadioGroup
          Left = 400
          Top = 0
          Width = 225
          Height = 73
          Caption = #34920#25805#20316
          ItemIndex = 0
          Items.Strings = (
            #19981#21019#24314#34920'(not create)'
            #26681#25454#38656#35201#21019#24314#34920'(craete if not exist)'
            #26367#25442#34920'(drop and create)')
          TabOrder = 4
        end
        object rowOpt: TRadioGroup
          Left = 640
          Top = 0
          Width = 121
          Height = 73
          Caption = #35760#24405#25805#20316
          ItemIndex = 0
          Items.Strings = (
            #25554#20837'(insert)'
            #26356#26032'(update)'
            #21512#24182'(merge)')
          TabOrder = 5
        end
        object cbRepeatRun: TCheckBox
          Left = 128
          Top = 30
          Width = 177
          Height = 17
          Caption = #37325#22797#36816#34892#25968#25454#28304
          TabOrder = 6
        end
      end
      object pcMapInfo: TPageControl
        Left = 0
        Top = 74
        Width = 847
        Height = 415
        ActivePage = TabSheet1
        Align = alClient
        TabOrder = 1
        object TabSheet1: TTabSheet
          Caption = #23545#24212#20851#31995
          object lvMapInfo: TListView
            Left = 0
            Top = 0
            Width = 839
            Height = 351
            Align = alClient
            Checkboxes = True
            Columns = <
              item
                Caption = 'Key'
              end
              item
                Caption = #28304#23383#27573#21517
                Width = 150
              end
              item
                Caption = #23383#27573#31867#22411
                Width = 120
              end
              item
                Caption = #30446#26631#23383#27573#21517
                Width = 150
              end
              item
                Caption = #23383#27573#31867#22411
                Width = 120
              end
              item
                Caption = #20801#35768#31354
              end
              item
                Caption = #24120#37327'('#39640#20248#20808#32423')'
                Width = 100
              end
              item
                Caption = 'SQL colorder'
                Width = 0
              end
              item
                Caption = 'fielde desc'
                Width = 0
              end>
            GridLines = True
            HideSelection = False
            ReadOnly = True
            RowSelect = True
            TabOrder = 0
            ViewStyle = vsReport
            OnDblClick = btnSetFieldInfoClick
            OnSelectItem = lvMapInfoSelectItem
          end
          object panelBottom: TPanel
            Left = 0
            Top = 351
            Width = 839
            Height = 36
            Align = alBottom
            BevelOuter = bvNone
            Ctl3D = True
            ParentCtl3D = False
            TabOrder = 1
            object btnSetFieldInfo: TBitBtn
              Left = 330
              Top = 6
              Width = 89
              Height = 25
              Caption = #32534#36753
              Enabled = False
              TabOrder = 0
              OnClick = btnSetFieldInfoClick
            end
            object btnSouTop: TBitBtn
              Left = 80
              Top = 6
              Width = 33
              Height = 25
              Hint = #32622#39030
              Caption = 'T'
              TabOrder = 1
              OnClick = btnSouTopClick
            end
            object btnSouUp: TBitBtn
              Left = 120
              Top = 6
              Width = 33
              Height = 25
              Hint = #19978#31227
              Caption = #8743
              TabOrder = 2
              OnClick = btnSouUpClick
            end
            object btnSouDown: TBitBtn
              Left = 160
              Top = 6
              Width = 33
              Height = 25
              Hint = #19979#31227
              Caption = #8744
              TabOrder = 3
              OnClick = btnSouDownClick
            end
            object btnSouBottom: TBitBtn
              Left = 200
              Top = 6
              Width = 33
              Height = 25
              Hint = #32622#24213' '
              Caption = #8869
              TabOrder = 4
              OnClick = btnSouBottomClick
            end
            object btnSouDelete: TBitBtn
              Left = 240
              Top = 6
              Width = 33
              Height = 25
              Hint = #21024#38500
              Caption = 'X'
              TabOrder = 5
              OnClick = btnSouDeleteClick
            end
            object btnDesTop: TBitBtn
              Left = 465
              Top = 6
              Width = 33
              Height = 25
              Hint = #32622#39030
              Caption = 'T'
              TabOrder = 6
              OnClick = btnDesTopClick
            end
            object btnDesUp: TBitBtn
              Left = 505
              Top = 6
              Width = 33
              Height = 25
              Hint = #19978#31227
              Caption = #8743
              TabOrder = 7
              OnClick = btnDesUpClick
            end
            object btnDesDown: TBitBtn
              Left = 545
              Top = 6
              Width = 33
              Height = 25
              Hint = #19979#31227
              Caption = #8744
              TabOrder = 8
              OnClick = btnDesDownClick
            end
            object btnDesBottom: TBitBtn
              Left = 585
              Top = 6
              Width = 33
              Height = 25
              Hint = #32622#24213' '
              Caption = #8869
              TabOrder = 9
              OnClick = btnDesBottomClick
            end
            object btnDesDelete: TBitBtn
              Left = 625
              Top = 6
              Width = 33
              Height = 25
              Hint = #21024#38500
              Caption = 'X'
              TabOrder = 10
              OnClick = btnDesDeleteClick
            end
            object btnAddDestField: TBitBtn
              Left = 667
              Top = 6
              Width = 33
              Height = 25
              Hint = #28155#21152#30446#26631#23383#27573
              Caption = #9532
              TabOrder = 11
              OnClick = btnAddDestFieldClick
            end
          end
        end
        object tsPretreatment: TTabSheet
          Caption = #35302#21457#22120
          ImageIndex = 1
          object optHint: TMemo
            Left = 8
            Top = 8
            Width = 985
            Height = 65
            BevelInner = bvNone
            BevelOuter = bvNone
            BorderStyle = bsNone
            Color = clScrollBar
            Lines.Strings = (
              #34892#35302#21457#22120#22312#25968#25454#36801#31227#26102#23545#27599#19968#26465#35760#24405#37117#25191#34892#19968#36941
              #25191#34892#39034#24207#20026#65306#36801#31227#21069#24038#12289#36801#31227#21069#21491#12289#38065#20197#21518#21491#12289#36801#31227#21518#24038#65288#24038#20195#34920#25968#25454#28304#65292#21491#20195#34920#25968#25454#30446#26631#65289
              #34892#35302#21457#22120#20026#19968#26465'DML'#35821#21477#65288'insert'#12289'update'#12289'delete'#65289#25110#32773#19968#20010#23384#20648#36807#31243#65288#22914#26524#38656#35201#25191#34892#22810#26465#35821#21477#29992#23601#29992#23384#20648#36807#31243#65289
              #23545#25968#25454#30340#24341#29992#21517#20026' '#39':'#39'+'#25968#25454#28304#23383#27573#21517','#25110#32773' TODAY'#24403#21069#26102#38388' SQL_ERROR_MSG '#25968#25454#24211#36816#34892#24322#24120#20449#24687)
            ReadOnly = True
            TabOrder = 0
          end
          object ledBeforeOptLeft: TLabeledEdit
            Left = 96
            Top = 72
            Width = 730
            Height = 21
            EditLabel.Width = 63
            EditLabel.Height = 13
            EditLabel.Caption = #36801#31227#21069#24038#65306' '
            LabelPosition = lpLeft
            TabOrder = 1
          end
          object ledBeforeOptRight: TLabeledEdit
            Left = 96
            Top = 101
            Width = 730
            Height = 21
            EditLabel.Width = 63
            EditLabel.Height = 13
            EditLabel.Caption = #36801#31227#21069#21491#65306' '
            LabelPosition = lpLeft
            TabOrder = 2
          end
          object ledAfterOptRight: TLabeledEdit
            Left = 96
            Top = 130
            Width = 730
            Height = 21
            EditLabel.Width = 63
            EditLabel.Height = 13
            EditLabel.Caption = #36801#31227#21518#21491#65306' '
            LabelPosition = lpLeft
            TabOrder = 3
          end
          object ledAfterOptLeft: TLabeledEdit
            Left = 96
            Top = 159
            Width = 730
            Height = 21
            EditLabel.Width = 63
            EditLabel.Height = 13
            EditLabel.Caption = #36801#31227#21518#24038#65306' '
            LabelPosition = lpLeft
            TabOrder = 4
          end
          object ledErrorRight: TLabeledEdit
            Left = 96
            Top = 217
            Width = 730
            Height = 21
            EditLabel.Width = 63
            EditLabel.Height = 13
            EditLabel.Caption = #22833#36133#21518#21491#65306' '
            LabelPosition = lpLeft
            TabOrder = 5
          end
          object ledErrorLeft: TLabeledEdit
            Left = 96
            Top = 188
            Width = 730
            Height = 21
            EditLabel.Width = 63
            EditLabel.Height = 13
            EditLabel.Caption = #22833#36133#21518#24038#65306' '
            LabelPosition = lpLeft
            TabOrder = 6
          end
          object optCompleteHint: TMemo
            Left = 9
            Top = 248
            Width = 985
            Height = 65
            BevelInner = bvNone
            BevelOuter = bvNone
            BorderStyle = bsNone
            Color = clScrollBar
            Lines.Strings = (
              #36801#31227#35302#21457#22120#22312#25968#25454#36801#31227#23436#25104#26102#25191#34892#65292#20854#34892#20026#21516#26679#26159#19968#26465'DML'#35821#21477#65288'insert'#12289'update'#12289'delete'#65289#25110#32773#19968#20010#23384#20648#36807#31243
              #65288#22914#26524#38656#35201#25191#34892#22810#26465#35821#21477#29992#23601#29992#23384#20648#36807#31243#65289
              
                #23545#25968#25454#30340#24341#29992#21517#20026' '#39':'#39'+'#25968#25454#28304#23383#27573#21517#65292#25110#32773#26159#19979#21015#20043#19968#65306' TODAY '#24403#21069#26102#38388#65292'SYNC_DATA_PIECES '#36801#31227#26465#25968#65292' S' +
                'UCCEED_PIECES '#25104#21151#26465#25968','
              'FAULT_PIECES '#22833#36133#26465#25968#65292'SYNC_BEGIN_TIME '#36801#31227#24320#22987#26102#38388' SYNC_END_TIME '#36801#31227#32467#26463#26102#38388)
            ReadOnly = True
            TabOrder = 7
          end
          object ledTransCompleteLeft: TLabeledEdit
            Left = 96
            Top = 312
            Width = 730
            Height = 21
            EditLabel.Width = 87
            EditLabel.Height = 13
            EditLabel.Caption = #36801#31227#23436#25104#21518#24038#65306' '
            LabelPosition = lpLeft
            TabOrder = 8
          end
          object ledTransCompleteRight: TLabeledEdit
            Left = 96
            Top = 341
            Width = 730
            Height = 21
            EditLabel.Width = 87
            EditLabel.Height = 13
            EditLabel.Caption = #36801#31227#23436#25104#21518#21491#65306' '
            LabelPosition = lpLeft
            TabOrder = 9
          end
        end
      end
    end
    object tsScript: TTabSheet
      Caption = #33050#26412#39044#35272
      ImageIndex = 2
      object edLeftScript: TMemo
        Left = 0
        Top = 41
        Width = 433
        Height = 448
        Align = alLeft
        ReadOnly = True
        TabOrder = 0
      end
      object edRightScript: TMemo
        Left = 433
        Top = 41
        Width = 414
        Height = 448
        Align = alClient
        ReadOnly = True
        TabOrder = 1
      end
      object panelScriptTop: TPanel
        Left = 0
        Top = 0
        Width = 847
        Height = 41
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 2
        object lbLeftScript: TLabel
          Left = 8
          Top = 16
          Width = 137
          Height = 17
          AutoSize = False
          Caption = #23548#20986#33050#26412
        end
        object lbRightScript: TLabel
          Left = 432
          Top = 16
          Width = 137
          Height = 17
          AutoSize = False
          Caption = #23548#20837#33050#26412
        end
      end
    end
  end
  object plOK: TPanel
    Left = 0
    Top = 517
    Width = 855
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object btnCancel: TBitBtn
      Left = 351
      Top = 7
      Width = 89
      Height = 26
      Caption = #21462#28040
      ModalResult = 2
      TabOrder = 0
    end
    object btnOK: TBitBtn
      Left = 680
      Top = 7
      Width = 89
      Height = 26
      Caption = #20445#23384#24182#36864#20986
      TabOrder = 1
      OnClick = btnOKClick
    end
    object btnCheckSetting: TBitBtn
      Left = 455
      Top = 7
      Width = 89
      Height = 26
      Caption = #26816#27979#35774#32622
      TabOrder = 2
      OnClick = btnCheckSettingClick
    end
    object cbAutoCheck: TCheckBox
      Left = 556
      Top = 14
      Width = 117
      Height = 14
      Caption = #20445#23384#26102#33258#21160#26816#27979
      Checked = True
      State = cbChecked
      TabOrder = 3
    end
  end
end
