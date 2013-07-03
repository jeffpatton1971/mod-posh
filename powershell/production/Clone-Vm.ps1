<#
    .SYNOPSIS
        A script that will clone a GM to a new VM
    .DESCRIPTION
        This script will take several parameters to create a brand new vm
    .PARAMETER Cluster
        The cluster that you will want to connect to
    .PARAMETER Datastore
        A datastore with enough space to hold the vm
    .PARAMETER NetworkName
        The name of the virtual network to connect this vm to
    .PARAMETER VmName
        The name of the virtual machine
    .PARAMETER Ram
        The amount of ram, expressed in MB so for 8gb use 8192
    .PARAMETER Cores
        The number of cores to assign to this vm
    .PARAMETER IpAddress
        A valid IP address
    .PARAMETER SubnetMask
        A valid subnet
    .PARAMETER DefaultGateway
        A valid gateway address
    .PARAMETER CloneVM
        The name of the Gold Master to clone from
    .EXAMPLE
        .\Clone-Vm -Cluster 'Test Cluster' -Datastore 'vmclst-tst_vnxp_big_01' -NetworkName 'dv_VLAN_104_Exchange_AD_Network' -VmName 'sample-vm' -Ram '8192' -Cores '4' -IpAddress '129.237.34.110' -SubnetMask '255.255.255.128' -DefaultGateway '129.237.34.126' -CloneVM 'GM-Win2008_R2'

        Description
        -----------
        This will create a new vm called sample-vm from the GM-Win2008_R2 vm. This machine will be placed in the Exchange network with a proper IP address and subnet.
    .NOTES
        ScriptName : Clone-Vm.ps1
        Created By : jspatton
        Date Coded : 01/14/2013 09:38:19
        ScriptName is used to register events for this script
 
        ErrorCodes
            100 = Success
            101 = Error
            102 = Warning
            104 = Information


        You will need to have the PowerCLI tools installed.
    .LINK
        https://code.google.com/p/mod-posh/wiki/Production/Clone-Vm.ps1
#>
[CmdletBinding()]
Param
    (
    $Cluster = 'C1v5 Cluster',
    $Datastore = 'vmclst-a_vnxp_san_01',
    $NetworkName = 'dv_VLAN_105_VLI_Auth_Servers',
    $VmName = 'adhome-sync-01',
    $Ram = '8192',
    $Cores = '4',
    $IpAddress = '129.237.34.203',
    $SubnetMask = '255.255.255.128',
    $DefaultGateway = '129.237.34.254',
    $CloneVm = 'GM-Win2008_R2',
    $Join = 'OU=Federation Services,OU=AD,DC=home,DC=ku,DC=edu'
    )
 Begin
   {
        $ScriptName = $MyInvocation.MyCommand.ToString()
        $ScriptPath = $MyInvocation.MyCommand.Path
        $Username = $env:USERDOMAIN + "\" + $env:USERNAME
 
        New-EventLog -Source $ScriptName -LogName 'Windows Powershell' -ErrorAction SilentlyContinue
 
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nStarted: " + (Get-Date).toString()
        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message
 
        #	Dotsource in the functions you need.
        if ((Get-PSSnapin -Name VMware.VimAutomation.Core))
        {
            }
        else
        {
            try
            {
                Add-PSSnapin -Name VMware.VimAutomation.Core
                }
            catch
            {
                Write-Host "Please download and install the PowerCLI from vmware's website, or run this from a computer that has the tools already installed."
                break                    
                }
            }
        $ViServer = 'vmclst-vc.home.ku.edu'
        Connect-viserver $ViServer
        $DiskFormat = 'Thin'
        $SpecFile = 'PowerCLI-Windows-2k8r2'
        $IpMode = 'UseStaticIp'
        $DnsServer = '129.237.34.200'
        }
Process
    
    {
        if ($Join)
        {
            # Check AD for $VmName
            try
            {
                $ADSPath = (([ADSI]"").distinguishedName)
                $DirectoryEntry = New-Object System.DirectoryServices.DirectoryEntry("LDAP://$($ADSPath)")
                $DirectorySearcher = New-Object System.DirectoryServices.DirectorySearcher
                $DirectorySearcher.SearchRoot = $DirectoryEntry
                $DirectorySearcher.PageSize = 1000
                $DirectorySearcher.Filter = "(cn=$($VmName))"
                $DirectorySearcher.SearchScope = 'Subtree'
                

                $Result = $DirectorySearcher.FindOne()
                }
            catch
            {
                }
            if($Result)
            {
                # Found computer object with $VmName already
                Write-Error "$($VmName) already exists inside the directory, please choose a new name"
                break
                }
            else
            {
                # Computer object not found
                $DirectoryEntry.Close()

                if ($Join -notmatch "LDAP://*")
                {
                    $ADSPath = "LDAP://$($Join)"
                    }

                try
                {
                    $DirectoryEntry = New-Object System.DirectoryServices.DirectoryEntry($ADSPath)
                    $DirectoryEntries = $DirectoryEntry.Children
                    $newVm = $DirectoryEntries.Add("CN=$($VmName)","computer")
                    $newVm.CommitChanges()
                    $newVm.Properties["sAMAccountName"].Value = "$($VmName)`$"
                    $newVm.CommitChanges()
                    $newVm.Properties["Description"].Value = "$($env:USERNAME) created this object on $(Get-Date)"
                    $newVm.CommitChanges()
                    $newVm.Properties["userAccountControl"].Value = 4128
                    $newVm.CommitChanges()
                    }
                catch
                {
                    $Error[0].Exception
                    }
                }
            }
        Set-OSCustomizationSpec -Spec $SpecFile -NamingScheme Fixed -NamingPrefix $VmName
        Get-OSCustomizationSpec $SpecFile |Get-OSCustomizationNicMapping |Set-OSCustomizationNicMapping -IpMode $IpMode -IpAddress $IpAddress -SubnetMask $SubnetMask -DefaultGateway $DefaultGateway -DNS $DnsServer
        New-VM -Name $VmName -VM $CloneVm -OSCustomizationSpec $SpecFile -VMHost (Get-Cluster $Cluster | Get-VMHost | Get-Random -count 1) -Datastore $Datastore -DiskStorageFormat $DiskFormat
        Get-VM -Name $VmName |Get-NetworkAdapter |Set-NetworkAdapter -NetworkName $NetworkName -Confirm:$False
        Get-VM -Name $VmName |Set-VM -MemoryMB $Ram -NumCPU $Cores -Confirm:$false
        Start-Vm -Vm $VmName 
        Get-VM -Name $VmName |Get-NetworkAdapter |Set-NetworkAdapter -Connected $true -Confirm:$false |Out-Null;
        (Get-VM -Name $VmName |Get-NetworkAdapter).ConnectionState
        }
End
    {
        Disconnect-viserver -Server $ViServer -Force -Confirm:$false
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message
        }