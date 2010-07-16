Option Explicit
Const HKEY_LOCAL_MACHINE = &H80000002
'
' Shutdown script for the lab computers
'
' This script will delete all printer connections
'
'
' November 11, 2008: Jeff Patton
'

	Call LogData(4, ScriptDetails(".") & vbCrLf & "Started: " & Now())
	Call ReadReg(".", "SYSTEM\ControlSet001\Control\Print\Connections")
	Call LogData(4, ScriptDetails(".") & vbCrLf & "Finished: " & Now())

Sub ReadReg(strComputer, strKeyPath)
'
' This procedure reads the subkeys within a parent key
'
' http://msdn.microsoft.com/en-us/library/293bt9hh(VS.85).aspx
'
Dim objRegistry
Dim arrSubKeys
Dim objSubKey

Set objRegistry = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\default:StdRegProv")

	objRegistry.EnumKey HKEY_LOCAL_MACHINE, strKeyPath, arrSubKeys

	For Each objSubKey In arrSubKeys
		Call DelReg(strKeyPath & "\" & objSubKey)
	Next
End Sub

Sub DelReg(strRegistryKey)
On Error Resume Next
'
' This procedure deletes a registry out of the Windows registry
'
' http://msdn.microsoft.com/en-us/library/293bt9hh(VS.85).aspx
'
Dim objRegistry
 
Set objRegistry=GetObject("winmgmts:\\.\root\default:StdRegProv")

	objRegistry.DeleteKey HKEY_LOCAL_MACHINE, strRegistryKey
	If Err <> 0 Then
		Call LogData(1, "Unable to delete the following registry key: " & vbCrLf & strRegistryKey & vbCrLf & Err.Number & vbCrLf & Err.Description)
		Err.Clear
	Else
		call Logdata(0, "Deleted the following registry key: " & vbCrLf & strRegistryKey)
	End If
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