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