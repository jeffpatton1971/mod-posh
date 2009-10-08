Const ADS_SCOPE_SUBTREE = 2
Set objConnection = CreateObject("ADODB.Connection")
Set objCommand =   CreateObject("ADODB.Command")
objConnection.Provider = "ADsDSOObject"
objConnection.Open "Active Directory Provider"

Set objCOmmand.ActiveConnection = objConnection
objCommand.CommandText = "Select DistinguishedName ,Name from 'LDAP://DC=soecs,DC=ku,DC=edu' Where objectClass='computer'"  
objCommand.Properties("Page Size") = 1000
objCommand.Properties("Searchscope") = ADS_SCOPE_SUBTREE 
Set objRecordSet = objCommand.Execute
objRecordSet.MoveFirst

Do 
	Wscript.Echo objRecordSet.Fields("Name").Value
	Wscript.Echo objRecordSet.Fields("Operating-System").Value
	objRecordSet.MoveNext
Loop Until objRecordSet.EOF