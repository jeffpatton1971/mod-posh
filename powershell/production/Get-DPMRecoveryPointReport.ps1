<#
    .SYNOPSIS
        Return a list of available Recovery Points from a DPM server
    .DESCRIPTION
        This script connects to a DPM server and queries a particular Production
        Server for it's DataSource. It then returns a list of all Recovery Points
        available in that DataSource.
    .PARAMETER DPMServerName
        The name of the server that has DPM installed on it
    .PARAMETER ProtectedComputer
        The name of the protected computer.
    .EXAMPLE
        .\Get-DPMRecoveryPointReport.ps1 -DPMServerName 'dpm' -ProductionServerName 'fs'

        RecoveryPoint             Size Server                  DataSource                     DateTime
        -------------             ---- ------                  ----------                     --------
        P:\           3.40232849121094 fs.cluster.soecs.ku.edu P:\ on fs.cluster.soecs.ku.edu 10/6/2011 ...
        P:\            3.4023323059082 fs.cluster.soecs.ku.edu P:\ on fs.cluster.soecs.ku.edu 10/7/2011 ...
        P:\            3.4023323059082 fs.cluster.soecs.ku.edu P:\ on fs.cluster.soecs.ku.edu 10/8/2011 ...
        P:\            3.4023323059082 fs.cluster.soecs.ku.edu P:\ on fs.cluster.soecs.ku.edu 10/9/2011 ...

        Description
        -----------
        This example shows the basic syntax of the command and expected output. The
        Size property has been converted into Gigabytes.
    .NOTES
        ScriptName : Get-DPMRecoveryPointReport.ps1
        Created By : jspatton
        Date Coded : 10/11/2011 10:59:47
        ScriptName is used to register events for this script
        LogName is used to determine which classic log to write to
 
        ErrorCodes
            100 = Success
            101 = Error
            102 = Warning
            104 = Information

        You could adjust this script to suit your needs, I am really only interested
        in the date and size of a given Recovery Point.
    .LINK
        http://scripts.patton-tech.com/wiki/PowerShell/Production/Get-RecoveryPointReport
 #>
[CmdletBinding()]
Param
    (
        [Parameter(Mandatory=$true)]$DPMServerName = 'dpm',
        [Parameter(Mandatory=$true)]$ProtectedComputer
    )
Begin
    {
        $ScriptName = $MyInvocation.MyCommand.ToString()
        $LogName = "Application"
        $ScriptPath = $MyInvocation.MyCommand.Path
        $Username = $env:USERDOMAIN + "\" + $env:USERNAME
 
        New-EventLog -Source $ScriptName -LogName $LogName -ErrorAction SilentlyContinue
 
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nStarted: " + (Get-Date).toString()
        Write-EventLog -LogName $LogName -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message
 
        #	Dotsource in the functions you need.
        if (!(Get-PSSnapin |Where-Object {$_.Name -eq "Microsoft.DataProtectionManager.PowerShell"}))
        {
            try
            {
                Write-Verbose "Adding DPM Snap-in"
                Add-PSSnapin -Name "Microsoft.DataProtectionManager.PowerShell"
                }
            catch
            {
                Return $Error[0].Exception.InnerException.Message.ToString().Trim()
                }
            }

        Write-Verbose "Get the ProductionServer object that matches the ProtectedComputer, that actually has a DataSource."
        $ProdServer =  Get-ProductionServer -DPMServerName $DPMServerName `
            |Where-Object {$_.MachineName -eq $ProtectedComputer} `
            |Where-Object {$_.IsHavingDataSourcesProtected -eq $True}
        
        Write-Verbose "Get a list of the DataSources available on the ProductionServer"
        $DataSources = Get-Datasource -ProductionServer $ProdServer

        $Report = @()
        }
Process
    {
        Write-Verbose "Loop through each available DataSource"
        foreach ($DataSource in $DataSources)
        {
            Write-Verbose "Get a list of RecoveryPoints for each DataSource"
            $RecoveryPoints = Get-RecoveryPoint -Datasource $DataSource
            
            Write-Verbose "Loop through each available RecoveryPoint"
            foreach ($RecoveryPoint in $RecoveryPoints)
            {
                Write-Verbose "Check if the RecoveryPoint is not empty"
                if (!($RecoveryPoint -eq $null))
                {
                    Write-Verbose "Pulling UserFriendlyName, RepresentedPointIntTime and Size from this RecoveryPoint"
                    $LineItem = New-Object -TypeName PSobject -Property @{
                        RecoveryPoint = $RecoveryPoint.UserFriendlyName;
                        DateTime = $RecoveryPoint.RepresentedPointInTime;
                        Size = $RecoveryPoint.Size /1gb
                        DataSource = "$($RecoveryPoint.DataSource.Name) on $($RecoveryPoint.DataSource.ProductionServerName)"
                        Server = $RecoveryPoint.DataSource.ProductionServerName
                        Location = $RecoveryPoint.DataLocation
                        }
                    $Report += $LineItem
                    }
                }
            }
        }
End
    {
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName $LogName -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message	
        Return $Report
        }
