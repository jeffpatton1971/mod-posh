'
' Inventory Script
'
' The purpose of this script is to check each computer object in the AD
' verify that it is there, and then connect to it and grab who is logged
' on, what it's MAC address is, and its service tag.
'
' August 12, 2008: Jeff Patton
'
Option Explicit

Dim strPropertyList
Dim strLDAPURL
Dim strObjectClass
Dim strQuery

strPropertyList = "DistinguishedName, Name"
strLDAPURL = "LDAP://DC=company,DC=com"
strObjectClass = "computer"
strQuery = "SELECT " & strPropertyList & " FROM '" & strLDAPURL & "' WHERE objectClass = '" & strObjectClass & "'"

    Call LogData(4, ScriptDetails(".")& vbCrLf & "Started: " & Now())
    Call QueryAD(strQuery)
    Call LogData(4, ScriptDetails(".")& vbCrLf & "Finished: " & Now())

Sub BuildDescription(strComputer, strADSPath, bolOnline)
    '
    ' Build the description value
    '
    'On Error Resume Next

    Dim strOldDescription
    Dim strDescription
    Dim arrDescription

    If bolOnline = vbTrue Then
        Call WriteData("Description", GetUser(strComputer) & "," & GetSerial(strComputer) & "," & GetMac(strComputer), strADSPath)
    Else
        strOldDescription = GetProp(strADSPath, "Description")
        If Len(strOldDescription) <> 0 Then
            arrDescription = Split(strOldDescription, ",")
            If ERR <> 0 Then
                Call LogData(1, Err.Number & vbCrLf & Err.Description & vbCrLf & "strOldDescription = '" & strOldDescription & "'")
                Err.Clear()
                Exit Sub
            End If
            arrDescription(0) = "OFFLINE"
            strDescription = arrDescription(0) & "," & arrDescription(1) & "," & arrDescription(2)
            Call WriteData("Description", strDescription, strADSPath)
        Else
            strDescription = "OFFLINE"
        End If
        End If

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

Function GetProp(strADSPath, strProperty)
On Error Resume Next
'
' Get the specified property from the requested AD object
'
Dim objComputer
Dim objProperty
Dim strStatus

Set objComputer = GetObject("LDAP://" & strADSPath)
objProperty = objComputer.Get(strProperty)

	If IsNull(objProperty) Then
		Call LogData(2, "No '" & strProperty & "' found for: " & vbCrLf & strADSPath)
	Else
		strStatus = objProperty
		objProperty = Null
	End If

	GetProp = strStatus
End Function

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
	Wscript.Echo objRecordSet.Fields("Name").Value

        If ComputerOnline(objRecordSet.Fields("Name").Value) = vbTrue Then
            Call BuildDescription(objRecordSet.Fields("Name").Value, objRecordSet.Fields("DistinguishedName").Value, vbTrue)
        Else
            Call BuildDescription(objRecordSet.Fields("Name").Value, objRecordSet.Fields("DistinguishedName").Value, vbFalse)
        End If
		objRecordSet.MoveNext
	Loop
End Sub

Function GetUser(strComputer)
'
' Get username of currently logged on user
'
Dim strUserName
Dim objWMIService
Dim colItems
Dim objItem

Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\CIMV2") 
Set colItems = objWMIService.ExecQuery("SELECT * FROM Win32_ComputerSystem",,48) 

	For Each objItem in colItems
		If IsNull(objItem.UserName) Then
			strUserName = "FREE"
		Else
			strUserName = objItem.UserName
		End If
	Next

GetUser = strUserName
End Function

Function GetSerial(strComputer)
'
' Get serial number from the BIOS
'
Dim strSerial
Dim objWMIService
Dim colItems
Dim objItem

Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\CIMV2") 
Set colItems = objWMIService.ExecQuery("SELECT * FROM Win32_BIOS",,48) 

	For Each objItem in colItems 
		strSerial = objItem.SerialNumber
	Next

GetSerial = strSerial
End Function

Function GetMac(strComputer)
'
' Get MAC Address of the computer
'
Dim strMacAddress
Dim objWMIService
Dim colItems
Dim objItem
Dim strIPAddress

Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\CIMV2") 
Set colItems = objWMIService.ExecQuery("SELECT * FROM Win32_NetworkAdapterConfiguration",,48) 

	For Each objItem in colItems
		If isNull(objItem.IPAddress) Then
		Else
		strIPAddress = Join(objItem.IPAddress, ",")
		If InStr(strIPAddress, "129.237") Or InStr(strIPAddress, "10.133") Then
			If IsNull(objItem.MACAddress) Then
			Else
			strMacAddress = objItem.MACAddress
			Exit For
			End If
		End If
	End If
	Next

GetMac = strMacAddress
End Function

Function ComputerOnline(strComputer)
'
' Is computer online?
' 
' Attempt WMI Connection if it fails ComputerOnline = False
'
On Error Resume Next

Dim blnOnline
Dim objWMIService

Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\CIMV2")
	If Err <> 0 Then
		blnOnline = vbFalse
	Else
		blnOnline = vbTrue
	End If

ComputerOnline = blnOnline
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

Function ScriptDetails(strComputer)
'
' Return information about who, what, where
'
    'On Error Resume Next
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
