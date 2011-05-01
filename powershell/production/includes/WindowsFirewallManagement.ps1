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
                http://scripts.patton-tech.com/wiki/PowerShell/WindowsFirewallManagement#Get-FWServices
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
                    $ThisService = New-Object -TypeName PSObject
                    Add-Member -InputObject $ThisService -MemberType NoteProperty -Name "Property" -Value "Service"
                    Add-Member -InputObject $ThisService -MemberType NoteProperty -Name "Name" -Value $item.Name
                    Add-Member -InputObject $ThisService -MemberType NoteProperty -Name "Type" -Value $item.Type
                    Add-Member -InputObject $ThisService -MemberType NoteProperty -Name "Customized" -Value $Item.Customized
                    Add-Member -InputObject $ThisService -MemberType NoteProperty -Name "IpVersion" -Value $item.IpVersion
                    Add-Member -InputObject $ThisService -MemberType NoteProperty -Name "Scope" -Value $item.Scope
                    Add-Member -InputObject $ThisService -MemberType NoteProperty -Name "RemoteAddresses" -Value $item.RemoteAddresses
                    Add-Member -InputObject $ThisService -MemberType NoteProperty -Name "Enabled" -Value $item.Enabled
                    Add-Member -InputObject $ThisService -MemberType NoteProperty -Name "Protocol" -Value "-"
                    Add-Member -InputObject $ThisService -MemberType NoteProperty -Name "Port" -Value "-"
                    Add-Member -InputObject $ThisService -MemberType NoteProperty -Name "Builtin" -Value "-"
                    ForEach ($entry in $Item.GloballyOpenPorts)
                    {
                        $ThisEntry = New-Object -TypeName PSObject
                        Add-Member -InputObject $ThisEntry -MemberType NoteProperty -Name "Property" -Value "Port"
                        Add-Member -InputObject $ThisEntry -MemberType NoteProperty -Name "Name" -Value $entry.Name
                        Add-Member -InputObject $ThisEntry -MemberType NoteProperty -Name "Type" -Value "-"
                        Add-Member -InputObject $ThisEntry -MemberType NoteProperty -Name "Customized" -Value "-"
                        Add-Member -InputObject $ThisEntry -MemberType NoteProperty -Name "IpVersion" -Value $entry.IpVersion
                        Add-Member -InputObject $ThisEntry -MemberType NoteProperty -Name "Scope" -Value $entry.Scope
                        Add-Member -InputObject $ThisEntry -MemberType NoteProperty -Name "RemoteAddresses" -Value $entry.RemoteAddresses
                        Add-Member -InputObject $ThisEntry -MemberType NoteProperty -Name "Enabled" -Value $entry.Enabled
                        Add-Member -InputObject $ThisEntry -MemberType NoteProperty -Name "Protocol" -Value $entry.Protocol
                        Add-Member -InputObject $ThisEntry -MemberType NoteProperty -Name "Port" -Value $entry.Port
                        Add-Member -InputObject $ThisEntry -MemberType NoteProperty -Name "BuiltIn" -Value $entry.Builtin
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
                http://scripts.patton-tech.com/wiki/PowerShell/WindowsFirewallManagement#Get-FWApplications
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
                http://scripts.patton-tech.com/wiki/PowerShell/WindowsFirewallManagement#Get-FWGloballyOpenPorts
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
                http://scripts.patton-tech.com/wiki/PowerShell/WindowsFirewallManagement#New-FWPortOpening
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