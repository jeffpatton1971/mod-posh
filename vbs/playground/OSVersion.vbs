On error resume next
strVersion = GetObject("winmgmts:win32_OperatingSystem=@").Caption

If strVersion = "" Then
	Wscript.Echo "Windows XP"
	Else
	Wscript.Echo strversion
End If