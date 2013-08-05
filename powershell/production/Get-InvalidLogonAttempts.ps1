<#
    .SYNOPSIS
        Return a list of invalid logon attempts.
    .DESCRIPTION
        This script queries the security log of a given computer and 
        retrieves Event ID 4625, failed logon attempt.
    .PARAMETER ComputerName
        The name of the computer to pull logs from 
    .PARAMETER LogName
        The name of the Event Log.
        
        You will notice that I have set the LogName to Security, since
        this particular script was designed to find a specific entry.
        This can be modified to suit your needs.
    .PARAMETER EventID
        The Event ID to return.
        
        You will notice that I have set the EventID to 4625, since
        this particular script was designed to find those particular
        entries. This can be modified to suit your needs.
    .PARAMETER Credentials
        A credential object to be passed to Get-Winevent
    .EXAMPLE
        .\Get-InvalidLogonAttempts.ps1 -ComputerName Desktop-pc1 -LogName 'Security' -EventID 4625
        
        Message        MachineName    TimeCreated   IpAddress         LogonType TargetUserNam IpPort
                                                                                e
        -------        -----------    -----------   ---------         --------- ------------- ------
        An account ... Desktop-pc1... 10/26/2011... ##.###.###...            10 Daniel        62581
        An account ... Desktop-pc1... 10/26/2011... ##.###.###...            10 Daniel        11369
        An account ... Desktop-pc1... 10/26/2011... ##.###.###...            10 Daniel        47575
        An account ... Desktop-pc1... 10/26/2011... ##.###.###...            10 Daniel        51144

        Description
        -----------
        This is the basic syntax of the command, the output is returned to stdin.
    .EXAMPLE
        .\Get-InvalidLogonAttempts.ps1 |Export-Csv -Path .\InvalidLoginAttempts.csv
        
        Description
        -----------
        This example shows redirecting the output through the Export-CSV command to get
        a csv file.
    .EXAMPLE
        .\Get-InvalidLogonAttempts.ps1 |Where-Object {(Get-Date($_.TimeCreated)) -eq (Get-Date)}
        Description
        -----------
        This example shows how to filter the output to get a list of events that happened today.
    .NOTES
        ScriptName : Get-InvalidLogonAttempts.ps1
        Created By : jspatton
        Date Coded : 10/26/2011 11:20:58
        ScriptName is used to register events for this script
        LogName is used to determine which classic log to write to
 
        ErrorCodes
            100 = Success
            101 = Error
            102 = Warning
            104 = Information
        
        If you adjust theh script to look for event id's other than 4625, you will
        want to examine the Event Properties. This is similar to viewing the 
        "Friendly" view of an event in the event log. Below are all the properties
        for Event ID 4625.
    
        00  SubjectUserSid S-1-5-18 
        01  SubjectUserName NODE1$ 
        02  SubjectDomainName SOECS 
        03  SubjectLogonId 0x3e7 
        04  TargetUserSid S-1-0-0 
        05  TargetUserName Daniel 
        06  TargetDomainName NODE1 
        07  Status 0xc000006d 
        08  FailureReason %%2313 
        09  SubStatus 0xc0000064 
        10  LogonType 10 
        11  LogonProcessName User32  
        12  AuthenticationPackageName Negotiate 
        13  WorkstationName NODE1 
        14  TransmittedServices - 
        15  LmPackageName - 
        16  KeyLength 0 
        17  ProcessId 0x3278 
        18  ProcessName C:\Windows\System32\winlogon.exe 
        19  IpAddress 75.127.226.131 
        20  IpPort 51144 
    .LINK
        https://code.google.com/p/mod-posh/wiki/Get-InvalidLogonAttempts
#>
[cmdletBinding()]
Param
    (
    $ComputerName = (& hostname),
    $LogName = "Security",
    $EventID = 4625,
    $Credentials = (Get-Credential)
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
    Write-Verbose "Get all $($EventID) events from the $($LogName) Log on $($ComputerName)"
    $Events = Get-WinEvent -ComputerName $ComputerName -LogName $LogName -Credential $Credentials |Where-Object {$_.Id -eq $EventID}
    }
Process
{
    Write-Verbose "Loop through each event that is returned from Get-WinEvent"
    foreach ($Event in $Events)
    {
        Write-Verbose "Create an object to hold the data I'm collecting"
        $ThisEvent = New-Object -TypeName PSObject -Property @{
            TimeCreated = $Event.TimeCreated
            MachineName = $Event.MachineName
            TargetUserName = $Event.Properties[5].Value
            LogonType = $Event.Properties[10].Value
            IpAddress = [net.ipaddress]$Event.Properties[19].Value
            IpPort = $Event.Properties[20].Value
            Message = $Event.Message
            }
        $Report += $ThisEvent
        }
    }
End
{
    $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
    Write-EventLog -LogName $LogName -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message
    Return $Report
    }
