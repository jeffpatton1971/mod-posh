<#
    .SYNOPSIS
        Create iSCSI drive maps on one or more servers
    .DESCRIPTION
        Making life easier by creating the iSCSI drive mappings via Powershell. 
        However, the Microsoft Initiator isn't natively powershell enabled, the calls
        must be made through the command line interface of iscsicli.exe.
        This script addresses the pain involved in dealing with larger numbers of servers, 
        in our data center this includes numerous Hyper-V Clusters with 
        Clustered Shared Volumes where we'd have quite a lot of UI clicking to do.
    .PARAMETER FileName
        The comma seperated file is easily managed with native powershell cmdlets.
        The file header includes: 
        
        Hostname,Cluster,IP,InitiatorIQN,iSCSI_Portal,iSCSI_Target
        
        Hostname     : Server Hostname, ie: "command prompt 'hostname'"
        IP           : Preferred source IP for the initiator
        InitiatorIQN : Not required for the scripts, but useful as a reference
        iSCSI_Portal : IP of the target portal
        iSCSI_Target : Full IQN of the target volume
    .PARAMETER ServerName
        If specified the server to target this script at, otherwise use the CSV.
    .PARAMETER Favorites
        True or False, Add the Target to the Favorites list
    .PARAMETER LoginTarget
        True or False, Login to the target for this session
    .EXAMPLE
        .\New-IscsiDriveMaps.ps1 -FileName 'C:\Temp\IscsiMaps.csv'
        
        Description
        -----------
        This is an example of the basic usage of this command.
    .EXAMPLE
        .\New-IscsiDriveMaps.ps1 -FileName 'C:\Temp\IscsiMaps.csv' -ServerName 'Server-01'
        
        Description
        -----------
        This example shows the basic usage, passing in one server to work on.
    .NOTES
        This script was originally written by Dynamic IT, and the source URL is the second link.
        I really liked the script and felt that the original could use a little more PowerShell
        loving, so I took nearly all the original code and as best as I could took in the 
        original intent.
        
        I noted that it appeared that they used a couple of values, Favorites and LoginTargets 
        as more or less switches. I set those as a parameter and defaulted to true, so that
        code runs by default.
        
        The VolumeMaps code was more or less the same, I left the ServerName parameter blank
        and if it's present we then filter the CSV by the ServerName. This also took out the 
        need to check if only 1 arg was passed.
        
        ScriptName : New-IscsiDriveMaps.ps1
        Created By : jspatton
        Date Coded : 11/21/2011 15:52:18
        ScriptName is used to register events for this script
        LogName is used to determine which classic log to write to
 
        ErrorCodes
            100 = Success
            101 = Error
            102 = Warning
            104 = Information
        
        Making life easier by creating the iSCSI drive mappings via Powershell. 
        However, the Microsoft Initiator isn't natively powershell enabled, the calls
        must be made through the command line interface of iscsicli.exe.
        This script addresses the pain involved in dealing with larger numbers of servers, 
        in our data center this includes numerous Hyper-V Clusters with 
        Clustered Shared Volumes where we'd have quite a lot of UI clicking to do.
        Import CSV for the list of Hostnames, Portals and Targets (volumes)
        The comma seperated file is easily managed with native powershell cmdlets.
    .LINK
        https://code.google.com/p/mod-posh/wiki/New-IscsiDriveMaps.ps1
    .LINK
        http://blogs.technet.com/b/mpsc_dynamic_it/archive/2010/01/30/using-powershell-remoting-iscsicli-exe-to-connect-your-clustered-shared-volumes.aspx
    .LINK
        http://www.microsoft.com/download/en/details.aspx?id=6408
#>
#requires -version 2
[cmdletbinding()]
Param
    (
        [Parameter(Mandatory=$true)]
        $FileName,
        [Parameter(Mandatory=$false)]
        $ServerName,
        [Parameter(Mandatory=$true)]
        $Favorites = $true,
        [Parameter(Mandatory=$true)]
        $LoginTarget = $true
    )
Begin
    {
        $ScriptName = $MyInvocation.MyCommand.ToString()
        $LogName = "Application"
        $ScriptPath = $MyInvocation.MyCommand.Path
        $Username = $env:USERDOMAIN + "\" + $env:USERNAME
 
        New-EventLog -Source $ScriptName -LogName $LogName -ErrorAction SilentlyContinue
 
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nStarted: " + (Get-Date).toString()
        Write-EventLog -LogName $LogName -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message
 
        #	Dotsource in the functions you need.
        if ($ServerName)
        {
            Write-Verbose "in this case we only need to execute commands for that specfic server rather than the entire Data Center"
            $VolumeMaps = Import-Csv -Path $FileName |Where-Object {$_.Hostname -ilike $ServerName}
            }
        else
        {
            $VolumeMaps = Import-Csv -Path $FileName
            }
        
        Write-Verbose "Constants - if using standard target ports, the Microsoft iSCSI Initiator and leveraging MPIO"
        $iSCSI_Port = "3260"
        $iSCSI_Initiator = "Root\ISCSIPRT\0000_0"
        $iSCSI_MPIO = "0x00000002"
        
        Write-Verbose "Output a report that shows all work completed."
        $MappedVolumes = @()
        }
Process
    {
        foreach ($MapItem in $VolumeMaps)
        {
            Write-Verbose "Setting Dynamic Variables"
            $iSCSI_Portal = $MapItem.iSCSI_Portal
            $iSCSI_Target = $MapItem.iSCSI_Target
            $ServerName = $MapItem.HostName
            
            Write-Verbose "Get the iSCSI Port Number for the specified IP address"
            Write-Verbose "We first convert the needed iSCSI source address to the IPv4 format within WMI"
            $IPAddress = [system.Net.IPAddress]$MapItem.IP
            
            Write-Verbose "Then Via WMI we query into the MSiSCSI_PortalInfoClass to find the correct Interface Index Number"
            $PortalList = Get-WmiObject -ComputerName $ServerName -Namespace root\wmi -Query "SELECT PortalInformation FROM MSiSCSI_PortalInfoClass"
            
            Write-Verbose "this index number will be used for several iscsicli.exe invoke-expression calls"
            $iSCSIPortID = ($PortalList.PortalInformation | Where-Object {$_.IpAddr.IPV4Address -match $IPAddress.Address} | Select-Object -Property port)
            
            Write-Verbose "Always refresh the target portal list and the currently connected target volumes"
            $Command = [scriptblock]::Create("iscsicli.exe refreshtargetportal $iSCSI_Portal $iSCSIPort")
            Invoke-Command -ComputerName $ServerName -ScriptBlock $Command
            Start-Sleep 2
            
            Write-Verbose "Verify info"
            $LineItem = New-Object -TypeName PSobject -Property @{
                ServerName = $ServerName
                Ip = $MapItem.IP
                iSCSIPort = $iSCSIPortID.Port
                iSCSIPortal = $iSCSI_Portal
                iSCSITarget = $iSCSI_Target
                }
            Write-Verbose $LineItem
            $MappedVolumes += $LineItem
            
            if ($Favorites -eq $true)
            {
                Write-Verbose "Add the Target to the Favorites list, doesn't login until a reboot (reconnects for every reboot)"
                $Command = [scriptblock]::Create("iscsicli PersistentLoginTarget $iSCSI_Target T $iSCSI_Portal $iSCSI_Port $iSCSI_Initiator $iSCSIPortID.Port * $iSCSI_MPIO * * * * * * * * * 0")
                Invoke-Command -ComputerName $Servername -ScriptBlock $Command
                Start-Sleep 2
                }
                
            if ($LoginTarget -eq $true)
            {
                Write-Verbose "Login to the target for this session since PersistentLoginTarget Doesn't Login until reboot"
                $Command = [scriptblock]::Create("iscsicli LoginTarget $iSCSI_Target T $iSCSI_Portal $iSCSI_Port $iSCSI_Initiator $iSCSIPortID.Port * $iSCSI_MPIO * * * * * * * * * 0")
                Invoke-Command -ComputerName $Servername -ScriptBlock $Command
                Start-Sleep 2
                }
            }
        }
End
    {
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName $LogName -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message
        Return $MappedVolumes
        }
