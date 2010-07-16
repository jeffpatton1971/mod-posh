'
' Enumerate all the groups in AD
'
Option Explicit

Dim strPropertyList
Dim strLDAPUrl
Dim strObjectClass
Dim strQuery

strPropertyList = "distinguishedName, Name"
strLDAPUrl = "LDAP://DC=company,DC=com"
strObjectClass = "group"

strQuery = "SELECT " & strPropertyList & " FROM '" & strLDAPUrl & "' WHERE objectClass = '" & strObjectClass & "'"

	Call LogData(4, ScriptDetails(".") & vbCrLf & "Started: " & Now())
	Call QueryAd(strQuery)
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
		Call OutputGroup(objRecordSet.Fields("distinguishedName").value, objRecordSet.Fields("Name").value)
		objRecordSet.MoveNext
	Loop
End Sub

Sub OutputGroup(strGroupDN, strGroupName)
Dim arrNames()
Dim intSize
Dim objGroup
Dim strUser
Dim objUser
Dim i
Dim j
Dim strHolder
Dim strName
Dim strData

intSize = 0

Set objGroup = GetObject("LDAP://" & strGroupDN)

For Each strUser in objGroup.Member
	Set objUser =  GetObject("LDAP://" & strUser)
	ReDim Preserve arrNames(intSize)
	arrNames(intSize) = objUser.CN
	intSize = intSize + 1
Next

For i = (UBound(arrNames) - 1) to 0 Step -1
	For j= 0 to i
		If UCase(arrNames(j)) > UCase(arrNames(j+1)) Then
			strHolder = arrNames(j+1)
			arrNames(j+1) = arrNames(j)
			arrNames(j) = strHolder
		End If
	Next
Next 

strData = strGroupName & vbCrLf

For Each strName in arrNames
	strData = strData & strName & vbCrLf
Next
End Sub

Sub BuildReport(strFileName, strFilePath, strData)
'
' Create the output file 
'
Dim objFSO
Dim strFile

Set objFSO = CreateObject("Scripting.FileSystemObject")

	If (objFSO.FolderExists(strFilePath)) Then
		Set strFile = objFSO.CreateTextFile(strFilePath & "\" & strFileName , True)

		strFile.WriteLine("Data to be written")
		strFile.Close
	Else
		Call LogData(1, strFilePath & " doesn't exist exiting script.")
		Exit Sub
	End If

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
