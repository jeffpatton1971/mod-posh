<#
    .SYNOPSIS
        Disables Ipv6 on local machine
    .DESCRIPTION
        This script will disable Ipv6 via a registry setting.
    .EXAMPLE
        .\Disable-Ipv6.ps1
        
        Description
        -----------
        This is the only syntax for this script.
    .NOTES
        ScriptName : Disable-Ipv6
        Created By : jspatton
        Date Coded : 06/08/2012 15:25:50
        ScriptName is used to register events for this script
 
        ErrorCodes
            100 = Success
            101 = Error
            102 = Warning
            104 = Information
        
        Attach this script to the startup scripts option in a
        GPO that affects the computers you wish to disable
        IPV6 on.
    .LINK
        https://code.google.com/p/mod-posh/wiki/Production/Disable-Ipv6
 #>
[CmdletBinding()]
Param
    (
    )
Begin
    {
        $ScriptName = $MyInvocation.MyCommand.ToString()
        $ScriptPath = $MyInvocation.MyCommand.Path
        $Username = $env:USERDOMAIN + "\" + $env:USERNAME
 
        New-EventLog -Source $ScriptName -LogName 'Windows Powershell' -ErrorAction SilentlyContinue
 
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nStarted: " + (Get-Date).toString()
        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message
 
        #	Dotsource in the functions you need.
        }
Process
    {
        New-ItemProperty “HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters\” -Name  “DisabledComponents” -Value  0xffffffff -PropertyType “DWord”
        }
End
    {
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message	
        }