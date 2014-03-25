'
' Sample Script
'
' This script contains the basic logging information that I use everywhere
'
	Call LogData(4, ScriptDetails(".") & vbCrLf & "Started: " & Now())
	freespace = GetFreeSpace(".", "C:")
	availram = GetRam(".")
	Wscript.Echo "Freespace: " & freespace
	Wscript.Echo "Ram: " & availram
	Call LogData(4, ScriptDetails(".") & vbCrLf & "Finished: " & Now())

Function GetWMIData(strComputer, WMIClass, WMIProperty)
	'
	' This function replaces more or less any WMI Call 
	' that returns a single value. You could potentially
	' tweak it to handle more complicated returns like
	' IPAddress.
	'
	' The function is passed three arguments:
	'     strComputer = Computer to run WMI call against
	'     WMIClass = The WMI Class that we're querying
	'     WMIProperty = The WMI property that we're looking for
	'
	Dim objWMIService
	Dim colItems
	Dim objItem
	Dim strReturnVal
	Dim strSysVol

	Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\CIMV2") 
		If Err <> 0 Then 
			Call HandleError(Err.Number, Err.Description)
		End If
	Set colItems = objWMIService.ExecQuery("SELECT " & WMIProperty & " FROM " & WMIClass,,48) 
	    	If Err <> 0 Then 
		   Call HandleError(Err.Number, Err.Description)
		End If
	
	For Each objItem In colItems
		Select Case lcase(WMIProperty)
			Case "caption"
				strReturnVal = objItem.Caption
			Case "csdversion"
				strReturnVal = objItem.CSDVersion
				If isNull(strReturnVal) Then strReturnVal = ""
			Case "serialnumber"
				strReturnVal = objItem.SerialNumber
			Case "dnshostname"
				strReturnVal = objItem.DNSHostName
			Case "csname"
				strReturnVal = objItem.CSName
			Case "uuid"
				strReturnVal = objItem.UUID
			Case "identifyingnumber"
				strReturnVal = objItem.IdentifyingNumber
			Case "name"
				strReturnVal = objItem.Name
			Case "vendor"
				strReturnVal = objItem.Vendor
			Case "totalphysicalmemory"
				strReturnVal = objItem.TotalPhysicalMemory
			Case "freespace"
				strReturnVal = objItem.FreeSpace
			Case Else
				Call LogData(1, "Unable to find " & WMIProperty & " in " & WMIClass & vbCrLf & "Please submit a ticket at http://code.patton-tech.com/winmon/newticket")
		End Select
	Next
	
	GetWMIData = strReturnVal
End Function

Sub HandleError(intErr, strErrDescription)
	'
	' Handle errors with pleasant messages
	'
	Select Case intErr
		Case 3709
			'
			' ODB Connection Error
			'
			Call LogData(1, "Error Number: " & intErr & vbCrLf & "Error Desc  : " & strDescription & vbCrLf & "Defined     : The proper ODBC driver is not present on this system.")
			Wscript.Quit
		Case Else
			Call LogData(1, "Error Number: " & intErr & vbCrLf & "Error Desc  : " & strDescription & vbCrLf & "Defined     : I have not yet seen this error number please submit a ticket at http://code.patton-tech.com/winmon.")
	End Select
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

Function GetFreeSpace(strComputer, strDrive)
'
' Returns the amount of free space on the given drive in GB
'
	Dim objWMIService
	Dim colItems
	Dim objItem
	Dim intFreeSpace

	Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\CIMV2") 
	Set colItems = objWMIService.ExecQuery("SELECT * FROM Win32_LogicalDisk WHERE Name = '" & strDrive &"'",,48) 

	For Each objItem in colItems 
		intFreeSpace = Cdbl(objItem.FreeSpace /1024 /1024 /1024)
	Next

	GetFreeSPace = intFreeSpace
End Function

Function GetRam(strComputer)
'
' Returns the amount of installed RAM
'
	Dim objWMIService
	Dim colItems
	Dim objItem
	Dim intClientRAM

	Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\CIMV2") 
	Set colItems = objWMIService.ExecQuery("SELECT * FROM Win32_OperatingSystem",,48) 

	For Each objItem in colItems 
		intClientRam = Cdbl(objItem.TotalVisibleMemorySize /1024 /1024 )
	Next

	GetRam = intClientRAM
End Function

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
