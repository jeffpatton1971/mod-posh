'
' Unified Startup Script
'
' This script will manage all computers in the SOECS domain.
'
' The main thrust of this script is to globally define all Environment variables for
' software that is available to computers in the domain. There is no differentiation
' between computers so checking what OU a computer is in is not necessary.
'
' The only exemption to this script will be computers in the Research OU, so there will
' be code that will check which OU the computer is in first.
'
' This script will perform five basic Functions:
'	Create the TEMP and SCRATCH directories if they are not there
'	Empty the TEMP and SCRATCH directories
'	Set Environment Variables through the registry
'	Define local administrators
'	Set local Administrator password
'
	Call LogData(4, ScriptDetails(".") & vbCrLf & "Started: " & Now())
	Call Main
	Call LogData(4, ScriptDetails(".") & vbCrLf & "Finished: " & Now())

Sub Main
	' This procedure is where everything gets kicked off from.
	'

	' Check if this computer is in the Research OU
	'	if true, wscript.quit
	'
	If InStr("OU=Research", RetreiveOU) Then Wscript.Quit

	' Add the proper admin group based on OU membership
	'	if Labs OU, LabsAdmin > Administrators
	'	if People OU, PeopleAdmin > Administrators
	'
	If InStr("OU=Labs", RetrieveOU) Then Call AddGroup(".", "Administrators", "LabsAdmin")
	If InStr("OU=People", RetrieveOU) Then Call AddGroup(".", "Administrators", "PeopleAdmin")

	' Set the local Administrator password
	Call ChangePass(".", "Administrator", WScript.Arguments(0))

	' Check if the folders are there
	'	if false, create them
	'	if true, clear them
	'
	If CheckFolder("C:\TEMP") = vbTrue Then
		Call ClearFolder("C:\TEMP")
	Else
		Call MkDir("C:\TEMP")
	End If

	If CheckFolder("C:\SCRATCH") = vbTrue Then
		Call ClearFolder("C:\SCRATCH")
	Else
		Call MkDir("C:\SCRATCH")
	End If

	' Add variable block for: Autodesk
	call AddVar("HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\", "ADSKFLEX_LICENSE_FILE", "@license1.soecs.ku.edu", "REG_SZ")

	' Add variable block for: Application XYZ
	Call AddVar("HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\", "LSHOST", "license.soecs.ku.edu:license1.soecs.ku.edu:license2.soecs.ku.edu:license3.soecs.ku.edu", "REG_SZ")

	' Add variable block for: Application XYZ
	Call AddVar("HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\", "LM_LICENSE_FILE", "3006@license1.soecs.ku.edu;@license1.soecs.ku.edu;@license2.soecs.ku.edu;@license.soecs.ku.edu;1700@license1.soecs.ku.edu;27004@license.soecs.ku.edu;7166@license1.soecs.ku.edu;27001@license1.soecs.ku.edu", "REG_SZ")

	' Add variable block for: Application XYZ
	Call AddVar("HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\", "28000@license1.soecs.ku.edu", "REG_SZ")

	' Add variable block for: UGS NX
	Call AddVar("HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\", "UGS_LICENSE_BUNDLE", "ACD", "REG_SZ")
	Call AddVar("HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\", "SDI_OVERRIDE_HOME", "C:\TEMP", "REG_SZ")

	' Add variable block for: ESRI ArcGIS
	Call AddVar("HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\", "ARCGIS_LICENSE_FILE", "27004@license.soecs.ku.edu", "REG_SZ")

	' Add variable block for: Fluent
	Call AddVar("HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\", "FLUENT_LICENSE_FILE", "7241@license1.soecs.ku.edu", "REG_SZ")

	' Add variable block for: Labview
	Call AddVar("HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\", "NILM_LICENSE_FILE", "@nilicensemgr.ku.edu", "REG_SZ")

	' Add variable block for: Windows
	Call AddVar("HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\", "TEMP", "%SystemRoot%\TEMP", "REG_EXPAND_SZ")
	Call AddVar("HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\", "TMP", "%SystemRoot%\TEMP", "REG_EXPAND_SZ")
	Call AddVar("HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\", "windir", "C:\WINDOWS", "REG_SZ")

	' Add variable block for: Bentley
	Call AddVar("HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\", "_USTN_WORKSPACEROOT", "P:\KDOT_NS_Workspace\", "REG_SZ")

	' Add variable block for: BioWin
	Call AddVar("HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\", "HLS_IPADDR", "license.soecs.ku.edu", "REG_SZ")

	' Fix the WSUS sysprep issue
	Call FixDupRegEntry("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SUSClientId", "0bf32620-93cd-499e-8460-316264b73d63")

	' Add variable block for: AAA
	Call DelRegKey("SOFTWARE\WIBU-SYSTEMS\WIBU-KEY\Network\03.00\WkLanAccess\")
	Call AddVar("HKLM\SOFTWARE\WIBU-SYSTEMS\WIBU-KEY\Network\03.00\WkLanAccess\")
	Call AddVar("HKLM\SOFTWARE\WIBU-SYSTEMS\WIBU-KEY\Network\03.00\WkLanAccess\", "Server1", "license.soecs.ku.edu", "REG_SZ")


End Sub
'
' Below are procedures and Functions required by this script.
'
Sub ChangePass(strComputer, strAccount, strPassword)
	'
	' http://www.microsoft.com/technet/scriptcenter/resources/qanda/jul07/hey0703.mspx
	'
	' Modified to make the procedure more generic so it will work in more than
	' one scenario.
	'
	Dim objUser 

	Set objUser = GetObject("WinNT://" & strComputer & "/" & strAccount)
	objUser.SetPassword strPassword
	If Err <> 0 Then Call LogData(1, Err.Number & vbCrLf & Err.Description & vbCrLf & "Unable to add " & strDomainGroup & " to " & strLocalGroup)
End Sub

Sub AddGroup(strComputer, strLocalGroup, strDomainGroup)
	'
	' http://www.microsoft.com/technet/scriptcenter/resources/qanda/jan08/hey0104.mspx
	'
	' Modified to make the procedure more generic so it will work in more than
	' one scenario.
	'
	Dim objLocalGroup
	Dim objADGroup

	Set objLocalGroup = GetObject("WinNT://" & strComputer & "/" & strLocalGroup)
	Set objADGroup = GetObject("WinNT://Fabrikam/" & strDomainGroup)

	objLocalGroup.Add(objADGroup.ADsPath)
	If Err <> 0 Then Call LogData(1, Err.Number & vbCrLf & Err.Description & vbCrLf & "Unable to add " & strDomainGroup & " to " & strLocalGroup)
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

Sub AddVar(strRegPath, strVariable, strVariableValue, strVariableType)
	'
	' This procedure adds environment variables reliably
	'
	' http://msdn.microsoft.com/en-us/library/yfdfhz1b(VS.85).aspx
	'
	Dim WshShell
	Set WshShell = WScript.CreateObject("WScript.Shell")
	
		WshShell.RegWrite strRegPath & strVariable, strVariableValue, strVariableType
		If Err <> 0 Then Call LogData(1, "Unable to add " & strvariable & " = " & strVariableValue)

End Sub

Sub DelRegKey(strRegistry)
	'
	' Delete Registry Key
	'
	Const HKEY_LOCAL_MACHINE = &H80000002
	Dim objRegistry
 
	Set objRegistry=GetObject("winmgmts:\\.\root\default:StdRegProv")

	objRegistry.DeleteKey HKEY_LOCAL_MACHINE, strRegistry
End Sub

Sub FixDupRegEntry(strRegistry, strRegValue)
	' Fix update service sid issue
	'
	' http://www.microsoft.com/technet/scriptcenter/guide/sas_wsh_oiuk.mspx
	'
	' Provide the registry key that might have the duplicate entry
	' Provide the entry in question
	' Provide the complete registry key to delete
	'
	' This procedure was created to fix a problem with Windows Update on 
	' syspreped machines. This is one entry that sysprep doesn't remove that causes
	' WSUS to think that this computer is already on the list of managed computers.
	'
	On Error Resume Next
	Dim objShell
	Dim strCurrentRegValue

	Set objShell = Wscript.CreateObject("Wscript.Shell")

		strCurrentRegValue = objShell.RegRead(strRegistry)

		If strCurrentRegValue = strRegValue Then
			Call LogData(1, "Found duplicate registry entry")
			objShell.RegDelete(strRegistry)
			If Err <> 0 Then
				Call LogData(1, "Error Number: " & vbTab & Err.Number & vbCrLf & "Error Description: " & vbTab & Err.Description)
				Err.Clear
				Exit Sub
			End If
			Call Logdata(0, "Deleted duplicate registry entry, client will show up on next reboot.")
		Else
		End If
End Sub

Function CheckFolder(strPath)
	'
	' This Function returns vbTrue or vbFalse based on whether or not it finds the folder
	'
	Dim blnFound
	Dim objFSO
	Dim objFolder

	blnFound = vbFalse
	Set objFSO = CreateObject("Scripting.FileSystemObject")

	If objFSO.FolderExists(strPath) Then
		blnFound = vbTrue
	End If

	CheckFolder = blnFound
End Function

Sub ClearFolder(strPath)
	' Delete files in a folder
	' 
	' http://www.microsoft.com/technet/scriptcenter/scripts/storage/files/stfivb06.mspx
	' http://www.microsoft.com/technet/scriptcenter/scripts/storage/folders/stfovb29.mspx
	'
	On Error Resume Next
	Dim blnDeleteReadOnly
	Dim objFSO

	blnDeleteReadOnly = True
	Set objFSO = CreateObject("Scripting.FileSystemObject")

		If objFSO.FolderExists(strPath) Then
			objFSO.DeleteFile(strPath & "\*.*"), blnDeleteReadOnly
			If Err <> 0 Then
				Call LogData(1, "Unable to delete: '" & strPath & vbCrLf & "'" & "Error Number: " & vbTab & Err.Number & vbCrLf & "Error Description: " & vbTab & Err.Description)
				Err.Clear
				Exit Sub
			End If
			Call LogData(0, "Successfully deleted: '" & strPath & "'")
		Else
			Call LogData(1, strPath & " does not exist.")
		End If
End Sub

Sub MkDir(strPath)
	On Error Resume Next
	Dim objFSO
	Dim objFolder
	
	Set objFSO = CreateObject("Scripting.FileSystemObject")
	Set objFolder = objFSO.CreateFolder(strPath)
	
		If Err <> 0 Then
			Call LogData(1, "Unable to create: '" & strPath & vbCrLf & "'" & "Error Number: " & vbTab & Err.Number & vbCrLf & "Error Description: " & vbTab & Err.Description)
			Err.Clear
			Exit Sub
		End IF
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