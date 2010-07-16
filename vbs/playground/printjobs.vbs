Dim strComputer
Dim strMessage
Dim arrCol(5)
Dim arrMessage(5)
Dim strWhat
Dim strWho
Dim strWhere
Dim intHowMany

Set RegularExpressionObject = New RegExp

strComputer = "."

Set objWMIService = GetObject("winmgmts:" _
    & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")

Set colLoggedEvents = objWMIService.ExecQuery("Select * from Win32_NTLogEvent Where Logfile = 'System' and EventCode = '10'")

For Each objEvent in colLoggedEvents
'	wscript.echo objEvent.Message


    Wscript.Echo "Record Number: " & objEvent.RecordNumber
'    Wscript.Echo "Time Written: " & objEvent.TimeWritten
'    Wscript.Echo "User: " & objEvent.User
'wscript.quit
Next

