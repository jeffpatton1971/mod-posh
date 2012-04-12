<#
    .SYNOPSIS
        Logon script to log details about user and computer
    .DESCRIPTION
        This script logs details about the user and computer at each logon. The data
        is stored in a log named logonstatus.txt in the logonlog folder of the SystemDrive.
    .EXAMPLE
        .\AdvancedEvent3.ps1
        
        Description
        -----------
        This script is called during logon and has no parameters.
    .EXAMPLE
        .\AdvancedEvent3.ps1 -Verbose
        
        Description
        -----------
        Passing in the verbose switch allows you to view what is happening during
        script execution. Useful for debugging.
    .NOTES
        ScriptName : AdvancedEvent3.ps1
        Created By : jspatton
        Date Coded : 04/04/2012 15:26:19
        ScriptName is used to register events for this script
        LogName is used to determine which classic log to write to
 
        ErrorCodes
            100 = Success
            101 = Error
            102 = Warning
            104 = Information
        
        I pull the domain and hostname from Net.NetworkInformation.IPGlobalProperties because
        the computer may be joined to a domain other than the $env:USERDNSDOMAIN
        
        Here is a list of things the CIO has mandated MUST be in the log file:

            The user name in domainname/username format, for example: Microsoft/EdWilson 
            The computer name in hostname.domainname format, for example: Mred.Microsoft.Com 
            Operating system version 
            Service Pack level 
            All mapped drives and path to mapped resources 
            The default printer 
            The last reboot of the computer 
            The type of boot up (for example, safemode or normal)
    .LINK
        https://code.google.com/p/mod-posh/wiki/Production/AdvancedEvent3.ps1
#>
[CmdletBinding()]
Param
    (
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
        $LogFileName = 'logonstatus.txt'
        $LogLocation = '\logonlog'
        
        if (!(Test-Path "$($env:SystemDrive)$($LogLocation)"))
        {
            New-Item "$($env:SystemDrive)$($LogLocation)" -ItemType Directory |Out-Null
            }
        $FileName = "$($env:SystemDrive)$($LogLocation)\$($LogFileName)"
        }
Process
    {
        $Message = "Connect to Win32_OperatingSystem to get LastBootUpTime"
        Write-Verbose $Message
        $LastBoot = Get-WMIObject -class Win32_OperatingSystem
        Write-Verbose $LastBoot.ConvertToDateTime($LastBoot.LastBootUpTime)
        
        $Message = "This will return the hostname and domainname of the computer"
        Write-Verbose $Message
        $ipProperties = [System.Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties()
        Write-Verbose $ipProperties
        
        $Message = "Connect to Win32_MappedLogicalDisk to return Name and ProviderName"
        Write-Verbose $Message
        $MappedDrives = Get-WmiObject -Class Win32_MappedLogicalDisk |Select-Object @{Name='Drive Letter';Expression={$_.Name}},@{Name='Resource Path';Expression={$_.ProviderName}}
        Write-Verbose "Converted Name to Drive Letter and ProviderName to Resource Path"
        Write-Verbose $MappedDrives.ToString()
        
        $Message = "Connect to Win32_Printer and get the printer object that is set as default"
        Write-Verbose $Message
        $DefaultPrinter = Get-WmiObject -Class Win32_Printer -Filter 'Default = TRUE'
        Write-Verbose $DefaultPrinter
        
        $Message = "Connect to Win32_OperatingSystem to get Version and CSDVersion"
        Write-Verbose $Message
        $OsDetails = Get-WmiObject -Class Win32_OperatingSystem
        Write-Verbose $OsDetails
        
        $Message = "Connect to Win32_ComputerSystem to get BootupState"
        Write-Verbose $Message
        $ComputerSystem = Get-WmiObject -Class Win32_ComputerSystem
        Write-Verbose $ComputerSystem.BootupState
        
        $Report = New-Object -TypeName PSObject -Property @{
            LastReboot = $LastBoot.ConvertToDateTime($LastBoot.LastBootUpTime)
            ComputerName = "$($ipProperties.HostName).$($ipProperties.DomainName)"
            UserName = $Username
            OperatingSystemVersion = $OsDetails.Version
            CurrentLog = Get-Date
            OperatingSystemServicePack = $OsDetails.CSDVersion
            DefaultPrinter = $DefaultPrinter.Name
            Drive = $MappedDrives
            TypeOfBoot = $ComputerSystem.BootupState
            }
        }
End
    {
        $Report |Select-Object -Property LastReboot, ComputerName, UserName, OperatingSystemVersion, CurrentLog, OperatingSystemServicePack, DefaultPrinter, Drive, TypeOfBoot `
                |Out-File -FilePath $FileName -Append
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName $LogName -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message	
        }
