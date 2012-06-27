<#
    .SYNOPSIS
        Template script
    .DESCRIPTION
        This script sets up the basic framework that I use for all my scripts.
    .PARAMETER
    .EXAMPLE
    .NOTES
        ScriptName : Toggle-Wireless.ps1
        Created By : jspatton
        Date Coded : 06/27/2012 08:54:56
        ScriptName is used to register events for this script
 
        ErrorCodes
            100 = Success
            101 = Error
            102 = Warning
            104 = Information
    .LINK
        https://code.google.com/p/mod-posh/wiki/Production/Toggle-Wireless.ps1
#>
[CmdletBinding()]
Param
    (
    [string]$ConnectionID = 'Wireless'
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
        $Wifi = Get-WmiObject -Class Win32_NetworkAdapter -Filter "NetConnectionID = '$($ConnectionID)'"
        $Battery = Get-WmiObject -Class Win32_Battery -Property BatteryStatus
        $principal = new-object System.Security.principal.windowsprincipal($CurrentUser)
        }
Process
    {
        if (!$wifi)
        {
            $Message = "Unable to find a wireless adapter named $($ConnectionID)"
            Write-Error $Message
            Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "101" -EntryType "Error" -Message $Message
            }
        else
        {
            if (!$principal.IsInRole("Administrators")) 
            {
                $Message = 'You need to run this from an elevated prompt'
                Write-Error $Message
                Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "101" -EntryType "Error" -Message $Message
                }
            else
            {
                if($Battery.BatteryStatus -eq 2)
                {
                    $Message = "The system has access to AC so no battery is being discharged. However, the battery is not necessarily charging."
                    Write-Verbose $Message
                    Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message
                    $Return = $Wifi.Disable()
                    if ($Return.ReturnValue -ne 0)
                    {
                        $Message = "Unable to disable wireless, the adapter returned: $($Return.ReturnValue)"
                        Write-Verbose $Message
                        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "101" -EntryType "Error" -Message $Message
                        }
                    }
                else
                {
                    $Return = $Wifi.Enable()
                    if ($Return.ReturnValue -ne 0)
                    {
                        $Message = "Unable to enable wireless, the adapter returned: $($Return.ReturnValue)"
                        Write-Verbose $Message
                        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "101" -EntryType "Error" -Message $Message
                        }
                    }
                }
            }
        }
End
    {
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message
        }