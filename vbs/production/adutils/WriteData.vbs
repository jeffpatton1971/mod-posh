'call writedata("serialNumber","15YQMN1", "CN=e1005-pc45,OU=1005,OU=Eaton,OU=Labs,DC=soecs,DC=ku,DC=edu")
'call writedata("ipHostNumber","10.133.0.117", "CN=e1005-pc45,OU=1005,OU=Eaton,OU=Labs,DC=soecs,DC=ku,DC=edu")
'call writedata("macAddress","AA:BB:CC:DD:EE:FF", "CN=e1005-pc45,OU=1005,OU=Eaton,OU=Labs,DC=soecs,DC=ku,DC=edu")
Set objOU = GetObject("LDAP://CN=e1005-pc45,OU=1005,OU=Eaton,OU=Labs,DC=soecs,DC=ku,DC=edu")
Wscript.Echo objOU.Get("Name")
Wscript.Echo objOU.Get("description")
Wscript.Echo objOU.Get("macAddress")
Wscript.Echo objOU.Get("serialNumber")

Sub WriteData(strProperty, strValue, strADSPath)
	'
	' Update a single-value property of an object in AD
	'
	Dim objADObject
	
	Set objADObject = GetObject("LDAP://" & strADSPath)
	
		objADObject.Put strProperty , strValue
		'objADObject.PutEx 3, strProperty, Array(strValue)
		objADObject.SetInfo

End Sub
