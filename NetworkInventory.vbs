'OS
Const adOpenStatic = 3
Const adLockOptimistic = 3
Const adUseClient = 3
Set objConnection = CreateObject("ADODB.Connection")
Set objRecordset = CreateObject("ADODB.Recordset")
Set objRecordset1 = CreateObject("ADODB.Recordset")
objConnection.Open "DSN=NetworkInventory;"
objRecordset.CursorLocation = adUseClient
objRecordset.Open "SELECT * FROM Computers where computername='ENGR1'" , objConnection,  adOpenStatic, adLockOptimistic

objRecordset1.Open "SELECT * FROM OS" , objConnection, adOpenStatic, adLockOptimistic

objRecordSet.MoveFirst
Do While Not objRecordSet.EOF
    strComputer = rtrim(objRecordSet("ComputerName"))

Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\CIMV2") 
Set colItems = objWMIService.ExecQuery("SELECT * FROM Win32_OperatingSystem",,48) 
    objRecordset1.AddNew
    objRecordset1("ComputerName") = rtrim(objRecordSet("ComputerName"))
For Each objItem in colItems 
    objRecordset1("OSName") = objItem.Caption
    objRecordset1("OSVersion") = objItem.Version & " Service Pack " & objItem.ServicePackMajorVersion
Next

Set colItems = objWMIService.ExecQuery("SELECT * FROM Win32_ComputerSystem",,48) 
For Each objItem in colItems 
    objRecordset1("SystemManufacturer") = objItem.Manufacturer
    objRecordset1("SystemModel") = objItem.Model
Next

Set colItems = objWMIService.ExecQuery("SELECT * FROM Win32_OperatingSystem",,48) 
For Each objItem in colItems 
    objRecordset1("WindowsDirectory") = objItem.WindowsDirectory
    objRecordset1("SystemDirectory") = objItem.SystemDirectory
    objRecordset1("BootDevice") = objItem.BootDevice
Next

	objRecordset1.Update
    objRecordSet.MoveNext
Loop
objRecordset.Close
objRecordset1.Close
objConnection.Close

'Processor
Set objConnection = CreateObject("ADODB.Connection")
Set objRecordset = CreateObject("ADODB.Recordset")
Set objRecordset1 = CreateObject("ADODB.Recordset")
objConnection.Open "DSN=NetworkInventory;"
objRecordset.CursorLocation = adUseClient
objRecordset.Open "SELECT * FROM Computers where computername='ENGR1'" , objConnection,  adOpenStatic, adLockOptimistic

objRecordset1.Open "SELECT * FROM Processor" , objConnection, adOpenStatic, adLockOptimistic

objRecordSet.MoveFirst
Do While Not objRecordSet.EOF
    strComputer = rtrim(objRecordSet("ComputerName"))

Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\CIMV2") 
Set colItems = objWMIService.ExecQuery("SELECT * FROM Win32_Processor",,48) 
For Each objItem in colItems 
    objRecordset1.AddNew
    objRecordset1("ComputerName") = rtrim(objRecordSet("ComputerName"))
    objRecordset1("Processor") = objItem.Caption & " " & objItem.Manufacturer & " " & objItem.MaxClockSpeed
    objRecordset1.Update
Next

    objRecordSet.MoveNext
Loop
objRecordset.Close
objRecordset1.Close
objConnection.Close

'BIOS
Set objConnection = CreateObject("ADODB.Connection")
Set objRecordset = CreateObject("ADODB.Recordset")
Set objRecordset1 = CreateObject("ADODB.Recordset")
objConnection.Open "DSN=NetworkInventory;"
objRecordset.CursorLocation = adUseClient
objRecordset.Open "SELECT * FROM Computers where computername='ENGR1'" , objConnection,  adOpenStatic, adLockOptimistic

objRecordset1.Open "SELECT * FROM BIOS" , objConnection, adOpenStatic, adLockOptimistic

objRecordSet.MoveFirst
Do While Not objRecordSet.EOF
    strComputer = rtrim(objRecordSet("ComputerName"))

Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\CIMV2") 
Set colItems = objWMIService.ExecQuery("SELECT * FROM Win32_BIOS",,48) 
For Each objItem in colItems 
    objRecordset1.AddNew
    objRecordset1("ComputerName") = rtrim(objRecordSet("ComputerName"))
    objRecordset1("BiosVersion") = RTrim(objItem.Manufacturer) & " " & objItem.Caption
    objRecordset1("SMBiosVersion") = objItem.SMBIOSMajorVersion & "." & objItem.SMBIOSMinorVersion
Next
	objRecordset1.Update
    objRecordSet.MoveNext
Loop
objRecordset.Close
objRecordset1.Close
objConnection.Close

'Memory
Set objConnection = CreateObject("ADODB.Connection")
Set objRecordset = CreateObject("ADODB.Recordset")
Set objRecordset1 = CreateObject("ADODB.Recordset")
objConnection.Open "DSN=NetworkInventory;"
objRecordset.CursorLocation = adUseClient
objRecordset.Open "SELECT * FROM Computers where computername='ENGR1'" , objConnection,  adOpenStatic, adLockOptimistic

objRecordset1.Open "SELECT * FROM Memory" , objConnection, adOpenStatic, adLockOptimistic

objRecordSet.MoveFirst
Do While Not objRecordSet.EOF
    strComputer = rtrim(objRecordSet("ComputerName"))
    objRecordset1.AddNew
    objRecordset1("ComputerName") = rtrim(objRecordSet("ComputerName"))

Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\CIMV2") 

Set colItems = objWMIService.ExecQuery("SELECT * FROM Win32_LogicalMemoryConfiguration",,48) 
For Each objItem in colItems 
    objRecordset1("TotalPhysicalMemory") = round(( objItem.TotalPhysicalMemory/1024)) & "MB"
Next

Set colItems = objWMIService.ExecQuery("SELECT * FROM Win32_OperatingSystem",,48) 
For Each objItem in colItems 
    objRecordset1("AvailablePhysicalMemory") = round(((objItem.FreePhysicalMemory/1024)/1024),2) & "GB"
    objRecordset1("TotalVirtualMemory") = round(((objItem.TotalVirtualMemorySize/1024)/1024),2) & "GB"
    objRecordset1("AvailableVirtualMemory") = round(((objItem.FreeVirtualMemory/1024)/1024),2) & "GB"
Next

Set colItems = objWMIService.ExecQuery("SELECT * FROM Win32_LogicalMemoryConfiguration",,48) 
For Each objItem in colItems 
    objRecordset1("PageFileSpace") = round(((objItem.TotalPageFileSpace/1024)/1024),2) & "GB"
Next

Set colItems = objWMIService.ExecQuery("SELECT * FROM Win32_PageFile",,48) 
For Each objItem in colItems 
    objRecordset1("PageFile") = objItem.Caption
Next

    objRecordSet.MoveNext
Loop
objRecordset.Close
objRecordset1.Close
objConnection.Close