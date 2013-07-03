<#

    Hardware
    --------

    Get a hardware inventory of the following items

    1. CPU's
        a. Speed
        b. Cores
    2. Ram
        a. Quantity
        b. Capacity
    3. Disks
        a. Size
        b. Used space
        c. Free space

    Required
    --------

    This function needs to know the name of the server in order to process
    the xml files or create them.

    Notes
    -----
    
    By default only some items will be logged, in order to log everything
    set $OverRide = $True. The following items will be logged by default:
        CPU
            NumberOfCores
        Ram
            TotalPhysicalMemory
        Disks
            DeviceId
            Size

#>

$OverRide = $False

# Connect over WinRM to the named server to collect this information
$ComputerSystem = Get-WmiObject -Class Win32_ComputerSystem
$Processor = Get-WmiObject -Class Win32_Processor
$Disks = Get-WmiObject -Class Win32_LogicalDisk |Select-Object -Property DeviceId, FreeSpace, Size, @{Name='UsedSpace';Expression={$_.Size - $_.FreeSpace}}

# Get CPU information
if ($Processor.Count -eq $null)
{
    if ($Processor.NumberOfCores -ne $null)
    {
        $Cores = $Processor.NumberOfCores
        $ClockSpeed = $Processor.CurrentClockSpeed
        }
    }
else
{
    foreach ($Core in $Processor)
    {
        if ($Core.NumberOfCores -ne $null)
        {
            $Cores += $Core.NumberOfCores
            }
        $ClockSpeed += $Core.CurrentClockSpeed
        }
    }
$DiscoveredCPU = New-Object -TypeName PSobject -Property @{
    NumberOfCores = $Cores
    CurrentClockSpeed = $ClockSpeed
    }

# Get Ram information
$DiscoveredRam = New-Object -TypeName PSobject -Property @{
    TotalPhysicalMemory = $ComputerSystem.TotalPhysicalMemory
    }

# Get Disk information
$DiscoveredDisks = $Disks

$Message = "`r`nThe following item was changed on $(Get-Date)"

if ((Test-Path .\cpu.xml))
{
    # File exists, load it up
    $PreviousCPU = Import-Clixml .\cpu.xml

    # Compare Previous to Discovered
    $NumberOfCores = Compare-Object $PreviousCPU $DiscoveredCPU -Property NumberOfCores
    $CurrentClockSpeed = Compare-Object $PreviousCPU $DiscoveredCPU -Property CurrentClockSpeed

    # Look to see what changed
    if ($NumberOfCores)
    {
        # Append change to this server's CHANGELOG
        $Message |Out-File .\changelog -Append
        $NumberOfCores |Format-List |Out-File .\changelog -Append
        }
    if ($CurrentClockSpeed)
    {
        if ($OverRide)
        {
            # Append change to this server's CHANGELOG
            $Message |Out-File .\changelog -Append
            $CurrentClockSpeed |Format-List |Out-File .\changelog -Append
            }
        }
    
    # Replace existing cpu.xml file
    $DiscoveredCPU |Export-Clixml .\cpu.xml -Force
    }
else
{
    # File doesn't exist, new server, create it
    $DiscoveredCPU |Export-Clixml .\cpu.xml -Force
    }
if ((Test-Path .\ram.xml))
{
    # File exists, load it up
    $PreviousRam = Import-Clixml .\ram.xml

    # Compare Previous to Discovered
    $TotalPhysicalMemory = Compare-Object $PreviousRam $DiscoveredRam -Property TotalPhysicalMemory

    # Look to see what changed
    if ($TotalPhysicalMemory)
    {        
        # Append change to this server's CHANGELOG
        $Message |Out-File .\changelog -Append
        $TotalPhysicalMemory |Format-List |Out-File .\changelog -Append
        }

    # Replace existing ram.xml file
    $DiscoveredRam |Export-Clixml .\ram.xml -Force
    }
else
{
    # File doesn't exist, new server, create it
    $DiscoveredRam |Export-Clixml .\ram.xml -Force
    }
if ((Test-Path .\disks.xml))
{
    # File exists, load it up
    $PreviousDisks = Import-Clixml .\disks.xml

    # Need to account for an added disk
    if ($PreviousDisks.Count -eq $null)
    {
        $Previous = 0
        }
    else
    {
        $Previous = $PreviousDisks.Count
        }
    if ($DiscoveredDisks.Count -eq $null)
    {
        $Discovered = 0
        }
    else
    {
        $Discovered = $DiscoveredDisks.Count
        }
    if ($Previous -ne $Discovered)
    {
        # Append change to this server's CHANGELOG
        $Message |Out-File .\changelog -Append
        if ($Previous -gt $Discovered)
        {
            "Disk Removed" |Out-File .\changelog -Append
            }
        if ($Previous -lt $Discovered)
        {
            "Disk Added" |Out-File .\changelog -Append
            }
        }

    # Compare Previous to Discovered
    $DeviceId = Compare-Object $PreviousDisks $DiscoveredDisks -Property DeviceId
    $FreeSpace = Compare-Object $PreviousDisks $DiscoveredDisks -Property FreeSpace
    $Size = Compare-Object $PreviousDisks $DiscoveredDisks -Property Size
    $UsedSpace = Compare-Object $PreviousDisks $DiscoveredDisks -Property UsedSpace

    if ($DeviceId)
    {
        # Append change to this server's CHANGELOG
        $Message |Out-File .\changelog -Append
        $DeviceId |Format-List |Out-File .\changelog -Append
        }
    if ($FreeSpace)
    {
        if ($OverRide)
        {
            # Append change to this server's CHANGELOG
            $Message |Out-File .\changelog -Append
            $FreeSpace |Format-List |Out-File .\changelog -Append
            }
        }
    if ($Size)
    {
        # Append change to this server's CHANGELOG
        $Message |Out-File .\changelog -Append
        $Size |Format-List |Out-File .\changelog -Append
        }
    if ($UsedSpace)
    {
        if ($OverRide)
        {
            # Append change to this server's CHANGELOG
            $Message |Out-File .\changelog -Append
            $UsedSpace |Format-List |Out-File .\changelog -Append
            }
        }
    # Replace existing disks.xml file
    $DiscoveredDisks |Export-Clixml .\disks.xml -Force
    }
else
{
    # File doesn't exist, new server, create it
    $DiscoveredDisks |Export-Clixml .\disks.xml -Force
    }