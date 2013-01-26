object CommDB: TCommDB
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Left = 531
  Top = 314
  Height = 263
  Width = 235
  object ADOQuery: TADOQuery
    Connection = ADOConn
    LockType = ltBatchOptimistic
    CommandTimeout = 30000
    EnableBCD = False
    Parameters = <>
    Left = 32
    Top = 24
  end
  object ADOConn: TADOConnection
    CommandTimeout = 30000
    ConnectionTimeout = 30
    Left = 120
    Top = 24
  end
  object ADOExecute: TADOQuery
    Connection = ADOConn
    LockType = ltBatchOptimistic
    CommandTimeout = 30000
    EnableBCD = False
    Parameters = <>
    Left = 32
    Top = 88
  end
end
