<#
    .SYNOPSIS
        Get the owner of the object
    .DESCRIPTION
        This script will return the owner of the provided object
    .PARAMETER LdapUri
        This the Ldap path to the object in question
    .EXAMPLE
        .\Get-AccountOwner.ps1 -LdapUri "cn=user,ou=employees,dc=company,dc=com"

        Account                                   Owner
        -------                                   -----
        cn=user,ou=employees,dc=company,dc=com    COMPANY\Domain Admins

        Description
        -----------

        This is the basic syntax of the command, remember if a Domain Admin
        creates the account, then Domain Admins own the account.
    .EXAMPLE
        "cn=user1,ou=employees,dc=company,dc=com","cn=user2,ou=employees,dc=company,dc=com" |.\Get-AccountOwner.ps1

        Account                                    Owner
        -------                                    -----
        cn=user1,ou=employees,dc=company,dc=com    COMPANY\Domain Admins
        cn=user2,ou=employees,dc=company,dc=com    COMPANY\Domain Admins
        
        Description
        -----------

        This example shows how to pipe uri's into the script.
    .NOTES
        ScriptName : Get-AccountOwner.ps1
        Created By : jspatton
        Date Coded : 07/11/2013 15:19:15
        ScriptName is used to register events for this script
 
        ErrorCodes
            100 = Success
            101 = Error
            102 = Warning
            104 = Information

        This script wraps around dsacls, see the LINK section for information
        on how to use this tool. Dsacls must be available on the system for
        this script to function properly.
    .LINK
        https://code.google.com/p/mod-posh/wiki/Playground/Get-AccountOwner.ps1
    .LINK
        http://technet.microsoft.com/en-us/library/cc771151(v=WS.10).aspx
#>
[CmdletBinding()]
Param
    (
    [Parameter(ValueFromPipeline=$True)]
    [string]$LdapUri
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

        if (!(Test-Path C:\Windows\System32\dsacls.exe))
        {
            Write-Host "dsacls not found in the default location"
            break
            }
        }
Process
    {
        foreach ($UserUri in $LdapUri)
        {
            $Owner = (dsacls $UserUri |Select-String "owner:").ToString().Trim()
            New-Object -TypeName psobject -Property @{
                Account = $LdapUri
                Owner = $Owner.Substring(7,$Owner.Length-7)
                }
            }
        }
End
    {
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message
        }