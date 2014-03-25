'
' SecurityLogParse.vbs
'
' This script queries the AD for a list of computers
' it then pulls specific event codes from the security log
'
' May 3, 2009: Jeff Patton
'
' Updated May 5, 2009 * Adjusted tabs
Option Explicit

Dim strPropertyList
Dim strLDAPURL
Dim strObjectClass
Dim strQuery

strPropertyList = "DistinguishedName ,Name"
strLDAPURL = "LDAP://OU=1005,OU=Eaton,OU=Labs,DC=company,DC=com"
strObjectClass = "computer"
strQuery = "SELECT " & strPropertyList & " FROM '" & strLDAPURL & "' WHERE objectClass = '" & strObjectClass & "'"

	Call QueryAD(strQuery)

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
	
		objRecordSet.MoveFirst
	
		Do Until objRecordSet.EOF
			Call SecLog(objRecordSet.Fields("Name"))
			objRecordSet.MoveNext
		Loop
End Sub

Sub SecLog(strComputerName)
	Dim eventMessage
	Dim objWMIService
	Dim colLoggedEvents
	Dim arr
	Dim finalArr
	Dim dtmDate
	Dim objEvent
	Dim strDomain
	Dim strUser
	
	Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate,(Security)}!\\" & strComputerName & ".soecs.ku.edu\root\cimv2")
	Set colLoggedEvents = objWMIService.ExecQuery("Select * FROM Win32_NTLogEvent WHERE Logfile = 'Security' AND EventType = 4 AND EventCode = 528")
	
	strDomain = "HOME"
	
		For Each objEvent in colLoggedEvents
			eventMessage = Trim(objEvent.Message)
			arr = split(eventMessage, vbCrLf)
			eventMessage = join(arr, ":")
			finalArr = split(eventMessage, ":")
			dtmDate = Left(objEvent.TimeWritten,8)
	
			if ucase(replace(Trim(finalArr(7)),vbTab,"")) = strDomain  and replace(Trim(finalArr(13)),vbTab,"") = 2 And dtmDate > 20090421 Then
				strUser = replace(Trim(finalArr(4)),vbTab,"")
				'Wscript.Echo "Domain:" & replace(Trim(finalArr(7)),vbTab,"")
				Wscript.Echo strComputerName & ", " & strUser & ", " & dtmDate
			End If
		Next

End Sub