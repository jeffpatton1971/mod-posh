'
' Clear Printers
'
' This script clears any network connected printers prior to GPO preferences being applied.
'
' January 13, 2010: Jeff Patton
'
	Call LogData(4, ScriptDetails(".") & vbCrLf & "Started: " & Now())
	Call DisconnectPrinters(".")
	Call LogData(4, ScriptDetails(".") & vbCrLf & "Finished: " & Now())

Sub DisconnectPrinters(strComputerName)
	' Disconnect network printers
	'
	' http://www.microsoft.com/technet/scriptcenter/resources/qanda/nov07/hey1102.mspx
	'
	Dim objWMIService
	Dim colInstalledPrinters
	Dim objPrinter
	
	On Error Resume Next
	Set objWMIService = GetObject("winmgmts:\\" & strComputerName & "\root\cimv2")
	Set colInstalledPrinters = objWMIService.ExecQuery("SELECT * FROM Win32_Printer WHERE Network = True")
	
		For Each objPrinter In colInstalledPrinters
			Call LogData(4, "Deleting printer connection: " & objPrinter.Name)
			objPrinter.Delete_
			If Err <> 0 Then 
				Call LogData(1, "Unable to delete " & objPrinter.Name & vbCrLf & Err.Number & vbCrLf & Err.Description)
				Err.Clear
				Exit For
			End If
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