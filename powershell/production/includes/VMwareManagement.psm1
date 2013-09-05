Function Get-VMHostNetworks
{
    <#
        .SYNOPSIS
            Return a list of networks from a given host
        .DESCRIPTION
            After connecting to your VI server, we get a list of virtual switches on the datacenter and from
            that we pull out the VHostID that matches the server we passed in at the command-line. Using the
            VHostID we return a list of networks objects on that server.
        .PARAMETER VMHost
            The name of the VMWare Host Server to pull networks from
        .PARAMETER VIServer
            The name of your VSPhere Server
        .EXAMPLE
            Get-VMHostNetworks -VMHost v1.copmany.com -VIServer vc.company.com
            Name                      Key                            VLanId PortBinding NumPorts
            ----                      ---                            ------ ----------- --------
            Management Network        key-vim.host.PortGroup-Mana... 0
            DMZ Network               key-vim.host.PortGroup-DMZ ... 100
            Admin Network             key-vim.host.PortGroup-Admi... 101

            Description
            -----------
            This shows the output from the command using all parameters.
        .NOTES
            This script requires the VMware vSphere PowerCLI to be downloaded and installed, please see
            the second link for the download.
        .LINK
            https://code.google.com/p/mod-posh/wiki/VMWareManagement#Get-VMHostNetworks
        .LINK
            http://communities.vmware.com/community/vmtn/server/vsphere/automationtools/powercli
        .LINK
            http://www.vmware.com/support/developer/PowerCLI/PowerCLI41U1/html/Connect-VIServer.html
        .LINK
            http://www.vmware.com/support/developer/PowerCLI/PowerCLI41U1/html/Get-VirtualSwitch.html
        .LINK
            http://www.vmware.com/support/developer/PowerCLI/PowerCLI41U1/html/Get-VirtualPortGroup.html
    #>
    [CmdletBinding()]
    Param
        (
        [string]$VMHost,
        [string]$VIServer
        )
    Begin
    {
        Try
        {
            If ($DefaultVIServers -eq $null)
            {
                Connect-VIServer -Server $VIServer |Out-Null
                }
            $VSwitches = Get-VirtualSwitch
            }
        Catch
        {
            Return $Error[0]
            }
        }
    Process
    {
        foreach ($Vswitch in $VSwitches)
        {
            If ($VSwitch.VMHost.Name -like "$($VMhost)*")
            {
                $VHostID = $VSwitch.VMHost.Id
                }
            }

        $VMNetworks = Get-VirtualPortGroup |Where-Object {$_.VMhostID -eq $VhostID}
        }
    End
    {
        Return $VMNetworks
        }
    }
Function Find-EntityView
{
    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER vimClient
        .PARAMETER ViewType
        .PARAMETER MoRef
        .PARAMETER Filter
        .PARAMETER Properties
        .EXAMPLE
        .NOTES
            FunctionName : Find-EntityView
            Created by   : jspatton
            Date Coded   : 08/31/2013 08:35:22
        .LINK
            https://code.google.com/p/mod-posh/wiki/Untitled22#Find-EntityView
    #>
    [CmdletBinding()]
    Param
        (
        [Parameter(Mandatory=$true)]
        [Vmware.Vim.VimClient]$vimClient,
        [ValidateSet("ClusterComputeResource","ComputeResource","Datacenter","Datastore",
                     "DistributedVirtualPortgroup","DistributedVirtualSwitch","Folder",
                     "HostSystem","Network","ResourcePool","StoragePod","VirtualApp",
                     "VirtualMachine","VmwareDistributedVirtualSwitch")]
        [System.String]$ViewType,
        [VMware.Vim.ManagedObjectReference]$MoRef = $null,
        $Filter = $null,
        $Properties = $null
        )
    Begin
    {
        switch ($ViewType)
        {
            "ClusterComputeResource"
            {
                $Type = [VMware.Vim.ClusterComputeResource]
                }
            "ComputeResource"
            {
                $Type = [VMware.Vim.ComputeResource]
                }
            "Datacenter"
            {
                $Type = [VMware.Vim.Datacenter]
                }
            "Datastore"
            {
                $Type = [VMware.Vim.Datastore]
                }
            "DistributedVirtualPortgroup"
            {
                $Type = [VMware.Vim.DistributedVirtualPortgroup]
                }
            "DistributedVirtualSwitch"
            {
                $Type = [VMware.Vim.DistributedVirtualSwitch]
                }
            "Folder"
            {
                $Type = [VMware.Vim.Folder]
                }
            "HostSystem"
            {
                $Type = [VMware.Vim.HostSystem]
                }
            "Network"
            {
                $Type = [VMware.Vim.Network]
                }
            "ResourcePool"
            {
                $Type = [VMware.Vim.ResourcePool]
                }
            "StoragePod"
            {
                $Type = [VMware.Vim.StoragePod]
                }
            "VirtualApp"
            {
                $Type = [VMware.Vim.VirtualApp]
                }
            "VirtualMachine"
            {
                $Type = [VMware.Vim.VirtualMachine]
                }
            "VmwareDistributedVirtualSwitch"
            {
                $Type = [VMware.Vim.VmwareDistributedVirtualSwitch]
                }
            }
        }
    Process
    {
        if (!($MoRef))
        {
            $MoRef = $null
            }
        if ($Filter)
        {
            $ViewFilter = New-Object System.Collections.Specialized.NameValueCollection
            foreach ($Key in $Filter.Keys)
            {
                $ViewFilter.Add($Key,$Filter.Item($Key))
                }
            }
        else
        {
            $ViewFilter = $null
            }
        $viObjects = $vimClient.FindEntityViews($Type,$MoRef,$ViewFilter,$Properties)
        }
    End
    {
        return $viObjects
        }
    }
Function Get-View
{
    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER
        .EXAMPLE
        .NOTES
            FunctionName : Get-View
            Created by   : jspatton
            Date Coded   : 08/31/2013 18:45:43
        .LINK
            https://code.google.com/p/mod-posh/wiki/Untitled22#Get-View
    #>
    [CmdletBinding()]
    Param
        (
        [Parameter(Mandatory=$true)]
        [VMware.Vim.VimClient]$vimClient,
        [Parameter(Mandatory=$true)]
        [VMware.Vim.ManagedObjectReference]$MoRef,
        $Properties
        )
    Begin
    {
        }
    Process
    {
        [VMware.Vim.ViewBase]$viObjects = $vimClient.GetView($MoRef,$Properties)
        }
    End
    {
        return $viObjects
        }
    }
Export-ModuleMember *