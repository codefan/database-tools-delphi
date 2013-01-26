//
//  MODULE:   AdoX.cpp
//
//	AUTHOR: Carlos Antollini 
//
//  mailto: cantollini@hotmail.com
//
//	Date: 06/14/2002
//
//	Version 1.02
// 
#include "stdafx.h"

#include "adoX.h"

#include <afxdisp.h>

inline void TESTHR(HRESULT x) {if FAILED(x) _com_issue_error(x);};
ADODB::_ConnectionPtr m_pConn = NULL;
///////////////////////////////////////////////////////
//
//  CADOXProcedure Class
//

CADOXUser::CADOXUser(CADOXCatalog* pCat)
{
	m_pCatalog = pCat->m_pCatalog;
	m_pUser = NULL;
	m_pUser.CreateInstance(__uuidof(User));
}

CADOXUser::~CADOXUser()
{
	m_pUser.Release();
	m_pCatalog = NULL;
	m_pUser = NULL;
}

bool CADOXUser::Open(LPCTSTR lpstrUserName)
{
	ASSERT(m_pCatalog != NULL);

	m_pUser = m_pCatalog->Users->GetItem(lpstrUserName);
	return m_pUser != NULL;
}

void CADOXUser::GetName(CString& strName)
{
	_variant_t vName;

	ASSERT(m_pUser != NULL);

	vName  = m_pUser->GetName();
	strName = vName.bstrVal;
}

bool CADOXUser::ChangePassword(LPCTSTR lpstrOldPassword, LPCTSTR lpstrNewPassword)
{
	ASSERT(m_pUser != NULL);
	
	m_pUser->ChangePassword(_bstr_t(lpstrOldPassword), _bstr_t(lpstrNewPassword));
	return true;

}

bool CADOXUser::Create(LPCTSTR lpstrUserName)
{
	try
	{
		m_pUser->PutName(lpstrUserName);
		return true;
	}
	catch(_com_error &e)
	{
		dump_com_error(e);
		return false;
	}
}

void CADOXUser::dump_com_error(_com_error &e)
{
	CString ErrorStr;
	
	
	_bstr_t bstrSource(e.Source());
	_bstr_t bstrDescription(e.Description());
	ErrorStr.Format( "CADOXUser Error\n\tCode = %08lx\n\tCode meaning = %s\n\tSource = %s\n\tDescription = %s\n",
		e.Error(), e.ErrorMessage(), (LPCSTR)bstrSource, (LPCSTR)bstrDescription );
#ifdef _DEBUG
	AfxMessageBox( ErrorStr, MB_OK | MB_ICONERROR );
#endif	
}


///////////////////////////////////////////////////////
//
//  CADOXView Class
//

CADOXView::CADOXView(CADOXCatalog* pCat)
{
	m_pCatalog = pCat->m_pCatalog;
	m_pView = NULL;
	m_pView.CreateInstance(__uuidof(View));
}

CADOXView::~CADOXView()
{
	m_pView.Release();
	m_pCatalog = NULL;
	m_pView = NULL;
}

bool CADOXView::Open(LPCTSTR lpstrViewName)
{
	ASSERT(m_pCatalog != NULL);

	m_pView = m_pCatalog->Views->GetItem(lpstrViewName);
	return m_pView != NULL;
}

void CADOXView::GetName(CString& strName)
{
	_variant_t vName;

	ASSERT(m_pView != NULL);

	vName  = m_pView->GetName();
	strName = vName.bstrVal;
}

bool CADOXView::Create(CString strName, CString strCommand)
{
	HRESULT hr;
	ADODB::_CommandPtr pCommand = NULL;
	pCommand.CreateInstance(__uuidof(ADODB::Command));
	
	try
	{
		pCommand->put_CommandText(strCommand.AllocSysString());
		hr = m_pCatalog->Views->Append(_bstr_t(strName.GetBuffer(0)), pCommand);
		if(SUCCEEDED(hr))
		{
			m_pCatalog->Views->Refresh();
			m_pView = m_pCatalog->Views->GetItem(strName.GetBuffer(0));
			pCommand.Release();
			return true;
		}
		else
		{
			return false;
		}
	}
	catch(_com_error &e)
	{
		dump_com_error(e);
		return false;
	}
}

void CADOXView::GetCommand(CString &strCommand)
{
	_variant_t vCommand;
	ADODB::_CommandPtr pCommand = NULL;

	ASSERT(m_pView != NULL);

	pCommand.CreateInstance(__uuidof(ADODB::Command));

	pCommand  = m_pView->GetCommand();
	vCommand = pCommand->GetCommandText();
	strCommand = vCommand.bstrVal;
	
}

void CADOXView::dump_com_error(_com_error &e)
{
	CString ErrorStr;
	
	
	_bstr_t bstrSource(e.Source());
	_bstr_t bstrDescription(e.Description());
	ErrorStr.Format( "CADOXView Error\n\tCode = %08lx\n\tCode meaning = %s\n\tSource = %s\n\tDescription = %s\n",
		e.Error(), e.ErrorMessage(), (LPCSTR)bstrSource, (LPCSTR)bstrDescription );
#ifdef _DEBUG
	AfxMessageBox( ErrorStr, MB_OK | MB_ICONERROR );
#endif	
}



///////////////////////////////////////////////////////
//
//  CADOXProcedure Class
//

CADOXProcedure::CADOXProcedure(CADOXCatalog* pCat)
{
	m_pCatalog = pCat->m_pCatalog;
	m_pProcedure = NULL;
	m_pProcedure.CreateInstance(__uuidof(Procedure));
}

CADOXProcedure::~CADOXProcedure()
{
	m_pProcedure.Release();
	m_pCatalog = NULL;
	m_pProcedure = NULL;
}

bool CADOXProcedure::Open(LPCTSTR lpstrProcedureName)
{
	ASSERT(m_pCatalog != NULL);

	m_pProcedure = m_pCatalog->Procedures->GetItem(lpstrProcedureName);
	return m_pProcedure != NULL;
}

void CADOXProcedure::GetName(CString& strName)
{
	_variant_t vName;

	ASSERT(m_pProcedure != NULL);

	vName  = m_pProcedure->GetName();
	strName = vName.bstrVal;
}

bool CADOXProcedure::Create(CString strName, CString strCommand)
{
	HRESULT hr;
	ADODB::_CommandPtr pCommand = NULL;
	pCommand.CreateInstance(__uuidof(ADODB::Command));

	try
	{
		pCommand->put_CommandText(strCommand.AllocSysString());
		hr = m_pCatalog->Procedures->Append(_bstr_t(strName.GetBuffer(0)), pCommand);
		if(SUCCEEDED(hr))
		{
			m_pCatalog->Procedures->Refresh();
			m_pProcedure = m_pCatalog->Procedures->GetItem(strName.GetBuffer(0));
			pCommand.Release();
			return true;
		}
		else
		{
			return false;
		}
	}
	catch(_com_error &e)
	{
		dump_com_error(e);
		return false;
	}
}

void CADOXProcedure::GetCommand(CString &strCommand)
{
	_variant_t vCommand;
	ADODB::_CommandPtr pCommand = NULL;

	ASSERT(m_pProcedure != NULL);

	pCommand.CreateInstance(__uuidof(ADODB::Command));

	pCommand  = m_pProcedure->GetCommand();
	vCommand = pCommand->GetCommandText();
	strCommand = vCommand.bstrVal;
}

void CADOXProcedure::dump_com_error(_com_error &e)
{
	CString ErrorStr;
	
	
	_bstr_t bstrSource(e.Source());
	_bstr_t bstrDescription(e.Description());
	ErrorStr.Format( "CADOXProcedure Error\n\tCode = %08lx\n\tCode meaning = %s\n\tSource = %s\n\tDescription = %s\n",
		e.Error(), e.ErrorMessage(), (LPCSTR)bstrSource, (LPCSTR)bstrDescription );
#ifdef _DEBUG
	AfxMessageBox( ErrorStr, MB_OK | MB_ICONERROR );
#endif	
}
/*
_variant_t GetDateCreated ( );
_variant_t GetDateModified ( );
*/


///////////////////////////////////////////////////////
//
// CADOXIndex Class
//

bool CADOXIndex::Create(LPCTSTR lpstrIndexName)
{
	try
	{
		m_pIndex->PutName(lpstrIndexName);
		return true;
	}
	catch(_com_error &e)
	{
		dump_com_error(e);
		return false;
	}
}

bool CADOXIndex::AddField(LPCTSTR lpstrIndexName, enum DataType Type, int nLength)
{
	try
	{
		m_pIndex->Columns->Append(lpstrIndexName, (enum DataTypeEnum) Type, nLength);
		return true;
	}
	catch(_com_error &e)
	{
		dump_com_error(e);
		return false;
	}
}

void CADOXIndex::SetPrimarKey(bool bPrimary)
{
	m_pIndex->PutPrimaryKey(bPrimary?-1:0);
	m_pIndex->PutUnique(bPrimary?-1:0);
}

void CADOXIndex::dump_com_error(_com_error &e)
{
	CString ErrorStr;
	
	
	_bstr_t bstrSource(e.Source());
	_bstr_t bstrDescription(e.Description());
	ErrorStr.Format( "CADOXIndex Error\n\tCode = %08lx\n\tCode meaning = %s\n\tSource = %s\n\tDescription = %s\n",
		e.Error(), e.ErrorMessage(), (LPCSTR)bstrSource, (LPCSTR)bstrDescription );
#ifdef _DEBUG
	AfxMessageBox( ErrorStr, MB_OK | MB_ICONERROR );
#endif	
}

///////////////////////////////////////////////////////
//
// CADOXTAble Class
//

/*CADOXTable::CADOXTable(CADOXCatalog* pCat)
{
//	::CoInitialize(NULL);
	m_pTable == NULL;
	m_pTable.CreateInstance(__uuidof(Table));
	m_pCatalog = NULL;
	m_pCatalog = pCat->m_pCatalog;
}
*/
CADOXTable::CADOXTable(CADOXCatalog* pCat, LPCTSTR lpstrTableName)
{
	::CoInitialize(NULL);
	m_pTable == NULL;
	m_pTable.CreateInstance(__uuidof(Table));
	m_pCatalog = NULL;
	m_pCatalog = pCat->m_pCatalog;
	if(strlen(lpstrTableName) > 0)
		Open(lpstrTableName);
}

CADOXTable::CADOXTable(CADOXCatalog* pCat, int nTableIndex)
{
	//::CoInitialize(NULL);
	m_pTable == NULL;
	m_pTable.CreateInstance(__uuidof(Table));
	m_pCatalog = NULL;
	m_pCatalog = pCat->m_pCatalog;
	if( nTableIndex > -1)
		Open(nTableIndex);
	//m_pTable->GetColumns()->GetItem(0)->GetName();
}

CADOXTable::~CADOXTable()
{
	m_pTable.Release();
	m_pTable = NULL;
	::CoUninitialize();
}

bool CADOXTable::Open(LPCTSTR lpstrTableName)
{
	ASSERT(m_pCatalog != NULL);

	m_pTable = m_pCatalog->Tables->GetItem(lpstrTableName);
	return m_pTable != NULL;
}
	
bool CADOXTable::Open(long nTableIndex)
{
	ASSERT(m_pCatalog != NULL);

	m_pTable = m_pCatalog->Tables->GetItem(nTableIndex);
	return m_pTable != NULL;
}
		
bool CADOXTable::Create(LPCTSTR lpstrTableName)
{
	try
	{
		m_pTable->PutName(lpstrTableName);
		return true;
	}
	catch(_com_error &e)
	{
		dump_com_error(e);
		return false;
	}
}

bool CADOXTable::AddField(LPCTSTR lpstrFieldName, enum DataType Type, int nLength)
{
	try
	{
		m_pTable->Columns->Append(lpstrFieldName, (enum DataTypeEnum) Type, nLength);
		return true;
	}
	catch(_com_error &e)
	{
		dump_com_error(e);
		return false;
	}
}

bool CADOXTable::AddIndex(CADOXIndex pIndex)
{
	try
	{
		m_pTable->Indexes->Append(_variant_t((IDispatch *)pIndex.m_pIndex));
		m_pCatalog->Tables->Refresh();
		return true;
	}
	catch(_com_error &e)
	{
		dump_com_error(e);
		return false;
	}
}

bool CADOXTable::DeleteField(LPCTSTR lpstrFieldName)
{
	try
	{
		m_pTable->Columns->Delete(lpstrFieldName);
		return true;
	}
	catch(_com_error &e)
	{
		dump_com_error(e);
		return false;
	}
}

void CADOXTable::GetName(CString& strTableName)
{
	_variant_t vName;

	ASSERT(m_pTable != NULL);

	vName  = m_pTable->GetName();
	strTableName = vName.bstrVal;
}

void CADOXTable::dump_com_error(_com_error &e)
{
	CString ErrorStr;
	
	
	_bstr_t bstrSource(e.Source());
	_bstr_t bstrDescription(e.Description());
	ErrorStr.Format( "CADOXTable Error\n\tCode = %08lx\n\tCode meaning = %s\n\tSource = %s\n\tDescription = %s\n",
		e.Error(), e.ErrorMessage(), (LPCSTR)bstrSource, (LPCSTR)bstrDescription );
#ifdef _DEBUG
	AfxMessageBox( ErrorStr, MB_OK | MB_ICONERROR );
#endif	
}


////////////////////////////////////////////////////////
//
// CADOXCAtalog Class
//

bool CADOXCatalog::CreateDatabase(LPCTSTR lpstrCreate)
{
	try
	{
		m_pCatalog->Create(_bstr_t(lpstrCreate));	
		return true;
	}
	catch(_com_error &e)
	{
		dump_com_error(e);
		return false;
	}
}

bool CADOXCatalog::Open(LPCTSTR lpstrConnection)
{
	HRESULT hr = S_OK;

	TESTHR(hr = m_pConn.CreateInstance(__uuidof(ADODB::Connection)));

	try
	{
		m_pConn->Open(lpstrConnection, "", "", NULL);

        m_pCatalog->PutActiveConnection(variant_t((IDispatch *)m_pConn));
		//m_pCatalog->PutActiveConnection(_bstr_t(lpstrConnection));
		return true;
	}
	catch(_com_error &e)
	{
		dump_com_error(e);
		return false;
	}
	
}

bool CADOXCatalog::AddTable(CADOXTable pTable)
{
	try
	{
		m_pCatalog->Tables->Append( _variant_t((IDispatch *)pTable.m_pTable));
		m_pCatalog->Tables->Refresh();
		return true;
	}
	catch(_com_error &e)
	{
		dump_com_error(e);
		return false;
	}
}

void CADOXCatalog::GetTableName(long nTableIndex, CString &strTableName)
{
	ASSERT(m_pCatalog != NULL);
	ASSERT(nTableIndex >= 0 && nTableIndex < m_pCatalog->Tables->GetCount());
	
	strTableName = (LPCTSTR)m_pCatalog->Tables->GetItem(nTableIndex)->GetName();
}

bool CADOXCatalog::DeleteTable(LPCTSTR lpstrTableName)
{
	ASSERT(m_pCatalog != NULL);

	try
	{
		m_pCatalog->Tables->Delete(lpstrTableName);
		return true;
	}
	catch(_com_error &e)
	{
		dump_com_error(e);
		return false;
	}
}

bool CADOXCatalog::DeleteTable(long nTableIndex)
{
	ASSERT(m_pCatalog != NULL);
	ASSERT(nTableIndex >= 0 && nTableIndex < m_pCatalog->Tables->GetCount());

	try
	{
		m_pCatalog->Tables->Delete(nTableIndex);
		return true;
	}
	catch(_com_error &e)
	{
		dump_com_error(e);
		return false;
	}
}

void CADOXCatalog::GetProcedureName(long nProcedure, CString &strProcedureName)
{
	ASSERT(m_pCatalog != NULL);
	ASSERT(nProcedure >= 0 && nProcedure < m_pCatalog->Procedures->GetCount());
	
	strProcedureName = (LPCTSTR)m_pCatalog->Procedures->GetItem(nProcedure)->GetName();
}

bool CADOXCatalog::DeleteProcedure(long nProcedure)
{
	ASSERT(m_pCatalog != NULL);
	ASSERT(nProcedure >= 0 && nProcedure < m_pCatalog->Procedures->GetCount());
	
	try
	{
		m_pCatalog->Procedures->Delete(nProcedure);
		m_pCatalog->Procedures->Refresh();
		return true;
	}
	catch(_com_error &e)
	{
		dump_com_error(e);
		return false;
	}
}

bool CADOXCatalog::DeleteProcedure(LPCTSTR lpstrProcedureName)
{
	ASSERT(m_pCatalog != NULL);
	
	try
	{
		m_pCatalog->Procedures->Delete(lpstrProcedureName);
		m_pCatalog->Procedures->Refresh();
		return true;
	}
	catch(_com_error &e)
	{
		dump_com_error(e);
		return false;
	}
}

long CADOXCatalog::GetViewCount()
{
	ASSERT(m_pCatalog != NULL);
	try
	{
		return m_pCatalog->Views->GetCount();
	}
	catch(_com_error &e)
	{
		dump_com_error(e);
		return -1;
	}
}
		

void CADOXCatalog::GetViewName(long nViewIndex, CString &strViewName)
{
	ASSERT(m_pCatalog != NULL);
	ASSERT(nViewIndex >= 0 && nViewIndex < m_pCatalog->Views->GetCount());
	
	strViewName = (LPCTSTR)m_pCatalog->Views->GetItem(nViewIndex)->GetName();
}

bool CADOXCatalog::DeleteView(LPCTSTR lpstrViewName)
{
	ASSERT(m_pCatalog != NULL);

	try
	{
		m_pCatalog->Views->Delete(lpstrViewName);
		return true;
	}
	catch(_com_error &e)
	{
		dump_com_error(e);
		return false;
	}
}

bool CADOXCatalog::DeleteView(long nViewIndex)
{
	ASSERT(m_pCatalog != NULL);
	ASSERT(nViewIndex >= 0 && nViewIndex < m_pCatalog->Views->GetCount());

	try
	{
		m_pCatalog->Views->Delete(nViewIndex);
		return true;
	}
	catch(_com_error &e)
	{
		dump_com_error(e);
		return false;
	}
}

void CADOXCatalog::GetGroupName(long nGroupIndex, CString &strGroupName)
{
	ASSERT(m_pCatalog != NULL);
	ASSERT(nGroupIndex >= 0 && nGroupIndex < m_pCatalog->Groups->GetCount());
	
	strGroupName = (LPCTSTR)m_pCatalog->Groups->GetItem(nGroupIndex)->GetName();
}

bool CADOXCatalog::DeleteGroup(LPCTSTR lpstrGroupName)
{
	ASSERT(m_pCatalog != NULL);

	try
	{
		m_pCatalog->Groups->Delete(lpstrGroupName);
		m_pCatalog->Groups->Refresh();
		return true;
	}
	catch(_com_error &e)
	{
		dump_com_error(e);
		return false;
	}
}

bool CADOXCatalog::DeleteGroup(long nGroupIndex)
{
	ASSERT(m_pCatalog != NULL);
	ASSERT(nGroupIndex >= 0 && nGroupIndex < m_pCatalog->Groups->GetCount());

	try
	{
		m_pCatalog->Groups->Delete(nGroupIndex);
		m_pCatalog->Groups->Refresh();
		return true;
	}
	catch(_com_error &e)
	{
		dump_com_error(e);
		return false;
	}
//	m_pCatalog->GetTables()->GetItem(
}

void CADOXCatalog::GetUserName(long nUserIndex, CString &strUserName)
{
	ASSERT(m_pCatalog != NULL);
	ASSERT(nUserIndex >= 0 && nUserIndex < m_pCatalog->Users->GetCount());
	
	strUserName = (LPCTSTR)m_pCatalog->Users->GetItem(nUserIndex)->GetName();
}

bool CADOXCatalog::DeleteUser(LPCTSTR lpstrUserName)
{
	ASSERT(m_pCatalog != NULL);

	try
	{
		m_pCatalog->Users->Delete(lpstrUserName);
		m_pCatalog->Users->Refresh();
		return true;
	}
	catch(_com_error &e)
	{
		dump_com_error(e);
		return false;
	}
}

bool CADOXCatalog::DeleteUser(long nUserIndex)
{
	ASSERT(m_pCatalog != NULL);
	ASSERT(nUserIndex >= 0 && nUserIndex < m_pCatalog->Users->GetCount());

	try
	{
		m_pCatalog->Users->Delete(nUserIndex);
		m_pCatalog->Users->Refresh();
		return true;
	}
	catch(_com_error &e)
	{
		dump_com_error(e);
		return false;
	}
}

bool CADOXCatalog::AddUser(CADOXUser pUser, LPCTSTR lpstrPassword)
{
	try
	{
		m_pCatalog->Users->Append( _variant_t((IDispatch *)pUser.m_pUser), _bstr_t(lpstrPassword));
		m_pCatalog->Users->Refresh();
		return true;
	}
	catch(_com_error &e)
	{
		dump_com_error(e);
		return false;
	}
}


void CADOXCatalog::dump_com_error(_com_error &e)
{
	CString ErrorStr;
	
	
	_bstr_t bstrSource(e.Source());
	_bstr_t bstrDescription(e.Description());
	ErrorStr.Format( "CADOXCatalog Error\n\tCode = %08lx\n\tCode meaning = %s\n\tSource = %s\n\tDescription = %s\n",
		e.Error(), e.ErrorMessage(), (LPCSTR)bstrSource, (LPCSTR)bstrDescription );
#ifdef _DEBUG
	AfxMessageBox( ErrorStr, MB_OK | MB_ICONERROR );
#endif	
}

