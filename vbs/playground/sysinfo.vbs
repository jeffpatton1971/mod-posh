Const adOpenStatic = 3
Const adLockOptimistic = 3
Const adUseClient = 3
Set objConnection = CreateObject("ADODB.Connection")
Set objRecordset = CreateObject("ADODB.Recordset")
objConnection.Open "DSN=NetworkInventory;"
objRecordset.CursorLocation = adUseClient
objRecordset.Open "SELECT * FROM Computers where computername='SOECS-ST-PATTON'" , objConnection,  adOpenStatic, adLockOptimistic
objRecordSet.MoveFirst
Do While Not objRecordSet.EOF
    strComputer = rtrim(objRecordSet("ComputerName"))

Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\CIMV2") 
Set colItems = objWMIService.ExecQuery( _
    "SELECT * FROM Win32_OperatingSystem",,48) 
For Each objItem in colItems 
    Wscript.Echo "OS Name: " & objItem.Caption
    Wscript.Echo "Version: " & objItem.Version & " Service Pack " & objItem.ServicePackMajorVersion
Next

Set colItems = objWMIService.ExecQuery("SELECT * FROM Win32_ComputerSystem",,48) 
For Each objItem in colItems 
    Wscript.Echo "System Name: " & objItem.Name
    Wscript.Echo "System Manufacturer: " & objItem.Manufacturer
    WScript.Echo "System Model: " & objItem.Model
Next

Set colItems = objWMIService.ExecQuery("SELECT * FROM Win32_Processor",,48) 
For Each objItem in colItems 
    Wscript.Echo "Processor: " & objItem.Caption & " " & objItem.Manufacturer & " " & objItem.MaxClockSpeed
Next

Set colItems = objWMIService.ExecQuery("SELECT * FROM Win32_BIOS",,48) 
For Each objItem in colItems 
    Wscript.Echo "Bios Version: " & RTrim(objItem.Manufacturer) & " " & objItem.Caption
    WScript.Echo "SMBios Version: " & objItem.SMBIOSMajorVersion & "." & objItem.SMBIOSMinorVersion
Next

Set colItems = objWMIService.ExecQuery("SELECT * FROM Win32_OperatingSystem",,48) 
For Each objItem in colItems 
    Wscript.Echo "Windows Directory: " & objItem.WindowsDirectory
    Wscript.Echo "System Directory: " & objItem.SystemDirectory
    Wscript.Echo "Boot Device: " & objItem.BootDevice
Next

Set colItems = objWMIService.ExecQuery("SELECT * FROM Win32_LogicalMemoryConfiguration",,48) 
For Each objItem in colItems 
    Wscript.Echo "Total Physical Memory: " & round(( objItem.TotalPhysicalMemory/1024)) & "MB"
Next

Set colItems = objWMIService.ExecQuery("SELECT * FROM Win32_OperatingSystem",,48) 
For Each objItem in colItems 
    Wscript.Echo "Available Physical Memory: " & round(((objItem.FreePhysicalMemory/1024)/1024),2) & "GB"
    Wscript.Echo "Total Virtual Memory: " & round(((objItem.TotalVirtualMemorySize/1024)/1024),2) & "GB"
    Wscript.Echo "Available Virtual Memory: " & round(((objItem.FreeVirtualMemory/1024)/1024),2) & "GB"
Next

Set colItems = objWMIService.ExecQuery("SELECT * FROM Win32_LogicalMemoryConfiguration",,48) 
For Each objItem in colItems 
    Wscript.Echo "Page File Space: " & round(((objItem.TotalPageFileSpace/1024)/1024),2) & "GB"
Next

Set colItems = objWMIService.ExecQuery("SELECT * FROM Win32_PageFile",,48) 
For Each objItem in colItems 
    Wscript.Echo "Page File: " & objItem.Caption
Next

    objRecordSet.MoveNext
Loop
objRecordset.Close
objConnection.Close