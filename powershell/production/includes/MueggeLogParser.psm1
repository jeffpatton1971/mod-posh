<#
<Library name='Muegge_LogParser_Lib.ps1'>
<Author>David Muegge</Author>
<CreateDate>20081108</CreateDate>
<ModifiedDate>20081121</ModifiedDate>
<Description>
Log Parser function library
</Description>
<Dependencies>
Log Parser 2.2 COM component
http://www.microsoft.com/downloads/en/details.aspx?FamilyID=890cd06b-abf8-4c25-91b2-f8d975cf8c07

Microsoft Office Chart Web Component
http://www.microsoft.com/downloads/en/details.aspx?FamilyID=982b0359-0a86-4fb2-a7ee-5f3a499515dd
</Dependencies>
<Usage>
Dot source from calling script
</Usage>
</Library>
#>
function Get-LPInputFormat {
 <#
 .SYNOPSIS
 Returns Log Parser Input Format object based on passed string
 .DESCRIPTION
 Returns Log Parser Input Format object based on passed string
 .EXAMPLE
 Get-LPInputFormat -InputType <string>
 .NOTES
 You will need to download and install Microsoft's LogParser, you can find it at this URL:
 http://www.microsoft.com/downloads/en/details.aspx?FamilyID=890cd06b-abf8-4c25-91b2-f8d975cf8c07

 The original code was pulled from http://muegge.com/blog/?p=65 I have just moved his comment blocks down
 into the PowerShell v2 internal help system.
 .LINK
 https://code.google.com/p/mod-posh/wiki/MueggeLogParser#get-LPInputFormat
 #>
 [CmdletBinding()]
 param
 (
  [String]$InputType
 )
 Begin {
 }
 Process {
  switch ($InputType.ToLower()) {
   "ads" {
    $inputobj = New-Object -comObject MSUtil.LogQuery.ADSInputFormat
   }
   "bin" {
    $inputobj = New-Object -comObject MSUtil.LogQuery.IISBINInputFormat
   }
   "csv" {
    $inputobj = New-Object -comObject MSUtil.LogQuery.CSVInputFormat
   }
   "etw" {
    $inputobj = New-Object -comObject MSUtil.LogQuery.ETWInputFormat
   }
   "evt" {
    $inputobj = New-Object -comObject MSUtil.LogQuery.EventLogInputFormat
   }
   "fs" {
    $inputobj = New-Object -comObject MSUtil.LogQuery.FileSystemInputFormat
   }
   "httperr" {
    $inputobj = New-Object -comObject MSUtil.LogQuery.HttpErrorInputFormat
   }
   "iis" {
    $inputobj = New-Object -comObject MSUtil.LogQuery.IISIISInputFormat
   }
   "iisodbc" {
    $inputobj = New-Object -comObject MSUtil.LogQuery.IISODBCInputFormat
   }
   "ncsa" {
    $inputobj = New-Object -comObject MSUtil.LogQuery.IISNCSAInputFormat
   }
   "netmon" {
    $inputobj = New-Object -comObject MSUtil.LogQuery.NetMonInputFormat
   }
   "reg" {
    $inputobj = New-Object -comObject MSUtil.LogQuery.RegistryInputFormat
   }
   "textline" {
    $inputobj = New-Object -comObject MSUtil.LogQuery.TextLineInputFormat
   }
   "textword" {
    $inputobj = New-Object -comObject MSUtil.LogQuery.TextWordInputFormat
   }
   "tsv" {
    $inputobj = New-Object -comObject MSUtil.LogQuery.TSVInputFormat
   }
   "urlscan" {
    $inputobj = New-Object -comObject MSUtil.LogQuery.URLScanLogInputFormat
   }
   "w3c" {
    $inputobj = New-Object -comObject MSUtil.LogQuery.W3CInputFormat
   }
   "xml" {
    $inputobj = New-Object -comObject MSUtil.LogQuery.XMLInputFormat
   }
  }
 }
 End {
  return $inputobj
 }
}
function Get-LPOutputFormat {
 <#
 .SYNOPSIS
 Returns Log Parser Output Format object based on passed string
 .DESCRIPTION
 Returns Log Parser Output Format object based on passed string
 .EXAMPLE
 Get-LPOutputFormat -OutputType <string>
 .NOTES
 You will need to download and install Microsoft's LogParser, you can find it at this URL:
 http://www.microsoft.com/downloads/en/details.aspx?FamilyID=890cd06b-abf8-4c25-91b2-f8d975cf8c07

 The original code was pulled from http://muegge.com/blog/?p=65 I have just moved his comment blocks down
 into the PowerShell v2 internal help system.
 .LINK
 https://code.google.com/p/mod-posh/wiki/MueggeLogParser#Get-LPOutputFormat
 #>
 [CmdletBinding()]
 param
 (
  [String]$OutputType
 )
 Begin {
 }
 Process {
  switch ($OutputType.ToLower()) {
   "csv" {
    $outputobj = New-Object -comObject MSUtil.LogQuery.CSVOutputFormat
   }
   "chart" {
    $outputobj = New-Object -comObject MSUtil.LogQuery.ChartOutputFormat
   }
   "iis" {
    $outputobj = New-Object -comObject MSUtil.LogQuery.IISOutputFormat
   }
   "sql" {
    $outputobj = New-Object -comObject MSUtil.LogQuery.SQLOutputFormat
   }
   "syslog" {
    $outputobj = New-Object -comObject MSUtil.LogQuery.SYSLOGOutputFormat
   }
   "tsv" {
    $outputobj = New-Object -comObject MSUtil.LogQuery.TSVOutputFormat
   }
   "w3c" {
    $outputobj = New-Object -comObject MSUtil.LogQuery.W3COutputFormat
   }
   "tpl" {
    $outputobj = New-Object -comObject MSUtil.LogQuery.TemplateOutputFormat
   }
  }
 }
 End {
  return $outputobj
 }
}
function Invoke-LPExecute {
 <#
 .SYNOPSIS
 Executes a Log Parser Query and returns a recordset
 .DESCRIPTION
 Executes a Log Parser Query and returns a recordset
 .EXAMPLE
 Invoke-LPExecute -query <string>
 .NOTES
 You will need to download and install Microsoft's LogParser, you can find it at this URL:
 http://www.microsoft.com/downloads/en/details.aspx?FamilyID=890cd06b-abf8-4c25-91b2-f8d975cf8c07

 The original code was pulled from http://muegge.com/blog/?p=65 I have just moved his comment blocks down
 into the PowerShell v2 internal help system.
 .LINK
 https://code.google.com/p/mod-posh/wiki/MueggeLogParser#Invoke-LPExecute
 #>
 [CmdletBinding()]
 param
 (
  [string] $query, $inputtype
 )
 Begin {
 }
 Process {
  $LPQuery = new-object -com MSUtil.LogQuery
  if ($inputtype) {
   $LPRecordSet = $LPQuery.Execute($query, $inputtype)
  }
  else {
   $LPRecordSet = $LPQuery.Execute($query)
  }
 }
 End {
  return $LPRecordSet
 }
}
function Invoke-LPExecuteBatch {
 <#
 .SYNOPSIS
 Executes Log Parser batch query with passed input and output types
 .DESCRIPTION
 Executes Log Parser batch query with passed input and output types
 .EXAMPLE
 Invoke-LPExecuteBatch -query <string> -inputtype <LogParserInputFormat> -outputtype <LogParserOutputFormat>
 .NOTES
 You will need to download and install Microsoft's LogParser, you can find it at this URL:
 http://www.microsoft.com/downloads/en/details.aspx?FamilyID=890cd06b-abf8-4c25-91b2-f8d975cf8c07

 The original code was pulled from http://muegge.com/blog/?p=65 I have just moved his comment blocks down
 into the PowerShell v2 internal help system.
 .LINK
 https://code.google.com/p/mod-posh/wiki/MueggeLogParser#Invoke-LPExecuteBatch
 #>
 [CmdletBinding()]
 param
 (
  [string]$query, $inputtype, $outputtype
 )
 Begin {
 }
 Process {
  $LPQuery = new-object -com MSUtil.LogQuery
  $result = $LPQuery.ExecuteBatch($query, $inputtype, $outputtype)
 }
 End {
  return $result
 }
}
function Get-LPRecord {
 <#
 .SYNOPSIS
 Returns PowerShell custom object from Log Parser recordset for current record
 .DESCRIPTION
 Returns PowerShell custom object from Log Parser recordset for current record
 .EXAMPLE
 Get-LPRecord -rs <RecordSet>
 .NOTES
 You will need to download and install Microsoft's LogParser, you can find it at this URL:
 http://www.microsoft.com/downloads/en/details.aspx?FamilyID=890cd06b-abf8-4c25-91b2-f8d975cf8c07

 The original code was pulled from http://muegge.com/blog/?p=65 I have just moved his comment blocks down
 into the PowerShell v2 internal help system.
 .LINK
 https://code.google.com/p/mod-posh/wiki/MueggeLogParser#Get-LPRecord
 #>
 [CmdletBinding()]
 param
 (
  $LPRecordSet
 )
 Begin {
 }
 Process {
  $LPRecord = new-Object System.Management.Automation.PSObject
  if ( -not $LPRecordSet.atEnd()) {
   $Record = $LPRecordSet.getRecord()
   for ($i = 0; $i -lt $LPRecordSet.getColumnCount(); $i++) {
    $LPRecord | add-member NoteProperty $LPRecordSet.getColumnName($i) -value $Record.getValue($i)
   }
  }
 }
 End {
  return $LPRecord
 }
}
function Get-LPRecordSet {
 <#
 .SYNOPSIS
 Executes a Log Parser Query and returns a LogRecordSet as a custom powershell object
 .DESCRIPTION
 Executes a Log Parser Query and returns a LogRecordSet as a custom powershell object
 .EXAMPLE
 Get-LPRecordSet -query <string>
 .NOTES
 You will need to download and install Microsoft's LogParser, you can find it at this URL:
 http://www.microsoft.com/downloads/en/details.aspx?FamilyID=890cd06b-abf8-4c25-91b2-f8d975cf8c07

 The original code was pulled from http://muegge.com/blog/?p=65 I have just moved his comment blocks down
 into the PowerShell v2 internal help system.
 .LINK
 https://code.google.com/p/mod-posh/wiki/MueggeLogParser#Get-LPRecordSet
 #>
 [CmdletBinding()]
 param
 (
  [string]$query
 )
 Begin {
 }
 Process {
  # Execute Query
  $LPRecordSet = Invoke-LPExecute $query
  $LPRecords = new-object System.Management.Automation.PSObject[] 0
  for (; -not $LPRecordSet.atEnd(); $LPRecordSet.moveNext()) {
   # Add record
   $LPRecord = Get-LPRecord($LPRecordSet)
   $LPRecords += new-Object System.Management.Automation.PSObject
   $RecordCount = $LPQueryResult.length - 1
   $LPRecords[$RecordCount] = $LPRecord
  }
  $LPRecordSet.Close();
 }
 End {
  return $LPRecords
 }
}

Export-ModuleMember *