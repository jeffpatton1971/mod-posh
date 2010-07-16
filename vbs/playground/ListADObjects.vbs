Set colItems = GetObject("LDAP://OU=1,OU=Eaton,OU=People,DC=company,DC=com")

For Each objItem in colItems
	If objItem.UNCName <> "" Then
		wscript.Echo objItem.Name
		Wscript.Echo objItem.UNCName
	End If
Next
