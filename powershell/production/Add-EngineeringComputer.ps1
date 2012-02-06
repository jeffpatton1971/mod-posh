<#
    .SYNOPSIS
        Template script
    .DESCRIPTION
        This script sets up the basic framework that I use for all my scripts.
    .PARAMETER
    .EXAMPLE
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
    .LINK
 #>
Param
    (
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
        $Server = Get-DHCPServer -Server 'net.soecs.ku.edu'
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
