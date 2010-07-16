'
' Unified Logon Script
'
' This script manages all "users" in the SOECS domain.
' 
' When this script runs against the computers in the Labs OU it does the following:
' 	Disconnects all printers
'	Unmounts all network drives
'	Discovers and maps all objects based on where they live in AD
'		(U: L: P: R: and lab printers)
'
' When this script runs against the computers in the People and Research OU it does the following:
'	Unmounts all network drives
'	Discovers and maps all objects based on where they live in AD
'		(U: L: P: R: and printers)
'
' This script should also handle special case OU's
'	(BERC KUTC EMGT)
'
' August 14, 2009: Jeff Patton
'
	Call LogData(4, ScriptDetails(".") & vbCrLf & "Started: " & Now())
	Call Main
	Call LogData(4, ScriptDetails(".") & vbCrLf & "Finished: " & Now())

Sub Main
	' This procedure is where everything gets kicked off from
	' it determines what to do based on the OU.
	Dim strOU

	strOU = RetrieveOU()
	If InStr(LCase(strOU), "labs") Then strOU = "labs"
	If InStr(LCase(strOU), "people") Then strOU = "people"
	If InStr(LCase(strOU), "research") Then strOU = "research"
	If InStr(LCase(strOU), "berc") Then strOU = "berc"
	If InStr(LCase(strOU), "kutc") Then strOU = "kutc"
	If InStr(LCase(strOU), "emgt") Then strOU = "emgt"

	Call LogData(4, "Script running against OU: " & strOU)

	Select Case strOU
		Case "labs"
			Call DisconnectPrinters
			Call DisconnectDrives
			Call BuildOUs(RetrieveOU)
			Call DisplayMessage
		Case "people"
			Call DisconnectDrives
			Call BuildOUs(RetrieveOU)
			Call DisplayMessage			
		Case "research"
			Call DisconnectDrives
			Call BuildOUs(RetrieveOU)
			Call DisplayMessage
		Case "berc"
		Case "kutc"
		Case "emgt"
		Case Else
			Call LogData(1, "Something tragic happened you should never see this.")
	End Select

End Sub
'
' Below are procedures and company.coms required by this script.
'
Sub DisconnectPrinters
	' Disconnect network printers
	'
	' http://www.microsoft.com/technet/scriptcenter/resources/qanda/nov07/hey1102.mspx
	'
	Dim objWMIService
	Dim colInstalledPrinters
	Dim objPrinter
	
	On Error Resume Next
	Set objWMIService = GetObject("winmgmts:\\" & strComputerName & "\root\cimv2")
	Set colInstalledPrinters = objWMIService.ExecQuery("SELECT * FROM Win32_Printer WHERE Network = True")
	
		For Each objPrinter In colInstalledPrinters
			objPrinter.Delete_
		Next

End Sub

Sub DisconnectDrives
	Dim objNetwork
	Dim colDrives
	Dim i
	
	On Error Resume Next
	Set objNetwork = CreateObject("Wscript.Network")
	Set colDrives = objNetwork.EnumNetworkDrives
	
		For i = 0 to (colDrives.Count -1) Step 2
			objNetwork.RemoveNetworkDrive colDrives.Item(i)
		Next

End Sub
'
' The next four procedures are where the magic happens.
'
' The BuildOUs procedure parses the LDAP URL returned by RetrieveOU,
' then it calls DiscoverObjects passing in the LDAP URL of where it currently is looking.
' The DiscoverOBjects procedure then looks at each object in the OU to see if there is a
' a UNCName property. When it finds an object with a UNCName it passes that object off 
' to MapObjects which maps whatever you pass into it.
'
Sub BuildOUs(strUrl)
	'
	' Parse URL into smaller URLs
	'
	Dim strBaseUrl
	Dim strVLANUrl
	Dim strBuildingUrl
	Dim strRoomUrl
	
	strRoomUrl = strUrl
	Call DiscoverObjects(strRoomUrl)
	
	strBuildingUrl = Right(strRoomUrl, (Len(strRoomUrl) -Instr(strRoomUrl, ",")))
	Call DiscoverObjects(strBuildingUrl)
	
	strVLANUrl = Right(strBuildingUrl , (Len(strBuildingUrl) -Instr(strBuildingUrl, ",")))
	Call DiscoverObjects(strVLANUrl)
	
	strBaseUrl = Right(strVLANUrl , (Len(strVLANUrl) -Instr(strVLANUrl, ",")))
	Call DiscoverObjects(strBaseUrl)

End Sub

company.com RetrieveOU()
' Retrieve computer OU
' 
' http://www.microsoft.com/technet/scriptcenter/resources/qanda/jul07/hey0727.mspx
'
Dim objSysInfo
Dim strName
Dim strOU

On Error Resume Next
set objSysInfo = CreateObject("ADSystemInfo")

strName = objSysInfo.ComputerName

strOU = Right(strName, Len(strName) - InStr(strName, ","))
RetrieveOU = strOU

End company.com

Sub DiscoverObjects(strURL)
	'
	' Locate all objects that have a UNCName property
	'
	On Error Resume Next
	Dim colItems
	Dim objItem
	
	Set colItems = GetObject("LDAP://" & strURL)
	If Err <> 0 Then
		Call LogData(1, Err.Number & vbCrLf & Err.Description)
		Err.Clear
	End If
	
	For Each objItem in colItems
		If objItem.UNCName <> "" Then
			Call MapObject(objItem.UNCName, objItem.CN)
		End If
	Next
End Sub

Sub MapObject(strURL, strDriveLetter)
	On Error Resume Next
	Dim strNetBios
	Dim objNetwork
	Dim strVersion
	'
	' Map an object in AD based on its UNCName property
	'
	' Printers are connected to \\ps
	' Folders are connected to \\fs \\people \\soecs-fs
	'
	' This script needs to catch the username
	'
	strNetBios = Left(strURL, InStr(strUrl, ".") - 1)
	Set objNetwork = CreateObject("Wscript.Network")
	strVersion = GetOSVersion
	
	Select Case strNetBios 
		Case "\\ps"
			If strVersion <> LCase("windows xp") Then Exit Sub
			If InStr(strURL, "laser") Then
				objNetwork.AddWindowsPrinterConnection strURL
				If Err <> 0 Then
					Call LogData(1, Err.Number & vbCrLf & Err.Description)
					Err.Clear
				Else
					Call LogData(4, "Mapping printer: " & strURL)
				End If			
				objNetwork.SetDefaultPrinter strURL
				If Err <> 0 Then
					Call LogData(1, Err.Number & vbCrLf & Err.Description)
					Err.Clear
				Else
					Call LogData(4, "Default printer: " & strURL)
				End If	
			Else
				objNetwork.AddWindowsPrinterConnection strURL
				If Err <> 0 Then
					Call LogData(1, Err.Number & vbCrLf & Err.Description)
					Err.Clear
				Else
					Call LogData(4, "Mapping printer: " & strURL)
				End If			
			End If
		Case "\\fs"
			objNetwork.MapNetworkDrive strDriveLetter, strURL
			If Err <> 0 Then
				Call LogData(1, "Unable to map the following resource:" & vbCrLf & strURL & vbCrLf & Err.Number & vbCrLf & Err.Description)
				Err.Clear
			Else
				Call LogData(4, "Mapping drive " & strDriveLetter)
			End If		
		Case "\\apps"
			objNetwork.MapNetworkDrive strDriveLetter, strURL
			If Err <> 0 Then
				Call LogData(1, "Unable to map the following resource:" & vbCrLf & strURL & vbCrLf & Err.Number & vbCrLf & Err.Description)
				Err.Clear
			Else
				Call LogData(4, "Mapping drive " & strDriveLetter)
			End If		
		Case "\\people"
			objNetwork.MapNetworkDrive strDriveLetter, strURL & "\" & RetrieveUser()
			If Err <> 0 Then
				Call LogData(1, "Unable to map the following resource:" & vbCrLf & strURL & vbCrLf & Err.Number & vbCrLf & Err.Description)
				Err.Clear
			Else
				Call LogData(4, "Mapping drive " & strDriveLetter)
			End If
		Case "\\bercsrv1"
			objNetwork.MapNetworkDrive strDriveLetter, strURL
			If Err <> 0 Then
				Call LogData(1, "Unable to map the following resource:" & vbCrLf & strURL & vbCrLf & Err.Number & vbCrLf & Err.Description)
				Err.Clear
			Else
				Call LogData(4, "Mapping drive " & strDriveLetter)
			End If
		Case Else
			Call LogData(2, "Unable to map the following resource:" & vbCrLf & strURL)
	End Select

End Sub

company.com RetrieveUser()
	Dim objWMIService
	Dim colItems
	Dim objItem
	Dim arrUser
	Dim strUser
	
	On Error Resume Next
	Set objWMIService = GetObject("winmgmts:\\.\root\cimv2")
	Set colItems = objWMIService.ExecQuery("SELECT * FROM Win32_ComputerSystem")
	
		For Each objItem in colItems
			arrUser = Split(objItem.UserName, "\")
			strUser = arrUser(1)
		Next
	
	RetrieveUser =  strUser

End company.com

Sub DisplayMessage
	'
	' Displays a custom HTA
	'
	Dim objFSO
	Dim objShell

	Set objFSO = CreateObject("Scripting.FileSystemObject")

	If objFSO.FileExists("message.hta") Then
		Set objShell = CreateObject("Wscript.Shell")
		objShell.Run "message.hta"
	Else
	End If
End Sub

company.com GetOSVersion
	'
	' This company.com returns the name of the OS the script is running in
	'
	' The one liner returns a value in vista and later, but in XP returns an error
	' the On Error ignores that and passes control to the If statement
	'
	Dim strVersion
	On Error Resume Next
	strVersion = GetObject("winmgmts:win32_OperatingSystem=@").Caption

	If strVersion = "" Then
		GetOSVersion = "Windows XP"
	Else
		GetOSVersion = strversion
	End If
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