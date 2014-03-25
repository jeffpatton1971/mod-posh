[CmdletBinding()]
Param
    (
    [string]$FilePath = '.',
    $DoRecurse = $true
    )

Function Get-DiskUsage1
{
    <#
        .SYNOPSIS
            Get the disk usage of a given path
        .DESCRIPTION
            This function returns the disk usage of a given path
        .PARAMETER Path
            The path to check
        .EXAMPLE
            Get-DiskUsage -Dir c:\

            FolderName              FolderSize
            ----------              ----------
            C:\dcam                        204
            C:\DPMLogs                 1166251
            C:\inetpub                       0
            C:\PerfLogs                      0
            C:\Program Files         504195070
            C:\Program Files (x86)  2747425666
            C:\repository             10294506
            C:\SCRATCH                       0
            C:\scripts                 2218148
            C:\TEMP                          0
            C:\Trail                         0
            C:\Users               16198918163
            C:\Windows             18163280116

            Description
            -----------
            This shows the basic syntax of the command
        .EXAMPLE
            Get-DiskUsage -Dir c:\ |Sort-Object -Property FolderSize

            FolderName              FolderSize
            ----------              ----------
            C:\SCRATCH                       0
            C:\Trail                         0
            C:\TEMP                          0
            C:\PerfLogs                      0
            C:\inetpub                       0
            C:\dcam                        204
            C:\DPMLogs                 1166251
            C:\scripts                 2218148
            C:\repository             10294506
            C:\Program Files         504195070
            C:\Program Files (x86)  2747425666
            C:\Users               16198918163
            C:\Windows             18163345365
            
            Description
            -----------
            This example shows piping the output through Sort-Object

        .NOTES
            FunctionName : Get-DiskUsage
            Created by   : jspatton
            Date Coded   : 03/21/2012 10:29:24
            
            If you don't have access to read the contents of a given folder
            the function returns 0.
        .LINK
            https://code.google.com/p/mod-posh/wiki/ComputerManagement#Get-DiskUsage
    #>
    [CmdletBinding()]
    Param
        (
        [string]$Path = ".",
        $Recurse
        )
    Begin
    {
        }
    Process
    {
        foreach ($Folder in (Get-ChildItem $Path))
        {
            $ErrorActionPreference = "SilentlyContinue"
            if ($Folder.PSIsContainer)
            {
                try
                {
                    if ($Recurse -eq $true)
                    {
                        $FolderSize = Get-ChildItem -Recurse $Folder.FullName |Measure-Object -Property Length -Sum
                        }
                    else
                    {
                        $FolderSize = Get-ChildItem $Folder.FullName |Measure-Object -Property Length -Sum
                        }
                    if ($FolderSize -eq $null)
                    {
                        Write-Verbose $Error[0].ToString()
                        $FolderSize = 0
                        }
                    else
                    {
                        $FolderSize = $FolderSize.sum
                        }
                    }
                catch
                {
                    }
                New-Object -TypeName PSobject -Property @{
                    FolderName = $Folder.FullName
                    FolderSize = $FolderSize
                    }
                }
            }
        }
    End
    {
        }
    }
<#
    .SYNOPSIS
        This script calls the Get-DiskUsage function to report foldersize
    .DESCRIPTION
        This scrips calls the Get-DiskUsage function to report the size
        of a given folder.
    .PARAMETER FilePath
        The path to recurse through.
    .EXAMPLE
        .\AdvancedEvent4.ps1 -FilePath C:\

        Size of Folder   Folder
        --------------   ------
        204.00 Bytes     C:\dcam
        1.11 MegaBytes   C:\DPMLogs
        0.00 Bytes       C:\inetpub
        9.63 KiloBytes   C:\logonlog
        0.00 Bytes       C:\PerfLogs
        481.09 MegaBytes C:\Program Files
        2.85 GigaBytes   C:\Program Files (x86)
        9.84 MegaBytes   C:\repository
        0.00 Bytes       C:\SCRATCH
        2.74 MegaBytes   C:\scripts
        25.63 KiloBytes  C:\TEMP
        0.00 Bytes       C:\Trail
        19.75 GigaBytes  C:\Users
        16.06 GigaBytes  C:\Virtual Machines
        16.71 GigaBytes  C:\Windows

        Description
        -----------
        
        This shows the basic output of the command.

    .NOTES
        ScriptName : AdvancedEvent4.ps1
        Created By : jspatton
        Date Coded : 04/05/2012 07:42:40
        ScriptName is used to register events for this script
        LogName is used to determine which classic log to write to
 
        ErrorCodes
            100 = Success
            101 = Error
            102 = Warning
            104 = Information
            
        The Get-Diskusage function above has been modified for this event. It will
        only report on folders, and not include files.
    .LINK
        https://code.google.com/p/mod-posh/wiki/Production/AdvancedEvent4.ps1
#>


        $FolderUsage = Get-DiskUsage1 -Path $FilePath -Recurse $DoRecurse
        
        foreach ($Folder in $FolderUsage)
        {
            if ($Folder.FolderSize -lt 1024)
            {
                $FolderSize = "{0:N2}" -f ($Folder.FolderSize) + " Bytes"
                }
            if ($Folder.FolderSize-gt 1024 -and $Folder.FolderSize -lt 1048576)
            {
                $FolderSize = "{0:N2}" -f ($Folder.FolderSize / 1kb) + " KiloBytes"
                }
            if ($Folder.FolderSize -gt 1048576 -and $Folder.FolderSize -lt 1073741824)
            {
                $FolderSize = "{0:N2}" -f ($Folder.FolderSize / 1mb) + " MegaBytes"
                }
            if ($Folder.FolderSize -gt 1073741824)
            {
                $FolderSize = "{0:N2}" -f ($Folder.FolderSize / 1gb) + " GigaBytes"
                }
            New-Object -TypeName PSobject -Property @{
                Folder = $Folder.FolderName
                'Size of Folder' = $FolderSize
                }
            }