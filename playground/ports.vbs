'strComputer = "."

'Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
'Set colPorts =  objWMIService.ExecQuery("Select * from Win32_TCPIPPrinterPort")

' Wscript.Echo "@ echo off"
' Wscript.Echo "ipconfig /flushdns"

'For Each objPort in colPorts
'	Wscript.Echo "Date /T"
'	Wscript.Echo "Time /T"
'	Wscript.Echo "nslookup " & objPort.Name
'	Wscript.Echo "ping -n 1 " & objPort.Name

'	Wscript.Echo objPort.SystemName
'	Wscript.Echo objPort.Name
'Next

strComputer = "." 
Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\CIMV2") 
Set colItems = objWMIService.ExecQuery( _
    "SELECT * FROM Win32_Printer",,48) 
For Each objItem in colItems 
    Wscript.Echo "Name: " & objItem.Name
    Wscript.Echo "PortName: " & objItem.PortName
Next