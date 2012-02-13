<#
    .SYNOPSIS
        Get a count of local profiles
    .DESCRIPTION
        This scrpit displays a count of the users who have logged in to each
        computer.
    .PARAMETER ADSPath
        The LDAP URL to where the computers you are interested in are located
        in the directory.
    .EXAMPLE
        .\Get-LocalProfiles.ps1 -ADSPath 'OU=Workstations,OU=ADmin,DC=company,DC=com'
    .NOTES
        ScriptName : Get-LocalProfiles
        Created By : jspatton
        Date Coded : 10/06/2011 08:48:37
        ScriptName is used to register events for this script
        LogName is used to determine which classic log to write to
 
        ErrorCodes
            100 = Success
            101 = Error
            102 = Warning
            104 = Information
    .LINK
        https://code.google.com/p/mod-posh/wiki/Get-LocalProfiles
#>
[cmdletBinding()]
Param
    (
    $ADSPath
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
    
    $Report = @()
 
    #	Dotsource in the functions you need.
    . .\includes\ActiveDirectoryManagement.ps1
    
    $Computers = Get-ADObjects -ADSPath "OU=Labs,DC=soecs,DC=ku,DC=edu" 
    }
Process
{
    foreach ($Computer in $Computers)
    {
        Write-Verbose "$($Computer.Properties.name) is accessible over the network"
        if (!(Test-Connection -ComputerName $Computer.Properties.name -Count 1 -Quiet))
        {
            Write-Verbose "Count the folders in the Users directory"
            try
            {
                $UserCount = (Get-ChildItem -Path "\\$($Computer.Properties.name)\c$\users").Count
                }
            Catch
            {
                $UserCount = "Directory doesn't exist"
                }
            
            }
        else
        {
            Write-Verbose "Set the message to display"
            $UserCount = "Unable to connect"
            }
        Write-Verbose "Create the object to return in the report"
        $LineItem = New-Object -TypeName PSobject -Property @{
            Computer = $Computer.Properties.name
            UserCount = $UserCount
            }
        $Report += $LineItem
        }
    }
End
{
    $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
    Write-EventLog -LogName $LogName -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message	
    Return $Report
    }