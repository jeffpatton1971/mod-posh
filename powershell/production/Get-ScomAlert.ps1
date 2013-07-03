<#
    .SYNOPSIS
        Script is triggered based on an alert in SCOM
    .DESCRIPTION
        This script is used to retrieve an event from SCOM based through
        Orchestrator. The idea behind this script is when an alert is thrown
        this script will capture that data, and write an event in a custom log
        on the Orchestrator server.

        This log is then consumed by Zenoss in order to generate a service-now
        ticket alerting the staff of a potential outage.
    .PARAMETER Id
        This is supplied from the Get-Alert Activity in the Runbook
    .EXAMPLE
        .\Get-ScomAlert.ps1 -Id "d651d28e-2bf8-4c4a-b4de-aabc962069c3"

        Description
        -----------
        This is how you could test the script to ensure it is working properly,
        otherwise this script is never directly run by a user. It is instead
        called from a runbook using the runbook service account.
    .NOTES
        ScriptName : Get-ScomAlert.ps1
        Created By : jspatton
        Date Coded : 12/31/2012 15:01:37
        ScriptName is used to register events for this script
 
        ErrorCodes
            100 = Success
            101 = Error
            102 = Warning
            104 = Information

        The runbook service account for your instance of Orchestrator must be a
        member of the OpsMgr Admins group.
    .LINK
        https://code.google.com/p/mod-posh/wiki/Production/Get-ScomAlert.ps1
#>
[CmdletBinding()]
Param
    (
    [string]$Id
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

        $rms = 'scom-01.home.ku.edu'
        try
        {
            Add-PSSnapin -Name Microsoft.EnterpriseManagement.OperationsManager.Client
            [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.EnterpriseManagement.OperationsManager")
            [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.EnterpriseManagement.OperationsManager.Common")
            Set-Location "OperationsManagerMonitoring::" 
            $MG = New-ManagementGroupConnection -ConnectionString:$rms
            Set-Location $rms 
            $Alert = Get-Alert -Id $Id
            }
        catch
        {
            $Message = $Error[0].Exception
            Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "101" -EntryType "Error" -Message $Message -ComputerName ittstscorch.home.ku.edu
            }
        }
Process
    {
        $AlertContext = ([xml]$Alert.Context).DataItem

        switch ($alert.Severity.ToString())
        {
            'Error'
            {
                $EntryType = "Error"
                $EventId = "101"
                }
            'Warning'
            {
                $EntryType = "Warning"
                $EventId = "102"
                }
            Default
            {
                # This should never happen generate an alert with new severity
                $EntryType = "Warning"
                $EventId = "102"
                }
            }

        $Hostname = $Alert.PrincipalName

        switch ($AlertContext.type)
        {
            'System.PropertyBagData'
            {
                $Source = $Alert.Category
                }
            'System.Performance.ConsecutiveSamplesData'
            {
                $Source = $Alert.Category
                }
            'System.Performance.BaseliningStateData'
            {
                $Source = $Alert.Category
                }
            'System.Performance.AverageData'
            {
                $Source = $Alert.Category
                }
            'System.Mom.BackwardCompatibility.Alert.Data'
            {
                $Source = $Alert.Category
                $EventId = $AlertContext.AlertContext.DataItem.EventNumber
                }
            'System.Event.LinkedData'
            {
                $Source = $AlertContext.type
                $EventId = $AlertContext.EventNumber
                }
            'System.CorrelatorData'
            {
                $Source = $AlertContext.type
                }
            'System.ConsolidatorData'
            {
                $Source = $AlertContext.type
                $EventId = $AlertContext.Context.DataItem.EventNumber
                }
            'System.Availability.StateData'
            {
                $Source = $AlertContext.type
                $Hostname = $AlertContext.hostname
                }
            'MonitorTaskDataType'
            {
                $Source = $AlertContext.type
                }
            'Microsoft.Windows.EventData'
            {
                $Source = $AlertContext.type
                $EventId = $AlertContext.EventNumber
                }
            }

        $Message = "Name : $($Alert.Name)`r`n"
        $Message += "Description : $($Alert.Description)`r`n"
        $Message += "Hostname : $($Hostname)`r`n"
        $Message += "OpsMgrId : $($Id)`r`n`r`n"
        $Message += "Context`r`n"
        $Message += $AlertContext |Out-String

        try
        {
            Write-EventLog -LogName 'SCOM alerts' -Source $Source -EntryType $EntryType -EventId $EventId -Message $Message -ComputerName ittstscorch.home.ku.edu
            }
        catch
        {
            Write-EventLog -LogName 'Windows Powershell' -Source 'Eventlog Runbook' -EventID "101" -EntryType "Error" -Message $Error[0].Exception -ComputerName ittstscorch.home.ku.edu
            Out-File C:\temp\error.txt -InputObject $Error[0].Exception -Append
            }
        }
End
    {
        if (!(Test-Path C:\temp))
        {
            New-Item C:\temp -ItemType Directory -Force
            }
        Out-File C:\temp\return.txt -InputObject $Alert -Append
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message
        }