'
' SetManagedBy
'
' This script works through AD and sets the managedby property
' of the computer object, to the owner of the same. In order 
' for this script to work, you will need to have rights to 
' query the GC of the domain the user account resides in.
'
' September 21, 2010: Jeff Patton
'
Dim strComputerPath
Dim strUserDN
Dim strADSIProp

	strADSIProp = "managedby"

	Call LogData(4, ScriptDetails(".") & vbCrLf & "Started: " & Now())
	Call QueryAD("SELECT DistinguishedName ,Name FROM 'LDAP://CN=Computers,DC=company,DC=com' WHERE objectClass = 'computer'")
	Call LogData(4, ScriptDetails(".") & vbCrLf & "Finished: " & Now())

Sub QueryAD(strQuery)
	On Error Resume Next
	'
	' This procedure will loop through a recordset of objects
	' returned from a query.
	'
	Const ADS_SCOPE_SUBTREE = 2
	Dim objConnection
	Dim objCommand
	Dim objRecordset
	
	Set objConnection = CreateObject("ADODB.Connection")
	Set objCommand =   CreateObject("ADODB.Command")
	objConnection.Provider = "ADsDSOObject"
	objConnection.Open "Active Directory Provider"
	
	Set objCOmmand.ActiveConnection = objConnection
	objCommand.CommandText = strQuery
	objCommand.Properties("Page Size") = 1000
	objCommand.Properties("Searchscope") = ADS_SCOPE_SUBTREE 
	Set objRecordSet = objCommand.Execute
	If Err <> 0 Then Call LogData(1, "Unable to connect using the provided query: " & vbCrLf & strQuery)
	
		objRecordSet.MoveFirst

		Do Until objRecordSet.EOF
			'
			' Code to do whatever is needed
			'
			strComputerPath = objRecordSet.Fields("DistinguishedName")
			strUserDN =  NT4toDN(GetOwner(objRecordSet.Fields("DistinguishedName")))
			Call WriteData(strADSIProp, strUserDN, strComputerPath)
			objRecordSet.MoveNext
		Loop
End Sub

Function GetOwner(strComputerDN)
	'
	' This function returns the owner of a computer object
	'
	' Source, Richard Mueller
	' http://social.technet.microsoft.com/Forums/en-us/ITCG/thread/59159984-729c-46d1-8faa-58c71ac3a209
	'
	Dim objADObject
	Dim objSecurityDescriptor

	set objADObject = GetObject("LDAP://" & strComputerDN)
	set objSecurityDescriptor = objADObject.Get("ntSecurityDescriptor")

	GetOwner = objSecurityDescriptor.Owner
End Function

Function NT4toDN(strUsername)
	'
	' This function accepts a username in the form of
	'	DOMAIN\User
	' It then converts that name to a DN
	'	CN=User,OU=users,DC=company,DC=com
	'
	' Source: Technet
	' http://blogs.technet.microsoft.com/b/heyscriptingguy/archive/2007/08/22/how-can-i-get-the-guid-for-a-user-account-if-all-i-have-is-the-user-s-logon-name-and-domain.aspx
	'

	Const ADS_NAME_INITTYPE_GC = 3
	Const ADS_NAME_TYPE_NT4 = 3
	Const ADS_NAME_TYPE_1779 = 1

		Set objTranslator = CreateObject("NameTranslate")

		objTranslator.Init ADS_NAME_INITTYPE_GC, "" ' You can set a gc or domainname here
		objTranslator.Set ADS_NAME_TYPE_NT4, strUsername

		strUserDN = objTranslator.Get(ADS_NAME_TYPE_1779)

		NT4toDN = strUserDN
End Function

Sub WriteData(strProperty, strValue, strADSPath)
	'
	' Update a single-value property of an object in AD
	'
	Dim objADObject
	
	Set objADObject = GetObject("LDAP://" & strADSPath)
	
		objADObject.Put strProperty , strValue
		objADObject.SetInfo

End Sub

Sub LogData(intCode, strMessage)
	' Write data to application log
	' 
	' http://www.microsoft.com/technet/scriptcenter/guide/default.mspx?mfr=true
	'
	' Event Codes
	' 	0 = Success
	'	1 = Error
	'	2 = Warning
	'	4 = Information
	Dim objShell

	Set objShell = Wscript.CreateObject("Wscript.Shell")

		objShell.LogEvent intCode, strMessage

End Sub

Function ScriptDetails(strComputer)
	'
	' Return information about who, what, where
	'
	On Error Resume Next
	Dim strScriptName
	Dim strScriptPath
	Dim strUserName
	Dim objWMIService
	Dim colProcesslist
	Dim objProcess
	Dim colProperties
	Dim strNameOfUser
	Dim struserDomain
	
	strScriptName = Wscript.ScriptName
	strScriptPath = Wscript.ScriptFullName
	
	Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")
	Set colProcessList = objWMIService.ExecQuery("Select * from Win32_Process Where Name = 'cscript.exe' or Name = 'wscript.exe'")
	
		For Each objProcess in colProcessList
			If InStr(objProcess.CommandLine, strScriptName) Then
				colProperties = objProcess.GetOwner(strNameOfUser,strUserDomain)
				If Err <> 0 Then
					Call LogData(1, "Error Number: " & vbTab & Err.Number & vbCrLf & "Error Description: " & vbTab & Err.Description)
					Err.Clear
					Exit For
				End If
				strUserName = strUserDomain & "\" & strNameOfUser
			End If
		Next
	
		ScriptDetails = "Script Name: " & strScriptName & vbCrLf & "Script Path: " & strScriptPath & vbCrLf & "Script User: " & strUserName
End Function
