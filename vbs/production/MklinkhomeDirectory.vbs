' 
' MKLink homeDirectory
'
' March 2, 2011: Jeff Patton
'
' This script reads in the username of the user running this script
' and the current location of the user's desktop. It takes that 
' information and uses MKLINK to create a symlink on their desktop
' to the shared storage location specifed in ther user object.
'
' If the user doesn't have a homeDirectory specified then exit.
'

Set adSysInfo = CreateObject("ADSystemInfo")
Set CurrentUser = GetObject("LDAP://"& ADSysInfo.UserName)
set WshShell = WScript.CreateObject("WScript.Shell")

strLinkFolder = "Link"
strCommand = "mklink /d " & chr(34) & WshShell.SpecialFolders("Desktop") & "\" & strLinkFolder & chr(34) & " " & chr(34) & CurrentUser.homeDirectory & chr(34)
wscript.echo strCommand
If IsEmpty(CurrentUser.homeDirectory) Then Wscript.Quit
RunCommand = WshShell.Run("cmd.exe /c " & strCommand,1,vbTrue)