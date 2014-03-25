'
' ShowPrinters Script
'
' September 29, 2010: Jeff Patton
'
' This script is an example of how you might use the framework
' to return a list of printers on a remote computer.
'
' Syntax
'
' CScript.ece ShowPrinters.vbs /ldapURI:LDAP://OU=Workstations,DC=company,DC=com /objectClass:computer /queryVars:Name
'
'	ldapURI		: The LDAP URL where you want to query
'	objectClass	: The type of object you are looking for
'	queryVars	: The names of the attributes you wish to return
'
' Located in the WMIUtils folders is the ListPrinters.txt file. 
' This is a procedure that accepts a computername and then
' uses WMI to connect to the computer and query it for printers.
'
' The part I want to draw your attention to is the line below the
' first call to LogData. You will see we are creating a 
' FileSystemObject, and then reading the contents of the 
' ListPrinters.txt file into a variable. The last thing we do is
' execute that, which effectively loads it into memory.
'
' You should be able to include as many of them as you like, you 
' will need to make sure that you load them PRIOR to calling the
' stubbed code.
'
Dim strQuery
Dim strQyeryObjectClass
Dim strQueryLDAP
Dim strQueryVars
Dim colNamedArguments
Const ForReading = 1

	If Wscript.Arguments.Count = 3 Then
		Set colNamedArguments = Wscript.Arguments.Named
		
		strQueryObjectClass = colNamedArguments.Item("objectClass")
		strQueryLDAP = colNamedArguments.Item("ldapURI")
		strQueryVars = colNamedArguments.Item("queryVars")
		strQuery = "SELECT " & strQueryVars & " FROM '" & strQueryLDAP & "' WHERE objectClass = '" & strQueryObjectClass & "'"
	Else
		Wscript.Echo "Usage: CScript.exe ShowPrinters.vbs /ldapURI:LDAP://OU=Workstations,DC=company,DC=com /objectClass:computer /queryVars:Name"
		Wscript.Quit
	End If
	
	Call LogData(4, ScriptDetails(".") & vbCrLf & "Started: " & Now())
	Set objFSO = CreateObject("Scripting.FileSystemObject")
	Set objFile = objFSO.OpenTextFile("wmiutils\ListPrinters.txt", ForReading)
	Execute objFile.ReadAll()
	Call QueryAD(strQuery)
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
	
	'
	' If you are reporting information, column headers should be output above the loop.
	'
	
		objRecordSet.MoveFirst
	
		Do Until objRecordSet.EOF
			'
			' If you are reporting information, row data goes inside the loop.
			'
			' If you are performing an action on the data returned a call
			' to your function/subroutine should be made here.
			'
			Wscript.Echo objRecordSet.Fields("Name")
			Call ListPrinters(objRecordSet.Fields("Name"))
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