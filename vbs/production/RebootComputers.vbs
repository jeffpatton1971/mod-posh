'
' Reboot Script
'
' December 7, 2010: Jeff Patton
'
' This script queries AD for a list of computers to reboot.
' For each computer returned from the query the shutdown command
' is executed.
'
' Command Line Options
' http://technet.microsoft.com/en-us/library/bb491003.aspx
'
' The options I'm using are as follows:
'
' -r Reboots after shutdown.
' -f Forces running applications to close
' -m Specifies the computer that you want to shut down.
' -t Sets the imer for sysmte shutdown in seconds (default 20).
' -c Specifies a message to be displayed in the message are of the 
'    System Shutdown window. You can use a maximum of 127 characters.
'
' NOTE
' In order for this script to work against Windows Vista and later
' the Remote Registry Service needs to be started. It is possible
' to start this service remotely, but if you have WMI connectivity
' issues, that may not work. My best suggestion is to have this 
' service enabled and started via Group or Local policy.
'
' Windows Exit and Error Codes List
' This list was copied down from the Symantec website, just in case
' at some point it goes away.
' The original can be found at:
' http://www.symantec.com/connect/articles/windows-system-error-codes-exit-codes-description
' My copy is located at:
' http://patton-tech.com/files/WindowsErrorAndExitCodes.csv
'
' WindowStyle Variable
' http://msdn.microsoft.com/en-us/library/d5fk67ky(v=vs.85).aspx
' 
' Defines the appearance of the program's window.
' 0 - Hides the window and activates another window.
' 1 - Activates and displays a window.
' 2 - Activates the window and displays it as a minimized window. 
' 3 - Activates the window and displays it as a maximized window. 
' 4 - Displays a window in its most recent size and position. The active window remains active.
' 5 - Activates the window and displays it in its current size and position.
' 6 - Minimizes the specified window and activates the next top-level window in the Z order.
' 7 - Displays the window as a minimized window.
' 8 - Displays the window in its current state.
' 9 - Activates and displays the window.
' 10 - Sets the show-state based on the state of the program that started the application.
'

Dim strQuery
Dim strQueryLDAP
Dim strShutdownCMD
Dim strShutdownMessage
Dim objShell
Dim strEmailList
Dim strEmailMessage
Dim strSubject
Dim intGoodCount
Dim intBadCount
Dim strGoodMessage
Dim strBadMessage
Dim intWindowStyle
Const ForReading = 1
	
	strEmailList = "user@company.com"
	intWindowStyle = 0
	
	If Wscript.Arguments.Count = 1 Then
		Set colNamedArguments = Wscript.Arguments.Named
		
		strQueryLDAP = colNamedArguments.Item("ldapURI")
		strQuery = "SELECT 'Name' FROM '" & strQueryLDAP & "' WHERE objectClass = 'computer'"
	Else
		Wscript.Echo "Usage: CScript.exe RebootComputers.vbs /ldapURI:LDAP://OU=Workstations,DC=company,DC=com"
		Wscript.Quit
	End If

	strShutdownMessage = "This computer will reboot within the next 2 minutes for weekly maintenance, please save all work."

	Call LogData(4,	ScriptDetails(".") & vbCrLf & "Started: " & Now())
	Set objFSO = CreateObject("Scripting.FileSystemObject")
	Set objFile = objFSO.OpenTextFile("utils\Sendmail.txt", ForReading)
	Execute objFile.ReadAll()
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
	strEmailMessage = "Searching for computers in: " & vbCrLf & vbTab & strQueryLDAP & vbCrLf & "Found " & objRecordSet.RecordCount & " computers." & vbCrLf
	
		objRecordSet.MoveFirst
	
		Do Until objRecordSet.EOF
			'
			' If you are reporting information, row data goes inside the loop.
			'
			' If you are performing an action on the data returned a call
			' to your function/subroutine should be made here.
			'
			strShutdownCMD = "shutdown -r -f -t 120 -m \\" & objRecordSet.Fields("Name") & " -c " & chr(34) & strShutdownMessage & chr(34)
			Set objShell = CreateObject("Wscript.Shell")
			intReturnCode = objShell.Run(strShutdownCMD,intWindowStyle,vbTrue)
			Select Case intReturnCode
				Case 0
					strGoodMessage = strGoodMessage & "The following command sucessfully executed." & vbCrLf & strShutdownCMD & vbCrLf
					intGoodCount = intGoodCount + 1
				Case 53,1707
					strBadMessage = strBadMessage & "Unable to connect to \\" & objRecordSet.Fields("Name") & ". The network address is invalid." & vbCrLf
					intBadCount = intBadCount + 1
				Case Else
					strBadMessage = strBadMessage & "Exit code " & intReturnCode & " was returned while attempting to reboot " & objRecordSet.Fields("Name") & vbCrLf
					intBadCount = intBadCount + 1
			End Select
			objRecordSet.MoveNext
		Loop
		strSubject = "Reboot Script Output"
		strEmailMessage = strEmailMessage & "Attempting to reboot " & intGoodCount + intBadCount & " computers. " & intGoodCount & " computers sucessfully rebooted. "
		strEmailMessage = strEmailMessage & intBadCount & " were unreachable due to power or network issues." & vbCrLf & vbCrLf
		strEmailMessage = strEmailMessage = "Successful reboots:" & vbCrLf & strGoodMessage & vbCrLf
		strEmailMessage = strEmailMessage = "Failed attempts:" & vbCrLf & strBadMessage
		Call Sendmail("user@company.com", strEmailList, strSubject, strEmailMessage, "smtp.company.com", vbFalse, "user", "password")
		Call LogData(4, strEmailMessage)
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