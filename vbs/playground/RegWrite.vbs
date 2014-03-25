Call QueryAD("SELECT DistinguishedName ,Name FROM 'LDAP://OU=Labs,DC=company,DC=com' WHERE objectClass = 'computer'")

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
		Call AddVar("UGS_LICENSE_BUNDLE", "ACD", "REG_SZ")
		objRecordSet.MoveNext
	Loop
End Sub

Sub AddVar(strVariable, strVariableValue, strVariableType)
'
' This procedure adds environment variables reliably
'
' http://msdn.microsoft.com/en-us/library/yfdfhz1b(VS.85).aspx
'
Dim WshShell
Set WshShell = WScript.CreateObject("WScript.Shell")

	WshShell.RegWrite"HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\" & strVariable, strVariableValue, strVariableType
	If Err <> 0 Then Call LogData(1, "Unable to add " & strvariable & " = " & strVariableValue)

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

