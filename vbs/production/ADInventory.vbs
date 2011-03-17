'
' AD Inventory Script
'
' December 21, 2010: Jeff Patton
'
' This script is a replacement of the current inventory 
' script. Hopefully script will work better than the
' previous one.
'
' In order for this script to work within your environment
' you will need to modify the variables below to suit
' your needs.
'
' strQueryLDAP: would be the LDAP connection string that 
' 		maps to your AD installation. NOTE LDAP
'		must be in ALL CAPS.
'
Dim strQuery
Dim strQyeryObjectClass
Dim strQueryLDAP
Dim strQueryVars
Dim strUsername
Dim strSerialnumber
Dim strMACAddress
Dim NoWMI
Dim Offline
Dim LocalAccount
Const ForReading = 1

	NoWMI = Array()
	Offline = Array()
	LocalAccount = Array()
	
	If Wscript.Arguments.Count = 1 Then
		Set colNamedArguments = Wscript.Arguments.Named
		
		strQueryLDAP = colNamedArguments.Item("ldapURI")
		strQuery = "SELECT 'Name,distinguishedName' FROM '" & strQueryLDAP & "' WHERE objectClass = 'computer'"
	Else
		Wscript.Echo "Usage: CScript.exe ADInventory.vbs /ldapURI:LDAP://OU=Workstations,DC=company,DC=com"
		Wscript.Quit
	End If


	Call LogData(4, ScriptDetails(".") & vbCrLf & "Started: " & Now())
	Set objFSO = CreateObject("Scripting.FileSystemObject")
	Set objFile = objFSO.OpenTextFile("wmiutils\WMIFunctions.txt", ForReading)
	Execute objFile.ReadAll()
	Set objFSO = CreateObject("Scripting.FileSystemObject")
	Set objFile = objFSO.OpenTextFile("adutils\WriteData.txt", ForReading)
	Execute objFile.ReadAll()
	Set objFSO = CreateObject("Scripting.FileSystemObject")
	Set objFile = objFSO.OpenTextFile("utils\Sendmail.txt", ForReading)
	Execute objFile.ReadAll()
	Call QueryAD(strQuery)
	Call LogData(4, ScriptDetails(".") & vbCrLf & "Finished: " & Now())

Sub QueryAD(strQuery)
	'On Error Resume Next
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
		strBody = "Script started at " & Now() & vbCrLf & "Updating " & strQuery & vbCrLf
		Do Until objRecordSet.EOF
			'
			' If you are reporting information, row data goes inside the loop.
			'
			' If you are performing an action on the data returned a call
			' to your function/subroutine should be made here.
			'
			strUsername = ""
			strSerialnumber = ""
			strMACAddress = ""
			If PingStatus(objRecordSet.Fields("Name")) = "Success" Then
				If WMIPing(objRecordSet.Fields("Name")) = vbTrue Then
					strUsername = GetWMIData(objRecordSet.Fields("Name"), "Win32_ComputerSystem", "UserName")
					If InStr(strUsername,objRecordSet.Fields("Name")) Then
						If Ubound(LocalAccount) = -1 Then	
							ReDim Preserve LocalAccount(Ubound(LocalACcount)+1)
							LocalAccount(Ubound(LocalACcount)) = objRecordSet.Fields("Name")
						Else
							ReDim Preserve LocalAccount(Ubound(LocalACcount)+1)
							LocalAccount(Ubound(LocalACcount)) = objRecordSet.Fields("Name")
						End If
					End If
					If IsNull(strUsername) Then strUsername = "Free"
					strSerialnumber = GetWMIData(objRecordSet.Fields("Name"), "Win32_BIOS", "SerialNumber")
					strMACAddress = GetMac(objRecordSet.Fields("Name"), "10.133")
					Call WriteData("macAddress", strMACAddress, objRecordSet.Fields("distinguishedName"))
					Call WriteData("serialNumber", strSerialnumber, objRecordSet.Fields("distinguishedName"))
					Call WriteData("description", strUsername, objRecordSet.Fields("distinguishedName"))
				Else
					If Ubound(NoWMI) = -1 Then
						ReDim Preserve NoWMI(Ubound(NoWMI)+1)
						NoWMI(Ubound(NoWMI)) = objRecordSet.Fields("Name")
					Else
						ReDim Preserve NoWMI(Ubound(NoWMI)+1)
						NoWMI(Ubound(NoWMI)) = objRecordSet.Fields("Name")
					End If
					Call WriteData("description", "WMI Error", objRecordSet.Fields("distinguishedName"))
				End If
			Else
				If Ubound(Offline) = -1 Then
					ReDim Preserve Offline(Ubound(Offline)+1)
					Offline(Ubound(Offline)) = objRecordSet.Fields("Name")
				Else
					ReDim Preserve Offline(Ubound(Offline)+1)
					Offline(Ubound(Offline)) = objRecordSet.Fields("Name")
				End If
				Call WriteData("description", "Offline", objRecordSet.Fields("distinguishedName"))
			End If
			objRecordSet.MoveNext
		Loop
		strBody = strBody & vbCrLf & "WMI Timeout: " & Ubound(NoWMI)+1 & vbCrLf
		For Each Item In NoWMI
			strBody = strBody & vbCrLf & Item
		Next
		strBody = strBody & vbCrLf & "Computer Offline: " & Ubound(Offline)+1 & vbCrLf
		For Each Item In Offline
			strBody = strBody & vbCrLf & Item
		Next
		strBody = strBody & vbCrLf & "Local Account: " & Ubound(LocalAccount)+1 & vbCrLf
		For Each Item In LocalAccount	
			strBody = strBody & vbCrLf & Item
		Next
		strBody = strBody & vbCrLf & "Script ended at " & Now()
		Call Sendmail("inventory@soecs.ku.edu", "logwatch@intranet.soecs.ku.edu", "AD Inventory for " & strQueryLDAP, strBody, "smtp.ku.edu", vbNo, strAuthUser, strAuthPass)
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

Function WMIPing(strComputer)
On Error Resume Next
	'
	' Is computer online?
	' 
	' Attempt WMI Connection if it fails ComputerOnline = False
	'
	Dim blnOnline
	Dim objWMIService
	
	Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\CIMV2")
		If Err <> 0 Then
			blnOnline = vbFalse
		Else
			blnOnline = vbTrue
		End If
	
	WMIPing = blnOnline
End Function