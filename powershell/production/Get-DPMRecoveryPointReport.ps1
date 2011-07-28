<#
    .SYNOPSIS
        Get-DPMRecoveryPointReport
    .DESCRIPTION
        This script sets up the basic framework that I use for all my scripts.
    .PARAMETER DPMServerName
        The FQDN of your DPM server
    .EXAMPLE
        Get-DPMRecoveryPointReport -DPMServerName dpm.company.com
        
        Name  BackupTime             Server                   DataSource    Location
        ----  ----------             ------                   ----------    --------
        P:\   7/23/2011 12:01:07 AM  fs.company.com  P:\ on fs.company.com  Disk
        P:\   7/24/2011 12:01:11 AM  fs.company.com  P:\ on fs.company.com  Disk
        P:\   7/25/2011 12:01:44 AM  fs.company.com  P:\ on fs.company.com  Disk
        P:\   7/26/2011 12:01:26 AM  fs.company.com  P:\ on fs.company.com  Disk

        Description
        -----------
        The basic usage and output of this script.
    .NOTES
        ScriptName: Get-DPMRecoveryPointReport
        Created By: Jeff Patton
        Date Coded: July 28, 2011
        ScriptName is used to register events for this script
        LogName is used to determine which classic log to write to
    .LINK
        http://scripts.patton-tech.com/wiki/PowerShell/Production/Get-DPMRecoveryPointReport
#>
Param
    (
    $DPMServerName = "dpm.soecs.ku.edu"
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

        $ProtectionGroups = Get-ProtectionGroup -DPMServerName $DPMServerName
        $Report = @()
    }
Process
    {
    If ($ProtectionGroups)
    {
        foreach ($ProtectionGroup in $ProtectionGroups)
        {
            if ($ProtectionGroup)
            {
                $DataSources = Get-Datasource -ProtectionGroup $ProtectionGroup

                foreach ($DataSource in $DataSources)
                {
                    $RecoveryPoints = Get-RecoveryPoint -Datasource $DataSource
                    foreach ($RecoveryPoint in $RecoveryPoints)
                    {
                        $ThisRecoveryPoint = New-Object -TypeName PSObject -Property @{
                            Name = $RecoveryPoint.UserFriendlyName
                            BackupTime = $RecoveryPoint.RepresentedPointInTime
                            DataSource = "$($RecoveryPoint.DataSource.Name) on $($RecoveryPoint.DataSource.ProductionServerName)"
                            Server = $RecoveryPoint.DataSource.ProductionServerName
                            Location = $RecoveryPoint.DataLocation
                            }
                        $Report += $ThisRecoveryPoint
                        }
                    }
                }
            }
        }
    }
End
    {
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName $LogName -Source $ScriptName -EventID "100" -EntryType "Information" -Message $Message
        
        Return $Report
    }