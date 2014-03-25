'
' LogBackup
'
' December 30, 2010: Jeff Patton
'
' This scripts collects the specified logs from each computer
' it finds and stores them in timestamped files, on the logfiles
' folder the remote computer. Once it backs them up, it clears the
' specified log.
'
' It then collects those files and uploads them to the fileserver.
'
' \\fs.soecs.ku.edu\world\admin\logfiles
'
Dim strQuery
Dim strQyeryObjectClass
Dim strQueryLDAP
Dim strQueryVars
Const ForReading = 1
	
	If Wscript.Arguments.Count = 1 Then
		Set colNamedArguments = Wscript.Arguments.Named
		
		strQueryLDAP = colNamedArguments.Item("ldapURI")
		strQueryObjectClass = ""
		strQueryVars = ""
		strQuery = "SELECT 'Name' FROM '" & strQueryLDAP & "' WHERE objectClass = 'computer'"
	Else
		Wscript.Echo "Usage: CScript.exe LogBackup.vbs /ldapURI:LDAP://OU=Workstations,DC=company,DC=com"
		Wscript.Quit
	End If

	Call LogData(4, ScriptDetails(".") & vbCrLf & "Started: " & Now())
	Call QueryAD(strQuery)
	Call LogData(4, ScriptDetails(".") & vbCrLf & "Finished: " & Now())

Sub BackupLog(strComputer, strLogFile, blnClear)
On Error Resume Next
	Dim objWMIService
	Dim colLogFiles
	Dim objLogFile
	Dim errBackupLog
	Dim objFSO
	Dim objFolder

	Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate,(backup)}!\\" & strComputer & "\root\cimv2")
	Set colLogFiles = objWMIService.ExecQuery("SELECT * FROM Win32_NTEventLogFile WHERE LogFileName='" & strLogFile & "'")
	
	Set objFSO = CreateObject("Scripting.FileSystemObject")
	If objFSO.FolderExists("\\" & strComputer & "\C$\LogFiles\") Then
	Else
		Set objFolder = objFSO.CreateFolder("\\" & strComputer & "\C$\LogFiles\")
		If Err <> 0 Then 
			Call LogData(1,"Error " & Err.Number & vbCrLf & Err.Description & vbCrLf & "Folder \\" & strComputer & "\C$\LogFiles\ could not be created.")
			Err.Clear
		End If
	End If
	For Each objLogfile in colLogFiles
		errBackupLog = objLogFile.BackupEventLog("C:\LogFiles\" & strComputer & "-" & strLogFile & "_" & TimeStamp & ".evt")
		If errBackupLog <> 0 Then
			Call LogData(1,"Error " & errBackupLog & vbCrLf & "The " & strLogFile & " log could not be backed up.")
		Else
			If blnClear = vbTrue Then 
				objLogFile.ClearEventLog()
			End If
		End If
	Next
End Sub

Sub LogShip(strDestinationPath)
	Dim objFSO
	Dim x

	Set objFSO = CreateObject("Scripting.FileSystemObject")
	x = objFSO.MoveFile("C:\LogFiles\*.evt" , strDestinationPath)
	wscript.echo x
End Sub

Function TimeStamp()
	Dim dtmMonth
	Dim dtmDay
	Dim dtmYear
	Dim dtmHour
	Dim dtmMinute
	Dim dtmSecond

	dtmMonth = Month(Now) 
	dtmDay = Day(Now)
	dtmYear = Year(Now)
	dtmHour = Hour(Now)
	dtmMinute = Minute(Now)
	dtmSecond = Second(Now)
	
	If dtmMonth = 1 Then dtmMonth = "0" & Month(Now)
	If dtmDay = 1 Then dtmDay = "0" & Day(Now)
	If dtmHour = 1 Then dtmHour = "0" & Hour(Now)
	If dtmMinute = 1 Then dtmMinute = "0" & Minute(Now)
	If dtmSecond = 1 Then dtmSecond = "0" & Second(Now)
	
	TimeStamp = dtmMonth & dtmDay & dtmYear & "-" & dtmHour & dtmMinute & dtmSecond
End Function

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
			Call BackupLog(objRecordSet.Fields("Name"), "Application", vbTrue)
			Call BackupLog(objRecordSet.Fields("Name"), "Security", vbTrue)
			Call BackupLog(objRecordSet.Fields("Name"), "System", vbTrue)
			Call LogShip("\\fs.soecs.ku.edu\world\ECS\Admin\ServerLogs")
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