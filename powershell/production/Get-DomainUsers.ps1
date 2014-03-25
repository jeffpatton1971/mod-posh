<#
    .SYNOPSIS
        Return a list of user accounts from the domain.
    .DESCRIPTION
        This script uses the Get-ADObjects function to return a list of user objects. The
        name, pwdLastSet, userAccountControle, adsPath and lastLogonTimestamp are returned.
    .PARAMETER ADSPath
        The LDAP URL of your current domain
    .PARAMETER SearchFilter
        What to filter your query on
    .PARAMETER ADProperties
        A list of properties to return from AD
    .EXAMPLE
        Get-DomainUsers |Export-Csv -Path ./DomainUsers.csv -NoTypeInformation
    .NOTES
        ScriptName: Get-DomainUsers
        Created By: Jeff Patton
        Date Coded: 06/17/2011
        ScriptName is used to register events for this script
        LogName is used to determine which classic log to write to
    .LINK
        https://code.google.com/p/mod-posh/wiki/Get-DomainUsers
#>
Param
(
    $ADSPath = "LDAP://DC=company,DC=com",
    $SearchFilter = "(objectCategory=user)",
    $ADProperties = "name, pwdlastset, lastlogontimestamp, useraccountcontrol"
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

    #	Dotsource in the functions you need.
    Try
    {
        Import-Module .\includes\ActiveDirectoryManagement.psm1
        }
    Catch
    {
        Write-Warning "Must have the ActiveDirectoryManagement Module available."
        Write-EventLog -LogName $LogName -Source $ScriptName -EventID "101" -EntryType "Error" -Message "ActiveDirectoryManagement Module Not Found"
        Break
        }
    $Users = Get-ADObjects -ADSPath $ADSPath -SearchFilter $SearchFilter -ADProperties $ADProperties
    $Jobs = @()
    }

Process
{
    foreach ($User in $Users)
    {
        $AccountDisabled = $False
        
        if ($User.Properties.lastlogontimestamp -ne $null)
        {
            $LastLogonTimestamp = ([DateTime]::FromFileTime([Int64]::Parse($User.Properties.lastlogontimestamp)))
            }
        if ($User.Properties.pwdlastset -ne $null)
        {
            $PwdLastSet = ([DateTime]::FromFileTime([Int64]::Parse($User.Properties.pwdlastset)))
            }

        if ($User.Properties.useraccountcontrol -eq 514)
        {
            $AccountDisabled = $True
            }

        $ThisJob = New-Object -TypeName PSObject -Property @{
            ADSPath = $($User.Properties.adspath)
            Name = $($User.Properties.name)
            LastLogonTimestamp = $LastLogonTimestamp
            PwdLastSet = $PwdLastSet
            AccountDisabled = $AccountDisabled
            }
        $Jobs += $ThisJob
        }
    }

End
{
    Return $Jobs
    }
