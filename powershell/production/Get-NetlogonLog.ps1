<#
    .SYNOPSIS
        Parse the netlogon.log file
    .DESCRIPTION
        This function will read in the netlogon.log file and return a properly 
        formatted object. A regex is used to split up each line of the file and
        build fields for the returned output.

        Some entries in the log will have an octal code, this code if found is 
        processed and a definition is returned as part of the object.
    .PARAMETER Logpath
        The path to where netlogon.log can be found, this is set to the default
        location

        C:\Windows\Debug\netlogon.log
    .PARAMETER DebugLog
        This switch if present directs the script to parse the debug version of
        the log as opposed to what normally shows up in the log.
    .EXAMPLE
        .\Get-NetlogonLog.ps1

        Date  Time     Message         Computer        Address
        ----  ----     -------         --------        -------
        10/13 15:08:30 NO_CLIENT_SITE: EBL2006         169.147.3.25
        10/13 15:38:30 NO_CLIENT_SITE: EBL2006         169.147.3.25
        10/13 16:08:30 NO_CLIENT_SITE: EBL2006         169.147.3.25

        Description
        -----------
        This example shows the basic syntax of the command when parsing a regular
        log file.
    .EXAMPLE
        .\Get-NetlogonLog.ps1 -DebugLog

        Date  Time     Type  Message                                                                                                                                           
        ----  ----     ----  -------                                                                                                                                           
        11/08 12:23:01 LOGON HOME: NlPickDomainWithAccount: WORKGROUP\Administrator:...
        11/08 12:23:01 LOGON HOME: SamLogon: Transitive Network logon of WORKGROUP\A...
        11/08 12:23:01 LOGON HOME: SamLogon: Transitive Network logon of WORKGROUP\A...
        11/08 12:23:01 LOGON HOME: NlPickDomainWithAccount: WORKGROUP\Administrator:...
        11/08 12:23:01 LOGON HOME: SamLogon: Transitive Network logon of WORKGROUP\A...

        Description
        -----------
        This example shows using the command with the DebugLog switch to parse
        the debug version of the netlogon.log file.
    .NOTES
        FunctionName : Get-NetlogonLog
        Created by   : jspatton
        Date Coded   : 11/08/2012 15:24:47

        You will need to be at an elevated prompt in order for this to work properly.
    .LINK
        https://code.google.com/p/mod-posh/wiki/Production/Get-NetlogonLog.ps1
 #>
[CmdletBinding()]
Param
    (
    [string]$LogPath = "C:\Windows\Debug\netlogon.log",
    [switch]$DebugLog
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

        $Codes = @{
        "0x0"="Successful Login"
        "0xC0000064"="The specified user does not exist"
        "0xC000006A"="The value provided as the current password is not correct"
        "0xC000006C"="Password policy not met"
        "0xC000006D"="The attempted logon is invalid due to bad user name"
        "0xC000006E"="User account restriction has prevented successful login"
        "0xC000006F"="The user account has time restrictions and may not be logged onto at this time"
        "0xC0000070"="The user is restricted and may not log on from the source workstation"
        "0xC0000071"="The user account's password has expired"
        "0xC0000072"="The user account is currently disabled"
        "0xC000009A"="Insufficient system resources"
        "0xC0000193"="The user's account has expired"
        "0xC0000224"="User must change his password before he logs on the first time"
        "0xC0000234"="The user account has been automatically locked"
        }

        if ($DebugLog)
        {
            [regex]$regex = "^(?<Date>\d{1,2}/\d{1,2})\s{1}(?<Time>\d{1,2}:\d{1,2}:\d{1,2})\s{1}(?<Type>\[[A-Z]*\])\s{1}(?<Message>.*)"
            [regex]$Code = "(?<Code>(\d{1}[x]\d{1})|(\d{1}[x]{1}[C]{1}\d{1,}))"
            }
        else
        {
            [regex]$regex = "^(?<Date>\d{1,2}/\d{1,2})\s{1}(?<Time>\d{1,2}:\d{1,2}:\d{1,2})\s{1}(?<Message>.*[:])\s{1}(?<Computer>[-a-zA-Z0-9_']{1,15})\s{1}(?<Address>(?:\d{1,3}\.){3}\d{1,3})"
            }
        $Object = @()
        }
Process
    {
        foreach ($Line in (Get-Content $LogPath))
        {
            Write-Verbose "Parse each line of the file to build object"
            $Line -match $regex |Out-Null
            if ($DebugLog)
            {
                $Item = New-Object -TypeName psobject -Property @{
                    Date = $Matches.Date
                    Time = $Matches.Time
                    Type = $Matches.Type.Replace('[','').Replace(']','')
                    Message = $Matches.Message
                    }

                Write-Verbose "Check to see if the Message contains a code"
                $Item.Message -match $Code |Out-Null
                if ($Matches.Code)
                {
                    Write-Verbose "Code found, adding definition to message"
                    $Item.Message += " : $($Codes.Item($Matches.Code))"
                    }
                $Object += $Item |Select-Object -Property Date, Time, Type, Message
                }
            else
            {
                $Item = New-Object -TypeName psobject -Property @{
                    Date = $Matches.Date
                    Time = $Matches.Time
                    Message = $Matches.Message
                    Computer = $Matches.Computer
                    Address = $Matches.Address
                    }
                $Object += $Item |Select-Object -Property Date, Time, Message, Computer, Address
                }
            }
        }
End
    {
        Write-Verbose "Returning parse logfile"
        Return $Object
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message
        }