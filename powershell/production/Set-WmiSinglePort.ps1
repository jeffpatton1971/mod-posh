<#
    .SYNOPSIS
        A script to either enable or disable WMI fixed port on a computer.
    .DESCRIPTION
        This script will either enable or disable the WMI fixed port settings
        on the local computer based on the value of the WmiMode parameter.
        
        The documentation for how to do this is found in the Related Links 
        section of this help document.
        
        This script will modify settings of your local system, please use
        -whatif and -confirm to see what will happen before it happens.
    .PARAMETER WmiMode
        There are only two values this parameter can be, Enable or Disable. This
        parameter determines the action the script takes on your system. 
        
        If Enable, the single port wmi settings are turned on.
        If Disable, the single port wmi settings are turned off.
    .PARAMETER WhatIf
        When this parameter is passed in, the script will present to you a list
        of actions that will be performed on the local computer. The presence
        of this parameter on the command-line equates to true inside the script.
        
        The default value is false, nothing will be displayed if the parameter
        is not passed in.
    .PARAMETER Confirm
        When this parameter is passed in, the script will perform all the 
        actions displayed if you passed in the WhatIf parameter earlier. The
        presence of this parameter on the command-line equates to true inside
        the script.
        
        The default value is false, no actions will be performed on the local
        computer.
    .EXAMPLE
        .\Set-WmiSinglePort.ps1 -WmiMode Enable
        
        Description
        -----------
        This example shows how to enable Wmi fixed port.
    .EXAMPLE
        .\Set-WmiSinglePort.ps1 -WmiMode Disable
        
        Description
        -----------
        This example shows  how to disable Wmi fixed port.
    .EXAMPLE
        .\Set-WmiSinglePort.ps1 -WmiMode disable -WhatIf

        Executing the following command
        & winmgmt -sharedhost
        Stopping dependent services

        Name : wscsvc
        Name : iphlpsvc
        Name : IAStorDataMgrSvc
        Name : ZcfgSvc7
        Name : EvtEng
        Name : DFEPService

        Restarting the Windows Management Instrumentation service
        Starting dependent services

        Name : wscsvc
        Name : iphlpsvc
        Name : IAStorDataMgrSvc
        Name : ZcfgSvc7
        Name : EvtEng
        Name : DFEPService

        Executing the following command
        & netsh advfirewall firewall delete rule name="Open TCP 24158 (WmiFixedPort)" protocol=TCP localport=24158

        Description
        -----------
        This example shows the use of the WhatIf parameter and it's associated output.
    .NOTES
        ScriptName : Set-WmiSinglePort.ps1
        Created By : jspatton
        Date Coded : 06/13/2012 08:52:33
        ScriptName is used to register events for this script
 
        ErrorCodes
            100 = Success
            101 = Error
            102 = Warning
            104 = Information
        In order for this script to work properly you must run it as an
        administrator from an elevated prompt. The script will terminate if
        those two conditions are not met.
        
        I'm using my own WhatIf and Confirm parameters for greater flexibility.
    .LINK
        https://code.google.com/p/mod-posh/wiki/Production/Set-WmiSinglePort.ps1
    .LINK
        http://msdn.microsoft.com/en-us/library/windows/desktop/bb219447(v=vs.85).aspx
#>
#requires -version 2.0
[CmdletBinding()]
Param
    (
    [Parameter(HelpMessage='Type Enable or Disable')]
    [ValidateSet('Enable','Disable')]
    [string]$WmiMode,
    [switch]$WhatIf = $false,
    [switch]$Confirm = $false
    )
Begin
    {
        $ScriptName = $MyInvocation.MyCommand.ToString()
        $ScriptPath = $MyInvocation.MyCommand.Path
        $Username = $env:USERDOMAIN + "\" + $env:USERNAME
 
        New-EventLog -Source $ScriptName -LogName 'Windows Powershell' -ErrorAction SilentlyContinue
 
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nStarted: " + (Get-Date).toString()
        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message -ErrorAction SilentlyContinue
 
        #	Dotsource in the functions you need.
        $CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = new-object System.Security.principal.windowsprincipal($CurrentUser)

        if ($principal.IsInRole("Administrators") -eq $false) 
        {
            $Message = 'This script must be run as an administrator from an elevated prompt.'
            Write-Error $Message
            Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "101" -EntryType "Error" -Message $Message -ErrorAction SilentlyContinue
            break
            }
            
        Write-Verbose "Setting up winmgmt commands."
        $StandAloneCMD = "& winmgmt -standalonehost"
        Write-Debug "Standalone command`r`n$($StandAloneCMD)"
        $SharedHostCMD = "& winmgmt -sharedhost"
        Write-Debug "Sharedhost command`r`n`$($SharedHostCMD)"
        
        Write-Verbose "Setting up firewall rules"
        $FirewallPortOpening = "& netsh advfirewall firewall add rule name=`"Open TCP 24158 (WmiFixedPort)`" dir=in action=allow protocol=TCP localport=24158"
        Write-Debug "WmiFixedPort rule creation`r`n$($FirewallPortOpening)"
        $FirewallPortClosing = "& netsh advfirewall firewall delete rule name=`"Open TCP 24158 (WmiFixedPort)`" protocol=TCP localport=24158"
        Write-Debug "WmiFixedPort rule deletion`r`n$($FirewallPortClosing)"
        
        Write-Verbose "Getting the list of services that depend on WMI"
        $Dependencies = Get-Service -Name winmgmt -DependentServices |Where-Object {$_.Status -eq 'Running'}
        }
Process
    {
        switch ($WmiMode)
        {
            "Enable"
            {
                if ($WhatIf)
                {
                    Write-Host "Executing the following command"
                    Write-Host $StandAloneCMD
                    }
                else
                {
                    if ($Confirm)
                    {
                        $Message = "Setting the Windows Management Instrumentation service to single mode."
                        Write-Verbose $Message
                        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message -ErrorAction SilentlyContinue
                        Invoke-Expression -Command $StandAloneCMD
                        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $StandAloneCMD -ErrorAction SilentlyContinue
                        }
                    }
                if ($WhatIf)
                {
                    Write-Host "Stopping dependent services"
                    $Dependencies |Format-List -Property Name
                    }
                else
                {
                    if ($Confirm)
                    {
                        foreach ($Service in $Dependencies)
                        {
                            $Message = "Stopping dependent service $($Service.Name)"
                            Write-Verbose $Message
                            Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message -ErrorAction SilentlyContinue
                            try
                            {
                                $Service.Stop()
                                $Service.WaitForStatus('Stopped')
                                $Message = "$($Service.Name) stopped."
                                Write-Debug $Message
                                }
                            catch
                            {
                                $Message = $Error[0].Exception.InnerException.Message
                                Write-Verbose $Message
                                Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "101" -EntryType "Error" -Message $Message -ErrorAction SilentlyContinue
                                }
                            }
                        }
                    }
                if ($WhatIf)
                {
                    Write-Host "Restarting the Windows Management Instrumentation service"
                    }
                else
                {
                    if ($Confirm)
                    {
                        $Message = "Restarting the Windows Management Instrumentation service"
                        Write-Verbose $Message
                        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message -ErrorAction SilentlyContinue
                        Restart-Service -Name winmgmt -Force
                        }
                    }
                if ($WhatIf)
                {
                    Write-Host "Starting dependent services"
                    $Dependencies |Format-List -Property Name
                    }
                else
                {
                    if ($Confirm)
                    {
                        foreach ($Service in $Dependencies)
                        {
                            $Message = "Starting dependent service $($Service.Name)"
                            Write-Verbose $Message
                            Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message -ErrorAction SilentlyContinue
                            try
                            {
                                $Service.Start()
                                $Service.WaitForStatus('Running')
                                $Message = "$($Service.Name) started."
                                Write-Debug $Message
                                }
                            catch
                            {
                                $Message = $Error[0].Exception.InnerException.Message
                                Write-Verbose $Message
                                Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "101" -EntryType "Error" -Message $Message -ErrorAction SilentlyContinue
                                }
                            }
                        }
                    }
                if ($WhatIf)
                {
                    Write-Host "Executing the following command"
                    Write-Host $FirewallPortOpening
                    }
                else
                {
                    if ($Confirm)
                    {
                        $Message = "Opening TCP Port 24158 for Single Port WMI calls"
                        Write-Verbose $Message
                        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message -ErrorAction SilentlyContinue
                        Invoke-Expression -Command $FirewallPortOpening
                        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $FirewallPortOpening -ErrorAction SilentlyContinue
                        }
                    }
                }
            "Disable"
            {
                if ($WhatIf)
                {
                    Write-Host "Executing the following command"
                    Write-Host $SharedHostCMD
                    }
                else
                {
                    if ($Confirm)
                    {
                        $Message = "Setting the Windows Management Instrumentation service to shared host."
                        Write-Verbose $Message
                        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message -ErrorAction SilentlyContinue
                        Invoke-Expression -Command $SharedHostCMD
                        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $SharedHostCMD -ErrorAction SilentlyContinue
                        }
                    }
                if ($WhatIf)
                {
                    Write-Host "Stopping dependent services"
                    $Dependencies |Format-List -Property Name
                    }
                else
                {
                    if ($Confirm)
                    {
                        foreach ($Service in $Dependencies)
                        {
                            $Message = "Stopping dependent service $($Service.Name)"
                            Write-Verbose $Message
                            Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message -ErrorAction SilentlyContinue
                            try
                            {
                                $Service.Stop()
                                $Service.WaitForStatus('Stopped')
                                $Message = "$($Service.Name) stopped."
                                Write-Debug $Message
                                }
                            catch
                            {
                                $Message = $Error[0].Exception.InnerException.Message
                                Write-Verbose $Message
                                Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "101" -EntryType "Error" -Message $Message -ErrorAction SilentlyContinue
                                }
                            }
                        }
                    }
                if ($WhatIf)
                {
                    Write-Host "Restarting the Windows Management Instrumentation service"
                    }
                else
                {
                    if ($Confirm)
                    {
                        $Message = "Restarting the Windows Management Instrumentation service"
                        Write-Verbose $Message
                        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message -ErrorAction SilentlyContinue
                        Restart-Service -Name winmgmt -Force
                        }
                    }
                if ($WhatIf)
                {
                    Write-Host "Starting dependent services"
                    $Dependencies |Format-List -Property Name
                    }
                else
                {
                    if ($Confirm)
                    {
                        foreach ($Service in $Dependencies)
                        {
                            $Message = "Starting dependent service $($Service.Name)"
                            Write-Verbose $Message
                            Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message -ErrorAction SilentlyContinue
                            try
                            {
                                $Service.Start()
                                $Service.WaitForStatus('Running')
                                $Message = "$($Service.Name) started."
                                Write-Debug $Message
                                }
                            catch
                            {
                                $Message = $Error[0].Exception.InnerException.Message
                                Write-Verbose $Message
                                Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "101" -EntryType "Error" -Message $Message -ErrorAction SilentlyContinue
                                }
                            }
                        }
                    }
                if ($WhatIf)
                {
                    Write-Host "Executing the following command"
                    Write-Host $FirewallPortClosing
                    }
                else
                {
                    if ($Confirm)
                    {
                        $Message = "Closing TCP Port 24158 to Single Port WMI calls"
                        Write-Verbose $Message
                        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message -ErrorAction SilentlyContinue
                        Invoke-Expression -Command $FirewallPortClosing
                        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $FirewallPortClosing -ErrorAction SilentlyContinue
                        }
                    }
                }
            }
        }
End
    {
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message -ErrorAction SilentlyContinue
        }