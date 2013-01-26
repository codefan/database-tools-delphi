object frQueryWizard: TfrQueryWizard
  Left = 370
  Top = 167
  Width = 695
  Height = 463
  Caption = #26597#35810#35821#21477'(SQL)'#29983#25104#21521#23548
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #23435#20307
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnHide = FormHide
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pcDesign: TPageControl
    Left = 0
    Top = 0
    Width = 687
    Height = 388
    ActivePage = tabWizard
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    MultiLine = True
    ParentFont = False
    TabOrder = 0
    TabPosition = tpRight
    OnChange = pcDesignChange
    object tabWizard: TTabSheet
      Caption = #26597#35810#21521#23548
      object trRelation: TPageControl
        Left = 0
        Top = 0
        Width = 661
        Height = 380
        ActivePage = tabSelect
        Align = alClient
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = #23435#20307
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        OnChange = trRelationChange
        object tabSelect: TTabSheet
          Caption = #26597#35810#20869#23481
          object pcSelect: TPageControl
            Left = 0
            Top = 0
            Width = 653
            Height = 352
            ActivePage = tabSelectWizard
            Align = alClient
            TabOrder = 0
            TabPosition = tpBottom
            OnChange = pcSelectChange
            object tabSelectWizard: TTabSheet
              Caption = #21521#23548
              object trTableColPS: TTreeView
                Left = 0
                Top = 0
                Width = 185
                Height = 326
                Align = alLeft
                HideSelection = False
                Indent = 19
                ReadOnly = True
                RowSelect = True
                TabOrder = 0
                OnChange = trTableColPSChange
                OnDblClick = trTableColPSDblClick
                OnDeletion = deleteTreeItemData
                OnExpanded = trTableColPSExpanded
              end
              object PanelSelectClient: TPanel
                Left = 185
                Top = 0
                Width = 460
                Height = 326
                Align = alClient
                BevelOuter = bvNone
                TabOrder = 1
                object lvSelectingField: TListView
                  Left = 0
                  Top = 0
                  Width = 460
                  Height = 201
                  Align = alClient
                  Checkboxes = True
                  Columns = <
                    item
                      Width = 35
                    end
                    item
                      Caption = #23383#27573#34920#36798#24335#20195#30721
                      Width = 140
                    end
                    item
                      Caption = #23383#27573#21035#21517
                      Width = 100
                    end
                    item
                      Caption = #23383#27573#34920#36798#24335#25551#36848
                      Width = 140
                    end>
                  GridLines = True
                  HideSelection = False
                  ReadOnly = True
                  RowSelect = True
                  TabOrder = 0
                  ViewStyle = vsReport
                  OnDeletion = lvSelectingFieldDeletion
                  OnKeyDown = lvSelectingFieldKeyDown
                end
                object PanelSelectClientBottom: TPanel
                  Left = 0
                  Top = 201
                  Width = 460
                  Height = 125
                  Align = alBottom
                  BevelOuter = bvNone
                  TabOrder = 1
                  object lbDealFieldPS: TLabel
                    Left = 10
                    Top = 10
                    Width = 64
                    Height = 16
                    AutoSize = False
                    Caption = #22788#29702#26041#24335#65306
                  end
                  object ledFieldDescPS: TLabeledEdit
                    Left = 74
                    Top = 64
                    Width = 380
                    Height = 21
                    AutoSize = False
                    EditLabel.Width = 65
                    EditLabel.Height = 13
                    EditLabel.Caption = #23383#27573#25551#36848#65306
                    ImeName = #20013#25991' ('#31616#20307') - '#24494#36719#25340#38899
                    LabelPosition = lpLeft
                    TabOrder = 5
                  end
                  object cbDealFieldPS: TComboBox
                    Left = 74
                    Top = 7
                    Width = 143
                    Height = 21
                    Style = csDropDownList
                    ImeName = #20013#25991' ('#31616#20307') - '#24494#36719#25340#38899
                    ItemHeight = 13
                    TabOrder = 0
                    OnSelect = updateSqlAndDescInSP
                  end
                  object btnAddFieldPS: TButton
                    Left = 288
                    Top = 94
                    Width = 75
                    Height = 25
                    Caption = #28155#21152
                    Default = True
                    TabOrder = 7
                    OnClick = btnAddFieldPSClick
                  end
                  object btnDeleteFieldPS: TButton
                    Left = 196
                    Top = 94
                    Width = 75
                    Height = 25
                    Caption = #21024#38500
                    TabOrder = 6
                    OnClick = btnDeleteFieldPSClick
                  end
                  object btnUpdateFieldPS: TButton
                    Left = 380
                    Top = 94
                    Width = 75
                    Height = 25
                    Caption = #26356#25913
                    TabOrder = 8
                    OnClick = btnUpdateFieldPSClick
                  end
                  object ledDealFieldPrm1PS: TLabeledEdit
                    Left = 289
                    Top = 7
                    Width = 55
                    Height = 21
                    AutoSize = False
                    EditLabel.Width = 46
                    EditLabel.Height = 13
                    EditLabel.Caption = #21442#25968'1'#65306
                    ImeName = #20013#25991' ('#31616#20307') - '#24494#36719#25340#38899
                    LabelPosition = lpLeft
                    TabOrder = 1
                    OnChange = updateSqlAndDescInSP
                  end
                  object ledDealFieldPrm2PS: TLabeledEdit
                    Left = 400
                    Top = 7
                    Width = 54
                    Height = 21
                    AutoSize = False
                    EditLabel.Width = 53
                    EditLabel.Height = 13
                    EditLabel.Caption = #21442#25968'2'#65306' '
                    ImeName = #20013#25991' ('#31616#20307') - '#24494#36719#25340#38899
                    LabelPosition = lpLeft
                    TabOrder = 2
                    OnChange = updateSqlAndDescInSP
                  end
                  object ledFieldSqlPS: TLabeledEdit
                    Left = 74
                    Top = 37
                    Width = 142
                    Height = 21
                    AutoSize = False
                    EditLabel.Width = 65
                    EditLabel.Height = 13
                    EditLabel.Caption = #23383#27573#35821#21477#65306
                    ImeName = #20013#25991' ('#31616#20307') - '#24494#36719#25340#38899
                    LabelPosition = lpLeft
                    TabOrder = 3
                  end
                  object btnMoveSelectUpPS: TButton
                    Left = 10
                    Top = 94
                    Width = 75
                    Height = 25
                    Caption = #19978#31227
                    TabOrder = 9
                    OnClick = btnMoveSelectUpPSClick
                  end
                  object btnMoveSelectDownPS: TButton
                    Left = 102
                    Top = 94
                    Width = 75
                    Height = 25
                    Caption = #19979#31227
                    TabOrder = 10
                    OnClick = btnMoveSelectDownPSClick
                  end
                  object ledFieldAlias: TLabeledEdit
                    Tag = 2
                    Left = 290
                    Top = 37
                    Width = 165
                    Height = 21
                    AutoSize = False
                    EditLabel.Width = 46
                    EditLabel.Height = 13
                    EditLabel.Caption = #21035' '#21517#65306
                    ImeName = #20013#25991' ('#31616#20307') - '#24494#36719#25340#38899
                    LabelPosition = lpLeft
                    TabOrder = 4
                    OnKeyPress = filterInputCharacter
                  end
                end
              end
            end
            object tabSelectSQL: TTabSheet
              Caption = 'SQL'#35821#21477
              ImageIndex = 1
              object edSelectSQL: TMemo
                Left = 0
                Top = 0
                Width = 646
                Height = 324
                Align = alClient
                ImeName = #20013#25991' ('#31616#20307') - '#24494#36719#25340#38899
                TabOrder = 0
              end
            end
          end
        end
        object tabFrom: TTabSheet
          Caption = #26597#35810#34920#26684
          ImageIndex = 1
          object pcFrom: TPageControl
            Left = 0
            Top = 0
            Width = 653
            Height = 352
            ActivePage = tabFromWizard
            Align = alClient
            TabOrder = 0
            TabPosition = tpBottom
            OnChange = pcFromChange
            object tabFromWizard: TTabSheet
              Caption = #21521#23548
              object lvTabJoin: TListView
                Left = 0
                Top = 0
                Width = 645
                Height = 286
                Align = alClient
                Columns = <
                  item
                    AutoSize = True
                    Caption = #20027#34920#21517#65288#34920#19968#65289
                  end
                  item
                    Caption = #32852#26426#26041#24335
                    Width = 100
                  end
                  item
                    AutoSize = True
                    Caption = #20174#34920#21517#65288#34920#20108#65289
                  end>
                GridLines = True
                HideSelection = False
                ReadOnly = True
                RowSelect = True
                TabOrder = 0
                ViewStyle = vsReport
                OnSelectItem = lvTabJoinSelectItem
              end
              object panelFromBottom: TPanel
                Left = 0
                Top = 286
                Width = 645
                Height = 40
                Align = alBottom
                BevelOuter = bvNone
                TabOrder = 1
                object panelFromBottomRight: TPanel
                  Left = 94
                  Top = 0
                  Width = 551
                  Height = 40
                  Align = alRight
                  BevelOuter = bvNone
                  TabOrder = 0
                  object ledTable1PF: TLabeledEdit
                    Left = 39
                    Top = 9
                    Width = 127
                    Height = 21
                    AutoSize = False
                    EditLabel.Width = 39
                    EditLabel.Height = 13
                    EditLabel.Caption = #34920#19968#65306
                    ImeName = #20013#25991' ('#31616#20307') - '#24494#36719#25340#38899
                    LabelPosition = lpLeft
                    ReadOnly = True
                    TabOrder = 2
                  end
                  object ledTable2PF: TLabeledEdit
                    Left = 318
                    Top = 9
                    Width = 132
                    Height = 21
                    AutoSize = False
                    EditLabel.Width = 39
                    EditLabel.Height = 13
                    EditLabel.Caption = #34920#20108#65306
                    ImeName = #20013#25991' ('#31616#20307') - '#24494#36719#25340#38899
                    LabelPosition = lpLeft
                    ReadOnly = True
                    TabOrder = 3
                  end
                  object cbTabJoinType: TComboBox
                    Left = 196
                    Top = 9
                    Width = 75
                    Height = 21
                    Style = csDropDownList
                    ImeName = #20013#25991' ('#31616#20307') - '#24494#36719#25340#38899
                    ItemHeight = 13
                    TabOrder = 0
                    OnSelect = updateSqlAndDescInSP
                  end
                  object btnChangeJionTyoePF: TButton
                    Left = 465
                    Top = 8
                    Width = 84
                    Height = 25
                    Caption = #26356#25913#36830#25509#26041#24335
                    Default = True
                    TabOrder = 1
                    OnClick = btnChangeJionTyoePFClick
                  end
                end
              end
            end
            object tabFromSQL: TTabSheet
              Caption = 'SQL'#35821#21477
              ImageIndex = 1
              object edFromSQL: TMemo
                Left = 0
                Top = 0
                Width = 646
                Height = 324
                Align = alClient
                ImeName = #20013#25991' ('#31616#20307') - '#24494#36719#25340#38899
                TabOrder = 0
              end
            end
          end
        end
        object tabWhere: TTabSheet
          Caption = #26597#35810#26465#20214
          ImageIndex = 2
          object pcWhere: TPageControl
            Left = 0
            Top = 0
            Width = 653
            Height = 352
            ActivePage = tabWhereWizard
            Align = alClient
            TabOrder = 0
            TabPosition = tpBottom
            OnChange = pcWhereChange
            object tabWhereWizard: TTabSheet
              Caption = #21521#23548
              object trTableColPW: TTreeView
                Left = 0
                Top = 0
                Width = 169
                Height = 326
                Align = alLeft
                HideSelection = False
                Indent = 19
                ReadOnly = True
                RowSelect = True
                TabOrder = 0
                OnChange = trTableColPWChange
                OnDeletion = deleteTreeItemData
                OnExpanded = trTableColPWExpanded
              end
              object panelWhereRight: TPanel
                Left = 169
                Top = 0
                Width = 476
                Height = 326
                Align = alClient
                BevelOuter = bvNone
                TabOrder = 1
                object lvConditionPW: TListView
                  Tag = 10
                  Left = 0
                  Top = 0
                  Width = 476
                  Height = 133
                  Align = alClient
                  Columns = <
                    item
                      Width = 20
                    end
                    item
                      Caption = #20195#30721
                      Width = 98
                    end
                    item
                      Caption = #36923#36753
                      Width = 45
                    end
                    item
                      Caption = #25968#20540
                    end
                    item
                      Caption = #36923#36753#34920#36798#24335
                      Width = 98
                    end
                    item
                      AutoSize = True
                      Caption = #36923#36753#34920#36798#24335#25551#36848
                    end>
                  GridLines = True
                  HideSelection = False
                  ReadOnly = True
                  RowSelect = True
                  TabOrder = 0
                  ViewStyle = vsReport
                  OnDblClick = editConditionFormulaPW
                  OnKeyDown = lvConditionPWKeyDown
                end
                object panelWhereRightBottom: TPanel
                  Left = 0
                  Top = 260
                  Width = 476
                  Height = 66
                  Align = alBottom
                  BevelOuter = bvNone
                  TabOrder = 1
                  object lbFormulaPW: TLabel
                    Left = 0
                    Top = 0
                    Width = 476
                    Height = 17
                    Align = alTop
                    AutoSize = False
                    Caption = #36923#36753#34920#36798#24335#65306
                    Font.Charset = DEFAULT_CHARSET
                    Font.Color = clWindowText
                    Font.Height = -14
                    Font.Name = 'MS Sans Serif'
                    Font.Style = []
                    ParentFont = False
                  end
                  object panelWhereRightBottomRight: TPanel
                    Left = 384
                    Top = 17
                    Width = 92
                    Height = 49
                    Align = alRight
                    BevelOuter = bvNone
                    TabOrder = 0
                    object btnAndPW: TButton
                      Tag = 1
                      Left = 2
                      Top = 0
                      Width = 24
                      Height = 21
                      Caption = #24182
                      TabOrder = 0
                      OnClick = editConditionFormulaPW
                    end
                    object btnLeftBracketPW: TButton
                      Tag = 4
                      Left = 2
                      Top = 23
                      Width = 24
                      Height = 21
                      Caption = #65288
                      TabOrder = 3
                      OnClick = editConditionFormulaPW
                    end
                    object btnRightBracketPW: TButton
                      Tag = 5
                      Left = 29
                      Top = 23
                      Width = 24
                      Height = 21
                      Caption = #65289
                      TabOrder = 4
                      OnClick = editConditionFormulaPW
                    end
                    object btnNotPW: TButton
                      Tag = 3
                      Left = 56
                      Top = 0
                      Width = 28
                      Height = 44
                      Caption = #21462#21453
                      TabOrder = 2
                      OnClick = editConditionFormulaPW
                    end
                    object btnOrPW: TButton
                      Tag = 2
                      Left = 29
                      Top = 0
                      Width = 24
                      Height = 21
                      Caption = #25110
                      TabOrder = 1
                      OnClick = editConditionFormulaPW
                    end
                  end
                  object edWhereFormula: TMemo
                    Tag = 1
                    Left = 0
                    Top = 17
                    Width = 384
                    Height = 49
                    Align = alClient
                    HideSelection = False
                    ImeName = #20013#25991' ('#31616#20307') - '#24494#36719#25340#38899
                    TabOrder = 1
                    OnKeyPress = filterInputCharacter
                  end
                end
                object PanelWhereRigthCenter: TPanel
                  Left = 0
                  Top = 133
                  Width = 476
                  Height = 127
                  Align = alBottom
                  BevelOuter = bvNone
                  TabOrder = 2
                  object lbDealTypePW: TLabel
                    Left = 15
                    Top = 8
                    Width = 64
                    Height = 16
                    AutoSize = False
                    Caption = #22788#29702#26041#24335#65306
                  end
                  object lbLogicOptPW: TLabel
                    Left = 38
                    Top = 59
                    Width = 35
                    Height = 16
                    AutoSize = False
                    Caption = #36923#36753#65306
                  end
                  object lbDictionaryValue: TLabel
                    Left = 254
                    Top = 56
                    Width = 49
                    Height = 17
                    AutoSize = False
                    Caption = #21442#32771#20540#65306
                  end
                  object ledDealFieldPrm1PW: TLabeledEdit
                    Left = 305
                    Top = 5
                    Width = 55
                    Height = 21
                    AutoSize = False
                    EditLabel.Width = 46
                    EditLabel.Height = 13
                    EditLabel.Caption = #21442#25968'1'#65306
                    ImeName = #20013#25991' ('#31616#20307') - '#24494#36719#25340#38899
                    LabelPosition = lpLeft
                    TabOrder = 1
                    OnChange = updateSqlAndDescInPW
                  end
                  object ledDealFieldPrm2PW: TLabeledEdit
                    Left = 415
                    Top = 5
                    Width = 54
                    Height = 21
                    AutoSize = False
                    EditLabel.Width = 53
                    EditLabel.Height = 13
                    EditLabel.Caption = #21442#25968'2'#65306' '
                    ImeName = #20013#25991' ('#31616#20307') - '#24494#36719#25340#38899
                    LabelPosition = lpLeft
                    TabOrder = 2
                    OnChange = updateSqlAndDescInPW
                  end
                  object ledFieldSqlPW: TLabeledEdit
                    Left = 78
                    Top = 30
                    Width = 143
                    Height = 21
                    AutoSize = False
                    EditLabel.Width = 65
                    EditLabel.Height = 13
                    EditLabel.Caption = #23383#27573#35821#21477#65306
                    ImeName = #20013#25991' ('#31616#20307') - '#24494#36719#25340#38899
                    LabelPosition = lpLeft
                    TabOrder = 3
                  end
                  object ledFieldDescPW: TLabeledEdit
                    Left = 305
                    Top = 30
                    Width = 164
                    Height = 21
                    AutoSize = False
                    EditLabel.Width = 65
                    EditLabel.Height = 13
                    EditLabel.Caption = #23383#27573#25551#36848#65306
                    ImeName = #20013#25991' ('#31616#20307') - '#24494#36719#25340#38899
                    LabelPosition = lpLeft
                    TabOrder = 4
                  end
                  object cbDealFieldPW: TComboBox
                    Left = 78
                    Top = 5
                    Width = 144
                    Height = 21
                    Style = csDropDownList
                    ImeName = #20013#25991' ('#31616#20307') - '#24494#36719#25340#38899
                    ItemHeight = 13
                    TabOrder = 0
                    OnSelect = updateSqlAndDescInPW
                  end
                  object btnAddConditionPW: TButton
                    Left = 340
                    Top = 104
                    Width = 60
                    Height = 23
                    Caption = #28155#21152
                    Default = True
                    TabOrder = 11
                    OnClick = btnAddConditionPWClick
                  end
                  object btnUpdateConditionPW: TButton
                    Left = 407
                    Top = 104
                    Width = 61
                    Height = 23
                    Caption = #26356#25913
                    TabOrder = 12
                    OnClick = btnUpdateConditionPWClick
                  end
                  object cbLogicOptPW: TComboBox
                    Left = 78
                    Top = 54
                    Width = 143
                    Height = 21
                    Style = csDropDownList
                    ImeName = #20013#25991' ('#31616#20307') - '#24494#36719#25340#38899
                    ItemHeight = 13
                    TabOrder = 5
                    OnSelect = cbLogicOptPWSelect
                  end
                  object ledValuePW: TLabeledEdit
                    Left = 78
                    Top = 79
                    Width = 361
                    Height = 21
                    AutoSize = False
                    EditLabel.Width = 39
                    EditLabel.Height = 13
                    EditLabel.Caption = #25968#20540#65306
                    ImeName = #20013#25991' ('#31616#20307') - '#24494#36719#25340#38899
                    LabelPosition = lpLeft
                    TabOrder = 9
                  end
                  object btnSubQuery: TButton
                    Left = 402
                    Top = 53
                    Width = 65
                    Height = 22
                    Caption = #23376#26597#35810
                    TabOrder = 8
                    OnClick = btnAddFieldPSClick
                  end
                  object cbDictionaryDataValue: TComboBox
                    Tag = 2
                    Left = 304
                    Top = 54
                    Width = 162
                    Height = 21
                    Style = csDropDownList
                    ImeName = #20013#25991' ('#31616#20307') - '#24494#36719#25340#38899
                    ItemHeight = 13
                    TabOrder = 6
                    OnSelect = chageDataValuePW
                  end
                  object dtpDataValue: TDateTimePicker
                    Tag = 1
                    Left = 305
                    Top = 53
                    Width = 163
                    Height = 21
                    Date = 38434.476233101900000000
                    Time = 38434.476233101900000000
                    DateFormat = dfLong
                    ImeName = #20013#25991' ('#31616#20307') - '#24494#36719#25340#38899
                    TabOrder = 7
                    OnChange = chageDataValuePW
                  end
                  object btnDeleteConditionPW: TButton
                    Left = 273
                    Top = 104
                    Width = 61
                    Height = 23
                    Caption = #21024#38500
                    TabOrder = 10
                    OnClick = btnDeleteConditionPWClick
                  end
                  object btnCiteParamWP: TBitBtn
                    Left = 441
                    Top = 79
                    Width = 27
                    Height = 21
                    Caption = '+'
                    TabOrder = 13
                    OnClick = btnCiteParamWPClick
                  end
                  object cbCurrentDate: TCheckBox
                    Left = 228
                    Top = 55
                    Width = 71
                    Height = 17
                    Caption = #24403#21069#26085#26399
                    TabOrder = 14
                    OnClick = cbCurrentDateClick
                  end
                end
              end
            end
            object tabWhereSQL: TTabSheet
              Caption = 'SQL'#35821#21477
              ImageIndex = 1
              object edWhereSQL: TMemo
                Left = 0
                Top = 0
                Width = 646
                Height = 324
                Align = alClient
                ImeName = #20013#25991' ('#31616#20307') - '#24494#36719#25340#38899
                TabOrder = 0
              end
            end
          end
        end
        object tabGroup: TTabSheet
          Caption = #20998#32452
          ImageIndex = 3
          object pcGroup: TPageControl
            Left = 0
            Top = 0
            Width = 653
            Height = 352
            ActivePage = tabGroupWizard
            Align = alClient
            TabOrder = 0
            TabPosition = tpBottom
            OnChange = pcGroupChange
            object tabGroupWizard: TTabSheet
              Caption = #21521#23548
              object lvSelectFieldNoStat: TListView
                Left = 0
                Top = 0
                Width = 645
                Height = 326
                Align = alClient
                Checkboxes = True
                Columns = <
                  item
                    Caption = #20998
                    Width = 20
                  end
                  item
                    Caption = #23383#27573#34920#36798#24335#25551#36848
                    Width = 150
                  end
                  item
                    AutoSize = True
                    Caption = #23383#27573#34920#36798#24335#20195#30721
                  end>
                GridLines = True
                ReadOnly = True
                RowSelect = True
                TabOrder = 0
                ViewStyle = vsReport
              end
            end
            object tabGroupSQL: TTabSheet
              Caption = 'SQL'#35821#21477
              ImageIndex = 1
              object edGroupSQL: TMemo
                Left = 0
                Top = 0
                Width = 646
                Height = 324
                Align = alClient
                ImeName = #20013#25991' ('#31616#20307') - '#24494#36719#25340#38899
                TabOrder = 0
              end
            end
          end
        end
        object tabHaving: TTabSheet
          Caption = #20998#32452#36807#28388
          ImageIndex = 4
          object pcHaving: TPageControl
            Left = 0
            Top = 0
            Width = 653
            Height = 352
            ActivePage = tabHavingWizard
            Align = alClient
            TabOrder = 0
            TabPosition = tpBottom
            OnChange = pcHavingChange
            object tabHavingWizard: TTabSheet
              Caption = #21521#23548
              object lvHavingField: TListView
                Left = 0
                Top = 0
                Width = 169
                Height = 326
                Align = alLeft
                Columns = <
                  item
                    Caption = #23383#27573#34920#36798#24335#25551#36848
                    Width = 100
                  end
                  item
                    AutoSize = True
                    Caption = #20195#30721
                  end>
                GridLines = True
                HideSelection = False
                ReadOnly = True
                RowSelect = True
                TabOrder = 0
                ViewStyle = vsReport
                OnSelectItem = lvHavingFieldSelectItem
              end
              object PanelHavingClient: TPanel
                Left = 169
                Top = 0
                Width = 476
                Height = 326
                Align = alClient
                BevelOuter = bvNone
                TabOrder = 1
                object lvConditionPH: TListView
                  Tag = 10
                  Left = 0
                  Top = 0
                  Width = 476
                  Height = 133
                  Align = alClient
                  Columns = <
                    item
                      Width = 20
                    end
                    item
                      Caption = #20195#30721
                      Width = 98
                    end
                    item
                      Caption = #36923#36753
                      Width = 45
                    end
                    item
                      Caption = #25968#20540
                    end
                    item
                      Caption = #36923#36753#34920#36798#24335
                      Width = 98
                    end
                    item
                      AutoSize = True
                      Caption = #36923#36753#34920#36798#24335#25551#36848
                    end>
                  GridLines = True
                  HideSelection = False
                  ReadOnly = True
                  RowSelect = True
                  TabOrder = 0
                  ViewStyle = vsReport
                  OnDblClick = editConditionFormulaPH
                  OnKeyDown = lvConditionPHKeyDown
                end
                object PanelGroupRightMiddle: TPanel
                  Left = 0
                  Top = 133
                  Width = 476
                  Height = 127
                  Align = alBottom
                  BevelOuter = bvNone
                  TabOrder = 1
                  object lbDealFieldPH: TLabel
                    Left = 15
                    Top = 8
                    Width = 64
                    Height = 16
                    AutoSize = False
                    Caption = #22788#29702#26041#24335#65306
                  end
                  object lbLogicOptPH: TLabel
                    Left = 38
                    Top = 59
                    Width = 35
                    Height = 16
                    AutoSize = False
                    Caption = #36923#36753#65306
                  end
                  object lbDictionaryValuePH: TLabel
                    Left = 254
                    Top = 56
                    Width = 49
                    Height = 17
                    AutoSize = False
                    Caption = #21442#32771#20540#65306
                  end
                  object ledDealFieldPrm1PH: TLabeledEdit
                    Left = 305
                    Top = 5
                    Width = 55
                    Height = 21
                    AutoSize = False
                    EditLabel.Width = 46
                    EditLabel.Height = 13
                    EditLabel.Caption = #21442#25968'1'#65306
                    ImeName = #20013#25991' ('#31616#20307') - '#24494#36719#25340#38899
                    LabelPosition = lpLeft
                    TabOrder = 1
                    OnChange = updateSqlAndDescInPH
                  end
                  object ledDealFieldPrm2PH: TLabeledEdit
                    Left = 415
                    Top = 5
                    Width = 54
                    Height = 21
                    AutoSize = False
                    EditLabel.Width = 53
                    EditLabel.Height = 13
                    EditLabel.Caption = #21442#25968'2'#65306' '
                    ImeName = #20013#25991' ('#31616#20307') - '#24494#36719#25340#38899
                    LabelPosition = lpLeft
                    TabOrder = 2
                    OnChange = updateSqlAndDescInPH
                  end
                  object ledFieldSqlPH: TLabeledEdit
                    Left = 78
                    Top = 30
                    Width = 143
                    Height = 21
                    AutoSize = False
                    EditLabel.Width = 65
                    EditLabel.Height = 13
                    EditLabel.Caption = #23383#27573#35821#21477#65306
                    ImeName = #20013#25991' ('#31616#20307') - '#24494#36719#25340#38899
                    LabelPosition = lpLeft
                    TabOrder = 3
                  end
                  object ledFieldDescPH: TLabeledEdit
                    Left = 305
                    Top = 30
                    Width = 164
                    Height = 21
                    AutoSize = False
                    EditLabel.Width = 65
                    EditLabel.Height = 13
                    EditLabel.Caption = #23383#27573#25551#36848#65306
                    ImeName = #20013#25991' ('#31616#20307') - '#24494#36719#25340#38899
                    LabelPosition = lpLeft
                    TabOrder = 4
                  end
                  object cbDealFieldPH: TComboBox
                    Left = 78
                    Top = 5
                    Width = 144
                    Height = 21
                    Style = csDropDownList
                    ImeName = #20013#25991' ('#31616#20307') - '#24494#36719#25340#38899
                    ItemHeight = 13
                    TabOrder = 0
                    OnSelect = updateSqlAndDescInPH
                  end
                  object btnAddConditionPH: TButton
                    Left = 340
                    Top = 104
                    Width = 60
                    Height = 23
                    Caption = #28155#21152
                    Default = True
                    TabOrder = 11
                    OnClick = btnAddConditionPHClick
                  end
                  object btnUpdateConditionPH: TButton
                    Left = 407
                    Top = 104
                    Width = 61
                    Height = 23
                    Caption = #26356#25913
                    TabOrder = 12
                    OnClick = btnUpdateConditionPHClick
                  end
                  object btnDeleteConditionPH: TButton
                    Left = 273
                    Top = 104
                    Width = 61
                    Height = 23
                    Caption = #21024#38500
                    TabOrder = 10
                    OnClick = btnDeleteConditionPHClick
                  end
                  object cbLogicOptPH: TComboBox
                    Left = 78
                    Top = 54
                    Width = 143
                    Height = 21
                    Style = csDropDownList
                    ImeName = #20013#25991' ('#31616#20307') - '#24494#36719#25340#38899
                    ItemHeight = 13
                    TabOrder = 5
                    OnSelect = cbLogicOptPHSelect
                  end
                  object ledValuePH: TLabeledEdit
                    Left = 78
                    Top = 79
                    Width = 363
                    Height = 21
                    AutoSize = False
                    EditLabel.Width = 39
                    EditLabel.Height = 13
                    EditLabel.Caption = #25968#20540#65306
                    ImeName = #20013#25991' ('#31616#20307') - '#24494#36719#25340#38899
                    LabelPosition = lpLeft
                    TabOrder = 6
                  end
                  object btnSubQueryPH: TButton
                    Left = 403
                    Top = 53
                    Width = 66
                    Height = 22
                    Caption = #23376#26597#35810
                    TabOrder = 9
                    OnClick = btnAddFieldPSClick
                  end
                  object cbDictionaryDataValuePH: TComboBox
                    Tag = 2
                    Left = 305
                    Top = 54
                    Width = 163
                    Height = 21
                    Style = csDropDownList
                    ImeName = #20013#25991' ('#31616#20307') - '#24494#36719#25340#38899
                    ItemHeight = 13
                    TabOrder = 7
                    OnChange = chageDataValuePH
                  end
                  object dtpDataValuePH: TDateTimePicker
                    Tag = 1
                    Left = 305
                    Top = 53
                    Width = 163
                    Height = 21
                    Date = 38434.476233101900000000
                    Time = 38434.476233101900000000
                    DateFormat = dfLong
                    ImeName = #20013#25991' ('#31616#20307') - '#24494#36719#25340#38899
                    TabOrder = 8
                    OnChange = chageDataValuePH
                  end
                  object btnCiteParamHP: TBitBtn
                    Left = 442
                    Top = 78
                    Width = 27
                    Height = 21
                    Caption = '+'
                    TabOrder = 13
                  end
                end
                object PanelGroupRightBottom: TPanel
                  Left = 0
                  Top = 260
                  Width = 476
                  Height = 66
                  Align = alBottom
                  BevelOuter = bvNone
                  TabOrder = 2
                  object lbFormulaPH: TLabel
                    Left = 0
                    Top = 0
                    Width = 476
                    Height = 17
                    Align = alTop
                    AutoSize = False
                    Caption = #36923#36753#34920#36798#24335#65306
                    Font.Charset = DEFAULT_CHARSET
                    Font.Color = clWindowText
                    Font.Height = -14
                    Font.Name = 'MS Sans Serif'
                    Font.Style = []
                    ParentFont = False
                  end
                  object PanelGroupRightBottomRight: TPanel
                    Left = 384
                    Top = 17
                    Width = 92
                    Height = 49
                    Align = alRight
                    BevelOuter = bvNone
                    TabOrder = 0
                    object btnAndPH: TButton
                      Tag = 1
                      Left = 2
                      Top = 0
                      Width = 24
                      Height = 21
                      Caption = #24182
                      TabOrder = 0
                      OnClick = editConditionFormulaPH
                    end
                    object btnLeftBracketPH: TButton
                      Tag = 4
                      Left = 2
                      Top = 23
                      Width = 24
                      Height = 21
                      Caption = #65288
                      TabOrder = 3
                      OnClick = editConditionFormulaPH
                    end
                    object btnRightBracketPH: TButton
                      Tag = 5
                      Left = 29
                      Top = 23
                      Width = 24
                      Height = 21
                      Caption = #65289
                      TabOrder = 4
                      OnClick = editConditionFormulaPH
                    end
                    object btnNotPH: TButton
                      Tag = 3
                      Left = 56
                      Top = 0
                      Width = 28
                      Height = 44
                      Caption = #21462#21453
                      TabOrder = 2
                      OnClick = editConditionFormulaPH
                    end
                    object btnOrPH: TButton
                      Tag = 2
                      Left = 29
                      Top = 0
                      Width = 24
                      Height = 21
                      Caption = #25110
                      TabOrder = 1
                      OnClick = editConditionFormulaPH
                    end
                  end
                  object edHavingFormula: TMemo
                    Tag = 1
                    Left = 0
                    Top = 17
                    Width = 384
                    Height = 49
                    Align = alClient
                    ImeName = #20013#25991' ('#31616#20307') - '#24494#36719#25340#38899
                    TabOrder = 1
                    OnKeyPress = filterInputCharacter
                  end
                end
              end
            end
            object tabHavingSQL: TTabSheet
              Caption = 'SQL'#35821#21477
              ImageIndex = 1
              object edHavingSQL: TMemo
                Left = 0
                Top = 0
                Width = 646
                Height = 324
                Align = alClient
                ImeName = #20013#25991' ('#31616#20307') - '#24494#36719#25340#38899
                TabOrder = 0
              end
            end
          end
        end
        object tabOrder: TTabSheet
          Caption = #32467#26524#25490#24207
          ImageIndex = 5
          object pcOrder: TPageControl
            Left = 0
            Top = 0
            Width = 653
            Height = 352
            ActivePage = tabOrderWizard
            Align = alClient
            TabOrder = 0
            TabPosition = tpBottom
            OnChange = pcOrderChange
            object tabOrderWizard: TTabSheet
              Caption = #21521#23548
              object lvSelectedField: TListView
                Left = 0
                Top = 0
                Width = 169
                Height = 326
                Align = alLeft
                Columns = <
                  item
                    Caption = #23383#27573#21035#21517
                    Width = 0
                  end
                  item
                    Caption = #23383#27573#34920#36798#24335#25551#36848
                    Width = 100
                  end
                  item
                    Caption = #20195#30721
                    Width = 65
                  end>
                GridLines = True
                HideSelection = False
                ReadOnly = True
                RowSelect = True
                TabOrder = 0
                ViewStyle = vsReport
                OnDblClick = btnAddOrderPOClick
                OnSelectItem = lvSelectedFieldSelectItem
              end
              object PanelOrderClient: TPanel
                Left = 169
                Top = 0
                Width = 476
                Height = 326
                Align = alClient
                BevelOuter = bvNone
                TabOrder = 1
                object lvOrderField: TListView
                  Left = 0
                  Top = 0
                  Width = 476
                  Height = 258
                  Align = alClient
                  Columns = <
                    item
                      Caption = #23383#27573#21035#21517
                      Width = 0
                    end
                    item
                      Caption = #23383#27573#34920#36798#24335#25551#36848
                      Width = 100
                    end
                    item
                      AutoSize = True
                      Caption = #23383#27573#34920#36798#24335#20195#30721
                    end
                    item
                      Caption = #25490#24207#26041#24335
                      Width = 80
                    end>
                  GridLines = True
                  HideSelection = False
                  ReadOnly = True
                  RowSelect = True
                  TabOrder = 0
                  ViewStyle = vsReport
                  OnKeyDown = lvOrderFieldKeyDown
                end
                object PanelOrderClientBottom: TPanel
                  Left = 0
                  Top = 258
                  Width = 476
                  Height = 68
                  Align = alBottom
                  BevelOuter = bvNone
                  TabOrder = 1
                  object lbOrderType: TLabel
                    Left = 246
                    Top = 10
                    Width = 64
                    Height = 16
                    AutoSize = False
                    Caption = #25490#24207#26041#24335#65306
                  end
                  object btnMoveOrderUpPO: TButton
                    Left = 18
                    Top = 34
                    Width = 75
                    Height = 25
                    Caption = #19978#31227
                    TabOrder = 2
                    OnClick = btnMoveOrderUpPOClick
                  end
                  object btnMoveOrderDownPO: TButton
                    Left = 112
                    Top = 34
                    Width = 75
                    Height = 25
                    Caption = #19979#31227
                    TabOrder = 3
                    OnClick = btnMoveOrderDownPOClick
                  end
                  object btnAddOrderPO: TButton
                    Left = 300
                    Top = 34
                    Width = 75
                    Height = 25
                    Caption = #28155#21152
                    Default = True
                    TabOrder = 5
                    OnClick = btnAddOrderPOClick
                  end
                  object btnUpdateOrderPO: TButton
                    Left = 394
                    Top = 34
                    Width = 75
                    Height = 25
                    Caption = #26356#25913
                    TabOrder = 6
                    OnClick = btnUpdateOrderPOClick
                  end
                  object btnDeleteOrderPO: TButton
                    Left = 206
                    Top = 34
                    Width = 75
                    Height = 25
                    Caption = #21024#38500
                    TabOrder = 4
                    OnClick = btnDeleteOrderPOClick
                  end
                  object ledOrderField: TLabeledEdit
                    Left = 82
                    Top = 7
                    Width = 142
                    Height = 21
                    AutoSize = False
                    EditLabel.Width = 65
                    EditLabel.Height = 13
                    EditLabel.Caption = #25490#24207#23383#27573#65306
                    ImeName = #20013#25991' ('#31616#20307') - '#24494#36719#25340#38899
                    LabelPosition = lpLeft
                    ReadOnly = True
                    TabOrder = 0
                  end
                  object cbOrderType: TComboBox
                    Left = 326
                    Top = 7
                    Width = 143
                    Height = 21
                    Style = csDropDownList
                    ImeName = #20013#25991' ('#31616#20307') - '#24494#36719#25340#38899
                    ItemHeight = 13
                    ItemIndex = 0
                    TabOrder = 1
                    Text = #21319#24207
                    OnSelect = updateSqlAndDescInSP
                    Items.Strings = (
                      #21319#24207
                      #38477#24207)
                  end
                end
              end
            end
            object tabOrderSQL: TTabSheet
              Caption = 'SQL'#35821#21477
              ImageIndex = 1
              object edOrderSQL: TMemo
                Left = 0
                Top = 0
                Width = 646
                Height = 324
                Align = alClient
                ImeName = #20013#25991' ('#31616#20307') - '#24494#36719#25340#38899
                TabOrder = 0
              end
            end
          end
        end
        object tabParam: TTabSheet
          Caption = #21442#25968#35774#23450
          ImageIndex = 6
          object lvParams: TListView
            Left = 0
            Top = 0
            Width = 653
            Height = 274
            Align = alClient
            Columns = <
              item
                Caption = #21442#25968#25551#36848
                Width = 300
              end
              item
                Caption = #40664#35748#20540
                Width = 120
              end>
            GridLines = True
            HideSelection = False
            ReadOnly = True
            RowSelect = True
            TabOrder = 0
            ViewStyle = vsReport
            OnSelectItem = lvParamsSelectItem
          end
          object pcParamOptPanel: TPanel
            Left = 0
            Top = 274
            Width = 653
            Height = 78
            Align = alBottom
            BevelOuter = bvNone
            TabOrder = 1
            object ledNewParamDesc: TLabeledEdit
              Left = 72
              Top = 32
              Width = 161
              Height = 21
              EditLabel.Width = 65
              EditLabel.Height = 13
              EditLabel.Caption = #21442#25968#25551#36848#65306
              ImeName = #20013#25991' ('#31616#20307') - '#24494#36719#25340#38899
              LabelPosition = lpLeft
              TabOrder = 0
            end
            object btnDeleteParam: TButton
              Left = 575
              Top = 32
              Width = 61
              Height = 23
              Caption = #21024#38500
              TabOrder = 1
              OnClick = btnDeleteParamClick
            end
            object btnAddParam: TButton
              Left = 435
              Top = 32
              Width = 60
              Height = 23
              Caption = #28155#21152
              Default = True
              TabOrder = 2
              OnClick = btnAddParamClick
            end
            object btnUpdateParam: TButton
              Left = 506
              Top = 32
              Width = 61
              Height = 23
              Caption = #26356#25913
              TabOrder = 3
              OnClick = btnUpdateParamClick
            end
            object ledNewParamDefValue: TLabeledEdit
              Left = 312
              Top = 32
              Width = 105
              Height = 21
              EditLabel.Width = 52
              EditLabel.Height = 13
              EditLabel.Caption = #40664#35748#20540#65306
              ImeName = #20013#25991' ('#31616#20307') - '#24494#36719#25340#38899
              LabelPosition = lpLeft
              TabOrder = 4
            end
          end
        end
      end
    end
    object tabMDLWizard: TTabSheet
      Caption = 'MDL'#21521#23548
      ImageIndex = 4
      object lbMDLDesc: TLabel
        Left = 200
        Top = 152
        Width = 201
        Height = 25
        AutoSize = False
        Caption = #35774#35745' update / delete / insert '#35821#21477
      end
    end
    object tabDDLWizard: TTabSheet
      Caption = 'DDL'#21521#23548
      ImageIndex = 5
      object lbDDLDesc: TLabel
        Left = 208
        Top = 136
        Width = 193
        Height = 25
        AutoSize = False
        Caption = #35774#35745' create / alter / drop '#35821#21477
      end
    end
    object tabSQL: TTabSheet
      Caption = 'SQL'#35821#21477
      ImageIndex = 1
      object edSQL: TMemo
        Left = 0
        Top = 0
        Width = 661
        Height = 380
        Align = alClient
        ImeName = #20013#25991' ('#31616#20307') - '#24494#36719#25340#38899
        TabOrder = 0
      end
    end
    object tabRunAsMode: TTabSheet
      Caption = #27979#35797#36816#34892
      ImageIndex = 2
      object edResult: TMemo
        Left = 0
        Top = 0
        Width = 661
        Height = 380
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Fixedsys'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
      end
    end
    object tabSetting: TTabSheet
      Caption = #35774#32622
      DragMode = dmAutomatic
      ImageIndex = 3
      object gbShowSetting: TGroupBox
        Left = 16
        Top = 8
        Width = 464
        Height = 167
        Caption = #39029#38754#37197#32622
        TabOrder = 0
        object cbShowSelect: TCheckBox
          Tag = 1
          Left = 28
          Top = 24
          Width = 99
          Height = 17
          Caption = #26597#35810#20869#23481
          TabOrder = 0
          OnClick = changeShowSetting
        end
        object cbShowFrom: TCheckBox
          Tag = 2
          Left = 142
          Top = 24
          Width = 97
          Height = 17
          Caption = #26597#35810#34920#26684
          TabOrder = 1
          OnClick = changeShowSetting
        end
        object cbShowWhere: TCheckBox
          Tag = 3
          Left = 251
          Top = 24
          Width = 88
          Height = 17
          Caption = #26597#35810#26465#20214
          TabOrder = 2
          OnClick = changeShowSetting
        end
        object cbShowGroup: TCheckBox
          Tag = 4
          Left = 28
          Top = 52
          Width = 99
          Height = 17
          Caption = #20998#32452
          TabOrder = 3
          OnClick = changeShowSetting
        end
        object cbShowHaving: TCheckBox
          Tag = 5
          Left = 142
          Top = 52
          Width = 97
          Height = 17
          Caption = #20998#32452#36807#28388
          TabOrder = 4
          OnClick = changeShowSetting
        end
        object cbShowOrder: TCheckBox
          Tag = 6
          Left = 251
          Top = 52
          Width = 88
          Height = 17
          Caption = #32467#26524#25490#24207
          TabOrder = 5
          OnClick = changeShowSetting
        end
        object cbAutoShowGroup: TCheckBox
          Tag = 7
          Left = 28
          Top = 80
          Width = 99
          Height = 17
          Caption = #20998#32452#33258#21160#26174#31034
          TabOrder = 6
          OnClick = changeShowSetting
        end
        object cbAutoShowHaving: TCheckBox
          Tag = 8
          Left = 142
          Top = 80
          Width = 97
          Height = 17
          Caption = #20998#32452#36807#28388#33258#21160
          TabOrder = 7
          OnClick = changeShowSetting
        end
        object cbShowWizard: TCheckBox
          Tag = 9
          Left = 251
          Top = 80
          Width = 99
          Height = 17
          Caption = #26597#35810#21521#23548
          TabOrder = 8
          OnClick = changeShowSetting
        end
        object cbShowRun: TCheckBox
          Tag = 10
          Left = 251
          Top = 108
          Width = 97
          Height = 17
          Caption = #36816#34892
          TabOrder = 9
          OnClick = changeShowSetting
        end
        object cbShowSetting: TCheckBox
          Tag = 11
          Left = 28
          Top = 137
          Width = 88
          Height = 17
          Caption = #35774#32622
          TabOrder = 10
          OnClick = changeShowSetting
        end
        object cbShowSqlName: TCheckBox
          Tag = 12
          Left = 142
          Top = 137
          Width = 99
          Height = 17
          Caption = #35821#21477#25551#36848
          TabOrder = 11
          OnClick = changeShowSetting
        end
        object cbShowCheckSql: TCheckBox
          Tag = 13
          Left = 251
          Top = 137
          Width = 97
          Height = 17
          Caption = #26816#26597#35821#21477
          TabOrder = 12
          OnClick = changeShowSetting
        end
        object rgShowSQL: TRadioGroup
          Left = 351
          Top = 16
          Width = 98
          Height = 138
          BiDiMode = bdLeftToRight
          Caption = 'SQL'#33050#26412#39029#38754
          Items.Strings = (
            #38544#34255
            #21482#35835
            #27491#24120)
          ParentBiDiMode = False
          TabOrder = 13
          OnClick = rgShowSQLClick
        end
        object cbShowMDLWizard: TCheckBox
          Tag = 14
          Left = 28
          Top = 108
          Width = 97
          Height = 17
          Caption = 'MDL'#21521#23548
          TabOrder = 14
          OnClick = changeShowSetting
        end
        object cbShowDDLWizard: TCheckBox
          Tag = 15
          Left = 142
          Top = 108
          Width = 97
          Height = 17
          Caption = 'DDL'#21521#23548
          TabOrder = 15
          OnClick = changeShowSetting
        end
      end
      object gbDBSetting: TGroupBox
        Left = 16
        Top = 182
        Width = 625
        Height = 185
        Caption = #25968#25454#24211#35774#32622
        TabOrder = 1
        object lbDBtypeInSet: TLabel
          Left = 58
          Top = 19
          Width = 70
          Height = 13
          AutoSize = False
          Caption = #25968#25454#24211#31867#21035#65306
        end
        object cbDBType: TComboBox
          Left = 133
          Top = 17
          Width = 145
          Height = 21
          Style = csDropDownList
          ImeName = #20013#25991' ('#31616#20307') - '#24494#36719#25340#38899
          ItemHeight = 13
          ItemIndex = 0
          TabOrder = 0
          Text = 'SQL Server'
          OnChange = cbDBTypeChange
          Items.Strings = (
            'SQL Server'
            'MS Access'
            'DB2'
            'Oracle')
        end
        object ledDBConn: TLabeledEdit
          Left = 132
          Top = 44
          Width = 407
          Height = 21
          EditLabel.Width = 84
          EditLabel.Height = 13
          EditLabel.Caption = #25968#25454#24211#36830#25509#20018#65306
          ImeName = #20013#25991' ('#31616#20307') - '#24494#36719#25340#38899
          LabelPosition = lpLeft
          TabOrder = 1
        end
        object edGetTabSQL: TLabeledEdit
          Left = 132
          Top = 71
          Width = 476
          Height = 21
          EditLabel.Width = 84
          EditLabel.Height = 13
          EditLabel.Caption = #20379#26597#35810#34920#35821#21477#65306
          ImeName = #20013#25991' ('#31616#20307') - '#24494#36719#25340#38899
          LabelPosition = lpLeft
          TabOrder = 2
        end
        object edGetColSQL: TLabeledEdit
          Left = 132
          Top = 98
          Width = 476
          Height = 21
          EditLabel.Width = 96
          EditLabel.Height = 13
          EditLabel.Caption = #20379#26597#35810#23383#27573#35821#21477#65306
          ImeName = #20013#25991' ('#31616#20307') - '#24494#36719#25340#38899
          LabelPosition = lpLeft
          TabOrder = 3
        end
        object edGetRelSQL: TLabeledEdit
          Left = 132
          Top = 125
          Width = 476
          Height = 21
          EditLabel.Width = 96
          EditLabel.Height = 13
          EditLabel.Caption = #20379#26597#35810#20851#31995#35821#21477#65306
          ImeName = #20013#25991' ('#31616#20307') - '#24494#36719#25340#38899
          LabelPosition = lpLeft
          TabOrder = 4
        end
        object edGetRelDetailSQL: TLabeledEdit
          Left = 132
          Top = 153
          Width = 476
          Height = 21
          EditLabel.Width = 120
          EditLabel.Height = 13
          EditLabel.Caption = #20379#26597#35810#20851#31995#26126#32454#35821#21477#65306
          ImeName = #20013#25991' ('#31616#20307') - '#24494#36719#25340#38899
          LabelPosition = lpLeft
          TabOrder = 5
        end
        object btnSetDBConn: TButton
          Left = 546
          Top = 41
          Width = 61
          Height = 25
          Caption = #35774#32622
          TabOrder = 6
          OnClick = btnSetDBConnClick
        end
      end
      object gbRunSeting: TGroupBox
        Left = 492
        Top = 8
        Width = 147
        Height = 167
        Caption = #36816#34892#35774#32622
        TabOrder = 2
        object lbRetFirstRows: TLabel
          Left = 9
          Top = 99
          Width = 121
          Height = 13
          Caption = #26597#35810#26102#20165#36820#22238#21069'[X]'#34892#65306
        end
        object cbCanRunMDL: TCheckBox
          Tag = 16
          Left = 24
          Top = 36
          Width = 97
          Height = 17
          Caption = #21487#36816#34892'MDL'
          TabOrder = 0
          OnClick = changeShowSetting
        end
        object cbCanRunDDL: TCheckBox
          Tag = 17
          Left = 24
          Top = 66
          Width = 97
          Height = 17
          Caption = #21487#36816#34892'DDL'
          TabOrder = 1
          OnClick = changeShowSetting
        end
        object edRetFirstRows: TEdit
          Tag = 3
          Left = 64
          Top = 124
          Width = 59
          Height = 21
          ImeName = #20013#25991' ('#31616#20307') - '#24494#36719#25340#38899
          MaxLength = 4
          TabOrder = 2
          Text = '10'
          OnChange = edRetFirstRowsChange
          OnKeyPress = filterInputCharacter
        end
      end
    end
  end
  object panelBottom: TPanel
    Left = 0
    Top = 388
    Width = 687
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    OnDblClick = showSettingPage
    object panelBottomRight: TPanel
      Left = 359
      Top = 0
      Width = 328
      Height = 41
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 0
      object btnCancel: TButton
        Left = 219
        Top = 8
        Width = 89
        Height = 25
        Caption = #36864#20986
        ModalResult = 2
        TabOrder = 0
        OnClick = btnCancelClick
      end
      object btnOK: TButton
        Left = 121
        Top = 8
        Width = 89
        Height = 25
        Caption = #30830#23450
        ModalResult = 1
        TabOrder = 1
        OnClick = btnOKClick
      end
      object btnCheckSql: TButton
        Left = 23
        Top = 8
        Width = 89
        Height = 25
        Caption = #26816#26597#35821#21477
        TabOrder = 2
        OnClick = btnCheckSqlClick
      end
    end
    object ledSQLName: TLabeledEdit
      Left = 78
      Top = 10
      Width = 281
      Height = 21
      AutoSize = False
      EditLabel.Width = 65
      EditLabel.Height = 13
      EditLabel.Caption = #35821#21477#25551#36848#65306
      ImeName = #20013#25991' ('#31616#20307') - '#24494#36719#25340#38899
      LabelPosition = lpLeft
      TabOrder = 1
    end
  end
  object pmParam: TPopupMenu
    AutoHotkeys = maManual
    Left = 632
  end
end
