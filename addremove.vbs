strComputer = "l3150-pc01.soecs.ku.edu" 
Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\CIMV2") 
Set colItems = objWMIService.ExecQuery( _
    "SELECT * FROM Win32_Product",,48) 
For Each objItem in colItems 
    Wscript.Echo objItem.Caption & ", " & objItem.Description
Next