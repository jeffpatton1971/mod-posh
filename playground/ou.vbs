Call BuildOUs(RetrieveOU())

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
'
' The following two lines take strip the URL down to the top level
'
' strOU = Right(strOU, Len(strOU) - InStr(strOU, ","))
' strOU = Right(strOU, Len(strOU) - InStr(strOU, ","))

RetrieveOU = strOU

End Function

Sub DiscoverObjects(strURL)
Dim colItems
Dim objItem

Set colItems = GetObject("LDAP://" & strURL)

For Each objItem in colItems
	If objItem.UNCName <> "" Then
		Call MapObject(objItem.UNCName, objItem.CN)
	End If
Next
End Sub

Sub MapObject(strURL, strDriveLetter)
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
			objNetwork.SetDefaultPrinter strURL
			Call LogData(4, "Setting default printer to: " & strURL)
		Else
			objNetwork.AddWindowsPrinterConnection strURL
			Call LogData(4, "Mapping printer: " & strURL)
		End If
	Case "\\fs"
		objNetwork.MapNetworkDrive strDriveLetter, strURL
		Call LogData(4, "Mapping drive " & strDriveLetter)
	Case "\\people"
		objNetwork.MapNetworkDrive strDriveLetter, strURL & "\" & RetrieveUser()
		Call LogData(4, "Mapping drive " & strDriveLetter)
	Case Else
		Call LogData(2, "Unable to map the following resource:" & vbCrLf & strURL)
End Select

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