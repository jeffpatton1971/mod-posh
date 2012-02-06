<#
    .SYNOPSIS
        Creates a new local admin account on a remote computer
    .DESCRIPTION
        This script creates a new local user account on domain joined computers.
    .PARAMETER ADSPath
        The LDAP URI to the collection of computers to update.
    .PARAMETER GroupName
        The name of the group to add the user to, the default is the Administrators group.
    .PARAMETER UserName
        The name of the user account to create
    .PARAMETER UserPass
        The new user account password
    .PARAMETER Description
        An optional description of the account to be created.
    .EXAMPLE
    .NOTES
        ScriptName: New-LocalAdmin.ps1
        Created By: Jeff Patton
        Date Coded: May 31, 2011
        ScriptName is used to register events for this script
        LogName is used to determine which classic log to write to
    .LINK
        https://code.google.com/p/mod-posh/wiki/Production/New-LocalAdmin
#>
Param
    (
        [Parameter(Mandatory=$true)]
        [String]$ADSPath,
        [String]$GroupName = "Administrators",
        [Parameter(Mandatory=$true)]
        [String]$UserAccount,
        [Parameter(Mandatory=$true)]
        [String]$UserPass,
        [String]$Description = "New User Account"
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
        . .\includes\ActiveDirectoryManagement.ps1
        . .\includes\ComputerManagement.ps1
        
        $LabComputers = Get-ADObjects -ADSPath $ADSPath
		$Jobs = @()
    }
Process
    {
                foreach ($LabComputer in $LabComputers)
                {
                    $NewUser = New-LocalUser -ComputerName $LabComputer.Properties.name -User $UserAccount -Password $UserPass -Description $Description
                    $GroupUpdate = Add-LocalUserToGroup -ComputerName $LabComputer.Properties.name -User $UserAccount -Group $GroupName
                    
                    $ThisJob = New-Object PSObject -Property @{
                        ComputerName = $($LabComputer.Properties.name)
                        NewUser = $($NewUser)
                        GroupUpdate = $($GroupUpdate)
                        }
                    $Jobs += $ThisJob
                    }
    }
End
    {
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName $LogName -Source $ScriptName -EventID "100" -EntryType "Information" -Message $Message	
        
        Return $Jobs
    }
