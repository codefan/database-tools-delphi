(*
 Name : QueryWizard.pas
 author: 杨淮生  E-mail id:codefan@sina.com codefan@centit.com
 create date: 2005/03/01

 purpose: 统一的查询统计工具
 Modification History：
    2006/08/24 ：增加查询字段之间的关系计算

 要能正确使用本单元,必须有四个元数据表
	供查询表元数据表(Q_MD_TABLE)
    TBCODE	char(32)	表代码
    TBNAME	char(64)	表名称
    TBTYPE	char(1)	类别   v:不在根目录出现,在关联中可以出现
    TBSTATE	char(1)	状态   F:不出现
    TBDESC	varchar(256)	描述
 	供查询字段元数据表(Q_MD_COLUMN)
    TBCODE	char(32)	表代码
    COLCODE	char(32)	字段代码
    COLNAME	char(64)	字段名称
    COLTYPE	char(32)	字段类型
    ACCETYPE	char(1)	字段类别
    COLSTATE	char(1)	状态     F:不出现
    REFDATACODE	varchar(1024)	参考值代码
  供查询表关联关系表(Q_MD_RELATION)
    RELCODE	char(32)	关联代码
    RELNAME	char(64)	关联名称
    PTABCODE	char(32)	p表代码
    CTABCODE	char(32)	c表代码
    RELSTATE	char(1)	状态     F:无效
	供查询表关联细节表 (Q_MD_REL_DETIAL)
    RELCODE	char(32)	关联代码
    PCOLCODE	char(32)	p字段代码
    CCOLCODE	char(32)	c字段代码

  interface :
    in:: m_Config:SConfig;
    out:: m_Result:SQuerySQL;

  precondition:
    uses CommonFunc,DBConn;

*)


unit QueryWizard;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls,Contnrs, ImgList, Buttons, Menus;
const
  MAX_COL_PRE_REL = 7;
  SPARAM_PREFIX = ':PRM_NO';
type
  DATABASETYPE = (SQLServer, MSAccess, DB2, Oracle);
  RETURN_SQL_TYPE = (SQL_QUERY, SQL_MDL, SQL_DDL);
  COLDATATYPE = (CT_NONE,CT_NUM, CT_CHAR, CT_STRING,CT_DATE,CT_TIME,CT_DATETIME);
  //QUERY_WIZARD_PANEL_TYPE = (pSelect, pFrom, pWhere, pGroup, pHaving, pOrder);
  PANELSET = set of (pSelect, pFrom, pWhere, pGroup, pHaving, pOrder, pParam);
  SDBConfig = Record
    DBType:DATABASETYPE;
    sGetTabSql:String;
    sGetColSql:String;
    sGetRelSql:String;
    sGetRelDetailSql:String;
  end;

  SQuerySQL = Record
    sqlType : RETURN_SQL_TYPE;
    sSQL:String;
    sSqlName:String;
    nFieldSum:integer;
    sFieldDesc:String;
    nPrmSum:integer;
    sPrmDesc:String;
  end;

  //function VaiantToQuerySQL(const OleVar:OleVariant):sWfRoleInfo;

  SConfig = Record
    sTitle:String;
    bCanNamed:boolean;
    sSqlName:String;
    dbConfig:SDBConfig;
    showPanelSet:PANELSET;
    bAutoShowGroup:boolean;
    bAutoShowHaving:boolean;
    bCheckSql:boolean;
    bShowWizard:boolean;
    bShowRun:boolean;
    bShowSetting:boolean;
    nShowSQL : Integer; // 0:隐藏,1:只读,2:正常
    bShowMDLWizard:boolean;
    bShowDDLWizard:boolean;
    bCanRunMDL:boolean;
    bCanRunDDL:boolean;

    bFieldTable:boolean;
    sTabFields:String;
    sStartTable:String;
    nTableNameType:Integer;// 1:别名,2:原表名,3:无
    nFirstRowsOnly:integer;
    nQueryAsModeRows:integer;
  end;

  PTableRec = ^STableRec;
  STableRec = Record
    sTBCode,sTBName,sTBType,sTBDESC:String;
    nSelectRef,nWhereRef:integer;
  end;

  PColumnRec = ^SColumnRec;
  SColumnRec = Record
    sTBCode,sColCode,sColName,sColType,sRefDataCode:String;
  end;

  PRelRecDetail = ^SRelRecDetail;
  SRelRecDetail = Record
    sPColCode,sCColCode:String;
  end;

  PRelRec = ^SRelRec;
  SRelRec = Record
    sRelCode,sRelName,sPTBCode,sCTBCode:String;
    nJoinType:Integer;
    nDetailSum:integer;
    relDetail : array [0..MAX_COL_PRE_REL] of SRelRecDetail;
  end;

  PTreeItemData = ^STreeItemData;
  STreeItemData = Record
    nStype:Integer; // 0: 字段， 1:字段集  2:表  3:关联表
    bExpand:boolean;
    sTabName:String;
    pParent: PTreeItemData;
    data : Pointer;
    data2 : Pointer;
  end;

  PSelectItemData = ^SSelectItemData;
  SSelectItemData = Record
    bStat:boolean;
    dataType:COLDATATYPE;
    pTreeItem:PTreeItemData;
  end;

  PColOperate = ^SColOperate;
  SColOperate = Record
    dataType:COLDATATYPE;//num,char,time,date,datetime,string
    sOptName:String;
    nOptPrmSum:Integer;
    bStatOpt:boolean;
    retType:COLDATATYPE;//num,char,time,date,datetime,string
    sOptSqlFmt:String;
    sOptDescFmt:String;
  end;

//  SParam = String;

  TfrQueryWizard = class(TForm)
    pcDesign: TPageControl;
    tabWizard: TTabSheet;
    tabSQL: TTabSheet;
    edSQL: TMemo;
    trRelation: TPageControl;
    tabSelect: TTabSheet;
    tabFrom: TTabSheet;
    tabWhere: TTabSheet;
    tabGroup: TTabSheet;
    tabHaving: TTabSheet;
    tabOrder: TTabSheet;
    pcSelect: TPageControl;
    tabSelectWizard: TTabSheet;
    tabSelectSQL: TTabSheet;
    edSelectSQL: TMemo;
    pcWhere: TPageControl;
    tabWhereWizard: TTabSheet;
    tabWhereSQL: TTabSheet;
    edWhereSQL: TMemo;
    pcGroup: TPageControl;
    tabGroupWizard: TTabSheet;
    tabGroupSQL: TTabSheet;
    edGroupSQL: TMemo;
    pcHaving: TPageControl;
    tabHavingWizard: TTabSheet;
    tabHavingSQL: TTabSheet;
    edHavingSQL: TMemo;
    pcOrder: TPageControl;
    tabOrderWizard: TTabSheet;
    tabOrderSQL: TTabSheet;
    edOrderSQL: TMemo;
    panelBottom: TPanel;
    panelBottomRight: TPanel;
    btnCancel: TButton;
    btnOK: TButton;
    trTableColPS: TTreeView;
    trTableColPW: TTreeView;
    btnCheckSql: TButton;
    lvConditionPW: TListView;
    panelWhereRight: TPanel;
    panelWhereRightBottom: TPanel;
    panelWhereRightBottomRight: TPanel;
    lbFormulaPW: TLabel;
    btnAndPW: TButton;
    btnLeftBracketPW: TButton;
    btnRightBracketPW: TButton;
    btnNotPW: TButton;
    btnOrPW: TButton;
    PanelWhereRigthCenter: TPanel;
    lvSelectFieldNoStat: TListView;
    lvHavingField: TListView;
    lvSelectedField: TListView;
    lvOrderField: TListView;
    PanelOrderClient: TPanel;
    PanelOrderClientBottom: TPanel;
    PanelSelectClient: TPanel;
    lvSelectingField: TListView;
    PanelSelectClientBottom: TPanel;
    ledFieldDescPS: TLabeledEdit;
    lbDealFieldPS: TLabel;
    cbDealFieldPS: TComboBox;
    btnAddFieldPS: TButton;
    btnDeleteFieldPS: TButton;
    btnUpdateFieldPS: TButton;
    ledDealFieldPrm1PS: TLabeledEdit;
    ledDealFieldPrm2PS: TLabeledEdit;
    ledSQLName: TLabeledEdit;
    ledFieldSqlPS: TLabeledEdit;
    btnMoveSelectUpPS: TButton;
    btnMoveSelectDownPS: TButton;
    pcFrom: TPageControl;
    tabFromWizard: TTabSheet;
    lvTabJoin: TListView;
    panelFromBottom: TPanel;
    ledTable2PF: TLabeledEdit;
    cbTabJoinType: TComboBox;
    btnChangeJionTyoePF: TButton;
    ledTable1PF: TLabeledEdit;
    tabFromSQL: TTabSheet;
    edFromSQL: TMemo;
    tabRunAsMode: TTabSheet;
    tabSetting: TTabSheet;
    edResult: TMemo;
    gbShowSetting: TGroupBox;
    rgShowSQL: TRadioGroup;
    cbShowSelect: TCheckBox;
    cbShowFrom: TCheckBox;
    cbShowWhere: TCheckBox;
    cbShowGroup: TCheckBox;
    cbShowHaving: TCheckBox;
    cbShowOrder: TCheckBox;
    cbAutoShowGroup: TCheckBox;
    cbAutoShowHaving: TCheckBox;
    cbShowWizard: TCheckBox;
    cbShowRun: TCheckBox;
    cbShowSetting: TCheckBox;
    gbDBSetting: TGroupBox;
    cbShowSqlName: TCheckBox;
    cbShowCheckSql: TCheckBox;
    cbDBType: TComboBox;
    ledDBConn: TLabeledEdit;
    edGetTabSQL: TLabeledEdit;
    edGetColSQL: TLabeledEdit;
    edGetRelSQL: TLabeledEdit;
    edGetRelDetailSQL: TLabeledEdit;
    lbDBtypeInSet: TLabel;
    btnSetDBConn: TButton;
    edWhereFormula: TMemo;
    lvConditionPH: TListView;
    PanelHavingClient: TPanel;
    lbDealTypePW: TLabel;
    ledDealFieldPrm1PW: TLabeledEdit;
    ledDealFieldPrm2PW: TLabeledEdit;
    ledFieldSqlPW: TLabeledEdit;
    ledFieldDescPW: TLabeledEdit;
    cbDealFieldPW: TComboBox;
    btnAddConditionPW: TButton;
    btnUpdateConditionPW: TButton;
    lbLogicOptPW: TLabel;
    cbLogicOptPW: TComboBox;
    ledValuePW: TLabeledEdit;
    btnSubQuery: TButton;
    lbDictionaryValue: TLabel;
    cbDictionaryDataValue: TComboBox;
    dtpDataValue: TDateTimePicker;
    btnMoveOrderUpPO: TButton;
    btnMoveOrderDownPO: TButton;
    btnAddOrderPO: TButton;
    btnUpdateOrderPO: TButton;
    btnDeleteOrderPO: TButton;
    ledOrderField: TLabeledEdit;
    cbOrderType: TComboBox;
    lbOrderType: TLabel;
    PanelGroupRightMiddle: TPanel;
    lbDealFieldPH: TLabel;
    lbLogicOptPH: TLabel;
    lbDictionaryValuePH: TLabel;
    ledDealFieldPrm1PH: TLabeledEdit;
    ledDealFieldPrm2PH: TLabeledEdit;
    ledFieldSqlPH: TLabeledEdit;
    ledFieldDescPH: TLabeledEdit;
    cbDealFieldPH: TComboBox;
    btnAddConditionPH: TButton;
    btnUpdateConditionPH: TButton;
    btnDeleteConditionPH: TButton;
    cbLogicOptPH: TComboBox;
    ledValuePH: TLabeledEdit;
    btnSubQueryPH: TButton;
    cbDictionaryDataValuePH: TComboBox;
    dtpDataValuePH: TDateTimePicker;
    PanelGroupRightBottom: TPanel;
    lbFormulaPH: TLabel;
    PanelGroupRightBottomRight: TPanel;
    btnAndPH: TButton;
    btnLeftBracketPH: TButton;
    btnRightBracketPH: TButton;
    btnNotPH: TButton;
    btnOrPH: TButton;
    edHavingFormula: TMemo;
    gbRunSeting: TGroupBox;
    cbCanRunMDL: TCheckBox;
    cbCanRunDDL: TCheckBox;
    edRetFirstRows: TEdit;
    lbRetFirstRows: TLabel;
    tabMDLWizard: TTabSheet;
    tabDDLWizard: TTabSheet;
    lbMDLDesc: TLabel;
    lbDDLDesc: TLabel;
    cbShowMDLWizard: TCheckBox;
    cbShowDDLWizard: TCheckBox;
    btnDeleteConditionPW: TButton;
    panelFromBottomRight: TPanel;
    ledFieldAlias: TLabeledEdit;
    tabParam: TTabSheet;
    lvParams: TListView;
    pcParamOptPanel: TPanel;
    ledNewParamDesc: TLabeledEdit;
    btnDeleteParam: TButton;
    btnAddParam: TButton;
    btnUpdateParam: TButton;
    btnCiteParamWP: TBitBtn;
    btnCiteParamHP: TBitBtn;
    pmParam: TPopupMenu;
    cbCurrentDate: TCheckBox;
    ledNewParamDefValue: TLabeledEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure trTableColPSChange(Sender: TObject; Node: TTreeNode);
    procedure updateSqlAndDescInSP(Sender: TObject);
    procedure btnAddFieldPSClick(Sender: TObject);
    procedure btnUpdateFieldPSClick(Sender: TObject);
    procedure btnDeleteFieldPSClick(Sender: TObject);
    procedure btnMoveSelectUpPSClick(Sender: TObject);
    procedure btnMoveSelectDownPSClick(Sender: TObject);
    procedure pcSelectChange(Sender: TObject);
    procedure changeShowSetting(Sender: TObject);
    procedure rgShowSQLClick(Sender: TObject);
    procedure pcDesignChange(Sender: TObject);
    procedure showSettingPage(Sender: TObject);
    procedure trTableColPWChange(Sender: TObject; Node: TTreeNode);
    procedure updateSqlAndDescInPW(Sender: TObject);
    procedure cbLogicOptPWSelect(Sender: TObject);
    procedure chageDataValuePW(Sender: TObject);
    procedure btnAddConditionPWClick(Sender: TObject);
    procedure btnUpdateConditionPWClick(Sender: TObject);
    procedure editConditionFormulaPW(Sender: TObject);
    procedure pcWhereChange(Sender: TObject);
    procedure filterInputCharacter(Sender: TObject; var Key: Char);
    procedure btnCheckSqlClick(Sender: TObject);
    procedure trTableColPSDblClick(Sender: TObject);
    procedure deleteTreeItemData(Sender: TObject; Node: TTreeNode);
    procedure trTableColPSExpanded(Sender: TObject; Node: TTreeNode);
    procedure trTableColPWExpanded(Sender: TObject; Node: TTreeNode);
    procedure btnDeleteConditionPWClick(Sender: TObject);
    procedure lvTabJoinSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure btnChangeJionTyoePFClick(Sender: TObject);
    procedure lvSelectingFieldDeletion(Sender: TObject; Item: TListItem);
    procedure pcFromChange(Sender: TObject);
    procedure pcGroupChange(Sender: TObject);
    procedure lvSelectedFieldSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure lvHavingFieldSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure editConditionFormulaPH(Sender: TObject);
    procedure updateSqlAndDescInPH(Sender: TObject);
    procedure cbLogicOptPHSelect(Sender: TObject);
    procedure chageDataValuePH(Sender: TObject);
    procedure btnAddConditionPHClick(Sender: TObject);
    procedure btnUpdateConditionPHClick(Sender: TObject);
    procedure btnDeleteConditionPHClick(Sender: TObject);
    procedure pcHavingChange(Sender: TObject);
    procedure btnAddOrderPOClick(Sender: TObject);
    procedure btnDeleteOrderPOClick(Sender: TObject);
    procedure btnUpdateOrderPOClick(Sender: TObject);
    procedure btnMoveOrderUpPOClick(Sender: TObject);
    procedure btnMoveOrderDownPOClick(Sender: TObject);
    procedure pcOrderChange(Sender: TObject);
    procedure trRelationChange(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure lvSelectingFieldKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lvConditionPWKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lvConditionPHKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lvOrderFieldKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure cbDBTypeChange(Sender: TObject);
    procedure btnAddParamClick(Sender: TObject);
    procedure btnUpdateParamClick(Sender: TObject);
    procedure btnDeleteParamClick(Sender: TObject);
    procedure lvParamsSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure btnCiteParamWPClick(Sender: TObject);
    procedure cbCurrentDateClick(Sender: TObject);
    procedure edRetFirstRowsChange(Sender: TObject);
    procedure btnSetDBConnClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
  private
    { Private declarations }
    m_bCreate : boolean;
    m_preRelationPage : TTabSheet;
    m_preDesignPage : TTabSheet;
    m_nPreTab:integer;
    m_nPreWizardTab:Integer;
    m_QTables : array of STableRec;
    m_QTabCols : array of SColumnRec;
    m_QRelation : array of SRelRec;
    m_nTabSum,m_nColSum,m_nRelSum:integer;
    //select panel var
    m_preSelColSP: PTreeItemData;
    m_preSelColWP: PTreeItemData;
    m_preColTypeWP: COLDATATYPE;
    m_preColTypeHP: COLDATATYPE;
  private
    procedure changeLogicComboBox(cbLogicOpt:TComboBox;dataType:COLDATATYPE);
    procedure loadDictionaryData(cbDictData:TComboBox;refSataCode:String);
    procedure treeItemStepit(tvTable:TTreeView;tnTab:TTreeNode);

    function checkFormulaInput(panelType{where:1,Having:2}:integer;const bSetSql:boolean=false):boolean;

    function trimFormulaInput(const sInSql:string;nDelCon:integer=0):string;

    function makeTableList(const bFillFromPanel:boolean=true):boolean;
    procedure makeParamList;


    procedure makeGroupPanel(const bFileGroupPanel:boolean=true);
    function configHavingField:boolean;
    function configOrderField:boolean;
    function IsParameter(const sValue:string):integer;
    function TrimInputConditionValue(const nPrmSum:integer;const dataType:COLDATATYPE; var sValue:String):boolean;

    procedure makeQuerySql(changePanels:PANELSET;bWholeSql:boolean=false);
    procedure trimQuerySql;
    procedure QueryTopRows;

    function  CheckInputSql:boolean;
    procedure AddParam(Sender: TObject);
  public  //interface
    { Public declarations }
    m_Config:SConfig;
    m_Result:SQuerySQL;
  public
    procedure ShowWhereOnly;
    procedure ShowWithoutGroup;
    procedure ShowNormal;
    procedure ShowAll;
    class function GetDataType(const sTypeDesc:String):COLDATATYPE;
  end;

  function QuerySQLToVaiant(const sQLInfo:SQuerySQL):OleVariant;

const
//  DATABASETYPE = (SQLServer, MSAccess, DB2, Oracle);

  ACCESS_Config : SDBConfig =(
    DBType :MSAccess;
    sGetTabSql : 'select TBCODE,TBNAME,TBTYPE,TBDESC from Q_MD_TABLE ';//'where (TBSTATE=''T'')';
    sGetColSql : 'select TBCODE,COLCODE,COLNAME,COLTYPE,REFDATACODE,ACCETYPE from Q_MD_COLUMN ';//where (COLSTATE=''T'')';
    sGetRelSql : 'select RELCODE,RELNAME,PTABCODE,CTABCODE from Q_MD_RELATION ';//where (RELSTATE=''T'')';
    sGetRelDetailSql : 'select RELCODE,PCOLCODE,CCOLCODE from Q_MD_REL_DETIAL';
  );

  ORACLE_Config : SDBConfig =(
    DBType :Oracle;
    sGetTabSql : 'select TBCODE,TBNAME,TBTYPE,TBDESC from Q_MD_TABLE ';//'where (TBSTATE=''T'')';
    sGetColSql : 'select TBCODE,COLCODE,COLNAME,COLTYPE,REFDATACODE,ACCETYPE from Q_MD_COLUMN ';//where (COLSTATE=''T'')';
    sGetRelSql : 'select RELCODE,RELNAME,PTABCODE,CTABCODE from Q_MD_RELATION ';//where (RELSTATE=''T'')';
    sGetRelDetailSql : 'select RELCODE,PCOLCODE,CCOLCODE from Q_MD_REL_DETIAL';
  );
  DB2_Config : SDBConfig =(
    DBType :DB2;
    sGetTabSql : 'select TBCODE,TBNAME,TBTYPE,TBDESC from Q_MD_TABLE ';//'where (TBSTATE=''T'')';
    sGetColSql : 'select TBCODE,COLCODE,COLNAME,COLTYPE,REFDATACODE,ACCETYPE from Q_MD_COLUMN ';//where (COLSTATE=''T'')';
    sGetRelSql : 'select RELCODE,RELNAME,PTABCODE,CTABCODE from Q_MD_RELATION ';//where (RELSTATE=''T'')';
    sGetRelDetailSql : 'select RELCODE,PCOLCODE,CCOLCODE from Q_MD_REL_DETIAL';
  );
  SQLSERVER_Config : SDBConfig =(
    DBType :SQLServer;
    sGetTabSql : 'select TBCODE,TBNAME,TBTYPE,TBDESC from Q_MD_TABLE ';//'where (TBSTATE=''T'')';
    sGetColSql : 'select TBCODE,COLCODE,COLNAME,COLTYPE,REFDATACODE,ACCETYPE from Q_MD_COLUMN ';//where (COLSTATE=''T'')';
    sGetRelSql : 'select RELCODE,RELNAME,PTABCODE,CTABCODE from Q_MD_RELATION ';//where (RELSTATE=''T'')';
    sGetRelDetailSql : 'select RELCODE,PCOLCODE,CCOLCODE from Q_MD_REL_DETIAL';
  );


  CONOPTMAXIND=29;
//(CT_NUM, CT_CHAR, CT_STRING,CT_DATE,CT_TIME,CT_DATETIME);
  conOptList : array [0..CONOPTMAXIND] of SColOperate=(
    (dataType:CT_NONE;sOptName:'无操作';nOptPrmSum:0;bStatOpt:false;retType:CT_NONE;
        sOptSqlFmt:'%s';sOptDescFmt:'%s'),

    (dataType:CT_NUM;sOptName:'+';nOptPrmSum:1;bStatOpt:false;retType:CT_NUM;
        sOptSqlFmt:'%s+%s';sOptDescFmt:'%s加上%s'),
    (dataType:CT_NUM;sOptName:'-';nOptPrmSum:1;bStatOpt:false;retType:CT_NUM;
        sOptSqlFmt:'%s+%s';sOptDescFmt:'%s减去%s'),
    (dataType:CT_NUM;sOptName:'*';nOptPrmSum:1;bStatOpt:false;retType:CT_NUM;
        sOptSqlFmt:'%s * %s';sOptDescFmt:'%s乘上%s'),
    (dataType:CT_NUM;sOptName:'/';nOptPrmSum:1;bStatOpt:false;retType:CT_NUM;
        sOptSqlFmt:'%s / %s';sOptDescFmt:'%s除去%s'),
    (dataType:CT_NUM;sOptName:'abs';nOptPrmSum:0;bStatOpt:false;retType:CT_NUM;
        sOptSqlFmt:'abs(%s)';sOptDescFmt:'取%s的绝对值'),
    (dataType:CT_NUM;sOptName:'求和';nOptPrmSum:0;bStatOpt:true;retType:CT_NUM;
        sOptSqlFmt:'cast(sum(%s) as char(12))';sOptDescFmt:'对%s求和'),
    (dataType:CT_NUM;sOptName:'求平均';nOptPrmSum:0;bStatOpt:true;retType:CT_NUM;
        sOptSqlFmt:'ave(%s)';sOptDescFmt:'对%s平均'),
    (dataType:CT_NUM;sOptName:'最大值';nOptPrmSum:0;bStatOpt:true;retType:CT_NUM;
        sOptSqlFmt:'max(%s)';sOptDescFmt:'取%s最大值'),
    (dataType:CT_NUM;sOptName:'最小值';nOptPrmSum:0;bStatOpt:true;retType:CT_NUM;
        sOptSqlFmt:'min(%s)';sOptDescFmt:'取%s最小值'),

    (dataType:CT_CHAR;sOptName:'最大值';nOptPrmSum:0;bStatOpt:true;retType:CT_CHAR;
        sOptSqlFmt:'max(%s)';sOptDescFmt:'取%s最大值'),
    (dataType:CT_CHAR;sOptName:'最小值';nOptPrmSum:0;bStatOpt:true;retType:CT_CHAR;
        sOptSqlFmt:'min(%s)';sOptDescFmt:'取%s最小值'),
    (dataType:CT_CHAR;sOptName:'大写';nOptPrmSum:0;bStatOpt:false;retType:CT_CHAR;
        sOptSqlFmt:'upper(%s)';sOptDescFmt:'大写%s'),
    (dataType:CT_CHAR;sOptName:'小写';nOptPrmSum:0;bStatOpt:false;retType:CT_CHAR;
        sOptSqlFmt:'lower(%s)';sOptDescFmt:'小写%s'),

    (dataType:CT_STRING;sOptName:'最大值';nOptPrmSum:0;bStatOpt:true;retType:CT_STRING;
        sOptSqlFmt:'max(%s)';sOptDescFmt:'取%s最大值'),
    (dataType:CT_STRING;sOptName:'最小值';nOptPrmSum:0;bStatOpt:true;retType:CT_STRING;
        sOptSqlFmt:'min(%s)';sOptDescFmt:'取%s最小值'),
    (dataType:CT_STRING;sOptName:'大写';nOptPrmSum:0;bStatOpt:false;retType:CT_STRING;
        sOptSqlFmt:'upper(%s)';sOptDescFmt:'大写%s'),
    (dataType:CT_STRING;sOptName:'小写';nOptPrmSum:0;bStatOpt:false;retType:CT_STRING;
        sOptSqlFmt:'lower(%s)';sOptDescFmt:'小写%s'),

    (dataType:CT_STRING;sOptName:'左整理';nOptPrmSum:0;bStatOpt:false;retType:CT_STRING;
        sOptSqlFmt:'ltrim(%s)';sOptDescFmt:'左整理%s'),
    (dataType:CT_STRING;sOptName:'右整理';nOptPrmSum:0;bStatOpt:false;retType:CT_STRING;
        sOptSqlFmt:'rtrim(%s)';sOptDescFmt:'右整理%s'),
    (dataType:CT_STRING;sOptName:'整理';nOptPrmSum:0;bStatOpt:false;retType:CT_STRING;
        sOptSqlFmt:'rtrim(ltrim(%s))';sOptDescFmt:'整理%s'),

    (dataType:CT_STRING;sOptName:'求长度';nOptPrmSum:0;bStatOpt:false;retType:CT_NUM;
        sOptSqlFmt:'len(%s)';sOptDescFmt:'%s的长度'),
    (dataType:CT_STRING;sOptName:'取子串';nOptPrmSum:2;bStatOpt:false;retType:CT_STRING;
        sOptSqlFmt:'substring(%s,%s,%s)';sOptDescFmt:'从%s第%s字符取%s个字符'),

    (dataType:CT_DATE;sOptName:'年';nOptPrmSum:0;bStatOpt:false;retType:CT_NUM;
        sOptSqlFmt:'year(%s)';sOptDescFmt:'%s的年份'),
    (dataType:CT_DATE;sOptName:'月';nOptPrmSum:0;bStatOpt:false;retType:CT_NUM;
        sOptSqlFmt:'month(%s)';sOptDescFmt:'%s的月份'),
    (dataType:CT_DATE;sOptName:'日';nOptPrmSum:0;bStatOpt:false;retType:CT_NUM;
        sOptSqlFmt:'day(%s)';sOptDescFmt:'%s的日'),
    (dataType:CT_DATE;sOptName:'取整';nOptPrmSum:0;bStatOpt:false;retType:CT_DATE;
        sOptSqlFmt:'TRUNC(%s)';sOptDescFmt:'%s'),

    (dataType:CT_NONE;sOptName:'计数';nOptPrmSum:0;bStatOpt:true;retType:CT_NUM;
        sOptSqlFmt:'cast(count(%s) as char(12))';sOptDescFmt:'%s个数'),
    (dataType:CT_NONE;sOptName:'精确计数';nOptPrmSum:0;bStatOpt:true;retType:CT_NUM;
        sOptSqlFmt:'cast(count(distinct %s) as char(12))';sOptDescFmt:'%s精确个数'),

    (dataType:CT_NONE;sOptName:'字段运算';nOptPrmSum:-1;bStatOpt:false;retType:CT_NUM;
        sOptSqlFmt:'%s';sOptDescFmt:'%s')
 );

  DONOTHINGOPT: SColOperate=(dataType:CT_NONE;sOptName:'标记值';nOptPrmSum:-2;bStatOpt:false;retType:CT_NONE;
        sOptSqlFmt:'%s';sOptDescFmt:'%s');

  CONLOGICOPTMAXIND=28;
//(CT_NUM, CT_CHAR, CT_STRING,CT_DATE,CT_TIME,CT_DATETIME);
  conLogicOptList : array [0..CONLOGICOPTMAXIND] of SColOperate=(
    (dataType:CT_NUM;sOptName:'大于(>)';nOptPrmSum:1;bStatOpt:false;retType:CT_NUM;
        sOptSqlFmt:'%s>%s';sOptDescFmt:'%s大于%s'),
    (dataType:CT_NUM;sOptName:'小于(<)';nOptPrmSum:1;bStatOpt:false;retType:CT_NUM;
        sOptSqlFmt:'%s<%s';sOptDescFmt:'%s小于%s'),
    (dataType:CT_NUM;sOptName:'等于(=)';nOptPrmSum:1;bStatOpt:false;retType:CT_NUM;
        sOptSqlFmt:'%s=%s';sOptDescFmt:'%s等于%s'),
    (dataType:CT_NUM;sOptName:'大于等于(>=)';nOptPrmSum:1;bStatOpt:false;retType:CT_NUM;
        sOptSqlFmt:'%s>=%s';sOptDescFmt:'%s大于等于%s'),
    (dataType:CT_NUM;sOptName:'小于等于(<=)';nOptPrmSum:1;bStatOpt:false;retType:CT_NUM;
        sOptSqlFmt:'%s<=%s';sOptDescFmt:'%s小于等于%s'),
    (dataType:CT_NUM;sOptName:'不等于(<>)';nOptPrmSum:1;bStatOpt:false;retType:CT_NUM;
        sOptSqlFmt:'%s<>%s';sOptDescFmt:'%s不等于%s'),

    (dataType:CT_CHAR;sOptName:'大于(>)';nOptPrmSum:1;bStatOpt:false;retType:CT_NUM;
        sOptSqlFmt:'%s>%s';sOptDescFmt:'%s大于%s'),
    (dataType:CT_CHAR;sOptName:'小于(<)';nOptPrmSum:1;bStatOpt:false;retType:CT_NUM;
        sOptSqlFmt:'%s<%s';sOptDescFmt:'%s小于%s'),
    (dataType:CT_CHAR;sOptName:'等于(=)';nOptPrmSum:1;bStatOpt:false;retType:CT_NUM;
        sOptSqlFmt:'%s=%s';sOptDescFmt:'%s等于%s'),
    (dataType:CT_CHAR;sOptName:'大于等于(>=)';nOptPrmSum:1;bStatOpt:false;retType:CT_NUM;
        sOptSqlFmt:'%s>=%s';sOptDescFmt:'%s大于等于%s'),
    (dataType:CT_CHAR;sOptName:'小于等于(<=)';nOptPrmSum:1;bStatOpt:false;retType:CT_NUM;
        sOptSqlFmt:'%s<=%s';sOptDescFmt:'%s小于等于%s'),
    (dataType:CT_CHAR;sOptName:'不等于(<>)';nOptPrmSum:1;bStatOpt:false;retType:CT_NUM;
        sOptSqlFmt:'%s<>%s';sOptDescFmt:'%s不等于%s'),
    (dataType:CT_CHAR;sOptName:'包含于(in)';nOptPrmSum:2;bStatOpt:false;retType:CT_NUM;
        sOptSqlFmt:'%s in (%s)';sOptDescFmt:'%s包含于(%s)'),

    (dataType:CT_STRING;sOptName:'大于(>)';nOptPrmSum:1;bStatOpt:false;retType:CT_NUM;
        sOptSqlFmt:'%s>%s';sOptDescFmt:'%s大于%s'),
    (dataType:CT_STRING;sOptName:'小于(<)';nOptPrmSum:1;bStatOpt:false;retType:CT_NUM;
        sOptSqlFmt:'%s<%s';sOptDescFmt:'%s小于%s'),
    (dataType:CT_STRING;sOptName:'等于(=)';nOptPrmSum:1;bStatOpt:false;retType:CT_NUM;
        sOptSqlFmt:'%s=%s';sOptDescFmt:'%s等于%s'),
    (dataType:CT_STRING;sOptName:'大于等于(>=)';nOptPrmSum:1;bStatOpt:false;retType:CT_NUM;
        sOptSqlFmt:'%s>=%s';sOptDescFmt:'%s大于等于%s'),
    (dataType:CT_STRING;sOptName:'小于等于(<=)';nOptPrmSum:1;bStatOpt:false;retType:CT_NUM;
        sOptSqlFmt:'%s<=%s';sOptDescFmt:'%s小于等于%s'),
    (dataType:CT_STRING;sOptName:'不等于(<>)';nOptPrmSum:1;bStatOpt:false;retType:CT_NUM;
        sOptSqlFmt:'%s<>%s';sOptDescFmt:'%s不等于%s'),
    (dataType:CT_STRING;sOptName:'像(like)';nOptPrmSum:3;bStatOpt:false;retType:CT_NUM;
        sOptSqlFmt:'%s like %s';sOptDescFmt:'%s像%s'),
    (dataType:CT_STRING;sOptName:'包含于(in)';nOptPrmSum:2;bStatOpt:false;retType:CT_NUM;
        sOptSqlFmt:'%s in (%s)';sOptDescFmt:'%s包含于(%s)'),

    (dataType:CT_DATE;sOptName:'大于(>)';nOptPrmSum:1;bStatOpt:false;retType:CT_NUM;
        sOptSqlFmt:'%s>%s';sOptDescFmt:'%s大于''%s'''),
    (dataType:CT_DATE;sOptName:'小于(<)';nOptPrmSum:1;bStatOpt:false;retType:CT_NUM;
        sOptSqlFmt:'%s<%s';sOptDescFmt:'%s小于''%s'''),
    (dataType:CT_DATE;sOptName:'等于(=)';nOptPrmSum:1;bStatOpt:false;retType:CT_NUM;
        sOptSqlFmt:'%s=%s';sOptDescFmt:'%s等于''%s'''),
    (dataType:CT_DATE;sOptName:'大于等于(>=)';nOptPrmSum:1;bStatOpt:false;retType:CT_NUM;
        sOptSqlFmt:'%s>=%s';sOptDescFmt:'%s大于等于''%s'''),
    (dataType:CT_DATE;sOptName:'小于等于(<=)';nOptPrmSum:1;bStatOpt:false;retType:CT_NUM;
        sOptSqlFmt:'%s<=%s';sOptDescFmt:'%s小于等于''%s'''),
    (dataType:CT_DATE;sOptName:'不等于(<>)';nOptPrmSum:1;bStatOpt:false;retType:CT_NUM;
        sOptSqlFmt:'%s<>%s';sOptDescFmt:'%s不等于''%s'''),

    (dataType:CT_NONE;sOptName:'是空值(is NULL)';nOptPrmSum:0;bStatOpt:false;retType:CT_NUM;
        sOptSqlFmt:'%s is NULL';sOptDescFmt:'%s是空'),
    (dataType:CT_NONE;sOptName:'非空值(is not NULL)';nOptPrmSum:0;bStatOpt:false;retType:CT_NUM;
        sOptSqlFmt:'%s is not NULL';sOptDescFmt:'%s非空值')
 );
 
  DEFAULT_JOIN_TYPE = 0;
  conJoinTypeMaxInd = 3;
  conSJoinType : array [0..conJoinTypeMaxInd] of string=
     ('inner join',//  内连接
      'left join',//  左连接
      'right join',//  右连接
      'full join'
     );
  conSJoinTypeDesc : array [0..conJoinTypeMaxInd] of string=
     ('内连接',// inner join
      '左连接',// left join
      '右连接',// right join
      '完整连接'// full join
     );
var
  frQueryWizard: TfrQueryWizard;
implementation

{$R *.dfm}
uses CommonFunc,CommDBM,ADODB,SvrConfig;

function QuerySQLToVaiant(const sQLInfo:SQuerySQL):OleVariant;
begin
  result := VarArrayCreate([0, 7], varVariant);
  result[1] := sQLInfo.sqlType;
  result[2] := sQLInfo.sSQL;
  result[3] := sQLInfo.sSqlName;
  result[4] := sQLInfo.nFieldSum;
  result[5] := sQLInfo.sFieldDesc;
  result[6] := sQLInfo.nPrmSum;
  result[7] := sQLInfo.sPrmDesc;
end;

procedure TfrQueryWizard.ShowWhereOnly;
begin
  m_Config.sTitle := '过滤语句生成';
  m_Config.bCanNamed := true;
  m_Config.sTabFields := '';
  m_Config.sStartTable := '';
  m_Config.sSqlName := '过滤器';
  m_Config.showPanelSet := [pWhere];
//  m_Config.bFieldTable := false;
  m_Config.nFirstRowsOnly := 0;
  m_Config.bCheckSql := false;
  m_Config.nTableNameType:=2;
end;

procedure TfrQueryWizard.ShowWithoutGroup;
begin
  m_Config.sTitle := '查询语句(SQL)生成向导';
  m_Config.bCanNamed := true;
  m_Config.showPanelSet := [pSelect, pFrom, pWhere, pOrder, pParam];
//  m_Config.bFieldTable := false;
  m_Config.bCheckSql:=true;
  m_Config.nFirstRowsOnly := 0;
  m_Config.nTableNameType:=1;
end;

procedure TfrQueryWizard.ShowNormal;
begin
  m_Config.sTitle := '查询语句(SQL)生成向导';
  m_Config.bCanNamed := true;
  m_Config.showPanelSet := [pSelect, pFrom, pWhere, pGroup, pHaving, pOrder, pParam];
//  m_Config.bFieldTable := false;
  m_Config.bAutoShowGroup:=true;
  m_Config.bAutoShowHaving:=true;
  m_Config.bCheckSql:=true;
  m_Config.bShowRun := true;
  m_Config.nFirstRowsOnly := 0;
  m_Config.nTableNameType:=1;
end;

procedure TfrQueryWizard.ShowAll;
begin
  m_Config.sTitle := '查询语句(SQL)生成向导';
  m_Config.bCanNamed := true;
  m_Config.showPanelSet := [pSelect, pFrom, pWhere, pGroup, pHaving, pOrder, pParam];
//  m_Config.bFieldTable := false;
  m_Config.bAutoShowGroup:=true;
  m_Config.bAutoShowHaving:=true;
  m_Config.bCheckSql:=true;
  m_Config.nFirstRowsOnly := 0;
  m_Config.nTableNameType:=1;
end;

procedure TfrQueryWizard.FormCreate(Sender: TObject);
var
  i:integer;
  sDb : String;
begin

  m_Config.dbConfig := ORACLE_Config;
  sDb := TCommonFunc.GetRegKeyValue('\Software\Centit\SqlWizard','database');
  //  DATABASETYPE = (SQLServer, MSAccess, DB2, Oracle);
  if sDb='SQLServer' then
    m_Config.dbConfig := SQLSERVER_Config
  else if sDb='MSAccess' then
    m_Config.dbConfig := ACCESS_Config
  else if sDb='DB2' then
    m_Config.dbConfig := DB2_Config;


  m_bCreate := false;

  m_Config.nFirstRowsOnly := 0;
  m_Config.bCanRunMDL:=false;
  m_Config.bCanRunDDL:=false;
  m_Config.nQueryAsModeRows := 10;

  m_Config.bAutoShowGroup:=true;
  m_Config.bAutoShowHaving:=true;

  m_Config.bCheckSql:=false;
  m_Config.bShowWizard:=true;

  m_Config.bShowRun:=false;
  m_Config.bShowSetting:=false;
  m_Config.bShowMDLWizard:=false;
  m_Config.bShowDDLWizard:=false;

  m_Config.nShowSQL:=2;
  m_Config.nTableNameType:=2;
  m_nPreTab:=0;
  m_nPreWizardTab:=0;

  m_Config.bCanNamed := false;

  m_Config.sTabFields := '';
  m_Config.sStartTable := '';

  for i:= 0 to conJoinTypeMaxInd do
    cbTabJoinType.AddItem(conSJoinTypeDesc[i],nil);

  ShowNormal;
  //ShowWithoutGroup;
  //ShowWhereOnly;
  //m_Config.sSqlName := 'hello';
  //ShowAll;
  //m_Config.bFieldTable := true;
  //m_Config.sTabFields := 'Q_MD_TABLE,Q_MD_COLUMN,Q_MD_REL_DETIAL,Q_MD_RELATION';
  //m_Config.sStartTable := 'Q_MD_RELATION';
end;

procedure TfrQueryWizard.FormDestroy(Sender: TObject);
begin
  m_QTables := nil;
  m_QTabCols := nil;
  m_QRelation := nil;
end;

class function TfrQueryWizard.GetDataType(const sTypeDesc:String):COLDATATYPE;
var
  sTypeH,sTypeL:String;
  nBPos:integer;
begin
//(CT_NONE,CT_NUM, CT_CHAR, CT_STRING,CT_DATE,CT_TIME,CT_DATETIME);
  result := CT_NONE;
  nBPos := Pos('(',sTypeDesc);
  if nBPos>0 then
    sTypeH := Copy(sTypeDesc,1,nBPos-1)
  else
    sTypeH := sTypeDesc;

  if (StrIComp(PChar(sTypeH),'integer')=0 ) or
     (StrIComp(PChar(sTypeH),'number')=0 ) or
     (StrIComp(PChar(sTypeH),'numeric')=0 ) or
     (StrIComp(PChar(sTypeH),'decimal')=0 )
  then
  begin
    result := CT_NUM;
  end else
  if  (StrIComp(PChar(sTypeH),'char')=0) or
      (StrIComp(PChar(sTypeH),'nchar')=0) or
      (StrIComp(PChar(sTypeH),'character')=0) or
      (StrIComp(PChar(sTypeH),'nvarchar')=0) or
      (StrIComp(PChar(sTypeH),'varchar')=0) or
      (StrIComp(PChar(sTypeH),'varchar2')=0)  then
  begin
    if nBPos > 0 then
    begin
      sTypeL := Copy(sTypeDesc,nBPos+1,length(trim(sTypeDesc))-nBPos-1);
      if StrToInt(sTypeL)>1 then
        result := CT_STRING
      else
        result := CT_CHAR;
    end else
      result := CT_CHAR;
  end else
  if (StrIComp(PChar(sTypeH),'date')=0 ) or
     (StrIComp(PChar(sTypeH),'datetime')=0 )
  then
  begin
    result := CT_DATE;
  end else
  if  StrIComp(PChar(sTypeH),'time')=0   then
  begin
    result := CT_TIME;
  end;
end;

//(pSelect, pFrom, pWhere, pGroup, pHaving, pOrder);
procedure TfrQueryWizard.treeItemStepit(tvTable:TTreeView;tnTab:TTreeNode);
var
  pCurItem,pSubItem : PTreeItemData;
  pTab:PTableRec;
  i,j,iCount:integer;
  tnCol : TTreeNode;
  sItemName:String;
begin
  pCurItem := PTreeItemData(tnTab.Data);
  if pCurItem^.nStype = 1 then
  begin
    pTab:=PTableRec(pCurItem^.data);
    for i:=0 to m_nColSum-1 do
    begin
      if m_QTabCols[i].sTBCode = pTab^.sTBCode then
      begin
        tnCol := tvTable.Items.AddChild(tnTab,m_QTabCols[i].sColName);
        New(pSubItem);
        pSubItem^.nStype := 0;
        pSubItem^.bExpand := true;
        pSubItem^.sTabName :=pCurItem^.sTabName;
        pSubItem^.data :=  pCurItem^.data;
        pSubItem^.Data2 := @(m_QTabCols[i]);
        pSubItem^.pParent := pCurItem^.pParent;
        tnCol.Data := pSubItem;
      end;
    end;
    pCurItem^.bExpand := true;
  end;

  if (pCurItem^.nStype = 2) or (pCurItem^.nStype = 3) then
  begin
    pTab:=PTableRec(pCurItem^.data);
    tnCol := tvTable.Items.AddChild(tnTab,'字段列表');
    New(pSubItem);
    pSubItem^.nStype := 1;
    pSubItem^.bExpand := false;
    pSubItem^.sTabName :=pCurItem^.sTabName;
    pSubItem^.data :=  pCurItem^.data;
    pSubItem^.pParent := pCurItem;
    pSubItem^.Data2 := nil;
    tnCol.Data := pSubItem;
    iCount := 0;
    for i:=0 to m_nRelSum-1 do
      if m_QRelation[i].sPTBCode = pTab^.sTBCode then
        for j:=0 to m_nTabSum-1 do
          if m_QTables[j].sTBCode = m_QRelation[i].sCTBCode then
          begin
            sItemName := {m_QTables[j].sTBName + ' - ' +} m_QRelation[i].sRelName;
            tnCol := tvTable.Items.AddChild(tnTab,sItemName);
            New(pSubItem);
            pSubItem^.nStype := 3;
            pSubItem^.bExpand := false;
            pSubItem^.sTabName := pCurItem^.sTabName+'_'+IntToStr(iCount);
            pSubItem^.data :=  @(m_QTables[j]);
            pSubItem^.Data2 := @(m_QRelation[i]);
            pSubItem^.pParent := pCurItem;
            tnCol.Data := pSubItem;
            Inc(iCount);
            break;
          end;
  end;
end;

procedure TfrQueryWizard.FormShow(Sender: TObject);
var
  sSqlSen,sTmp:String;
  i:integer;
  tnTab:TTreeNode;
  pItem : PTreeItemData;
begin
  m_bCreate := false;
  m_Result.nPrmSum := 0;
  self.Caption := m_Config.sTitle;
  if not ( (pSelect in m_Config.showPanelSet) or (pWhere in m_Config.showPanelSet))
  then
    m_Config.showPanelSet := m_Config.showPanelSet + [pWhere];

  ledSQLName.Visible := m_Config.bCanNamed;
  if m_Config.bCanNamed then
    ledSQLName.Text := m_Config.sSqlName;

  tabSQL.TabVisible := m_Config.nShowSQL>0;
  edSQL.ReadOnly := m_Config.nShowSQL = 1;
  tabSelectSQL.TabVisible := m_Config.nShowSQL>0;
  edSelectSQL.ReadOnly := m_Config.nShowSQL = 1;
  tabFromSQL.TabVisible := m_Config.nShowSQL>0;
  edFromSQL.ReadOnly := m_Config.nShowSQL = 1;
  tabWhereSQL.TabVisible := m_Config.nShowSQL>0;
  edWhereSQL.ReadOnly := m_Config.nShowSQL = 1;
  tabGroupSQL.TabVisible := m_Config.nShowSQL>0;
  edGroupSQL.ReadOnly := m_Config.nShowSQL = 1;
  tabHavingSQL.TabVisible := m_Config.nShowSQL>0;
  edHavingSQL.ReadOnly := m_Config.nShowSQL = 1;
  tabOrderSQL.TabVisible := m_Config.nShowSQL>0;
  edOrderSQL.ReadOnly := m_Config.nShowSQL = 1;

  tabWizard.TabVisible := m_Config.bShowWizard;
  tabRunAsMode.TabVisible := m_Config.bShowRun;
  tabMDLWizard.TabVisible := m_Config.bShowMDLWizard;
  tabDDLWizard.TabVisible := m_Config.bShowDDLWizard;
  tabSetting.TabVisible := m_Config.bShowSetting;

  tabSelect.TabVisible := pSelect in m_Config.showPanelSet;
  tabFrom.TabVisible := pFrom in m_Config.showPanelSet;
  tabWhere.TabVisible := pWhere in m_Config.showPanelSet;
  tabParam.TabVisible := pParam in m_Config.showPanelSet;

 
  tabGroup.TabVisible := [pGroup,pSelect] <= m_Config.showPanelSet;
  tabHaving.TabVisible := [pGroup,pSelect,pHaving] <= m_Config.showPanelSet;
  tabOrder.TabVisible := [pSelect,pOrder] <= m_Config.showPanelSet;

  btnCheckSQL.Visible  := m_Config.bCheckSql;

  btnCiteParamWP.Enabled := false;
  btnCiteParamHP.Enabled := false;
// 获取表信息
  if m_Config.sTabFields<>'' then
    sSqlSen := m_Config.dbConfig.sGetTabSql +
              ' where (ltrim(TBCODE) '+TCommonFunc.FormatTableField(m_Config.sTabFields)+')'
  else
    sSqlSen := m_Config.dbConfig.sGetTabSql +
              ' where (TBSTATE=''T'') ';
  CltDMConn.ConnectDB;
  CltDMConn.QueryDB(sSqlSen);
  m_nTabSum := CltDMConn.ReordCount;
  SetLength(m_QTables,m_nTabSum);
  m_nTabSum := 0;
  while not CltDMConn.EndOfQuery do
  begin
    m_QTables[m_nTabSum].sTBCode := CltDMConn.FieldAsString(0);
    m_QTables[m_nTabSum].sTBName := CltDMConn.FieldAsString(1);
    m_QTables[m_nTabSum].sTBType := CltDMConn.FieldAsString(2);
    m_QTables[m_nTabSum].sTBDESC := CltDMConn.FieldAsString(3);
    m_QTables[m_nTabSum].nSelectRef := 0;
    m_QTables[m_nTabSum].nWhereRef := 0;
    inc(m_nTabSum);
    CltDMConn.NextRecord;
  end;
  CltDMConn.CloseQuery;
// 获取字段信息
  if m_Config.sTabFields<>'' then
    sSqlSen := m_Config.dbConfig.sGetColSql +
              ' where (COLSTATE=''T'') and (ltrim(TBCODE) '+TCommonFunc.FormatTableField(m_Config.sTabFields)+')'
  else
    sSqlSen := m_Config.dbConfig.sGetColSql +
              ' where (COLSTATE=''T'') order by TBCODE,COLCODE';

  CltDMConn.QueryDB(sSqlSen);
  m_nColSum := CltDMConn.ReordCount;
  SetLength(m_QTabCols,m_nColSum);
  m_nColSum := 0;
  while not CltDMConn.EndOfQuery do
  begin
    m_QTabCols[m_nColSum].sTBCode := CltDMConn.FieldAsString(0);
    m_QTabCols[m_nColSum].sColCode := CltDMConn.FieldAsString(1);
    m_QTabCols[m_nColSum].sColName := CltDMConn.FieldAsString(2);
    m_QTabCols[m_nColSum].sColType := CltDMConn.FieldAsString(3);
    m_QTabCols[m_nColSum].sRefDataCode := CltDMConn.FieldAsString(4);
    inc(m_nColSum);
    CltDMConn.NextRecord;
  end;
  CltDMConn.CloseQuery;
// 获取关联信息

  if m_Config.sTabFields<>'' then
    sSqlSen := m_Config.dbConfig.sGetRelSql +
              ' where (ltrim(PTABCODE) '+TCommonFunc.FormatTableField(m_Config.sTabFields) +
                ')'// or (ltrim(CTABCODE) '+TCommonFunc.FormatTableField(m_Config.sTabFields) +')'
  else
    sSqlSen := m_Config.dbConfig.sGetRelSql +
              ' where (RELSTATE=''T'')';

  CltDMConn.QueryDB(sSqlSen);
  m_nRelSum := CltDMConn.ReordCount;
  SetLength(m_QRelation,m_nRelSum);
  m_nRelSum := 0;
  while not CltDMConn.EndOfQuery do
  begin
    m_QRelation[m_nRelSum].sRelCode := CltDMConn.FieldAsString(0);
    m_QRelation[m_nRelSum].sRelName := CltDMConn.FieldAsString(1);
    m_QRelation[m_nRelSum].sPTBCode := CltDMConn.FieldAsString(2);
    m_QRelation[m_nRelSum].sCTBCode := CltDMConn.FieldAsString(3);
    m_QRelation[m_nRelSum].nDetailSum := 0;
    m_QRelation[m_nRelSum].nJoinType := DEFAULT_JOIN_TYPE;  //0 default inner join ;
                                            //1 default Left Join
    inc(m_nRelSum);
    CltDMConn.NextRecord;
  end;
  CltDMConn.CloseQuery;
// 获取关联明细信息
  if m_Config.sTabFields<>'' then
    sSqlSen := m_Config.dbConfig.sGetRelDetailSql +
         ' WHERE RELCODE in ( select RELCODE from Q_MD_RELATION '+
               ' WHERE (RELSTATE=''T'') and (ltrim(PTABCODE) '+TCommonFunc.FormatTableField(m_Config.sTabFields) +
                 '))'// or (ltrim(CTABCODE) '+TCommonFunc.FormatTableField(m_Config.sTabFields) +') )'
  else
    sSqlSen := m_Config.dbConfig.sGetRelDetailSql;

  CltDMConn.QueryDB(sSqlSen);
  while not CltDMConn.EndOfQuery do
  begin
    sTmp := CltDMConn.FieldAsString(0);
    for i:=0 to m_nRelSum-1 do
    begin
      if m_QRelation[i].sRelCode = sTmp then
      begin
        if m_QRelation[i].nDetailSum < MAX_COL_PRE_REL then
        begin
          m_QRelation[i].relDetail[m_QRelation[i].nDetailSum].sPColCode :=
                                              CltDMConn.FieldAsString(1);
          m_QRelation[i].relDetail[m_QRelation[i].nDetailSum].sCColCode :=
                                              CltDMConn.FieldAsString(2);
          inc(m_QRelation[i].nDetailSum);
        end;
        break;
      end;
    end;
    CltDMConn.NextRecord;
  end;
  CltDMConn.CloseQuery;
  CltDMConn.Disconnect;

// config select and where panel
//  pSelect in m_Config.showPanelSet or pWhere in m_Config.showPanelSet
    trTableColPS.Items.Clear;
    trTableColPW.Items.Clear;

    ledDealFieldPrm1PS.Visible := false;
    ledDealFieldPrm2PS.Visible := false;
    m_preSelColSP := nil;
    m_preSelColWP := nil;
    m_preColTypeWP := CT_NONE;
    m_preColTypeHP := CT_NONE;
    for i:=0 to m_nTabSum-1 do
    begin
      //pSelect
      if m_QTables[i].sTBType = 'V' then
        Continue;
      if  (m_Config.sStartTable<>'') and
          (m_QTables[i].sTBCode <> m_Config.sStartTable) then
        Continue;

      tnTab := trTableColPS.Items.AddChild(nil,m_QTables[i].sTBName);
      New(pItem);
      pItem^.nStype := 2;
      pItem^.bExpand := false;
      pItem^.data :=  @(m_QTables[i]);
      pItem^.Data2 := nil;
      pItem^.sTabName := 'T'+IntToStr(i);
      pItem^.pParent := nil;
      tnTab.Data := pItem;
      treeItemStepit(trTableColPS,tnTab);
      //pWhere
      tnTab := trTableColPW.Items.AddChild(nil,m_QTables[i].sTBName);
      New(pItem);
      pItem^.nStype := 2;
      pItem^.bExpand := false;
      pItem^.data :=  @(m_QTables[i]);
      pItem^.Data2 := nil;
      pItem^.sTabName := 'T'+IntToStr(i);
      pItem^.pParent := nil;
      tnTab.Data := pItem;
      treeItemStepit(trTableColPW,tnTab);
    end;
// config where panel
  dtpDataValue.Visible := false;
  cbCurrentDate.Visible := false;
  lbDictionaryValue.Visible := false;
  cbDictionaryDataValue.Visible := false;
  btnSubQuery.Visible := false;
  ledDealFieldPrm1PW.Visible := false;
  ledDealFieldPrm2PW.Visible := false;
// end of config where panel
// config having panel
  dtpDataValuePH.Visible := false;
  lbDictionaryValuePH.Visible := false;
  cbDictionaryDataValuePH.Visible := false;
  btnSubQueryPH.Visible := false;
  ledDealFieldPrm1PH.Visible := false;
  ledDealFieldPrm2PH.Visible := false;
// end of config having panel
  m_preRelationPage := trRelation.ActivePage;
  m_preDesignPage := pcDesign.ActivePage;
  m_bCreate := true;
end;
//select panel 消息处理

procedure TfrQueryWizard.trTableColPSChange(Sender: TObject;
  Node: TTreeNode);
var
  curSelCol :PColumnRec;
  selNode : TTreeNode;
  colType : COLDATATYPE;
  sColSql:String;
  i : integer;
  pItem : PTreeItemData;
begin
  //m_preSelColSP
  if not m_bCreate then Exit;
  selNode := trTableColPS.Selected;
  if selNode = nil then Exit;
  pItem := PTreeItemData(selNode.Data);
  if pItem^.nStype <> 0 then Exit;

    ledDealFieldPrm1PS.Visible := false;
    ledDealFieldPrm2PS.Visible := false;

  curSelCol := PColumnRec(pItem^.data2);

  if (m_preSelColSP = nil) or (m_preSelColSP<>pItem) then
  begin
    m_preSelColSP := pItem;
    if m_Config.nTableNameType = 1 then
      sColSql := pItem^.sTabName +'.'+ curSelCol^.sColCode
    else if m_Config.nTableNameType = 2 then
      sColSql := curSelCol^.sTBCode +'.'+ curSelCol^.sColCode
    else
      sColSql := curSelCol^.sColCode;

    ledFieldDescPS.Text := curSelCol^.sColName;
    ledFieldSqlPS.Text := sColSql;
    ledFieldAlias.Text := curSelCol^.sColCode;
    colType := GetDataType(curSelCol^.sColType);
    cbDealFieldPS.Clear;
    for i:=0 to CONOPTMAXIND do
    begin
      if (conOptList[i].dataType = colType) or
         (conOptList[i].dataType = CT_NONE) then
      begin
        cbDealFieldPS.AddItem(conOptList[i].sOptName,TObjPointer.Create(@(conOptList[i])));
      end;
    end;
  end;
end;

procedure TfrQueryWizard.updateSqlAndDescInSP(Sender: TObject);
var
  pOpt : PColOperate;
  sStr:String;
  sColSql:String;
//  sAlias,asStr:String;
  curSelCol :PColumnRec;
begin
  if m_preSelColSP=nil then Exit;
  curSelCol := PColumnRec(m_preSelColSP^.data2);
  //sColSql := m_preSelColSP^.sTabName +'.'+ curSelCol^.sColCode;
  if m_Config.nTableNameType = 1 then
    sColSql := m_preSelColSP^.sTabName +'.'+ curSelCol^.sColCode
  else if m_Config.nTableNameType = 2 then
    sColSql := curSelCol^.sTBCode +'.'+ curSelCol^.sColCode
  else
    sColSql := curSelCol^.sColCode;

  if cbDealFieldPS.ItemIndex < 0 then
    Exit;

  pOpt := PColOperate(TObjPointer(cbDealFieldPS.Items.Objects[cbDealFieldPS.ItemIndex]).pData);
//  if (pOpt^.retType <> CT_NONE)  or (sAlias <> curSelCol^.sColCode) then
//    asStr := ' as '+sAlias
//  else
 //   asStr := '';

  ledDealFieldPrm1PS.Visible := pOpt^.nOptPrmSum>0;
  ledDealFieldPrm2PS.Visible := pOpt^.nOptPrmSum>1;

  if pOpt^.nOptPrmSum = -1 then
  begin
    ledFieldSqlPS.Text := '';//+asStr;
    ledFieldDescPS.Text := '';
  end;

  if pOpt^.nOptPrmSum = 0 then
  begin
    FmtStr(sStr,pOpt^.sOptSqlFmt,[sColSql]);
    ledFieldSqlPS.Text := sStr;//+asStr;
    FmtStr(sStr,pOpt^.sOptDescFmt,[curSelCol^.sColName]);
    ledFieldDescPS.Text := sStr;
  end;

  if pOpt^.nOptPrmSum = 1 then
  begin
    FmtStr(sStr,pOpt^.sOptSqlFmt,[sColSql,ledDealFieldPrm1PS.Text]);
    ledFieldSqlPS.Text := sStr;//+asStr;
    FmtStr(sStr,pOpt^.sOptDescFmt,[curSelCol^.sColName,ledDealFieldPrm1PS.Text]);
    ledFieldDescPS.Text := sStr;
  end;

  if pOpt^.nOptPrmSum = 2 then
  begin
    FmtStr(sStr,pOpt^.sOptSqlFmt,[sColSql,ledDealFieldPrm1PS.Text,ledDealFieldPrm2PS.Text]);
    ledFieldSqlPS.Text := sStr;//+asStr;
    FmtStr(sStr,pOpt^.sOptDescFmt,[curSelCol^.sColName,ledDealFieldPrm1PS.Text,ledDealFieldPrm2PS.Text]);
    ledFieldDescPS.Text := sStr;
  end;
  // pOpt^.bStatOpt
end;

procedure TfrQueryWizard.btnAddFieldPSClick(Sender: TObject);
var
  liSelect : TListItem;
  sSql:String;
  sAlias:String;
  i,iCount:integer;

  curSelCol :PColumnRec;
  iR:Integer;
  bGetAlias:boolean;
  pOpt : PColOperate;
  pSelData:PSelectItemData;
  bC:boolean;

  function GetFormualSql(const sQ:String;var bCorrect:boolean):string;
  var
    sSqlSen,sWord,sFormula:String;
    iCount,nInd,nPos,nBC,nPreWordType:integer;
    pItemData : PSelectItemData;
  begin
    nPreWordType := 0;
    bCorrect := true;
    nBC := 0;
    sFormula := sQ;
    iCount := lvSelectingField.Items.Count;
    nPos := 1;
    sSqlSen := '';
    sWord := TCommonFunc.GetAWord(sFormula,nPos);
    while sWord<>'' do
    begin
      if (length(sWord) = 1) and
        (sWord[1] in ['+','-','*','/']) then
      begin
{        sSqlSen := sSqlSen+sWord+' ';   // 0: 1:+-*/ 2:( 3:) 4:! 5: N
        if nPreWordType in [0,1,2,4] then
           bCorrect := false;           2
        nPreWordType := 1;
      end else if (sWord='+') or (sWord='-') then
      begin
}
        sSqlSen := sSqlSen+sWord+' ';
        if nPreWordType in [0,1,2,4]  then
           bCorrect := false;
        nPreWordType := 1;
      end else if sWord='(' then
      begin
        sSqlSen := sSqlSen+'( ';
        if nPreWordType in [3,5]  then
           bCorrect := false;
        nPreWordType := 2;
        Inc(nBC);
      end else if sWord=')' then
      begin
        sSqlSen := sSqlSen+') ';
        if nPreWordType in [0,1,2,4]  then
           bCorrect := false;
        nPreWordType := 3;
        Dec(nBC);
        if nBC<0 then
          bCorrect := false;
      end else
      begin
        if TCommonFunc.IsNumber(sWord) then
        begin
          nInd := StrToInt(sWord)-1;
          if (nInd>=0) and (nInd<iCount) then
          begin
            pItemData := PSelectItemData(lvSelectingField.Items[nInd].Data);
            if pItemData^.dataType <> CT_NUM then
              bCorrect := false;

            sSqlSen := sSqlSen+lvSelectingField.Items[nInd].SubItems[0]+' ';
          end else
             bCorrect := false;
          if nPreWordType in [3,5] then
             bCorrect := false;

          nPreWordType := 5;
        end else
          bCorrect := false;
      end;
      sWord := TCommonFunc.GetAWord(sFormula,nPos);
    end;
    if nPreWordType in [1,2,4] then
       bCorrect := false;
    if nBC<>0 then
      bCorrect := false;

    result := sSqlSen;
  end;

begin
  if m_preSelColSP=nil then Exit;

  curSelCol := PColumnRec(m_preSelColSP^.data2);
  bC := false;
  sSql := trim(ledFieldSqlPS.Text);
  if sSql = '' then Exit;
  if cbDealFieldPS.ItemIndex >= 0 then
    if PColOperate(TObjPointer(cbDealFieldPS.Items.Objects[cbDealFieldPS.ItemIndex]).pData)^.nOptPrmSum = -1 then
    begin
      sSql := GetFormualSql(sSql,bC);
      if not bC then
      begin
        ShowMessage('表达式输入有误！');
        Exit;
      end;
    end;

  sAlias := trim(ledFieldAlias.Text);
  if sAlias='' then
    sAlias := curSelCol^.sColCode;

  bGetAlias := true;
  iCount := lvSelectingField.Items.Count;
  for i:=0 to iCount-1 do
    if  (lvSelectingField.Items[i].SubItems[1] = sAlias) then
    begin
      bGetAlias := false;
      break;
    end;

  if not bGetAlias then
  begin
    iR := 3;
    sAlias := curSelCol^.sColCode+'2';
    while not bGetAlias do
    begin
      bGetAlias := true;
      for i:=0 to iCount-1 do
        if  (lvSelectingField.Items[i].SubItems[1] = sAlias) then
        begin
          bGetAlias := false;
          sAlias := curSelCol^.sColCode+IntToStr(iR);
          Inc(iR);
          break;
        end;
    end;
    ledFieldAlias.Text := sAlias;
    ShowMessage('有重复的字段别名，不能添加！系统已重新为您制定了一个别名。');
    Exit;
  end;

  liSelect := lvSelectingField.Items.Add;
  liSelect.Caption := IntToStr(iCount+1);// m_preSelColSP^.sColName;//
  liSelect.SubItems.Add(sSql);
  liSelect.SubItems.Add(sAlias);
  liSelect.SubItems.Add(ledFieldDescPS.Text);

  //liSelect
  New(pSelData);
  pSelData^.pTreeItem := m_preSelColSP;
  pSelData^.bStat := false;
  if bC then
    pSelData^.dataType := CT_NUM
  else
    pSelData^.dataType := GetDataType(curSelCol^.sColType);
  if cbDealFieldPS.ItemIndex>=0 then
  begin
    pOpt := PColOperate(TObjPointer(cbDealFieldPS.Items.Objects[cbDealFieldPS.ItemIndex]).pData);
    if pOpt^.bStatOpt then
      pSelData^.bStat := true;
    if pOpt^.retType <> CT_NONE then
      pSelData^.dataType := pOpt^.retType;
  end;
  liSelect.Data := pSelData;
  liSelect.Checked := true;
  lvSelectingField.ItemIndex := iCount;     

  makeGroupPanel(false);

end;

procedure TfrQueryWizard.trTableColPSDblClick(Sender: TObject);
var
  curSelCol :PColumnRec;
  liSelect : TListItem;
  selNode : TTreeNode;
  sAlias,sSql:String;
  pItem : PTreeItemData;
  i,iCount:integer;
  iR:Integer;
  bGetAlias:boolean;
  pSelData:PSelectItemData;
begin
  //m_preSelColSP
  selNode := trTableColPS.Selected;
  if selNode = nil then Exit;
  pItem := PTreeItemData(selNode.Data);
  if pItem^.nStype <> 0 then Exit;
  curSelCol := PColumnRec(pItem^.Data2);
  sAlias := curSelCol^.sColCode;
  iCount := lvSelectingField.Items.Count;
  bGetAlias := false;
  iR := 2;
  while not bGetAlias do
  begin
    bGetAlias := true;
    for i:=0 to iCount-1 do
      if  (lvSelectingField.Items[i].SubItems[1] = sAlias) then
      begin
        bGetAlias := false;
        sAlias := curSelCol^.sColCode+IntToStr(iR);
        Inc(iR);
        break;
      end;
  end;
//  sSql := pItem^.sTabName +'.'+ curSelCol^.sColCode;
  if m_Config.nTableNameType = 1 then
    sSql := pItem^.sTabName +'.'+ curSelCol^.sColCode
  else if m_Config.nTableNameType = 2 then
    sSql := curSelCol^.sTBCode +'.'+ curSelCol^.sColCode
  else
    sSql := curSelCol^.sColCode;


  if sAlias<>  curSelCol^.sColCode then
    sSql := sSql ;// + ' as ' + sAlias;
  new(pSelData);
  pSelData^.pTreeItem := pItem;
  pSelData^.bStat := false;
  pSelData^.dataType := GetDataType(curSelCol^.sColType);
  liSelect := lvSelectingField.Items.Add;
  liSelect.Caption := IntToStr(iCount+1) ;//curSelCol^.sColName;//
  liSelect.SubItems.Add(sSql);
  liSelect.SubItems.Add(sAlias);
  liSelect.SubItems.Add(curSelCol^.sColName);
  liSelect.Data := pSelData;
  liSelect.Checked := true;
  lvSelectingField.ItemIndex := iCount;

  makeGroupPanel(false);

end;

procedure TfrQueryWizard.btnUpdateFieldPSClick(Sender: TObject);
var
  liSelect : TListItem;
  sSql:String;
  sAlias:String;
  i,iInd,iCount:integer;
  curSelCol :PColumnRec;
  iR:Integer;
  bGetAlias:boolean;
  pOpt : PColOperate;
  pSelData:PSelectItemData;
  bC:boolean;

  function GetFormualSql(const sQ:String;var bCorrect:boolean):string;
  var
    sSqlSen,sWord,sFormula:String;
    iCount,nInd,nPos,nBC,nPreWordType:integer;
    pItemData : PSelectItemData;
  begin
    nPreWordType := 0;
    bCorrect := true;
    nBC := 0;
    sFormula := sQ;
    iCount := lvSelectingField.Items.Count;
    nPos := 1;
    sSqlSen := '';
    sWord := TCommonFunc.GetAWord(sFormula,nPos);
    while sWord<>'' do
    begin
      if (length(sWord) = 1) and
        (sWord[1] in ['+','-','*','/']) then
      begin
{        sSqlSen := sSqlSen+'* ';   // 0: 1:*+ 2:( 3:) 4:! 5: N
        if nPreWordType in [0,1,2,4] then
           bCorrect := false;
        nPreWordType := 1;
      end else if sWord='+' then
      begin
}
        sSqlSen := sSqlSen+sWord+' ';
        if nPreWordType in [0,1,2,4]  then
           bCorrect := false;
        nPreWordType := 1;
      end else if sWord='(' then
      begin
        sSqlSen := sSqlSen+'( ';
        if nPreWordType in [3,5]  then
           bCorrect := false;
        nPreWordType := 2;
        Inc(nBC);
      end else if sWord=')' then
      begin
        sSqlSen := sSqlSen+') ';
        if nPreWordType in [0,1,2,4]  then
           bCorrect := false;
        nPreWordType := 3;
        Dec(nBC);
        if nBC<0 then
          bCorrect := false;
      end else
      begin
        if TCommonFunc.IsNumber(sWord) then
        begin
          nInd := StrToInt(sWord)-1;
          if (nInd>=0) and (nInd<iCount) then
          begin
            pItemData := PSelectItemData(lvSelectingField.Items[nInd].Data);
            if pItemData^.dataType <> CT_NUM then
              bCorrect := false;

            sSqlSen := sSqlSen+lvSelectingField.Items[nInd].SubItems[0]+' ';
          end else
             bCorrect := false;
          if nPreWordType in [3,5] then
             bCorrect := false;

          nPreWordType := 5;
        end else
          bCorrect := false;
      end;
      sWord := TCommonFunc.GetAWord(sFormula,nPos);
    end;
    if nPreWordType in [1,2,4] then
       bCorrect := false;
    if nBC<>0 then
      bCorrect := false;

    result := sSqlSen;
  end;

begin

  if m_preSelColSP=nil then Exit;
  curSelCol := PColumnRec(m_preSelColSP^.data2);
  if lvSelectingField.Selected = nil then Exit;

  bC := false;
  sSql := trim(ledFieldSqlPS.Text);
  if sSql = '' then Exit;
  if cbDealFieldPS.ItemIndex >= 0 then
    if PColOperate(TObjPointer(cbDealFieldPS.Items.Objects[cbDealFieldPS.ItemIndex]).pData)^.nOptPrmSum = -1 then
    begin
      sSql := GetFormualSql(sSql,bC);
      if not bC then
      begin
        ShowMessage('表达式输入有误！');
        Exit;
      end;
    end;

  sAlias := trim(ledFieldAlias.Text);
  if sAlias='' then
    sAlias := curSelCol^.sColCode;

  iInd := lvSelectingField.ItemIndex;
  bGetAlias := true;
  iCount := lvSelectingField.Items.Count-1;
  for i:=0 to iCount do
    if (i<>iInd) and (lvSelectingField.Items[i].SubItems[1] = sAlias) then
    begin
      bGetAlias := false;
      break;
    end;

  if not bGetAlias then
  begin
    iR := 3;
    sAlias := curSelCol^.sColCode+'2';
    while not bGetAlias do
    begin
      bGetAlias := true;
      for i:=0 to iCount-1 do
        if  (i<>iInd) and (lvSelectingField.Items[i].SubItems[1] = sAlias) then
        begin
          bGetAlias := false;
          sAlias := curSelCol^.sColCode+IntToStr(iR);
          Inc(iR);
          break;
        end;
    end;
    ledFieldAlias.Text := sAlias;
    ShowMessage('有重复的字段别名，无法更改！系统已重新为您制定了一个别名。');
    Exit;
  end;

  liSelect := lvSelectingField.Selected;
  //liSelect.Caption := I;// m_preSelColSP^.sColName;
  liSelect.SubItems[0] := sSql;// m_preSelColSP^.sColName;
  liSelect.SubItems[1] := sAlias;
  liSelect.SubItems[2] := ledFieldDescPS.Text;

  pSelData := PSelectItemData(liSelect.Data);
  pSelData^.pTreeItem := m_preSelColSP;
  pSelData^.bStat := false;
  pSelData^.dataType := GetDataType(curSelCol^.sColType);
  if cbDealFieldPS.ItemIndex>=0 then
  begin
    pOpt := PColOperate(TObjPointer(cbDealFieldPS.Items.Objects[cbDealFieldPS.ItemIndex]).pData);
    if pOpt^.bStatOpt then
      pSelData^.bStat := true;
    if pOpt^.retType <> CT_NONE then
      pSelData^.dataType := pOpt^.retType;
  end;

  makeGroupPanel(false);

end;

procedure TfrQueryWizard.lvSelectingFieldDeletion(Sender: TObject;
  Item: TListItem);
begin
  if Item.Data <> nil then
  begin
    Dispose(Item.Data);
    Item.Data := nil;
  end;
end;

procedure TfrQueryWizard.btnDeleteFieldPSClick(Sender: TObject);
var
  iSel:integer;
begin
  // add select col
  if lvSelectingField.Selected = nil then Exit;
  iSel := lvSelectingField.ItemIndex;
  lvSelectingField.DeleteSelected;
  if iSel < lvSelectingField.Items.Count then
  begin
    lvSelectingField.ItemIndex := iSel;
    while iSel < lvSelectingField.Items.Count do
    begin
      lvSelectingField.Items[iSel].Caption := IntToStr(iSel+1);
      Inc(iSel);
    end;
  end  else if iSel>0 then
    lvSelectingField.ItemIndex := iSel-1;

  makeGroupPanel(false);
end;

procedure TfrQueryWizard.btnMoveSelectUpPSClick(Sender: TObject);
var
  sTemp:String;
  pColTemp: Pointer;
  liSel , liUpSel : TListItem;
begin
  // move up
  if lvSelectingField.Selected = nil then Exit;
  liSel := lvSelectingField.Selected ;
  if liSel.Index < 1 then Exit;
  liUpSel := lvSelectingField.Items[liSel.Index-1];

  //sTemp:=liUpSel.Caption; liUpSel.Caption:=liSel.Caption; liSel.Caption:= sTemp;
  sTemp:=liUpSel.SubItems[0]; liUpSel.SubItems[0]:=liSel.SubItems[0]; liSel.SubItems[0]:= sTemp;
  sTemp:=liUpSel.SubItems[1]; liUpSel.SubItems[1]:=liSel.SubItems[1]; liSel.SubItems[1]:= sTemp;
  sTemp:=liUpSel.SubItems[2]; liUpSel.SubItems[2]:=liSel.SubItems[2]; liSel.SubItems[2]:= sTemp;
  pColTemp:=liUpSel.Data; liUpSel.Data:=liSel.Data; liSel.Data:=pColTemp;

  lvSelectingField.ItemIndex := liSel.Index-1;
end;

procedure TfrQueryWizard.btnMoveSelectDownPSClick(Sender: TObject);
var
  iCount : Integer;
  sTemp:String;
  pColTemp: Pointer;
  liSel , liDownSel : TListItem;
begin
  // move up
  if lvSelectingField.Selected = nil then Exit;
  liSel := lvSelectingField.Selected ;
  iCount := lvSelectingField.Items.Count;

  if liSel.Index >= iCount-1 then Exit;
  liDownSel := lvSelectingField.Items[liSel.Index+1];

//  sTemp:=liDownSel.Caption; liDownSel.Caption:=liSel.Caption; liSel.Caption:= sTemp;
  sTemp:=liDownSel.SubItems[0]; liDownSel.SubItems[0]:=liSel.SubItems[0]; liSel.SubItems[0]:= sTemp;
  sTemp:=liDownSel.SubItems[1]; liDownSel.SubItems[1]:=liSel.SubItems[1]; liSel.SubItems[1]:= sTemp;
  sTemp:=liDownSel.SubItems[2]; liDownSel.SubItems[2]:=liSel.SubItems[2]; liSel.SubItems[2]:= sTemp;
  pColTemp:=liDownSel.Data; liDownSel.Data:=liSel.Data; liSel.Data:=pColTemp;

  lvSelectingField.ItemIndex := liSel.Index+1;
end;

procedure TfrQueryWizard.makeQuerySql(changePanels:PANELSET;bWholeSql:boolean=false);
var
  sSqlSen,sJoinSql,sFieldSql,sTmp,sAlias:String;
  i,j,iPos,iCount:Integer;
  pRel : PRelRec;
  sTable,sHeadTab:String;
  pItem : PTreeItemData;
begin
  if pSelect in changePanels then
  begin
    iCount := lvSelectingField.Items.Count;
    if iCount>0 then
    begin
      sSqlSen := '';
      for i:=0 to iCount-1 do
      begin
        if lvSelectingField.Items[i].Checked then
        begin
          sFieldSql := lvSelectingField.Items[i].SubItems[0];
          sAlias := lvSelectingField.Items[i].SubItems[1];
          iPos := Pos('.',sFieldSql);
          if (iPos>0) and (length(sFieldSql)>iPos) then
          begin
            sTmp := Copy(sFieldSql,iPos+1,length(sFieldSql)-iPos);
            if sTmp<>sAlias then
              sFieldSql := sFieldSql+' as '+ sAlias;
          end;

          if sSqlSen='' then
            sSqlSen := sFieldSql//
          else
            sSqlSen := sSqlSen + ','+ sFieldSql;//
        end;
      end;
      edSelectSQL.Text := sSqlSen;
    end;
  end;//
  
  if pWhere in changePanels then
    checkFormulaInput(1,true);

  if pFrom in  changePanels then
  begin
    iCount := lvTabJoin.Items.Count;
    sSqlSen := '';
    for i:=0 to iCount-1 do
    begin
      if lvTabJoin.Items[i].Caption = '' then
        sSqlSen := sSqlSen + ' ' +lvTabJoin.Items[i].SubItems[1]
      else
      begin
        pItem := PTreeItemData(lvTabJoin.Items[i].Data);
        pRel := PRelRec(pItem^.data2);

        if m_Config.nTableNameType = 1 then
        begin
          sTable := pItem^.sTabName;
          sHeadTab := pItem^.pParent^.sTabName;
        end else
        begin
          sTable := pRel^.sCTBCode;
          sHeadTab := pRel^.sPTBCode;
        end;

        sJoinSql := ' '+conSJoinType[pRel^.nJoinType]+' '+ lvTabJoin.Items[i].SubItems[1] + ' on ';
        if pRel^.nDetailSum > 0 then
        begin
          if (m_Config.nTableNameType = 1) or ((m_Config.nTableNameType = 2)) then
            sJoinSql := sJoinSql + '('+ sHeadTab+'.'+pRel^.relDetail[0].sPColCode+
                            ' = '+sTable+'.'+ pRel^.relDetail[0].sCColCode +')'
          else
            sJoinSql := sJoinSql + '('+ pRel^.relDetail[0].sPColCode+
                            ' = ' + pRel^.relDetail[0].sCColCode +')';
        end;

        for j:=1 to pRel^.nDetailSum - 1 do
        begin
          if (m_Config.nTableNameType = 1) or ((m_Config.nTableNameType = 2)) then
            sJoinSql := sJoinSql + ' and ('+ sHeadTab+'.'+pRel^.relDetail[j].sPColCode+
                            ' = '+sTable+'.'+ pRel^.relDetail[j].sCColCode +')'
          else
            sJoinSql := sJoinSql + ' and ('+ pRel^.relDetail[j].sPColCode+
                            ' = ' + pRel^.relDetail[j].sCColCode +')';
        end;
        case m_Config.dbConfig.DBType  of
          MSAccess :
            sSqlSen := '('+ sSqlSen +')' + sJoinSql;
          Oracle,
          SQLServer, DB2 :
            sSqlSen := sSqlSen + sJoinSql;
        end;
      end;
    end;
    edFromSQL.Text := sSqlSen;
  end;

  if pGroup in changePanels then
  begin
    iCount := lvSelectFieldNoStat.Items.Count;
    sSqlSen := '';
    for i:=0 to iCount-1 do
      if lvSelectFieldNoStat.Items[i].Checked then
      begin
        if sSqlSen='' then
          sSqlSen := lvSelectFieldNoStat.Items[i].SubItems[1]
        else
          sSqlSen := sSqlSen+','+ lvSelectFieldNoStat.Items[i].SubItems[1];
      end;
    edGroupSQL.Text := sSqlSen;
  end;

  if pHaving in changePanels then
  begin
    checkFormulaInput(2,true);
  end;

  if pOrder in changePanels then
  begin
    iCount := lvOrderField.Items.Count;
    sSqlSen := '';
    for i:=0 to iCount-1 do
      if sSqlSen = ''  then
        sSqlSen := lvOrderField.Items[i].SubItems[1]
      else
        sSqlSen := sSqlSen+', '+ lvOrderField.Items[i].SubItems[1];
    edOrderSQL.Text := sSqlSen;
  end;

  if bWholeSql then
  begin
    sSqlSen := '';
    if tabSelect.TabVisible then
      sSqlSen := 'select ' + edSelectSql.Text;

    if tabFrom.TabVisible then
      sSqlSen := sSqlSen + ' from ' + edFromSql.Text;

    if tabWhere.TabVisible then
    begin
      if trim(edWhereSql.Text) <> '' then
        sSqlSen := sSqlSen + ' where ' + edWhereSql.Text;
    end;

    if tabGroup.TabVisible then
    begin
      if trim(edGroupSql.Text) <> '' then
      begin
        sSqlSen := sSqlSen + ' group by ' + edGroupSql.Text;
        if tabHaving.TabVisible then
        begin
          if trim(edHavingSql.Text) <> '' then
            sSqlSen := sSqlSen + ' having ' + edHavingSql.Text;
        end;
      end;
    end;

    if tabOrder.TabVisible then
    begin
      if trim(edOrderSql.Text) <> '' then
        sSqlSen := sSqlSen + ' order by ' + edOrderSql.Text;
    end;
    edSql.Text := sSqlSen;
  end; // whole sql
end;

procedure TfrQueryWizard.pcSelectChange(Sender: TObject);
begin
  if pcSelect.ActivePage = tabSelectSQL then
    makeQuerySql([pSelect]);
end;

procedure TfrQueryWizard.changeShowSetting(Sender: TObject);
var
  nTag : integer;
  bCheck : boolean;
begin
  nTag := (Sender as TCheckBox).Tag;
  bCheck := (Sender as TCheckBox).Checked;

  case nTag  of
  1:begin
      if bCheck then
        m_Config.showPanelSet := m_Config.showPanelSet+[pSelect]
      else
        m_Config.showPanelSet := m_Config.showPanelSet-[pSelect];

      tabSelect.TabVisible := pSelect in m_Config.showPanelSet;
      tabOrder.TabVisible := [pSelect,pOrder] <= m_Config.showPanelSet;
      tabGroup.TabVisible := [pGroup,pSelect] <= m_Config.showPanelSet;
      tabHaving.TabVisible := [pGroup,pSelect,pHaving] <= m_Config.showPanelSet;
    end;
  2:begin
      if bCheck then
        m_Config.showPanelSet := m_Config.showPanelSet+[pFrom]
      else
        m_Config.showPanelSet := m_Config.showPanelSet-[pFrom];

      tabFrom.TabVisible := pFrom in m_Config.showPanelSet;
    end;
  3:begin
      if bCheck then
        m_Config.showPanelSet := m_Config.showPanelSet+[pWhere]
      else
        m_Config.showPanelSet := m_Config.showPanelSet-[pWhere];

      tabWhere.TabVisible := pWhere in m_Config.showPanelSet;
    end;
  4:begin
      if bCheck then
        m_Config.showPanelSet := m_Config.showPanelSet+[pGroup]
      else
        m_Config.showPanelSet := m_Config.showPanelSet-[pGroup];
      tabGroup.TabVisible := [pGroup,pSelect] <= m_Config.showPanelSet;
      tabHaving.TabVisible := [pGroup,pSelect,pHaving] <= m_Config.showPanelSet;
    end;
  5:begin
      if bCheck then
        m_Config.showPanelSet := m_Config.showPanelSet+[pHaving]
      else
        m_Config.showPanelSet := m_Config.showPanelSet-[pHaving];
      tabHaving.TabVisible := [pGroup,pSelect,pHaving] <= m_Config.showPanelSet;
    end;
  6:begin
      if bCheck then
        m_Config.showPanelSet := m_Config.showPanelSet+[pOrder]
      else
        m_Config.showPanelSet := m_Config.showPanelSet-[pOrder];
      tabOrder.TabVisible := [pSelect,pOrder] <= m_Config.showPanelSet;
    end;
  7:begin
      m_Config.bAutoShowGroup := cbAutoShowGroup.Checked;
    end;
  8:begin
      m_Config.bAutoShowHaving := cbAutoShowHaving.Checked;
    end;
  9:begin
      m_Config.bShowWizard := cbShowWizard.Checked;
      tabWizard.TabVisible := m_Config.bShowWizard;
    end;
  10:begin
      m_Config.bShowRun :=cbShowRun.Checked;
      tabRunAsMode.TabVisible := m_Config.bShowRun;
    end;
  11:begin
      m_Config.bShowSetting := cbShowSetting.Checked;
      tabSetting.TabVisible := m_Config.bShowSetting;
    end;
  12:begin
      m_Config.bCanNamed := cbShowSqlName.Checked;
      ledSQLName.Visible := m_Config.bCanNamed;
    end;
  13:begin
      m_Config.bCheckSql := cbShowCheckSql.Checked;
      btnCheckSql.Visible := m_Config.bCheckSql;
    end;
  14:begin
      m_Config.bShowMDLWizard := cbShowMDLWizard.Checked;
      tabMDLWizard.TabVisible := m_Config.bShowMDLWizard;
    end;
  15:begin
      m_Config.bShowDDLWizard := cbShowDDLWizard.Checked;
      tabDDLWizard.TabVisible := m_Config.bShowDDLWizard;
    end;
  16:begin
      m_Config.bCanRunMDL := cbCanRunMDL.Checked;
    end;
  17:begin
      m_Config.bCanRunDDL := cbCanRunDDL.Checked;
    end;
  end;
end;

procedure TfrQueryWizard.rgShowSQLClick(Sender: TObject);
var
  nSel:integer;
begin
  nSel := rgShowSQL.ItemIndex;
  m_Config.nShowSQL := nSel;

  tabSQL.TabVisible := m_Config.nShowSQL>0;
  edSQL.ReadOnly := m_Config.nShowSQL = 1;
  tabSelectSQL.TabVisible := m_Config.nShowSQL>0;
  edSelectSQL.ReadOnly := m_Config.nShowSQL = 1;
  tabFromSQL.TabVisible := m_Config.nShowSQL>0;
  edFromSQL.ReadOnly := m_Config.nShowSQL = 1;
  tabWhereSQL.TabVisible := m_Config.nShowSQL>0;
  edWhereSQL.ReadOnly := m_Config.nShowSQL = 1;
  tabGroupSQL.TabVisible := m_Config.nShowSQL>0;
  edGroupSQL.ReadOnly := m_Config.nShowSQL = 1;
  tabHavingSQL.TabVisible := m_Config.nShowSQL>0;
  edHavingSQL.ReadOnly := m_Config.nShowSQL = 1;
  tabOrderSQL.TabVisible := m_Config.nShowSQL>0;
  edOrderSQL.ReadOnly := m_Config.nShowSQL = 1;
end;

procedure TfrQueryWizard.trimQuerySql;
var
  changePanels : PANELSET;
begin
  if m_preRelationPage = tabSelect then
  begin
    if tabFrom.TabVisible then
      makeTableList;
    if tabGroup.TabVisible then
      makeGroupPanel;
    if tabHaving.TabVisible then
      configHavingField;
    if tabOrder.TabVisible then
      configOrderField;
  end;

  if m_preRelationPage = tabWhere then
    makeTableList;

  changePanels := [];
  if (tabSelect.TabVisible) and (pcSelect.ActivePage = tabSelectWizard) then
    changePanels := changePanels+[pSelect];
  if (tabFrom.TabVisible) and (pcFrom.ActivePage = tabFromWizard) then
    changePanels := changePanels+[pFrom];
  if (tabWhere.TabVisible) and (pcWhere.ActivePage = tabWhereWizard) then
    changePanels := changePanels+[pWhere];
  if (tabGroup.TabVisible) and (pcGroup.ActivePage = tabGroupWizard) then
    changePanels := changePanels+[pGroup];
  if (tabHaving.TabVisible) and (pcHaving.ActivePage = tabHavingWizard) then
    changePanels := changePanels+[pHaving];
  if (tabOrder.TabVisible) and (pcOrder.ActivePage = tabOrderWizard) then
    changePanels := changePanels+[pOrder];

  makeQuerySql(changePanels,true);
end;

procedure TfrQueryWizard.QueryTopRows;
var
  sSqlSen,sMsg,sSplitLine,sTemp : String;
  sPrams :TStrings;
  i,nC,nT,nL,j : integer;
begin
  sSqlSen := edSql.Text;
  case m_Config.dbConfig.DBType  of
    MSAccess,SQLServer :
      sSqlSen := 'select top '+ IntToStr( m_Config.nQueryAsModeRows ) +
                 ' * From (' + sSqlSen +')';
    Oracle :
      sSqlSen := 'select * From (' + sSqlSen +') '+
                 'where rownum <= '+ IntToStr( m_Config.nQueryAsModeRows );

    DB2 :
      if m_Config.nQueryAsModeRows > 1 then
        sSqlSen := sSqlSen + ' fetch first '+IntToStr( m_Config.nQueryAsModeRows )+ ' rows only'
      else
        sSqlSen := sSqlSen + ' fetch first '+IntToStr( m_Config.nQueryAsModeRows )+ ' row only';
  end;

  edResult.Clear;

  try
    CltDMConn.ConnectDB;
    nT := GetTickCount;
    if lvParams.Items.Count > 0 then
    begin
      sPrams := TStringList.Create;
      for i:=0 to lvParams.Items.Count-1 do
        sPrams.add(lvParams.Items[i].SubItems[0]);
      CltDMConn.QueryDB(sSqlSen,sPrams);
      sPrams.Free;
    end
    else
      CltDMConn.QueryDB(sSqlSen);

    nC := CltDMConn.FieldCount;

    sMsg:= '';
    for i:=0 to nC-1 do
    begin
      sTemp := CltDMConn.FieldByInd(i).DisplayName;
      nL := CltDMConn.FieldByInd(i).Size;
      if nl>0 then
      begin
        if nL > length(sTemp) then
        begin
          for j:= length(sTemp) to nL-1 do
            sTemp := sTemp+' ';
        end else if nL < length(sTemp) then
          sTemp := Copy(sTemp,1,nL);
      end;
      sMsg := sMsg + sTemp + chr(9);
    end;
    edResult.Lines.Add(sMsg);

    sSplitLine := sMsg;
    for i:=1 to length(sSplitLine) do
      if sSplitLine[i] <> chr(9) then
        sSplitLine[i] :='-';

    edResult.Lines.Add(sSplitLine);
    while not CltDMConn.EndOfQuery do
    begin
      sMsg:= '';
      for i:=0 to nC-1 do
        sMsg := sMsg + CltDMConn.FieldAsString(i) + chr(9);
      edResult.Lines.Add(sMsg);

      CltDMConn.NextRecord;
    end;
    CltDMConn.CloseQuery;
    edResult.Lines.Add(sSplitLine);
    nT := GetTickCount - nT;
    edResult.Lines.Add('耗时 '+IntToStr(nT)+' 毫秒');
    CltDMConn.Disconnect;
  except
  end;
end;


procedure TfrQueryWizard.pcDesignChange(Sender: TObject);
begin
  if pcDesign.ActivePage = tabSetting then
  begin
    rgShowSQL.ItemIndex := m_Config.nShowSQL;
    cbShowSelect.Checked := pSelect in m_Config.showPanelSet;
    cbShowFrom.Checked := pFrom in m_Config.showPanelSet;
    cbShowWhere.Checked := pWhere in m_Config.showPanelSet;
    cbShowGroup.Checked := pGroup in m_Config.showPanelSet;
    cbShowHaving.Checked := pHaving in m_Config.showPanelSet;
    cbShowOrder.Checked := pOrder in m_Config.showPanelSet;

    cbAutoShowGroup.Checked := m_Config.bAutoShowGroup;
    cbAutoShowHaving.Checked := m_Config.bAutoShowHaving;
    cbShowWizard.Checked := m_Config.bShowWizard;
    cbShowRun.Checked := m_Config.bShowRun;
    cbShowSetting.Checked := m_Config.bShowSetting;
    cbShowMDLWizard.Checked := m_Config.bShowMDLWizard;
    cbShowDDLWizard.Checked := m_Config.bShowDDLWizard;

    cbShowSqlName.Checked := m_Config.bCanNamed;
    cbShowCheckSql.Checked := m_Config.bCheckSql;

    ledDBConn.Text := svrInfo.sDBConn;
    edGetTabSQL.Text := m_Config.dbConfig.sGetTabSql;
    edGetColSQL.Text := m_Config.dbConfig.sGetColSql;
    edGetRelSQL.Text := m_Config.dbConfig.sGetRelSql;
    edGetRelDetailSQL.Text := m_Config.dbConfig.sGetRelDetailSql;

    cbCanRunMDL.Checked := m_Config.bCanRunMDL;
    cbCanRunDDL.Checked := m_Config.bCanRunDDL;
    edRetFirstRows.Text := IntToStr(m_Config.nQueryAsModeRows);
    case m_Config.dbConfig.DBType of
      SQLServer: cbDBType.ItemIndex := 0;//SQLServer;
      MSAccess: cbDBType.ItemIndex := 1;//MSAccess;
      DB2: cbDBType.ItemIndex := 2;//DB2;
      Oracle: cbDBType.ItemIndex := 3;//Oracle;
    end;
  end else if pcDesign.ActivePage = tabSql then
  begin
    trimQuerySql;
  end else if pcDesign.ActivePage = tabRunAsMode then
  begin
    trimQuerySql;
    QueryTopRows;//edResult.Text :=' hello tabRunAsMode ';
  end;

  m_preDesignPage := pcDesign.ActivePage;
end;

procedure TfrQueryWizard.showSettingPage(Sender: TObject);
begin
  if tabSetting.TabVisible = false then
  begin
    tabSetting.TabVisible := true;
    m_Config.bShowSetting := true;
    cbShowSetting.Checked := true;
  end;
end;

procedure TfrQueryWizard.changeLogicComboBox(cbLogicOpt:TComboBox;dataType:COLDATATYPE);
var
  i:integer;
begin
  cbLogicOpt.Clear;
  for i:=0 to CONLOGICOPTMAXIND do
  begin
    if (conLogicOptList[i].dataType = dataType) or
        (conLogicOptList[i].dataType =  CT_NONE) then
    begin
      cbLogicOpt.AddItem(conLogicOptList[i].sOptName,TObjPointer.Create(@(conLogicOptList[i])));
    end;
  end;
end;

procedure TfrQueryWizard.loadDictionaryData(cbDictData:TComboBox;refSataCode:String);
var
  sSqlSen:String;
  sWord,sDataValue,sDataDesc:String;
  nPos : Integer;
begin
  cbDictData.Clear;
  nPos := 1;
  sWord := TCommonFunc.GetAWord(refSataCode,nPos);
  if UpperCase(sWord) = 'SELECT' then
  begin
    sSqlSen := refSataCode; //'select DATACODE,DATAVALUE from DATADICTIONARY where CATALOGCODE=''DATATYPE''';
    CltDMConn.ConnectDB;
    CltDMConn.QueryDB(sSqlSen);
    while not CltDMConn.EndOfQuery do
    begin
      cbDictData.AddItem(CltDMConn.FieldAsString(1),
          TObjString.Create(CltDMConn.FieldAsString(0)) );
      CltDMConn.NextRecord;
    end;
    CltDMConn.CloseQuery;
    CltDMConn.Disconnect;
  end else
  begin
    while sWord<>'' do
    begin
      sDataValue := sWord;
      sWord := TCommonFunc.GetAWord(refSataCode,nPos);
      if sWord=':' then
        sWord := TCommonFunc.GetAWord(refSataCode,nPos);
      if (sWord = '') or (sWord = ';') or (sWord = ',')  then
        sDataDesc := sDataValue
      else
      begin
        sDataDesc := sWord;
        sWord := TCommonFunc.GetAWord(refSataCode,nPos);
      end;
      cbDictData.AddItem(sDataDesc,
          TObjString.Create(sDataValue));
      if (sWord = ';') or (sWord = ',') then
        sWord := TCommonFunc.GetAWord(refSataCode,nPos);
    end;
  end;
end;

procedure TfrQueryWizard.trTableColPWChange(Sender: TObject;
  Node: TTreeNode);
var
  curSelCol :PColumnRec;
  selNode : TTreeNode;
  colType : COLDATATYPE;
  sColSql:String;
  i : integer;
  pItem : PTreeItemData;
begin
  //m_preSelColPW
  if not m_bCreate then Exit;
  selNode := trTableColPW.Selected;
  if selNode = nil then Exit;
  pItem := PTreeItemData(selNode.Data);
  if pItem^.nStype <> 0 then Exit;
  curSelCol := PColumnRec(pItem^.data2);

  dtpDataValue.Visible := false;
  cbCurrentDate.Visible := false;
  lbDictionaryValue.Visible := false;
  cbDictionaryDataValue.Visible := false;
  btnSubQuery.Visible := false;
  ledDealFieldPrm1PW.Visible := false;
  ledDealFieldPrm2PW.Visible := false;

  if (m_preSelColWP = nil) or (m_preSelColWP<>pItem) then
  begin
    m_preSelColWP := pItem;

//    sColSql := m_preSelColWP^.sTabName +'.'+ curSelCol^.sColCode;
    if m_Config.nTableNameType = 1 then
      sColSql := m_preSelColWP^.sTabName +'.'+ curSelCol^.sColCode
    else if m_Config.nTableNameType = 2 then
      sColSql := curSelCol^.sTBCode +'.'+ curSelCol^.sColCode
    else
      sColSql := curSelCol^.sColCode;

    ledFieldDescPW.Text := curSelCol^.sColName;
    ledFieldSqlPW.Text := sColSql;
    colType := GetDataType(curSelCol^.sColType);
    if m_preColTypeWP <> colType then
    begin
      changeLogicComboBox(cbLogicOptPW,colType);
      cbLogicOptPW.AddItem(DONOTHINGOPT.sOptName,TObjPointer.Create(@(DONOTHINGOPT)));
      m_preColTypeWP := colType;
    end else
      cbLogicOptPW.ItemIndex := -1;

    
    cbDealFieldPW.Clear;
    for i:=0 to CONOPTMAXIND do
    begin
      if ( (conOptList[i].dataType = colType) or
           (conOptList[i].dataType = CT_NONE) ) and
         ( not conOptList[i].bStatOpt ) then
      begin
        cbDealFieldPW.AddItem(conOptList[i].sOptName,TObjPointer.Create(@(conOptList[i])));
      end;
    end;
//    cbDealFieldPW.ItemIndex := 0;
    
    if curSelCol^.sRefDataCode <> '' then
      loadDictionaryData(cbDictionaryDataValue,curSelCol^.sRefDataCode);
  end;
end;

procedure TfrQueryWizard.updateSqlAndDescInPW(Sender: TObject);
var
  pOpt : PColOperate;
  sStr:String;
  sColSql:String;
  colType : COLDATATYPE;
  curSelCol :PColumnRec;
begin
  if m_preSelColWP=nil then Exit;
  curSelCol := PColumnRec(m_preSelColWP^.data2);
//TComponent
  if cbDealFieldPW.ItemIndex < 0 then Exit;
  pOpt := PColOperate(TObjPointer(cbDealFieldPW.Items.Objects[cbDealFieldPW.ItemIndex]).pData);

  ledDealFieldPrm1PW.Visible := pOpt^.nOptPrmSum>0;
  ledDealFieldPrm2PW.Visible := pOpt^.nOptPrmSum>1;
  colType := pOpt^.retType;
  if colType = CT_NONE then
    colType := GetDataType(curSelCol^.sColType);
  if m_preColTypeWP <> colType then
  begin
    changeLogicComboBox(cbLogicOptPW,colType);
    cbLogicOptPW.AddItem(DONOTHINGOPT.sOptName,TObjPointer.Create(@(DONOTHINGOPT)));
    m_preColTypeWP := colType;
  end;
  //sColSql := m_preSelColWP^.sTabName +'.'+ curSelCol^.sColCode;
  if m_Config.nTableNameType = 1 then
    sColSql := m_preSelColWP^.sTabName +'.'+ curSelCol^.sColCode
  else if m_Config.nTableNameType = 2 then
    sColSql := curSelCol^.sTBCode +'.'+ curSelCol^.sColCode
  else
    sColSql := curSelCol^.sColCode;

  if pOpt^.nOptPrmSum = 0 then
  begin
    FmtStr(sStr,pOpt^.sOptSqlFmt,[sColSql]);
    ledFieldSqlPW.Text := sStr;
    FmtStr(sStr,pOpt^.sOptDescFmt,[curSelCol^.sColName]);
    ledFieldDescPW.Text := sStr;
  end;

  if pOpt^.nOptPrmSum = 1 then
  begin
    FmtStr(sStr,pOpt^.sOptSqlFmt,[sColSql,ledDealFieldPrm1PW.Text]);
    ledFieldSqlPW.Text := sStr;
    FmtStr(sStr,pOpt^.sOptDescFmt,[curSelCol^.sColName,ledDealFieldPrm1PW.Text]);
    ledFieldDescPW.Text := sStr;
  end;

  if pOpt^.nOptPrmSum = 2 then
  begin
    FmtStr(sStr,pOpt^.sOptSqlFmt,[sColSql,ledDealFieldPrm1PW.Text,ledDealFieldPrm2PW.Text]);
    ledFieldSqlPW.Text := sStr;
    FmtStr(sStr,pOpt^.sOptDescFmt,[curSelCol^.sColName,ledDealFieldPrm1PW.Text,ledDealFieldPrm2PW.Text]);
    ledFieldDescPW.Text := sStr;
  end;

end;

procedure TfrQueryWizard.cbLogicOptPWSelect(Sender: TObject);
var
  pOpt : PColOperate;
 // colType : COLDATATYPE;
  curSelCol :PColumnRec;
begin
  if m_preSelColWP=nil then Exit;
  curSelCol := PColumnRec(m_preSelColWP^.data2);

  if cbLogicOptPW.ItemIndex < 0 then Exit;
  pOpt := PColOperate(TObjPointer(cbLogicOptPW.Items.Objects[cbLogicOptPW.ItemIndex]).pData);
  dtpDataValue.Visible := false;
  cbCurrentDate.Visible := false;
  lbDictionaryValue.Visible := false;
  cbDictionaryDataValue.Visible := false;
  btnSubQuery.Visible := false;
  if pOpt^.nOptPrmSum = 2 then
  begin
    btnSubQuery.Visible := true;
    Exit;
  end;

  if curSelCol.sRefDataCode<>''then
  begin
    lbDictionaryValue.Visible := true;
    cbDictionaryDataValue.Visible := true;
    Exit;
  end;
  //colType := GetDataType(curSelCol^.sColType);
  dtpDataValue.Visible :=  m_preColTypeWP = CT_DATE;
  cbCurrentDate.Visible := m_preColTypeWP = CT_DATE;
  cbCurrentDate.Checked := false;
end;

procedure TfrQueryWizard.chageDataValuePW(Sender: TObject);
var
  nTag : Integer;
begin
  //change data value
  nTag := TComponent(Sender).Tag;
  if nTag = 1 then
  begin
    ledValuePW.Text := FormatDatetime('YYYY-MM-DD',dtpDataValue.DateTime);
  end;
  if nTag = 2 then
  begin
    if cbDictionaryDataValue.ItemIndex>=0 then
      ledValuePW.Text :=TObjString(
        cbDictionaryDataValue.Items.Objects[cbDictionaryDataValue.ItemIndex]
        ).str;
  end;
end;


function TfrQueryWizard.IsParameter(const sValue:string):integer;
var
  sTemp:String;
  nSl :integer;
begin
  result := -1;
  nSl := length(sValue);
  if nSl<8 then Exit;  //':PRM_NO';
  sTemp := Copy(sValue,1,7);
  if sTemp<>SPARAM_PREFIX then Exit;
  sTemp :=  Copy(sValue,8,nSl-7);
  if not TCommonFunc.IsNumber(sTemp) then Exit;
  nSl := -1;
  try
    nSl := StrToInt(sTemp);
  except
  end;
  if (nSl>=0) and (nSl<m_Result.nPrmSum) then
    result := nSl;
end;

function TfrQueryWizard.TrimInputConditionValue
      (const nPrmSum:integer;const dataType:COLDATATYPE; var sValue:String):boolean;
var
  nPos,nCount:integer;
  sAWord:String;
  sStrs : TStrings;
  bIsSysdate:boolean;
begin
  result := false;
  if (nPrmSum > 0) and (sValue = '') then
  begin
    ShowMessage('请输入数值！');
    Exit;
  end;
//(CT_NONE,CT_NUM, CT_CHAR, CT_STRING,CT_DATE,CT_TIME,CT_DATETIME);

  if (nPrmSum = 1) then
  begin
    if (dataType = CT_CHAR) then
    begin
      if length(sValue)>1 then
        sValue := sValue[1];
      sValue:= QuotedStr(sValue);
    end else if (dataType = CT_STRING) then
    begin
      sValue:= QuotedStr(sValue);
    end else if dataType = CT_DATE then
    begin
      bIsSysdate := false;
      case m_Config.dbConfig.DBType  of
        MSAccess :
          bIsSysdate := sValue = 'now';
        Oracle :
          bIsSysdate := sValue = 'sysdate';
        SQLServer:
          bIsSysdate := sValue = 'getdate()';
        DB2 :
          bIsSysdate := sValue = 'current date';
      end;
      if not bIsSysdate then
      begin
        sValue := TCommonFunc.TrimDateString(sValue);
        if not TCommonFunc.IsDate(sValue) then
        begin
          ShowMessage('输入的日期格式不正确！');
          Exit;
        end;

        case m_Config.dbConfig.DBType  of
          MSAccess :
            sValue := '#'+sValue+'#';
          Oracle:
            sValue := 'to_date('+QuotedStr(sValue)+',''yyyy-mm-dd'')';
          SQLServer, DB2 :
            sValue := QuotedStr(sValue);
        end;
      end;
    end else if dataType = CT_NUM then
    begin
      if not TCommonFunc.IsNumber(sValue) then
      begin
        ShowMessage('请输入数值！');
        Exit;
      end;
    end;
  end;

  if (nPrmSum = 3) then  // like
  begin
    if (Pos('%',sValue) = 0) and (Pos('_',sValue) = 0) then
      sValue := '%'+sValue+'%';
    sValue := QuotedStr(sValue);
  end;

  if (nPrmSum = 2) then  // in
  begin
    if dataType = CT_STRING then
    begin
      nPos := 1;
      sAWord := TCommonFunc.GetAWord(sValue,nPos);
      if UpperCase(sAWord) <> 'SELECT' then
      begin
        sStrs := TStringList.Create;
        nCount := TCommonFunc.SplitString(sValue,',',sStrs);
        if nCount = 0 then
        begin
          sStrs.Free;
          ShowMessage('输入的数据不正确！');
          Exit;
        end;
        sValue := QuotedStr(sStrs[0]);
        for nPos:=1 to nCount-1 do
          sValue := sValue+','+QuotedStr(sStrs[nPos]);
        sStrs.Free;
      end;
    end
  end;
  result := true;
end;


procedure TfrQueryWizard.btnAddConditionPWClick(Sender: TObject);
var
  liSelect : TListItem;
  sSql,sValue,sDesc,sLogic,sLogicDesc:String;
  nOpt,nCount,nTemp: Integer;
  pOpt : PColOperate;
  bSignValue,bFormula,bC : boolean;

  function GetFormualSql(const sQ:String;var bCorrect:boolean):string;
  var
    sSqlSen,sWord,sFormula:String;
    iCount,nInd,nPos,nBC,nPreWordType:integer;
  begin
    nPreWordType := 0;
    bCorrect := true;
    nBC := 0;
    sFormula := sQ;
    iCount := lvSelectingField.Items.Count;
    nPos := 1;
    sSqlSen := '';
    sWord := TCommonFunc.GetAWord(sFormula,nPos);
    while sWord<>'' do
    begin
      if (length(sWord) = 1) and
        (sWord[1] in ['+','-','*','/']) then
      begin
{        sSqlSen := sSqlSen+'* ';   // 0: 1:*+ 2:( 3:) 4:! 5: N
        if nPreWordType in [0,1,2,4] then
           bCorrect := false;
        nPreWordType := 1;
      end else if sWord='+' then
      begin
}
        sSqlSen := sSqlSen+sWord+' ';
        if nPreWordType in [0,1,2,4]  then
           bCorrect := false;
        nPreWordType := 1;
      end else if sWord='(' then
      begin
        sSqlSen := sSqlSen+'( ';
        if nPreWordType in [3,5]  then
           bCorrect := false;
        nPreWordType := 2;
        Inc(nBC);
      end else if sWord=')' then
      begin
        sSqlSen := sSqlSen+') ';
        if nPreWordType in [0,1,2,4]  then
           bCorrect := false;
        nPreWordType := 3;
        Dec(nBC);
        if nBC<0 then
          bCorrect := false;
      end else
      begin
        if TCommonFunc.IsNumber(sWord) then
        begin
          nInd := StrToInt(sWord)-1;
          if (nInd>=0) and (nInd<iCount) then
          begin
            if lvConditionPW.Items[nInd].SubItems[1] <> DONOTHINGOPT.sOptName then  //检验是否为表达式
              bCorrect := false;
//          pItemData := PTreeItemData(lvConditionPW.Items[nInd].Data);
//          if pItemData^.dataType <> CT_NUM then
//             bCorrect := false;
            sSqlSen := sSqlSen+lvConditionPW.Items[nInd].SubItems[0]+' ';
          end else
             bCorrect := false;
          if nPreWordType in [3,5] then
             bCorrect := false;
          nPreWordType := 5;
        end else
          bCorrect := false;
      end;
      sWord := TCommonFunc.GetAWord(sFormula,nPos);
    end;
    if nPreWordType in [1,2,4] then
       bCorrect := false;
    if nBC<>0 then
      bCorrect := false;
    result := sSqlSen;
  end;

begin
  sSql := trim(ledFieldSqlPW.Text);
  if sSql = '' then
  begin
    ShowMessage('请输入字段语句！');
    Exit;
  end;

  bFormula := false;
  nOpt := cbDealFieldPW.ItemIndex;
  if (nOpt>=0) then
  begin
    pOpt := PColOperate(TObjPointer(cbDealFieldPW.Items.Objects[nOpt]).pData);
    bFormula := pOpt^.nOptPrmSum = -1;
  end;

  if bFormula then
  begin
    bC := false;
    sSql := GetFormualSql(sSql,bC);
    if not bC then
    begin
      ShowMessage('表达式输入有误！');
      Exit;
    end;
  end;

  nOpt := cbLogicOptPW.ItemIndex;
  if (nOpt<0) then Exit;
  pOpt := PColOperate(TObjPointer(cbLogicOptPW.Items.Objects[nOpt]).pData);

  bSignValue := pOpt^.nOptPrmSum = -2;

  if bSignValue then
  begin
    if m_preColTypeWP <> CT_NUM then
    begin
      ShowMessage('只能标记数值类型的字段！');
      Exit;
    end;
    nCount := lvConditionPW.Items.Count+1;
    liSelect := lvConditionPW.Items.Add;
    liSelect.Caption := IntToStr(nCount);
    liSelect.SubItems.Add(sSql);
    liSelect.SubItems.Add(DONOTHINGOPT.sOptName);
    liSelect.SubItems.Add('');
    liSelect.SubItems.Add(sSql);
    liSelect.SubItems.Add(ledFieldDescPW.Text);
    liSelect.Data := m_preSelColWP;
    lvConditionPW.ItemIndex := nCount-1;
    Exit;
  end;

  sValue := trim(ledValuePW.Text);
  nTemp := IsParameter(sValue);
  if nTemp > -1 then
  begin
    sDesc := lvParams.Items[nTemp].Caption;
  end else
  begin
    sDesc := sValue;
    if not TrimInputConditionValue(pOpt^.nOptPrmSum,m_preColTypeWP,sValue) then Exit;
  end;

  if pOpt^.nOptPrmSum=0 then
  begin
    FmtStr(sLogic,pOpt^.sOptSqlFmt,[sSql]);
    FmtStr(sLogicDesc,pOpt^.sOptDescFmt,[ledFieldDescPW.Text]);
  end else
  begin
    FmtStr(sLogic,pOpt^.sOptSqlFmt,[sSql,sValue]);
    FmtStr(sLogicDesc,pOpt^.sOptDescFmt,[ledFieldDescPW.Text,sDesc]);
  end;

  nCount := lvConditionPW.Items.Count+1;
  liSelect := lvConditionPW.Items.Add;
  liSelect.Caption := IntToStr(nCount);
  liSelect.SubItems.Add(sSql);
  liSelect.SubItems.Add(pOpt^.sOptName);
  liSelect.SubItems.Add(sValue);
  liSelect.SubItems.Add(sLogic);
  liSelect.SubItems.Add(sLogicDesc);
  liSelect.Data := m_preSelColWP;
  lvConditionPW.ItemIndex := nCount-1;

  sSql := edWhereFormula.Text;
  if sSql='' then
    edWhereFormula.Text := IntToStr(nCount)
  else
    edWhereFormula.Text := sSql +' * ' + IntToStr(nCount);

end;

procedure TfrQueryWizard.btnUpdateConditionPWClick(Sender: TObject);
var
  liSelect : TListItem;
  sSql,sValue,sDesc,sLogic,sLogicDesc:String;
  nOpt,nTemp: Integer;
  pOpt : PColOperate;
begin
  liSelect := lvConditionPW.Selected;
  if liSelect=nil then Exit;

  nOpt := cbLogicOptPW.ItemIndex;
  if nOpt<0 then Exit;
  pOpt := PColOperate(TObjPointer(cbLogicOptPW.Items.Objects[nOpt]).pData);

  sSql := trim(ledFieldSqlPW.Text);
  if sSql = '' then
  begin
    ShowMessage('请输入字段语句！');
    Exit;
  end;
  sValue := trim(ledValuePW.Text);

  nTemp := IsParameter(sValue);
  if nTemp > -1 then
  begin
    sDesc := lvParams.Items[nTemp].Caption;
  end else
  begin
    sDesc := sValue;
    if not TrimInputConditionValue(pOpt^.nOptPrmSum,m_preColTypeWP,sValue) then Exit;
  end;

  if pOpt^.nOptPrmSum=0 then
  begin
    FmtStr(sLogic,pOpt^.sOptSqlFmt,[sSql]);
    FmtStr(sLogicDesc,pOpt^.sOptDescFmt,[ledFieldDescPW.Text]);
  end else
  begin
    FmtStr(sLogic,pOpt^.sOptSqlFmt,[sSql,sValue]);
    FmtStr(sLogicDesc,pOpt^.sOptDescFmt,[ledFieldDescPW.Text,sDesc]);
  end;

  liSelect.SubItems[0] := sSql;
  liSelect.SubItems[1] := pOpt^.sOptName;
  liSelect.SubItems[2] := sValue;
  liSelect.SubItems[3] := sLogic;
  liSelect.SubItems[4] := sLogicDesc;
  liSelect.Data := m_preSelColWP;
end;

procedure TfrQueryWizard.editConditionFormulaPW(Sender: TObject);
var
  nTag:integer;
  sStr:String;
begin
  sStr:='';
  nTag := TComponent(Sender).Tag;
  case nTag of
  1: sStr := '* ';
  2: sStr := '+ ';
  3: sStr := '! ';
  4: sStr := '( ';
  5: sStr := ') ';
  10:
        if lvConditionPW.ItemIndex>=0 then
        begin
          sStr := IntToStr(lvConditionPW.ItemIndex+1);
          sStr := sStr+' ';
        end;
  end;
  edWhereFormula.SetSelTextBuf(PChar(sStr));
end;

procedure TfrQueryWizard.filterInputCharacter(Sender: TObject;
  var Key: Char);
var
  nTag:integer;
begin
  nTag := TComponent(Sender).Tag;
  if nTag = 1 then  // 简单表达式
  begin
    if not (key in ['0'..'9',' ','(',')','+','*','!',char(VK_BACK) ]) then
	    key := #0;
  end;
  if nTag = 2 then  // 字符串
  begin
    if not (key in ['0'..'9','a'..'z','A'..'Z','_',char(VK_BACK) ]) then
	    key := #0;
  end;
  if nTag = 3 then  // 仅数字
  begin
    if not (key in ['0'..'9',char(VK_BACK) ]) then
	    key := #0;
  end;

end;

function TfrQueryWizard.trimFormulaInput(const sInSql:string;nDelCon:integer=0):string;
var
  sInWords:TStrings;
  sOutSql,sPreWord,sWord:String;
  nPos,nInd,nCount,nPreWordType,nBC : Integer;
begin
  sInWords := TStringList.Create;
  nPos := 1;
  nCount := 0;
  sWord := TCommonFunc.GetAWord(sInSql,nPos);
  nBC := 0;
  // 0: 1:*+ 2:( 3:) 4:! 5: N
  while sWord<>'' do
  begin
    nPreWordType := 0;
    if nCount>0 then
    begin
      sPreWord := sInWords[nCount-1];
      if (sPreWord='*') or (sPreWord='+') then
        nPreWordType := 1
      else  if (sPreWord='(') then
        nPreWordType := 2
      else  if (sPreWord=')') then
        nPreWordType := 3
      else  if (sPreWord='!') then
        nPreWordType := 4
      else
        nPreWordType := 5;
    end;

    if (sWord='*') or (sWord='+') then
    begin
      //if nPreWordType=0 then donothing
      if nPreWordType in [3,5] then
      begin
        sInWords.Add(sWord);
        Inc(nCount);
      end;
    end
    else  if (sWord='(') then
    begin
      if nPreWordType in [0,1,2,4] then
      begin
        sInWords.Add(sWord);
        Inc(nBC);
        Inc(nCount);
      end;

      if nPreWordType=5 then
      begin
        sInWords.Delete(nCount-1);
        Dec(nCount);
        continue;
      end;
    end
    else  if (sWord=')') then
    begin
      if (nBC>0) and (nPreWordType in [3,5]) then
      begin
        sInWords.Add(sWord);
        Dec(nBC);
        Inc(nCount);
      end;

      if nPreWordType=2 then
      begin
        sInWords.Delete(nCount-1);
        Dec(nCount);
        Dec(nBC);
      end;
      
      if nPreWordType in [1,4] then
      begin
        sInWords.Delete(nCount-1);
        Dec(nCount);
        continue;
      end;
    end
    else  if (sWord='!') then
    begin
      if nPreWordType in [0,1,2] then
      begin
        sInWords.Add(sWord);
        Inc(nCount);
      end;
    end
    else
    begin
      if (sWord <> IntToStr(nDelCon) ) and
        (nPreWordType in [0,1,2]) then
      begin
        nInd := StrToInt(sWord);
        if (nDelCon<>0) and ( nInd>nDelCon) then
          sWord := IntToStr(nInd-1);
        sInWords.Add(sWord);
        Inc(nCount);
      end;
    end;

    sWord := TCommonFunc.GetAWord(sInSql,nPos);
  end;

  while nCount>0 do
  begin
    sPreWord := sInWords[nCount-1];
    if (sPreWord='*') or (sPreWord='+') or (sPreWord='(') or (sPreWord='!') then
    begin
      sInWords.Delete(nCount-1);
      Dec(nCount);
    end else
      break;
  end;
  if nCount>0 then
  begin
    sOutSql := sInWords[0];
    for nPos:=1 to nCount-1 do
      sOutSql := sOutSql + ' ' + sInWords[nPos];
  end;

  sInWords.Free;
  result := sOutSql;
end;

function TfrQueryWizard.checkFormulaInput(panelType{where:1,Having:2}:integer;const bSetSql:boolean=false):boolean;
var
  sSqlSen,sFormula,sWord:String;
  nInd,nPos,nBC,iCount,nPreWordType:Integer;
  bCorrect:boolean;
  // 0: 1:*+ 2:( 3:) 4:! 5: N
  conditionList:TListView;
  edFormula:TMemo;
begin
  nPreWordType := 0;
  nBC := 0;
  bCorrect := true;
  if panelType = 1 then
  begin
    conditionList := lvConditionPW;
    edFormula := edWhereFormula;
  end else
  begin
    conditionList := lvConditionPH;
    edFormula := edHavingFormula;
  end;

  iCount := conditionList.Items.Count;
  nPos := 1;
  sFormula := edFormula.Text;
  sSqlSen := '';
  sWord := TCommonFunc.GetAWord(sFormula,nPos);
  while sWord<>'' do
  begin
    if sWord='*' then
    begin
      sSqlSen := sSqlSen+'and ';   // 0: 1:*+ 2:( 3:) 4:! 5: N
      if nPreWordType in [0,1,2,4] then
         bCorrect := false;
      nPreWordType := 1;
    end else if sWord='+' then
    begin
      sSqlSen := sSqlSen+'or ';
      if nPreWordType in [0,1,2,4]  then
         bCorrect := false;
      nPreWordType := 1;
    end else if sWord='(' then
    begin
      sSqlSen := sSqlSen+'( ';
      if nPreWordType in [3,5]  then
         bCorrect := false;
      nPreWordType := 2;
      Inc(nBC);
    end else if sWord=')' then
    begin
      sSqlSen := sSqlSen+') ';
      if nPreWordType in [0,1,2,4]  then
         bCorrect := false;
      nPreWordType := 3;
      Dec(nBC);
      if nBC<0 then
        bCorrect := false;
    end else if  (sWord='!')  then
    begin
      sSqlSen := sSqlSen+'not ';
      if nPreWordType in [3,4,5] then
         bCorrect := false;
      nPreWordType := 4;

    end else
    begin
      nInd := StrToInt(sWord)-1;
      if (nInd>=0) and (nInd<iCount) then
      begin
        if conditionList.Items[nInd].SubItems[1] = DONOTHINGOPT.sOptName then  //检验是否为表达式
          bCorrect := false;
        sSqlSen := sSqlSen+'('+conditionList.Items[nInd].SubItems[3]+') ';
      end else
         bCorrect := false;
      if nPreWordType in [3,5] then
         bCorrect := false;
      nPreWordType := 5;
    end;
    sWord := TCommonFunc.GetAWord(sFormula,nPos);
  end;
  if nPreWordType in [1,2,4] then
     bCorrect := false;
  if nBC<>0 then
    bCorrect := false;
  if bSetSql then
  begin
    if panelType = 1 then
      edWhereSQL.Text := sSqlSen
    else
      edHavingSQL.Text := sSqlSen;
  end;
  result := bCorrect;
end;

procedure TfrQueryWizard.pcWhereChange(Sender: TObject);
begin
  if pcWhere.ActivePage = tabWhereSQL then
  begin
    checkFormulaInput(1,true);
  end;
end;

procedure TfrQueryWizard.deleteTreeItemData(Sender: TObject;
  Node: TTreeNode);
begin
  if Node.Data <> nil then
  begin
    Dispose(Node.Data);
    Node.Data := nil;
  end;
end;

procedure TfrQueryWizard.trTableColPSExpanded(Sender: TObject;
  Node: TTreeNode);
var
  pItem : PTreeItemData;
  subItem: TTreeNode;
begin
  pItem := PTreeItemData(Node.Data);
  if not pItem^.bExpand then
  begin
    subItem := Node.getFirstChild;
    while subItem<>nil do
    begin
      treeItemStepit(trTableColPS,subItem);
      subItem := subItem.getNextSibling;
    end;
    pItem^.bExpand := true;
  end;
end;

procedure TfrQueryWizard.trTableColPWExpanded(Sender: TObject;
  Node: TTreeNode);
var
  pItem : PTreeItemData;
  subItem: TTreeNode;
begin
  pItem := PTreeItemData(Node.Data);
  if not pItem^.bExpand then
  begin
    subItem := Node.getFirstChild;
    while subItem<>nil do
    begin
      treeItemStepit(trTableColPW,subItem);
      subItem := subItem.getNextSibling;
    end;
    pItem^.bExpand := true;
  end;
end;

procedure TfrQueryWizard.btnDeleteConditionPWClick(Sender: TObject);
var
  liSelect : TListItem;
  i,iSel,iCount:Integer;
  sFormula:String;
begin
  liSelect := lvConditionPW.Selected;
  if liSelect=nil then Exit;
  iSel := lvConditionPW.ItemIndex;
  iCount := lvConditionPW.Items.Count;
  for i:=iSel to iCount-1 do
    lvConditionPW.Items[i].Caption := IntToStr(i);
  lvConditionPW.DeleteSelected;

  sFormula := edWhereFormula.Text;

  sFormula := trimFormulaInput(sFormula, iSel+1);
  edWhereFormula.Text := sFormula;
end;

function TfrQueryWizard.makeTableList(const bFillFromPanel:boolean=true):boolean;
var
  sStarts,sTables: TStrings;
  i,j,iCount:integer;
  pItem,pHeadItem : PTreeItemData;
  pRel : PRelRec;
  pTable: PTableRec;
  tableList : TObjectList;
  bNotFound:boolean;

  iInd,iPos:Integer;
  sFormula,sJoinSql,sTmpSql,sSqlSen,sWord,sTable,sHeadTab,sCommonTable:String;
  formItem:TListItem;

  function GetCommonTable(const sTab:string; const sTab2:string;
       var sComTable:String) :integer;// 0: next 1: replace 2:leave
  var
    sH,sH2,sTmp,sTmp2:string;
    nPos,nPos2:integer;
  begin
    if (sTab = sTab2) or ( (length(sTab) < length(sTab2)) and
                         ( Pos(sTab,sTab2)>0 ) ) then
    begin
      result := 2;
      Exit;
    end;
    if (length(sTab) > length(sTab2)) and
      ( Pos(sTab2,sTab)>0 ) then
    begin
      sComTable := sTab2;
      result := 1;
      Exit;
    end;

    sComTable := '';
    nPos := Pos('_',sTab);
    nPos2 := Pos('_',sTab2);
    sTmp2 := sTab2; sTmp := sTab;
    while (nPos>0) and (nPos2>0) do
    begin
      sH := Copy(sTmp,1,nPos-1);
      sH2 := Copy(sTmp2,1,nPos2-1);

      sTmp := Copy(sTmp,nPos+1,length(sTmp)-nPos);
      sTmp2 := Copy(sTmp2,nPos2+1,length(sTmp2)-nPos);

      if sH=sH2 then
      begin
        if sComTable='' then
          sComTable := sH
        else
          sComTable := sComTable+'_'+sH;
      end;
      nPos := Pos('_',sTmp);
      nPos2 := Pos('_',sTmp2);
    end;

    if sComTable='' then
      result := 0
    else
      result := 1;
  end;

begin
  sStarts := TStringList.Create;
  sTables := TStringList.Create;
  tableList := TObjectList.Create;

  // get select panel tables
  if tabSelect.TabVisible then
  begin
    iCount := lvSelectingField.Items.Count;
    for i:=0 to iCount-1 do
    begin
      pItem := PSelectItemData(lvSelectingField.Items[i].Data).pTreeItem;
      bNotFound := true;
      for j:=0 to tableList.Count-1 do
      begin
        if PTreeItemData(TObjPointer(tableList.Items[j]).pData)^.sTabName
            = pItem^.sTabName then
        begin
          bNotFound := false;
          break;
        end;
      end;
      if bNotFound then
        tableList.Add(TObjPointer.Create(pItem));
    end;
  end;
  // get where panel tables
  iCount := lvConditionPW.Items.Count;
  sFormula := edWhereFormula.Text;
  iPos := 1;
  sWord := TCommonFunc.GetAWord(sFormula,iPos);
  while sWord<>'' do
  begin
    if not ( (sWord='*') or (sWord='+') or (sWord='!') or
          (sWord='(') or (sWord=')') )  then
    begin
      iInd := StrToInt(sWord)-1;
      if (iInd >= 0) and (iInd < iCount) then
      begin
        pItem := PTreeItemData(lvConditionPW.Items[iInd].Data);
        bNotFound := true;
        for j:=0 to tableList.Count-1 do
        begin
          if PTreeItemData(TObjPointer(tableList.Items[j]).pData)^.sTabName
              = pItem^.sTabName then
          begin
            bNotFound := false;
            break;
          end;
        end;
        if bNotFound then
          tableList.Add(TObjPointer.Create(pItem));
      end;
    end;
    sWord := TCommonFunc.GetAWord(sFormula,iPos);
  end;
  // make start tables
  // GetCommonTable  // 0: next 1: replace 2:leave

  for i:=0 to tableList.Count - 1 do
  begin
    iPos := 0;
    sTable := PTreeItemData(TObjPointer(tableList.Items[i]).pData)^.sTabName;
    sCommonTable := sTable;
    for j:=0 to sStarts.Count - 1 do
    begin
      iPos := GetCommonTable(sStarts[j],
              sTable,
              sCommonTable);
      if iPos = 1 then
        sStarts[j] := sCommonTable;

      if iPos <> 0 then
        break;
    end;
    if iPos = 0 then
      sStarts.Add(sTable);
  end;
  // make from sql
  // and fill from panel if bFillFromPanel is true
  if bFillFromPanel then
     lvTabJoin.Items.Clear;
  iCount := 0;
  sSqlSen:='';
  for i:=0 to tableList.Count - 1 do
  begin
    pItem := PTreeItemData(TObjPointer(tableList.Items[i]).pData);
    pItem := pItem^.pParent;
    pHeadItem := pItem;
    iPos := 0;
    while pHeadItem<> nil do
    begin
      sHeadTab := pHeadItem^.sTabName;
      if sTables.IndexOf(sHeadTab)>=0 then
      begin
        iPos := 1;
        break;
      end;
      if sStarts.IndexOf(sHeadTab)>=0 then
      begin
        iPos := 2;
        break;
      end;
      pHeadItem := pHeadItem^.pParent;
    end;
    if iPos = 0 then  // impossible
      break;
    if (iPos = 1) or (iPos = 2)then
    begin
      sTmpSql := '';
      iInd := iCount;
      while pItem <> pHeadItem do
      begin

        pRel := PRelRec(pItem^.data2);
        if pRel = nil then break;  // impossible

        if m_Config.nTableNameType = 1 then
        begin
          sTable := pItem^.sTabName;
          sHeadTab := pItem^.pParent^.sTabName;
        end else
        begin
          sTable := pRel^.sCTBCode;
          sHeadTab := pRel^.sPTBCode;
        end;

        sJoinSql := ' '+conSJoinType[pRel^.nJoinType]+' '+ pRel^.sCTBCode + ' ' + sTable + ' on ';
        if pRel^.nDetailSum < 1 then break;//impossible

        if (m_Config.nTableNameType = 1) or ((m_Config.nTableNameType = 2)) then
          sJoinSql := sJoinSql + '('+ sHeadTab+'.'+pRel^.relDetail[0].sPColCode+
                          ' = '+sTable+'.'+ pRel^.relDetail[0].sCColCode +')'
        else
          sJoinSql := sJoinSql + '('+ pRel^.relDetail[0].sPColCode+
                            ' = ' + pRel^.relDetail[0].sCColCode +')';
        for j:=1 to pRel^.nDetailSum - 1 do
        begin
          if (m_Config.nTableNameType = 1) or ((m_Config.nTableNameType = 2)) then
            sJoinSql := sJoinSql + ' and ('+ sHeadTab+'.'+pRel^.relDetail[j].sPColCode+
                            ' = '+sTable+'.'+ pRel^.relDetail[j].sCColCode +')'
          else
            sJoinSql := sJoinSql + ' and ('+ pRel^.relDetail[j].sPColCode+
                            ' = ' + pRel^.relDetail[j].sCColCode +')';
        end;

        sTmpSql := sJoinSql + sTmpSql;
        sTables.Add(sTable);

        if bFillFromPanel then
        begin
          formItem := lvTabJoin.Items.Insert(iInd);
          if (m_Config.nTableNameType = 1) then
            formItem.Caption := pRel^.sPTBCode+' '+sHeadTab
          else
            formItem.Caption := pRel^.sPTBCode;

          formItem.SubItems.Add(conSJoinTypeDesc[pRel^.nJoinType]);
          if (m_Config.nTableNameType = 1) then
            formItem.SubItems.Add(pRel^.sCTBCode+' '+sTable)
          else
            formItem.SubItems.Add(pRel^.sCTBCode);

          formItem.Data := pItem;
          Inc(iCount);
        end;
        pItem := pItem^.pParent;
      end;

      if iPos=2 then // Insert Head table
      begin
        pTable:= PTableRec(pItem^.data);
        if (m_Config.nTableNameType = 1) then
          sJoinSql := pTable^.sTBCode+' '+pItem^.sTabName
        else
          sJoinSql := pTable^.sTBCode;
          
        sTmpSql := sJoinSql + sTmpSql;
        sTables.Add(pItem^.sTabName);
        if bFillFromPanel then
        begin
          formItem := lvTabJoin.Items.Insert(iInd);
          formItem.Caption := '';
          formItem.SubItems.Add('');
          formItem.SubItems.Add(sJoinSql);
          formItem.Data := pItem;
          Inc(iCount);
        end;
      end; //end of iPos=2
      sSqlSen := sSqlSen + sTmpSql;
    end; // end of iPos=1
  end;  // end of for
  if bFillFromPanel then // show the sql 
    edFromSQL.Text := sSqlSen;

  result := sStarts.Count = 1;
  sStarts.Free;
  sTables.Free;
  tableList.Free;
end;

procedure TfrQueryWizard.makeGroupPanel(const bFileGroupPanel:boolean=true);
var
  i,iCount:integer;
  gpItem:TListItem;
  bHaveStat,bHaveNormal,bNeedGroup:boolean;
begin
  iCount := lvSelectingField.Items.Count;
  bHaveStat:=false; bHaveNormal := false;
  
  if bFileGroupPanel then
    lvSelectFieldNoStat.Items.Clear;
  for i:=0 to iCount-1 do
  begin
    if bFileGroupPanel then
    begin
      gpItem := lvSelectFieldNoStat.Items.Add;
      gpItem.Caption :='';
      gpItem.SubItems.Add(lvSelectingField.Items[i].SubItems[2]);
      gpItem.SubItems.Add(lvSelectingField.Items[i].SubItems[0]);
      gpItem.Checked := not PSelectItemData(lvSelectingField.Items[i].Data)^.bStat;
    end;
    if PSelectItemData(lvSelectingField.Items[i].Data)^.bStat then
      bHaveStat := true
    else
      bHaveNormal := true;
  end;

  if bFileGroupPanel and ( (not bHaveNormal) or (not bHaveStat)) then
    for i:=0 to iCount-1 do
      lvSelectFieldNoStat.Items[i].Checked := false;

  bNeedGroup := bHaveNormal and bHaveStat;

  if m_Config.bAutoShowGroup then
  begin
    tabGroup.TabVisible := bNeedGroup;
    if bNeedGroup then
      m_Config.showPanelSet := m_Config.showPanelSet+[pGroup]
    else
      m_Config.showPanelSet := m_Config.showPanelSet-[pGroup];
  end;

  if m_Config.bAutoShowHaving then
  begin
    tabHaving.TabVisible := bNeedGroup;
    if bNeedGroup then
      m_Config.showPanelSet := m_Config.showPanelSet+[pHaving]
    else
      m_Config.showPanelSet := m_Config.showPanelSet-[pHaving];
  end;
end;

function TfrQueryWizard.configHavingField:boolean;
var
  i,iCount:integer;
  hvItem:TlistItem;
begin
  lvHavingField.Items.Clear;
  iCount := lvSelectingField.Items.Count;
  for i:=0 to iCount-1 do
  begin
    hvItem := lvHavingField.Items.Add;
    hvItem.Caption :=lvSelectingField.Items[i].SubItems[2];
//    hvItem.SubItems.Add(lvSelectingField.Items[i].SubItems[1]);
    hvItem.SubItems.Add(lvSelectingField.Items[i].SubItems[0]);
    hvItem.Data := lvSelectingField.Items[i].Data;//PSelectItemData^.datatype;
  end;
  result := true;
end;

function TfrQueryWizard.configOrderField:boolean;
var
  i,iCount:integer;
  odItem:TlistItem;
begin
  lvSelectedField.Items.Clear;
  iCount := lvSelectingField.Items.Count;
  for i:=0 to iCount-1 do
  begin
    odItem := lvSelectedField.Items.Add;
    odItem.Caption :=lvSelectingField.Items[i].SubItems[1];
    odItem.SubItems.Add(lvSelectingField.Items[i].SubItems[2]);
    odItem.SubItems.Add(lvSelectingField.Items[i].SubItems[0]);
  end;
  result := true;
end;

function  TfrQueryWizard.CheckInputSql:boolean;
var
  bRes:boolean;
  i,iCount:integer;
//  sSqlSen:String;
begin
  Result := false;
  if tabSelect.Visible then
  begin
    iCount := 0;
    for i:=0 to lvSelectingField.Items.Count - 1 do
      if lvSelectingField.Items[i].Checked then
        Inc(iCount);
    if iCount<1 then
    begin
      ShowMessage('请选择要查询/统计的项目！');
      Exit;
    end;
  end;

  bRes := makeTableList;
  if not bRes then
  begin
    ShowMessage('有多个表无法连接！');
    Exit;
  end;

  bRes := checkFormulaInput(1,false);
  if not bRes then
  begin
    ShowMessage('where语句语法出错！');
    Exit;
  end;

  if tabHaving.TabVisible then
  begin
    bRes := checkFormulaInput(2,false);
    if not bRes then
    begin
      ShowMessage('having语句语法出错！');
      Exit;
    end;
  end;
  Result := true;
end;

procedure TfrQueryWizard.btnCheckSqlClick(Sender: TObject);
begin
  if CheckInputSql then
    ShowMessage('语法检测通过！');
end;

procedure TfrQueryWizard.lvTabJoinSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
var
  selItem:TListItem;
  pRel : PRelRec;
  sCaption:string;
begin
  selItem := lvTabJoin.Selected;
  if selItem = nil then Exit;
  sCaption := selItem.Caption;
  if sCaption = ''  then
  begin
    cbTabJoinType.Enabled := false;
    btnChangeJionTyoePF.Enabled := false;
    Exit;
  end;
  cbTabJoinType.Enabled := true;
  btnChangeJionTyoePF.Enabled := true;
  pRel := PRelRec(PTreeItemData(selItem.Data)^.data2);
  cbTabJoinType.ItemIndex := pRel^.nJoinType;
  ledTable1PF.Text := selItem.Caption;
  ledTable2PF.Text := selItem.SubItems[1];
end;

procedure TfrQueryWizard.btnChangeJionTyoePFClick(Sender: TObject);
var
  selItem:TListItem;
  pRel : PRelRec;
begin
  selItem := lvTabJoin.Selected;
  if selItem = nil then Exit;
  pRel := PRelRec(PTreeItemData(selItem.Data)^.data2);
  pRel^.nJoinType := cbTabJoinType.ItemIndex;
  selItem.SubItems[0] := cbTabJoinType.Text;
end;

procedure TfrQueryWizard.pcFromChange(Sender: TObject);
begin
  if pcFrom.ActivePage = tabFromSQL then
    makeQuerySql([pFrom]);
end;

procedure TfrQueryWizard.pcGroupChange(Sender: TObject);
begin
  if pcGroup.ActivePage = tabGroupSQL then
    makeQuerySql([pGroup]);
end;

procedure TfrQueryWizard.lvSelectedFieldSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
  ledOrderField.Text := Item.SubItems[0];
end;

procedure TfrQueryWizard.lvHavingFieldSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
var
  pSelItem:PSelectItemData;
  curSelCol :PColumnRec;
  i:integer;
begin
  //pSelItem^.dataType
  dtpDataValuePH.Visible := false;
  lbDictionaryValuePH.Visible := false;
  cbDictionaryDataValuePH.Visible := false;
  btnSubQueryPH.Visible := false;
  ledDealFieldPrm1PH.Visible := false;
  ledDealFieldPrm2PH.Visible := false;

  ledFieldSqlPH.Text := Item.SubItems[0];
  ledFieldDescPH.Text := Item.Caption;
  //config panel
  pSelItem := PSelectItemData(Item.Data);
  if m_preColTypeHP <> pSelItem^.dataType then
  begin
    m_preColTypeHP := pSelItem^.dataType;
    changeLogicComboBox(cbLogicOptPH,m_preColTypeHP);
  end else
    cbLogicOptPH.ItemIndex := -1;

  curSelCol := PColumnRec(pSelItem^.pTreeItem.data2);
  cbDealFieldPH.Clear;
  for i:=0 to CONOPTMAXIND do
  begin
    if ( (conOptList[i].dataType = m_preColTypeHP) or
         (conOptList[i].dataType = CT_NONE) ) and
       ( not conOptList[i].bStatOpt ) and
       ( conOptList[i].nOptPrmSum >= 0 ) then
    begin
      cbDealFieldPH.AddItem(conOptList[i].sOptName,TObjPointer.Create(@(conOptList[i])));
    end;
  end;
  if curSelCol^.sRefDataCode <> '' then
    loadDictionaryData(cbDictionaryDataValuePH,curSelCol^.sRefDataCode);

  //cbDealFieldPH
end;

procedure TfrQueryWizard.editConditionFormulaPH(Sender: TObject);
var
  nTag:integer;
  sStr:String;
begin
  sStr:='';
  nTag := TComponent(Sender).Tag;
  case nTag of
  1: sStr := '* ';
  2: sStr := '+ ';
  3: sStr := '! ';
  4: sStr := '( ';
  5: sStr := ') ';
  10:
        if lvConditionPH.ItemIndex>=0 then
        begin
          sStr := IntToStr(lvConditionPH.ItemIndex+1);
          sStr := sStr+' ';
        end;
  end;
  edHavingFormula.SetSelTextBuf(PChar(sStr));
end;

procedure TfrQueryWizard.updateSqlAndDescInPH(Sender: TObject);
var
  pOpt : PColOperate;
  sStr:String;
  sColSql:String;
  colType : COLDATATYPE;
  pSelItem:PSelectItemData;
begin
  if lvHavingField.Selected =nil then Exit;
  pSelItem := PSelectItemData(lvHavingField.Selected.Data);
//  curSelCol := PColumnRec(pSelItem^.pTreeItem^.data2);
//TComponent

  if cbDealFieldPH.ItemIndex < 0 then Exit;
  pOpt := PColOperate(TObjPointer(cbDealFieldPH.Items.Objects[cbDealFieldPH.ItemIndex]).pData);

  ledDealFieldPrm1PH.Visible := pOpt^.nOptPrmSum>0;
  ledDealFieldPrm2PH.Visible := pOpt^.nOptPrmSum>1;

  colType := pOpt^.retType;
  if colType = CT_NONE then
    colType := pSelItem^.dataType;
  if m_preColTypeHP <> colType then
  begin
    changeLogicComboBox(cbLogicOptPH,colType);
    m_preColTypeHP := colType;
  end;

  sColSql := lvHavingField.Selected.SubItems[0];

  if pOpt^.nOptPrmSum = 0 then
  begin
    FmtStr(sStr,pOpt^.sOptSqlFmt,[sColSql]);
    ledFieldSqlPH.Text := sStr;
    FmtStr(sStr,pOpt^.sOptDescFmt,[lvHavingField.Selected.Caption]);
    ledFieldDescPH.Text := sStr;
  end;

  if pOpt^.nOptPrmSum = 1 then
  begin
    FmtStr(sStr,pOpt^.sOptSqlFmt,[sColSql,ledDealFieldPrm1PH.Text]);
    ledFieldSqlPH.Text := sStr;
    FmtStr(sStr,pOpt^.sOptDescFmt,[lvHavingField.Selected.Caption,ledDealFieldPrm1PH.Text]);
    ledFieldDescPH.Text := sStr;
  end;

  if pOpt^.nOptPrmSum = 2 then
  begin
    FmtStr(sStr,pOpt^.sOptSqlFmt,[sColSql,ledDealFieldPrm1PH.Text,ledDealFieldPrm2PH.Text]);
    ledFieldSqlPH.Text := sStr;
    FmtStr(sStr,pOpt^.sOptDescFmt,[lvHavingField.Selected.Caption,ledDealFieldPrm1PH.Text,ledDealFieldPrm2PH.Text]);
    ledFieldDescPH.Text := sStr;
  end;
end;

procedure TfrQueryWizard.cbLogicOptPHSelect(Sender: TObject);
var
  pOpt : PColOperate;
  curSelCol :PColumnRec;
  pSelItem : PSelectItemData;
begin
  if lvHavingField.Selected =nil then Exit;
  pSelItem := PSelectItemData(lvHavingField.Selected.Data);
  curSelCol := PColumnRec(pSelItem^.pTreeItem^.data2);

  if cbLogicOptPH.ItemIndex < 0 then Exit;
  pOpt := PColOperate(TObjPointer(cbLogicOptPH.Items.Objects[cbLogicOptPH.ItemIndex]).pData);
  dtpDataValuePH.Visible := false;
  lbDictionaryValuePH.Visible := false;
  cbDictionaryDataValuePH.Visible := false;
  btnSubQueryPH.Visible := false;
  if pOpt^.nOptPrmSum = 2 then
  begin
    btnSubQueryPH.Visible := true;
    Exit;
  end;

  if curSelCol.sRefDataCode<>''then
  begin
    lbDictionaryValuePH.Visible := true;
    cbDictionaryDataValuePH.Visible := true;
    Exit;
  end;

  if pSelItem^.dataType = CT_DATE then
     dtpDataValuePH.Visible := true;
end;

procedure TfrQueryWizard.chageDataValuePH(Sender: TObject);
var
  nTag : Integer;
begin
  //change data value
  nTag := TComponent(Sender).Tag;
  if nTag = 1 then
  begin
    ledValuePH.Text := FormatDatetime('YYYY-MM-DD',dtpDataValuePH.DateTime);
  end;
  if nTag = 2 then
  begin
    if cbDictionaryDataValuePH.ItemIndex>=0 then
      ledValuePH.Text :=TObjString(
        cbDictionaryDataValuePH.Items.Objects[cbDictionaryDataValuePH.ItemIndex]
        ).str;
  end;
end;

procedure TfrQueryWizard.btnAddConditionPHClick(Sender: TObject);
var
  liSelect : TListItem;
  sSql,sValue,sDesc,sLogic,sLogicDesc:String;
  nOpt,nCount,nTemp: Integer;
  pOpt : PColOperate;
begin
  nOpt := cbLogicOptPH.ItemIndex;
  if nOpt<0 then Exit;
  sSql := trim(ledFieldSqlPH.Text);
  if sSql = '' then
  begin
    ShowMessage('请输入字段语句！');
    Exit;
  end;
  pOpt := PColOperate(TObjPointer(cbLogicOptPH.Items.Objects[nOpt]).pData);

  sValue := trim(ledValuePH.Text);
  nTemp := IsParameter(sValue);
  if nTemp > -1 then
  begin
    sDesc := lvParams.Items[nTemp].Caption;
  end else
  begin
    sDesc := sValue;
    if not TrimInputConditionValue(pOpt^.nOptPrmSum,m_preColTypeHP,sValue) then Exit;
  end;

  if pOpt^.nOptPrmSum=0 then
  begin
    FmtStr(sLogic,pOpt^.sOptSqlFmt,[sSql]);
    FmtStr(sLogicDesc,pOpt^.sOptDescFmt,[ledFieldDescPH.Text]);
  end else
  begin
    FmtStr(sLogic,pOpt^.sOptSqlFmt,[sSql,sValue]);
    FmtStr(sLogicDesc,pOpt^.sOptDescFmt,[ledFieldDescPH.Text,sDesc]);
  end;

  nCount := lvConditionPH.Items.Count+1;
  liSelect := lvConditionPH.Items.Add;
  liSelect.Caption := IntToStr(nCount);
  liSelect.SubItems.Add(sSql);
  liSelect.SubItems.Add(pOpt^.sOptName);
  liSelect.SubItems.Add(sValue);
  liSelect.SubItems.Add(sLogic);
  liSelect.SubItems.Add(sLogicDesc);
  //liSelect.Data := m_preSelColWP;
  lvConditionPH.ItemIndex := nCount-1;

  sSql := edHavingFormula.Text;
  if sSql='' then
    edHavingFormula.Text := IntToStr(nCount)
  else
    edHavingFormula.Text := sSql +' * ' + IntToStr(nCount);

end;

procedure TfrQueryWizard.btnUpdateConditionPHClick(Sender: TObject);
var
  liSelect : TListItem;
  sSql,sValue,sDesc,sLogic,sLogicDesc:String;
  nOpt,nTemp: Integer;
  pOpt : PColOperate;
begin
  liSelect := lvConditionPH.Selected;
  if liSelect=nil then Exit;

  nOpt := cbLogicOptPH.ItemIndex;
  if nOpt<0 then Exit;
  sSql := trim(ledFieldSqlPH.Text);

  if sSql = '' then
  begin
    ShowMessage('请输入字段语句！');
    Exit;
  end;
  pOpt := PColOperate(TObjPointer(cbLogicOptPH.Items.Objects[nOpt]).pData);
  sValue := trim(ledValuePH.Text);

  nTemp := IsParameter(sValue);
  if nTemp > -1 then
  begin
    sDesc := lvParams.Items[nTemp].Caption;
  end else
  begin
    sDesc := sValue;
    if not TrimInputConditionValue(pOpt^.nOptPrmSum,m_preColTypeHP,sValue) then Exit;
  end;

  if pOpt^.nOptPrmSum=0 then
  begin
    FmtStr(sLogic,pOpt^.sOptSqlFmt,[sSql]);
    FmtStr(sLogicDesc,pOpt^.sOptDescFmt,[ledFieldDescPH.Text]);
  end else
  begin
    FmtStr(sLogic,pOpt^.sOptSqlFmt,[sSql,sValue]);
    FmtStr(sLogicDesc,pOpt^.sOptDescFmt,[ledFieldDescPH.Text,sDesc]);
  end;
  
  liSelect.SubItems[0] := sSql;
  liSelect.SubItems[1] := pOpt^.sOptName;
  liSelect.SubItems[2] := sValue;
  liSelect.SubItems[3] := sLogic;
  liSelect.SubItems[4] := sLogicDesc;
//  liSelect.Data := m_preSelColWP;
end;

procedure TfrQueryWizard.btnDeleteConditionPHClick(Sender: TObject);
var
  liSelect : TListItem;
  i,iSel,iCount:Integer;
  sFormula:String;
begin
  liSelect := lvConditionPH.Selected;
  if liSelect=nil then Exit;
  iSel := lvConditionPH.ItemIndex;
  iCount := lvConditionPH.Items.Count;
  for i:=iSel to iCount-1 do
    lvConditionPH.Items[i].Caption := IntToStr(i);
  lvConditionPH.DeleteSelected;

  sFormula := edHavingFormula.Text;
  sFormula := trimFormulaInput(sFormula, iSel+1);

  edHavingFormula.Text := sFormula;
end;

procedure TfrQueryWizard.pcHavingChange(Sender: TObject);
begin
  if pcHaving.ActivePage = tabHavingSQL then
  begin
    checkFormulaInput(2,true);
  end;
end;

procedure TfrQueryWizard.btnAddOrderPOClick(Sender: TObject);
var
  i,iCount:integer;
  sStr:String;
  selItem,odItem:TListItem;
begin
  if lvSelectedField.Selected = nil then Exit;
  selItem := lvSelectedField.Selected;
  sStr := selItem.Caption;
  iCount := lvOrderField.Items.Count;
  for i:=0 to iCount-1 do
    if sStr = lvOrderField.Items[i].Caption then
    begin
      if cbOrderType.ItemIndex = 1 then
      begin
        lvOrderField.Items[i].SubItems[0] := selItem.SubItems[0];
        lvOrderField.Items[i].SubItems[1] := selItem.SubItems[1] + ' DESC';
        lvOrderField.Items[i].SubItems[2] := '降序排列';
      end else
      begin
        lvOrderField.Items[i].SubItems[0] := selItem.SubItems[0];
        lvOrderField.Items[i].SubItems[1] := selItem.SubItems[1] + ' ASC';
        lvOrderField.Items[i].SubItems[2] := '升序排列';
      end;
      Exit;
    end;
  odItem := lvOrderField.Items.Add;
  odItem.Caption := sStr;
  if cbOrderType.ItemIndex = 1 then
  begin
    odItem.SubItems.Add(selItem.SubItems[0]);
    odItem.SubItems.Add(selItem.SubItems[1] + ' DESC');
    odItem.SubItems.Add('降序排列');
  end else
  begin
    odItem.SubItems.Add(selItem.SubItems[0]);
    odItem.SubItems.Add(selItem.SubItems[1] + ' ASC');
    odItem.SubItems.Add('升序排列');
  end;
end;

procedure TfrQueryWizard.btnDeleteOrderPOClick(Sender: TObject);
begin
  if lvOrderField.Selected = nil then Exit;
  lvOrderField.DeleteSelected;
end;

procedure TfrQueryWizard.btnUpdateOrderPOClick(Sender: TObject);
var
  i,iPos,iCount:integer;
  sStr:String;
  selItem,odItem:TListItem;
begin
  if lvSelectedField.Selected = nil then Exit;
  selItem := lvSelectedField.Selected;
  if lvOrderField.Selected = nil then Exit;
  odItem := lvOrderField.Selected;
  iPos := lvOrderField.ItemIndex;
  sStr := selItem.Caption;
  iCount := lvOrderField.Items.Count;

  for i:=0 to iCount-1 do
    if (i<>iPos) and (sStr=lvOrderField.Items[i].Caption) then
    begin
      lvOrderField.ItemIndex := i;
      ShowMessage('已存在对该字段的排序，无法更改！');
      Exit;
    end;

  odItem.Caption := selItem.Caption;
  odItem.SubItems[0] := selItem.SubItems[0];
  if cbOrderType.ItemIndex = 1 then
  begin
    odItem.SubItems[1] := selItem.SubItems[1] + ' DESC';
    odItem.SubItems[2] := '降序排列';
  end else
  begin
    odItem.SubItems[1] := selItem.SubItems[1] + ' ASC';
    odItem.SubItems[2] := '升序排列';
  end;
end;

procedure TfrQueryWizard.btnMoveOrderUpPOClick(Sender: TObject);
var
  sTemp:String;
  liSel , liUpSel : TListItem;
begin
  // move up
  if lvOrderField.Selected = nil then Exit;
  liSel := lvOrderField.Selected ;
  if liSel.Index < 1 then Exit;
  liUpSel := lvOrderField.Items[liSel.Index-1];

  sTemp:=liUpSel.Caption; liUpSel.Caption:=liSel.Caption; liSel.Caption:= sTemp;
  sTemp:=liUpSel.SubItems[0]; liUpSel.SubItems[0]:=liSel.SubItems[0]; liSel.SubItems[0]:= sTemp;
  sTemp:=liUpSel.SubItems[1]; liUpSel.SubItems[1]:=liSel.SubItems[1]; liSel.SubItems[1]:= sTemp;
  sTemp:=liUpSel.SubItems[2]; liUpSel.SubItems[2]:=liSel.SubItems[2]; liSel.SubItems[2]:= sTemp;

  lvOrderField.ItemIndex := liSel.Index-1;
end;

procedure TfrQueryWizard.btnMoveOrderDownPOClick(Sender: TObject);
var
  iCount : Integer;
  sTemp:String;
  liSel , liDownSel : TListItem;
begin
  // move up
  if lvOrderField.Selected = nil then Exit;
  liSel := lvOrderField.Selected ;
  iCount := lvOrderField.Items.Count;

  if liSel.Index >= iCount-1 then Exit;
  liDownSel := lvOrderField.Items[liSel.Index+1];

  sTemp:=liDownSel.Caption; liDownSel.Caption:=liSel.Caption; liSel.Caption:= sTemp;
  sTemp:=liDownSel.SubItems[0]; liDownSel.SubItems[0]:=liSel.SubItems[0]; liSel.SubItems[0]:= sTemp;
  sTemp:=liDownSel.SubItems[1]; liDownSel.SubItems[1]:=liSel.SubItems[1]; liSel.SubItems[1]:= sTemp;
  sTemp:=liDownSel.SubItems[2]; liDownSel.SubItems[2]:=liSel.SubItems[2]; liSel.SubItems[2]:= sTemp;

  lvOrderField.ItemIndex := liSel.Index+1;
end;

procedure TfrQueryWizard.pcOrderChange(Sender: TObject);
begin
  if pcOrder.ActivePage = tabOrderSql then
    makeQuerySql([pOrder]);
end;

procedure TfrQueryWizard.trRelationChange(Sender: TObject);

begin
  if m_preRelationPage = tabSelect then
  begin
    if tabFrom.TabVisible then
      makeTableList;
    if tabGroup.TabVisible then
      makeGroupPanel;
    if tabHaving.TabVisible then
      configHavingField;
    if tabOrder.TabVisible then
      configOrderField;
  end;

  if m_preRelationPage = tabWhere then
    makeTableList;

  if m_preRelationPage = tabParam then
  begin
    makeParamList;
    if tabWhere.TabVisible then
      btnCiteParamWP.Enabled := m_Result.nPrmSum>0;
    if tabHaving.TabVisible then
      btnCiteParamHP.Enabled := m_Result.nPrmSum>0;
  end;
  m_preRelationPage := trRelation.ActivePage;
  
end;

procedure TfrQueryWizard.btnOKClick(Sender: TObject);
var
  i,iCount:integer;
begin
  if not CheckInputSql then
    Exit;
  if m_Config.bCanNamed then
  begin
    m_Result.sSqlName := trim(ledSQLName.Text);
    if m_Result.sSqlName = '' then
    begin
      ShowMessage('请输入SQL语句的名称');
      ledSQLName.SetFocus;
      Exit;
    end;
  end;

  if pcDesign.ActivePage <> tabSQL then
    trimQuerySql;

  m_Result.sqlType := SQL_QUERY;
  m_Result.sSQL := edSql.Text;
  m_Result.nFieldSum := 0;
  m_Result.sFieldDesc := '';
  if tabSelect.TabVisible then
  begin
    iCount := lvSelectingField.Items.Count;
    for i:=0 to iCount -1 do
      if lvSelectingField.Items[i].Checked then
      begin
        m_Result.nFieldSum := m_Result.nFieldSum  + 1;
        if m_Result.sFieldDesc = '' then
          m_Result.sFieldDesc := lvSelectingField.Items[i].SubItems[2]
        else
          m_Result.sFieldDesc := m_Result.sFieldDesc + ',' + lvSelectingField.Items[i].SubItems[2];
      end;
  end;
  //self.Close;
  self.ModalResult := MROK;
end;

procedure TfrQueryWizard.FormHide(Sender: TObject);
begin
  lvHavingField.Items.Clear;
  lvSelectedField.Items.Clear;
  lvOrderField.Items.Clear;
  lvConditionPW.Items.Clear;
  lvSelectFieldNoStat.Items.Clear;
  lvTabJoin.Items.Clear;
  lvConditionPH.Items.Clear;
  lvSelectingField.Items.Clear;
  lvParams.Items.Clear;
  
  edWhereFormula.Text := '';
  edHavingFormula.Text := '';
end;

procedure TfrQueryWizard.lvSelectingFieldKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if key=VK_DELETE then
     btnDeleteFieldPSClick(Sender);
end;

procedure TfrQueryWizard.lvConditionPWKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if key=VK_DELETE then
     btnDeleteConditionPWClick(Sender);
end;

procedure TfrQueryWizard.lvConditionPHKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if key=VK_DELETE then
     btnUpdateConditionPHClick(Sender);
end;

procedure TfrQueryWizard.lvOrderFieldKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if key=VK_DELETE then
     btnDeleteOrderPOClick(Sender);
end;

procedure TfrQueryWizard.cbDBTypeChange(Sender: TObject);
var
  nSel : Integer;
begin
  nSel := cbDBType.ItemIndex;
  //  DATABASETYPE = (SQLServer, MSAccess, DB2, Oracle);
  case nSel of
    0:  begin
          m_Config.dbConfig.DBType := SQLServer;
          TCommonFunc.SetRegKeyValue('\Software\Centit\SqlWizard','database','SQLServer');
        end;
    1:  begin
          m_Config.dbConfig.DBType := MSAccess;
          TCommonFunc.SetRegKeyValue('\Software\Centit\SqlWizard','database','MSAccess');
        end;
    2:  begin
          m_Config.dbConfig.DBType := DB2;
          TCommonFunc.SetRegKeyValue('\Software\Centit\SqlWizard','database','DB2');
        end;
    3:  begin
          m_Config.dbConfig.DBType := Oracle;
          TCommonFunc.SetRegKeyValue('\Software\Centit\SqlWizard','database','Oracle');
        end;
  end;
end;

procedure TfrQueryWizard.makeParamList;
var
  i:integer;
begin
  m_Result.nPrmSum := lvParams.Items.Count;
  if m_Result.nPrmSum>0 then
    m_Result.sPrmDesc := lvParams.Items[0].Caption;
  for i:=1 to m_Result.nPrmSum-1 do
    m_Result.sPrmDesc := m_Result.sPrmDesc + ',' + lvParams.Items[i].Caption;
end;

procedure TfrQueryWizard.btnAddParamClick(Sender: TObject);
var
  sParam:String;
  i,nC : Integer;
  newItem : TListItem;
begin
  // AddParam
  sParam := trim(ledNewParamDesc.Text);
  if sParam = '' then
    Exit;
  sParam := StringReplace(sParam,',','，',[rfReplaceAll]);
  nC := lvParams.Items.Count;
  for i:=0 to nC-1 do
    if  lvParams.Items[i].Caption = sParam then Exit;
  newItem := lvParams.Items.Add;
  newItem.Caption := sParam;
  newItem.SubItems.add(ledNewParamDefValue.Text);
end;

procedure TfrQueryWizard.btnUpdateParamClick(Sender: TObject);
var
  selItem : TListItem;
  sParam:String;
  i,nC : Integer;
begin
  // UpdateParam
  selItem := lvParams.Selected;
  if selItem = nil then Exit;
  sParam := trim(ledNewParamDesc.Text);
  if sParam = '' then
    Exit;
  sParam := StringReplace(sParam,',','，',[rfReplaceAll]);
  nC := lvParams.Items.Count;
  for i:=0 to nC-1 do
    if  lvParams.Items[i].Caption = sParam then Exit;

  selItem.Caption := sParam;
  selItem.SubItems[0] := ledNewParamDefValue.Text;
end;

procedure TfrQueryWizard.btnDeleteParamClick(Sender: TObject);
var
  nSel,nC:integer;
begin
  // DeleteParam
  nSel := lvParams.ItemIndex;
  if nSel = -1 then Exit;
  nC := lvParams.Items.Count;
  lvParams.DeleteSelected;
  if nSel = nC-1 then Dec(nSel);
  if nSel<0 then Exit; 
  lvParams.ItemIndex := nSel;
end;

procedure TfrQueryWizard.lvParamsSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
var
  selItem : TListItem;
begin
  // UpdateParam
  selItem := lvParams.Selected;
  if selItem = nil then Exit;
  ledNewParamDesc.Text := selItem.Caption;
end;

procedure TfrQueryWizard.btnCiteParamWPClick(Sender: TObject);
var
  mi: TMenuItem;
  CurPoint: TPoint;
  i: integer;
begin
  if lvParams.Items.Count = 0 then exit;

  pmParam.Items.Clear;
  for i := 0 to lvParams.Items.Count - 1 do
  begin
    mi := TMenuItem.Create(pmParam);
    //mi.Tag := i;
    mi.Caption := lvParams.Items[i].Caption;
    pmParam.Items.Add(mi);
    mi.OnClick := AddParam;
  end;

  //弹出
  if pmParam.Items.Count > 0 then
  begin
    GetCursorPos(CurPoint);
    pmParam.Popup(CurPoint.X, CurPoint.Y);
  end;
end;

//增加参数
procedure TfrQueryWizard.AddParam(Sender: TObject);
begin
  ledValuePW.Text := SPARAM_PREFIX + IntToStr(TMenuItem(Sender).MenuIndex);
end;

procedure TfrQueryWizard.cbCurrentDateClick(Sender: TObject);
begin
  dtpDataValue.Enabled := not cbCurrentDate.Checked;

  case m_Config.dbConfig.DBType  of
    MSAccess :
      ledValuePW.Text := 'now';
    Oracle :
      ledValuePW.Text := 'sysdate';
    SQLServer:
      ledValuePW.Text := 'getdate()';
    DB2 :
      ledValuePW.Text := 'current date';
  end;
end;

procedure TfrQueryWizard.edRetFirstRowsChange(Sender: TObject);
begin
  if length(trim(edRetFirstRows.Text)) = 0 then
    Exit;
  m_Config.nQueryAsModeRows := StrToInt(edRetFirstRows.Text);
end;

procedure TfrQueryWizard.btnSetDBConnClick(Sender: TObject);
var
  sAdoConn,sTmpCOnn:String;
begin
  sTmpCOnn := svrInfo.sDBConn;
  sAdoConn := PromptDataSource(Handle, sTmpCOnn);
  if sAdoConn <> '' then
  begin
     ledDBConn.Text := sAdoConn;
     svrInfo.sDBConn := sAdoConn;
     TCommonFunc.SetRegKeyValue('\Software\Centit\SqlWizard','conn',sAdoConn);
  end
end;

procedure TfrQueryWizard.btnCancelClick(Sender: TObject);
begin
  Close();
end;

end.
