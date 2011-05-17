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
    }
Process
    {
        $Computers = Get-ADObjects -ADSPath "LDAP://OU=Labs,DC=soecs,DC=ku,DC=edu"
        Foreach ($Computer in $computers)
        {
            If ($computer.properties.name -ne $null)
                {
                    Get-DellBIOSReport -ComputerName $Computer.Properties.name
                }
        }
    }
End
    {
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName $LogName -Source $ScriptName -EventID "100" -EntryType "Information" -Message $Message	
    }