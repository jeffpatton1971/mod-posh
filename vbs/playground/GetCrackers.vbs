'
' Find Crackers
'
' This script searches through AD for computer accounts. It then connects
' to each computer and lists membership of the "Administrators" local account.
' If a user outside our scope of allowed users is listed, it removes them.
' Additionally it logs each non-allowed user account in the Application log of
' the computer running this script.
'
	Call LogData(4, ScriptDetails(".") & vbCrLf & "Started: " & Now())
	Call QueryAD("SELECT DistinguishedName ,Name FROM 'LDAP://OU=1014,OU=Eaton,OU=Labs,DC=company,DC=com' WHERE objectClass = 'computer'")
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
			Call ListMembership(objRecordSet.Fields("Name"), "Administrators")
			objRecordSet.MoveNext
		Loop
End Sub

Sub ListMembership(strComputer, strGroup)
	On Error Resume Next
	'
	' This procedure lists all the members of a local group
	'
	Dim objNetwork
	Dim objGroup
	Dim objMember
	Dim strUser
	
	Set objGroup = GetObject("WinNT://" & strComputer & "/" & strGroup & ",group")
	If Err <> 0 Then
		Call LogData(1, "Error connecting to group: " & strGroup & " on computer: " & strComputer & vbCrLf & "Error Number: " & vbTab & Err.Number & vbCrLf & "Error Description: " & vbTab & Err.Description)
		Err.Clear
	End If
	For Each objMember In objGroup.Members
		strUser = objMember.Name
	Select Case strUser
		Case "Domain Admins"
		Case Else
			Call LogData(2,"Computer: " & strComputer & vbTab & "Found User: " & strUser)
			Call DelMembers(strComputer, strGroup, strUser)
	End Select
	Next
End Sub

Sub DelMembers(strComputer, strGroup, strUser)
	On Error Resume Next
	'
	' Deletes a user from a local computer group
	'
	Dim objGroup
	Dim objUser

	Set objGroup = GetObject("WinNT://" & strComputer & "/" & strGroup & ",group")
	If Err <> 0 Then
		Call LogData(1, "Error connecting to group: " & strGroup & " on computer: " & strComputer & vbCrLf & "Error Number: " & vbTab & Err.Number & vbCrLf & "Error Description: " & vbTab & Err.Description)
		Err.Clear
	End If
	
	Set objUser = GetObject("WinNT://" & strComputer & "/" & strUser & ",user")
	If Err <> 0 Then
		Call LogData(1, "Error connecting to user: " & strUser & " on computer: " & strComputer & vbCrLf & "Error Number: " & vbTab & Err.Number & vbCrLf & "Error Description: " & vbTab & Err.Description)
		Err.Clear
	End If
	
	objGroup.Remove(objUser.ADSPath)
	If Err <> 0 Then
		Call LogData(1, "Error removing user: " & strUser & " from group: " & strGroup & vbCrLf & "Error Number: " & vbTab & Err.Number & vbCrLf & "Error Description: " & vbTab & Err.Description)
		Err.Clear
	End If
	Call LogData(0, "Removed " & strUser & ", from " & strComputer)
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

company.com ScriptDetails(strComputer)
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
End company.com