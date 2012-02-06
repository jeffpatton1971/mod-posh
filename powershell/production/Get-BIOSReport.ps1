<#
    .SYNOPSIS
        Get-BIOSReport
    .DESCRIPTION
        This script walks AD and returns information about udating the BIOS
    .PARAMETER
    .EXAMPLE
    .NOTES
        ScriptName:
        Created By: Jeff Patton
        Date Coded:
        ScriptName is used to register events for this script
        LogName is used to determine which classic log to write to
    .LINK
#>
Param
    (
    [parameter(Mandatory=$true, HelpMessage="Enter an LDAP url.")]
     $ADSPath
    )
Begin
    {
        $ScriptName = $MyInvocation.MyCommand.ToString()
        $LogName = "Application"
        $ScriptPath = $MyInvocation.MyCommand.Path
        $Username = $env:USERDOMAIN + "\" + $env:USERNAME

        New-EventLog -Source $ScriptName -LogName $LogName -ErrorAction SilentlyContinue

        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nStarted: " + (Get-Date).toString()
        Write-EventLog -LogName $LogName -Source $ScriptName -EventID "100" -EntryType "Information" -Message $Message 

        . .\includes\ActiveDirectoryManagement.ps1
        . .\includes\DellWebsiteFunctions.ps1
        
        $Computers = Get-ADObjects -ADSPath $ADSPath
    }
Process
    {   
        $Jobs = @()
        Foreach ($Computer in $computers)
        {
            If ($computer.properties.name -ne $null)
                {
                    $Jobs += Get-DellBIOSReport -ComputerName $Computer.Properties.name
                }
        }
    }
End
    {
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName $LogName -Source $ScriptName -EventID "100" -EntryType "Information" -Message $Message
        
        Return $Jobs
    }
