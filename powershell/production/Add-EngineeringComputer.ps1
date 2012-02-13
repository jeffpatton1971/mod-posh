<#
    .SYNOPSIS
        Add Metadata to allow filter on DHCP
    .DESCRIPTION
        This script adds metadata about the computer to
        the description property of an allow filter. 
    .PARAMETER DHCPServer
        FQDN of local DHCP server
    .PARAMETER MacAddress
        Valid MAC Address
        
        Examples
        --------
        AA:BB:CC:DD:EE:FF
        AA-BB-CC-DD-EE-FF
        AABBCCDDEEFF
    .PARAMETER ComputerName
        The Netbios name of the computer to add
    .PARAMETER Department
        What department does this computer belong to
    .PARAMETER Owner
        Who is the primary user or departmental IT person
    .PARAMETER Serial
        Serial number of the computer
    .EXAMPLE
        .\Add-EngineeringComputer.ps1 -DHCPServer dhcp.company.com 
                                    -MacAddress aabbccddeeff 
                                    -ComputerName Desktop-01 
                                    -Department Admin 
                                    -Owner 'Jeff Patton' 
                                    -Serial 8675309
    .NOTES
        ScriptName : Add-EngineeringComputer.ps1
        Created By : jspatton
        Date Coded : 10/10/2011 15:57:22
        ScriptName is used to register events for this script
        LogName is used to determine which classic log to write to
 
        ErrorCodes
            100 = Success
            101 = Error
            102 = Warning
            104 = Information

        Really more of an internal script but is useful for anyone else. This
        script leverages the fine work that Jeremy Engle has done on his 
        DHCP Module (see second link). You will need to download that module
        and copy it to your modules folder for this to work.
    .LINK
        https://code.google.com/p/mod-posh/wiki/Add-EngineeringComputer
    .LINK
        http://gallery.technet.microsoft.com/05b1d766-25a6-45cd-a0f1-8741ff6c04ec
#>
[cmdletBinding()]
Param
    (
    $DHCPServer,
    $MacAddress,
    $ComputerName,
    $Department,
    $Owner,
    $Serial 
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
    Try
    {
        Import-Module -Name Microsoft.DHCP.PowerShell.Admin
        }
    Catch
    {
        Write-Warning "Must have the DHCP PowerShell Module available."
        Write-EventLog -LogName $LogName -Source $ScriptName -EventID "101" -EntryType "Error" -Message "DHCP Module Not Found"
        Break
        }
    
    $Description = "Name: $($ComputerName), Dept: $($Department), Owner: $($Owner), Serial: $($Serial)"
    $Server = Get-DHCPServer -Server $DHCPServer
    }
Process
{
    Try
    {
        Add-DHCPFilter -Server $Server -Allow -MACAddress $MacAddress -Description $Description
        }
    Catch
    {
        Return $Error[0].Exception
        }
    }
End
{
    $Message = "Added $($MacAddress) to $($Server.name) with the following description:`n$($Description)"
    Write-EventLog -LogName $LogName -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message	
    $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
    Write-EventLog -LogName $LogName -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message	
    }