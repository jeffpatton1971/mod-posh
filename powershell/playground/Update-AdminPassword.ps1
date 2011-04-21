<#
    .SYNOPSIS
        Local administrator password update
    .DESCRIPTION
        This script changes the local administrator password.
    .PARAMETER ADSPath
        The ActiveDirectory namespace to search for computers
    .PARAMETER AdminAccount
        The username of the administrator account
    .PARAMETER NewPassword
        The new password
    .EXAMPLE
    .NOTES
        ScriptName is used to register events for this script
        LogName is used to determine which classic log to write to
    .LINK
#>
    Param
        (
            [Parameter(Mandatory=$true)]
            [string]$ADSPath,
            [Parameter(Mandatory=$true)]
            [string]$AdminAccount,
            [Parameter(Mandatory=$true)]
            [string]$NewPassword            
        )

    $ScriptName = $MyInvocation.MyCommand.ToString()
    $LogName = "Application"
    $ScriptPath = $MyInvocation.MyCommand.Path
    $Username = $env:USERDOMAIN + "\" + $env:USERNAME

	New-EventLog -Source $ScriptName -LogName $LogName -ErrorAction SilentlyContinue
	
	$Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nStarted: " + (Get-Date).toString()
	Write-EventLog -LogName $LogName -Source $ScriptName -EventID "100" -EntryType "Information" -Message $Message 
	
	. .\includes\ActiveDirectoryManagement.ps1
    . .\includes\ComputerManagement.ps1

    $Workstations = Get-ADObjects -ADSPath $ADSPath
    $Jobs = @()
	foreach ($Workstation in $Workstations)
        {
            [string]$ThisWorkstation = $Workstation.Properties.name
            $ThisJob = New-Object PSobject

            $Retval = Set-Pass -ComputerName $ThisWorkstation -UserName $AdminAccount -Password $NewPassword

            Add-Member -InputObject $ThisJob -MemberType NoteProperty -Name "ComputerName" -Value $ThisWorkstation
            Add-Member -InputObject $ThisJob -MemberType NoteProperty -Name "UserName" -Value $AdminAccount
            Add-Member -InputObject $ThisJob -MemberType NoteProperty -Name "Status" -Value $RetVal.Trim()
            $Jobs += $ThisJob
            $ThisJob
            }
            	
	$Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
	Write-EventLog -LogName $LogName -Source $ScriptName -EventID "100" -EntryType "Information" -Message $Message	