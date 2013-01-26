// OleDataLink.h: interface for the COleDataLink class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_OLEDATALINK_H__BF987A55_6A49_4140_919E_BB956D807885__INCLUDED_)
#define AFX_OLEDATALINK_H__BF987A55_6A49_4140_919E_BB956D807885__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
//	Compiler:	Visual C++
//	Tested on:	Visual C++ 6.0
//	Version:	1.0
//	Created:	09/September/2001
//	Author:		 yanghuaisheng (codefan@sou.com)
// Copyright yanghuaisheng, 2001-2003 (codefan@sou.com)
// Feel free to use and distribute. May not be sold for profit. 

/*
add the following code in the stdafx.h and call the function 
::CoInitialize(NULL) before using it.
#import "G:\program files\common files\system\ado\msado15.tlb" no_namespace rename("EOF", "IsEOF") rename("BOF", "IsBOF")
#import "G:\program files\common files\system\ole db\oledb32.dll" \
rename_namespace("oledb")

*/

#include <comdef.h>

BOOL	ShowDataLink( _bstr_t* );
BOOL	ShowDataLink( CString & sConn,CString & sUsername,CString & sPasaword);
#endif // !defined(AFX_OLEDATALINK_H__BF987A55_6A49_4140_919E_BB956D807885__INCLUDED_)
