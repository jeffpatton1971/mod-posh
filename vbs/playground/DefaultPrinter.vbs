'
' Sample Script
'
' This script contains the basic logging information that I use everywhere
'
	Call LogData(4, ScriptDetails(".") & vbCrLf & "Started: " & Now())
	Call SetDefaultPrinter(WScript.Arguments.Item(0))
	Call LogData(4, ScriptDetails(".") & vbCrLf & "Finished: " & Now())

Sub SetDefaultPrinter(strPrinterShare)
	'
	' Set Default Printers
	' This script is based on the one found at the following URL:
	' http://madisonengineer.blogspot.com/2009/10/deploying-printers-via-group-policy.html
	'
	On Error Resume Next
	Dim WshNetwork
	
	Wscript.Sleep 30000
	Set WshNetwork = CreateObject("Wscript.Network")
	Call LogData(4, "Setting your default printer connection to: " & strPrinterShare)
	WshNetwork.SetDefaultPrinter strPrinterShare
	If Err <> 0 Then
		Call LogData(1, "Unable to set default printer connection to: " & strPrinterShare & vbCrLf & Err.Number & vbCrLf & Err.Description)
		Err. Clear
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