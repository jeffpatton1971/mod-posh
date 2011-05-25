<#
    .SYNOPSIS
        Update lab computers
    .DESCRIPTION
        This script updates the Administrators group on the lab computers. This could be done
        with a GPO, but sometimes our requirements change and this is easier and more immediate.
    .PARAMETER ADSPath
        A valid LDAP URI to the OU containing the computers to update.
    .PARAMETER GroupName
        The name of the group to add to Administrators.
    .PARAMETER DomainName
        The NetBIOS domain name of your domain.
    .EXAMPLE
        Update-LabComputers -ADSPath "LDAP://OU=Workstations,DC=company,DC=com" -GroupName "StudentAdmins" -DomainName "COMPANY"
        
        Description
        -----------
        The basic syntax of the script.
    .NOTES
        ScriptName: Update-LabComputers
        Created By: Jeff Patton
        Date Coded: May 24, 2011
        ScriptName is used to register events for this script
        LogName is used to determine which classic log to write to
    .LINK
        http://scripts.patton-tech.com/wiki/PowerShell/Production/Update-LabComputers
#>
Param
    (
        [Parameter(Mandatory=$true)]
        [String]$ADSPath,
        [Parameter(Mandatory=$true)]
        [String]$GroupName,
        [Parameter(Mandatory=$true)]
        [String]$DomainName
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
        
        $LabComputers = Get-ADObjects -ADSPath $ADSPath
		$Jobs = @()
    }
Process
    {
        foreach ($LabComputer in $LabComputers)
        {
            $Status = Add-DomainGroupToLocalGroup -ComputerName $LabComputer.Properties.name -DomainGroup $GroupName -UserDomain $DomainName
			
			$ThisJob = New-Object PSObject -Property @{
				ComputerName = $($LabComputer.Properties.name)
				Status = $Status
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