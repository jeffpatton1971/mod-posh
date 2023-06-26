Function Get-WevtLog {
 <#
 .SYNOPSIS
 Displays configuration information for the specified log
 .DESCRIPTION
 Displays configuration information for the specified log, which
 includes whether the log is enabled or not, the current maximum
 size limit of the log, and the path to the file where the log is
 stored.
 .PARAMETER Logname
 The name of a log
 .PARAMETER Format
 Specifies that the output should be either XML or text format.
 If <Format> is XML, the output is displayed in XML format. If
 <Format> is Text, the output is displayed without XML tags. The
 default is Text.
 .PARAMETER List
 If present displays the names of all logs.
 .EXAMPLE
 Get-WevtLog -Logname System -Format xml

 <?xml version="1.0" encoding="UTF-8"?>
 <channel name="System" enabled="true" type="Admin" owningPublisher="" isolation="System" channelAccess="O:BAG:SYD:(A;;0xf0007;;;SY)(A;;0x7;;;BA)(A;;0x3;;;BO)(A;;0x5;;;SO)(A;;0x1;;;IU)(A;;0x3;;;SU)(A;;0x1;;;S-1-5-3)(A;;0x2;;;S-1-5-33)(A;;0x1;;;S-1-5-32-573)" xmlns="http://schemas.microsoft.com/win/2004/08/events">
 <logging>
 <logFileName>%SystemRoot%\System32\Winevt\Logs\System.evtx</logFileName>
 <retention>false</retention>
 <autoBackup>false</autoBackup>
 <maxSize>20971520</maxSize>
 </logging>
 <publishing>
 <fileMax>1</fileMax>
 </publishing>
 </channel>

 Description
 -----------
 Get configuration information about the System log in XML format
 .EXAMPLE
 Get-WevtLog -List

 Analytic
 Application
 Cisco AnyConnect Secure Mobility Client
 ConnectionInfo

 Description
 -----------
 Get a list of all logs available
 .NOTES
 FunctionName : Get-WevtLog
 Created by   : jspatton
 Date Coded   : 03/02/2015 8:26:42
 .LINK
 https://github.com/jeffpatton1971/mod-posh/wiki/WevtUtil#Get-WevtLog
 .LINK
 https://msdn.microsoft.com/en-us/library/windows/desktop/aa820708%28v=vs.85%29.aspx?f=255&MSPPError=-2147217396
 .LINK
 https://technet.microsoft.com/en-us/library/cc732848.aspx
 #>
 [CmdletBinding()]
 Param
 (
  [Parameter(Mandatory = $true, ParameterSetName = 'get-log')]
  $Logname,
  [ValidateSet("xml", "text")]
  [Parameter(ParameterSetName = 'get-log')]
  [string]$Format,
  [Parameter(Mandatory = $true, ParameterSetName = 'enum-logs')]
  [switch]$List
 )
 Begin {
  $WevtUtil = "wevtutil $($PSCmdlet.ParameterSetName) ";
 }
 Process {
  if ($PSCmdlet.ParameterSetName -eq 'get-log') {
   $WevtUtil += "$($Logname) "
   if ($Format) {
    $WevtUtil += "/f:$($Format)"
   }
  }
  if ($PSCmdlet.ParameterSetName -eq 'enum-logs') {
  }
  Invoke-Expression -Command $WevtUtil.Trim();
 }
 end {
 }
}
Function Set-WevtLog {
 <#
 .SYNOPSIS
 Modifies the configuration of the specified log.
 .DESCRIPTION
 Modifies the configuration of the specified log.
 .PARAMETER Logname
 The name of a log
 .PARAMETER Enbled
 Enables or disables a log. <Enabled> can be true or false.
 .PARAMETER Isolation
 Sets the log isolation mode. <Isolation> can be system, application
 or custom. The isolation mode of a log determines whether a log
 shares a session with other logs in the same isolation class. If
 you specify system isolation, the target log will share at least
 write permissions with the System log. If you specify application
 isolation, the target log will share at least write permissions
 with the Application log. If you specify custom isolation, you
 must also provide a security descriptor by using the Channel option.
 .PARAMETER Logpath
 Defines the log file name. <Logpath> is a full path to the file
 where the Event Log service stores events for this log.
 .PARAMETER Retention
 Sets the log retention mode. <Retention> can be true or false. The
 log retention mode determines the behavior of the Event Log service
 when a log reaches its maximum size. If an event log reaches its
 maximum size and the log retention mode is true, existing events
 are retained and incoming events are discarded. If the log
 retention mode is false, incoming events overwrite the oldest
 events in the log.
 .PARAMETER AutoBackup
 Specifies the log auto-backup policy. <Auto> can be true or false.
 If this value is true, the log will be backed up automatically when
 it reaches the maximum size. If this value is true, the retention
 (specified with the Retention option) must also be set to true.
 .PARAMETER Size
 Sets the maximum size of the log in bytes. The minimum log size is
 1048576 bytes (1024KB) and log files are always multiples of 64KB,
 so the value you enter will be rounded off accordingly.
 .PARAMETER Level
 Defines the level filter of the log. <Level> can be any valid level
 value. This option is only applicable to logs with a dedicated
 session. You can remove a level filter by setting <Level> to 0.
 .PARAMETER Keywords
 Specifies the keywords filter of the log. <Keywords> can be any
 valid 64 bit keyword mask. This option is only applicable to logs
 with a dedicated session.
 .PARAMETER Channel
 Sets the access permission for an event log. <Channel> is a
 security descriptor that uses the Security Descriptor Definition
 Language (SDDL). For more information about SDDL format, see the
 Microsoft Developers Network (MSDN) Web site (http://msdn.microsoft.com).
 .PARAMETER Config
 Specifies the path to a configuration file. This option will cause
 log properties to be read from the configuration file defined in
 <Config>. If you use this option, you must not specify a <Logname>
 parameter. The log name will be read from the configuration file.
 .EXAMPLE
 Set-WevtLog -Logname Microsoft-Windows-CAPI2/Operational -Enabled $true -Retention $true -AutoBackup $true

 # jspatton@IT08082 | 13:16:15 | 03-02-2015 | C:\projects\mod-posh\powershell\production #
 Get-WevtLog -Logname Microsoft-Windows-CAPI2/Operational

 name: Microsoft-Windows-CAPI2/Operational
 enabled: true
 type: Operational
 owningPublisher: Microsoft-Windows-CAPI2
 isolation: Application
 channelAccess: O:BAG:SYD:(A;;0x7;;;BA)(A;;0x2;;;AU)
 logging:
 logFileName: %SystemRoot%\System32\Winevt\Logs\Microsoft-Windows-CAPI2%4Operational.evtx
 retention: true
 autoBackup: true
 maxSize: 1052672
 publishing:
 fileMax: 1

 Description
 -----------
 Enable the CAPI2 log, and set it's retention and autobackup settings. Then use Get-WevtLog
 to confirm.
 .NOTES
 FunctionName : Set-WevtLog
 Created by   : jspatton
 Date Coded   : 03/02/2015 8:50:14
 .LINK
 https://github.com/jeffpatton1971/mod-posh/wiki/WevtUtil#Set-WevtLog
 .LINK
 https://msdn.microsoft.com/en-us/library/windows/desktop/aa820708%28v=vs.85%29.aspx?f=255&MSPPError=-2147217396
 .LINK
 https://technet.microsoft.com/en-us/library/cc732848.aspx
 #>
 [CmdletBinding()]
 Param
 (
  [Parameter(Mandatory = $true, ParameterSetName = 'set-log')]
  $Logname,
  [Parameter(Mandatory = $false, ParameterSetName = 'set-log')]
  [string]$Enabled,
  [Parameter(Mandatory = $false, ParameterSetName = 'set-log')]
  [ValidateSet("system", "application", "custom")]
  [string]$Isolation,
  [Parameter(Mandatory = $false, ParameterSetName = 'set-log')]
  [string]$Logpath,
  [Parameter(Mandatory = $false, ParameterSetName = 'set-log')]
  [bool]$Retention,
  [Parameter(Mandatory = $false, ParameterSetName = 'set-log')]
  [bool]$AutoBackup,
  [Parameter(Mandatory = $false, ParameterSetName = 'set-log')]
  [int]$Size,
  [Parameter(Mandatory = $false, ParameterSetName = 'set-log')]
  [string]$Level,
  [Parameter(Mandatory = $false, ParameterSetName = 'set-log')]
  [string]$Keywords,
  [Parameter(Mandatory = $false, ParameterSetName = 'set-log')]
  [string]$Channel,
  [Parameter(Mandatory = $false, ParameterSetName = 'set-log')]
  [string]$Config
 )
 Begin {
  $WevtUtil = "wevtutil $($PSCmdlet.ParameterSetName) $($Logname) ";
 }
 Process {
  if ($PSCmdlet.ParameterSetName -eq 'set-log') {
   if ($Enabled) {
    if (($Enabled.ToString() -eq "False") -or ($Enabled.ToString() -eq "True")) {
     $WevtUtil += "/e:$($Enabled) "
    }
   }
   if ($Isolation) {
    $WevtUtil += "/i:$($Isolation) "
   }
   if ($Logpath) {
    $WevtUtil += "/lfn:$($Logpath) "
   }
   if ($Retention) {
    $WevtUtil += "/rt:$($Retention) /ab:$($AutoBackup) "
   }
   else {
    if ($AutoBackup) {
     $WevtUtil += "/rt:$($true) /ab:$($AutoBackup) "
    }
    else {
     $WevtUtil += "/rt:$($Retention) /ab:$($AutoBackup) "
    }
   }
   if ($Size) {
    $WevtUtil += "/ms:$($Size) "
   }
   if ($Level) {
    $WevtUtil += "/l:$($Level) "
   }
   if ($Keywords) {
    $WevtUtil += "/k:$($Keywords) "
   }
   if ($Channel) {
    $WevtUtil += "/ca:$($Channel) "
   }
   if ($Config) {
    $WevtUtil = "wevtutil /c:$($Config) "
   }
  }
  Invoke-Expression -Command $WevtUtil.Trim();
 }
 End {
 }
}
Function Get-WevtPublisher {
 <#
 .SYNOPSIS
 Displays the configuration information for the specified event publisher.
 .DESCRIPTION
 Displays the configuration information for the specified event publisher.
 .PARAMETER List
 Displays the event publishers on the local computer.
 .PARAMETER PublisherName
 The name of a Publisher
 .PARAMETER Metadata
 Gets metadata information for events that can be raised by this publisher.
 <Metadata> can be true or false.
 .PARAMETER Message
 Displays the actual message instead of the numeric message ID. <Message>
 can be true or false.
 .PARAMETER Format
 Specifies that the output should be either XML or text format.
 If <Format> is XML, the output is displayed in XML format. If
 <Format> is Text, the output is displayed without XML tags. The
 default is Text.
 .EXAMPLE
 Get-WevtPublisher -List |Select-String "capi"

 Microsoft-Windows-CAPI2
 Microsoft-Windows-WMPNSS-PublicAPI

 Description
 -----------
 Filter the list of Publishers to find just the ones related to CAPI
 .EXAMPLE
 Get-WevtPublisher -PublisherName Microsoft-Windows-CAPI2 -Metadata $true -Message $true -Format xml

 <?xml version="1.0" encoding="UTF-8"?>
 <provider name="Microsoft-Windows-CAPI2" guid="5bbca4a8-b209-48dc-a8c7-b23d3e5216fb" helpLink="http://go.microsoft.com/f
 wlink/events.asp?CoName=Microsoft%20Corporation&amp;ProdName=Microsoft%c2%ae%20Windows%c2%ae%20Operating%20System&amp;Pr
 odVer=6.3.9600.16431&amp;FileName=crypt32.dll&amp;FileVer=6.3.9600.16431" resourceFileName="C:\Windows\System32\crypt32.
 dll" messageFileName="C:\Windows\System32\crypt32.dll" message="Microsoft-Windows-CAPI2" xmlns="http://schemas.microsoft
 .com/win/2004/08/events">
 <channels>
 <channel name="Application" id="9" flags="1" message="Application">
 </channel>
 <channel name="Microsoft-Windows-CAPI2/Operational" id="16" flags="0" message="Microsoft-Windows-CAPI2/Operational">

 </channel>
 <channel name="Microsoft-Windows-CAPI2/Catalog Database Debug" id="17" flags="0" message="Microsoft-Windows-CAPI2/Ca
 talog Database Debug">
 </channel>
 </channels>

 Description
 -----------
 Get the configuration of the CAPI2 publisher with Metadata and Messages, in XML format.
 .NOTES
 FunctionName : Get-WevtPublisher
 Created by   : jspatton
 Date Coded   : 03/02/2015 9:24:02
 .LINK
 https://github.com/jeffpatton1971/mod-posh/wiki/WevtUtil#Get-WevtPublisher
 .LINK
 https://msdn.microsoft.com/en-us/library/windows/desktop/aa820708%28v=vs.85%29.aspx?f=255&MSPPError=-2147217396
 .LINK
 https://technet.microsoft.com/en-us/library/cc732848.aspx
 #>
 [CmdletBinding()]
 Param
 (
  [Parameter(Mandatory = $true, ParameterSetName = 'enum-publishers')]
  [switch]$List,
  [Parameter(Mandatory = $true, ParameterSetName = 'get-publisher')]
  [string]$PublisherName,
  [Parameter(Mandatory = $false, ParameterSetName = 'get-publisher')]
  [bool]$Metadata,
  [Parameter(Mandatory = $false, ParameterSetName = 'get-publisher')]
  [bool]$Message,
  [Parameter(Mandatory = $false, ParameterSetName = 'get-publisher')]
  [ValidateSet("xml", "text")]
  [string]$Format
 )
 Begin {
  $WevtUtil = "wevtutil $($PSCmdlet.ParameterSetName) ";
 }
 Process {
  if ($PSCmdlet.ParameterSetName -eq "enum-publishers") {
  }
  if ($PSCmdlet.ParameterSetName -eq "get-publisher") {
   $WevtUtil += "$($PublisherName) "
   if ($Metadata) {
    $WevtUtil += "/ge:$($Metadata) "
   }
   if ($Message) {
    $WevtUtil += "/gm:$($Message) "
   }
   if ($Format) {
    $WevtUtil += "/f:$($Format) "
   }
  }
  Invoke-Expression -Command $WevtUtil.Trim();
 }
 End {
 }
}
Function Install-WevtManifest {
 <#
 .SYNOPSIS
 Installs event publishers and logs from a manifest.
 .DESCRIPTION
 Installs event publishers and logs from a manifest. For more
 information about event manifests and using this parameter, see
 the Windows Event Log SDK at the Microsoft Developers Network
 (MSDN) Web site (http://msdn.microsoft.com).
 .PARAMETER Manifest
 This is a valid XML file containing the Manifest, see MSDN for
 more details.
 https://msdn.microsoft.com/en-us/library/windows/desktop/dd996930(v=vs.85).aspx
 .EXAMPLE
 Install-WevtManifest -Manifest C:\Temp\Sample-Manifest.man

 Description
 -----------
 Installs the Sample-Manifest as a publisher
 .NOTES
 FunctionName : Install-WevtManifest
 Created by   : jspatton
 Date Coded   : 03/02/2015 10:26:34
 .LINK
 https://github.com/jeffpatton1971/mod-posh/wiki/WevtUtil#Install-WevtManifest
 .LINK
 https://msdn.microsoft.com/en-us/library/windows/desktop/aa820708%28v=vs.85%29.aspx?f=255&MSPPError=-2147217396
 .LINK
 https://technet.microsoft.com/en-us/library/cc732848.aspx
 #>
 [CmdletBinding()]
 Param
 (
  [Parameter(Mandatory = $true, ParameterSetName = 'install-manifest')]
  $Manifest
 )
 Begin {
  $WevtUtil = "wevtutil $($PSCmdlet.ParameterSetName) $($Manifest)"
 }
 Process {
  Invoke-Expression $WevtUtil;
 }
 End {
 }
}
Function Uninstall-WevtManifest {
 <#
 .SYNOPSIS
 Uninstalls all publishers and logs from a manifest.
 .DESCRIPTION
 Uninstalls all publishers and logs from a manifest. For more
 information about event manifests and using this parameter, see
 the Windows Event Log SDK at the Microsoft Developers Network
 (MSDN) Web site (http://msdn.microsoft.com).
 .PARAMETER Manifest
 This is a valid XML file containing the Manifest, see MSDN for
 more details.
 https://msdn.microsoft.com/en-us/library/windows/desktop/dd996930(v=vs.85).aspx
 .EXAMPLE
 Uninstall-WevtManifest -Manifest C:\Temp\Sample-Manifest.man

 Description
 -----------
 Uninstalls the Sample-Manifest as a publisher
 .NOTES
 FunctionName : Uninstall-WevtManifest
 Created by   : jspatton
 Date Coded   : 03/02/2015 10:30:24
 .LINK
 https://github.com/jeffpatton1971/mod-posh/wiki/WevtUtil#Uninstall-WevtManifest
 .LINK
 https://msdn.microsoft.com/en-us/library/windows/desktop/aa820708%28v=vs.85%29.aspx?f=255&MSPPError=-2147217396
 .LINK
 https://technet.microsoft.com/en-us/library/cc732848.aspx
 #>
 [CmdletBinding()]
 Param
 (
  [Parameter(Mandatory = $true, ParameterSetName = 'uninstall-manifest')]
  $Manifest
 )
 Begin {
  $WevtUtil = "wevtutil $($PSCmdlet.ParameterSetName) $($Manifest)"
 }
 Process {
 }
 End {
 }
}
Function Find-WevtEvent {
 <#
 .SYNOPSIS
 Reads events from an event log, from a log file, or using a
 structured query.
 .DESCRIPTION
 Reads events from an event log, from a log file, or using a
 structured query. By default, you provide a log name for <Logname>.
 However, if you use the LogFile option, then <Logname> must be a
 path to a log file. If you use the StructuredQuery parameter,
 <Logname> must be a path to a file that contains a structured query.
 .PARAMETER Logname
 The name of a log or path to a logfile/structured query file
 .PARAMETER LogFile
 Specifies that the events should be read from a log or from a log
 file. <Logfile> can be true or false. If true, the parameter to the
 command is the path to a log file.
 .PARAMETER StructuredQuery
 Specifies that events should be obtained with a structured query.
 <Structquery> can be true or false. If true, <Path> is the path to
 a file that contains a structured query.
 .PARAMETER Query
 Defines the XPath query to filter the events that are read or
 exported. If this option is not specified, all events will be
 returned or exported. This option is not available when /sq is true.
 .PARAMETER Bookmark
 Specifies the path to a file that contains a bookmark from a
 previous query.
 .PARAMETER SaveBM
 Specifies the path to a file that is used to save a bookmark of this
 query. The file name extension should be .xml
 .PARAMETER Direction
 Specifies the direction in which events are read. <Direction> can be
 true or false. If true, the most recent events are returned first.
 .PARAMETER Format
 Specifies that the output should be either XML or text format.
 If <Format> is XML, the output is displayed in XML format. If
 <Format> is Text, the output is displayed without XML tags. The
 default is Text.
 .PARAMETER Locale
 Defines a locale string that is used to print event text in a specific
 locale. Only available when printing events in text format using the
 /f option.
 .PARAMETER Count
 Sets the maximum number of events to read.
 .PARAMETER Element
 Includes a root element when displaying events in XML. <Element> is
 the string that you want within the root element. For example,
 -Element root would result in XML that contains the root element
 pair <root></root>.
 .EXAMPLE
 Find-WevtEvent -LogName System -Direction $true -Count 1 -Format xml

 <Event xmlns='http://schemas.microsoft.com/win/2004/08/events/event'><System><Provider Name='Microsoft-Windows-Eventlog'
 Guid='{fc65ddd8-d6ef-4962-83d5-6e5cfe9ce148}'/><EventID>105</EventID><Version>0</Version><Level>4</Level><Task>105</Tas
 k><Opcode>0</Opcode><Keywords>0x8000000000000000</Keywords><TimeCreated SystemTime='2015-03-02T19:31:37.776314200Z'/><Ev
 entRecordID>125448</EventRecordID><Correlation/><Execution ProcessID='720' ThreadID='952'/><Channel>System</Channel><Com
 puter>it08082.home.ku.edu</Computer><Security/></System><UserData><AutoBackup xmlns='http://manifests.microsoft.com/win/
 2004/08/windows/eventlog'><Channel>Microsoft-Windows-CAPI2/Operational</Channel><BackupPath>C:\Windows\System32\Winevt\L
 ogs\Archive-Microsoft-Windows-CAPI2%4Operational-2015-03-02-19-31-37-619.evtx</BackupPath></AutoBackup></UserData></Even
 t>

 Description
 -----------
 Get the last log from the System log in XML format
 .EXAMPLE
 Find-WevtEvent -LogName System -Direction $true -Count 1 -Format xml -Query "*[System[Level=3]]"

 <Event xmlns='http://schemas.microsoft.com/win/2004/08/events/event'><System><Provider Name='Microsoft-Windows-Time-Serv
 ice' Guid='{06EDCFEB-0FD0-4E53-ACCA-A6F8BBF81BCB}'/><EventID>129</EventID><Version>0</Version><Level>3</Level><Task>0</T
 ask><Opcode>0</Opcode><Keywords>0x8000000000000000</Keywords><TimeCreated SystemTime='2015-03-02T14:02:15.448409500Z'/><
 EventRecordID>125419</EventRecordID><Correlation/><Execution ProcessID='1068' ThreadID='1668'/><Channel>System</Channel>
 <Computer>it08082.home.ku.edu</Computer><Security UserID='S-1-5-19'/></System><EventData Name='TMP_EVENT_DOMAIN_PEER_DIS
 COVERY_ERROR'><Data Name='ErrorMessage'>The entry is not found. (0x800706E1)</Data><Data Name='RetryMinutes'>15</Data></
 EventData></Event>

 Description
 -----------
 Use an XPATH query to get the most recent Level 3 event
 .NOTES
 FunctionName : Find-WevtEvent
 Created by   : jspatton
 Date Coded   : 03/02/2015 10:35:12
 .LINK
 https://github.com/jeffpatton1971/mod-posh/wiki/WevtUtil#Find-WevtEvent
 .LINK
 https://msdn.microsoft.com/en-us/library/windows/desktop/aa820708%28v=vs.85%29.aspx?f=255&MSPPError=-2147217396
 .LINK
 https://technet.microsoft.com/en-us/library/cc732848.aspx
 #>
 [CmdletBinding()]
 Param
 (
  [Parameter(Mandatory = $true, ParameterSetName = 'query-events')]
  [string]$LogName,
  [Parameter(Mandatory = $false, ParameterSetName = 'query-events')]
  [switch]$LogFile,
  [Parameter(Mandatory = $false, ParameterSetName = 'query-events')]
  [switch]$StructuredQuery,
  [Parameter(Mandatory = $false, ParameterSetName = 'query-events')]
  [string]$Query,
  [Parameter(Mandatory = $false, ParameterSetName = 'query-events')]
  [System.IO.FileInfo]$Bookmark,
  [Parameter(Mandatory = $false, ParameterSetName = 'query-events')]
  [System.IO.FileInfo]$SaveBM,
  [Parameter(Mandatory = $false, ParameterSetName = 'query-events')]
  [bool]$Direction,
  [ValidateSet("xml", "text")]
  [Parameter(Mandatory = $false, ParameterSetName = 'query-events')]
  [string]$Format,
  [Parameter(Mandatory = $false, ParameterSetName = 'query-events')]
  [string]$Locale,
  [Parameter(Mandatory = $false, ParameterSetName = 'query-events')]
  [string]$Count,
  [Parameter(Mandatory = $false, ParameterSetName = 'query-events')]
  [string]$Element
 )
 Begin {
  $WevtUtil = "wevtutil $($PSCmdlet.ParameterSetName) ";
 }
 Process {
  if ($LogFile) {
   if ((Test-Path $LogName)) {
    $WevtUtil += "$($LogName) "
   }
   else {
    throw "$($LogName) must be a path and filename to a log file";
    break;
   }
  }
  else {
   $WevtUtil += "$($LogName) "
  }
  if ($StructuredQuery) {
   if ((Test-Path $LogName)) {
    $WevtUtil += "$($LogName) "
   }
   else {
    throw "$($LogName) must be a path and filename to a structured query file";
    break;
   }
  }
  if ($Query) {
   if (!($StructuredQuery)) {
    $WevtUtil += "/q:$($Query) "
   }
  }
  if ($Bookmark) {
   if ((Test-Path $Bookmark.FullName)) {
    $WevtUtil += "/bm:$($Bookmark.FullName) "
   }
   else {
    throw "$($Bookmark) must be a path to a file that contains a bookmark";
    break;
   }
  }
  if ($SaveBM) {
   if ($SaveBM.Exists()) {
    $WevtUtil += "/sbm:$($SaveBM.FullName) "
   }
   else {
    $SaveBM.Create()
    $WevtUtil += "/sbm:$($SaveBM.FullName) "
   }
  }
  if ($Direction) {
   $WevtUtil += "/rd:$($Direction) "
  }
  if ($Format) {
   $WevtUtil += "/f:$($Format) "
  }
  if ($Locale) {
   $WevtUtil += "/l:$($Locale) "
  }
  if ($Count) {
   $WevtUtil += "/c:$($Count) "
  }
  if ($Element) {
   $WevtUtil += "/e:$($Element) "
  }
  Invoke-Expression -Command $WevtUtil.Trim();
 }
 End {
 }
}
Function Get-WevtLogInfo {
 <#
 .SYNOPSIS
 Displays status information about an event log or log file.
 .DESCRIPTION
 Displays status information about an event log or log file. If the
 LogFile option is used, <Logname> is a path to a log file. You can
 run Get-WevtLog -List to obtain a list of log names.
 .PARAMETER Logname
 The name of a log or path to a logfile/structured query file
 .PARAMETER LogFile
 Specifies that the events should be read from a log or from a log
 file. <Logfile> can be true or false. If true, the parameter to the
 command is the path to a log file.
 .EXAMPLE
 Get-WevtLogInfo -LogName Microsoft-Windows-CAPI2/Operational

 creationTime: 2015-03-02T18:08:49.513Z
 lastAccessTime: 2015-03-02T18:08:49.513Z
 lastWriteTime: 2015-03-02T19:57:11.003Z
 fileSize: 1052672
 attributes: 32
 numberOfLogRecords: 177
 oldestRecordNumber: 1

 Description
 -----------
 Get the log information for the CAPI log
 .NOTES
 FunctionName : Get-WevtLogInfo
 Created by   : jspatton
 Date Coded   : 03/02/2015 10:47:25
 .LINK
 https://github.com/jeffpatton1971/mod-posh/wiki/WevtUtil#Get-WevtLogInfo
 .LINK
 https://msdn.microsoft.com/en-us/library/windows/desktop/aa820708%28v=vs.85%29.aspx?f=255&MSPPError=-2147217396
 .LINK
 https://technet.microsoft.com/en-us/library/cc732848.aspx
 #>
 [CmdletBinding()]
 Param
 (
  [Parameter(Mandatory = $true, ParameterSetName = 'get-loginfo')]
  [string]$LogName,
  [Parameter(Mandatory = $false, ParameterSetName = 'get-loginfo')]
  [switch]$LogFile
 )
 Begin {
  $WevtUtil = "wevtutil $($PSCmdlet.ParameterSetName) ";
 }
 Process {
  if ($LogFile) {
   if ((Test-Path $LogName)) {
    $WevtUtil += "$($LogName) /lf:$($LogFile)"
   }
   else {
    throw "$($LogName) must be a path and filename to a logfile"
   }
  }
  else {
   $WevtUtil += "$($LogName) ";
  }
  Invoke-Expression -Command $WevtUtil;
 }
 End {
 }
}
Function Export-WevtLog {
 <#
 .SYNOPSIS
 Exports events from an event log, from a log file, or using
 a structured query to the specified file.
 .DESCRIPTION
 Exports events from an event log, from a log file, or using
 a structured query to the specified file. By default, you provide
 a log name for <Logname>. However, if you use the LogFile option, then
 <Logname> must be a path to a log file. If you use the StructuredQuery
 option, <Logname> must be a path to a file that contains a structured
 query. <Exportfile> is a path to the file where the exported events
 will be stored.
 .PARAMETER Logname
 The name of a log or path to a logfile/structured query file
 .PARAMETER ExportFile
 A path to the file where the exported events will be stored.
 .PARAMETER LogFile
 Specifies that the events should be read from a log or from a log
 file. <Logfile> can be true or false. If true, the parameter to the
 command is the path to a log file.
 .PARAMETER StructuredQuery
 Specifies that events should be obtained with a structured query.
 <Structquery> can be true or false. If true, <Path> is the path to
 a file that contains a structured query.
 .PARAMETER Query
 Defines the XPath query to filter the events that are read or
 exported. If this option is not specified, all events will be
 returned or exported. This option is not available when /sq is true.
 .PARAMETER Overwrite
 Specifies that the export file should be overwritten. <Overwrite>
 can be true or false. If true, and the export file specified in
 <Exportfile> already exists, it will be overwritten without
 confirmation.
 .EXAMPLE
 Export-WevtLog -LogName Microsoft-Windows-CAPI2/Operational -ExportFile C:\temp\capi2-operational.evtx

 # jspatton@IT08082 | 14:51:10 | 03-02-2015 | C:\projects\mod-posh\powershell\production #
 Get-WevtLogInfo -LogName C:\temp\capi2-operational.evtx -LogFile

 creationTime: 2015-03-02T20:51:10.530Z
 lastAccessTime: 2015-03-02T20:51:10.530Z
 lastWriteTime: 2015-03-02T20:51:10.655Z
 fileSize: 1118208
 attributes: 32
 numberOfLogRecords: 409
 oldestRecordNumber: 1

 Description
 -----------
 Export the CAPI log to a file, then get information from the file using Get-WevtLogInfo
 .NOTES
 FunctionName : Export-WevtLog
 Created by   : jspatton
 Date Coded   : 03/02/2015 11:15:23
 .LINK
 https://github.com/jeffpatton1971/mod-posh/wiki/WevtUtil#Export-WevtLog
 .LINK
 https://msdn.microsoft.com/en-us/library/windows/desktop/aa820708%28v=vs.85%29.aspx?f=255&MSPPError=-2147217396
 .LINK
 https://technet.microsoft.com/en-us/library/cc732848.aspx
 #>
 [CmdletBinding()]
 Param
 (
  [Parameter(Mandatory = $true, ParameterSetName = 'export-log')]
  [string]$LogName,
  [Parameter(Mandatory = $true, ParameterSetName = 'export-log')]
  [string]$ExportFile,
  [Parameter(Mandatory = $false, ParameterSetName = 'export-log')]
  [switch]$LogFile,
  [Parameter(Mandatory = $false, ParameterSetName = 'export-log')]
  [switch]$StructuredQuery,
  [Parameter(Mandatory = $false, ParameterSetName = 'export-log')]
  [string]$Query,
  [Parameter(Mandatory = $false, ParameterSetName = 'export-log')]
  [switch]$Overwrite
 )
 Begin {
  $WevtUtil = "wevtutil $($PSCmdlet.ParameterSetName) ";
 }
 Process {
  if ($LogFile) {
   if ((Test-Path $LogName)) {
    $WevtUtil += "$($LogName) /lf:$($LogFile) "
   }
   else {
    throw "$($LogName) must be a file and path to a log file"
    break;
   }
  }
  else {
   $WevtUtil += "$($LogName) "
  }
  if ($StructuredQuery) {
   if ((Test-Path $LogName)) {
    $WevtUtil += "$($LogName) /sq:$($StructuredQuery) "
   }
   else {
    throw "$($LogName) must be a file and path to a structured query file"
    break;
   }
  }
  else {
  }
  $WevtUtil += "$($ExportFile) ";
  if ($Query) {
   if (!($StructuredQuery)) {
    $WevtUtil += "/q:$($Query) "
   }
  }
  if ($Overwrite) {
   $WevtUtil += "/ow:$($Overwrite) "
  }
  Invoke-Expression -Command $WevtUtil.Trim();
 }
 End {
 }
}
Function Save-WevtLog {
 <#
 .SYNOPSIS
 Archives the specified log file in a self-contained format.
 .DESCRIPTION
 Archives the specified log file in a self-contained format. A
 subdirectory with the name of the locale is created and all locale-
 specific information is saved in that subdirectory. After the
 directory and log file are created by running Save-WevtLog, events
 in the file can be read whether the publisher is installed or not.
 .PARAMETER LogPath
 Defines the log file name. <Logpath> is a full path to the file
 where the Event Log service stores events for this log.
 .PARAMETER Locale
 Defines a locale string that is used to print event text in a specific
 locale. Only available when printing events in text format using the
 /f option.
 .EXAMPLE
 .NOTES
 FunctionName : Save-WevtLog
 Created by   : jspatton
 Date Coded   : 03/02/2015 11:20:23
 .LINK
 https://github.com/jeffpatton1971/mod-posh/wiki/WevtUtil#Save-WevtLog
 .LINK
 https://msdn.microsoft.com/en-us/library/windows/desktop/aa820708%28v=vs.85%29.aspx?f=255&MSPPError=-2147217396
 .LINK
 https://technet.microsoft.com/en-us/library/cc732848.aspx
 #>
 [CmdletBinding()]
 Param
 (
  [Parameter(Mandatory = $true, ParameterSetName = 'archive-log')]
  [string]$LogPath,
  [Parameter(Mandatory = $false, ParameterSetName = 'archive-log')]
  [string]$Locale
 )
 Begin {
  $WevtUtil = "wevtutil $($PSCmdlet.ParameterSetName) $($LogPath) ";
 }
 Process {
  if ($Locale) {
   $WevtUtil += "/l:$($Locale) "
  }
  Invoke-Expression -Command $WevtUtil.Trim();
 }
 End {
 }
}
Function Clear-WevtLog {
 <#
 .SYNOPSIS
 Clears events from the specified event log.
 .DESCRIPTION
 Clears events from the specified event log. The Backup option can
 be used to back up the cleared events.
 .PARAMETER Logname
 The name of a log
 .PARAMETER Backup
 Specifies the path to a file where the cleared events will be
 stored. Include the .evtx extension in the name of the backup file.
 .EXAMPLE
 .NOTES
 FunctionName : Clear-WevtLog
 Created by   : jspatton
 Date Coded   : 03/02/2015 11:26:42
 .LINK
 https://github.com/jeffpatton1971/mod-posh/wiki/WevtUtil#Clear-WevtLog
 .LINK
 https://msdn.microsoft.com/en-us/library/windows/desktop/aa820708%28v=vs.85%29.aspx?f=255&MSPPError=-2147217396
 .LINK
 https://technet.microsoft.com/en-us/library/cc732848.aspx
 #>
 [CmdletBinding()]
 Param
 (
  [Parameter(Mandatory = $true, ParameterSetName = 'clear-log')]
  [string]$LogName,
  [Parameter(Mandatory = $false, ParameterSetName = 'clear-log')]
  [string]$Backup
 )
 Begin {
  $WevtUtil = "wevtutil $($PSCmdlet.ParameterSetName) $($LogName) ";
 }
 Process {
  if ($Backup) {
   $WevtUtil += "/bu:$($Backup)"
  }
  Invoke-Expression -Command $WevtUtil.Trim();
 }
 End {
 }
}

Export-ModuleMember *