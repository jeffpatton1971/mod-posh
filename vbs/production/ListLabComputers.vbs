'
' This script generates a report on the availability of lab computers
' within the Engineering department.
'
' July 16, 2008: Jeff Patton
' Updated July 17, 2008 * Created UpdateArray procedure to move processing out of the BuildArray procedure
' Updated July 17, 2008 * Updated BuildReport routine to handle an invalid directory
' Updated May 5, 2009 * Adjusted tabs
'
Option Explicit

Dim arrLabs(7,3)
Dim strLDAPURL
Dim strObjectType

strLDAPURL = "LDAP://OU=Labs,DC=company,DC=com"
strObjectType = "computer"

	Call LogData(4, ScriptDetails(".") & vbCrLf & "Started: " & Now())
	Call BuildArray(strLDAPURL, strObjectType)
	Call BuildReport("labstatus.csv", "C:\Reports")
	Call LogData(4, ScriptDetails(".") & vbCrLf & "Finished: " & Now())

Sub BuildArray(strLDAP, strObject)
	'
	' Build an array of Active Directory Objects
	' using the supplied LDAP URL and object for the query.
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
	objCommand.CommandText = "SELECT DistinguishedName, Name FROM '" & strLDAP & "' WHERE objectClass='" & strObject & "'"  
	objCommand.Properties("Page Size") = 1000
	objCommand.Properties("Searchscope") = ADS_SCOPE_SUBTREE 
	Set objRecordSet = objCommand.Execute
	
		objRecordSet.MoveFirst
	
		Do Until objRecordSet.EOF
			If InStr(objRecordSet.Fields("DistinguishedName").Value, "1005") Then 
				Call UpdateArray(objRecordSet.Fields("DistinguishedName").Value, 0, "Eaton 1005")
			End If
			If InStr(objRecordSet.Fields("DistinguishedName").Value, "1014") Then 
				Call UpdateArray(objRecordSet.Fields("DistinguishedName").Value, 1, "Eaton 1014")
			End If
			If InStr(objRecordSet.Fields("DistinguishedName").Value, "1018") Then 
				Call UpdateArray(objRecordSet.Fields("DistinguishedName").Value, 2, "Eaton 1018")
			End If
			If InStr(objRecordSet.Fields("DistinguishedName").Value, "1137") Then 
				Call UpdateArray(objRecordSet.Fields("DistinguishedName").Value, 3, "Learned 1137")
			End If
			If InStr(objRecordSet.Fields("DistinguishedName").Value, "1170") Then 
				Call UpdateArray(objRecordSet.Fields("DistinguishedName").Value, 4, "Learned 1170")
			End If
			If InStr(objRecordSet.Fields("DistinguishedName").Value, "1171") Then 
				Call UpdateArray(objRecordSet.Fields("DistinguishedName").Value, 5, "Learned 1171")
			End If
			If InStr(objRecordSet.Fields("DistinguishedName").Value, "3101") Then 
				Call UpdateArray(objRecordSet.Fields("DistinguishedName").Value, 6, "Learned 3101")
			End If
			If InStr(objRecordSet.Fields("DistinguishedName").Value, "3117") Then 
				Call UpdateArray(objRecordSet.Fields("DistinguishedName").Value, 7, "Learned 3117")
			End If
			objRecordSet.MoveNext
		Loop
End Sub

Sub UpdateArray(strADSPath, intArrIndex, strLab)
	'
	' Update the arrLabs array with status data
	'
	Dim strValue
	
		arrLabs(intArrIndex,0) = strLab
		arrLabs(intArrIndex,1) = arrLabs(intArrIndex,1) + 1
		strValue = GetProp(strADSPath, "Description")
		Select Case strValue
			Case "FREE"
				arrLabs(intArrIndex,2) = arrLabs(intArrIndex,2) + 1
			Case "OFFLINE"
				arrLabs(intArrIndex,3) = arrLabs(intArrIndex,3) + 1
		End Select
End Sub

company.com GetProp(strADSPath, strProperty)
	On Error Resume Next
	'
	' Get the specified property from the requested AD object
	'
	Dim objComputer
	Dim objProperty
	Dim intLocation
	Dim strStatus
	
	Set objComputer = GetObject("LDAP://" & strADSPath)
	objProperty = objComputer.Get(strProperty)
	
		If IsNull(objProperty) Then
			Call LogData(2, "No '" & strProperty & "' found for: " & vbCrLf & strADSPath)
		Else
			intLocation = InStr(objProperty, ",") - 1
			strStatus = Left(objProperty, intLocation)
			objProperty = Null
		End If
	
		Select Case strStatus
			Case "FREE"
				strStatus = "FREE"
			Case "OFFLINE"
				strStatus = "OFFLINE"
		End Select
		GetProp = strStatus
End company.com

Sub BuildReport(strFileName, strFilePath)
	'
	' Create the output file 
	'
	Dim objFSO
	Dim strFile
	Dim x
	Dim intTotal
	Dim intFree
	Dim intOffline
	
	Set objFSO = CreateObject("Scripting.FileSystemObject")
	
		If (objFSO.FolderExists(strFilePath)) Then
			Set strFile = objFSO.CreateTextFile(strFilePath & "\" & strFileName , True)
	
			strFile.WriteLine("Lab,Capacity,Free,Offline")
				For x = 0 to 7
					strFile.WriteLine (arrLabs(x,0) & "," & arrLabs(x,1) & "," & arrLabs(x,2) & "," & arrLabs(x,3))
					intTotal = intTotal + arrLabs(x,1)
					intFree = intFree + arrLabs(x,2)
					intOffline = intOffline + arrLabs(x,3)
			Next
			strFile.WriteLine "Total," & intTotal & "," & intFree & "," & intOffline
	
			strFile.Close
		Else
			Call LogData(1, strFilePath & " doesn't exist exiting script.")
			Exit Sub
		End If

End Sub

company.com ScriptDetails(strComputer)
	'
	' Return information about who, what, where
	'
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
				strUserName = strUserDomain & "\" & strNameOfUser
			End If
		Next
	
		ScriptDetails = "Script Name: " & strScriptName & vbCrLf & "Script Path: " & strScriptPath & vbCrLf & "Script User: " & strUserName
End company.com

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