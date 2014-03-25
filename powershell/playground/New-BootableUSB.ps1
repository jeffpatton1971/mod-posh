#Requires -Version 3.0

Function New-BootableUSB
{
<#
.SYNOPSIS
	This fucntion will create a bootable USB drive from a ISO file.

.DESCRIPTION
	This function will create a bootable USB drive from a ISO containing the install bits from a Microsoft operating system.

.PARAMETER  ImagePath
	Specifies path to the ISO file.

.PARAMETER USBDriveLetter
    Specifies the drive letter of the USB drive that is to be made bootable to install an operating system.

.EXAMPLE

    PS C:\Windows\System32\WindowsPowerShell\v1.0> New-BootableUSB -ImagePath D:\ISOs\en_windows_7_enterprise_with_sp1_x64_dvd_u_677651.iso -USBDriveLetter E
   
   Confirm
Are you sure you want to perform this action?
Performing operation "Formating volume" on Target "Drive F. All data will be lost".
[Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"): y


   Disk Number: 2

PartitionNumber  DriveLetter Offset                                                                       Size Type
---------------  ----------- ------                                                                       ---- ----
1                F           1048576                                                                   7.46 GB Logical



DriveLetter DriveType FileSystem HealthStatus
----------- --------- ---------- ------------
          F Removable NTFS       Healthy



Target volumes will be updated with BOOTMGR compatible bootcode.

F: (\\?\Volume{1d05c01a-1246-11e2-be7f-b61c1382e5a2})

    Successfully updated NTFS filesystem bootcode.

Bootcode was successfully updated on all targeted volumes.
Bootable USB creation complete! 

   Description
   -----------
   This command installs the Windows 7 installation bits on USB drive F: and makes the drive bootable.

.NOTES
    Author:Jason Walker
    Last modified: 10/19/2012
#>
    
    [CmdletBinding(
                SupportsShouldProcess=$true,
                ConfirmImpact="High"
            )]

    Param(
    [Parameter(Mandatory=$True)]
    [ValidateScript({Test-Path $_ -Include *.iso })] 
    [string]$ImagePath,

    [Parameter(Mandatory=$True)]
    [ValidateLength(1,2)]
    [String]$USBDriveLetter
    )

    Begin
    {
        $ProgressCounter = 0
        $USBDriveLetter  = $USBDriveLetter.ToUpper()
    
        #Test for elevated credentials
        If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
        {
            Write-Warning "This script requires elevated.  Launch PowerShell as administrator and run script again.  Thanks!"
            Break
        }

        #Check for storage module availablity
        If(-not(Get-Module -Name Storage -ListAvailable))
        {
            Write-Warning "This script requires PowerShell version 3.0 and the Storage module. Storage module not found."
            Break
        }
    
        #Validate USBDrive is a removable drive
        If($USBDriveLetter.Length -eq 2)
        {
           $USBDriveLetter = $USBDriveLetter.Substring(0,1)
        }

        If((Get-Volume | Where DriveType -eq Removable | Select -ExpandProperty DriveLetter) -notcontains $USBDriveLetter)
        {
            "$USBDriveLetter is not a removable drive"
            Break
        }                     

    }#end begin

    Process
    {           
        #Format partition and mount image
        If($PSCmdlet.ShouldProcess("Drive $USBDriveLetter. All data will be lost","Formating volume"))
        {
            Try
            {
                $Disks = Get-Disk | Where-Object BusType -eq USB
                $USBDiskNumber = $Disks | Get-Partition | Where-Object DriveLetter -eq $USBDriveLetter | Select -ExpandProperty DiskNumber
                
                
                If(!$USBDiskNumber)
                {
                    Write-Verbose "No partitions detected.  USBDiskNumber will be the disk without a partition"
                    $USBDiskNumber = $Disks | Where NumberOfPartitions -eq 0 | Select -ExpandProperty Number
                    
                }
                Else
                {
                    Write-Verbose "Cleaning disk" 
                    Clear-Disk -Number $USBDiskNumber -RemoveData -Confirm:$false                                                                                   
                }

                Write-Verbose "Creating partition"
                New-Partition -DiskNumber $USBDiskNumber -UseMaximumSize -IsActive

                #Validate USBDrive has enough disk space
                $USBDiskSize = $Disks | Where-Object Number -eq $USBDiskNumber | Select -ExpandProperty Size
                $ImageSize = (Get-ChildItem $ImagePath).Length

                If($ImageSize -gt $USBDiskSize)
                {
                    Write-Warning "There is not enough free space on drive $USBDriveLetter.  A USB drive with a $(($ImageSize/1GB).ToString("0.00 GB")) capacity is needed."
                    Break
                }

                Write-Verbose "Formating drive $USBDriveLetter"
                Format-Volume -DriveLetter $USBDriveLetter -FileSystem NTFS -Confirm:$false -ErrorAction Stop | 
                    Format-Table -Property DriveLetter,DriveType,FileSystem,HealthStatus -AutoSize

            }#end try
            Catch
            {
                Write-Warning $_
                Break
            }
        
        }
        Else
        {        
            Write-Warning "Action canceled"
            Break
        }
    
    
        #Mount ISO
        #Check to see if ISO already mounted
        If(-not(Get-DiskImage -ImagePath $ImagePath | Get-Volume))
        {
            $DiskMounted = $true
            Write-Verbose "DiskMounted equals $DiskMounted"

            Try
            {  
               Write-Verbose "Mounting ISO"          
               Mount-DiskImage -ImagePath $ImagePath -ErrorAction Stop
            }
            Catch
            {
                Write-Warning $_
                Break
               
            }#end catch

        }#end if
        Else
        {
            Write-Verbose "ISO already mounted"
        }
       
        #Get drive letter of newly mounted drive
        $ISODrive = ((Get-DiskImage -ImagePath $ImagePath | Get-Volume).DriveLetter) + ":"
        $USBDestination = $USBDriveLetter + ":"

        #Build command to apply MBR to USB
        $CMD = "$ISODrive" + "\boot\bootsect.exe /NT60 $USBDriveLetter" + ":"

        #Apply MBR
        Write-Host #format display
        Invoke-Expression $CMD
        
        #Create directories to flash drive
        Write-Verbose "Creating directories on boot device"

        $Directories  = Get-ChildItem $ISODrive -Recurse -Directory
        $InstallItems = Get-ChildItem $ISODrive -Recurse -File 

        Foreach($Dir in $Directories)
        {    
            New-Item -ItemType directory -Path ($USBDestination + ($Dir.Fullname.Substring(2))) | Out-Null
        }

        Write-Verbose "$($Directories.count) directories created"

        #Copy files to flash drive
       
        Write-Verbose "Copying files to USB device"
        
        Foreach($Item in $InstallItems)
        {
            $ProgressCounter++

            #Format file size        
            Switch($Item.Length){
                {$_ -lt 1MB}{$ItemSize = ($_/1KB).ToString("0.00 KB");Break}
                {$_ -lt 1GB}{$ItemSize = ($_/1MB).ToString("0.00 MB");Break}
                {$_ -lt 1TB}{$ItemSize = ($_/1GB).ToString("0.00 GB");Break}
                    }#end switch
    
            Write-Progress -Activity "Copying install bits to flash drive" `
            -Status "Copying File: $($Item.FullName) Size: $ItemSize" `
            -PercentComplete (($ProgressCounter/$InstallItems.Count) * 100)
            
            Copy-Item $Item.FullName -Destination ($USBDestination + $Item.DirectoryName.Substring(2)) 
            
            

        }#end foreach InstallItems

    }#end process
    End
    {
        If($DiskMounted)
        {
            Write-Verbose "Dismounting image"
            Dismount-DiskImage -ImagePath $ImagePath
        }
        Write-Host "Bootable USB creation complete!"

    }#end
} 