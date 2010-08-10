'
' Sample Script
'
' This script contains the basic logging information that I use everywhere
'
	Call LogData(4, ScriptDetails(".") & vbCrLf & "Started: " & Now())
	Call GetEvents(".", "System", 5)
	Call LogData(4, ScriptDetails(".") & vbCrLf & "Finished: " & Now())

Sub GetEvents(strComputer, strLogFile, intDays)
'
' This procedure returns events from the specified log
' from the provided computer.
'
' http://msdn.microsoft.com/en-us/library/aa394226(VS.85).aspx
'
	Dim dtmStartDate
	Dim dtmEndDate
	Dim dtmTimeWritten
	Dim dtmTempDate
	Dim objWMIService
	Dim colLoggedEvents
	Dim objEvent
	Dim arrValues(5)

	Set dtmStartDate = CreateObject("WbemScripting.SWbemDateTime")
	Set dtmEndDate = CreateObject("WbemScripting.SWbemDateTime")
	Set dtmTimeWritten = CreateObject("WbemScripting.SWbemDateTime")

	intDays  = (intDays - intDays) - intDays
	dtmStartDate.SetVarDate now(), True
	dtmEndDate.SetVarDate DateAdd("d", intDays, now()), True

	Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
	Set colLoggedEvents = objWMIService.ExecQuery("Select * from Win32_NTLogEvent Where TimeWritten >= '" _ 
	    		      				      & dtmEndDate.Value & "' and TimeWritten < '" & dtmStartDate.Value _ 
							      & "' And Logfile = '" & strLogFile & "'")

	For Each objEvent in colLoggedEvents
	    arrValues(0) = objEvent.LogFile
	    arrValues(1) = objEvent.EventCode
	    arrValues(2) = objEvent.Type
	    If isNull(objEvent.User) Then
	       arrValues(3) = ""
	    Else
	       arrValues(3) = objEvent.User
	    End If
	    dtmTimeWritten.Value = objEvent.TimeWritten
	    dtmTempDate = dtmTimeWritten.Year & "-"
	    If dtmTimeWritten.Month < 10 Then dtmTempDate = dtmTempDate & "0" & dtmTimeWritten.Month & "-"
	    If dtmTimeWritten.Day < 10 Then dtmTempDate = dtmTempDate & "0" & dtmTimeWritten.Day & " "
	    If dtmTimeWritten.Hoursm < 10 Then dtmTempDate = dtmTempDate & "0" & dtmTimeWritten.Hours & ":"
	    
	    arrValues(4) = dtmTimeWritten.Year & "-" & dtmTimeWritten.Month & "-" & dtmTimeWritten.Day & " " & dtmTimeWritten.Hours & ":" & dtmTimeWritten.Minutes & ":" & dtmTimeWritten.Seconds
	    arrValues(5) = objEvent.Message
	    For x = 0 to 5
	    	wscript.echo arrvalues(x)
	    Next
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
