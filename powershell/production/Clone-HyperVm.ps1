<#
.SYNOPSIS
    Template script
.DESCRIPTION
    This script sets up the basic framework that I use for all my scripts.
.PARAMETER
.EXAMPLE
.NOTES
    ScriptName : Clone-HyperVm
    Created By : Jeffrey
    Date Coded : 02/05/2015 15:40:51
    ScriptName is used to register events for this script
 
    ErrorCodes
        100 = Success
        101 = Error
        102 = Warning
        104 = Information
.LINK
    https://github.com/jeffpatton1971/mod-posh/wiki/Production/Clone-HyperVm
#>
[CmdletBinding()]
Param
(
    $ComputerName = ".",
    $VmName,
    $Size
)
Begin
{
    try
    {
        Import-Module Hyper-V
        switch ($Size.ToLower())
        {
            "a0"
            {
                $Mem = 768MB
                $CpuCount = 1        
                }
            "a1"
            {
                $Mem = 1.75GB
                $CpuCount = 1        
                }
            "a2"
            {
                $Mem = 3.5GB
                $CpuCount = 2        
                }
            "a3"
            {
                $Mem = 7GB
                $CpuCount = 4        
                }
            "a4"
            {
                $Mem = 14GB
                $CpuCount = 8       
                }
            default
            {
                $Mem = 768MB
                $CpuCount = 1
                }
            }
        
        }
    catch
    {
        $Error[0]
        break
        }
    }
Process
{
    try
    {
        $VmHost = Get-VMHost -ComputerName $ComputerName
        if ($ComputerName -ne ".")
        {
            $TemplateVhd = "\\$($VmHost.VirtualHardDiskPath.Replace(":","$"))\Template.vhdx"
            $destPath = "\\$($VmHost.VirtualHardDiskPath.Replace(":","$"))\$($VmName).vhdx"
            }
        else
        {
            $TemplateVhd = "$($VmHost.VirtualHardDiskPath)\Template.vhdx"
            $destPath = "$($VmHost.VirtualHardDiskPath)\$($VmName).vhdx"
            }
        Write-Host "Creating VM : $($VmName)"
        New-Vm -Name $VmName -MemoryStartupBytes $Mem -SwitchName (Get-VmSwitch).Name -Generation 2 -NoVHD -ComputerName $ComputerName
        Set-VMProcessor -VmName $VmName -Count $CpuCount
        Write-Host "Copying Template Disk"
        Copy-Item $TemplateVhd $destPath
        Write-Host "Adding Template Disk"
        Add-VMHardDiskDrive -VmName $VmName -Path $destPath -ControllerType SCSI
        Write-Host "Configuring to boot from disk"
        Set-VMFirmware -VMName $VmName -FirstBootDevice (Get-VMHardDiskDrive -VMName $VmName)
        }
    catch
    {
        $Error[0]
        break
        }
    }
End
{
    }