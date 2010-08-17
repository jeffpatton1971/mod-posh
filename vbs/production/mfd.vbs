'
' Map MFD Printers for XP
'
' August 17, 2010 - Jeffrey S. Patton
' jspatton@ku.edu
'
' Original Source
' http://code.patton-tech.com/release/production/mfd.vbs
'
' Bug Report
' http://projects.patton-tech.com/scripts/newticket
'
' This script maps the new mfd printers for the School of Engineering.
'
' USAGE:
' Place this script on a network share that all users are able to access
' preferrably a read-only share, otherwise you will want to deny write 
' to this script.
'
' Call this script as a logon script, and the only parameter that 
' needs to be specified is the printer share name.
'
' Two options can be set within the script bolDefault and strPrintServer.
'
' bolDefault is either vbTrue or vbFalse, and determines wether or not the
' provided pritner will be set as the default printer.
'
' strPrintServer is the FQDN of the server hosting the shared printer.
'
' GPO Requirements:
' The GPO that calls this script needs to have the following policy
' set to disabled.
'
' User Configuration\Policies\Administrative Templates\Printers\Point and Print Restrictions
'
' Disabling this policy allows users to install printers from
' servers that are not in the same domain as the computer where the
' printer is being installed from.
'
Option Explicit
Dim bolDefault
Dim strPrintServer

bolDefault = vbTrue
strPrintServer = "pcutprd.home.ku.edu"

Call ConnectPrinters(strPrintServer, Wscript.Arguments.Item(0), bolDefault)

Sub ConnectPrinters(strPrintServer, strPrinter, bolDefault)
	Dim objNetwork
	
	On Error Resume Next
	Set objNetwork = CreateObject("Wscript.Network")
	
		objNetwork.AddWindowsPrinterConnection "\\" & strPrintServer & "\" & strPrinter
		If Err <> 0 Then
			Call LogData(1, "Error Number: " & Err.Number & vbCrLf & "Error Description: " & err.Description)
			Err.Clear
		End If
	
		If bolDefault = vbTrue Then
			objNetwork.SetDefaultPrinter "\\" & strPrintServer & "\" & strPrinter
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
