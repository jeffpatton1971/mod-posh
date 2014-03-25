<#

    Operating System
    ----------------

    Get of the following items from the operating system

    1. Version
    2. Service Pack Level
    3. Services
        a. Running
        b. Stopped
        c. Logon Account
    4. Processes
        a. Name
        b. Username
        c. Memory
        d. Threads
        e. Image Path Name
        f. Command Line
        g. PID
    5. Installed Features/Roles

    Required
    --------

    This function needs to know the name of the server in order to process
    the xml files or create them.

    Notes
    -----

    By default only some items will be logged, in order to log everything
    set $OverRide = $True. The following items will be logged by default:

#>

$OverRide = $false

# Connect over WinRM to the named server to collect this information
$OS = Get-WmiObject -Class Win32_OperatingSystem |Select-Object -Property Version, ServicePackMajorVersion, ServicePackMinorVersion
$Services = Get-WmiObject -Class Win32_Service |Select-Object -Property DisplayName, State, StartName
$Processes = Get-WmiObject -Class Win32_Process |Select-Object -Property Caption, @{Name='Username';Expression={$_.GetOwner().User}}, VirtualSize, WorkingSetSize, ThreadCount, CommandLine, ExecutablePath, ProcessId
Import-Module ServerManager
$Features = Get-WindowsFeature |Where-Object {$_.Installed -eq $true} |Select-Object -Property Name

# Get the OS information
$DiscoveredOs = $OS

# Get Services information
$DiscoveredServices = $Services

# Get Process information
$DiscoveredProcesses = $Processes

# Get Feature information
$DiscoveredFeatures = $Features

$Message = "`r`nThe following item was changed on $(Get-Date)"

if ((Test-Path .\os.xml))
{
    # File exists load it up
    $PreviousOs = Import-Clixml .\os.xml

    # Compare Previous to Discovered
    $Version = Compare-Object $PreviousOs $DiscoveredOs -Property Version
    $ServicePackMajorVersion = Compare-Object $PreviousOs $DiscoveredOs -Property ServicePackMajorVersion
    $ServicePackMinorVersion = Compare-Object $PreviousOs $DiscoveredOs -Property ServicePackMinorVersion

    # Look to see what changed
    if ($Version)
    {
        # Append change to this server's CHANGELOG
        $Message |Out-File .\changelog -Append
        $Version |Format-List |Out-File .\changelog -Append        
        }
    if ($ServicePackMajorVersion)
    {
        # Append change to this server's CHANGELOG
        $Message |Out-File .\changelog -Append
        $ServicePackMajorVersion |Format-List |Out-File .\changelog -Append
        }
    if ($ServicePackMinorVersion)
    {
        # Append change to this server's CHANGELOG
        $Message |Out-File .\changelog -Append
        $ServicePackMinorVersion |Format-List |Out-File .\changelog -Append
        }

    # Replace existing os.xml file
    $DiscoveredOs |Export-Clixml .\os.xml -Force
    }
else
{
    # File dosn't exist, new server, create it
    $DiscoveredOs |Export-Clixml .\os.xml -Force
    }

if ((Test-Path .\services.xml))
{
    # File exists load it up
    $PreviousServices = Import-Clixml .\services.xml

    # Compare Previous to Discovered
    if ($DiscoveredServices.Count -gt $PreviousServices.Count)
    {
        # New services were added
        foreach ($DiscoveredService in $DiscoveredServices)
        {
            $PreviousService = $PreviousServices |Where-Object {$_.DisplayName -eq $DiscoveredService.DisplayName}
            if ($PreviousService)
            {
                $DisplayName = Compare-Object $PreviousService $DiscoveredService -Property DisplayName
                $State = Compare-Object $PreviousService $DiscoveredService -Property State
                $StartName = Compare-Object $PreviousService $DiscoveredService -Property StartName

                if ($DisplayName -and $OverRide)
                {
                    # Append change to this server's CHANGELOG
                    $Message |Out-File .\changelog -Append
                    $PreviousService.DisplayName |Out-File .\changelog -Append
                    $DisplayName |Format-List |Out-File .\changelog -Append
                    }
                if ($State -and $OverRide)
                {
                    # Append change to this server's CHANGELOG
                    $Message |Out-File .\changelog -Append
                    $PreviousService.DisplayName |Out-File .\changelog -Append
                    $State |Format-List |Out-File .\changelog -Append
                    }
                if ($StartName -and $OverRide)
                {
                    # Append change to this server's CHANGELOG
                    $Message |Out-File .\changelog -Append
                    $PreviousService.DisplayName |Out-File .\changelog -Append
                    $StartName |Format-List |Out-File .\changelog -Append
                    }
                }
            else
            {
                # Append change to this server's CHANGELOG
                $Message |Out-File .\changelog -Append
                "Service Added" |Out-File .\changelog -Append
                $DiscoveredService |Format-List |Out-File .\changelog -Append
                }
            }
        }
    if ($PreviousServices.Count -ge $DiscoveredServices.Count)
    {
        # Services were removed or the count is the same
        foreach ($PreviousService in $PreviousServices)
        {
            $DiscoveredService = $DiscoveredServices |Where-Object {$_.DisplayName -eq $PreviousService.DisplayName}
            if ($DiscoveredService)
            {
                $DisplayName = Compare-Object $PreviousService $DiscoveredService -Property DisplayName
                $State = Compare-Object $PreviousService $DiscoveredService -Property State
                $StartName = Compare-Object $PreviousService $DiscoveredService -Property StartName

                if ($DisplayName -and $OverRide)
                {
                    # Append change to this server's CHANGELOG
                    $Message |Out-File .\changelog -Append
                    $PreviousService.DisplayName |Out-File .\changelog -Append
                    $DisplayName |Format-List |Out-File .\changelog -Append
                    }
                if ($State -and $OverRide)
                {
                    # Append change to this server's CHANGELOG
                    $Message |Out-File .\changelog -Append
                    $PreviousService.DisplayName |Out-File .\changelog -Append
                    $State |Format-List |Out-File .\changelog -Append
                    }
                if ($StartName -and $OverRide)
                {
                    # Append change to this server's CHANGELOG
                    $Message |Out-File .\changelog -Append
                    $PreviousService.DisplayName |Out-File .\changelog -Append
                    $StartName |Format-List |Out-File .\changelog -Append
                    }
                }
            else
            {
                # Append change to this server's CHANGELOG
                $Message |Out-File .\changelog -Append
                "Service Removed" |Out-File .\changelog -Append
                $PreviousService |Format-List |Out-File .\changelog -Append
                }
            }
        }

    # Replace existing os.xml file
    $DiscoveredServices |Export-Clixml .\services.xml -Force
    }
else
{
    # File dosn't exist, new server, create it
    $DiscoveredServices |Export-Clixml .\services.xml -Force
    }

if ((Test-Path .\processes.xml))
{
    # File exists load it up
    $PreviousProcesses = Import-Clixml .\processes.xml

    # Compare Previous to Discovered

    # Look to see what changed

    # Replace existing os.xml file
    $DiscoveredProcesses |Export-Clixml .\processes.xml -Force
    }
else
{
    # File dosn't exist, new server, create it
    $DiscoveredProcesses |Export-Clixml .\processes.xml -Force
    }

if ((Test-Path .\features.xml))
{
    # File exists load it up
    $PreviousFeatures = Import-Clixml .\features.xml

    # Compare Previous to Discovered

    # Look to see what changed

    # Replace existing os.xml file
    $DiscoveredFeatures |Export-Clixml .\features.xml -Force
    }
else
{
    # File dosn't exist, new server, create it
    $DiscoveredFeatures |Export-Clixml .\features.xml -Force
    }