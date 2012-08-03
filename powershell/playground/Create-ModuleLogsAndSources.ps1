<#
    .SYNOPSIS
        A script to create the logs and sources for the modules I wrote.
    .DESCRIPTION
        This script will create individual logs and log sources for the modules
        that I have written. The log is named after the filename of the module
        and the sources are the actual function names inside the module.
        
        This script will only run from an admin prompt, so that the logs can
        be created.
    .PARAMETER
    .EXAMPLE
    .NOTES
        ScriptName : Create-ModuleLogsAndSources.ps1
        Created By : jspatton
        Date Coded : 07/20/2012 09:47:12
        ScriptName is used to register events for this script
 
        ErrorCodes
            100 = Success
            101 = Error
            102 = Warning
            104 = Information
        
        New-EventLog -LogName 'ActiveDirectory-Management-Module' -Source $MyInvocation.MyCommand.Name
    .LINK
        https://code.google.com/p/mod-posh/wiki/Production/Create-ModuleLogsAndSources.ps1
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
        $CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = new-object System.Security.principal.windowsprincipal($CurrentUser)

        if ($principal.IsInRole("Administrators") -eq $false) 
        {
            $Message = 'This script must be run as an administrator from an elevated prompt.'
            Write-Error $Message
            Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "101" -EntryType "Error" -Message $Message -ErrorAction SilentlyContinue
            break
            }
        }
Process
    {
        foreach ($ModuleFile in $ModuleFiles)
        {
            $Functions = (Get-Content $ModuleFile.FullName |Select-String -Pattern '^Function ') -replace ('function ','')
            $LognameAndSources = New-Object -TypeName PSobject -Property @{
                ModuleName = $ModuleFile.Name.Remove($ModuleFile.Name.IndexOf('.'),5)+"-Module"
                Functions = $Functions
                }
            foreach ($Function in $LognameAndSources.Functions)
            {
                New-EventLog -LogName $LognameAndSources.ModuleName -Source $Function
                }
            }
        }
End
    {
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message
        }