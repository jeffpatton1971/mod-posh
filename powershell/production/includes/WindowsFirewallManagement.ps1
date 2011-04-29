Function Get-FWServices
    {
        <#
            .SYNOPSIS
            .DESCRIPTION
            .EXAMPLE
            .NOTES
            .LINK
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
            .DESCRIPTION
            .EXAMPLE
            .NOTES
            .LINK
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
            .DESCRIPTION
            .EXAMPLE
            .NOTES
            .LINK
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
            .DESCRIPTION
            .EXAMPLE
            .NOTES
            .LINK
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