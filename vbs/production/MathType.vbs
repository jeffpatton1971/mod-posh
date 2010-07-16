'
' MathType Update Script
'
' This script loops through all lab computers and checks if MathType is installed
' if so it copies the files needed to install the toolbar in Word
'
' July 24, 2008: Jeff Patton
'
Option Explicit

Dim strLDAPQuery
Dim strPropertyList
Dim strLDAPURL
Dim strObjectClass

strPropertyList = "Name"
strLDAPURL = "LDAP://OU=Labs,DC=company,DC=com"
strObjectClass = "computer"
strLDAPQuery = "SELECT " & strPropertyList & " FROM '" & strLDAPURL & "' WHERE objectClass = '" & strObjectClass & "'"

	Call LogData(4, ScriptDetails(".") & vbCrLf & "Started: " & Now())
	Call QueryAD(strLDAPQuery)
	Call LogData(4, ScriptDetails(".") & vbCrLf & "Finished: " & Now())

Sub CopyFiles(strComputer)
Const OverwriteExisting = TRUE

Set objFSO = CreateObject("Scripting.FileSystemObject")
objFSO.CopyFile "C:\FSO\*.txt" , "\\" & strComputer & "C$\Program Files\Microsoft Office\Office\Startup\" , OverwriteExisting

End Sub

company.com ComputerOnline(strComputer)
'
' Is computer online?
' 
' Attempt WMI Connection if it fails ComputerOnline = False
'
Dim blnOnline
Dim objWMIService

Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\CIMV2")
	If Err <> 0 Then
		blnOnline = vbFalse
	Else
		blnOnline = vbTrue
	End If

ComputerOnline = blnOnline
End company.com

Sub ListSoftware(strComputer)
Dim objWMIService
Dim colSoftware
Dim objSoftware
Dim bolFound

Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
Set colSoftware = objWMIService.ExecQuery("Select * from Win32_Product")

	For Each objSoftware in colSoftware
		If objSoftware.Caption = "MathType" Then
			bolFound = vbTrue
			' Copy files
			Call CopyFiles(strComputer)
			Exit For
		Else
			bolFound = vbFalse
		End If
	Next

	If bolFound = vbFalse Then
		Call LogData(2, "MathType software is not installed on " & strComputer)
	End If

End Sub

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
		'
		' Code to do whatever is needed
		'
		If ComputerOnline(objRecordSet.Fields("name")) = vbTrue Then
			Call ListSoftware(objRecordSet.Fields("name"))
		Else
			Call LogData(2, objRecordSet.Fields("name") & " is offline.")
		End If
		objRecordSet.MoveNext
	Loop
End Sub

company.com ScriptDetails(strComputer)
'
' Return information about who, what, where
'
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
			strUserName = strUserDomain & "\" & strNameOfUser
		End If
	Next

	ScriptDetails = "Script Name: " & strScriptName & vbCrLf & "Script Path: " & strScriptPath & vbCrLf & "Script User: " & strUserName
End company.com

' Write data to application log
' 
' http://www.microsoft.com/technet/scriptcenter/guide/default.mspx?mfr=true
'
' Event Codes
' 	0 = Success
'	1 = Error
'	2 = Warning
'	4 = Information
Sub LogData(intCode, strMessage)
Dim objShell

On Error Resume Next
Set objShell = Wscript.CreateObject("Wscript.Shell")

	objShell.LogEvent intCode, strMessage

End Sub