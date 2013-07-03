<#
    .SYNOPSIS
        Template script
    .DESCRIPTION
        This script sets up the basic framework that I use for all my scripts.
    .PARAMETER
    .EXAMPLE
    .NOTES
        ScriptName : Deprovision-HomeDirectory
        Created By : jspatton
        Date Coded : 05/08/2013 17:10:21
        ScriptName is used to register events for this script
 
        ErrorCodes
            100 = Success
            101 = Error
            102 = Warning
            104 = Information
    .LINK
        https://code.google.com/p/mod-posh/wiki/Production/Deprovision-HomeDirectory
#>
[CmdletBinding()]
Param
    (
    $MorguePath = "\\groups1.home.ku.edu\morgue",
    $AdProperties = @("extensionAttribute15","name","homeDirectory"),
    $AdsPath = "ou=ku_users,dc=home,dc=ku,dc=edu",
    $SearchFilter = "(&(objectClass=user)(extensionAttribute15=1))",
    $SearchScope = "Subtree"
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
            Import-Module C:\scripts\powershell\production\includes\ActiveDirectoryManagement.psm1
            }
        catch
        {
            $Error[0].Exception
            break
            }
        $Users = Get-ADObjects -ADProperties $AdProperties -ADSPath $AdsPath -SearchFilter $SearchFilter -SearchScope $SearchScope
        }
Process
    {
        foreach ($User in $Users)
        {
            if ($User.extensionAttribute15 -eq 1)
            {
                try
                {
                    Write-Verbose "Move user folder to morgue"
                    Write-Verbose "Test if homeDirectory Path is valid"

#                    Move-Item [string]$User.homeDirectory "$($MorguePath)\$($User.name)"
                    Copy-Item "$($User.homeDirectory)" "$($MorguePath)\$($User.name)" -ErrorAction Stop
                    }
                catch
                {
                    $Error[0].Exception
                    Write-Host "An error was encountered move operation cancelled."
                    }
                }
            }
       }
End
    {
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message
        }