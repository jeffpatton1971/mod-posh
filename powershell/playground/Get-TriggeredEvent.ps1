
<#
    .SYNOPSIS
        Template script
    .DESCRIPTION
        This script sets up the basic framework that I use for all my scripts.
    .PARAMETER EventID
        The EventID that triggered this script to run.
    .PARAMETER EventLog
        The EventLog that the EventID can be found in.
    .PARAMETER TriggerName
        The name of the EventTrigger, this becomes a directory within LogPath
        to keep like reports together.
    .PARAMETER LogPath
        A file path to store event reports in. This can be a path on a local 
        disk or a UNC path.
    .PARAMETER EmailTo
        The email address to send notifications to.
    .PARAMETER EmailSMTP
        The address of the SMTP server to send emails from.
    .EXAMPLE
        .\Get-TriggeredEvent.ps1 -EventID 100 -EventLog System -TriggerName '100 Events' -LogPath C:\LogFiles

        Description
        -----------
        This example shows the basic usage of the command. This command searches for EventID 100 in
        the System log, and stores a report in C:\LogFiles
    .EXAMPLE
        .\Get-TriggeredEvent.ps1 -EventID 100 -EventLog System -TriggerName '100 Events' -LogPath C:\LogFiles `
             -EmailTo administrator@company.com -EmailSMTP smtp.company.com

        Description
        -----------
        This example shows using the command to also send a notification email.  This command searches 
        for EventID 100 in the System log, and stores a report in C:\LogFiles. Additionally it will
        send an email to administrator@company.com using the specified smtp server.
    .NOTES
        ScriptName : Get-TriggeredEvent.ps1
        Created By : Jeff Patton
        Date Coded : 10/29/2011 07:14:36
        ScriptName is used to register events for this script
        LogName is used to determine which classic log to write to
 
        ErrorCodes
            100 = Success
            101 = Error
            102 = Warning
            104 = Information

        LogPath
        -------
        If this path is a UNC path, the context which this script runs under must have modify permission
        on the share, and change permissions on the filesystem.
    .LINK
        http://scripts.patton-tech.com/wiki/PowerShell/Production/Get-TriggeredEvent.ps1
#>
#requires -version 2
[cmdletbinding()]
Param
    (
        [Parameter(Mandatory=$true)]
        $EventID,
        [Parameter(Mandatory=$true)]
        [string]$EventLog,
        [Parameter(Mandatory=$true)]
        [string]$TriggerName,
        [Parameter(Mandatory=$true)]
        $LogPath,
        [Parameter(Mandatory=$false)]
        [string]$EmailTo,
        [Parameter(Mandatory=$false)]
        [string]$EmailSMTP
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
        $Report = @()
        $FileName = "EventID-$($EventID)-$((Get-Date -Format "yyyMMdd-hhmmss")).xml"
        $LogPath = "$($LogPath)\$($TriggerName)\$($FileName)"
        $EmailFrom = ("$($env:USERNAME)@$($env:COMPUTERNAME).$($env:USERDNSDOMAIN)").ToLower()
        }
Process
    {
        $Events = Get-WinEvent -LogName $EventLog |Where-Object {$_.Id -eq $EventID}
        $Event = $Events[0]

        Write-Verbose "Build report based on EventID $($EventID)" 
        switch ($EventID)
        {
           #EventID
           #{
           #     $EmailSubject = ""
           #     $EmailBody = $Event.Message
           #     $Report = New-Object -TypeName PSObject -Property @{
           #          TimeCreated = $Event.TimeCreated
           #          MachineName = $Event.MachineName
           #          }
           #     }
            default
            {
                }
            }
        }
End
    {
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName $LogName -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message
        if ((Test-Path $LogPath) -ne $true)
        {
            New-Item $LogPath -ItemType Directory -Force
            }
        Export-Clixml -Path $LogPath -InputObject $Report
        if ($EmailSMTP -ne $null -and $EmailTo -ne $null)
        {
            Send-MailMessage -To $EmailTo -From $EmailFrom -Subject $EmailSubject -Body $EmailBody -SmtpServer $EmailSMTP
            }
        }
