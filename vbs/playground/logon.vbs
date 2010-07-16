Option Explicit
On Error Resume Next
'
' Logon script for the People OU
'
' This script will map all drives for all departments based on their location in AD
'
' This script will map all printers for all departments based on their location in AD
'
' October 20, 2008: Jeff Patton
'
	Call LogData(4, ScriptDetails(".") & vbCrLf & "Started: " & Now())
	Call DisconnectDrives
	Call BuildOUs(RetrieveOU)
	Call DisplayMessage
	Call Logdata(4, ScriptDetails(".") & vbCrLf & "Finished: " & Now())

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

On Error Resume Next
Set objShell = Wscript.CreateObject("Wscript.Shell")

	objShell.LogEvent intCode, strMessage

End Sub

Function RetrieveOU()
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

End Function

Sub DisconnectDrives
' Discconect any mapped drives
'
' http://www.microsoft.com/technet/scriptcenter/resources/qanda/sept05/hey0915.mspx
'
Dim objNetwork
Dim colDrives
Dim i

On Error Resume Next
Set objNetwork = CreateObject("Wscript.Network")
Set colDrives = objNetwork.EnumNetworkDrives

	For i = 0 to (colDrives.Count -1) Step 2
		objNetwork.RemoveNetworkDrive colDrives.Item(i)
		Call LogData(4, "Disconnected Drive: " & colDrives.Item(i))
	Next

End Sub

Sub DiscoverObjects(strURL)
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
'
' Map an object in AD based on its UNCName property
'
' Printers are connected to \\ps
' Folders are connected to \\soecs-fs
'
' This script needs to catch the username
'
strNetBios = Left(strURL, InStr(strUrl, ".") - 1)
Set objNetwork = CreateObject("Wscript.Network")

Select Case strNetBios 
	Case "\\ps"
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
	Case "\\people"
		objNetwork.MapNetworkDrive strDriveLetter, strURL & "\" & RetrieveUser()
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

Sub BuildOUs(strUrl)
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

' Retrieve User
' 
' http://www.microsoft.com/technet/scriptcenter/scripts/default.mspx?mfr=true
' http://www.microsoft.com/technet/scriptcenter/resources/qanda/may05/hey0526.mspx
'
Function RetrieveUser()
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
	Next

	strUser = arrUser(UBound(arrUser))

RetrieveUser =  strUser

End Function

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
				Call LogData(1, "DCOM Service Unavailable, exiting procedure.")
				Exit For
			End If
			strUserName = strUserDomain & "\" & strNameOfUser
		End If
	Next

	ScriptDetails = "Script Name: " & strScriptName & vbCrLf & "Script Path: " & strScriptPath & vbCrLf & "Script User: " & strUserName
End Function