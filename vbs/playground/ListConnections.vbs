Option Explicit
'
' List User Connections
'
' This script connects to each server and enumerates the shares
' and returns the number of users connected to each.
'
' This script will accept a command-line argument similar to the following:
' 	LDAP://CN=fs,OU=servers,DC=company,DC=com
'	LDAP://OU=servers,DC=company,DC=com
'
' June 17, 2009: Jeff Patton
'
	Call LogData(4, ScriptDetails(".") & vbCrLf & "Started: " & Now())
	If Wscript.Arguments.Count = 0 Then
		Wscript.Echo "Please provide a target in the form of: 'LDAP://DC=company,DC=com'"
		Wscript.Quit
	Else
		Call QueryAD("SELECT DistinguishedName ,Name FROM '" & Wscript.Arguments.Item(0) & "'")
	End If
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
			Call GetServerConnections(objRecordSet.Fields("Name") & ".soecs.ku.edu")
			objRecordSet.MoveNext
		Loop
End Sub

Sub GetServerConnections(strComputer)
	'
	' This procedure gets a list of sharenames from the provided server
	' to pass along to the userconnections function.
	'
	Dim objWMIService
	Dim colItems
	Dim objItem

	Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\CIMV2") 
	Set colItems = objWMIService.ExecQuery("SELECT * FROM Win32_Share",,48) 
	For Each objItem in colItems
		If InStr(objItem.Name, "$") > 0 Then
		Else
			Wscript.Echo strComputer & ", " & objItem.Name & ", " & UserConnections(strComputer, objItem.Name)
		End If
	Next
End Sub

Function UserConnections(strComputer, strShare)
	'
	' This function conntects to the remost server and counts the number
	' of users connected to the provided share.
	'
	Dim objWMIService
	Dim objItem
	Dim colItems
	Dim intCount

	Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\CIMV2") 
	Set colItems = objWMIService.ExecQuery("SELECT * FROM Win32_ServerConnection",,48)

	For Each objItem in colItems 
		If objItem.ShareName <> strShare Then
		Else
			intCount = intCount + 1
		End If
	Next

	If isEmpty(intCount) Then intCount = 0

	UserConnections = intCount
End Function

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