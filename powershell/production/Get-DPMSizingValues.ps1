<#
    .SYNOPSIS
        This script is an attempt at a simple replacement for the existing calculator
    .DESCRIPTION
        This script uses the basic formulas of the v3.3 DPM Sizing tool. You can find
        links to the various articles explaing the calculator under the RELATED LINKS
        section. I will not attempt to explain everything here. 
        
        This script will work against the local or one or more remote machines. It will
        establish a connection to the computer and retrieve a list of volumes whose
        used space is greater than 0. For each of those volumes it will perform the
        same basic calculations as defined in the DPMSizingCalculatorv3.3
        
        The script will return the calculated values for the Replica Volume and Shadow
        Copy volume. These values could then be used to create Protection Groups of 
        the appropriate size to accomodate the needs of the backup.
    .PARAMETER ReplicaOverheadFactor
        This is the amount of overhead to account for. This number should be entered
        as a whole number which is then converted to a percentage internally. For 
        example:
        
        ReplicaOverheadFactor of 120%
        ReplicaOverheadFactor = 120
    .PARAMETER RetentionRange
        The number of days to store retention points on disk.
    .PARAMETER DataChange
        The amount of change that occurs in your data. This number should be entered
        as a whole number which is then convereted to a percentage internally. For
        example:
        
        DataChange of 10%
        DataChange = 10
    .PARAMETER ComputerName
        The name of one or more computers to connect to. If nothing is specified we
        will pull drive data from the local computer.
    .EXAMPLE
        .\Get-DPMSizingValues.ps1 -ComputerName 'fs1.company.com','fs2'
        
        Name         UsedSpace Retention           Replica       ShadowCopy DataChange ReplicaOverhead
        ----         --------- ---------           -------       ---------- ---------- ---------------
        C     34.9616050720215         7  41.9539260864258  26.035623550415         10             120
        H      333.11011505127         7  399.732138061523 234.739580535889         10             120
        I     623.373153686523         7  748.047784423828 437.923707580566         10             120
        J     169.964572906494         7  203.957487487793 120.537701034546         10             120
        K     516.936908721924         7  620.324290466309 363.418336105347         10             120
        M     170.538990020752         7  204.646788024902 120.939793014526         10             120
        N      354.89725112915         7   425.87670135498 249.990575790405         10             120
        O     433.843196868896         7  520.611836242676 305.252737808228         10             120
        Q    0.106410980224609         7 0.127693176269531 1.63698768615723         10             120
        T     295.978736877441         7   355.17448425293 208.747615814209         10             120
        U     4025.43589782715         7  4830.52307739258   2819.367628479         10             120
        V      425.40172958374         7  510.482075500488 299.343710708618         10             120
        C     37.3827171325684         7   44.859260559082 27.7304019927979         10             120
        L     588.976539611816         7   706.77184753418 413.846077728272         10             120
        P     2.79181671142578         7  3.35018005371094 3.51677169799805         10             120
        R     1166.86437988281         7  1400.23725585938 818.367565917969         10             120
        S     473.855869293213         7  568.627043151855 333.261608505249         10             120
        W     1268.42325592041         7  1522.10790710449 889.458779144287         10             120
        Y     515.471645355225         7  618.565974426269 362.392651748657         10             120
        
        Description
        -----------
        This example shows pulling data from multiple servers and a sample of the output.

    .EXAMPLE
        .\Get-DPMSizingValues.ps1 -ComputerName 'RemoteHost'
        
        Name            : C
        UsedSpace       : 44.3877143859863
        Retention       : 7
        Replica         : 53.2652572631836
        ShadowCopy      : 32.6339000701904
        DataChange      : 10
        ReplicaOverhead : 120

        Description
        -----------
        This example is pulling data from a single remote computer.
    .EXAMPLE
        .\Get-DPMSizingValues.ps1     
        
        Name        UsedSpace Retention          Replica       ShadowCopy DataChange ReplicaOverhead
        ----        --------- ---------          -------       ---------- ---------- ---------------
        C    83.2223930358887         7 99.8668716430664 59.8181751251221         10             120
        E    271.819194793701         7 326.183033752441 191.835936355591         10             120
        P    2.79181671142578         7 3.35018005371094 3.51677169799805         10             120
        S    473.855869293213         7 568.627043151855 333.261608505249         10             120
        U    516.929672241211         7 620.315606689453 363.413270568848         10             120
        W    1268.42526245117         7 1522.11031494141  889.46018371582         10             120
        
        Description
        -----------
        This example is pulling data from the local computer.

    .NOTES
        ScriptName : Get-DPMSizingValues.ps1
        Created By : jspatton
        Date Coded : 04/10/2012 15:34:43
        ScriptName is used to register events for this script
        LogName is used to determine which classic log to write to
 
        ErrorCodes
            100 = Success
            101 = Error
            102 = Warning
            104 = Information
    .LINK
        https://code.google.com/p/mod-posh/wiki/Production/Get-DPMSizingValues.ps1
    .LINK
        http://technet.microsoft.com/en-us/library/bb795684.aspx
    .LINK
        http://blogs.technet.com/b/dpm/archive/2007/10/31/data-protection-manager-2007-storage-calculator.aspx
    .LINK
        http://blogs.technet.com/b/dpm/archive/2010/09/02/new-dpm2010-storage-calculator-links-sep-2010.aspx
    .LINK
        http://blogs.msdn.com/b/douggowans/archive/2008/01/17/a-closer-look-at-the-dpm-2007-storage-calculator.aspx
#>
[CmdletBinding()]
Param
    (
    $ReplicaOverheadFactor = 120,
    $RetentionRange = 7,
    $DataChange = 10,
    $ComputerName = (& hostname)
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

        $Volumes = @()
        $DPMData = @()
        $ScriptBlock = {Get-PSDrive -PSProvider FileSystem |Where-Object {$_.Used -gt 0} |Select-Object -Property Free, Name, @{Label='Used';Expression={$_.Used /1gb}}}
        }
Process
    {
        if ($ComputerName.Count -ne $null)
        {
            foreach ($Computer in $ComputerName)
            {
                Write-Verbose 'Create a new session for $($Computer)'
                $ThisSession = New-PSSession -ComputerName $Computer -Credential $Credentials
                Write-Verbose 'Connect to the session, and collect the results of the scriptblock'
                $Volumes += Invoke-Command -Session $ThisSession -ScriptBlock $ScriptBlock
                Write-Verbose 'Close sesion when done.'
                Remove-PSSession -Session $ThisSession
                }
            }
        else
        {
            if ($ComputerName -eq (& hostname))
            {
                $Volumes += Invoke-Command -ScriptBlock $ScriptBlock
                }
            else
            {
                Write-Verbose 'Create a new session for $($ComputerName)'
                $ThisSession = New-PSSession -ComputerName $ComputerName -Credential $Credentials
                Write-Verbose 'Connect to the session, and collect the results of the scriptblock'
                $Volumes += Invoke-Command -Session $ThisSession -ScriptBlock $ScriptBlock
                Write-Verbose 'Close sesion when done.'
                Remove-PSSession -Session $ThisSession
                }
            }
        Foreach ($VolumeIdentifier in $Volumes)
        {
            Write-Verbose 'This formula is located at G2 on the spreadsheet (=IF(J2>=100%,E2*J2,E2*1.5)). '
            if (($ReplicaOverheadFactor/100) -gt 1)
            {
                $ReplicaVolume = $VolumeIdentifier.Used * ($ReplicaOverheadFactor/100)
                }
            else
            {
                $ReplicaVolume = $VolumeIdentifier.Used * 1.5
                }
            Write-Verbose 'This formula is located at H2 on the spreadsheet (=IF(E2>0,(E2*F2*I2) + (1600/1024),0))'
            if ($VolumeIdentifier.Used -gt 0)
            {
                $ShadowCopyVolume = ($VolumeIdentifier.Used * $RetentionRange * ($DataChange/100)) + (1600/1024)
                }
            Write-Verbose 'Build the object to return'
            $Return = New-Object -TypeName PSObject -Property @{
                Name = $VolumeIdentifier.Name
                UsedSpace = $VolumeIdentifier.Used
                TotalSpace = (($VolumeIdentifier.Free)/1gb + ($VolumeIdentifier.Used))
                Retention = $RetentionRange
                Replica = $ReplicaVolume
                ShadowCopy = $ShadowCopyVolume
                DataChange = $DataChange
                ReplicaOverhead = $ReplicaOverheadFactor
                }

            $DPMData += $Return
            }
        }
End
    {
        Return $DPMData |Select-Object -Property Name, UsedSpace, TotalSpace, Retention, Replica, ShadowCopy, DataChange, ReplicaOverhead
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName $LogName -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message	
        }
