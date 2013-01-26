object CommDB: TCommDB
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Left = 424
  Top = 299
  Height = 164
  Width = 185
  object ADOQuery: TADOQuery
    Connection = ADOConn
    Parameters = <>
    Left = 40
    Top = 16
  end
  object ADOConn: TADOConnection
    Left = 104
    Top = 24
  end
end
