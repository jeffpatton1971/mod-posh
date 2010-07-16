Option Explicit
On Error Resume Next

Dim strQuery
Dim strPropertyList
Dim strLDAPURL
Dim strObjectClass
Dim intOnline
Dim intOffline

strPropertyList = "name"
strLDAPURL = "LDAP://OU=Labs, DC=company,DC=com"
strObjectClass = "computer"
strQuery = "SELECT " & strPropertyList & " FROM '" & strLDAPURL & "' WHERE objectClass = '" & strObjectClass & "'"

Call LogData(4, ScriptDetails(".") & vbCrLf & "Started: " & Now())
Call QueryAD(strQuery)
Call LogData(4, ScriptDetails(".") & vbCrLf & "Finished: " & Now() & vbCrLf & intOnline + intOffline & " computers found." & vbCrLf & intOnline & " computers were online and modified." & vbCrLf & intOffline & " computers were offline and not modified.")

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
		If ComputerOnline(objRecordSet.Fields("name")) = vbTrue Then
			Call DelRegKey("SOFTWARE\WIBU-SYSTEMS\WIBU-KEY\Network\03.00\WkLanAccess\", objRecordSet.Fields("name"))
			Call AddRegKey("SOFTWARE\WIBU-SYSTEMS\WIBU-KEY\Network\03.00\WkLanAccess\", objRecordSet.Fields("name"))
			Call AddRegVal("SOFTWARE\WIBU-SYSTEMS\WIBU-KEY\Network\03.00\WkLanAccess\", "Server1", "license.soecs.ku.edu", objRecordSet.Fields("name"))
			Call AddRegVal("SOFTWARE\WIBU-SYSTEMS\WIBU-KEY\Network\03.00\WkLanAccess\", "Server2", "ecs-licenser.soecs.ku.edu", objRecordSet.Fields("name"))
			intOnline = intOnline + 1
		Else
			Call LogData(1, objRecordSet.Fields("name") & ": OFFLINE" & vbCrLf & "Script did not run, please run manually")
			intOffline = intOffline + 1
		End If
		objRecordSet.MoveNext
	Loop
End Sub

company.com ComputerOnline(strComputer)
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

ComputerOnline = blnOnline
End company.com

Sub DelRegKey(strRegistry, strComputer)
Const HKEY_LOCAL_MACHINE = &H80000002
Dim objRegistry
 
Set objRegistry=GetObject("winmgmts:\\" & strComputer & "\root\default:StdRegProv")

objRegistry.DeleteKey HKEY_LOCAL_MACHINE, strRegistry
End Sub

Sub AddRegVal(strRegistry, strValueName, szValue, strComputer)
Const HKEY_LOCAL_MACHINE = &H80000002
Dim objRegistry

Set objRegistry = GetObject("winmgmts:\\" & strComputer & "\root\default:StdRegProv")

objRegistry.SetStringValue HKEY_LOCAL_MACHINE, strRegistry, strValueName, szValue
End Sub

Sub AddRegKey(strRegistry, strComputer)
Const HKEY_LOCAL_MACHINE = &H80000002
Dim objRegistry

Set objRegistry = GetObject("winmgmts:\\" & strComputer & "\root\default:StdRegProv")

objRegistry.CreateKey HKEY_LOCAL_MACHINE, strRegistry
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

company.com ScriptDetails(strComputer)
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
End company.com