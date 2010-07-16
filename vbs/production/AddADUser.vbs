'
' Add AD User to local group
'
' This script contains the basic logging information that I use everywhere
'
' Created February 18, 2009: Jeff Patton
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
		'
		' Code to do whatever is needed
		'
		Call AddUser(objRecordSet.Fields("Name") & ".soecs.ku.edu", "tsquared", "Administrators")
		objRecordSet.MoveNext
	Loop
End Sub

Sub AddUser(strComputer, strUser, strGroup)
' Add a user to the local SAM Database and assign them to an existing group.
'
On Error Resume Next

Dim objComputer
Dim objUser
Dim objGroup

Set objGroup = GetObject("WinNT://" & strComputer & "/" & strGroup)
	If Err <> 0 Then Wscript.Echo("Unable to bind to computer: " & strComputer)
Set objUser = GetObject("WinNT://HOME/" & strUser)
	If Err <> 0 Then Wscript.Echo("Unable to bind to domain user: " & strUser)

	objGroup.Add(objUser.ADsPath)
	If Err <> 0 Then
		Call LogData(1, "Unable to add user to group: " & strGroup & vbCrLf & Err.Number & vbCrLf & Err.Description)
		Err.Clear
		Exit Sub
	Else
		Call LogData(0, "Added " & strUser & " to the following group: " & strGroup)
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