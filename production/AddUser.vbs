'
' Sample Script
'
' This script contains the basic logging information that I use everywhere
'
	Call LogData(4, ScriptDetails(".") & vbCrLf & "Started: " & Now())
	Call AddUser
	Call LogData(4, ScriptDetails(".") & vbCrLf & "Finished: " & Now())

Sub AddUser
' Add a user to the local SAM Database and assign them to an existing group.
'
On Error Resume Next

Dim strUser
Dim strPassword
Dim strGroup
Dim strComputer
Dim objNetwork
Dim objComputer
Dim objUser
Dim objGroup

strUser = "Admin"
strPassword = "Pass12345"
strGroup = "Power Users"

Set objNetwork = CreateObject("Wscript.Network")
strComputer = objNetwork.ComputerName

Set objComputer = GetObject("WinNT://" & strComputer)
Set objUser = objComputer.Create("user", strUser)

	objUser.SetPassword strPassword

	objUser.SetInfo
	If Err <> 0 Then
		Call LogData(1, "Unable to create the user: " & strUser & vbCrLf & Err.Number & vbCrLf & Err.Description & vbCrLf & "Check that user exists.")
		Err.Clear
	Else
		Call LogData(0, "Created user: " & strUser)
	End If

Set objGroup = GetObject("WinNT://" & strComputer & "/" & strGroup)

	objGroup.Add(objUser.ADsPath)
	If Err <> 0 Then
		Call LogData(1, "Unable to add user to group: " & strGroup & vbCrLf & Err.Number & vbCrLf & Err.Description)
		Err.Clear
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