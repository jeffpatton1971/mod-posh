Const adOpenStatic = 3
Const adLockOptimistic = 3
Const adUseClient = 3
Set objConnection = CreateObject("ADODB.Connection")
Set objRecordset = CreateObject("ADODB.Recordset")
Set objRecordset1 = CreateObject("ADODB.Recordset")
objConnection.Open "DSN=NetworkInventory;"
objRecordset.CursorLocation = adUseClient
objRecordset.Open "SELECT * FROM Computers where computername='SOECS-ST-PATTON'" , objConnection,  adOpenStatic, adLockOptimistic

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