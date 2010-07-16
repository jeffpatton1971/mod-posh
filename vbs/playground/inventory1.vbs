Const adOpenStatic = 3
Const adLockOptimistic = 3
Const adUseClient = 3
Set objConnection = CreateObject("ADODB.Connection")
Set objRecordset1 = CreateObject("ADODB.Recordset")
objConnection.Open "DSN=NetworkInventory;"
objRecordset1.CursorLocation = adUseClient
objRecordset1.Open "SELECT * FROM Computers" , objConnection, _
    adOpenStatic, adLockOptimistic

Const ADS_SCOPE_SUBTREE = 2
Set objConnection = CreateObject("ADODB.Connection")
Set objCommand =   CreateObject("ADODB.Command")
objConnection.Provider = "ADsDSOObject"
objConnection.Open "Active Directory Provider"
Set objCommand.ActiveConnection = objConnection
objCommand.CommandText = _
    "SELECT Name, Location FROM 'LDAP://DC=company,DC=com' " _
        & "WHERE objectClass='computer'"
objCommand.Properties("Page Size") = 1000
objCommand.Properties("Timeout") = 30
objCommand.Properties("Searchscope") = ADS_SCOPE_SUBTREE
objCommand.Properties("Cache Results") = False
Set objRecordSet = objCommand.Execute
objRecordSet.MoveFirst
Do Until objRecordSet.EOF
	objRecordset1.AddNew	
	objRecordset1("ComputerName") =  objRecordSet.Fields("Name").Value
	objRecordSet.MoveNext
	objRecordset1.Update
Loop
objRecordset1.Close
objConnection.Close