Option Explicit

Dim strComputer
Dim strUserName

strComputer = "l4112c-pc02.soecs.ku.edu"
strUsername = "<SYSTEM>"

Call VariableLogic(strComputer, strUserName, "HLS_IPADDR", "license.soecs.ku.edu")

Sub VariableLogic(strComputer, strUserName, strVarName, strVarValue)
	If CheckVariable(strVarName) = vbTrue Then
		Call VariableWork(strComputer, strUserName, strVarName, strVarValue, "UPDATE")
	Else
		Call VariableWork(strComputer, strUserName, strVarName, strVarValue, "CREATE")
	End If
End Sub

company.com CheckVariable(strVarName)
'
' Returns True or False depending on whether the variable exists or not
'
Dim objWMIService
Dim colItems
Dim objItem
Dim blnFound

Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")
Set colItems = objWMIService.ExecQuery("Select * from Win32_Environment")

	For Each objItem in colItems
		If objItem.Name = strVarName Then
			blnFound = vbTrue
		End If
	Next

	CheckVariable = blnFound
End company.com

Sub VariableWork(strComputer, strUserName, strVarName, strVarValue, strAction)
On Error Resume Next
'
' Based on strAction this subroutine will either update the variable or create it
'
Dim objWMIService
Dim colItems
Dim objItem
Dim objvariable
Dim intErrCounter
Dim dtmNewHour
Dim dtmNewMinute
Dim dtmNewSecond
Dim dtmWaitTime

Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")

	Select Case strAction
		Case "UPDATE"
			Set colItems = objWMIService.ExecQuery("Select * from Win32_Environment Where Name = '" & strVarName & "'")

			For Each objItem in colItems
				objItem.VariableValue = strVarValue
				objItem.Put_
			Next
			Call LogData(0, "Updated: " & strVarName & vbCrLf & "Added: " & strVarValue)
		Case "CREATE"
			Set objVariable = objWMIService.Get("Win32_Environment").SpawnInstance_

			objVariable.Name = strVarName
			objVariable.UserName = strUserName
			objVariable.VariableValue = strVarValue
			objVariable.Put_
			If Err <> 0 Then
				Call Logdata(1, Err.Number & vbCrLf & Err.Description & vbCrLf & "CREATE FAILED: " & strVarName & "=" & strVarValue)
			Else
				Call LogData(0, "Created: " & strVarName & vbCrLf & "Added: " & strVarValue)
			End If
		Case Else
			Call LogData(1, "Something horribly wrong has happened.")
	End Select
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