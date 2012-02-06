Function Get-FWServices
    {
        <#
            .SYNOPSIS
                Return a list of services allowed through the firewall
            .DESCRIPTION
                This function returns a list of services and related ports that are allowed through the Windows Firewall
            .EXAMPLE
                Get-FWServices |Format-Table

                Property  Name           Type Customize IpVersion     Scope RemoteAdd   Enabled Protocol  Port
                                                      d                     resses
                --------  ----           ---- --------- ---------     ----- ---------   ------- --------  ----
                Service   File a...         0     False         2         1 LocalS...      True -         -
                Port      File a...         -         -         2         1 LocalS...      True 17        138
                Service   Networ...         1     False         2         1 LocalS...     False -         -
                Port      Networ...         -         -         2         1 LocalS...     False 6         2869
                Service   Remote...         2     False         2         0 *             False -         -
                Port      Remote...         -         -         2         0 *             False 6         3389

                Description
                -----------
                This example shows the output of the function piped through Format-Table
            .NOTES
            .LINK
                https://code.google.com/p/mod-posh/wiki/WindowsFirewallManagement#Get-FWServices
        #>
        
        Begin
            {
                $Firewall = New-Object -ComObject "HNetCfg.FwMgr"
                $FirewallPolicy = $Firewall.LocalPolicy.CurrentProfile 
            }
        Process
            {
                $FWServices = @()

                ForEach($item in $FirewallPolicy.Services)
                {
                    $ThisService = New-Object -TypeName PSObject -Property @{
                        Property = "Service"
                        Name = $item.Name
                        Type = $item.Type
                        Customized = $Item.Customized
                        IpVersion = $item.IpVersion
                        Scope = $item.Scope
                        RemoteAddresses = $item.RemoteAddresses
                        Enabled = $item.Enabled
                        Protocol = "-"
                        Port = "-"
                        Builtin = "-"
                        }
                    ForEach ($entry in $Item.GloballyOpenPorts)
                    {
                        $ThisEntry = New-Object -TypeName PSObject -Property @{
                            Property = "Port"
                            Name = $entry.Name
                            Type = "-"
                            Customized = "-"
                            IpVersion = $entry.IpVersion
                            Scope = $entry.Scope
                            RemoteAddresses = $entry.RemoteAddresses
                            Enabled = $entry.Enabled
                            Protocol = $entry.Protocol
                            Port = $entry.Port
                            BuiltIn = $entry.Builtin
                            }
                    }
                    $FWServices += $ThisService
                    $FwServices += $ThisEntry
                }
        }
    End
        {
            Return $FwServices
        }
    }
Function Get-FWApplications
    {
        <#
            .SYNOPSIS
                Return a list of applicaitons allowed
            .DESCRIPTION
                This function returns a list of applications that have been authorized through the Windows Firewall.
            .EXAMPLE
                Get-FWApplications |Format-Table

                ProcessImageFi Name               IpVersion Property      RemoteAddress       Enabled         Scope
                leName                                                    es
                -------------- ----               --------- --------      -------------       -------         -----
                C:\Program ... VMware Authd               2 Application   *                      True             0
                C:\Program ... Bonjour Ser...             2 Application   *                      True             0
                C:\users\je... dropbox.exe                2 Application   *                      True             0
                C:\program ... Opera Inter...             2 Application   *                      True             0
                C:\program ... Microsoft O...             2 Application   *                      True             0

                Description
                -----------
                Sample output piped through Format-Table
            .NOTES
            .LINK
                https://code.google.com/p/mod-posh/wiki/WindowsFirewallManagement#Get-FWApplications
        #>

        Begin
            {
                $Firewall = New-Object -ComObject "HNetCfg.FwMgr"
                $FirewallPolicy = $Firewall.LocalPolicy.CurrentProfile 
            }
        Process
            {
                $Applications = @()

                ForEach($item in $FirewallPolicy.AuthorizedApplications)
                {
                    $ThisApplication = New-Object -TypeName PSObject -Property @{
                        Property = "Application"
                        Name = $item.Name
                        ProcessImageFileName = $item.ProcessImageFileName
                        IpVersion = $item.IpVersion
                        Scope = $item.Scope
                        RemoteAddresses = $item.RemoteAddresses
                        Enabled = $item.Enabled
                        }
                    $Applications += $ThisApplication
                }
            }
        End
            {
                Return $Applications
            }
    }
Function Get-FWGloballyOpenPorts
    {
        <#
            .SYNOPSIS
                Return ports that are open across all profiles.
            .DESCRIPTION
                This function returns a list of Globally Open Ports that are available on the Windows Firewall
            .EXAMPLE
                Get-FWGloballyOpenPorts |Format-Table

                RemoteAddres Name            IpVersion         Port       Scope    Protocol     Enabled     BuiltIn
                ses
                ------------ ----            ---------         ----       -----    --------     -------     -------
                *            Allowed P...            2          456           0          17        True       False
                *            Allowed P...            2          123           0           6        True       False

                Description
                -----------
                Sample output piped through Format-Table
            .NOTES
            .LINK
                https://code.google.com/p/mod-posh/wiki/WindowsFirewallManagement#Get-FWGloballyOpenPorts
        #>

        Begin
            {
                $Firewall = New-Object -ComObject "HNetCfg.FwMgr"
                $FirewallPolicy = $Firewall.LocalPolicy.CurrentProfile 
            }
        Process
            {
                $OpenPorts = @()

                ForEach($item in $FirewallPolicy.GloballyOpenPorts)
                {
                    $ThisPort = New-Object -TypeName PSObject -Property @{
                        Name = $item.Name
                        IpVersion = $item.IpVersion
                        Protocol = $item.Protocol
                        Port = $item.Port
                        Scope = $item.Scope
                        RemoteAddresses = $item.RemoteAddresses
                        Enabled = $item.Enabled
                        BuiltIn = $item.BuiltIn
                        }
                    $OpenPorts += $ThisPort
                }
            }
        End
            {
                Return $OpenPorts
            }
    }
Function New-FWPortOpening
    {
        <#
            .SYNOPSIS
                Create a port opening in Windows Firewall.
            .DESCRIPTION
                This function creates a port opening in the Windows Firewall.
            .EXAMPLE
                New-FWPortOpening -RuleName Rule1 -RuleProtocol 6 -RulePort 123 -RuleRemoteAddresses *
                
                Get-FWGloballyOpenPorts

                RemoteAddresses : *
                Name            : Rule1
                IpVersion       : 2
                Port            : 123
                Scope           : 0
                Protocol        : 6
                Enabled         : False
                BuiltIn         : False
                
                Description
                -----------
                This example shows setting a portopening, and then viewing the newly created rule.
            .NOTES
                In order for this function to work properly you will need to run this function in an elevated PowerShell
                prompt, as well as have the permissions to modify the firewall.
            .LINK
                https://code.google.com/p/mod-posh/wiki/WindowsFirewallManagement#New-FWPortOpening
        #>

        Param
            (
                [string]$RuleName,
                [int]$RuleProtocol,
                [double]$RulePort,
                [string]$RuleRemoteAddresses,
                [bool]$RuleEnabled
            )

        Begin
            {
                $FwMgr = New-Object -ComObject HNetCfg.FwMgr
                $FwProfile = $FwMgr.LocalPolicy.CurrentProfile
            }
        Process
            {
                $FwPort = New-Object -ComObject HNetCfg.FwOpenPort
                $FwPort.Name = $RuleName
                $FwPort.Protocol = $RuleProtocol
                $FwPort.Port = $RulePort
                $FwPort.RemoteAddresses = $RuleRemoteAddresses
                $FwPort.Enabled = $RuleEnabled
            }
        End
            {
                $FwProfile.GloballyOpenPorts.Add($FwPort)
            }
    }
