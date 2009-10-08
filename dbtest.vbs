Const adOpenStatic = 3
Const adLockOptimistic = 3
Const adUseClient = 3
Set objConnection = CreateObject("ADODB.Connection")
Set objRecordset = CreateObject("ADODB.Recordset")
objConnection.Open "DSN=Inventory;"
objRecordset.CursorLocation = adUseClient
objRecordset.Open "SELECT * FROM Hardware" , objConnection, _
    adOpenStatic, adLockOptimistic
strComputer = "."
Set objWMIService = GetObject("winmgmts:" _
    & "{impersonationLevel=impersonate}!\\" & strComputer& "\root\cimv2")
Set colSoundCards = objWMIService.ExecQuery _
    ("SELECT * FROM Win32_SoundDevice")
For Each objSoundCard in colSoundCards
    objRecordset.AddNew
    objRecordset("ComputerName") = objSoundCard.SystemName
    objRecordset("Manufacturer") = objSoundCard.Manufacturer
    objRecordset("ProductName") = objSoundCard.ProductName
    objRecordset.Update
Next
objRecordset.Close
objConnection.Close
