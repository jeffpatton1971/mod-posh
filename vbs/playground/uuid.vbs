'
' Print ComputerSystemProduct UUID
'
' This script will connect to a computer and return it's UUID
'
	Call LogData(4, ScriptDetails(".") & vbCrLf & "Started: " & Now())
	Call QueryAD("SELECT DistinguishedName ,Name FROM 'LDAP://DC=soecs,DC=ku,DC=edu' WHERE objectClass = 'computer'")
	Call LogData(4, ScriptDetails(".") & vbCrLf & "Finished: " & Now())

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
			Wscript.Echo objRecordSet.Fields("Name") & ": " & GetWMIData(objRecordSet.Fields("Name"),"Win32_ComputerSystemProduct","UUID")
			objRecordSet.MoveNext
		Loop
End Sub

Function GetWMIData(strComputer, WMIClass, WMIProperty)
	'
	' This function replaces more or less any WMI Call 
	' that returns a single value. You could potentially
	' tweak it to handle more complicated returns like
	' IPAddress.
	'
	' The function is passed three arguments:
	'     strComputer = Computer to run WMI call against
	'     WMIClass = The WMI Class that we're querying
	'     WMIProperty = The WMI property that we're looking for
	'
	Dim objWMIService
	Dim colItems
	Dim objItem
	Dim strReturnVal

	Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\CIMV2") 
		If Err <> 0 Then 
			Call HandleError(Err.Number, Err.Description)
		End If
	Set colItems = objWMIService.ExecQuery("SELECT " & WMIProperty & " FROM " & WMIClass,,48) 
		If Err <> 0 Then 
			Call HandleError(Err.Number, Err.Description)
		End If
	
	For Each objItem In colItems
		Select Case lcase(WMIProperty)
			Case "caption"
				strReturnVal = objItem.Caption
			Case "csdversion"
				strReturnVal = objItem.CSDVersion
				If isNull(strReturnVal) Then strReturnVal = ""
			Case "serialnumber"
				strReturnVal = objItem.SerialNumber
			Case "dnshostname"
				strReturnVal = objItem.DNSHostName
			Case "csname"
				strReturnVal = objItem.CSName
			Case "uuid"
				strReturnVal = objItem.UUID
			Case Else
				Call LogData(1, "Unable to find " & WMIProperty & " in " & WMIClass & vbCrLf & "Please submit a ticket at http://code.patton-tech.com/winmon/newticket")
		End Select
	Next
	
	GetWMIData = strReturnVal
End Function

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

Function ScriptDetails(strComputer)
	'
	' Return information about who, what, where
	'
	On Error Resume Next
	Dim strScriptName
	Dim strScriptPath
	Dim strUserName
	Dim objWMIService
	Dim colProcesslist
	Dim objProcess
	Dim colProperties
	Dim strNameOfUser
	Dim struserDomain
	
	strScriptName = Wscript.ScriptName
	strScriptPath = Wscript.ScriptFullName
	
	Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")
	Set colProcessList = objWMIService.ExecQuery("Select * from Win32_Process Where Name = 'cscript.exe' or Name = 'wscript.exe'")
	
		For Each objProcess in colProcessList
			If InStr(objProcess.CommandLine, strScriptName) Then
				colProperties = objProcess.GetOwner(strNameOfUser,strUserDomain)
				If Err <> 0 Then
					Call LogData(1, "Error Number: " & vbTab & Err.Number & vbCrLf & "Error Description: " & vbTab & Err.Description)
					Err.Clear
					Exit For
				End If
				strUserName = strUserDomain & "\" & strNameOfUser
			End If
		Next
	
		ScriptDetails = "Script Name: " & strScriptName & vbCrLf & "Script Path: " & strScriptPath & vbCrLf & "Script User: " & strUserName
End Function
