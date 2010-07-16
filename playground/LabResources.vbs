'
' Lab Resources
'
' This script outputs the amount of RAM (MB) and Drive C: Freespace (GB)
'
	Call LogData(4, ScriptDetails(".") & vbCrLf & "Started: " & Now())
	Call QueryAD("SELECT DistinguishedName ,Name FROM 'LDAP://OU=People,DC=soecs,DC=ku,DC=edu' WHERE objectClass = 'computer'")
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
	Dim strOUtput
	
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

		Wscript.Echo "Computer, RAM (MB), Drive (GB)"	
		Do Until objRecordSet.EOF
			'
			' Code to do whatever is needed
			'
			strOutput = objRecordSet.Fields("Name") & ".soecs.ku.edu"
			strOutput = strOutput &  "," & CheckRam(objRecordSet.Fields("Name") & ".soecs.ku.edu")
			strOutput = strOutput &  "," & CheckFreeSpace(objRecordSet.Fields("Name") & ".soecs.ku.edu", "C:")
			Wscript.Echo strOutput
			objRecordSet.MoveNext
		Loop
End Sub

Function CheckFreeSpace(strComputer, strDrive)
'
' Returns the approximate amount of free space on the given drive in GB
'
	Dim objWMIService
	Dim colItems
	Dim objItem
	Dim intFreeSpace
	Dim lngFreeSpace

	Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\CIMV2") 
	Set colItems = objWMIService.ExecQuery("SELECT * FROM Win32_LogicalDisk WHERE Name = '" & strDrive & "'",,48) 

	For Each objItem in colItems 
		intFreeSpace = Left(objItem.FreeSpace, Len(objItem.FreeSpace) - 9)
	Next

	CheckFreeSpace = intFreeSpace
End Function

Function CheckRam(strComputer)
'
' Returns the amount of installed RAM
'
	Dim objWMIService
	Dim colItems
	Dim objItem
	Dim intClientRAM

	Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\CIMV2") 
	Set colItems = objWMIService.ExecQuery("SELECT * FROM Win32_LogicalMemoryConfiguration",,48) 

	For Each objItem in colItems 
		intClientRAM = (objItem.TotalPhysicalMemory \1024)
	Next

	CheckRam = intClientRAM
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