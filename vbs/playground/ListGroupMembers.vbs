Option Explicit
'
' List Group Members
'
' This script will walk through AD looking for groups
' for each group it finds it will display a list of 
' group members.
'
' Optionally you can provide a user name as a filter
'
' June 12, 2009 * Jeff Patton

	Call QueryAD("SELECT distinguishedName FROM 'LDAP://OU=Security Groups,DC=company,DC=com' WHERE objectClass = 'group'")	

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
			Wscript.Echo GroupMembers(objRecordSet.Fields("distinguishedName")) ' , "auser")
			objRecordSet.MoveNext
		Loop
End Sub

Function GroupMembers(strADSPath) ' , strUserName)
	On Error Resume Next
	Dim objGroup
	Dim arrMemberOf
	Dim strMember
	'
	' This function returns a list of users belonging to a group
	' http://www.microsoft.com/technet/scriptcenter/scripts/ad/groups/adgpvb13.mspx?mfr=true
	'

	Set objGroup = GetObject("LDAP://" & strADSPath)
	If Err <> 0 Then Call LogData(1, "Error Number" & vbCrLf & Err.Number & vbCrLf & "Error Description" & vbCrLf & Err.Description)

	objGroup.GetInfo
	If Err <> 0 Then Call LogData(1, "Error Number" & vbCrLf & Err.Number & vbCrLf & "Error Description" & vbCrLf & Err.Description)

	arrMemberOf = objGroup.GetEx("member")

	WScript.Echo "Members:"
	For Each strMember in arrMemberOf
		WScript.echo strMember
	Next

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