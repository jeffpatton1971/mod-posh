Set objShell = WScript.CreateObject("WScript.Shell")
objShell.RegWrite "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\ADSKFLEX_LICENSE_FILE", "@license1.soecs.ku.edu", "REG_SZ"


