<#
    .SYNOPSIS
        Create a new VM from an imported template
    .DESCRIPTION
        This script will modify a VM on Hyper-V R2 that has been imported from an exported VM.
        The current release of the HyperV module does not support the proper Import method, so 
        I don't implement that bit in this script.
    .PARAMETER TargetVM
        This is the name of the imported VM Template
    .PARAMETER NewVMName
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
        [string]$NewVMName
    )
Begin
    {
        $ScriptName = $MyInvocation.MyCommand.ToString()
        $LogName = "Application"
        $ScriptPath = $MyInvocation.MyCommand.Path
        $Username = $env:USERDOMAIN + "\" + $env:USERNAME

        New-EventLog -Source $ScriptName -LogName $LogName -ErrorAction SilentlyContinue

        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nStarted: " + (Get-Date).toString()
        Write-EventLog -LogName $LogName -Source $ScriptName -EventID "100" -EntryType "Information" -Message $Message 

        #	Dotsource in the functions you need.
        
        if (Get-Module -Name 'HyperV')
        {}
        else
        {
            Write-EventLog -LogName $LogName -Source $ScriptName -EventID "100" -EntryType "Information" -Message "Loading HyperV Module"
            Import-Module 'C:\Program Files\modules\HyperV\HyperV.psd1'
            }
        
        # Set the name of the VM we're working with
        $VirtualMachine = Get-VM |Where-Object {$_.VMElementName -eq $TargetVM}
        Write-EventLog -LogName $LogName -Source $ScriptName -EventID "100" -EntryType "Information" -Message "Get the Working VM, $($VirtualMachine.VMElementName)"
        # Get the disk information for the rename
        $VMDiskPath = Get-VMDisk -VM $VirtualMachine.VMElementName |Where-Object {$_.DriveName -eq "Hard Drive"}
        Write-EventLog -LogName $LogName -Source $ScriptName -EventID "100" -EntryType "Information" -Message "Get the disk to work with, $($VMDiskPath.DiskImage)"
        # Split the path up on slash
        $NewDiskPath = $VMDiskPath.DiskImage.Split("\")
        
        # The last item in the array is the filename, so update it.
        $NewDiskPath[$NewDiskPath.Count -1] = "$($NewVMName).vhd"
        
        # Cat the string back together
        $NewDiskPath = [string]::join("\",$NewDiskPath)
    }
Process
    {
        # Remove any disks that are attached to the newly imported VM
        Get-VMDisk -VM $VirtualMachine.VMElementName | `
            foreach {Remove-VMDrive -Diskonly -VM $_.VMElementName -ControllerID $_.ControllerID -LUN $_.DriveLUN}
        Write-EventLog -LogName $LogName -Source $ScriptName -EventID "100" -EntryType "Information" -Message "Removed all disks"
        # Rename the existing imported disk, to the new VM name
        Rename-Item $VMDiskPath.DiskImage $NewDiskPath
        Write-EventLog -LogName $LogName -Source $ScriptName -EventID "100" -EntryType "Information" -Message "Renamed disk to $($NewDiskPath)"
        # Attach the newly renamed VHD back to the VM
        Set-VMDisk -VM $TargetVM -Path $NewDiskPath
        Write-EventLog -LogName $LogName -Source $ScriptName -EventID "100" -EntryType "Information" -Message "Added new disk to VM"
        # Change the name of the VM to the new name, and add a note about what happened
        Set-VM -VM $TargetVM -Name $NewVMName -Notes "Imported $($TargetVM) to $($NewVMName) on $(Get-Date)"
        Write-EventLog -LogName $LogName -Source $ScriptName -EventID "100" -EntryType "Information" -Message "Changed the VM name to $($NewVMName) and wrote a note"
        # Create an initial snapshot after the import
        New-VMSnapshot -VM $NewVMName -Note "Creating initial snapshot after Import" -Force
        Write-EventLog -LogName $LogName -Source $ScriptName -EventID "100" -EntryType "Information" -Message "Creating initial snapshot after Import"
    }
End
    {
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName $LogName -Source $ScriptName -EventID "100" -EntryType "Information" -Message $Message	
    }
