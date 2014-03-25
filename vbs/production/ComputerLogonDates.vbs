'
' Computer Logon Dates
'
' December 6, 2010: Jeff Patton
'
' This script queries AD and returns computer objects.  The intent of
' the script is to provide a list of computers that have not updated
' their account in over 90 days. This could mean that the object is no
' longer associated with an actual computer, and the object was not
' deleted. The properties we are asking for are:
'
' Name: The name of the object
' distinguishedName: The proper name of the object in AD
' pwdLastSet: The last time this object was updated
'
' pwdLastSet is interesting for us because this gives an indication
' of how old or stale a give computer object is. 
'
Dim strQuery
Dim strQyeryObjectClass
Dim strQueryLDAP
Dim strQueryVars
Dim objFSO
Dim objFile
Const ForReading = 1
Dim strComputerName
Dim dtmPasswordDate
Dim strComputerLocation

	strQueryObjectClass = "computer"
	strQueryLDAP = "LDAP://DC=soecs,DC=ku,DC=edu"
	strQueryVars = "Name,distinguishedName,pwdLastSet"
    strQuery = "SELECT " & strQueryVars & " FROM '" & strQueryLDAP & "' WHERE objectClass = '" & strQueryObjectClass & "'"

	Set objFSO = CreateObject("Scripting.FileSystemObject")
	Set objFile = objFSO.OpenTextFile("adutils\Integer8.txt", ForReading)
	Execute objFile.ReadAll()

	Call LogData(4, ScriptDetails(".") & vbCrLf & "Started: " & Now())
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
	Wscript.Echo "Computer Name" & "," & "Last Password Change" & "," & "AD Location"
	
		objRecordSet.MoveFirst
	
		Do Until objRecordSet.EOF
			'
			' If you are reporting information, row data goes inside the loop.
			'
			' If you are performing an action on the data returned a call
			' to your function/subroutine should be made here.
			'
			strComputerName = objRecordSet.Fields("Name")
			strComputerLocation = objRecordSet.Fields("distinguishedName")
			If (TypeName(objRecordSet.Fields("pwdLastSet").Value) = "Object") Then
				dtmPasswordDate = Integer8Date(objRecordSet.Fields("pwdLastSet").Value, TZBias)
			End If
			Wscript.Echo strComputerName & "," & dtmPasswordDate & "," & chr(34) & strComputerLocation & chr(34)
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