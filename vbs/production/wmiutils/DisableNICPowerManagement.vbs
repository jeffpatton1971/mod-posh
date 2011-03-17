Sub DisableNICPowerManagement(strComputer, intDWordValue)
	' This procedure allows you to enable or disable the PowerManagement
	' features of a network card. 
	'
	' To disable intDWordValue = 56
	' To enable intDWordValue = 48
	'
	' This subroutine updates the registry to make the change so the 
	' target computer will need to reboot before the change kicks in.
	'
	' The GUID of Network Cards: http://technet.microsoft.com/en-us/library/cc780532(WS.10).aspx
	' The value to set for PnPCapabilities: http://support.microsoft.com/kb/837058
	' The WMI Class we want (Win32_NetworkAdapter): http://msdn.microsoft.com/en-us/library/aa394216(v=vs.85).aspx
	' From that class what we need is the Index property, this number represents the specific
	' network card we wish to manipulate.
	On Error Resume Next

	Const HKLM = &H80000002
	Dim objReg
	Dim objWMIService
	Dim colItems
	Dim objItem
	Dim strRegKey

	strRegKey = "SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002bE10318}\"

	Set objReg = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\default:StdRegProv")
	Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
	Set colItems = objWMIService.ExecQuery ("Select * From Win32_NetworkAdapterConfiguration Where IPEnabled = True")

	For Each objItem in colItems
		If Len(objItem.Index) = 1 Then strDeviceID = "000" & objItem.Index
		If Len(objItem.Index) = 2 Then strDeviceID = "00" & objItem.Index
		If Len(objItem.Index) = 3 Then strDeviceID = "0" & objItem.Index
		objReg.SetDWORDValue HKLM, strRegKey & strDeviceID & "\","PnPCapabilities",intDWordValue
	Next
End Sub