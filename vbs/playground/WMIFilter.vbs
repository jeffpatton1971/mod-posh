'
' This function returns false when run on a notebook or true on a desktop
'
' In order to prevent a GPO from being applied the filter should return false
'
' http://technet.microsoft.com/en-us/library/cc779036.aspx
'
' Created February 4, 2009: Jeff Patton
'
Dim objWMIService
Dim colItems
Dim objItem
Dim bolDesktop

Set objWMIService = GetObject("winmgmts:\\.\root\CIMV2") 
Set colItems = objWMIService.ExecQuery("SELECT * FROM Win32_SystemEnclosure",,48) 

	For Each objItem in colItems 
		If isNull(objItem.ChassisTypes) Then
			Wscript.Echo strComputer
		Else
			Select Case Join(objItem.ChassisTypes, ",")
				Case 8, 9, 10, 11, 12
					bolDesktop = vbFalse
				Case Else
					bolDesktop = vbTrue
			End Select
		End If
	Next

Wscript.Echo bolDesktop