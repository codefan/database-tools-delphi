// AdoQuery.cpp: implementation of the CAdoQuery class.
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"

#include "AdoQuery.h"

#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[]=__FILE__;
#define new DEBUG_NEW
#endif

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////
inline void TESTHR(HRESULT x) {if FAILED(x) _com_issue_error(x);};

CQueryParamList::CQueryParamList()
{
}
CQueryParamList::~CQueryParamList()
{
}

#if defined _NAMESPACE_MSADO15_
MSADO15::DataTypeEnum CQueryParamList::GetDataType(LPCTSTR szType)
#else
DataTypeEnum CQueryParamList::GetDataType(LPCTSTR szType)
#endif
{
    if( strcmp(szType,"tinyint") ==0) return adTinyInt;
    if( strcmp(szType,"smallint") ==0) return adSmallInt;
    if( strcmp(szType,"integer") ==0) return adInteger;
    if( strcmp(szType,"bigint") ==0) return adBigInt ;
    if( strcmp(szType,"unsignedtinyint") ==0) return adUnsignedTinyInt;
    if( strcmp(szType,"unsignedsmallint") ==0) return adUnsignedSmallInt;
    if( strcmp(szType,"unsignedint") ==0) return adUnsignedInt;
    if( strcmp(szType,"unsignedbigint") ==0) return adUnsignedBigInt ;
    if( strcmp(szType,"single") ==0) return adSingle ;
    if( strcmp(szType,"double") ==0) return adDouble;
    if( strcmp(szType,"currency") ==0) return adCurrency ;
    if( strcmp(szType,"decimal") ==0) return adDecimal ;
    if( strcmp(szType,"numeric") ==0) return adNumeric;
    if( strcmp(szType,"boolean") ==0) return adBoolean;
    if( strcmp(szType,"error") ==0) return adError ;
    if( strcmp(szType,"userdefined") ==0) return adUserDefined ;
    if( strcmp(szType,"variant") ==0) return adVariant;
    if( strcmp(szType,"idispatch") ==0) return adIDispatch ;
    if( strcmp(szType,"iunknown") ==0) return adIUnknown;
    if( strcmp(szType,"guid") ==0) return adGUID ;
    if( strcmp(szType,"date") ==0) return adDate ;
    if( strcmp(szType,"dbdate") ==0) return adDBDate;
    if( strcmp(szType,"dbtime") ==0) return adDBTime ;
	if( strcmp(szType,"dbtimestamp") ==0) return adDBTimeStamp ;
    if( strcmp(szType,"bstr") ==0) return adBSTR;
    if( strcmp(szType,"char") ==0) return adChar;
    if( strcmp(szType,"varchar") ==0) return adVarChar;
    if( strcmp(szType,"longvarchar") ==0) return adLongVarChar;
    if( strcmp(szType,"wchar") ==0) return adWChar ;
    if( strcmp(szType,"varwchar") ==0) return adVarWChar ;
    if( strcmp(szType,"longvarwchar") ==0) return adLongVarWChar;
    if( strcmp(szType,"binary") ==0) return adBinary ;
    if( strcmp(szType,"varbinary") ==0) return adVarBinary;
    if( strcmp(szType,"longvarbinary") ==0) return adLongVarBinary ;
    if( strcmp(szType,"chapter") ==0) return adChapter;
    if( strcmp(szType,"filetime") ==0) return adFileTime;
    if( strcmp(szType,"propvariant") ==0) return adPropVariant;
    if( strcmp(szType,"varnumeric") ==0) return adVarNumeric;
    if( strcmp(szType,"array") ==0) return adArray;
	return adEmpty;
}

#if defined _NAMESPACE_MSADO15_
MSADO15::ParameterDirectionEnum CQueryParamList::GetDataDirectionType(LPCTSTR szType)
#else
ParameterDirectionEnum CQueryParamList::GetDataDirectionType(LPCTSTR szType)
#endif
{
    
	if( strcmp(szType,"in") == 0) return   adParamInput ;
	if( strcmp(szType,"out") == 0) return   adParamOutput ;
	if( strcmp(szType,"inout") == 0) return   adParamInputOutput ;
	if( strcmp(szType,"return") == 0) return  adParamReturnValue;
	return adParamUnknown;
}

void CQueryParamList::AddParameter(LPCTSTR name, LPCTSTR type, LPCTSTR direction, UINT value)
{
	SQueryParam tPrm;
	tPrm.name = name;
	tPrm.type = GetDataType(type);
	tPrm.direction = GetDataDirectionType(direction);
	tPrm.value.vt = VT_UI4;
	tPrm.value.uintVal = value;
	tPrm.size = sizeof(tPrm.value);
	AddTail(tPrm);
}
void CQueryParamList::AddParameter(LPCTSTR name, LPCTSTR type, LPCTSTR direction, LPCTSTR value)
{
	SQueryParam tPrm;
	tPrm.name = name;
	tPrm.type = GetDataType(type);
	tPrm.direction = GetDataDirectionType(direction);
	tPrm.value = bstr_t(value);
	tPrm.size = sizeof(tPrm.value);
	AddTail(tPrm);
}
void CQueryParamList::AddParameter(LPCTSTR name, LPCTSTR type, LPCTSTR direction, _variant_t value)
{
	SQueryParam tPrm;
	tPrm.name = name;
	tPrm.type = GetDataType(type);
	tPrm.direction = GetDataDirectionType(direction);
	tPrm.value = value;
	tPrm.size = sizeof(tPrm.value);
	AddTail(tPrm);
}

SQueryParam CQueryParamList::GetItem(LPCTSTR name)
{
	ASSERT(!IsEmpty());
	SQueryParam rePrm;
	POSITION p = GetHeadPosition();
	while(p != NULL){
		rePrm = GetNext(p);
		if( strcmp(LPCTSTR(rePrm.name),name) == 0 )
			return rePrm;
	}
	return rePrm;
}

SQueryParam CQueryParamList::GetItem(long lno)
{
	ASSERT(!IsEmpty());
	ASSERT(lno < GetCount());
	SQueryParam rePrm;
	POSITION p = GetHeadPosition();
	long np=0;
	while(p != NULL){
		if(np == lno)
			rePrm = GetNext(p);
		else
			GetNext(p);
	}
	return rePrm;
}

CAdoQuery::CAdoQuery()
{
	m_bIsConnect = false;
	pCnn = NULL;
	pRecord = NULL;
	pCommand = NULL;
//	Initialize();
}
CAdoQuery::CAdoQuery(LPCTSTR szConn,LPCTSTR szUsername,LPCTSTR szPassword)
{
	SetDBParameter(szConn,szUsername,szPassword);
}

CAdoQuery::~CAdoQuery()
{

}

void CAdoQuery::SetDBParameter(LPCTSTR szConn,LPCTSTR szUsername,LPCTSTR szPassword)
{
	conn = CString(szConn).AllocSysString();
	username = CString(szUsername).AllocSysString();
	password = CString(szPassword).AllocSysString();
}

void CAdoQuery::Initialize()
{
	pCnn.CreateInstance(__uuidof(Connection));
	pRecord.CreateInstance(__uuidof(Recordset));
	pCommand.CreateInstance(__uuidof(Command));
}
BOOL CAdoQuery::ConnectDatabase()
{
	ASSERT(!m_bIsConnect);
	bool bConnOK = true;
	try{
		HRESULT hr = pCnn->Open(conn,username,password,-1);
		if( FAILED(hr))
			bConnOK = false;
	}catch(_com_error & ){
		bConnOK = false;
	}
	if (bConnOK)
		m_bIsConnect = true;
	return bConnOK;
}
BOOL CAdoQuery::DisconnectDatabase()
{
	ASSERT(m_bIsConnect);
	m_bIsConnect = false;
	BOOL bExecute = TRUE;
	try{
		HRESULT hr = pCnn->Close();
		if( FAILED(hr))
			bExecute = FALSE;
	}catch(_com_error & ){
		bExecute = FALSE;
	}
	return bExecute;
}
BOOL CAdoQuery::QueryDatabase(LPCTSTR szSqlSen)
{
	ASSERT(m_bIsConnect);
	bstr_t sqlsen = CString(szSqlSen).AllocSysString();

	BOOL bExecute = TRUE;
	try{
		HRESULT hr = pRecord->Open(sqlsen , _variant_t((IDispatch *) pCnn,true), adOpenStatic,
		         adLockReadOnly, adCmdText);
		if( FAILED(hr))
			bExecute = FALSE;
	}catch(...){//_com_error & ){
		bExecute = FALSE;
	}
	return bExecute;
}
BOOL CAdoQuery::EndQuery()
{
	BOOL bExecute = TRUE;
	try{
		HRESULT hr = pRecord->Close();
		if( FAILED(hr))
			bExecute = FALSE;
	}catch(...){//_com_error & ){
		bExecute = FALSE;
	}
	return bExecute;
}

BOOL CAdoQuery::ExecuteSql(LPCTSTR szSqlSen)
{
	//pCommand->ActiveConnection = pCnn;
	//pCommand->CommandType = adCmdStoredProc;
	ASSERT(m_bIsConnect);
	CString strSqlSen(szSqlSen);
	bstr_t sqlsen = strSqlSen.AllocSysString();
	BOOL bExecute = TRUE;
	try{
		HRESULT hr = pCnn->Execute(sqlsen,NULL,-1);
		if( FAILED(hr))
			bExecute = FALSE;
#if 1
	}catch(_com_error & e ){
		bstr_t bstrErr = e.Description();
		AfxMessageBox(sqlsen + bstrErr);
#else
	}catch(...){
#endif
		bExecute = FALSE;
	}
	return bExecute;
}
void CAdoQuery::SetSqlSen(LPCTSTR szSqlSen)
{
	pCommand->ActiveConnection = pCnn;
	pCommand->CommandType = adCmdText;
	pCommand->CommandText = szSqlSen;
	pCommand->PutPrepared(TRUE);
}

void CAdoQuery::AppendParam(SQueryParam & prm)
{
	_ParameterPtr pprmByRoyalty = pCommand->CreateParameter(prm.name,prm.type,prm.direction,prm.size,prm.value);
	pCommand->Parameters->Append(pprmByRoyalty);
}

void CAdoQuery::AppendParam(LPCTSTR name, LPCTSTR type, LPCTSTR direction, _variant_t value)
{
	SQueryParam tPrm;
	tPrm.name = name;
	tPrm.type = CQueryParamList::GetDataType(type);
	tPrm.direction = CQueryParamList::GetDataDirectionType(direction);
	tPrm.value = value;
	tPrm.size = sizeof(tPrm.value);
	AppendParam(tPrm);
}

void CAdoQuery::CreateParam( CQueryParamList & prmList)
{
	if(!prmList.IsEmpty()){
		POSITION pos = prmList.GetHeadPosition();
		while(pos != NULL){
			SQueryParam & prm = prmList.GetNext(pos);
			AppendParam(prm);
		}
	}
}
void CAdoQuery::EndExecute()
{
//	pCommand->Parameters->Refresh();
	long n = pCommand->Parameters->GetCount();
	for(long i=n-1;i>=0l;i--)
		pCommand->Parameters->Delete(i);
	pCommand->PutPrepared(FALSE);
}

BOOL CAdoQuery::Execute()
{
	pCommand->Execute(NULL,NULL,adCmdText);
	return TRUE;
}

BOOL CAdoQuery::ExecuteTrans(CStringList & szSqlList)
{
	ASSERT(!szSqlList.IsEmpty());
	ASSERT(m_bIsConnect);
	BOOL bExecute = TRUE;
	HRESULT hr;
	try{
		pCnn->BeginTrans();
		POSITION p = szSqlList.GetHeadPosition();
		while(p != NULL){
			bstr_t sqlsen = szSqlList.GetNext(p).AllocSysString();
			hr = pCnn->Execute(sqlsen,NULL,-1);
			if( FAILED(hr)){
				pCnn->RollbackTrans();
				bExecute = FALSE;
			}
		}
		
		if(bExecute){
			hr = pCnn->CommitTrans();
			if( FAILED(hr)){
				pCnn->RollbackTrans();
				bExecute = FALSE;
			}
		}
#if 0
	}catch(_com_error & e){
		CString str;
		str = LPCTSTR(e.Description());
		pCnn->RollbackTrans();
		bExecute = FALSE;
	}
#else
	}catch(_com_error &  ){
		pCnn->RollbackTrans();
		bExecute = FALSE;
	}
#endif
	return bExecute;
}

BOOL CAdoQuery::QueryDatabaseWithParam(LPCTSTR szSqlSen,  CQueryParamList & prmList)
{
	BOOL bExecute = TRUE;
	try{
		pCommand->ActiveConnection = pCnn;
		pCommand->CommandType = adCmdText;
		pCommand->CommandText = szSqlSen;
		
		if(!prmList.IsEmpty()){
			POSITION pos = prmList.GetHeadPosition();
			while(pos != NULL){
				SQueryParam & prm = prmList.GetNext(pos);
				_ParameterPtr pprmByRoyalty = pCommand->CreateParameter(prm.name,prm.type,prm.direction,prm.size,prm.value);
				pCommand->Parameters->Append(pprmByRoyalty);
			}
		}
		pRecord = pCommand->Execute(NULL,NULL,adCmdText);
		pCommand->Parameters->Refresh();
		
	}catch(_com_error & e){
		CString sErr = LPCTSTR(e.Description());
		AfxMessageBox(sErr);
		bExecute = FALSE;
	}
	return bExecute;
}

BOOL CAdoQuery::ExecuteProcedure(LPCTSTR szSqlSen, CQueryParamList & prmList)
{
	BOOL bExecute = TRUE;
	try{
		pCommand->ActiveConnection = pCnn;
		pCommand->CommandType = adCmdStoredProc;
		pCommand->CommandText = szSqlSen;

		if(!prmList.IsEmpty()){
			POSITION pos = prmList.GetHeadPosition();
			while(pos != NULL){
				SQueryParam & prm = prmList.GetNext(pos);
				_ParameterPtr pprmByRoyalty = pCommand->CreateParameter(prm.name,prm.type,prm.direction,prm.size,prm.value);
				pCommand->Parameters->Append(pprmByRoyalty);
			}
		}
		pCommand->Execute(NULL,NULL,adCmdStoredProc);
		if(!prmList.IsEmpty()){
			POSITION pos = prmList.GetHeadPosition();
			while(pos != NULL){
				SQueryParam & prm = prmList.GetNext(pos);
				if( prm.direction > adParamInput)
					prm.value = pCommand->Parameters->GetItem(prm.name)->Value;	
			}
		}
		pCommand->Parameters->Refresh();
	}catch(_com_error & e){
		CString sErr = LPCTSTR(e.Description());
		AfxMessageBox(sErr);
		bExecute = FALSE;
	}
	return bExecute;
}

_variant_t CAdoQuery::FieldValue(long n)
{
	_variant_t v_r;
	try{
//		_variant_t v_n;
//		v_n.vt = VT_I4;
//		v_n.lVal = n;
		v_r =  pRecord->Fields->Item[n]->Value;
	}catch(...){
		v_r.vt = VT_NULL;
	}
	return v_r;
}
_variant_t CAdoQuery::FieldValue(LPCTSTR s)
{
	_variant_t v_r;
	try{
		_variant_t v_n;
		v_n.vt = VT_BSTR;
		v_n.bstrVal = CString(s).AllocSysString();
		v_r =  pRecord->Fields->Item[v_n]->Value;
	}catch(...){
		v_r.vt = VT_NULL;
	}
	return v_r;
}

CString CAdoQuery:: FieldString(long n)
{
	CString sR;
	try{
		bstr_t tmpBstr =L"";
		_variant_t v_v = pRecord->Fields->Item[n]->Value;
		USHORT nVT = v_v.vt;
		if ((nVT == VT_BSTR )||
			(nVT == VT_LPSTR)||
			(nVT == VT_LPWSTR))
			tmpBstr = v_v.bstrVal;
		sR  = LPCTSTR(tmpBstr);
	}catch(...){
		sR="";
	}
	return sR;
}

CString CAdoQuery:: FieldAsString(long n)
{
	CString sR;
	try{
		bstr_t tmpBstr =L"";
		_variant_t v_v = pRecord->Fields->Item[n]->Value;
		if (v_v.vt != VT_NULL) 
			tmpBstr = _bstr_t(v_v);
		sR = LPCTSTR(tmpBstr);
		sR.TrimRight();
	}catch(...){
		sR="";
	}
	return sR;
}



CString CAdoQuery:: FieldString(LPCTSTR s)
{
	CString sR;
	try{
		_variant_t v_n;
		v_n.vt = VT_BSTR;
		v_n.bstrVal = CString(s).AllocSysString();
		bstr_t tmpBstr =L"";
		_variant_t v_v = pRecord->Fields->Item[v_n]->Value;
		USHORT nVT = v_v.vt;
		if ((nVT == VT_BSTR )||
			(nVT == VT_LPSTR)||
			(nVT == VT_LPWSTR))
			tmpBstr = v_v.bstrVal;
		sR = LPCTSTR(tmpBstr);
		sR.TrimRight();
	}catch(...){
		sR="";
	}
	return sR;}

CString CAdoQuery:: FieldAsString(LPCTSTR s)
{
	CString sR;
	try{
		_variant_t v_n;
		v_n.vt = VT_BSTR;
		v_n.bstrVal = CString(s).AllocSysString();
		bstr_t tmpBstr =L"";
		_variant_t v_v = pRecord->Fields->Item[v_n]->Value;
		if (v_v.vt != VT_NULL) 
			tmpBstr = _bstr_t(v_v);
		sR = LPCTSTR(tmpBstr);
		sR.TrimRight();
	}catch(...){
		sR="";
	}
	return sR;
}