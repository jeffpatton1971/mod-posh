<#
.SYNOPSIS
    Setup permissions for Zenoss monitoring on Windows
.DESCRIPTION
    This script works under the assumption that you have a GPO or manually added your zenoss user to several groups.
    In testing these are the groups that appear to work
        Backup Operators
        Distributed COM Users
        Event Log Readers
        Performance Log Users
        Performance Monitor Users
        Users
    This script will setup the zenoss user to access the WMI namespace root, and all nodes below. If this isn't 
    what you want comment out the two lines with $Inheritance in them.
.PARAMETER Class
    This is the ROOT class by default, but could be any class you wish
.PARAMETER Principal
    This is the DOMAIN\Username of your monitoring account
.EXAMPLE
    .\Set-ZenossPermissions.ps1 -Principal "Domain\Username"

    Description
    -----------
    This is the only syntax for this script.
.NOTES
    ScriptName : Set-ZenossPermissions.ps1
    Created By : jspatton
    Date Coded : 12/23/2014 16:58:30
    ScriptName is used to register events for this script
 
    ErrorCodes
        100 = Success
        101 = Error
        102 = Warning
        104 = Information

    This should be run elevated
.LINK
    https://gist.github.com/jeffpatton1971/d8460a45117192817ef3
#>
[CmdletBinding()]
Param
(
    [string]$Class = "root",
    [string]$Principal = "DOMAIN\UserName"
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
    $security = Get-WmiObject -Namespace $Class -Class __SystemSecurity
    $binarySD = @($null)
    $result = $security.PsBase.InvokeMethod("GetSD",$binarySD)

    $ID = new-object System.Security.Principal.NTAccount($Principal)
    $sid = $ID.Translate( [System.Security.Principal.SecurityIdentifier] ).toString()
    #
    # Convert the current permissions to SDDL 
    #
    $converter = new-object system.management.ManagementClass Win32_SecurityDescriptorHelper
    $CurrentWMISDDL = $converter.BinarySDToSDDL($binarySD[0])
    #
    # Set SDDL
    #
    $InheritanceSDDL = "(A;CI;CCDCLCSWRPWPRCWD;;;BA)"
    $RemoteEnableSDDL = "(A;CI;CCDCWP;;;$($sid))"
    #
    # Assign SDDL
    #
    $NewWMISDDL = $CurrentWMISDDL.SDDL += $InheritanceSDDL
    $NewWMISDDL = $CurrentWMISDDL.SDDL += $RemoteEnableSDDL
    #
    # Convert SDDL back to Binary 
    #
    $WMIbinarySD = $converter.SDDLToBinarySD($NewWMISDDL)
    $WMIconvertedPermissions = ,$WMIbinarySD.BinarySD

    $result = $security.PsBase.InvokeMethod("SetSD",$WMIconvertedPermissions) 
    if($result='0'){write-host "`t`tApplied WMI Security complete."}
    #
    # Configure non-admin access to services
    #
    Start-Process -FilePath cmd.exe -ArgumentList "/c sc sdset SCMANAGER D:(A;;CCLCRPRC;;;AU)(A;;CCLCRPWPRC;;;SY)(A;;KA;;;BA)S:(AU;FA;KA;;;WD)(AU;OIIOFA;GA;;;WD)"
    Start-Process -FilePath netsh -ArgumentList "firewall set service remoteadmin enable"
    }
End
{
    $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
    Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message
    }