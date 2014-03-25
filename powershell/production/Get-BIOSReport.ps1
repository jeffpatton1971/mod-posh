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
        https://code.google.com/p/mod-posh/wiki/Get-BiosReport
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

        Try
        {
            Import-Module .\includes\ActiveDirectoryManagement.psm1
            Import-Module .\includes\DellWebsiteFunctions.psm1
            }
        Catch
        {
            Write-Warning "Must have the ActiveDirectoryManagement or DellWebsiteFunctions Modules available."
            Write-EventLog -LogName $LogName -Source $ScriptName -EventID "101" -EntryType "Error" -Message "ActiveDirectoryManagement or DellWebsiteFunctions Modules Not Found"
            Break
            }
        
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
