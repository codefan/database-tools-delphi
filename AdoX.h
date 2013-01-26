//
//  MODULE:   AdoX.h
//
//	AUTHOR: Carlos Antollini 
//
//  mailto: cantollini@hotmail.com
//
//	Date: 06/14/2002
//
//	Version 1.02
// 
#ifndef _ADOX_H_
#define _ADOX_H_


#include <afxdisp.h>

#pragma warning (disable: 4146)
#import "c:\Program Files\Common Files\system\ado\msadox.dll" no_namespace 
#import "c:\Program Files\Common Files\system\ado\msado15.dll" rename("EOF", "EndOfFile")

#include "icrsint.h"

class CADOXIndex;
class CADOXCatalog;

class CADOXUser
{
public:
	CADOXUser(CADOXCatalog* pCat);
	~CADOXUser();
	void GetName(CString& strName);
	bool Create(LPCTSTR lpstrUserName);
	bool Open(LPCTSTR lpstrUserName);
	bool ChangePassword(LPCTSTR lpstrOldPassword, LPCTSTR lpstrNewPassword);

public:
	_UserPtr m_pUser;

protected:
	_CatalogPtr m_pCatalog;

protected:
	void dump_com_error(_com_error &e);

};

class CADOXView
{
public:
	CADOXView(CADOXCatalog* pCat);
	~CADOXView();
	void GetCommand(CString& strCommand);
	void GetName(CString& strName);
	bool Open(LPCTSTR lpstrViewName);
	bool Create(CString strName, CString strCommand);
	
public:
	ViewPtr m_pView;

protected:
	_CatalogPtr m_pCatalog;

protected:
	void dump_com_error(_com_error &e);
};

class CADOXProcedure
{
public:
	CADOXProcedure(CADOXCatalog* pCat);
	~CADOXProcedure();
	void GetName(CString& strName);
	bool Open(LPCTSTR lpstrProcedureName);
	bool Create(CString strName, CString strCommand);
	void GetCommand(CString &strCommand);

public:
	ProcedurePtr m_pProcedure;

protected:
	_CatalogPtr m_pCatalog;

protected:
	void dump_com_error(_com_error &e);

};

class CADOXTable
{

public:
	enum DataType
	{
		typeSmallInt = adSmallInt,
		typeInteger = adInteger,
		typeUnsignedTinyInt = adUnsignedTinyInt,
		typeUnsignedSmallInt = adUnsignedSmallInt,
		typeUnsignedInt = adUnsignedInt,
		typeUnsignedBigInt = adUnsignedBigInt,
		typeSingle = adSingle,
		typeDouble = adDouble,
		typeCurrency = adCurrency,
		typeDecimal = adDecimal,
		typeNumeric = adNumeric,
		typeBoolean = adBoolean,
		typeDate = adDate,
		typeDBDate = adDBDate,
		typeDBTime = adDBTime,
		typeDBTimeStamp = adDBTimeStamp,
		typeBSTR = adBSTR,
		typeVarChar = adVarChar,
		typeLongVarChar = adLongVarChar,
		typeWChar = adWChar,
		typeVarWChar = adVarWChar,
		typeLongVarWChar = adLongVarWChar,
		typeBinary = adBinary,
		typeVarBinary = adVarBinary,
		typeLongVarBinary = adLongVarBinary,
		typeChapter = adChapter,
		typeFileTime = adFileTime,
		typePropVariant = adPropVariant,
		typeVarNumeric = adVarNumeric
	};
	
	_TablePtr m_pTable;

	//CADOXTable(CADOXCatalog* pCat);
	CADOXTable(CADOXCatalog* pCat, LPCTSTR lpstrTableName = _T(""));
	CADOXTable(CADOXCatalog* pCat, int nTableIndex);
	~CADOXTable();

	bool Create(LPCTSTR lpstrTableName);
	bool Open(LPCTSTR lpstrTableName);
	bool Open(long nTableIndex);
	bool AddField(LPCTSTR lpstrFieldName, enum DataType Type, int nLength = 0);
	bool AddIndex(CADOXIndex pIndex);
	bool DeleteField(LPCTSTR lpstrFieldName);
	void GetName(CString& strTableName);

protected:
	_CatalogPtr m_pCatalog;

protected:
	void dump_com_error(_com_error &e);

};


class CADOXIndex
{
public:
	enum DataType
	{
		typeSmallInt = adSmallInt,
		typeInteger = adInteger,
		typeUnsignedTinyInt = adUnsignedTinyInt,
		typeUnsignedSmallInt = adUnsignedSmallInt,
		typeUnsignedInt = adUnsignedInt,
		typeUnsignedBigInt = adUnsignedBigInt,
		typeSingle = adSingle,
		typeDouble = adDouble,
		typeCurrency = adCurrency,
		typeDecimal = adDecimal,
		typeNumeric = adNumeric,
		typeBoolean = adBoolean,
		typeDate = adDate,
		typeDBDate = adDBDate,
		typeDBTime = adDBTime,
		typeDBTimeStamp = adDBTimeStamp,
		typeBSTR = adBSTR,
		typeVarChar = adVarChar,
		typeLongVarChar = adLongVarChar,
		typeWChar = adWChar,
		typeVarWChar = adVarWChar,
		typeLongVarWChar = adLongVarWChar,
		typeBinary = adBinary,
		typeVarBinary = adVarBinary,
		typeLongVarBinary = adLongVarBinary,
		typeChapter = adChapter,
		typeFileTime = adFileTime,
		typePropVariant = adPropVariant,
		typeVarNumeric = adVarNumeric
	};
	
	_IndexPtr m_pIndex;

	CADOXIndex()
	{
		//::CoInitialize(NULL);
		m_pIndex = NULL;
		m_pIndex.CreateInstance(__uuidof(Index));
	}

	~CADOXIndex()
	{
		m_pIndex.Release();
		m_pIndex = NULL;
		//::CoUninitialize();
	}

	bool Create(LPCTSTR lpstrIndexName);
	bool AddField(LPCTSTR lpstrIndexName, enum DataType Type, int nLength = 0);
	void SetPrimarKey(bool bPrimary = true);
protected:
	void dump_com_error(_com_error &e);
};


class CADOXCatalog
{
public:
	bool Open(LPCTSTR lpstrConnection);
	bool CreateDatabase(LPCTSTR lpstrCreate);
	bool AddTable(CADOXTable pTable);
	bool AddUser(CADOXUser pUser, LPCTSTR lpstrPassword);

	long GetProcedureCount()
		{return m_pCatalog->Procedures->GetCount();};
	long GetTableCount()
		{return m_pCatalog->Tables->GetCount();};
	long GetViewCount();
	long GetUserCount()
		{return m_pCatalog->Users->GetCount();};
	long GetGroupCount()
		{return m_pCatalog->Groups->GetCount();};

	void GetTableName(long nTableIndex, CString &strTableName);
	void GetProcedureName(long nProcedureIndex, CString &strProcedureName);
	void GetViewName(long nViewIndex, CString &strViewName);
	void GetUserName(long nUserIndex, CString &strUserName);
	void GetGroupName(long nGroupIndex, CString &strGroupName);
	bool DeleteTable(LPCTSTR lpstrTableName);
	bool DeleteTable(long nTableIndex);
	bool DeleteProcedure(long nProcedureIndex);
	bool DeleteProcedure(LPCTSTR lpstrProcedureName);
	bool DeleteView(LPCTSTR lpstrViewName);
	bool DeleteView(long nViewIndex);
	bool DeleteGroup(LPCTSTR lpstrGroupName);
	bool DeleteGroup(long nGroupIndex);
	bool DeleteUser(LPCTSTR lpstrUserName);
	bool DeleteUser(long nViewIndex);

	CADOXCatalog()
	{
		::CoInitialize(NULL);
		m_pCatalog = NULL;
		m_pCatalog.CreateInstance(__uuidof(Catalog));
	}

	~CADOXCatalog()
	{
		m_pCatalog.Release();
		m_pCatalog = NULL;
		::CoUninitialize();
	}

	_CatalogPtr m_pCatalog;	

protected:
	void dump_com_error(_com_error &e);
	
};

#endif