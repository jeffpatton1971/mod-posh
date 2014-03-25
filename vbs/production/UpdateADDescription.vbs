Option Explicit
On Error Resume Next

Const ADS_SCOPE_SUBTREE = 2
Dim objConnection
Dim objCommand
Dim objRecordSet
Dim intOnline
Dim intOffline
Dim strLDAPURI

	strLDAPURI = "LDAP://OU=Labs,DC=company,DC=com"
	Call LogData(4, "Update AD Computer.Description started: " & Now())

Set objConnection = CreateObject("ADODB.Connection")
Set objCommand =   CreateObject("ADODB.Command")
objConnection.Provider = "ADsDSOObject"
objConnection.Open "Active Directory Provider"

Set objCOmmand.ActiveConnection = objConnection
objCommand.CommandText = "Select DistinguishedName ,Name from '" & strLDAPURI & "' Where objectClass='computer'"  
objCommand.Properties("Page Size") = 1000
objCommand.Properties("Searchscope") = ADS_SCOPE_SUBTREE 
Set objRecordSet = objCommand.Execute
objRecordSet.MoveFirst

Do 
	If ComputerOnline(objRecordSet.Fields("Name").Value) = vbTrue Then
		Call BuildDescription(objRecordSet.Fields("Name").Value, objRecordSet.Fields("DistinguishedName").Value)
		intOnline = intOnline + 1
	Else
		Call ComputerOffline(objRecordSet.Fields("Name").Value, objRecordSet.Fields("DistinguishedName").Value)
		intOffline = intOffline + 1
	End If

	objRecordSet.MoveNext

Loop Until objRecordSet.EOF

	Call LogData(4, "Update AD Computer.Description completed: " & Now() & vbCrLf & "Total Online : " & intOnline & vbCrLf & "Total Offline: " & intOffline)

'
' Is computer online?
' 
' Attempt WMI Connection if it fails ComputerOnline = False
'
Function ComputerOnline(strComputer)
Dim blnOnline
Dim objWMIService
Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\CIMV2")
	If Err <> 0 Then
		blnOnline = vbFalse
		Wscript.Echo strComputer
	Else
		blnOnline = vbTrue
	End If

ComputerOnline = blnOnline
End Function

'
' Get username of currently logged on user
'
Function GetUser(strComputer)
Dim strUserName
Dim objWMIService
Dim colItems
Dim objItem

Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\CIMV2") 
Set colItems = objWMIService.ExecQuery("SELECT * FROM Win32_ComputerSystem",,48) 

	For Each objItem in colItems
		If IsNull(objItem.UserName) Then
			strUserName = "FREE"
		Else
			strUserName = objItem.UserName
		End If
	Next

GetUser = strUserName
End Function

'
' Get serial number from the BIOS
'
Function GetSerial(strComputer)
Dim strSerial
Dim objWMIService
Dim colItems
Dim objItem

Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\CIMV2") 
Set colItems = objWMIService.ExecQuery("SELECT * FROM Win32_BIOS",,48) 

	For Each objItem in colItems 
		strSerial = objItem.SerialNumber
	Next

GetSerial = strSerial
End Function

'
' Get MAC Address of the computer
Function GetMac(strComputer)
Dim strMacAddress
Dim objWMIService
Dim colItems
Dim objItem
Dim strIPAddress

Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\CIMV2") 
Set colItems = objWMIService.ExecQuery("SELECT * FROM Win32_NetworkAdapterConfiguration",,48) 

	For Each objItem in colItems
		If isNull(objItem.IPAddress) Then
		Else
		strIPAddress = Join(objItem.IPAddress, ",")
		If InStr(strIPAddress, "10.133") Then
			If IsNull(objItem.MACAddress) Then
			Else
			strMacAddress = objItem.MACAddress
			Exit For
			End If
		End If
	End If
	Next

GetMac = strMacAddress
End Function

'
' Build the description value
'
Sub BuildDescription(strComputer, strADSPath)

	Call WriteData(GetUser(strComputer) & "," & GetSerial(strComputer) & "," & GetMac(strComputer), strADSPath)

End Sub

'
' Update the description property of the computer in AD
'
Sub WriteData(strDescription, strADSPath)
Dim objComputer

Set objComputer = GetObject("LDAP://" & strADSPath)

	objComputer.Put "Description" , strDescription
	objComputer.SetInfo

End Sub

'
' Handle an offline computer
' 
' http://www.microsoft.com/technet/scriptcenter/resources/qanda/jan05/hey0121.mspx
'
Sub ComputerOffline(strComputer, strADSPath)
Dim strOldDescription
Dim strDescription
Dim arrDescription
Dim objComputer

Set objComputer = GetObject("LDAP://" & strADSPath)

	strOldDescription = objComputer.Get("Description")

	If strOldDescription = "" Then
		strDescription = "OFFLINE"
	Else
		arrDescription = Split(strOldDescription, ",")
		arrDescription(0) = "OFFLINE"
		strDescription = arrDescription(0) & "," & arrDescription(1) & "," & arrDescription(2)
	End If
	Call Logdata(2, strComputer & " " & strDescription)
	Call WriteData(strDescription, strADSPath)

End Sub

'
' Write data to application log
' 
' http://www.microsoft.com/technet/scriptcenter/guide/default.mspx?mfr=true
'
' Event Codes
' 	0 = Success
'	1 = Error
'	2 = Warning
'	4 = Information
Sub LogData(intCode, strMessage)
Dim objShell

On Error Resume Next
Set objShell = Wscript.CreateObject("Wscript.Shell")

	objShell.LogEvent intCode, strMessage

End Sub