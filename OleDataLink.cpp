// OleDataLink.cpp: implementation of the COleDataLink class.
//
//////////////////////////////////////////////////////////////////////
#include "stdafx.h"
#include "OleDataLink.h"

#if ! defined _IMPORT_MSADO15_ 
#define _IMPORT_MSADO15_
#import "C:\Program Files\Common Files\System\ADO\msado15.dll" \
no_namespace rename("EOF", "EndOfFile")
#endif


//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

//#import "G:\program files\common files\system\ado\msado20.tlb" no_namespace rename("EOF", "IsEOF") rename("BOF", "IsBOF")
#import "C:\program files\common files\system\Ole DB\oledb32.dll" rename_namespace("oledb")

inline void TESTHR( HRESULT hr )
	{
	if( FAILED(hr) ) _com_issue_error( hr );
	}	
/*
 *  ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
 *
 *  Function ..... : BOOL ShowDataLink( _bstr_t * bstr_ConnectString )
 *  Purpose ...... : Display the OLE DB Data Link properties dialog, using (if supplied) a 
 *				   : pre-configured connection string.
 *  Parameters ... : bstr_ConnectString = A pointer to a _bstr_t that currently holds the 
 *				   :                      connection string. Upon completion, it will contain 
 *				   :					  the new connection string.
 *  Returns ...... : TRUE indicating OK was pressed to save the connection string.
 *
 */

BOOL ShowDataLink( _bstr_t * bstr_ConnectString )
	{

	HRESULT		hr;
	oledb::IDataSourceLocatorPtr	p_IDSL= NULL;			// This is the Data Link dialog object
	_ConnectionPtr			p_conn = NULL;			// We need a connection pointer too
	BOOL							b_ConnValid = FALSE;
	
	try
		{
	
		/*
		 *   Create an instance of the IDataSourceLocator interface and check for errors.
		 */
		hr = p_IDSL.CreateInstance( __uuidof( oledb::DataLinks ));
		TESTHR( hr );

		/*
		 *   If the passed in Connection String is blank, we are creating a new connection
		 */
		if( *bstr_ConnectString == _bstr_t("") )
			{
			/*
			 *   Simply display the dialog. It will return a NULL or a valid connection object 
			 *   with the connection string filled in for you. If it returns NULL, the user
			 *	 must of clicked the cancel button.
			 */
			p_conn = p_IDSL->PromptNew();
			if( p_conn != NULL ) b_ConnValid = TRUE;
			
			}
		else 
			{
			/*
			 *   We are going to use a pre-existing connection string, so first we need to
			 *	 create a connection object ourselves. After creating it, we'll copy the
			 *   connection string into the object's connection string member
			 */
			p_conn.CreateInstance( "ADODB.Connection" );
			p_conn->ConnectionString = *bstr_ConnectString;

			/*	 
			 *   When editing a data link, the IDataSourceLocator interface requires we pass 
			 *	 it a connection object under the guise of an IDispatch interface. So,
			 *	 here we'll query the interface to get a pointer to the IDispatch interface,
			 *	 and we'll pass that to the data link dialog.
			 */
			IDispatch * p_Dispatch = NULL;
			p_conn.QueryInterface( IID_IDispatch, (LPVOID*) & p_Dispatch );
			
			if( p_IDSL->PromptEdit( &p_Dispatch )) b_ConnValid = TRUE;
			
			p_Dispatch->Release();
			}
		/*   
		 *   Once we arrive here, we're done editing. Did the user press OK or cancel ?
		 *
		 *	 If OK was pressed, we want to return the new connection string in the parameter given to us.
		 */
		if( b_ConnValid )
			{
			*bstr_ConnectString = p_conn->ConnectionString;
			}

		}
	catch( _com_error &  )
		{
		
		/*
		 *   Catcher for any _com_error's that are generated.
		 */
		
		return FALSE;
		}

	return b_ConnValid;
	}



/*
 *  ====================================================================================================================================================================
 *
 *  Eof : core.cpp
 *
 */

BOOL	ShowDataLink( CString & sConn,CString & sUsername,CString & sPassword)
{
	int bp = -1;
    if( sPassword.GetLength() > 0){
		CString spwd = sPassword;
		spwd.Replace("\"","\"\"");
		bp = sConn.Find("Password");
		if( bp != -1 ){
			bp = sConn.Find('=',bp);
			CString sbp = sConn.Mid(0,bp+1);
			int ep = sConn.Find('=',bp+1);
			if( ep != -1){
				CString tempStr = sConn.Mid(bp+1,ep-bp-2);
				int pbp = tempStr.ReverseFind(';');
				sConn = sbp + sConn.Mid(bp+pbp+1);
				sConn = sbp +"\"" + spwd + "\""+ sConn.Mid(bp+pbp+1);
			}else{
				sConn = sbp +"\"" + spwd + "\"";
			}
		}else
			sConn = sConn + ";Password=\"" + spwd + "\"";
	}
    if( sUsername.GetLength() > 0){
		CString suser = sUsername;
		suser.Replace("\"","\"\"");
		bp = sConn.Find("User ID");
		if( bp != -1 ){
			bp = sConn.Find('=',bp);
			CString sbp = sConn.Mid(0,bp+1);
			int ep = sConn.Find('=',bp+1);
			if(ep != -1){
				CString tempStr = sConn.Mid(bp+1,ep-bp-2);
				int pbp = tempStr.ReverseFind(';');
				sConn = sbp + sConn.Mid(bp+pbp+1);
				sConn = sbp +"\"" + suser + "\""+ sConn.Mid(bp+pbp+1);
			}else{
				sConn = sbp +"\"" + suser + "\"";
			}
		}else
			sConn = sConn + ";User ID=\"" + suser + "\"";
	}

	bstr_t bstrConn = sConn.AllocSysString();
	if(!ShowDataLink(&bstrConn)) return FALSE;
	sConn = LPCTSTR(bstrConn);
	bp = sConn.Find("Password");
	if( bp != -1 ){
		CString sbp = sConn.Mid(0,bp);
		bp = sConn.Find('=',bp);
		int ep = sConn.Find('=',bp+1);
		CString tempStr,spwd; 
		if( ep != -1) {
			tempStr = sConn.Mid(bp+1,ep-bp-2);
			int pbp = tempStr.ReverseFind(';');
			sConn = sbp + sConn.Mid(bp+pbp+2);
			spwd = tempStr.Mid(0,pbp);
		}else{
			tempStr = sConn.Mid(bp+1);
			sConn = sbp ;
			spwd = tempStr;
		}

		spwd.TrimLeft();
		spwd.TrimRight();
		if(spwd[0] == '"')
			spwd = spwd.Mid(1,spwd.GetLength()-2);
		spwd.Replace("\"\"","\"");
		sPassword = spwd;
	}
	bp = sConn.Find("User ID");
	if( bp != -1 ){
		CString sbp = sConn.Mid(0,bp);
		bp = sConn.Find('=',bp);
		int ep = sConn.Find('=',bp+1);
		CString tempStr,suser; 
		if( ep != -1) {
			tempStr = sConn.Mid(bp+1,ep-bp-2);
			int pbp = tempStr.ReverseFind(';');
			sConn = sbp + sConn.Mid(bp+pbp+2);
			suser = tempStr.Mid(0,pbp);
		}else{
			tempStr = sConn.Mid(bp+1);
			sConn = sbp ;
			suser = tempStr;
		}
		suser.TrimLeft();
		suser.TrimRight();
		if(suser[0] == '"')
			suser = suser.Mid(1,suser.GetLength()-2);
		suser.Replace("\"\"","\"");
		sUsername = suser;
	}
	return TRUE;
}
