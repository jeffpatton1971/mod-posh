<#
    .SYNOPSIS
        Get the Windows Update Log
    .DESCRIPTION
        This script will grab the Windows Update Log and format it as an object for easier
        viewing and exporting. This script will also accept a filter parameter which will
        allow you to filter the data returned, based on any one of the defined field names
        below.

        Date      : yyy-mm-dd
        Time      : hh:mm:ss:ms
        PID       : ???
        TID       : ???
        Component : AGENT, AU, AUCLNT, CDM, CMPRESS, COMAPI, DRIVER, DTASTOR, DWNLDMGR, EEHDNLER
                  : HANDLER, MISC, OFFLSNC, PARSER, PT, REPORT, SERVICE, SETUP, SHUTDWN, WUREDIR
                  : WUWEB

        Each of these are text values see the example section for details on using the filter
        paramter with this script.
    .PARAMETER Path
        This is the path to the Windows Update log file. The default location is the default
        value for this parameter.
    .PARAMETER Filter
        This is a simple expression fieldname seperated by an equal sign and then the value. 
        
        For example:

            'Date=2012-10-24'

            Description
            -----------
            A filter to view the log for a specific date

            'component=au'

            Description
            -----------
            A filter to view the log for a specific component of the update service
    .PARAMETER Errors
        This is a switch parameter, if present it will override any filter and display only the
        entries from the log that are error messages.
    .EXAMPLE
        .\Get-WindowsUpdateLog.ps1
        
        Date      : 2012-10-18
        Time      : 11:26:40:141
        PID       : 856
        TID       : f34
        Component : Agent
        Text      : Update {1B90C35B-EE81-4568-A84B-8B5005ECAEC6}.1 is pruned out due to potential supersedence

        Description
        -----------
        Without any parameters the entire contents of the log will be displayed out on the console.
    .EXAMPLE
        .\Get-WindowsUpdateLog.ps1 -Filter 'Date=2012-10-24'

        Date      : 2012-10-24
        Time      : 10:21:17:985
        PID       : 856
        TID       : 7e4
        Component : Service
        Text      : *************

        Desciption
        ----------
        This example shows a filter using a date, to return only entries that occurred on specific
        date.
    .EXAMPLE
        .\Get-WindowsUpdateLog.ps1 -Filter 'component=DRIVER'

        Date      : 2012-10-18
        Time      : 14:07:41:390
        PID       : 856
        TID       : 1238
        Component : Driver
        Text      : Matched driver to device USB\VID_045E&PID_0745&REV_0633&MI_01

        Description
        -----------
        This example shows a filter using a component, this will return only entries that matched the
        Driver component.
    .EXAMPLE
        .\Get-WindowsUpdateLog.ps1 -Filter 'Date=2012-10-24' |Export-Csv .\TodaysLogs.csv

        Description
        -----------
        This example shows piping the output of the script that is filtered by date, to a 
        csv file using the Export-Csv cmdlet.
    .NOTES
        ScriptName : Get-WindowsUpdateLog
        Created By : jspatton
        Date Coded : 10/24/2012 10:44:12
        ScriptName is used to register events for this script
 
        ErrorCodes
            100 = Success
            101 = Error
            102 = Warning
            104 = Information
    .LINK
        https://code.google.com/p/mod-posh/wiki/Production/Get-WindowsUpdateLog
 #>
[CmdletBinding()]
Param
    (
    [string]$Path = 'C:\Windows\WindowsUpdate.log',
    [string]$Filter,
    [switch]$Errors
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
        $Header = 'Date','Time','PID','TID','Component','Text'
        $Validated = $false
        }
Process
    {
        if ($Errors)
        {
            Import-Csv -Path $Path -Header $Header -Delimiter `t |Where-Object {$_.Text -like "Warning:*" -or $_.Text -like "Fatal:*"}
            }
        else
        {
            if ($Filter)
            {
                $fldFilter = ($Filter.Split('='))[0]
                $datFilter = ($Filter.Split('='))[1]

                foreach ($FieldName in $Header)
                {
                    if (!($Validated))
                    {
                        if ($fldFilter -eq $FieldName)
                        {
                            $Validated = $true
                            }
                        else
                        {
                            $Validated = $false
                            }
                        }
                    }
                if ($Validated)
                {
                    Import-Csv -Path $Path -Header $Header -Delimiter `t |Where-Object {$_.$fldFilter -eq $datFilter}
                    }
                }
            else
            {
                Import-Csv -Path $Path -Header $Header -Delimiter `t
                }
            }
        }
End
    {
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message
        }