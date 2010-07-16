Option Explicit
'
' This routine updates the registry on computers in our AD
'

	Call LogData(4, ScriptDetails(".") & vbCrLf & "Started: " & Now())
	Call QueryAD("SELECT DistinguishedName ,Name FROM 'LDAP://OU=1137,OU=Learned,OU=Labs,DC=soecs,DC=ku,DC=edu' WHERE objectClass = 'computer'")	
	Call LogData(4, ScriptDetails(".") & vbCrLf & "Finished: " & Now())

Sub QueryAD(strQuery)
'On Error Resume Next
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
		Call RegRead(objRecordSet.Fields("Name") & ".soecs.ku.edu", "\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\ADSKFLEX_LICENSE_FILE")
		objRecordSet.MoveNext
	Loop
End Sub

Sub RegRead(strComputer, strKeyPath)
const HKEY_LOCAL_MACHINE = &H80000002
'On Error Resume Next
'
' This procedure reads the subkeys within a parent key
'
' http://msdn.microsoft.com/en-us/library/293bt9hh(VS.85).aspx
'
Dim objRegistry
Dim arrSubKeys
Dim objSubKey

Set objRegistry = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\default:StdRegProv")

	objRegistry.EnumKey HKEY_LOCAL_MACHINE, strKeyPath, arrSubKeys

	For Each objSubKey In arrSubKeys
		Wscript.Echo objSubKey
	Next
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
