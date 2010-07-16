Option Explicit

Dim strISOFile

If Wscript.Arguments.Count > 0 Then
	strISOFile = Wscript.Arguments.Item(0)
Else
	Wscript.Echo "Invalid number of arguments"
End If

Call DetermineDrive

Sub DetermineDrive
On Error Resume Next

Dim strComputer
Dim objWMIService
Dim colItems
Dim objItem
Dim strCapability
Dim blnWriteable
Dim strDriveLetter

strComputer = "."
Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")

Set colItems = objWMIService.ExecQuery("Select * from Win32_CDROMDrive")

For Each objItem in colItems
	If objItem.Availability = 3 Then
		If objItem.MediaLoaded = vbTrue Then
			For Each strCapability in objItem.Capabilities
				If strCapability = 4 Then
					blnWriteable = vbTrue
				End If
			Next
			strDriveLetter = objItem.Drive
			Wscript.Echo "cdburn " & strDriveLetter & strISOFile
		Else
			Wscript.Echo "There is no media in drive " & objItem.Drive
		End If
	Else
		Wscript.Echo "The drive is offline."
	End If
Next
End Sub