'
' OldComputers
'
' January 3, 2011: Jeff Patton
'
' This script searches through Active Directory looking
' for computers that have not been updated within the
' past 90 days.
'
' In order for this script to work within your environment
' you will need to modify the variables below to suit
' your needs.
'
' strQueryObjectClass: would be the object in AD you wish
' 		       to search for (eg: computer, user)
'
' strQueryLDAP: would be the LDAP connection string that 
' 		maps to your AD installation. NOTE LDAP
'		must be in ALL CAPS.
'
' strQueryVars: would be the attributes for the objectClass
' 		that you are returning from AD. If you don't
'		know what the property names are, run the
'		ListObjectAttribs.vbs script from the adutils
'		folder.
'
Dim strQuery
Dim strQyeryObjectClass
Dim strQueryLDAP
Dim strQueryVars
Const ForReading = 1
	
	If Wscript.Arguments.Count = 1 Then
		Set colNamedArguments = Wscript.Arguments.Named
		
		strQueryLDAP = colNamedArguments.Item("ldapURI")
		' strQueryObjectClass = ""
		' strQueryLDAP = ""
		strQueryVars = "Name,distinguishedName,USNCreated,USNChanged,WhenCreated,WhenChanged"
		strQuery = "SELECT '" & strQueryVars & "' FROM '" & strQueryLDAP & "' WHERE objectClass = 'computer'"
	Else
		Wscript.Echo "Usage: CScript.exe //NOLOGO OldComputers.vbs /ldapURI:LDAP://OU=Workstations,DC=company,DC=com > OldComputers.csv"
		Wscript.Quit
	End If

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
	Wscript.Echo "Computer,Location,USNCreated,USNChanged,DateCreated,DateChanged,DaysSinceUpdate"
	
		objRecordSet.MoveFirst
	
		Do Until objRecordSet.EOF
			'
			' If you are reporting information, row data goes inside the loop.
			'
			' If you are performing an action on the data returned a call
			' to your function/subroutine should be made here.
			'
			If Cint(DateDiff("d", objRecordSet.Fields("whenChanged"), Now())) > 90 Then
				If InStr(objRecordSet.Fields("distinguishedName"), "Servers") Then
				Else
					strComputer = objRecordSet.Fields("Name")
					strLocation = Chr(34) &  objRecordSet.Fields("distinguishedName") & Chr(34)
					Set objComputer = GetObject("LDAP://" & objRecordSet.Fields("distinguishedName"))

					Set objUSNCreated =  objComputer.Get("uSNCreated")
					dblUSNCreated = Abs(objUSNCreated.HighPart * 2^32 + objUSNCreated.LowPart)
					
					Set objUSNChanged = objComputer.Get("usnChanged")
					dblUSNChanged = Abs(objUSNChanged.HighPart * 2^32 + objUSNChanged.LowPart)

					dtmDateCreated = objRecordSet.Fields("whenCreated")
					dtmDateChanged = objRecordSet.Fields("whenChanged")
					intDateDiff =  DateDiff("d", objRecordSet.Fields("whenChanged"), Now())
					Wscript.Echo strComputer & "," & strLocation & "," & dblUSNCreated & "," & dblUSNChanged & "," & dtmDateCreated & "," & dtmDateChanged & "," & intDateDiff
				End If
			Else
			End If
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