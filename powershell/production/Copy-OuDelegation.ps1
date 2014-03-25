<#
    .SYNOPSIS
        Copy the permissions of one OU to a second OU
    .DESCRIPTION
        This script will copy the permissions from one OU to a seperate OU either in the 
        same domain or to a second domain to which you have admin rights.
    .PARAMETER SourceDN
        This is the LDAP path to the source ou
    .PARAMETER DestDN
        This is the LDAP path to the destination ou
    .PARAMETER Credential
        These are the credentials used to connect to AD
    .PARAMETER dCredential
        If a different domain these are seperate credentials, if left blank they
        default to the same as Credential.
    .EXAMPLE
    .NOTES
        ScriptName : Copy-Delegations.ps1
        Created By : jspatton
        Date Coded : 03/25/2014 12:45:57
        ScriptName is used to register events for this script
 
        ErrorCodes
            100 = Success
            101 = Error
            102 = Warning
            104 = Information
    .LINK
        https://code.google.com/p/mod-posh/wiki/Production/Copy-Delegations.ps1
#>
[CmdletBinding()]
Param
    (
    [string]$SourceDN,
    [string]$DestDN,
    [pscredential]$Credential,
    [pscredential]$dCredential = $Credential
    )
Begin
    {
        [string]$ScriptName = $MyInvocation.MyCommand.ToString()
        [string]$ScriptPath = $MyInvocation.MyCommand.Path
        [string]$Username = $env:USERDOMAIN + "\" + $env:USERNAME
 
        New-EventLog -Source $ScriptName -LogName 'Windows Powershell' -ErrorAction SilentlyContinue
 
        [string]$Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nStarted: " + (Get-Date).toString()
        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message
 
        #	Dotsource in the functions you need.
        if (!($SourceDN.Contains("LDAP")))
        {
            Write-Error "Please make sure your Source OU is in proper form : LDAP://ou=something,dc=something"
            break
            }
        if (!($DestDN.Contains("LDAP")))
        {
            Write-Error "Please make sure your Destination OU is in proper form : LDAP://ou=something,dc=something"
            break
            }
        }
Process
    {
        $ErrorActionPreference = "Stop"
        try
        {
            Write-Verbose "Connecting to $($SourceDN)"
            [System.DirectoryServices.DirectoryEntry]$SourceDirectoryEntry = New-Object System.DirectoryServices.DirectoryEntry($SourceDN, $Credential.UserName, $Credential.GetNetworkCredential().Password)
            Write-Verbose "Accessing security of $($SourceDN)"
            [System.Security.AccessControl.DirectoryObjectSecurity]$SourceSecurityDescriptor = $SourceDirectoryEntry.ObjectSecurity
            Write-Verbose "Storing the SDDL of $($SourceDN)"
            [string]$SourceSDDL = $SourceSecurityDescriptor.Sddl
            Write-Verbose "Connecting to $($DestDN)"
            [System.DirectoryServices.DirectoryEntry]$DestDirectoryEntry = New-Object System.DirectoryServices.DirectoryEntry($DestDN, $dCredential.UserName, $dCredential.GetNetworkCredential().Password)
            Write-Verbose "Setting the security of $($DestDN) to the SDDL of $($SourceDN)"
            $DestDirectoryEntry.ObjectSecurity.SetSecurityDescriptorSddlForm($SourceSDDL)
            Write-Verbose "Saving changes back to AD"
            $DestDirectoryEntry.CommitChanges()
            }
        catch
        {
            Write-Error $Error[0]
            $ErrorActionPreference = "Continue"
            break
            }
        }
End
    {
        [string]$Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message
        }