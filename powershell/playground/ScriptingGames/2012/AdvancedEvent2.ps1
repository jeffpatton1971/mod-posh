<#
    .SYNOPSIS
        Find Information about Remote and Local Services
    .DESCRIPTION
        This script will return a list of services running on a local or remote computer
    .PARAMETER ComputerName
        The name of the computer to check
    .PARAMETER Credentials
        Username and Password to use in order to query remote machine
    .PARAMETER FileName
        The name of the CSV file to create.
    .EXAMPLE
        .\AdvancedEvent2.ps1 -ComputerName Server -Credentials $Credentials
        
        Description
        -----------
        This example shows running the script against a remote computer
        where your Credentials are stored in the variable $Credentials
    .EXAMPLE
        .\AdvancedEvent2.ps1 
        
        Description
        -----------
        This example shows running the script against a local computer
    .NOTES
        ScriptName : AdvancedEvent2
        Created By : jspatton
        Date Coded : 04/03/2012 12:54:25
        ScriptName is used to register events for this script
        LogName is used to determine which classic log to write to
 
        ErrorCodes
            100 = Success
            101 = Error
            102 = Warning
            104 = Information
        
        This script returns a csv containing the following columns
            __Server  : Name of the computer returning information
            Name      : Name of the service
            StartMode : Manual/Auto/Disabled
            State     : Running/Stopped
            StartName : Service Account Name
        
        You can pass Get-Credential into the Credentials Parameter
        
    .LINK
        https://code.google.com/p/mod-posh/wiki/Production/AdvancedEvent2
#>
[CmdletBinding()]
Param
    (
    [string]$ComputerName = (& hostname),
    $Credentials,
    $FileName = 'Services.csv'
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
        
        $principal = New-Object System.Security.principal.windowsprincipal([System.Security.Principal.WindowsIdentity]::GetCurrent())
        if (($principal.IsInRole('Administrators')) -ne $true)
        {
            $Message = "$($Credentials.UserName) is not an admin"
            Write-Error $Message
            Write-EventLog -LogName $LogName -Source $ScriptName -EventID "101" -EntryType "Error" -Message $Message
            Break
        	}
        }
Process
    {
        Try
        {
            $ErrorActionPreference = 'Stop'
            if ($ComputerName -eq (& hostname))
            {
                $Message =  "Checking $(& hostname) for list of services"
                Write-Verbose $Message
                $Services = Get-WmiObject -Class Win32_Service |Select-Object -Property __SERVER, Name, StartMode, State, StartName
                Write-EventLog -LogName $LogName -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message
                }
            else
            {
                $Message = "Checking $($ComputerName) for list of services"
                Write-Verbose $Message
                $Services = Get-WmiObject -Class Win32_Service -ComputerName $ComputerName -Credential $Credentials `
                    |Select-Object -Property __SERVER, Name, StartMode, State, StartName
                Write-EventLog -LogName $LogName -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message
                }
            }
        Catch
        {
            $Message = "Unable to connect to WMI"
            Write-Error $Message
            }
        }
End
    {
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName $LogName -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message	
        $Services |Export-Csv -Path $FileName -NoTypeInformation
        }