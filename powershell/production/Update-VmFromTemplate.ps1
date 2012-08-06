<#
    .SYNOPSIS
        Create a new VM from an imported template
    .DESCRIPTION
        This script will modify a VM on Hyper-V R2 that has been imported from an exported VM.
        The current release of the HyperV module does not support the proper Import method, so 
        I don't implement that bit in this script.
    .PARAMETER TargetVM
        This is the name of the imported VM Template
    .PARAMETER VmName
        This is the name you wish to give your new VM
    .EXAMPLE
        .\Update-VmFromTemplate.ps1 -TargetVM "2008 Core Server" -NewVMName "IIS Web Server"
        
        Description
        -----------
        This is the only syntax for this script.
    .NOTES
        ScriptName: Update-VmFromTemplate.ps1
        Created By: Jeff Patton
        Date Coded: August 3, 2011
        ScriptName is used to register events for this script
        LogName is used to determine which classic log to write to
        
        You will need the HyperV Module from Codeplex
            http://pshyperv.codeplex.com/
    .LINK
        https://code.google.com/p/mod-posh/wiki/Update-VmFromTemplate
    .LINK
        http://technet.microsoft.com/en-us/magazine/ff458346.aspx
    .LINK
        http://pshyperv.codeplex.com/
#>
Param
    (
    [Parameter(Mandatory=$true)]
    [string]$TargetVM,
    [Parameter(Mandatory=$true)]
    [string]$VmName,
    [Parameter(Mandatory=$true)]
    [string]$ExportPath
    )
Begin
    {
        $ScriptName = $MyInvocation.MyCommand.ToString()
        $ScriptPath = $MyInvocation.MyCommand.Path
        $Username = $env:USERDOMAIN + "\" + $env:USERNAME

        New-EventLog -Source $ScriptName -LogName 'Windows Powershell' -ErrorAction SilentlyContinue

        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nStarted: " + (Get-Date).toString()
        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "100" -EntryType "Information" -Message $Message 

        # Dotsource in the functions you need.
        if (Get-Module -Name HyperV)
        {
            }
        else
        {
            Write-Verbose "Importing HyperV Module"
            Import-Module 'C:\Program Files\modules\HyperV\HyperV.psd1'
            }

        if ((Test-Path "$($ExportPath)\$($TargetVM)"))
        {
            Write-Verbose "Read in the config.xml from $($TargetVM)"
            [xml]$Config = Get-Content "$($ExportPath)\$($TargetVM)\config.xml"
            Write-Verbose "Get the vhd location of $($TargetVM)"
            $VMDiskPath = $Config.configuration.vhd.source."#text"
            Write-Verbose "Get the vhd"
            $ExportedDisk = Get-ChildItem "$($ExportPath)\$($TargetVM)\Virtual Hard Disks"
            }
        else
        {
            Write-Host "Exported VM(s)"
            Get-ChildItem $ExportPath |Select-Object -Property Name
            break
            }
        }
Process
    {
        foreach ($NewVMName in $VmName)
        {
            Write-Verbose "Copying disk for $($NewVMName)"
            try
            {
                Write-Verbose "Create diskpath for $($NewVMName)"
                $NewDiskPath = $VMDiskPath.Split("\")          
                $NewDiskPath[$NewDiskPath.Count -1] = "$($NewVMName).vhd"
                $NewDiskPath = [string]::join("\",$NewDiskPath)
                Write-Verbose "Copy disk from $($ExportedDisk.Fullname) to $($NewDiskPath)"
                Copy-Item $ExportedDisk.FullName $NewDiskPath
                }
            catch
            {
                Write-Error $Error[0]
                break
                }

            try
            {
                Write-Verbose "Create VM $($NewVMName)"
                $NewVM = New-VM -Name $NewVMName
                Write-Verbose "Adding CD/DVD-ROM to $($NewVMName)"
                Add-VMDisk -VM $NewVM -ControllerID 0 -LUN 1 -Path C:\VirtualMachines\ISOs\SW_DVD5_Windows_Svr_DC_EE_SE_Web_2008_R2_64Bit_English_w_SP1_MLF_X17-22580.ISO -OpticalDrive
                Write-Verbose "Adding legacy network card to $($NewVMName)"
                Add-VMNIC -VM $NewVM -Legacy
                Write-Verbose "Attach the disk in $($NewDiskPath) to $($NewVMName)"
                $VmDiskReturn = Set-VMDisk -VM $NewVM -Path $NewDiskPath
                Write-Verbose "Add a note to $($NewVMName)"
                Set-VM -VM $NewVM -Name $NewVMName -Notes "Imported $($TargetVM) to $($NewVMName) on $(Get-Date)" |Out-Null
                Write-Verbose "Create the initial snapshot"
                New-VMSnapshot -VM $NewVM -Note "Creating initial snapshot after Import" -Force
                }
            catch
            {
                Write-Error $Error[0]
                break
                }
            }
        }
End
    {
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "100" -EntryType "Information" -Message $Message
        }