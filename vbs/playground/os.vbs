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
Set colItems = objWMIService.ExecQuery("SELECT * FROM Win32_OperatingSystem",,48) 
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

Set colItems = objWMIService.ExecQuery("SELECT * FROM Win32_OperatingSystem",,48) 
For Each objItem in colItems 
    Wscript.Echo "Windows Directory: " & objItem.WindowsDirectory
    Wscript.Echo "System Directory: " & objItem.SystemDirectory
    Wscript.Echo "Boot Device: " & objItem.BootDevice
Next

    objRecordSet.MoveNext
Loop
objRecordset.Close
objConnection.Close