// AdoQuery.h: interface for the CAdoQuery class.
//
//////////////////////////////////////////////////////////////////////

//	Compiler:	Visual C++
//	Tested on:	Visual C++ 6.0
//	Version:	1.0
//	Created:	09/September/2001
//	Author:		 yanghuaisheng (codefan@sou.com)
// Copyright yanghuaisheng, 2001-2003 (codefan@sou.com)
// Feel free to use and distribute. May not be sold for profit. 

#if !defined(AFX_ADOQUERY_H__93D3CB09_FA9D_4A30_9F97_A400A70F42D4__INCLUDED_)
#define AFX_ADOQUERY_H__93D3CB09_FA9D_4A30_9F97_A400A70F42D4__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

/*
add the following code in the stdafx.h and call the function 
::CoInitialize(NULL); before using it.
#import "G:\Program Files\Common Files\System\ADO\msado15.dll" \
no_namespace rename("EOF", "EndOfFile")
if define DBADO 

#import "G:\Program Files\Common Files\System\ADO\msado15.dll" \
no_namespace rename("EOF", "EndOfFile")
if define DBADO 
#define _IMPORT_MSADO15_
#define _NAMESPACE_MSADO15_
#import "J:\Program Files\Common Files\System\ADO\msado15.dll" \
rename_namespace("MSADO15") rename("EOF", "EndOfFile")

*/
#if ! defined _IMPORT_MSADO15_ 
#define _IMPORT_MSADO15_
#import "C:\Program Files\Common Files\System\ADO\msado15.dll" \
no_namespace rename("EOF", "EndOfFile")
#endif


#if defined _NAMESPACE_MSADO15_
using namespace MSADO15; 
#endif

#include <afxtempl.h>

#if defined _NAMESPACE_MSADO15_
struct SQueryParam{
	bstr_t	name;			// the name of the parameter
	MSADO15::DataTypeEnum	type;	// the data type of the parameter
	MSADO15::ParameterDirectionEnum	direction; // in | out | inout | return
	long	size;			// 
	_variant_t value;		// the value of the parameter
};
#else
struct SQueryParam{
	bstr_t	name;			// the name of the parameter
	DataTypeEnum	type;	// the data type of the parameter
	ParameterDirectionEnum	direction; // in | out | inout | return
	long	size;			// 
	_variant_t value;		// the value of the parameter
};
#endif

// parameter list
class CQueryParamList : public CList<SQueryParam,SQueryParam&>
{
public:
	CQueryParamList();
	~CQueryParamList();
public:

#if defined _NAMESPACE_MSADO15_
	static MSADO15::DataTypeEnum GetDataType(LPCTSTR szType);
	static MSADO15::ParameterDirectionEnum GetDataDirectionType(LPCTSTR szType);
#else
	static DataTypeEnum GetDataType(LPCTSTR szType);
	static ParameterDirectionEnum GetDataDirectionType(LPCTSTR szType);

#endif

public:
	void AddParameter(LPCTSTR name, LPCTSTR type, LPCTSTR direction, UINT value);
	void AddParameter(LPCTSTR name, LPCTSTR type, LPCTSTR direction, LPCTSTR value);
	void AddParameter(LPCTSTR name, LPCTSTR type, LPCTSTR direction, _variant_t value);
	SQueryParam GetItem(LPCTSTR name);
	SQueryParam GetItem(long lno);
};

class CAdoQuery  
{
public:
	CAdoQuery();
	CAdoQuery(LPCTSTR szConn,LPCTSTR szUsername,LPCTSTR szPassword);
	virtual ~CAdoQuery();
public:
	bstr_t conn;
	bstr_t username;
	bstr_t password;
	/// set the database parameter 
	/// szConn  : the connect string used by oledb
	/// szUsername : the database user name  szPassword : user password 
	void SetDBParameter(LPCTSTR szConn,LPCTSTR szUsername,LPCTSTR szPassword);
public:
	bool m_bIsConnect;
	_ConnectionPtr pCnn;
	_RecordsetPtr pRecord;
	_CommandPtr   pCommand;
	_variant_t FieldValue(long n);  // get the recordset field value
	CString FieldString(long n);	// get the recordset field string
	CString FieldAsString(long n);

	_variant_t FieldValue(LPCTSTR s);  // get the recordset field value
	long FieldSize(long n);
	long FieldSize(LPCTSTR s);
	CString FieldString(LPCTSTR s);	// get the recordset field string
	CString FieldAsString(LPCTSTR s);
	inline BOOL NotEnd(){ return ! pRecord->EndOfFile; } // check the end of the recordset
	//inline UINT RecordCount(){ return pRecord->RecordCount;}
	inline void StepIt(){pRecord->MoveNext();} // nove Next
	inline void MoveNext(){pRecord->MoveNext();} // nove Next
	inline void BeginTrans(){pCnn->BeginTrans();}
	inline void CommitTrans(){pCnn->CommitTrans();}
	inline void RollbackTrans(){pCnn->RollbackTrans();}
public:
	void Initialize();
public:
	BOOL ConnectDatabase(); 
	BOOL DisconnectDatabase();
	// Query Databse and after done this you could call thr function to retrieve 
	// the data from the recordset.
	// and you must call EndQuery when you need not using the recodset any more.
	BOOL QueryDatabase(LPCTSTR szSqlSen); 
	BOOL EndQuery();
	// Run Sql such as Insert Delete
	BOOL ExecuteSql(LPCTSTR szSqlSen);
	// Run Sql With Parameter
	void SetSqlSen(LPCTSTR szSqlSen);
	void AppendParam(SQueryParam & prm);
	void AppendParam(LPCTSTR name, LPCTSTR type, LPCTSTR direction, _variant_t value);
	void CreateParam( CQueryParamList & prmList);
	inline void SetParamValue(long ind, _variant_t value){ pCommand->GetParameters()->GetItem(ind)->Value = value; }
	
	void EndExecute();
	BOOL Execute();
	// 
	BOOL ExecuteTrans(CStringList & szSqlList);
	//
	BOOL QueryDatabaseWithParam(LPCTSTR szSqlSen, CQueryParamList & prmList);
	//
	BOOL ExecuteProcedure(LPCTSTR szSqlSen,  CQueryParamList & prmList);
};

#endif // !defined(AFX_ADOQUERY_H__93D3CB09_FA9D_4A30_9F97_A400A70F42D4__INCLUDED_)

