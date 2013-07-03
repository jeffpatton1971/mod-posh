$Session = New-PSSession -ComputerName 'SCOM-01.HOME.KU.EDU'
Invoke-Command -Session $Session -ScriptBlock {

    $rms = 'scom-01.home.ku.edu'
    Add-PSSnapin -Name Microsoft.EnterpriseManagement.OperationsManager.Client
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.EnterpriseManagement.OperationsManager")
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.EnterpriseManagement.OperationsManager.Common")
    Set-Location "OperationsManagerMonitoring::" 
    $MG = New-ManagementGroupConnection -ConnectionString:$rms
    Set-Location $rms 

    <#

    type
    ----
    System.PropertyBagData
    System.Performance.ConsecutiveSamplesData
    System.Performance.BaseliningStateData
    System.Performance.AverageData
    System.Mom.BackwardCompatibility.Alert.Data
    System.Event.LinkedData
    System.CorrelatorData
    System.ConsolidatorData
    System.Availability.StateData
    MonitorTaskDataType
    Microsoft.Windows.EventData

    #>

    $Alert = Get-Alert -Id "\`d.T.~Ed/{5F53031C-E289-4732-8723-3581DC87EEDC}.Id\`d.T.~Ed/"
    $AlertContext = ([xml]$Alert.Context).DataItem

    switch ($alert.Severity.ToString())
    {
        'Error'
        {
            $EntryType = "Error"
            $EventId = "101"
            }
        'Warning'
        {
            $EntryType = "Warning"
            $EventId = "102"
            }
        Default
        {
            # This should never happen generate an alert with new severity
            $EntryType = "Warning"
            $EventId = "102"
            }
        }

    $Hostname = $Alert.PrincipalName

    switch ($AlertContext.type)
    {
        'System.PropertyBagData'
        {
            $Source = $Alert.Category
            }
        'System.Performance.ConsecutiveSamplesData'
        {
            $Source = $Alert.Category
            }
        'System.Performance.BaseliningStateData'
        {
            $Source = $Alert.Category
            }
        'System.Performance.AverageData'
        {
            $Source = $Alert.Category
            }
        'System.Mom.BackwardCompatibility.Alert.Data'
        {
            $Source = $Alert.Category
            $EventId = $AlertContext.AlertContext.DataItem.EventNumber
            }
        'System.Event.LinkedData'
        {
            $Source = $AlertContext.type
            $EventId = $AlertContext.EventNumber
            }
        'System.CorrelatorData'
        {
            $Source = $AlertContext.type
            }
        'System.ConsolidatorData'
        {
            $Source = $AlertContext.type
            $EventId = $AlertContext.Context.DataItem.EventNumber
            }
        'System.Availability.StateData'
        {
            $Source = $AlertContext.type
            $Hostname = $AlertContext.hostname
            }
        'MonitorTaskDataType'
        {
            $Source = $AlertContext.type
            }
        'Microsoft.Windows.EventData'
        {
            $Source = $AlertContext.type
            $EventId = $AlertContext.EventNumber
            }
        Default
        {
            # This could happen as new Management Packs and Monitors are loaded on Operations Manager
            # generate an alert with new type
            $Source = "NEW SOURCE FOUND"
            }
        }

    $Message = "Name : $($Alert.Name)`r`n"
    $Message += "Description : $($Alert.Description)`r`n"
    $Message += "Hostname : $($Hostname)`r`n`r`n"
    $Message += "Context`r`n"
    $Message += $AlertContext |Out-String

    Try
    {
        New-EventLog -LogName 'SCOM Alerts' -Source $Source
        Write-EventLog -LogName 'SCOM alerts' -Source $Source -EntryType $EntryType -EventId $EventId -Message $Message
        New-EventLog -LogName 'Windows PowerShell' -Source 'Eventlog Runbook'
        }
    catch
    {
        Write-EventLog -LogName 'Windows Powershell' -Source 'Eventlog Runbook' -EventID "101" -EntryType "Error" -Message $Error[0].Exception
        }
    }



$Id = "\`d.T.~Ed/{5F53031C-E289-4732-8723-3581DC87EEDC}.Id\`d.T.~Ed/"
$rmsName = 'scom-01.home.ku.edu'
try
{
    $AccountName = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    $Password = ConvertTo-SecureString (Get-Content -Path C:\Temp\scorch-creds.txt) -Key (1..16) 
    $Credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $AccountName, $Password
    }
catch
{
    Out-File C:\temp\cred-error.log -InputObject $Error[0].Exception -Append ascii
    }

try
{
    $RMSSession = New-PSSession -ComputerName $rmsName -Authentication Credssp -Credential (Get-Credential -Credential $Credentials)
    Invoke-Command -Session $RMSSession -ArgumentList $rmsName -ScriptBlock {param ($rmsName) $rms=$rmsName} 
    Invoke-Command -Session $RMSsession -ScriptBlock {add-pssnapin "Microsoft.EnterpriseManagement.OperationsManager.Client"} 
    Invoke-Command -Session $RMSsession -ScriptBlock {Set-Location "OperationsManagerMonitoring::"} 
    Invoke-Command -Session $RMSSession -ScriptBlock {New-ManagementGroupConnection -connectionString:$rms} 
    Invoke-Command -Session $RMSsession -ScriptBlock {Set-Location $rmsName}
    Invoke-Command -Session $RMSSession -ArgumentList $Id -ScriptBlock {param ($id)$id=$id}
    $Alert = Invoke-Command -Session $RMSSession -ArgumentList $Id -ScriptBlock {get-alert -id $id}
    $Agent = Invoke-Command -Session $RMSSession -ArgumentList $Id -ScriptBlock {
        foreach ($Agent in (Get-Agent))
        {
            foreach ($Alert in (Get-Alert |Where-Object {$_.NetbiosComputerName -eq $Agent.ComputerName}))
            {
                if ($Alert.Id -eq $Id)
                {
                    Return $Agent
                    }
                }
            }
        }
    Remove-PsSession -Session $RMSSession
    }
catch
{
    Out-File C:\temp\session-error.log -InputObject $Error[0].Exception -Append ascii
    }

if ($Alert)
{
    $AlertContext = ([xml]$Alert.Context).DataItem
    switch ($alert.Severity.ToString())
    {
        'Error'
        {
            $EntryType = "Error"
            $EventId = "101"
            }
        'Warning'
        {
            $EntryType = "Warning"
            $EventId = "102"
            }
        Default
        {
            # This should never happen generate an alert with new severity
            $EntryType = "Warning"
            $EventId = "102"
            }
        }

    $Hostname = $Alert.PrincipalName
    switch ($AlertContext.type)
    {
        'System.PropertyBagData'
        {
            $Source = $Alert.Category
            }
        'System.Performance.ConsecutiveSamplesData'
        {
            $Source = $Alert.Category
            }
        'System.Performance.BaseliningStateData'
        {
            $Source = $Alert.Category
            }
        'System.Performance.AverageData'
        {
            $Source = $Alert.Category
            }
        'System.Mom.BackwardCompatibility.Alert.Data'
        {
            $Source = $Alert.Category
            $EventId = $AlertContext.AlertContext.DataItem.EventNumber
            }
        'System.Event.LinkedData'
        {
            $Source = $AlertContext.type
            $EventId = $AlertContext.EventNumber
            }
        'System.CorrelatorData'
        {
            $Source = $AlertContext.type
            }
        'System.ConsolidatorData'
        {
            $Source = $AlertContext.type
            $EventId = $AlertContext.Context.DataItem.EventNumber
            }
        'System.Availability.StateData'
        {
            $Source = $AlertContext.type
            $Hostname = $AlertContext.hostname
            }
        'MonitorTaskDataType'
        {
            $Source = $AlertContext.type
            }
        'Microsoft.Windows.EventData'
        {
            $Source = $AlertContext.type
            $EventId = $AlertContext.EventNumber
            }
        }

    $Message = "Name : $($Alert.Name)`r`n"
    $Message += "Description : $($Alert.Description)`r`n"
    $Message += "Hostname : $($Hostname)`r`n"
    $Message += "OpsMgrId : $($Id)`r`n`r`n"
    $Message += "Context`r`n"
    $Message += $AlertContext |Out-String

    try
    {
        [int32]$EventId
        }
    catch
    {
        if($EntryType -eq "Error")
        {
            $EventId = "101"
            }
        else
        {
            $EventId = 102
            }
        }

    New-EventLog -LogName 'SCOM Alerts' -Source $Source -ErrorAction SilentlyContinue
    Write-EventLog -LogName 'SCOM Alerts' -Source $Source -EntryType $EntryType -EventId $EventId -Message $Message
    }
else
{
    Out-File C:\temp\alert-error.log -InputObject "The session did not return an alert, was there an error?" -Append
    }

$Agent = Get-Agent |Where-Object {$_.ComputerName -eq 'kuec-ad1'}
$block = {
$Id = Get-Alert -Id "74896e24-be4e-4a94-9917-3d25aaaa1c2c"

if ($Id.NetbiosComputerName)
{
    $Hostname = $Id.NetbiosComputerName
    }
elseif ($Id.MonitoringObjectDisplayname)
{
    $Hostname = $Id.MonitoringObjectDisplayName.Split('.')[0]
    }

foreach ($Agent in (Get-Agent))
{
    foreach ($Alert in (Get-Alert -Criteria "NetbiosComputerName = '$Agent.ComputerName' and ResolutionState <> '255'"))
    {
        if ($Alert.Id -eq $Id)
        {
            Return $Agent
            }
        }
    }
}


# this will get all agents. Not just windows agents.

$Agents = Get-Agent |Select-Object -Property ComputerName, PrincipalName

foreach($Agent in $Agents)
{
    foreach ($Alert in (Get-Alert -Criteria "NetbiosComputerName = '$Agent.ComputerName' and ResolutionState <> '255'"))   
    {
        if ($Alert.Id -eq $Id)
	    {
            Return $Agent
            }
        }
    }

$Id = "\`d.T.~Ed/{5F53031C-E289-4732-8723-3581DC87EEDC}.Id\`d.T.~Ed/"
$rmsName = 'scom-01.home.ku.edu'
try
{
    $AccountName = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    $Password = ConvertTo-SecureString (Get-Content -Path C:\Temp\scorch-creds.txt) -Key (1..16) 
    $Credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $AccountName, $Password
    }
catch
{
    Out-File C:\temp\cred-error.log -InputObject $Error[0].Exception -Append ascii
    }

try
{
    $RMSSession = New-PSSession -ComputerName $rmsName -Authentication Credssp -Credential (Get-Credential -Credential $Credentials)
    Invoke-Command -Session $RMSSession -ArgumentList $rmsName -ScriptBlock {param ($rmsName) $rms=$rmsName} 
    Invoke-Command -Session $RMSsession -ScriptBlock {add-pssnapin "Microsoft.EnterpriseManagement.OperationsManager.Client"} 
    Invoke-Command -Session $RMSsession -ScriptBlock {Set-Location "OperationsManagerMonitoring::"} 
    Invoke-Command -Session $RMSSession -ScriptBlock {New-ManagementGroupConnection -connectionString:$rms} 
    Invoke-Command -Session $RMSsession -ScriptBlock {Set-Location $rmsName}
    Invoke-Command -Session $RMSSession -ArgumentList $Id -ScriptBlock {param ($id)$id=$id}
    $Alert = Invoke-Command -Session $RMSSession -ArgumentList $Id -ScriptBlock {get-alert -id $id}
    $Agent = Invoke-Command -Session $RMSSession -ArgumentList $Id -ScriptBlock {
        foreach ($Agent in (Get-Agent))
        {
            foreach ($Alert in (Get-Alert |Where-Object {$_.NetbiosComputerName -eq $Agent.ComputerName}))
            {
                if ($Alert.Id -eq $Id)
                {
                    Return $Agent
                    }
                }
            }
        }
    Remove-PsSession -Session $RMSSession
    }
catch
{
    Out-File C:\temp\session-error.log -InputObject $Error[0].Exception -Append ascii
    }
if ($Agent)
{
    if ($Alert)
    {
        $AlertContext = ([xml]$Alert.Context).DataItem
        switch ($alert.Severity.ToString())
        {
            'Error'
            {
                $EntryType = "Error"
                $EventId = "101"
                }
            'Warning'
            {
                $EntryType = "Warning"
                $EventId = "102"
                }
            Default
            {
                # This should never happen generate an alert with new severity
                $EntryType = "Warning"
                $EventId = "102"
                }
            }

        $Hostname = $Agent.ComputerName

        switch ($AlertContext.type)
        {
            'System.PropertyBagData'
            {
                $Source = $Alert.Category
                }
            'System.Performance.ConsecutiveSamplesData'
            {
                $Source = $Alert.Category
                }
            'System.Performance.BaseliningStateData'
            {
                $Source = $Alert.Category
                }
            'System.Performance.AverageData'
            {
                $Source = $Alert.Category
                }
            'System.Mom.BackwardCompatibility.Alert.Data'
            {
                $Source = $Alert.Category
                $EventId = $AlertContext.AlertContext.DataItem.EventNumber
                }
            'System.Event.LinkedData'
            {
                $Source = $AlertContext.type
                $EventId = $AlertContext.EventNumber
                }
            'System.CorrelatorData'
            {
                $Source = $AlertContext.type
                }
            'System.ConsolidatorData'
            {
                $Source = $AlertContext.type
                $EventId = $AlertContext.Context.DataItem.EventNumber
                }
            'System.Availability.StateData'
            {
                $Source = $AlertContext.type
                }
            'MonitorTaskDataType'
            {
                $Source = $AlertContext.type
                }
            'Microsoft.Windows.EventData'
            {
                $Source = $AlertContext.type
                $EventId = $AlertContext.EventNumber
                }
            }

        $Message = "Name : $($Alert.Name)`r`n"
        $Message += "Description : $($Alert.Description)`r`n"
        $Message += "Hostname : $($Hostname)`r`n"
        $Message += "IP Address : $($Agent.IPAddress)`r`n"
        $Message += "OpsMgrId : $($Id)`r`n`r`n"
        $Message += "Context`r`n"
        $Message += $AlertContext |Out-String

        try
        {
            [int32]$EventId
            }
        catch
        {
            if($EntryType -eq "Error")
            {
                $EventId = "101"
                }
            else
            {
                $EventId = 102
                }
            }

        Out-File C:\temp\Alert_Agent.txt -InputObject "$($Source), $($EntryType), $($EventId), $($Message)"
        }
    }