$HyperVServer = "it08082"
$Vmname = "my-sample-vm1"
$VhdName = "$($Vmname)-disk.vhd"
[uint64]$VhdSize = 10
[UInt64]$Size1G = 0x40000000

$Vmpath = Get-WmiObject -Namespace 'root/virtualization' -Query "SELECT DefaultVirtualHardDiskPath FROM Msvm_VirtualSystemManagementServiceSettingData"
$VmSwitch = Get-WmiObject -Namespace 'root/virtualization' -Query "SELECT ElementName FROM Msvm_VirtualSwitch"
$VmService = Get-WmiObject -Namespace 'root/virtualization' -Query "SELECT * FROM Msvm_VirtualSystemManagementService"
$ImageManagementService = Get-WmiObject -Namespace 'root\virtualization' -Class Msvm_ImageManagementService

$GlobalSettingsData = ([WMIClass]"\\.\Root\Virtualization:MSVM_VirtualSystemGlobalSettingData").CreateInstance()
$GlobalSettingsData.ElementName = $Vmname
$GlobalSettingsData.ExternalDataRoot = $Vmpath

$VmResult = $VmService.DefineVirtualSystem($GlobalSettingsData.GetText([System.Management.TextFormat]::WmiDtd20), $null, $null)

$DiskResult = $ImageManagementService.CreateDynamicVirtualHardDisk("$($Vmpath.DefaultVirtualHardDiskPath)\$($VhdName)",$VhdSize * $Size1G)

$NewVm = Get-WmiObject -Namespace 'root\virtualization' -Query "SELECT * FROM Msvm_ComputerSystem WHERE ElementName='$Vmname'"