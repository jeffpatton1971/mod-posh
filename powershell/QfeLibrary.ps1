Function New-QfePatch
{
    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER
        .EXAMPLE
            New-QfePatch 
                -URL 'http://support.microsoft.com/kb/981314' 
                -KB 981314 
                -OS (Get-WmiObject -Class Win32_OperatingSystem |Select-Object -Property Caption -ExpandProperty Caption) 
                -Arch 'x64' 
                -Test '(Get-Item -Path C:\Windows\System32\wbem\cimwin32.dll).VersionInfo.FilePrivatePart' 
                -Answer 20683
        .NOTES
            FunctionName : New-QfePatch
            Created by   : jspatton
            Date Coded   : 07/09/2012 11:16:28
        .LINK
            https://code.google.com/p/mod-posh/wiki/Untitled5#New-QfePatch
    #>
    [CmdletBinding()]
    Param
        (
        [string]$URL,
        [string]$KB,
        [string]$OS,
        [string]$Arch,
        [string]$QfeFilename,
        $Test,
        $Answer,
        $Server = $QfeServer
        )
    Begin
    {
        if ($QfeServer -eq $null)
        {
            Write-Error 'Please define your QFE Server by running the Set-QfeServer cmdlet.'
            break
            }
        }
    Process
    {
        $Result = New-Object -TypeName PSobject -Property @{
            QfeId = "$($Kb.Trim())-$($Os.Trim().Replace(' ','-'))-$($Arch.Trim())"
            URL = $URL.Trim()
            KB = $KB.Trim()
            OS = $OS.Trim()
            Arch = $Arch.Trim()
            QfeFilename = $QfeFilename
            Test = $Test
            Answer = $Answer
            }
        }
    End
    {
        $FileName = $Result.QfeId
        $Result |Export-Clixml "$($QfeServer)\$($FileName).xml"
        }
     }
Function Test-QfePatch
{
    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER
        .EXAMPLE
        .NOTES
            FunctionName : Test-QfePatch
            Created by   : jspatton
            Date Coded   : 07/09/2012 11:55:03
        .LINK
            https://code.google.com/p/mod-posh/wiki/Untitled5#Test-QfePatch
    #>
    [CmdletBinding()]
    Param
        (
        [string]$QfeId,
        [string]$QfeServer = $Global:QfeServer
        )
    Begin
    {
        if ($QfeServer)
        {
            $Qfe = Import-Clixml -Path (Get-ChildItem -Path $QfeServer -Filter "*$($QfeId)*").Fullname
            }
        else
        {
            Write-Error 'Please define your QFE Server by running the Set-QfeServer cmdlet.'
            break
            }        
        }
    Process
    {
        $ScriptBlock = $ExecutionContext.InvokeCommand.NewScriptBlock($Qfe.Test)
        $Return = Invoke-Command -ScriptBlock $ScriptBlock
        }
    End
    {
        $Return -eq $Qfe.Answer
        }
    }
Function Get-QfeList
{
    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER
        .EXAMPLE
        .NOTES
            FunctionName : Get-QfeList
            Created by   : jspatton
            Date Coded   : 07/09/2012 12:10:14
        .LINK
            https://code.google.com/p/mod-posh/wiki/Untitled5#Get-QfeList
    #>
    [CmdletBinding()]
    Param
        (
        [string]$QfeServer = $Global:QfeServer,
        [switch]$All,
        [switch]$Download,
        $LocalPath = 'C:\Hotfixes'
        )
    Begin
    {
        if ($QfeServer)
        {
            $Qfes = Get-ChildItem $QfeServer -Filter *.xml
            }
        else
        {
            Write-Error 'Please define your QFE Server by running the Set-QfeServer cmdlet.'
            break
            }
        if ($Download)
        {
            if ((Test-Path $LocalPath) -eq $false)
            {
                New-Item -Path $LocalPath -ItemType Directory -Force |Out-Null
                }
            }
        }
    Process
    {
        foreach ($Qfe in $Qfes)
        {
            if ($All)
            {
                if ($Download)
                {
                    $QfeFilename = (Import-Clixml -Path $Qfe.FullName |Select-Object -Property QfeFileName).QfeFilename
                    Copy-Item -Path "$($QfeServer)\$($QfeFilename)" -Destination $LocalPath
                    Copy-Item -Path $Qfe.FullName -Destination $LocalPath
                    }
                else
                {
                    Import-Clixml -Path $Qfe.FullName |Select-Object -Property QfeId, KB, Url, Os, Arch
                    }
                }
            else
            {
                if ($Download)
                {
                    $LocalOs = (Get-WmiObject -Class Win32_OperatingSystem |Select-Object -Property Caption -ExpandProperty Caption).Trim()
                    if ((Import-Clixml -Path $Qfe.FullName |Select-Object -Property Os).Os -like $LocalOs)
                    {
                        $QfeFilename = (Import-Clixml -Path $Qfe.FullName |Select-Object -Property QfeFileName).QfeFilename
                        Copy-Item -Path "$($QfeServer)\$($QfeFilename)" -Destination $LocalPath
                        Copy-Item -Path $Qfe.FullName -Destination $LocalPath
                        }
                    }
                else
                {
                    $LocalOs = (Get-WmiObject -Class Win32_OperatingSystem |Select-Object -Property Caption -ExpandProperty Caption).Trim()
                    Import-Clixml -Path $Qfe.FullName |Where-Object {$_.Os -like $LocalOs} |Select-Object -Property QfeId, KB, Url, Os, Arch
                    }
                }
            }
        }
    End
    {
        }
    }
Function Set-QfeServer
{
    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER
        .EXAMPLE
        .NOTES
            FunctionName : Set-QfeServer
            Created by   : jspatton
            Date Coded   : 07/09/2012 13:01:13
        .LINK
            https://code.google.com/p/mod-posh/wiki/Untitled5#Set-QfeServer
    #>
    [CmdletBinding()]
    Param
        (
        $QfeServer
        )
    Begin
    {
        $Global:QfeServer = $QfeServer
        }
    Process
    {
        }
    End
    {
        }
    }
Function Install-QfePatch
{
    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER
        .EXAMPLE
            Get-ChildItem C:\Hotfixes\ -Filter *.msu |Install-QfePatch
        .NOTES
            FunctionName : Install-QfePatch
            Created by   : jspatton
            Date Coded   : 07/09/2012 14:23:45
        .LINK
            https://code.google.com/p/mod-posh/wiki/Untitled5#Install-QfePatch
    #>
    [CmdletBinding()]
    Param
        (
        [Parameter(ValueFromPipeline=$True)]
        $QfeFilename
        )
    Begin
    {
        if ($QfeFilename -and $QfeFilename.Count -eq $null)
        {
            $QfeFilename = Get-Item $QfeFilename
            }
        }
    Process
    {
        foreach ($QfeFile in $QfeFilename)
        {
            if ($QfeFile.extension -eq '.xml')
            {
                $QfeManifest = Import-Clixml $QfeFile
                if((Get-WmiObject -Class Win32_QuickFixEngineering -Filter "HotfixId like '*$($QfeManifest.KB)*'") -eq $null)
                {
                    $QfeFilename = "$($QfeFile.Directory.FullName)\$($QfeManifest.QfeFilename)"
                    $QfeLogFilename = "$($QfeFile.Directory.FullName)\$($QfeManifest.QfeId)-Install.evtx"
                    $CmdLine = "C:\Windows\System32\wusa.exe $($QfeFilename) /quiet /norestart /log:$($QfeLogFilename)"
                    cmd /c $CmdLine
                    }
                else
                {
                    }
                }
            else
            {
                }
            }
        }
    End
    {
        }
    }
Function Uninstall-QfePatch
{
    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER
        .EXAMPLE
        .NOTES
            FunctionName : Uninstall-QfePatch
            Created by   : jspatton
            Date Coded   : 07/09/2012 14:23:58
        .LINK
            https://code.google.com/p/mod-posh/wiki/Untitled5#Uninstall-QfePatch
    #>
    [CmdletBinding()]
    Param
        (
        [Parameter(ValueFromPipeline=$True)]
        $QfeFilename
        )
    Begin
    {
        if ($QfeFilename -and $QfeFilename.Count -eq $null)
        {
            $QfeFilename = Get-Item $QfeFilename
            }
        }
    Process
    {
        foreach ($QfeFile in $QfeFilename)
        {
            if ($QfeFile.extension -eq '.xml')
            {
                $QfeManifest = Import-Clixml $QfeFile
                if((Get-WmiObject -Class Win32_QuickFixEngineering -Filter "HotfixId like '*$($QfeManifest.KB)*'") -eq $null)
                {
                    }
                else
                {
                    $QfeFilename = "$($QfeFile.Directory.FullName)\$($QfeManifest.QfeFilename)"
                    $QfeLogFilename = "$($QfeFile.Directory.FullName)\$($QfeManifest.QfeId)-Uninstall.evtx"
                    $CmdLine = "C:\Windows\System32\wusa.exe /uninstall $($QfeFilename) /quiet /norestart /log:$($QfeLogFilename)"
                    cmd /c $CmdLine
                    }
                }
            else
            {
                }
            }
        }
    End
    {
        }
    }