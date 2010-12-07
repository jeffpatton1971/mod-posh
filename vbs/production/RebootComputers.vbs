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
Dim strQuery
Dim strQyeryObjectClass
Dim strQueryLDAP
Dim strQueryVars
Dim strShutdownCMD
Dim strShutdownMessage
Dim objShell

	If Wscript.Arguments.Count = 3 Then
		Set colNamedArguments = Wscript.Arguments.Named
		
		strQueryObjectClass = colNamedArguments.Item("objectClass")
		strQueryLDAP = colNamedArguments.Item("ldapURI")
		strQueryVars = colNamedArguments.Item("queryVars")
		strQuery = "SELECT " & strQueryVars & " FROM '" & strQueryLDAP & "' WHERE objectClass = '" & strQueryObjectClass & "'"
	Else
		Wscript.Echo "Usage: CScript.exe RebootComputers.vbs /ldapURI:LDAP://OU=Workstations,DC=company,DC=com /objectClass:computer /queryVars:Name"
		Wscript.Quit
	End If

	strShutdownMessage = "This computer will reboot within the next 2 minutes for weekly maintenance, please save all work."

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
			intReturnCode = objShell.Run(strShutdownCMD,1,vbTrue)
			Select Case intReturnCode
				Case 0
					Call LogData(0, "The following command sucessfully executed." & vbCrLf & strShutdownCMD)
				Case 1707
					Call LogData(1, "Unable to connect to \\" & objRecordSet.Fields("Name") & vbCrLf & "The network address is invalid.")
				Case Else
					Call LogData(1, "Exit code, " & intReturnCode & " was returned from the command. List of exit codes available at http://patton-tech.com/files/WindowsErrorAndExitCodes.csv")
			End Select
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