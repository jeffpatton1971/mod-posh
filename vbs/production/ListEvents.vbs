'
' ListEvents Script
'
' December 29, 2010: Jeff Patton
'
' This script lists specific events for a computer from the 
' logfile given at the command line.
'
Dim strComputer
Dim strLogFile
Dim strEventCode
Const ForReading = 1
	
	If Wscript.Arguments.Count = 3 Then
		Set colNamedArguments = Wscript.Arguments.Named
		
		strComputer = colNamedArguments.Item("computer")
		strLogFile = colNamedArguments.Item("logfile")
		strEventCode = colNamedArguments.Item("eventcode")
	Else
		Wscript.Echo "Usage: CScript.exe ListEvents.vbs /computer:Desktop-PC01 /logfile:SYSTEM /eventcode:5722"
		Wscript.Quit
	End If

	Call LogData(4, ScriptDetails(".") & vbCrLf & "Started: " & Now())
	Call GetEvents(strComputer, strLogFile, strEventCode)
	Call LogData(4, ScriptDetails(".") & vbCrLf & "Finished: " & Now())

Sub GetEvents(strComputer, strLogFile, strEventCode)
'
' This procedure returns events from the specified log
' from the provided computer.
'
' http://msdn.microsoft.com/en-us/library/aa394226(VS.85).aspx
'
	Dim objWMIService
	Dim colLoggedEvents
	Dim objEvent
	Dim strLine
	Dim strMessage
	Dim objFSO
	Dim csvFile

	Set objFSO = CreateObject("Scripting.FileSystemObject")
	Set csvFile = objFSO.CreateTextFile(strComputer & "-" & strLogFile & ".csv", True)

	Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
	Set colLoggedEvents = objWMIService.ExecQuery("Select * from Win32_NTLogEvent Where EventCode = '" & strEventCode & "' And Logfile = '" & strLogFile & "'")

	Wscript.Echo "Running query: Select * from Win32_NTLogEvent Where EventCode = '" & strEventCode & "' And Logfile = '" & strLogFile & "'"
	csvFile.WriteLine("Logname" & "," & "EventId" & "," & "Level" & "," & "User" & "," & "Logged" & "," & "Message")
	For Each objEvent in colLoggedEvents
	    strLine = objEvent.LogFile & "," & _ 
					objEvent.EventCode & "," & _ 
					objEvent.Type & "," & _ 
					objEvent.User & "," & _ 
					objEvent.TimeWritten & ","
		If InStr(objEvent.Message, vbCrLf) Then
			'
			' This one line merits some explanation
			'
			' If the event message contains a linefeed, this one line of code
			' creates an array using the linefeed as the delimiter, it then
			' joins the newly created array MINUS the linefeeds.
			strMessage = Join(Split(objEvent.Message, vbCrLf))
		Else
			' If there are no linefeeds just get on with your life.
			strMessage = objEvent.Message
		End If
		
		strline = strLine & strMessage
		csvFile.WriteLine(strline)
		strLine = ""
	Next
	csvFile.Close
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