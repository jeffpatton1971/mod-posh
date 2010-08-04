Sub GetEvents(strComputer, strLogFile, intDays)
'
' This procedure returns events from the specified log
' from the provided computer.
'
' http://msdn.microsoft.com/en-us/library/aa394226(VS.85).aspx
'
	Set dtmStartDate = CreateObject("WbemScripting.SWbemDateTime")
	Set dtmEndDate = CreateObject("WbemScripting.SWbemDateTime")

	intDays  = (intDays - intDays) - intDays
	dtmStartDate.SetVarDate now(), True
	dtmEndDate.SetVarDate DateAdd("d", intDays, now()), True

	Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
	Set colLoggedEvents = objWMIService.ExecQuery("Select * from Win32_NTLogEvent Where TimeWritten >= '" _ 
	    		      				      & dtmEndDate.Value & "' and TimeWritten < '" & dtmStartDate.Value _ 
							      & "' And Logfile = '" & strLogFile & "'")

	For Each objEvent in colLoggedEvents
	    Wscript.Echo "Logname: " & objEvent.LogFile
	    Wscript.Echo "EventId: " & objEvent.EventCode
	    Wscript.Echo "Level: " & objEvent.Type
	    Wscript.Echo "User: " & objEvent.User
	    Wscript.Echo "Logged: " & objEvent.TimeWritten
	    Wscript.Echo "Message: " & vbCrLf & objEvent.Message
	Next
End Sub