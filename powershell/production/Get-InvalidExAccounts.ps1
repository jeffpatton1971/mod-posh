<#
    .SYNOPSIS
        A simple script to return a list of AD objects that may cause Exchange to be angry
    .DESCRIPTION
        This script will return a list of user objects from Active Directory that have 
        problems with their accounts as identified from the Exchange Get-Mailbox cmdlet.

        Accounts that seem to cause problems are missing some properties, and some properties 
        are misconfigured. This script will test for the following:

        samAccountname has a trailing space
        displayName is missing
        primarySMTP is not defined

        In our environment, AD objects are populated via 3rd party software, and sometimes
        bugs work their way into the system. This script can output a list of objects that
        have slipped through the cracks.
    .PARAMETER AdsPath
        What OU to look for in AD
    .PARAMETER LdapFilter
        Look for user accounts please
    .EXAMPLE
        .\Get-InvalidExAccounts.ps1

        samAccountName displayName primarySmtp trailingspace
        -------------- ----------- ----------- -------------
        user01                                 True         
        user02         False                                
        user03         False                                
        user04                     False                    
        user05                     False                    
        user06         False                                
        user07         False                                
        user08                     False                    

        Description
        -----------
        This example shows using the default syntax and paramters. Some explanation of the
        output may be necessary.

        user01 has a trailing space in their samAccountname
        user02, 03, 06 and 07 are missing a displayName
        user04, 05 and 08 don't have a primarySmtp set
    .NOTES
        ScriptName : Get-InvalidExAccounts.ps1
        Created By : jspatton
        Date Coded : 11/29/2012 17:04:11
        ScriptName is used to register events for this script
 
        ErrorCodes
            100 = Success
            101 = Error
            102 = Warning
            104 = Information
    .LINK
        https://code.google.com/p/mod-posh/wiki/Production/Get-InvalidExAccounts.ps1
 #>
[CmdletBinding()]
Param
    (
    [string]$AdsPath = "OU=Accounts,DC=company,DC=com",
    [string]$LdapFilter = "(objectCategory=user)"
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
            Import-Module C:\scripts\powershell\production\includes\ActiveDirectoryManagement.psm1 -ErrorAction SilentlyContinue
            Import-Module ActiveDirectory -ErrorAction SilentlyContinue
            }
        catch
        {
            }
        if (Get-Module activedirectory)
        {
            $Users = Get-ADObject -LDAPFilter $LdapFilter -Properties "samAccountname","displayname","proxyaddresses" -SearchBase $AdsPath
            }
        elseif (Get-Module ActiveDirectoryManagement)
        {
            $Users = Get-ADObjects -SearchFilter $LdapFilter -ADProperties "samAccountname","displayname","proxyaddresses" -ADSPath $AdsPath
            }
        $Result = @()
        }
Process
    {
        foreach ($User in $Users)
        {
            Write-Verbose "Set my object flags to null"
            $trailingSpace = $null
            $displayName = $null
            $primarySmtp = $null

            if ($User.Properties)
            {
                Write-Verbose "In case we are using my library and not passing in properties"
                $User = $User.Properties
                }
            [string]$samAccountName = $User.samaccountname
            if (($samAccountName).Substring(($samAccountName).Length -1,1) -contains ' ')
            {
                Write-Verbose "$($samAccountName) has a trailing space"
                $trailingSpace = "True"
                }

            if ($User.displayname -eq $null)
            {
                Write-Verbose "$($samAccountName) is missing a displayName property"
                $displayName = "False"
                }

            if ($User.proxyaddresses -ne $null)
            {
                Write-Verbose "Skipping where proxyaddresses property doesn't exist"
                Write-Verbose "Setting our flag to false for the primarySmtp test"
                $flag = $false
                foreach ($proxyAddress in $User.proxyaddresses)
                {
                    Write-Verbose "Assuming object is missing primary SMTP"
                    if ($proxyAddress -clike 'SMTP:*')
                    {
                        Write-Verbose "$($samAccountName) has a primary SMTP"
                        $flag = $true
                        }
                    }
                if (!($flag))
                {
                    Write-Verbose "$($samAccountName) is missing a primary SMTP"
                    $primarySmtp = "False"
                    }
                }
            if (($trailingSpace) -or ($displayName) -or ($primarySmtp))
            {
                $LineItem = New-Object -TypeName PSobject -Property @{
                    samAccountName = $samAccountName
                    displayName = $displayName
                    primarySmtp = $primarySmtp
                    trailingspace = $trailingSpace
                    }
                $Result += $LineItem
                }
            }
        }
End
    {
        Return $Result |Select-Object -Property samAccountName, displayname, primarySmtp, trailingSpace
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message
        }