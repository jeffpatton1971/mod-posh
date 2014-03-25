strComputer = "."

Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")

Set colPrinters = objWMIService.ExecQuery("Select * From Win32_Printer")

Wscript.Echo "Printer,Print Port,Driver"
For Each objPrinter in colPrinters
	wscript.echo objPrinter.Name & vbtab & objPrinter.PortName ' & "," & objPrinter.DriverName
Next