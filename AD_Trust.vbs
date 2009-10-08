strComputer = "dc2.soecs.ku.edu" 
Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\MicrosoftActiveDirectory") 
Set colItems = objWMIService.ExecQuery( _
    "SELECT * FROM Microsoft_DomainTrustStatus",,48) 
For Each objItem in colItems 
    Wscript.Echo "-----------------------------------"
    Wscript.Echo "Microsoft_DomainTrustStatus instance"
    Wscript.Echo "-----------------------------------"
    Wscript.Echo "TrustedDCName: " & objItem.TrustedDCName
    Wscript.Echo "TrustedDomain: " & objItem.TrustedDomain
    Wscript.Echo "TrustIsOk: " & objItem.TrustIsOk
Next