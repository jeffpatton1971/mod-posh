'
' AD Inventory Script
'
' December 21, 2010: Jeff Patton
'
' This script is a replacement of the current inventory 
' script. Hopefully script will work better than the
' previous one.
'
' In order for this script to work within your environment
' you will need to modify the variables below to suit
' your needs.
'
' strQueryLDAP: would be the LDAP connection string that 
' 		maps to your AD installation. NOTE LDAP
'		must be in ALL CAPS.
'
Dim strQuery
Dim strQyeryObjectClass
Dim strQueryLDAP
Dim strQueryVars
Dim strUsername
Dim strSerialnumber
Dim strMACAddress
Dim NoWMI
Dim Offline
Dim LocalAccount
Const ForReading = 1

	NoWMI = Array()
	Offline = Array()
	LocalAccount = Array()
	
	If Wscript.Arguments.Count = 1 Then
		Set colNamedArguments = Wscript.Arguments.Named
		
		strQueryLDAP = colNamedArguments.Item("ldapURI")
		strQuery = "SELECT 'Name,distinguishedName' FROM '" & strQueryLDAP & "' WHERE objectClass = 'computer'"
	Else
		Wscript.Echo "Usage: CScript.exe ADInventory.vbs /ldapURI:LDAP://OU=Workstations,DC=company,DC=com > report.txt"
		Wscript.Quit
	End If


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
		strBody = "Script started at " & Now() & vbCrLf & "Updating " & strQuery & vbCrLf
		Do Until objRecordSet.EOF
			'
			' If you are reporting information, row data goes inside the loop.
			'
			' If you are performing an action on the data returned a call
			' to your function/subroutine should be made here.
			'
			strUsername = ""
			strSerialnumber = ""
			strMACAddress = ""
			If PingStatus(objRecordSet.Fields("Name")) = "Success" Then
				If WMIPing(objRecordSet.Fields("Name")) = vbTrue Then
					strUsername = GetWMIData(objRecordSet.Fields("Name"), "Win32_ComputerSystem", "UserName")
					If InStr(strUsername,objRecordSet.Fields("Name")) Then
						If Ubound(LocalAccount) = -1 Then	
							ReDim Preserve LocalAccount(Ubound(LocalACcount)+1)
							LocalAccount(Ubound(LocalACcount)) = objRecordSet.Fields("Name")
						Else
							ReDim Preserve LocalAccount(Ubound(LocalACcount)+1)
							LocalAccount(Ubound(LocalACcount)) = objRecordSet.Fields("Name")
						End If
					End If
					If IsNull(strUsername) Then strUsername = "Free"
					strSerialnumber = GetWMIData(objRecordSet.Fields("Name"), "Win32_BIOS", "SerialNumber")
					strMACAddress = GetMac(objRecordSet.Fields("Name"), "10.133")
					Call WriteData("macAddress", strMACAddress, objRecordSet.Fields("distinguishedName"))
					Call WriteData("serialNumber", strSerialnumber, objRecordSet.Fields("distinguishedName"))
					Call WriteData("description", strUsername, objRecordSet.Fields("distinguishedName"))
				Else
					If Ubound(NoWMI) = -1 Then
						ReDim Preserve NoWMI(Ubound(NoWMI)+1)
						NoWMI(Ubound(NoWMI)) = objRecordSet.Fields("Name")
					Else
						ReDim Preserve NoWMI(Ubound(NoWMI)+1)
						NoWMI(Ubound(NoWMI)) = objRecordSet.Fields("Name")
					End If
					Call WriteData("description", "WMI Error", objRecordSet.Fields("distinguishedName"))
				End If
			Else
				If Ubound(Offline) = -1 Then
					ReDim Preserve Offline(Ubound(Offline)+1)
					Offline(Ubound(Offline)) = objRecordSet.Fields("Name")
				Else
					ReDim Preserve Offline(Ubound(Offline)+1)
					Offline(Ubound(Offline)) = objRecordSet.Fields("Name")
				End If
				Call WriteData("description", "Offline", objRecordSet.Fields("distinguishedName"))
			End If
			objRecordSet.MoveNext
		Loop
		strBody = strBody & vbCrLf & "WMI Timeout: " & Ubound(NoWMI)+1 & vbCrLf
		For Each Item In NoWMI
			strBody = strBody & vbCrLf & Item
		Next
		strBody = strBody & vbCrLf & "Computer Offline: " & Ubound(Offline)+1 & vbCrLf
		For Each Item In Offline
			strBody = strBody & vbCrLf & Item
		Next
		strBody = strBody & vbCrLf & "Local Account: " & Ubound(LocalAccount)+1 & vbCrLf
		For Each Item In LocalAccount	
			strBody = strBody & vbCrLf & Item
		Next
		
		strBody = strBody & vbCrLf & "Script ended at " & Now()
		Wscript.Echo "AD Inventory for " & strQueryLDAP & vbCrLf & strBody
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

Function WMIPing(strComputer)
On Error Resume Next
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
	
	WMIPing = blnOnline
End Function

Sub Sendmail(strFrom, strTo, strSub, strBody, strSmtpServer, blnAuthSmtp, strAuthUser, strAuthPass)
'
' A procedure that sends email
' http://technet.microsoft.com/en-us/library/ee176585.aspx
'
Dim cdoAuthType

	cdoAuthType = 1			'Basic Auth
	'cdoAuthType = 2		'NTLM Auth

	Set objEmail = CreateObject("CDO.Message")
	objEmail.From = strFrom
	objEmail.To = strTo
	objEmail.Subject = strSub
	objEmail.Textbody = strBody
	
	If blnAuth = vbTrue Then
		objEmail.Configuration.Fields.Item("http://schemas.microsoft.com/cdo/configuration/smtpauthenticate") = 1
		objEmail.Configuration.Fields.Item("http://schemas.microsoft.com/cdo/configuration/sendusername") = strAuthUser
		objEmail.Configuration.Fields.Item("http://schemas.microsoft.com/cdo/configuration/sendpassword") = strAuthPass
	End If
	
	objEmail.Configuration.Fields.Item("http://schemas.microsoft.com/cdo/configuration/sendusing") = 2
	objEmail.Configuration.Fields.Item("http://schemas.microsoft.com/cdo/configuration/smtpserver") = strSmtpServer
	objEmail.Configuration.Fields.Item("http://schemas.microsoft.com/cdo/configuration/smtpserverport") = 25
	objEmail.Configuration.Fields.Update
	objEmail.Send
End Sub

Sub WriteData(strProperty, strValue, strADSPath)
	'
	' Update a single-value property of an object in AD
	'
	Dim objADObject
	
	Set objADObject = GetObject("LDAP://" & strADSPath)
	
		objADObject.Put strProperty , strValue
		objADObject.SetInfo

End Sub

Function GetWMIData(strComputer, WMIClass, WMIProperty)
On Error Resume Next
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
	Dim strPingStatus
	
	strPingStatus = PingStatus(strComputer)
	
	If strPingStatus = "Success" Then
		Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\CIMV2") 
			If Err <> 0 Then 
				If objWMIService Is Nothing Then
					Call LogData(1, "Unable to bind to WMI on " & strComputer & vbCrLf & "Error Num: " & Err.Number & vbCrLf & "Description: " & Err.Description & vbCrLf & "Source: " & Err.Source)
				End If
			End If
		Set colItems = objWMIService.ExecQuery("SELECT " & WMIProperty & " FROM " & WMIClass,,48) 
			If colItems Is Nothing Then 
				Call LogData(1, "SELECT " & WMIProperty & " FROM " & WMIClass & vbCrLf & "Returned Nothing for " & strComputer)
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
				Case "systemdrive"
					strReturnVal = objItem.SystemDrive
				Case "totalvisiblememorysize"
					strReturnVal = objItem.TotalVisibleMemorySize
				Case "numberofcores"
					strReturnVal = objItem.NumberOfCores
				Case "lastbootuptime"
					strReturnVal = objItem.LastBootUpTime
				Case "currentclockspeed"
					strReturnVal = objItem.CurrentClockSpeed
				Case "username"
					strReturnVal = objItem.UserName
				Case "smbiosbiosversion"
					strReturnVal = objItem.SMBIOSBIOSVersion
				Case Else
					Call LogData(1, "Unable to find " & WMIProperty & " in " & WMIClass & vbCrLf & "Please submit a ticket at http://code.patton-tech.com/winmon/newticket")
			End Select
		Next
		GetWMIData = strReturnVal
	Else
		Call LogData(1, "Pinging " & strComputer & " failed with " & vbCrLf & strPingStatus)
		GetWMIData = strPingStatus
	End If
End Function

Function GetMac(strComputer, strSubNet)
	'
	' Get MAC Address of the computer
	'
	Dim strMacAddress
	Dim objWMIService
	Dim colItems
	Dim objItem
	Dim strIPAddress

	Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\CIMV2") 
	Set colItems = objWMIService.ExecQuery("SELECT * FROM Win32_NetworkAdapterConfiguration Where IPEnabled = True",,48) 

		For Each objItem in colItems
			strIPAddress = Join(objItem.IPAddress, ",")
			If InStr(strIPAddress, strSubNet) Then
				strMacAddress = objItem.MACAddress
				Exit For
			End If
		Next

	GetMac = strMacAddress
End Function

Function PingStatus(strComputer)
'
' Source
' http://technet.microsoft.com/en-us/library/ee692852.aspx
'
On Error Resume Next

Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
Set colPings = objWMIService.ExecQuery("SELECT * FROM Win32_PingStatus WHERE Address = '" & strComputer & "'")

For Each objPing in colPings
	Select Case objPing.StatusCode
		Case 0 PingStatus = "Success"
		Case 11001 PingStatus = "Status code 11001 - Buffer Too Small"
		Case 11002 PingStatus = "Status code 11002 - Destination Net Unreachable"
		Case 11003 PingStatus = "Status code 11003 - Destination Host Unreachable"
		Case 11004 PingStatus = "Status code 11004 - Destination Protocol Unreachable"
		Case 11005 PingStatus = "Status code 11005 - Destination Port Unreachable"
		Case 11006 PingStatus = "Status code 11006 - No Resources"
		Case 11007 PingStatus = "Status code 11007 - Bad Option"
		Case 11008 PingStatus = "Status code 11008 - Hardware Error"
		Case 11009 PingStatus = "Status code 11009 - Packet Too Big"
		Case 11010 PingStatus = "Status code 11010 - Request Timed Out"
		Case 11011 PingStatus = "Status code 11011 - Bad Request"
		Case 11012 PingStatus = "Status code 11012 - Bad Route"
		Case 11013 PingStatus = "Status code 11013 - TimeToLive Expired Transit"
		Case 11014 PingStatus = "Status code 11014 - TimeToLive Expired Reassembly"
		Case 11015 PingStatus = "Status code 11015 - Parameter Problem"
		Case 11016 PingStatus = "Status code 11016 - Source Quench"
		Case 11017 PingStatus = "Status code 11017 - Option Too Big"
		Case 11018 PingStatus = "Status code 11018 - Bad Destination"
		Case 11032 PingStatus = "Status code 11032 - Negotiating IPSEC"
		Case 11050 PingStatus = "Status code 11050 - General Failure"
		Case Else PingStatus = "Status code " & objPing.StatusCode & " - Unable to determine cause of failure."
	End Select
Next

End Function