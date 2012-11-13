<#
    .SYNOPSIS
        This script will return the NTDS Diagnostic levels
    .DESCRIPTION
        This script will return the value for each of the 24 different Diagnostic Logging
        options available. For the complete list please see the related links section of
        this help file.
        
        When used alone it will report only the values where the Diagnostic Subkey varies
        from the default of 0. Optionally you can pass the All switch to the script and
        it will return all the subkeys in the NTDS Diagnostic logging key.
        
        This script can be used in conjunction with the Set-NtdsDiagnosticLogging.ps1
        script. When used in this fashion you can update all they keys to a specific 
        level or reset keys that have values that differ from default to their default
        values.
    .PARAMETER All
        A switch that if present will allow the script to return all keys and values
        from the NTDS Diagnostic key.
    .EXAMPLE
        .\Get-NtdsDiagnosticLogging.ps1

        DiagnosticSubkey         Value
        ----------------         -----
        6 Garbage Collection         1
        16 LDAP Interface Events     3

        Description
        -----------
        The default syntax of the command will only return key | value pairs that 
        have values that differ from the default.
    .EXAMPLE
        .\Get-NtdsDiagnosticLogging.ps1 -All

        DiagnosticSubkey                Value
        ----------------                -----
        1 Knowledge Consistency Checker     0
        2 Security Events                   0
        3 ExDS Interface Events             0
        4 MAPI Interface Events             0
        5 Replication Events                0
        6 Garbage Collection                1
        7 Internal Configuration            0
        8 Directory Access                  0
        9 Internal Processing               0
        10 Performance Counters             0
        11 Initialization/Termination       0
        12 Service Control                  0
        13 Name Resolution                  0
        14 Backup                           0
        15 Field Engineering                0
        16 LDAP Interface Events            3
        17 Setup                            0
        18 Global Catalog                   0
        19 Inter-site Messaging             0
        20 Group Caching                    0
        21 Linked-Value Replication         0
        22 DS RPC Client                    0
        23 DS RPC Server                    0
        24 DS Schema                        0
        
        Description
        -----------
        This example shows passing the -All switch into the script.
    .EXAMPLE
        .\Get-NtdsDiagnosticLogging.ps1 |.\Set-NtdsDiagnosticLogging.ps1


        DiagnosticSubkey         Value
        ----------------         -----
        6 Garbage Collection         1
        6 Garbage Collection         0
        16 LDAP Interface Events     3
        16 LDAP Interface Events     0

        Description
        -----------
        This example shows passing the output to Set-NtdsDiagnosticLogging.ps1. Here the
        existing value is displayed first and then the updated value. This output is
        from the Set-NtdsDiagnosticLogging.ps1 script.
    .NOTES
        ScriptName : Get-NtdsDiagnosticLogging.ps1
        Created By : jspatton
        Date Coded : 07/12/2012 08:30:21
        ScriptName is used to register events for this script
 
        ErrorCodes
            100 = Success
            101 = Error
            102 = Warning
            104 = Information
    .LINK
        https://code.google.com/p/mod-posh/wiki/Production/Get-NtdsDiagnosticLogging.ps1
    .LINK
        http://technet.microsoft.com/en-us/library/cc961809.aspx
#>
[CmdletBinding()]
Param
    (
    [string]$RegPath = 'HKLM:\SYSTEM\CurrentControlSet\services\NTDS\Diagnostics\',
    [switch]$All
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
        $DiagnosticSubkeys = ('1 Knowledge Consistency Checker','2 Security Events',
            '3 ExDS Interface Events','4 MAPI Interface Events','5 Replication Events',
            '6 Garbage Collection','7 Internal Configuration','8 Directory Access',
            '9 Internal Processing','10 Performance Counters','11 Initialization/Termination',
            '12 Service Control','13 Name Resolution','14 Backup','15 Field Engineering',
            '16 LDAP Interface Events','17 Setup','18 Global Catalog','19 Inter-site Messaging', 
            '20 Group Caching','21 Linked-Value Replication','22 DS RPC Client','23 DS RPC Server','24 DS Schema')
        }
Process
    {
        foreach ($DiagnosticSubkey in $DiagnosticSubkeys)
        {
            try
            {
                Write-Verbose "Retrieve the value of $($DiagnosticSubkey) and store in an object"
                $Result = New-Object -TypeName PSObject -Property @{
                    DiagnosticSubkey = $DiagnosticSubkey
                    Value = (Get-ItemProperty -Path $RegPath).$DiagnosticSubkey
                    }
                if ($All)
                {
                    Write-Verbose "Return all the values."
                    $Result |Select-Object -Property DiagnosticSubkey, Value
                    }
                else
                {
                    Write-Verbose "Return specific values."
                    $Result |Where-Object {$_.Value -gt 0} |Select-Object -Property DiagnosticSubkey, Value
                    }
                }
            catch
            {
                $Message = $Error[0]
                Write-Error $Message
                break
                }
            }
        }
End
    {
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message
        }