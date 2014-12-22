Function Write-LogFile
{
    <#
        .SYNOPSIS
            Create a text based log file
        .DESCRIPTION
            This function will store log information you specify in a text format. This
            log can easily be read in any text editor, or processed via other cmdlets.

            The delimiter used for the files is [char]0xFE 
        .PARAMETER LogPath
            This is the location where your logfile will be stored, if blank it will
            default to C:\LogFiles
        .PARAMETER LogName
            This becomes the name of the logfile
        .PARAMETER Source
            This is how you identify the source of a given entry in the log
        .PARAMETER EventID
            Some way to uniquely identify a given log
        .PARAMETER EntryType
            A string representing what kind of entry to be used, this can be any 
            valid string
        .PARAMETER Message
            This is the message that will be stored in the log
        .EXAMPLE
            Write-LogFile -LogName PowerShellTesting -Source Testing -EventID 0 -EntryType Information -Message "This is a test"

            Description
            -----------
            This example shows the basic syntax of the function
        .EXAMPLE
            Write-LogFile -LogFile C:\Logs -LogName PowerShellTesting -Source Testing -EventID 0 -EntryType Information -Message "This is a test"

            Description
            -----------
            This example shows how to specify a location for the logfile
        .NOTES
            FunctionName : Write-LogFile
            Created by   : jspatton
            Date Coded   : 11/08/2014 06:06:32
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/LogFiles#Write-LogFile
    #>
    [CmdletBinding()]
    Param
        (
        [string]$LogPath = "C:\LogFiles",
        [string]$LogName,
        [string]$Source,
        [string]$EventID,
        [string]$EntryType,
        [string]$Message
        )
    Begin
    {
        if (!(Test-Path $LogPath))
        {
            New-Item $LogPath -ItemType Directory -Force |Out-Null
            }
        $Source = $Source.Replace('.','_')
        $Source = $Source.Replace(' ','-')
        $LogName = $LogName.Replace('.','_')
        $LogName = $LogName.Replace(' ','-')
        if (!(Test-Path "$($LogPath)\$($LogName)"))
        {
            New-Item "$($LogPath)\$($LogName)" -ItemType Directory -Force |Out-Null
            }
        $LogFileName = "$($LogName.Replace(' ','-')).log"
        $LogFile = "$($LogPath)\$($LogName)\$($LogFileName)"
        $Delim = [char]0xFE
        }
    Process
    {
        "$($LogName)$($Delim)$($Source)$($Delim)$(Get-Date)$($Delim)$($EventID)$($Delim)$($EntryType)$($Delim)$($Message)" |Out-File $LogFile -Append
        }
    End
    {
        }
    }
Function Get-LogFile
{
    <#
        .SYNOPSIS
            Returns information from a logfile
        .DESCRIPTION
            This function reads in a logfile and displays the information back out as objects.
        .PARAMETER LogPath
            This is the location where your logfile will be stored, if blank it will
            default to C:\LogFiles
        .PARAMETER LogName
            This becomes the name of the logfile
        .PARAMETER Source
            This is how you identify the source of a given entry in the log
        .PARAMETER EntryType
            A string representing what kind of entry to be used, this can be any 
            valid string
        .EXAMPLE
        .NOTES
            FunctionName : Get-LogFile
            Created by   : jspatton
            Date Coded   : 11/08/2014 06:06:45
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/LogFiles#Get-LogFile
    #>
    [CmdletBinding()]
    Param
        (
        [string]$LogPath = "C:\LogFiles",
        [string]$LogName,
        [string]$Source,
        [string]$EntryType
        )
    Begin
    {
        if (!(Test-Path $LogPath))
        {
            #
            # No logfiles found 
            #
            Write-Error "No logfile found"
            break
            }
        $LogName = $LogName.Replace('.','_')
        $LogName = $LogName.Replace(' ','-')
        if (!(Test-Path "$($LogPath)\$($LogName)"))
        {
            #
            # Source not found
            #
            Write-Error "Logname not found"
            break
            }
        $LogFileName = "$($LogName.Replace(' ','-')).log"
        $LogFile = "$($LogPath)\$($LogName)\$($LogFileName)"
        if (!(Test-Path $LogFile))
        {
            #
            # LogName not found
            #
            Write-Error "LogFile not found"
            break
            }
        $Delim = [char]0xFE
        }
    Process
    {
        $Headers = "LogName","Source","Time","EventID","EntryType","Message"
        if ($EntryType -and !($Source))
        {
            Import-Csv $LogFile -Header $Headers -Delimiter $Delim |Where-Object -Property EntryType -eq $EntryType
            break
            }
        if ($Source -and !($EntryType))
        {
            Import-Csv $LogFile -Header $Headers -Delimiter $Delim |Where-Object -Property Source -eq $Source
            break
            }
        if ($Source -and $EntryType)
        {
            Import-Csv $LogFile -Header $Headers -Delimiter $Delim |Where-Object -Property Source -eq $Source |Where-Object -Property EntryType -eq $EntryType
            break
            }
        else
        {
            Import-Csv $LogFile -Header $Headers -Delimiter $Delim
            }
        }
    End
    {
        }
    }
Function Get-LogSource
{
    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER LogPath
            This is the location where your logfile will be stored, if blank it will
            default to C:\LogFiles
        .PARAMETER LogName
            This becomes the name of the logfile
        .EXAMPLE
        .NOTES
            FunctionName : Get-LogSource
            Created by   : jspatton
            Date Coded   : 11/08/2014 06:06:46
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/LogFiles#Get-LogSource
    #>
    [CmdletBinding()]
    Param
        (
        [string]$LogPath = "C:\LogFiles",
        [string]$LogName
        )
    Begin
    {
        if (!(Test-Path $LogPath))
        {
            #
            # No logfiles found 
            #
            Write-Error "No logfile found"
            break
            }
        }
    Process
    {
        Get-LogFile -LogName $LogName |Select-Object -Property Source -Unique
        }
    End
    {
        }
    }
Function Backup-Logfile
{
    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER LogPath
            This is the location where your logfile will be stored, if blank it will
            default to C:\LogFiles
        .PARAMETER LogName
            This becomes the name of the logfile
        .EXAMPLE
        .NOTES
            FunctionName : Backup-Logfile
            Created by   : jspatton
            Date Coded   : 12/22/2014 10:27:07
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/LogFiles#Backup-Logfile
    #>
    [CmdletBinding()]
    Param
        (
        [string]$LogPath = "C:\LogFiles",
        [string]$LogName
        )
    Begin
    {
        [string]$Archive = (Get-Date -Format yyyMMdd-HHmmss).ToString();
        if (!(Test-Path $LogPath))
        {
            #
            # No logfiles found 
            #
            Write-Error "No logfile found"
            break
            }
        $LogName = $LogName.Replace('.','_')
        $LogName = $LogName.Replace(' ','-')
        if (!(Test-Path "$($LogPath)\$($LogName)"))
        {
            #
            # Source not found
            #
            Write-Error "Logname not found"
            break
            }
        $LogFileName = "$($LogName.Replace(' ','-')).log"
        $LogFile = "$($LogPath)\$($LogName)\$($LogFileName)"
        if (!(Test-Path $LogFile))
        {
            #
            # LogName not found
            #
            Write-Error "LogFile not found"
            break
            }
        }
    Process
    {
        $CurrentLog = Get-Item $LogFile
        $CurrentLog.MoveTo("$($CurrentLog.DirectoryName)\$($Archive)_$($CurrentLog.Name)")
        }
    End
    {
        }
    }