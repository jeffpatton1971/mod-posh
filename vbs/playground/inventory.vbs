Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objFile = objFSO.CreateTextFile("C:\Documents and Settings\jeffpatton\My Documents\computers.txt")
'Set objFile = objFSO.OpenTextFile("C:\Documents and Settings\jeffpatton\My Documents\computers.txt", 2)

Const ADS_SCOPE_SUBTREE = 2
Set objConnection = CreateObject("ADODB.Connection")
Set objCommand =   CreateObject("ADODB.Command")
objConnection.Provider = "ADsDSOObject"
objConnection.Open "Active Directory Provider"
Set objCommand.ActiveConnection = objConnection
objCommand.CommandText = _
    "SELECT Name, Location FROM 'LDAP://DC=soecs,DC=ku,DC=edu' " _
        & "WHERE objectClass='computer'"
objCommand.Properties("Page Size") = 1000
objCommand.Properties("Timeout") = 30
objCommand.Properties("Searchscope") = ADS_SCOPE_SUBTREE
objCommand.Properties("Cache Results") = False
Set objRecordSet = objCommand.Execute
objRecordSet.MoveFirst
Do Until objRecordSet.EOF
    objFile.WriteLine ("Computer Name: " & objRecordSet.Fields("Name").Value)
    objRecordSet.MoveNext
Loop
objFile.Close