Function Write-LogFile {
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
  [string]$CorrelationID,
  [string]$EntryType,
  [string]$Message
 )
 Begin {
  if (!(Test-Path $LogPath)) {
   New-Item $LogPath -ItemType Directory -Force | Out-Null
  }
  $Source = $Source.Replace('.', '_')
  $Source = $Source.Replace(' ', '-')
  $LogName = $LogName.Replace('.', '_')
  $LogName = $LogName.Replace(' ', '-')
  if (!(Test-Path "$($LogPath)\$($LogName)")) {
   New-Item "$($LogPath)\$($LogName)" -ItemType Directory -Force | Out-Null
  }
  $LogFileName = "$($LogName.Replace(' ','-')).log"
  $LogFile = "$($LogPath)\$($LogName)\$($LogFileName)"
  if (!(Test-Path $LogFile)) {
   $TempEventRecord = 1
  }
  else {
   $TempLog = Get-LogFile -LogPath $LogPath -LogName $LogName -MaxEvents 1
   [int]$TempEventRecord = [System.Convert]::ToInt16($TempLog.EventRecord)
   Write-Verbose $TempEventRecord
   [int]$TempEventRecord += 1
   Write-Verbose $TempEventRecord
   Remove-Variable TempLog
  }
  $EventRecord = "{0:D8}" -f $TempEventRecord
  $Delim = [char]0xFE
 }
 Process {
  "$($EventRecord)$($Delim)$($LogName)$($Delim)$($Source)$($Delim)$(Get-Date)$($Delim)$($EventID)$($Delim)$($CorrelationID)$($Delim)$($EntryType)$($Delim)$($Message)" | Out-File $LogFile -Append
 }
 End {
 }
}
Function Test-FileOpen {
 <#
 .SYNOPSIS
 Test if a file is open
 .Description
 Test if a file is open for writing, used in Write-LogFile to avoid IOException
 file in use by another process.
 .EXAMPLE
 Test-FileOpen -Path C:\LogFiles\testing\testing.log
 True
 .NOTES
 FunctionName : Test-FileOpen
 Created by   : jspatton
 Date Coded   : 08/09/2015 11:00:00
 .LINK
 https://github.com/jeffpatton1971/mod-posh/wiki/LogFiles#Test-FileOpen
 .LINK
 http://poshcode.org/2236
 #>
 [CmdletBinding()]
 Param
 (
  [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
  [psobject]$Path
 )
 Process {
  try {
   $File = Get-Item $Path -Force;
   $Stream = $File.OpenWrite();
   $Stream.Close() | Out-Null;
   return $true;
  }
  catch {
   return $false;
  }
 }
}
Function Get-LogFile {
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
 .EXAMPLE
 Get-LogFile -LogName PowerShellTesting


 LogName   : PowerShellTesting
 Source    : Testing
 Time      : 12/22/2014 11:54:50
 EventID   : 0
 EntryType : Information
 Message   : This is a test

 Description
 -----------
 This shows the basic syntax of the command and what is returned
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
  [int]$MaxEvents
 )
 Begin {
  if (!(Test-Path $LogPath)) {
   #
   # No logfiles found
   #
   Write-Error "No logfile found"
   break
  }
  $LogName = $LogName.Replace('.', '_')
  $LogName = $LogName.Replace(' ', '-')
  if (!(Test-Path "$($LogPath)\$($LogName)")) {
   #
   # Source not found
   #
   Write-Error "Logname not found"
   break
  }
  $LogFileName = "$($LogName.Replace(' ','-')).log"
  $LogFile = "$($LogPath)\$($LogName)\$($LogFileName)"
  if (!(Test-Path $LogFile)) {
   #
   # LogName not found
   #
   Write-Error "LogFile not found"
   break
  }
  $Delim = [char]0xFE
  $Headers = "EventRecord", "LogName", "Source", "Time", "EventID", "CorrelationID", "EntryType", "Message"
  $Result = Get-Content $LogFile -Delimiter $Delim -TotalCount $Headers.Count
  if ($Result[0] -eq "$($LogName)$($Delim)") {
   throw "EventRecord is missing, run Update-LogFile -LogPath $($LogPath) -LogName $($LogName)"
   break
  }
  Write-Verbose "Opening $($LogFile)"
  $TempLog = Import-Csv -Path $LogFile -Header $Headers -Delimiter $Delim
  if ($TempLog.Count -gt 1) {
   [array]::Reverse($TempLog)
  }
  Write-Verbose "Found $($TempLog.Count) log entries"
 }
 Process {
  if ($MaxEvents) {
   if ($TempLog.GetType().Name -ne "PSCustomObject") {
    $TempLog = $TempLog[0..($MaxEvents - 1)]
   }
  }
  $TempLog
 }
 End {
 }
}
Function Get-LogSource {
 <#
 .SYNOPSIS
 Returns a list of sources for a log
 .DESCRIPTION
 This function returns all the sources that are used in a given logfile
 .PARAMETER LogPath
 This is the location where your logfile will be stored, if blank it will
 default to C:\LogFiles
 .PARAMETER LogName
 This becomes the name of the logfile
 .EXAMPLE
 Get-LogSource -LogName PowerShellTesting

 Source
 ------
 Testing

 Description
 -----------
 This example shows the syntax of the command and it's output
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
 Begin {
  if (!(Test-Path $LogPath)) {
   #
   # No logfiles found
   #
   Write-Error "No logfile found"
   break
  }
 }
 Process {
  Get-LogFile -LogName $LogName | Select-Object -Property Source -Unique
 }
 End {
 }
}
Function Backup-Logfile {
 <#
 .SYNOPSIS
 A function to backup/archive a log file
 .DESCRIPTION
 This function will allow you to backup/archive the logfile. It simply
 renames the logfile with the name and time and date of when it was backed up.

 This can be useful to run on a schedule to roll the file every X time interval.
 .PARAMETER LogPath
 This is the location where your logfile will be stored, if blank it will
 default to C:\LogFiles
 .PARAMETER LogName
 This becomes the name of the logfile
 .EXAMPLE
 Backup-Logfile -LogName PowerShellTesting


 Directory: C:\LogFiles\PowerShellTesting


 Mode                LastWriteTime     Length Name
 ----                -------------     ------ ----
 -a---        12/22/2014  11:54 AM        154 20141224-085806_PowerShellTesting.log

 Description
 -----------
 This example shows the basic syntax and output of the function.
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
 Begin {
  [string]$Archive = (Get-Date -Format yyyMMdd-HHmmss).ToString();
  if (!(Test-Path $LogPath)) {
   #
   # No logfiles found
   #
   Write-Error "No logfile found"
   break
  }
  $LogName = $LogName.Replace('.', '_')
  $LogName = $LogName.Replace(' ', '-')
  if (!(Test-Path "$($LogPath)\$($LogName)")) {
   #
   # Source not found
   #
   Write-Error "Logname not found"
   break
  }
  $LogFileName = "$($LogName.Replace(' ','-')).log"
  $LogFile = "$($LogPath)\$($LogName)\$($LogFileName)"
  if (!(Test-Path $LogFile)) {
   #
   # LogName not found
   #
   Write-Error "LogFile not found"
   break
  }
 }
 Process {
  $CurrentLog = Get-Item $LogFile
  $CurrentLog.MoveTo("$($CurrentLog.DirectoryName)\$($Archive)_$($CurrentLog.Name)")
 }
 End {
  $CurrentLog
 }
}
Function Update-LogFile {
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
 .EXAMPLE
 Get-LogFile -LogName PowerShellTesting


 LogName   : PowerShellTesting
 Source    : Testing
 Time      : 12/22/2014 11:54:50
 EventID   : 0
 EntryType : Information
 Message   : This is a test

 Description
 -----------
 This shows the basic syntax of the command and what is returned
 .NOTES
 FunctionName : Get-LogFile
 Created by   : jspatton
 Date Coded   : 01/29/2015 12:04:19
 .LINK
 https://github.com/jeffpatton1971/mod-posh/wiki/LogFiles#Get-LogFile
 #>
 [CmdletBinding()]
 Param
 (
  [string]$LogPath = "C:\LogFiles",
  [string]$LogName
 )
 Begin {
  if (!(Test-Path $LogPath)) {
   #
   # No logfiles found
   #
   Write-Error "No logfile found"
   break
  }
  $LogName = $LogName.Replace('.', '_')
  $LogName = $LogName.Replace(' ', '-')
  if (!(Test-Path "$($LogPath)\$($LogName)")) {
   #
   # Source not found
   #
   Write-Error "Logname not found"
   break
  }
  $LogFileName = "$($LogName.Replace(' ','-')).log"
  $LogFile = "$($LogPath)\$($LogName)\$($LogFileName)"
  if (!(Test-Path $LogFile)) {
   #
   # LogName not found
   #
   Write-Error "LogFile not found"
   break
  }
  $Delim = [char]0xFE
 }
 Process {
  $Headers = "LogName", "Source", "Time", "EventID", "CorrelationID", "EntryType", "Message"
  $TempLog = Import-Csv $LogFile -Header $Headers -Delimiter $Delim
  $EventRecord = 1
  Remove-Item $LogFile
  New-Item $LogFile -ItemType file
  foreach ($TempEntry in $TempLog) {
   $NewEventRecord = "{0:D8}" -f $EventRecord
   "$($NewEventRecord)$($Delim)$($TempEntry.LogName)$($Delim)$($TempEntry.Source)$($Delim)$($TempEntry.Time)$($Delim)$($TempEntry.EventID)$($Delim)$($TempEntry.CorrelationID)$($Delim)$($TempEntry.EntryType)$($Delim)$($TempEntry.Message)" | Out-File $LogFile -Append
   [int]$EventRecord += 1
  }
 }
 End {
  Remove-Variable TempLog
 }
}
Function Get-LogFileTail {
 <#
 .SYNOPSIS
 Tail a log file
 .DESCRIPTION
 This function will tail the logfile created by Write-LogFile included
 within this module LogFiles
 .PARAMETER LogPath
 This is the location where your logfile will be stored, if blank it will
 default to C:\LogFiles
 .PARAMETER LogName
 This becomes the name of the logfile
 .PARAMETER ShowExisting
 An integer to show the number of events to start with, the default is 10
 .EXAMPLE
 .NOTES
 FunctionName : Get-LogFileTail
 Created by   : jspatton
 Date Coded   : 01/29/2015 14:38:22
 .LINK
 https://github.com/jeffpatton1971/mod-posh/wiki/LogFiles#Get-LogFileTail
 #>
 [CmdletBinding()]
 Param
 (
  [string]$LogPath = "C:\LogFiles",
  [string]$LogName,
  [int]$ShowExisting
 )
 Begin {
  if ($ShowExisting -gt 0) {
   $Data = Get-LogFile -LogPath $LogPath -LogName $LogName -MaxEvents $ShowExisting
   $Data | Sort-Object -Property EventRecord
   [int]$Index1 = [System.Convert]::ToInt16($Data[0].EventRecord)
   Write-Verbose "Index1 is $($Index1)"
  }
  else {
   [int]$Index1 = [System.Convert]::ToInt16((Get-LogFile -LogPath $LogPath -LogName $LogName -MaxEvents 1).EventRecord)
   Write-Verbose "Index1 is $($Index1)"
  }
 }
 Process {
  while ($true) {
   Start-Sleep -Seconds 1
   Write-Verbose "get 1 entry"
   [int]$Index2 = [System.Convert]::ToInt16((Get-LogFile -LogPath $LogPath -LogName $LogName -MaxEvents 1).EventRecord)
   Write-Verbose "Index2 is $($Index2)"
   if ($Index2 -gt $Index1) {
    Write-Verbose "Index2 - Index1 = $(($Index2) - $($index1))"
    Get-LogFile -LogPath $LogPath -LogName $LogName -MaxEvents ($Index2 - $Index1) | Sort-Object -Property EventRecord
   }
   $Index1 = $Index2
  }
 }
 End {
 }
}

Export-ModuleMember *