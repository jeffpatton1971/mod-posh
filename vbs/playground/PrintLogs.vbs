Call GetPrintLogs(".")

Sub GetPrintLogs(strComputer)
'
' A function to return the number of processes
' running on the provided computer.
'

	 Dim objWMIService
	 Dim colItems
	 Dim objItem
	 
	 Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\CIMV2")
	 Set colItems = objWMIService.ExecQuery("SELECT * FROM Win32_NTLogEvent WHERE SourceName='Microsoft-Windows-PrintService'",,48)

	 For Each objItem In colItems
		 Wscript.Echo objItem
	 Next
End Sub