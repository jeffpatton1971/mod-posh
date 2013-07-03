<#
    .SYNOPSIS
        A script to create the OUA Group
    .DESCRIPTION
        This script creates the OUA group for administering departmental OUs
    .PARAMETER AnyWriteaeblDC
        This is the FQDN of a writeable DC in the domain
    .PARAMETER Name
        The name of the OUA group to create
    .PARAMETER Member
        The first member of the group
    .PARAMETER Description
        A brief description of the groups purpose
    .EXAMPLE
        .\Create-OuAdminGroup.ps1 -Name _OUA_PHARM -Member jspatton_a -Description 'OU Group for administergin Pharmacy OU'
    .NOTES
        ScriptName : Create-OuAdminGroup.ps1
        Created By : jspatton
        Date Coded : 01/14/2013 16:05:05
        ScriptName is used to register events for this script
 
        ErrorCodes
            100 = Success
            101 = Error
            102 = Warning
            104 = Information
    .LINK
        https://code.google.com/p/mod-posh/wiki/Production/Create-OuAdminGroup.ps1
#>
[CmdletBinding()]
Param
    (
    [string]$AnyWriteableDC = 'adhome-idm-01.home.ku.edu',
    [Parameter(Mandatory=$true)]
    [string]$Name,
    [Parameter(Mandatory=$true)]
    [string]$Member,
    [Parameter(Mandatory=$true)]
    [string]$Description
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
            Write-Verbose 'Load the Quest Cmdlets'
            Add-PSSnapin Quest.ActiveRoles.ADManagement
            Write-Verbose 'Connect to DC'
            Connect-QADService -service $AnyWriteableDC
            }
        catch
        {
            Write-Verbose 'Are the Quest cmdlets installed?'
            break
            }
        $ParentContainer = "OU=OU_Administration,OU=AD,DC=HOME,DC=KU,DC=EDU"
        }
Process
    {
        try
        {
            Write-Verbose "Creating OUA Group $($Name)"
            New-QADGroup -ParentContainer $ParentContainer -Name $Name -SamAccountNam $Name -Member $Member -Description $Description
            Write-Verbose "Adding $($Name) to _OUA_Everyone"
            Add-QADGroupMember -Identity "_OUA_Everyone" -Member $Name
            Write-Verbose "Adding $($Name) to _SCCM_Console_Access"
            Add-QADGroupMember -Identity "_SCCM_Console_Access" -Member $Name
            Write-Verbose "Adding $($Name) to Group Policy Creator Owners"
            Add-QADGroupMember -Identity "Group Policy Creator Owners" -Member $Name
            }
        catch
        {
            $Message = $Error[0].Exception
            Write-Error $Message
            Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "101" -EntryType "Error" -Message $Message	
            }
        }
End
    {
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message
        }