$ComputerName = "\`d.T.~Ed/{032A3EBD-4EBC-48A0-937E-F857C451A0B8}.{7157DCED-42FB-442C-BD4F-6C38EDFADEB6}\`d.T.~Ed/"
$Username = "\`d.T.~Ed/{032A3EBD-4EBC-48A0-937E-F857C451A0B8}.{4A20B188-9557-43F8-8289-A11D2971842A}\`d.T.~Ed/"
$Password = ConvertTo-SecureString -String "\`d.T.~Ed/{032A3EBD-4EBC-48A0-937E-F857C451A0B8}.{F4893892-5E22-4F91-BA14-2AA99E1A0DCD}\`d.T.~Ed/" -AsPlainText -Force
$Criteria = "\`d.T.~Ed/{032A3EBD-4EBC-48A0-937E-F857C451A0B8}.{C26AB833-054F-4C1E-A0D8-97CC61E88344}\`d.T.~Ed/"
$FromMicrosoft = "\`d.T.~Ed/{032A3EBD-4EBC-48A0-937E-F857C451A0B8}.{7B0B3F36-C9C6-486C-9F43-596B20F70AF9}\`d.T.~Ed/"
<#
    .SYNOPSIS
        Apply updates to a server
    .DESCRIPTION
        This script will check windows updates for any updates that are applicable
        to the server. If updates are found it will accept a eula, download the update
        and then install the update.
        
        If an update requires a reboot a flag will be set, and once all udpates have been
        downloaded and installed the server will reboot.

        If no criteria is specified the default is to pull security and critical updates
        that are not already installed.
    .NOTES
        This script relies on a pair of modules that I wrote. 
        
        WindowsUpdateLibrary provides cmdlets for working with the windows update agent
        on the local computer.

        LogFiles provides cmdlets for working with and creating text based log files in 
        a similar fashion as the windows event log cmdlets.
#>
$Credential = New-Object System.Management.Automation.PSCredential ($Username, $Password)
$Session = New-PSSession -ComputerName $ComputerName -Credential $Credential  -Authentication Credssp
Invoke-Command -Session $Session -ArgumentList $Criteria, $FromMicrosoft -ScriptBlock {
    Param
    (
    $Criteria = "(IsInstalled=0 AND CategoryIDs contains 'E6CF1350-C01B-414D-A61F-263D14D133B4') OR (IsInstalled=0 AND CategoryIDs contains '0FA1201D-4330-4FA8-8AE9-B877473B6441')",
    $FromMicrosoft
    )
    try
    {
        $ErrorActionPreference = "Stop"
        $Error.Clear()
        Import-Module C:\scripts\WindowsUpdateLibrary.psm1
        Import-Module C:\scripts\LogFiles.psm1
        $Reboot = $false
        Write-LogFile -LogName "WindowsUpdates" -Source "Logic" -EventID 0 -EntryType Information -Message "Starting Updates $(Get-Date)"
        Write-LogFile -LogName "WindowsUpdates" -Source "GetWindowsUpdate" -EventID 1 -EntryType Information -Message "Connecting to update server to retrieve updates"
        if ($FromMicrosoft)
        {
            $Updates = Get-WindowsUpdate -Criteria $Criteria -FromMicrosoft
            }
        else
        {
            $Updates = Get-WindowsUpdate -Criteria $Criteria
            }
        if ($Updates)
        {
            Write-LogFile -LogName "WindowsUpdates" -Source "GetWindowsUpdate" -EventID 1 -EntryType Information -Message "$($Updates.Count) updates available"
            foreach ($Update in $Updates)
            {
                Accept-WindowsUpdateEULA -Update $Update -AcceptEULA $true
                Start-WindowsUpdateDownload -Update $Update
                Write-LogFile -LogName "WindowsUpdates" -Source "UpdateDownload" -EventID 2 -EntryType Information -Message "Downloading update $($Update.Title)"
                $Result = Install-WindowsUpdate -Update $Update
                Write-LogFile -LogName "WindowsUpdates" -Source "UpdateInstall" -EventID 3 -EntryType Information -Message "Installing update $($Update.Title)"
                if ($Result)
                {
                    Write-LogFile -LogName "WindowsUpdates" -Source "Restart" -EventID 3 -EntryType Information -Message "Update requires restart"
                    $Reboot = $true
                    }
                }
            }
        else
        {
            Write-LogFile -LogName "WindowsUpdates" -Source "GetWindowsUpdate" -EventID 1 -EntryType Information -Message "No updates found"
            }
        Write-LogFile -LogName "WindowsUpdates" -Source "Logic" -EventID 0 -EntryType Information -Message "Ending Updates $(Get-Date)"
        if ($Reboot)
        {
            Write-LogFile -LogName "WindowsUpdates" -Source "Logic" -EventID 0 -EntryType Information -Message "Rebooting"
            Restart-Computer -Force
            }
        }
    catch
    {
        $err = $Error[0]
        $inv = $err.InvocationInfo
        Write-LogFile -LogName "WindowsUpdates" -Source $err.FullyQualifiedErrorId -EventID 4 -EntryType Error -Message $inv.Line
        Write-LogFile -LogName "WindowsUpdates" -Source $err.FullyQualifiedErrorId -EventID 4 -EntryType Error -Message $err.Exception.Message
        }
    }
Remove-PSSession -Session $Session