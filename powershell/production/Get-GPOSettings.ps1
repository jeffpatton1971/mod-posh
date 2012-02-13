<#
    .SYNOPSIS
        Get-GPOSettings
    .DESCRIPTION
        This script gets a list of all Group Policy Objects in the domain filtered on the value
        of GPOSettingName. For each GPO if the Extension Name matches GPOSettingName the Extensions
        are then reported back. 
    .PARAMETER GPOSettingName
        The name of the GPO Setting you want to filter on. This can be viewed by using the 
        GPO search function of the GPMC.
    .PARAMETER GPOSettingGuid
        The GUID of the GPOSettingName, the only way to determine this is to enable GPMC
        logging in the registry, and then grep the log file for the GPO Setting Name.
    .PARAMETER GPOComputerContext
        Any value other than $true will switch the script to evaluate the user policies.
    .EXAMPLE
        .\Get-GPOSettings.ps1
        
        Description
        -----------
        
        The default syntax returns a list of Deployed Printer connections. 
    .NOTES
        ScriptName: Get-GPOSettings.ps1
        Created By: Jeff Patton
        Date Coded: August 18, 2011
        ScriptName is used to register events for this script
        LogName is used to determine which classic log to write to
        This script relies on the Get-ADObject and Get-GPO cmdlet that are provided from
        the ActiveDirectory and GroupPolicy modules.
    .LINK
        https://code.google.com/p/mod-posh/wiki/Get-GPOSettings
    .LINK
        http://www.ldap389.info/en/2010/09/17/powershell-search-settings-gpo-parameter-configuration-gpmc/
    .LINK
        http://technet.microsoft.com/en-us/library/ee617198.aspx
    .LINK
        http://technet.microsoft.com/en-us/library/ee461059.aspx
#>
Param
    (
        $GPOSettingName = "Deployed Printer Connections Policy",
        $GPOSettingGuid = "{8A28E2C5-8D06-49A4-A08C-632DAA493E17}",
        $GPOComputerContext = $true
    )
Begin
    {
        $ScriptName = $MyInvocation.MyCommand.ToString()
        $LogName = "Application"
        $ScriptPath = $MyInvocation.MyCommand.Path
        $Username = $env:USERDOMAIN + "\" + $env:USERNAME

        New-EventLog -Source $ScriptName -LogName $LogName -ErrorAction SilentlyContinue

        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nStarted: " + (Get-Date).toString()
        Write-EventLog -LogName $LogName -Source $ScriptName -EventID "100" -EntryType "Information" -Message $Message

        $GPOSettingGuid = "*$($GPOSettingGuid)*"
        
        $ErrorActionPreference = "Stop"
        #	Dotsource in the functions you need.

        Try
        {
            Import-Module GroupPolicy
            Import-Module ActiveDirectory
            }
        Catch
        {
            Write-Warning "Must have the Active Directory and Group Policy cmdlets installed."
            Write-EventLog -LogName $LogName -Source $ScriptName -EventID "101" -EntryType "Error" -Message "RSAT installed?"
            Break
            }

        Switch ($GPOComputerContext)
        {
            $true
            {
                $GPOs = Get-ADObject -Filter {(ObjectClass -eq "groupPolicyContainer") -and (gPCMachineExtensionNames -like $GPOSettingGuid)}
                }
            Default
            {
                $GPOs = Get-ADObject -Filter {(ObjectClass -eq "groupPolicyContainer") -and (gPCUserExtensionNames -like $GPOSettingGuid)}
                }
            }
    }
Process
    {
        If ($GPOs -ne $null)
        {
            $Report = @()
            foreach ($GPO in $GPOs)
            {
                [XML]$GPOReport = Get-GPOReport -Guid $GPO.Name -ReportType XML
                Try
                {
                    Switch ($GPOComputerContext)
                    {
                        $true
                        {
                            foreach ($Extension in $GPOReport.GPO.Computer.ExtensionData)
                            {
                                if ($Extension.Name -eq $GPOSettingName)
                                {
                                    $Settings = $Extension.Extension.ChildNodes
                                    }
                                }
                            If ($Settings -ne $null)
                            {
                                foreach ($Setting in $Settings)
                                {
                                    $ReportItem = New-Object -TypeName PSObject -Property @{
                                        Name = $GPOReport.GPO.Name
                                        GUID = $GPO.Name
                                        Setting = $Setting.InnerText
                                        }
                                    $Report += $ReportItem
                                    }
                                }
                            }
                        Default
                        {
                            foreach ($Extension in $GPOReport.GPO.User.ExtensionData)
                            {
                                if ($Extension.Name -eq $GPOSettingName)
                                {
                                    $Settings = $Extension.Extension.ChildNodes
                                    }
                                }
                            If ($Settings -ne $null)
                            {
                                foreach ($Setting in $Settings)
                                {
                                    $ReportItem = New-Object -TypeName PSObject -Property @{
                                        Name = $GPOReport.GPO.Name
                                        GUID = $GPO.Name
                                        Setting = $Setting.InnerText
                                        }
                                    $Report += $ReportItem
                                    }
                                }
                            }
                        }
                    }
                Catch
                {
                    Write-Error $Error[0].Exception.InnerException.Message.ToString().Trim()
                    Write-EventLog -LogName $LogName -Source $ScriptName -EventID "100" -EntryType "Information" -Message $Error[0]
                    }
                }
            }
    }
End
    {
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName $LogName -Source $ScriptName -EventID "100" -EntryType "Information" -Message $Message	
        
        Return $Report
    }
