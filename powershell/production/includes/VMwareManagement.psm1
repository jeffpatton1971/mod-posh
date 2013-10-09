Function Get-vmHostNetworks
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
            https://code.google.com/p/mod-posh/wiki/VMWareManagement#Get-vmHostNetworks
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
Function Find-vmEntityView
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
            https://code.google.com/p/mod-posh/wiki/VMWareManagement#Find-vmEntityView
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
Function Get-vmView
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
            https://code.google.com/p/mod-posh/wiki/VMWareManagement#Get-vmView
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
Function Set-vmHotAddFeature
{
    <#
        .SYNOPSIS
            Enable or Disable the Hot Add memory and CPU feature for a VM
        .DESCRIPTION
            This function allows you to either enable or disable hot add features
            on a VM. You will need to run this function inside the vSphere
            PowerCLI shell, or have the VMWare Snap-in loaded.
        .PARAMETER Name
            The name of the virtual machine
        .PARAMETER Feature
            Currently supported features are
                mem.hotadd
                vcpu.hotadd
        .PARAMETER Enable
            This is either $true or $false, the default is set to $true
        .EXAMPLE
            Set-vmHotAddFeature cm12-test vcpu.hotadd

            Name                                                        MemoryHotAddEnabled
            ----                                                        -------------------
            cm12-test                                                                  True

            Description
            -----------
            This is the basic usage of the command
        .EXAMPLE
            "cm12-test","gpo-testing" |Set-vmHotAddFeature -Feature mem.hotadd -Enable $false

            Name                                                        MemoryHotAddEnabled
            ----                                                        -------------------
            cm12-test                                                                 False
            gpo-testing                                                               False

            Description
            -----------
            This example shows how to pass names of vm's across the pipeline to the function
        .NOTES
            FunctionName : Set-vmHotAddFeature
            Created by   : jspatton
            Date Coded   : 10/09/2013 09:24:54
        .LINK
            https://code.google.com/p/mod-posh/wiki/VMWareManagement#Set-vmHotAddFeatures
        .LINK
            http://www.vmware.com/support/developer/PowerCLI/PowerCLI41/html/Get-VM.html
        .LINK
            http://www.vmware.com/support/developer/PowerCLI/PowerCLI41/html/Get-View.html
    #>
    [CmdletBinding()]
    Param
        (
        [Parameter(Mandatory=$false,ValueFromPipeline=$true,Position=1)]
        [string]$Name,
        [Parameter(Mandatory=$True,Position=2)]
        [ValidateSet("mem.hotadd","vcpu.hotadd")]
        [string]$Feature,
        [Parameter(Position=3)]
        [bool]$Enable = $True
        )
    Begin
    {
        try
        {
            $vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec
            $optionValue = New-Object VMware.Vim.OptionValue
            }
        catch
        {
            Write-Error $Error[0]
            break
            }
        }
    Process
    {
        try
        {
            Write-Verbose "Get the view object for the passed in VM"
            $Vm = Get-VM -Name $Name
            $vmView = $VM |Get-View
            Write-Verbose "Changing $($Feature)"
            switch ($Feature)
            {
                "mem.hotadd"
                {
                    if ($Enable)
                    {
                        Write-Verbose "Enable $($Feature)"
                        $optionValue.Key = "mem.hotadd"
                        $optionValue.Value = "true"
                        }
                    else
                    {
                        Write-Verbose "Disable $($Feature)"
                        $optionValue.Key = "mem.hotadd"
                        $optionValue.Value = "false"
                        }
                    }
                "vcpu.hotadd"
                {
                    if ($Enable)
                    {
                        Write-Verbose "Enable $($Feature)"
                        $optionValue.Key = "vcpu.hotadd"
                        $optionValue.Value = "true"
                        }
                    else
                    {
                        Write-Verbose "Disable $($Feature)"
                        $optionValue.Key = "vcpu.hotadd"
                        $optionValue.Value = "false"
                        }
                    }
                }
            Write-Verbose "Update VM"
            $vmConfigSpec.ExtraConfig += $optionValue
            $vmView.ReconfigVM($vmConfigSpec)
            switch ($Feature)
            {
                "mem.hotadd"
                {
                    Return $VM |Get-View |Select-Object Name, @{Name="MemoryHotAddEnabled";Expression={$_.Config.MemoryHotAddEnabled}}
                    }
                "vcpu.hotadd"
                {
                    Return $VM |Get-View |Select-Object Name, @{Name="CpuHotAddEnabled";Expression={$_.Config.CpuHotAddEnabled}}
                    }
                }
            }
        catch
        {
            Write-Error $Error[0]
            break
            }
        }
    End
    {
        }
    }
Export-ModuleMember *