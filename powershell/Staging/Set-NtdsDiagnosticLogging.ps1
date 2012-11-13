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
        .\Set-NtdsDiagnosticLogging.ps1 -DiagnosticSubKey '6 Garbage Collection'

        DiagnosticSubkey         Value
        ----------------         -----
        6 Garbage Collection         1
        6 Garbage Collection         0
        
        Description
        -----------
        This example shows the basic syntax of the command, and set's the value of 6 Garbage Collection
        to the default value of 0.
    .EXAMPLE
        .\Set-NtdsDiagnosticLogging.ps1 -LoggingLevel 3 -DiagnosticSubKey '6 Garbage Collection'
        
        DiagnosticSubkey         Value
        ----------------         -----
        6 Garbage Collection         0
        6 Garbage Collection         1
        
        Description
        -----------
        This example shows the basic syntax of the command, and set's the value of 6 Garbage Collection 
        back to its original value of 1.
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
    [ValidateSet('1 Knowledge Consistency Checker','2 Security Events',
                '3 ExDS Interface Events','4 MAPI Interface Events',
                '5 Replication Events','6 Garbage Collection',
                '7 Internal Configuration','8 Directory Access',
                '9 Internal Processing','10 Performance Counters',
                '11 Initialization/Termination','12 Service Control',
                '13 Name Resolution','14 Backup','15 Field Engineering',
                '16 LDAP Interface Events','17 Setup','18 Global Catalog',
                '19 Inter-site Messaging', '20 Group Caching','21 Linked-Value Replication',
                '22 DS RPC Client','23 DS RPC Server','24 DS Schema')]
    [Parameter(ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)]
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

        $CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = new-object System.Security.principal.windowsprincipal($CurrentUser)
        }
Process
    {      
        if (!$principal.IsInRole("Administrators")) 
        {
            $Message = 'You need to run this from an elevated prompt'
            Write-Error $Message
            Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "101" -EntryType "Error" -Message $Message
            }
        else
        {
            Write-Verbose "Storing previous logging level in the log"
            [int]$CurrentLoggingLevel = (Get-ItemProperty -Path $RegPath).$DiagnosticSubkey
            $Message = "The exising level for $($RegPath)\$($DiagnosticSubkey) is $($CurrentLoggingLevel)"
            Write-Verbose $Message
            Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message

            $Return = New-Object -TypeName PSObject -Property @{
                DiagnosticSubkey = $DiagnosticSubkey
                Value = $CurrentLoggingLevel
                }
            $Return |Select-Object -Property DiagnosticSubkey, Value
                
            Write-Verbose "Setting new logging level"
            try
            {
                Set-ItemProperty -Path $RegPath -Name $DiagnosticSubkey -Value $LoggingLevel
                $Return = New-Object -TypeName PSObject -Property @{
                    DiagnosticSubkey = $DiagnosticSubkey
                    Value = $LoggingLevel
                    }
                $Return |Select-Object -Property DiagnosticSubkey, Value
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
        }
End
    {
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message
        }