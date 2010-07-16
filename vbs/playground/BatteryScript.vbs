Dim intMiss
Dim intHit

Call QueryAD("SELECT DistinguishedName ,Name FROM 'LDAP://OU=Computers,OU=SOEDO,DC=company,DC=com' WHERE objectClass = 'computer'")
Wscript.Echo "Found   " & intHit
Wscript.Echo "Skipped " & intMiss
Wscript.Echo "Total   " & intHit + intMiss

Sub BatteryPresent(strComputer)
Dim objWMIService
Dim colItems
Dim objItem

Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\CIMV2") 
' Set colItems = objWMIService.ExecQuery("SELECT * FROM Win32_Battery",,48) 
Set colItems = objWMIService.ExecQuery("SELECT * FROMWin32_PortableBattery",,48)

	For Each objItem in colItems 
		If objItem.Caption = "" Then 
			intMiss = intMiss + 1
			Exit For
		Else
			Wscript.Echo strComputer & ": " & objItem.Caption
			intHit = intHit + 1
		End If
	Next
End Sub

Sub QueryAD(strQuery)
On Error Resume Next
'
' This procedure will loop through a recordset of objects
' returned from a query.
'
Const ADS_SCOPE_SUBTREE = 2
Dim objConnection
Dim objCommand
Dim objRecordset

Set objConnection = CreateObject("ADODB.Connection")
Set objCommand =   CreateObject("ADODB.Command")
objConnection.Provider = "ADsDSOObject"
objConnection.Open "Active Directory Provider"

Set objCOmmand.ActiveConnection = objConnection
objCommand.CommandText = strQuery
objCommand.Properties("Page Size") = 1000
objCommand.Properties("Searchscope") = ADS_SCOPE_SUBTREE 
Set objRecordSet = objCommand.Execute
If Err <> 0 Then Call LogData(1, "Unable to connect using the provided query: " & vbCrLf & strQuery)

	objRecordSet.MoveFirst

	Do Until objRecordSet.EOF
		'
		' Code to do whatever is needed
		'
		Call BatteryPresent(objRecordset.Fields("Name"))
		objRecordSet.MoveNext
	Loop
End Sub

Sub LogData(intCode, strMessage)
' Write data to application log
' 
' http://www.microsoft.com/technet/scriptcenter/guide/default.mspx?mfr=true
'
' Event Codes
' 	0 = Success
'	1 = Error
'	2 = Warning
'	4 = Information
Dim objShell

Set objShell = Wscript.CreateObject("Wscript.Shell")

	objShell.LogEvent intCode, strMessage

End Sub