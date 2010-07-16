Option Explicit
'
' List Connected Users
'
' This script connects to the provided server and
' and returns a list of users connected to the given share.
'
' Need to pump in the AD stuff
'
' This script will accept a command-line argument similar to the following:
'	fs.soces.ku.edu research
'
' June 17, 2009: Jeff Patton
'
	Call LogData(4, ScriptDetails(".") & vbCrLf & "Started: " & Now())
	If Wscript.Arguments.Count = 0 Then
		Wscript.Echo "Please provide a target in the form of: 'LDAP://DC=company,DC=com'"
		Wscript.Quit
	Else
		' Call QueryAD("SELECT DistinguishedName ,Name FROM '" & Wscript.Arguments.Item(0) & "'")
		Call ListConnectedUsers(Wscript.Arguments.Item(0), Wscript.Arguments.Item(1))
	End If
	Call LogData(4, ScriptDetails(".") & vbCrLf & "Finished: " & Now())

Sub ListConnectedUsers(strComputer, strShare)
	'
	' This procedure returns the users connected to a given share
	'
	Dim objWMIService
	Dim colItems
	Dim objItem

	Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\CIMV2")
	Set colItems = objWMIService.ExecQuery("SELECT * FROM Win32_ServerConnection WHERE ShareName = '" & strShare & "'",,48)

	Wscript.Echo strComputer
	Wscript.Echo strShare

	For Each objItem in colItems 
		Wscript.Echo "UserName: " & objItem.UserName
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