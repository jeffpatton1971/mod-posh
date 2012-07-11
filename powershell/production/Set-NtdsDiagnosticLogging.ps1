<#
    .SYNOPSIS
        This script will change the NTDS Diagnostic logging level
    .DESCRIPTION
        This script is used to modify the NTDS Diagnostic logging level in the registry
        of a Domain Controller. There are a total of 24 Dword values in the Diagnostics
        subkey, and their values range from 0 (default) to 5 (verbose). This script
        should make it easy to set those values as needed.
        
        When run on it's own the script will set the provided key to it's default of 0.
    .PARAMETER LoggingLevel
        This is an integer between 0 and 5. This parameter defaults to 0.
    .PARAMETER DiagnosticSubkey
        This is one of 24 entries possible.

            1 Knowledge Consistency Checker
            2 Security Events
            3 ExDS Interface Events
            4 MAPI Interface Events
            5 Replication Events
            6 Garbage Collection
            7 Internal Configuration
            8 Directory Access
            9 Internal Processing
            10 Performance Counters
            11 Initialization/Termination
            12 Service Control
            13 Name Resolution
            14 Backup
            15 Field Engineering
            16 LDAP Interface Events
            17 Setup
            18 Global Catalog
            19 Inter-site Messaging
            20 Group Caching
            21 Linked-Value Replication
            22 DS RPC Client
            23 DS RPC Server
            24 DS Schema
    .PARAMETER RegPath
        Currently these keys are stored in HKLM:\SYSTEM\CurrentControlSet\services\NTDS\Diagnostics
        this is the default value for this parameter.
    .EXAMPLE
        .\Set-NtdsDiagnosticLogging.ps1 -DiagnosticSubKey '1 Knowledge Consistency Checker'
        
        Description
        -----------
        This example shows the basic syntax of the command, and set's the value of KCC Logging to 0
    .EXAMPLE
        .\Set-NtdsDiagnosticLogging.ps1 -LoggingLevel 3 -DiagnosticSubKey '1 Knowledge Consistency Checker'
        
        Description
        -----------
        This example shows the basic syntax of the command, and set's the value of KCC Logging to 3
    .NOTES
        ScriptName : Set-NtdsDiagnosticLogging.ps1
        Created By : jspatton
        Date Coded : 07/11/2012 16:30:17
        ScriptName is used to register events for this script
 
        ErrorCodes
            100 = Success
            101 = Error
            102 = Warning
            104 = Information
    .LINK
        https://code.google.com/p/mod-posh/wiki/Production/Set-NtdsDiagnosticLogging.ps1
    .LINK
        http://technet.microsoft.com/en-us/library/cc961809.aspx
#>
[CmdletBinding()]
Param
    (
    [ValidateRange(0,5)]
    [int]$LoggingLevel = 0,
    [ValidateSet('1 Knowledge Consistency Checker','2 Security Events','3 ExDS Interface Events','4 MAPI Interface Events','5 Replication Events','6 Garbage Collection','7 Internal Configuration','8 Directory Access','9 Internal Processing','10 Performance Counters','11 Initialization/Termination','12 Service Control','13 Name Resolution','14 Backup','15 Field Engineering','16 LDAP Interface Events','17 Setup','18 Global Catalog','19 Inter-site Messaging', '20 Group Caching','21 Linked-Value Replication','22 DS RPC Client','23 DS RPC Server','24 DS Schema')]
    [string]$DiagnosticSubkey,
    [string]$RegPath = 'HKLM:\SYSTEM\CurrentControlSet\services\NTDS\Diagnostics\'
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

        }
Process
    {
        Write-Verbose "Storing previous logging level in the log"
        [int]$CurrentLoggingLevel = (Get-ItemProperty -Path $RegPath).$DiagnosticSubkey
        $Message = "The exising level for $($RegPath)\$($DiagnosticSubkey) is $($CurrentLoggingLevel)"
        Write-Verbose $Message
        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message
        
        Write-Verbose "Setting new logging level"
        try
        {
            Set-ItemProperty -Path $RegPath -Name $DiagnosticSubkey -Value $LoggingLevel
            $Message = "Updated $($RegPath)\$($DiagnosticSubkey) to $($LoggingLevel)"
            Write-Verbose $Message
            Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message
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