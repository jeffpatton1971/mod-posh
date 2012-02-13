<#
    .SYNOPSIS
        Returns the length of time a server was offline.
    .DESCRIPTION
        This script works in conjunction with an Event Trigger on the System
        event. This script queries the System log for EventID 11, and returns
        when the computer went offline, when it came back online and how long
        it was unavailable.
               
        It outputs an XML file to the Reports directory which it creates if
        it doesn't exist already.
    .PARAMETER FileName
        The fully qualified path and filename for the report.
    .EXAMPLE
        Get-OutageDuration.ps1
        
        Description
        -----------
        This is the only syntax for this script.
    .NOTES
        ScriptName : Get-OutageDuration.ps1
        Created By : jeffpatton.admin
        Date Coded : 10/26/2011 17:12:21
        ScriptName is used to register events for this script
        LogName is used to determine which classic log to write to
 
        ErrorCodes
            100 = Success
            101 = Error
            102 = Warning
            104 = Information
    .LINK
        https://code.google.com/p/mod-posh/wiki/Get-OutageDuration.ps1
#>
Param
    (
        $FileName = "NetworkOutage-$((get-date -format "yyyMMdd-hhmmss")).xml"
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
        $Online = $false
        $Events = Get-WinEvent -LogName System
        }
Process
    {
        foreach ($Event in $Events)
        {
            if ($Event.id -eq 11)
            {
                $Online = $true
                }
            if ($Online)
            {
                if ($Event.id -eq 11)
                {
                    $Connected = $Event
                    }
                if ($event.id -eq 4)
                {
                    $Disconnected = $Event
                    Break
                    }
                }
            }
        $Outage = New-Object -TypeName PSObject -Property @{
            ComputerName = $Connected.MachineName
            Offline = $Disconnected.TimeCreated
            Online = $Connected.TimeCreated
            TotalOutage = $Connected.TimeCreated - $Disconnected.TimeCreated
            }
        }
End
    {
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName $LogName -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message	
        Export-Clixml -Path "C:\StorageReports\$($FileName)" -InputObject $Outage
        }
