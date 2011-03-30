# ---------------------------------------------------------------------------
### <Library name='Muegge_LogParser_Lib.ps1'>
### <Author>David Muegge</Author>
### <CreateDate>20081108</CreateDate>
### <ModifiedDate>20081121</ModifiedDate>
### <Description>
### 	Log Parser function library
### </Description>
### <Dependencies>
###		Log Parser 2.2 COM component
### </Dependencies>
### <Usage>
### 	Dot source from calling script
### </Usage>
### </Library>
# ---------------------------------------------------------------------------
 
# ---------------------------------------------------------------------------
### <Function name='Get-LPInputFormat'>
### <Description>
### 	Returns Log Parser Input Format object based on passed string
### </Description>
### <Usage>
###		Get-LPInputFormat -InputType <string>
### </Usage>
### </Function>
# ---------------------------------------------------------------------------
function Get-LPInputFormat{
 
	param([String]$InputType)
 
	switch($InputType.ToLower()){
		"ads"{$inputobj = New-Object -comObject MSUtil.LogQuery.ADSInputFormat}
		"bin"{$inputobj = New-Object -comObject MSUtil.LogQuery.IISBINInputFormat}
		"csv"{$inputobj = New-Object -comObject MSUtil.LogQuery.CSVInputFormat}
		"etw"{$inputobj = New-Object -comObject MSUtil.LogQuery.ETWInputFormat}
		"evt"{$inputobj = New-Object -comObject MSUtil.LogQuery.EventLogInputFormat}
		"fs"{$inputobj = New-Object -comObject MSUtil.LogQuery.FileSystemInputFormat}
		"httperr"{$inputobj = New-Object -comObject MSUtil.LogQuery.HttpErrorInputFormat}
		"iis"{$inputobj = New-Object -comObject MSUtil.LogQuery.IISIISInputFormat}
		"iisodbc"{$inputobj = New-Object -comObject MSUtil.LogQuery.IISODBCInputFormat}
		"ncsa"{$inputobj = New-Object -comObject MSUtil.LogQuery.IISNCSAInputFormat}
		"netmon"{$inputobj = New-Object -comObject MSUtil.LogQuery.NetMonInputFormat}
		"reg"{$inputobj = New-Object -comObject MSUtil.LogQuery.RegistryInputFormat}
		"textline"{$inputobj = New-Object -comObject MSUtil.LogQuery.TextLineInputFormat}
		"textword"{$inputobj = New-Object -comObject MSUtil.LogQuery.TextWordInputFormat}
		"tsv"{$inputobj = New-Object -comObject MSUtil.LogQuery.TSVInputFormat}
		"urlscan"{$inputobj = New-Object -comObject MSUtil.LogQuery.URLScanLogInputFormat}
		"w3c"{$inputobj = New-Object -comObject MSUtil.LogQuery.W3CInputFormat}
		"xml"{$inputobj = New-Object -comObject MSUtil.LogQuery.XMLInputFormat}
 
	}
 
	return $inputobj
 
}
 
 
# ---------------------------------------------------------------------------
### <Function name='Get-LPOutputFormat'>
### <Description>
### 	Returns Log Parser Output Format object based on passed string
### </Description>
### <Usage>
###		Get-LPOutputFormat -OutputType <string>
### </Usage>
### </Function>
# ---------------------------------------------------------------------------
function Get-LPOutputFormat{
 
	param([String]$OutputType)
 
	switch($OutputType.ToLower()){
		"csv"{$outputobj = New-Object -comObject MSUtil.LogQuery.CSVOutputFormat}
		"chart"{$outputobj = New-Object -comObject MSUtil.LogQuery.ChartOutputFormat}
		"iis"{$outputobj = New-Object -comObject MSUtil.LogQuery.IISOutputFormat}
		"sql"{$outputobj = New-Object -comObject MSUtil.LogQuery.SQLOutputFormat}
		"syslog"{$outputobj = New-Object -comObject MSUtil.LogQuery.SYSLOGOutputFormat}
		"tsv"{$outputobj = New-Object -comObject MSUtil.LogQuery.TSVOutputFormat}
		"w3c"{$outputobj = New-Object -comObject MSUtil.LogQuery.W3COutputFormat}
		"tpl"{$outputobj = New-Object -comObject MSUtil.LogQuery.TemplateOutputFormat}
 
	}
 
	return $outputobj
 
}
 
 
# ---------------------------------------------------------------------------
### <Function name='Invoke-LPExecute'>
### <Description>
### 	Executes a Log Parser Query and returns a recordset
### </Description>
### <Usage>
###		Invoke-LPExecute -query <string>
### </Usage>
### </Function>
# ---------------------------------------------------------------------------
function Invoke-LPExecute{
 
	param([string] $query, $inputtype)
 
    $LPQuery = new-object -com MSUtil.LogQuery
	if($inputtype){
    	$LPRecordSet = $LPQuery.Execute($query, $inputtype)	
	}
	else
	{
		$LPRecordSet = $LPQuery.Execute($query)
	}
    return $LPRecordSet
 
}
 
 
# ---------------------------------------------------------------------------
### <Function name='Invoke-LPExecuteBatch'>
### <Description>
### 	Executes Log Parser batch query with passed input and output types
### </Description>
### <Usage>
###		Invoke-LPExecuteBatch -query <string> -inputtype <LogParserInputFormat> -outputtype <LogParserOutputFormat>
### </Usage>
### </Function>
# ---------------------------------------------------------------------------
function Invoke-LPExecuteBatch{
 
	param([string]$query, $inputtype, $outputtype)
 
    $LPQuery = new-object -com MSUtil.LogQuery
    $result = $LPQuery.ExecuteBatch($query, $inputtype, $outputtype)
    return $result
}
 
 
# ---------------------------------------------------------------------------
### <Function name='Get-LPRecord'>
### <Description>
###		Returns PowerShell custom object from Log Parser recordset for current record
### </Description>
### <Usage>
###		Get-LPRecord -rs <RecordSet>
### </Usage>
### </Function>
# ---------------------------------------------------------------------------
function Get-LPRecord{
 
	param($LPRecordSet)
 
	$LPRecord = new-Object System.Management.Automation.PSObject
	if( -not $LPRecordSet.atEnd())
	{
		$Record = $LPRecordSet.getRecord()
		for($i = 0; $i -lt $LPRecordSet.getColumnCount();$i++)
		{        
			$LPRecord | add-member NoteProperty $LPRecordSet.getColumnName($i) -value $Record.getValue($i)
		}
	}
	return $LPRecord
}
 
 
 
# ---------------------------------------------------------------------------
### <Function name='Get-LPRecordSet'>
### <Description>
### 	Executes a Log Parser Query and returns a LogRecordSet as a custom powershell object
### </Description>
### <Usage>
###		Get-LPRecordSet -query <string>
### </Usage>
### </Function>
# ---------------------------------------------------------------------------
function Get-LPRecordSet{
 
	param([string]$query)
 
	# Execute Query
	$LPRecordSet = Invoke-LPExecute $query
	$LPRecords = new-object System.Management.Automation.PSObject[] 0
	for(; -not $LPRecordSet.atEnd(); $LPRecordSet.moveNext())
	{
		# Add record
		$LPRecord = Get-LPRecord($LPRecordSet)
		$LPRecords += new-Object System.Management.Automation.PSObject	
        $RecordCount = $LPQueryResult.length-1
        $LPRecords[$RecordCount] = $LPRecord
	}
	$LPRecordSet.Close();
	return $LPRecords
 
}