Wscript.Echo GetRunningProcesses(".")
Function GetRunningProcesses(strComputer)
'
' A function to return the number of processes
' running on the provided computer.
'

     Dim objWMIService
     Dim colItems
     Dim objItem
     Dim intProcesses

     Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\CIMV2")
     Set colItems = objWMIService.ExecQuery("SELECT Processes FROM Win32_PerfFormattedData_PerfOS_System",,48)

     For Each objItem In colItems
     	 intProcesses = objItem.Processes
     Next

     GetRunningProcesses = intProcesses     
End Function