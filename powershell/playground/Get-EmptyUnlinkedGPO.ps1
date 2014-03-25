<#
    .SYNOPSIS
        Template script
    .DESCRIPTION
        This script sets up the basic framework that I use for all my scripts.
    .PARAMETER
    .EXAMPLE
    .NOTES
        ScriptName : Get-EmptyUnlinkedGPO.ps1
        Created By : jspatton
        Date Coded : 09/11/2013 09:16:51
        ScriptName is used to register events for this script
 
        ErrorCodes
            100 = Success
            101 = Error
            102 = Warning
            104 = Information
    .LINK
        https://code.google.com/p/mod-posh/wiki/Production/Get-EmptyUnlinkedGPO.ps1
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
        try
        {
            Import-Module GroupPolicy
            Import-Module C:\powershell\Production\includes\ActiveDirectoryManagement.psm1
            }
        catch
        {
            Write-Error $Error[0]
            break
            }
        }
Process
    {
        foreach ($Gpo in (Get-GPO -All))
        {
            if ($Gpo.Computer.DSVersion -eq 0 -and $Gpo.User.DSVersion -eq 0)
            {
                $Links = Get-GpoLink -Gpo $Gpo.Id.Guid
                if (!($Links))
                {
                    $Gpo.DisplayName
                    }
                }
            }
        }
End
    {
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message
        }