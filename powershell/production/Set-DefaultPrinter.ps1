<#
    .SYNOPSIS
        Set the default printer for a given user account
    .DESCRIPTION
        This script is run as a user logon script. The idea behind it is that not everyone needs the 
        same default printer, so this script checks the current user ($env:UserName) if they are listed
        in the PrinterMappingFile then the specific printer they requested as mapped to them.
    .PARAMETER Filename
        This is a .CSV file that contains a user column and a printer column. The user column should be
        labled as Name and the printer column should be labeled as Printer. This file is processed by
        the script to map a specific printer to a specific user.
    .EXAMPLE
        .\Set-DefaultPrinter -PrinterMappingFile .\admin-suite.csv
    .NOTES
        ScriptName: Set-DefaultPrinter
        Created By: Jeff Patton
        Date Coded: September 9, 2011
        ScriptName is used to register events for this script
        LogName is used to determine which classic log to write to
        
        ErrorCodes
            100 = Success
            101 = Error
            102 = Warning
            104 = Information
        
        This script should be added to a GPO for the OU that we need to make exceptions for. See the first
        Technet article for more details on how to configure it.
            Script Name = PowerShell.exe
            Script Parameters = -noninteractive -command \\server\share\Set-DefaultPrinter.ps1 -Filename \\server\share\map.csv
    .LINK
        https://code.google.com/p/mod-posh/wiki/Production/Set-DefaultPrinter
    .LINK
        http://technet.microsoft.com/en-us/library/ee431705(WS.10).aspx
    .LINK
        http://technet.microsoft.com/en-us/library/ff731009.aspx
#>
Param
    (
    [Parameter(Mandatory = $True)]
    $Filename
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

        Write-Verbose "Import the spreadsheet to a variable to work with"
        $PrintMappings = Import-Csv -Path $Filename
        }
Process
    {
        Write-Verbose "Loop through each row in the spreadsheet"
        foreach ($User in $PrintMappings)
        {
            Write-Verbose "If the current user is found in the list map the corresponding printer"
            if ($User.Name -eq $env:UserName)
            {
                Write-Verbose "Connect to WMI and check if the printer exists"
                $DefaultPrinter = Get-WMIObject -query "Select * From Win32_Printer Where Name = $($User.Printer)"
                If ($DefaultPrinter -eq $null)
                {
                    Write-Verbose "The specified printer, $($User.Printer) was not found on the client"
                    $Message = "$($User.Printer) is not a valid printer name"
                    Write-EventLog -LogName $LogName -Source $ScriptName -EventID "101" -EntryType "Error" -Message $Message	
                    }
                Else
                {
                    Write-Verbose "Set the default printer"
                    $DefaultPrinter.SetDefaultPrinter()
                    $Message = "Setting $($User.Printer) as default printer for $($user.Name)"
                    Write-EventLog -LogName $LogName -Source $ScriptName -EventID "100" -EntryType "Information" -Message $Message	
                    }
                }
            }
        }
End
    {
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName $LogName -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message	
        }
