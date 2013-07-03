if ($DiscoveredProcesses.Count -gt $PreviousProcesses.Count)
{
    # New services were added
    foreach ($DiscoveredProcess in $DiscoveredProcesses)
    {
        $PreviousProcess = $PreviousProcesses |Where-Object {$_.DisplayName -eq $DiscoveredProcess.DisplayName}
        if ($PreviousProcess)
        {
            $Caption = Compare-Object $PreviousProcess $DiscoveredProcess -Property Caption
            $Username = Compare-Object $PreviousProcess $DiscoveredProcess -Property Username
            $VirtualSize = Compare-Object $PreviousProcess $DiscoveredProcess -Property VirtualSize
            $WorkingSetSize = Compare-Object $PreviousProcess $DiscoveredProcess -Property WorkingSetSize
            $ThreadCount = Compare-Object $PreviousProcess $DiscoveredProcess -Property ThreadCount
            $CommandLine = Compare-Object $PreviousProcess $DiscoveredProcess -Property CommandLine
            $ExecutablePath = Compare-Object $PreviousProcess $DiscoveredProcess -Property ExecutablePath
            $ProcessId = Compare-Object $PreviousProcess $DiscoveredProcess -Property ProcessId

            if ($Caption -and $OverRide)
            {
                # Append change to this server's CHANGELOG
                $Message |Out-File .\changelog -Append
                $PreviousProcess.Caption |Out-File .\changelog -Append
                $Caption |Format-List |Out-File .\changelog -Append
                }
            if ($Username -and $OverRide)
            {
                # Append change to this server's CHANGELOG
                $Message |Out-File .\changelog -Append
                $PreviousProcess.Caption |Out-File .\changelog -Append
                $Username |Format-List |Out-File .\changelog -Append
                }
            if ($VirtualSize -and $OverRide)
            {
                # Append change to this server's CHANGELOG
                $Message |Out-File .\changelog -Append
                $PreviousProcess.Caption |Out-File .\changelog -Append
                $VirtualSize |Format-List |Out-File .\changelog -Append
                }
            if ($WorkingSetSize -and $OverRide)
            {
                # Append change to this server's CHANGELOG
                $Message |Out-File .\changelog -Append
                $PreviousProcess.Caption |Out-File .\changelog -Append
                $WorkingSetSize |Format-List |Out-File .\changelog -Append
                }
            if ($ThreadCount -and $OverRide)
            {
                # Append change to this server's CHANGELOG
                $Message |Out-File .\changelog -Append
                $PreviousProcess.Caption |Out-File .\changelog -Append
                $ThreadCount |Format-List |Out-File .\changelog -Append
                }
            if ($CommandLine -and $OverRide)
            {
                # Append change to this server's CHANGELOG
                $Message |Out-File .\changelog -Append
                $PreviousProcess.Caption |Out-File .\changelog -Append
                $CommandLine |Format-List |Out-File .\changelog -Append
                }
            if ($ExecutablePath -and $OverRide)
            {
                # Append change to this server's CHANGELOG
                $Message |Out-File .\changelog -Append
                $PreviousProcess.Caption |Out-File .\changelog -Append
                $ExecutablePath |Format-List |Out-File .\changelog -Append
                }
            if ($ProcessId -and $OverRide)
            {
                # Append change to this server's CHANGELOG
                $Message |Out-File .\changelog -Append
                $PreviousProcess.Caption |Out-File .\changelog -Append
                $ProcessId |Format-List |Out-File .\changelog -Append
                }
            }
        else
        {
            # Append change to this server's CHANGELOG
            $Message |Out-File .\changelog -Append
            "New Process" |Out-File .\changelog -Append
            $DiscoveredProcess |Format-List |Out-File .\changelog -Append
            }
        }
    }
if ($PreviousProcesses.Count -ge $DiscoveredProcesses.Count)
{
    # Services were removed or the count is the same
    foreach ($PreviousProcess in $PreviousProcesses)
    {
        $DiscoveredProcess = $DiscoveredProcesses |Where-Object {$_.DisplayName -eq $PreviousProcess.DisplayName}
        if ($DiscoveredProcess)
        {
            $Caption = Compare-Object $PreviousProcess $DiscoveredProcess -Property Caption
            $Username = Compare-Object $PreviousProcess $DiscoveredProcess -Property Username
            $VirtualSize = Compare-Object $PreviousProcess $DiscoveredProcess -Property VirtualSize
            $WorkingSetSize = Compare-Object $PreviousProcess $DiscoveredProcess -Property WorkingSetSize
            $ThreadCount = Compare-Object $PreviousProcess $DiscoveredProcess -Property ThreadCount
            $CommandLine = Compare-Object $PreviousProcess $DiscoveredProcess -Property CommandLine
            $ExecutablePath = Compare-Object $PreviousProcess $DiscoveredProcess -Property ExecutablePath
            $ProcessId = Compare-Object $PreviousProcess $DiscoveredProcess -Property ProcessId

            if ($Caption -and $OverRide)
            {
                # Append change to this server's CHANGELOG
                $Message |Out-File .\changelog -Append
                $PreviousProcess.Caption |Out-File .\changelog -Append
                $Caption |Format-List |Out-File .\changelog -Append
                }
            if ($Username -and $OverRide)
            {
                # Append change to this server's CHANGELOG
                $Message |Out-File .\changelog -Append
                $PreviousProcess.Caption |Out-File .\changelog -Append
                $Username |Format-List |Out-File .\changelog -Append
                }
            if ($VirtualSize -and $OverRide)
            {
                # Append change to this server's CHANGELOG
                $Message |Out-File .\changelog -Append
                $PreviousProcess.Caption |Out-File .\changelog -Append
                $VirtualSize |Format-List |Out-File .\changelog -Append
                }
            if ($WorkingSetSize -and $OverRide)
            {
                # Append change to this server's CHANGELOG
                $Message |Out-File .\changelog -Append
                $PreviousProcess.Caption |Out-File .\changelog -Append
                $WorkingSetSize |Format-List |Out-File .\changelog -Append
                }
            if ($ThreadCount -and $OverRide)
            {
                # Append change to this server's CHANGELOG
                $Message |Out-File .\changelog -Append
                $PreviousProcess.Caption |Out-File .\changelog -Append
                $ThreadCount |Format-List |Out-File .\changelog -Append
                }
            if ($CommandLine -and $OverRide)
            {
                # Append change to this server's CHANGELOG
                $Message |Out-File .\changelog -Append
                $PreviousProcess.Caption |Out-File .\changelog -Append
                $CommandLine |Format-List |Out-File .\changelog -Append
                }
            if ($ExecutablePath -and $OverRide)
            {
                # Append change to this server's CHANGELOG
                $Message |Out-File .\changelog -Append
                $PreviousProcess.Caption |Out-File .\changelog -Append
                $ExecutablePath |Format-List |Out-File .\changelog -Append
                }
            if ($ProcessId -and $OverRide)
            {
                # Append change to this server's CHANGELOG
                $Message |Out-File .\changelog -Append
                $PreviousProcess.Caption |Out-File .\changelog -Append
                $ProcessId |Format-List |Out-File .\changelog -Append
                }
            }
        else
        {
            # Append change to this server's CHANGELOG
            $Message |Out-File .\changelog -Append
            "Missing Process" |Out-File .\changelog -Append
            $PreviousProcess |Format-List |Out-File .\changelog -Append
            }
        }
    }