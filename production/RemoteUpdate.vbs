'
' RemoteUpdate.vbs
'
' This script queries the AD for a list of computers
' it then updates the environment variable provided
' in the registry.
'
' May 12, 2009: Jeff Patton
'

Option Explicit

Dim strPropertyList
Dim strLDAPURL
Dim strObjectClass
Dim strQuery
Dim strVariable
Dim strVariableValue

strPropertyList = "DistinguishedName ,Name"
strLDAPURL = "LDAP://OU=Labs,DC=soecs,DC=ku,DC=edu"
strObjectClass = "computer"
strQuery = "SELECT " & strPropertyList & " FROM '" & strLDAPURL & "' WHERE objectClass = '" & strObjectClass & "'"

strVariable = "FLUENT_LICENSE_FILE"
strVariableValue = "7241@license1.soecs.ku.edu"

	Call LogData(4, ScriptDetails(".") & vbCrLf & "Started: " & Now())
	Call QueryAD(strQuery)
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
			Call RemoteAddVar(strVariable, strVariableValue, objRecordSet.Fields("Name"))
			objRecordSet.MoveNext
		Loop
End Sub

Sub RemoteAddVar(strVariable, strVariableValue, strComputerName)
	'
	' http://msdn.microsoft.com/en-us/library/aa393600(VS.85).aspx
	'
	CONST HKEY_LOCAL_MACHINE = &H80000002
	Dim objRegistry
	Dim strPath

	On Error Resume Next

	Set ObjRegistry = GetObject("winmgmts:{impersonationLevel = impersonate}!\\" & strComputerName & "\root\default:StdRegProv")

	strPath = "SYSTEM\CurrentControlSet\Control\Session Manager\Environment\"

	objRegistry.SetStringValue HKEY_LOCAL_MACHINE, strPath, strVariable, strVariableValue
	If Err <> 0 Then
		Call LogData(1, strComputerName & vbCrLf & Err.Number & vbCrLf & Err.Description)
		Err.Clear
	Else
		Call LogData(0, "Successfully updated the registry on: " & strComputerName)
	End If
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