<#
    .SYNOPSIS
        Export an Eventlog from a local or remote computer
    .DESCRIPTION
        This function will export the logname you specify to the folder
        and filename that you provide. The exported file is in the native
        format for Event logs. 
            
        This function leverages the System.Diagnostics.Eventing.Reader class
        to export the log of the local or remote computer.
    .PARAMETER ComputerName
        Type the NetBIOS name, an Internet Protocol (IP) address, or the fully 
        qualified domain name of the computer. The default value is the local 
        computer.

        This parameter accepts only one computer name at a time. To find event logs 
        or events on multiple computers, use a ForEach statement. 
           
        To get events and event logs from remote computers, the firewall port for 
        the event log service must be configured to allow remote access.
    .PARAMETER Credential
        Specifies a user account that has permission to perform this action. The 
        default value is the current user.
    .PARAMETER ListLog
        If present the function will list all the logs currently available on the
        computer.
    .PARAMETER LogName
        Export messages from the specified LogName
    .PARAMETER Destination
        The full path and filename to where the log should be exported to.
    .EXAMPLE
        Export-EventLogs -ComputerName sql -Credential (Get-Credential) -LogName Application -Destination 'C:\LogFiles1\Application.evtx'
            
        Description
        -----------
        This example shows how to export the Application log from a computer named SQL and save
        the file as Application.evtx in a folder called LogFiles. This also shows how to use 
        the Get-Credential cmdlet to pass credentials into the function.
    .EXAMPLE
        Export-EventLog -ListLog
        Application
        HardwareEvents
        Internet Explorer
        Key Management Service
        Media Center
            
        Description
        -----------
        This example shows how to list the lognames on the local computer
    .EXAMPLE
        Export-EventLog -LogName Application -Destination C:\Logs\App.evtxExport-EventLog -LogName Application -Destination C:\Logs\App.evtx
            
        Description
        -----------
        This example shows how to export the Application log on the local computer to
        a folder on the local computer.
    .NOTES
        FunctionName : Export-EventLogs
        Created by   : jspatton
        Date Coded   : 04/30/2012 12:36:12
            
        The folder and filename that you specify will be created on the remote machine.
    .LINK
        https://code.google.com/p/mod-posh/wiki/ComputerManagement#Export-EventLog
#>
[CmdletBinding()]
    Param
        (
        $ComputerName,
        $Credential,
        [switch]$ListLog,
        $LogName,
        $Destination
        )
Begin
{
    $Remote = $false
    if (!($ComputerName))
    {
        Write-Verbose "No ComputerName passed, setting ComputerName to $(& hostname)"
        $ComputerName = (& hostname)
        }
    if ($Credential)
    {
        Write-Verbose "Attempting to connect to $($ComputerName) as $($Credential.Username)"
        $EventSession = New-Object System.Diagnostics.Eventing.Reader.EventLogSession($ComputerName, `
                                                                                        $Credential.GetNetworkCredential().Domain, `
                                                                                        $Credential.GetNetworkCredential().Username, `
                                                                                        $Credential.Password,'Default')
        $Remote = $true
        }
    else
    {
        Write-Verbose "Connecting to $($ComputerName)"
        $EventSession = New-Object System.Diagnostics.Eventing.Reader.EventLogSession($ComputerName)
        }
    }
Process
{
    switch ($ListLog)
    {
        $true
        {
            try
            {
                Write-Verbose "Outputting a list of all lognames"
                $EventSession.GetLogNames()
                }
            catch
            {
                Write-Error $Error[0]
                break
                }
            }
        $false
        {
            try
            {
                if (($EventSession.GetLogNames() |Where-Object {$_ -eq $LogName}) -eq $null)
                {
                    Write-Error "There is not an event log on the $($ComputerName) computer that matches `"$($LogName)`""
                    }
                else
                {
                    if ($Remote)
                    {
                        Write-Verbose "Checking to see if \\$($ComputerName)\$((([System.IO.Directory]::GetParent($Destination)).FullName).Replace(":","$")) exists"
                        if ((Test-Path -Path "\\$($ComputerName)\$((([System.IO.Directory]::GetParent($Destination)).FullName).Replace(":","$"))") -ne $true)
                        {
                            Write-Verbose "Creating $((([System.IO.Directory]::GetParent($Destination)).FullName).Replace(":","$"))"
                            $ScriptBlock = {New-Item -Path $args[0] -ItemType Directory -Force}
                            Invoke-Command -ScriptBlock $ScriptBlock -ComputerName $ComputerName -Credential $Credential -ArgumentList (([System.IO.Directory]::GetParent($Destination)).FullName) |Out-Null
                            }
                        }
                    else
                    {
                        Write-Verbose "Checking to see if $($Destination) exists."
                        if ((Test-Path $Destination) -ne $true)
                        {
                            Write-Verbose "Creating $((([System.IO.Directory]::GetParent($Destination)).FullName).Replace(":","$"))"
                            New-Item -Path (([System.IO.Directory]::GetParent($Destination)).FullName) -ItemType Directory -Force |Out-Null
                            }
                        }
                    Write-Verbose "Exporting event log $($LogName) to the following location $($Destination)"
                    $EventSession.ExportLogAndMessages($LogName,'LogName','*',$Destination)
                    }
                }
            catch
            {
                Write-Error $Error[0]
                break
                }
            }
        }
        
    }
End
{
    }