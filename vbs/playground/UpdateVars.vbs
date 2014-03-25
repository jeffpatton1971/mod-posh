Option Explicit

	Call QueryAD("SELECT DistinguishedName ,Name FROM 'LDAP://OU=1014,OU=Eaton,OU=Labs,DC=company,DC=com' WHERE objectClass = 'computer'")	

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
Dim strUserName

strUsername = "<SYSTEM>"
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
		Call DeleteVar(objRecordSet.Fields("Name") & ".soecs.ku.edu", "ADSKFLEX_LICENSE_FILE")
		call CreateVar(objRecordSet.Fields("Name") & ".soecs.ku.edu", strUserName, "ADSKFLEX_LICENSE_FILE", "@license1.soecs.ku.edu")
'		Call VariableLogic(objRecordSet.Fields("Name") & ".soecs.ku.edu", strUserName, "LM_LICENSE_FILE", "1700@license1.soecs.ku.edu;27004@license.soecs.ku.edu;7166@license1.soecs.ku.edu;@license1.soecs.ku.edu;@license2.soecs.ku.edu;7241@soecs-licenser.soecs.ku.edu;27001@license1.soecs.ku.edu")
'		Call VariableLogic(objRecordSet.Fields("Name") & ".soecs.ku.edu", strUserName, "LSHOST", "license.soecs.ku.edu:license1.soecs.ku.edu:license2.soecs.ku.edu:license3.soecs.ku.edu")
'		Call VariableLogic(objRecordSet.Fields("Name") & ".soecs.ku.edu", strUserName, "UGS_LICENSE_SERVER", "28000@license1.soecs.ku.edu;28000@license2.soecs.ku.edu")
'		Call VariableLogic(objRecordSet.Fields("Name") & ".soecs.ku.edu", strUserName, "windir", "C:\WINDOWS")
'		Call VariableLogic(objRecordSet.Fields("Name") & ".soecs.ku.edu", strUserName, "_USTN_WORKSPACEROOT", "P:\KDOT_NS_Workspace\")
'		Call VariableLogic(objRecordSet.Fields("Name") & ".soecs.ku.edu", strUserName, "HLS_IPADDR", "license.soecs.ku.edu")
		objRecordSet.MoveNext
	Loop
End Sub



Sub VariableLogic(strComputer, strUserName, strVarName, strVarValue)

	If CheckVariable(strComputer, strVarName) = vbTrue Then
		Call DeleteVar(strComputer, strVarName)
		Call CreateVar(strComputer, strUserName, strVarName, strVarvalue)
	Else
		Call CreateVar(strComputer, strUserName, strVarName, strVarvalue)
	End If
End Sub

Function CheckVariable(strComputer, strVarName)
'
' Returns True or False depending on whether the variable exists or not
'
Dim objWMIService
Dim colItems
Dim objItem
Dim blnFound

Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")
Set colItems = objWMIService.ExecQuery("Select Name from Win32_Environment") ' Where Name = '" & strVarName & "'")

	For Each objItem in colItems
		If objItem.Name = strVarName Then
			blnFound = vbTrue
			Exit For
		Else
			blnFound = vbFalse
		End If
	Next

	CheckVariable = blnFound
Wscript.echo "Done Checking for " & strVarName & " on " & strComputer & " " & blnFound
End Function

Sub CreateVar(strComputer, strUserName, strVarName, strVarValue)
'On Error Resume Next

Dim objWMIService
Dim objvariable

Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")
Set objVariable = objWMIService.Get("Win32_Environment").SpawnInstance_

	objVariable.Name = strVarName
	objVariable.UserName = strUserName
	objVariable.VariableValue = strVarValue
	objVariable.Put_

	If Err <> 0 Then
		Call Logdata(1, Err.Number & vbCrLf & Err.Description & vbCrLf & "CREATE FAILED: " & strVarName & "=" & strVarValue & vbCrLf & " on " & strComputer)
	Else
		Call LogData(0, "Created: " & strVarName & " on " & strComputer & vbCrLf & "Added: " & strVarValue)
	End If
End Sub

Sub DeleteVar(strComputer, strVarName)
On Error Resume Next

Dim objWMIService
Dim colItems
Dim objItem

Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")
Set colItems = objWMIService.ExecQuery("Select * from Win32_Environment Where Name = '" & strVarName & "'")

	For Each objItem in colItems
		objItem.Delete_
		If Err <> 0 Then
			Call Logdata(1, Err.Number & vbCrLf & Err.Description & vbCrLf & "CREATE FAILED: " & strVarName & "=" & strVarValue & vbCrLf & " on " & strComputer)
		Else
			Call LogData(0, "Deleted: " & strVarName & " on " & strComputer)
		End If
	Next

End Sub

Sub LogData(intCode, strMessage)
'
' Write data to application log
' 
' http://www.microsoft.com/technet/scriptcenter/guide/default.mspx?mfr=true
'
' Event Codes
' 	0 = Success
'	1 = Error
'	2 = Warning
'	4 = Information
'
Dim objShell

On Error Resume Next
Set objShell = Wscript.CreateObject("Wscript.Shell")

	objShell.LogEvent intCode, strMessage

End Sub