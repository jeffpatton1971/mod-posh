Function New-QfePatch
{
    <#
        .SYNOPSIS
            Create the QFE metadata file on the server
        .DESCRIPTION
            This function will create an XML metadata file for each QFE for each affected OS. This
            is not an automatic action, the admin will need to provide all the details for the 
            hotfix (QFE).
            
            The intended workflow would be an issue is identified on one or more servers. The issue
            is researched and a hotfix is found that addresses this issue. The admin then writes a 
            simple test that will evaluate to true or false depending on the test (eg. checking
            the version information of a file is common). Once the test is confirmed against an
            affected server, the patch is downloaded to a central respository, and all the information
            is passed to this function to create an XML file for later use.
        .PARAMETER URL
            This is the URL from the Microsoft support site that contains the details
            regarding this hotfix.
        .PARAMETER KB
            This is the numeric article for the hotfix. This information is used to
            generate the QfeId, as well as a filter for other functions.
        .PARAMETER OS
            This is the OS of the target system. Ideally this would be the output of
            Get-WmiObject -Query 'Select Caption from Win32_OperatingSystem'. This is what
            in other functions within the library. If there is a difference then lookups
            won't work as expected.
        .PARAMETER Arch
            This would be the 3 to 4 character representation that is used for process architecture
            x86, x64, ia64
        .PARAMETER Test
            This should be a simple test that would evaluate out to true or false. For example
            KB981314 makes a change to cimwin32.dll, as a result the private revision number
            for the file changes. The article displays what the new version should be, so it's
            a simple get-item to check the existing version number and compare it to the new. If
            they don't match, then we need to update, otherwise no update needed.
        .PARAMETER Answer
            This is what we test against. If the answer is 20683, then any value other than 20683
            results in a false, which means the patch should be applied.
        .PARAMETER QfeServer
            This is the path to where the QFEs and their metadata should be stored. It can be in 
            the form of a shared folder:
                \\fs\share\hotfixes
            
            or as a local path:
                C:\hotfixes
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
            https://code.google.com/p/mod-posh/wiki/QfeLIbrary#New-QfePatch
    #>
    [CmdletBinding()]
    Param
        (
        [Parameter(Mandatory=$true)]
        [string]$URL,
        [Parameter(Mandatory=$true)]
        [string]$KB,
        [Parameter(Mandatory=$true)]
        [string]$OS,
        [Parameter(Mandatory=$true)]
        [string]$Arch,
        [Parameter(Mandatory=$true)]
        [string]$QfeFilename,
        [Parameter(Mandatory=$true)]
        $Test,
        [Parameter(Mandatory=$true)]
        $Answer,
        [string]$QfeServer = $Global:QfeServer
        )
    Begin
    {
        Write-Verbose "Check to see if we have the QfeServer variable"
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
        try
        {
            $FileName = $Result.QfeId
            Write-Verbose "Write the QFE metadata to a file: $($QfeServer)\$($FileName).xml"
            $Result |Export-Clixml "$($QfeServer)\$($FileName).xml"
            }
        catch
        {
            Write-Error $Error[0]
            Write-Error "QFE Metadata file not written to disk."
            break
            }
        }
     }
Function Test-QfePatch
{
    <#
        .SYNOPSIS
            Verify that the hotfix is needed for this system.
        .DESCRIPTION
            This function will read in the metadata from the provided QfeId and extract
            the test and answer properties. This test doesn't install the patch it simply
            runs the test and compares it to the answer. If they don't equal then the patch
            is assumed to be needed.
            
            Whether the hotfix acutally gets installed is handled by wusa in a seperate
            function.
        .PARAMETER QfeId
            This is the generated Id based on the KB, OS and Arch. To get a list of 
            QFE's you can run Get-QfeList.
        .PARAMETER QfeServer
            This is the path to where the QFEs and their metadata should be stored. It can be in 
            the form of a shared folder:
                \\fs\share\hotfixes
            
            or as a local path:
                C:\hotfixes
        .EXAMPLE
            Test-QfePatch -QfeId '977944-Microsoft-Windows-7-Enterprise-x64'
        .NOTES
            FunctionName : Test-QfePatch
            Created by   : jspatton
            Date Coded   : 07/09/2012 11:55:03
        .LINK
            https://code.google.com/p/mod-posh/wiki/QfeLIbrary#Test-QfePatch
    #>
    [CmdletBinding()]
    Param
        (
        [Parameter(Mandatory=$true)]
        [string]$QfeId,
        [string]$QfeServer = $Global:QfeServer
        )
    Begin
    {
        Write-Verbose "Check to see if we have the QfeServer variable"
        if ($QfeServer)
        {
            try
            {
                Write-Verbose "Import the meta data file that matches $($QfeId)"
                $Qfe = Import-Clixml -Path (Get-ChildItem -Path $QfeServer -Filter "*$($QfeId)*").Fullname
                }
            catch
            {
                Write-Error $Error[0]
                break
                }
            }
        else
        {
            Write-Error 'Please define your QFE Server by running the Set-QfeServer cmdlet.'
            break
            }        
        }
    Process
    {
        try
        {
            Write-Verbose "Build a scriptblock from the Test property of the imported QFE"
            $ScriptBlock = $ExecutionContext.InvokeCommand.NewScriptBlock($Qfe.Test)
            Write-Verbose "Run the following test`r`n$($Qfe.Test)"
            $Return = Invoke-Command -ScriptBlock $ScriptBlock
            }
        catch
        {
            Write-Error $Error[0]
            break
            }
        }
    End
    {
        Write-Verbose "Return `$true or `$false based on the result of the test."
        $Return -eq $Qfe.Answer
        }
    }
Function Get-QfeList
{
    <#
        .SYNOPSIS
            Get a list of available QFE's from the server.
        .DESCRIPTION
            This function will return a list of available QFE's that are available. The default
            action is to return only a list of QFE's where the client OS matches the OS property
            of QFE metadata file. This behaviour can be overridden by the -All switch.
            
            In addition to returning a list of available QFE's, you can also specify the -Download
            switch to optionally download all the QFE's or just the ones for your OS.
        .PARAMETER QfeServer
            This is the path to where the QFEs and their metadata should be stored. It can be in 
            the form of a shared folder:
                \\fs\share\hotfixes
            
            or as a local path:
                C:\hotfixes
        .PARAMETER All
            When present the list of QFE's returned is filtered against the client OS. It's
            important that the client OS matches the OS property of the QFE. 
            
            See the help for New-QfePatch for more information about the OS property.
        .PARAMETER Download
            When present the list of QFE's will be downloaded locally to the client.
        .PARAMETER LocalPath
            This is the location to where the hotfix files and their metadata will be 
            downloaded to. The default location is C:\HotFixes, if it doesn't exist it
            will be created.
            
            This folder only get's created, if -Download is present.
        .EXAMPLE
            Get-QfeList


            QfeId : 977944-Microsoft-Windows-7-Enterprise-x64
            KB    : 977944
            URL   : http://support.microsoft.com/kb/977944
            OS    : Microsoft Windows 7 Enterprise
            Arch  : x64

            QfeId : 981314-Microsoft-Windows-7-Enterprise-x64
            KB    : 981314
            URL   : http://support.microsoft.com/kb/981314
            OS    : Microsoft Windows 7 Enterprise
            Arch  : x64

            Description
            -----------
            This example shows the default behaviour of the function. The list of QFE's matches
            the client OS, Microsoft Windows 7 Enterprise.
        .EXAMPLE
            Get-QfeList -All


            QfeId : 977944-Microsoft-Windows-7-Enterprise-x64
            KB    : 977944
            URL   : http://support.microsoft.com/kb/977944
            OS    : Microsoft Windows 7 Enterprise
            Arch  : x64

            QfeId : 981314-Microsoft-Windows-7-Enterprise-x64
            KB    : 981314
            URL   : http://support.microsoft.com/kb/981314
            OS    : Microsoft Windows 7 Enterprise
            Arch  : x64

            QfeId : 981314-Microsoft-Windows-Server-2008-R2-Enterprise-x64
            KB    : 981314
            URL   : http://support.microsoft.com/kb/981314
            OS    : Microsoft Windows Server 2008 R2 Enterprise
            Arch  : x64

            Description
            -----------
            This example shows additional QFE's because the -All switch was passed into the function.
        .EXAMPLE
            Get-QfeList -All -Download -LocalPath c:\temp
            
            Description
            -----------
            This example will download all QFE's to the c:\temp folder on the local computer.
        .NOTES
            FunctionName : Get-QfeList
            Created by   : jspatton
            Date Coded   : 07/09/2012 12:10:14
        .LINK
            https://code.google.com/p/mod-posh/wiki/QfeLIbrary#Get-QfeList
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
        Write-Verbose "Check to see if we have the QfeServer variable"
        if ($QfeServer)
        {
            try
            {
                Write-Verbose "Get a list of all the QFE files stored in $($QfeServer)"
                $Qfes = Get-ChildItem $QfeServer -Filter *.xml
                }
            catch
            {
                Write-Error $Error[0]
                break
                }
            }
        else
        {
            Write-Error 'Please define your QFE Server by running the Set-QfeServer cmdlet.'
            break
            }
        if ($Download)
        {
            Write-Verbose "We're downloading, create the folder $($LocalPath)"
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
                Write-Verbose "Return all QFEs"
                if ($Download)
                {
                    Write-Verbose "Download all QFEs"
                    $QfeFilename = (Import-Clixml -Path $Qfe.FullName |Select-Object -Property QfeFileName).QfeFilename
                    Write-Verbose "Copy the hotfix $($QfeFilename)"
                    Copy-Item -Path "$($QfeServer)\$($QfeFilename)" -Destination $LocalPath
                    Write-Verbose "Copy the meta file $($Qfe.FullName)"
                    Copy-Item -Path $Qfe.FullName -Destination $LocalPath
                    }
                else
                {
                    Write-Verbose "Display the QfeId, KB, URL, Os and Arch from the Qfe"
                    Import-Clixml -Path $Qfe.FullName |Select-Object -Property QfeId, KB, Url, Os, Arch
                    }
                }
            else
            {
                Write-Verbose "Return all QFEs that match the client OS"
                if ($Download)
                {
                    Write-Verbose "Download QFEs that match the client OS"
                    Write-Verbose "Ask WMI for the client OS"
                    $LocalOs = (Get-WmiObject -Class Win32_OperatingSystem |Select-Object -Property Caption -ExpandProperty Caption).Trim()
                    Write-Verbose "Display only QFEs where the client OS matches the OS property of the QFE"
                    if ((Import-Clixml -Path $Qfe.FullName |Select-Object -Property Os).Os -like $LocalOs)
                    {
                        $QfeFilename = (Import-Clixml -Path $Qfe.FullName |Select-Object -Property QfeFileName).QfeFilename
                        Write-Verbose "Copy the hotfix $($QfeFilename)"
                        Copy-Item -Path "$($QfeServer)\$($QfeFilename)" -Destination $LocalPath
                        Write-Verbose "Copy the meta file $($Qfe.FullName)"
                        Copy-Item -Path $Qfe.FullName -Destination $LocalPath
                        }
                    }
                else
                {
                    Write-Verbose "Ask WMI for the client OS"
                    $LocalOs = (Get-WmiObject -Class Win32_OperatingSystem |Select-Object -Property Caption -ExpandProperty Caption).Trim()
                    Write-Verbose "Display the QfeId, KB, URL, Os and Arch from the Qfe"
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
            Define the location for QFE's for this session.
        .DESCRIPTION
            This function set's a global variable QfeServer that is able to be used
            throughout your current PowerShell session.
        .PARAMETER QfeServer
            This is the path to where the QFEs and their metadata should be stored. It can be in 
            the form of a shared folder:
                \\fs\share\hotfixes
            
            or as a local path:
                C:\hotfixes
        .EXAMPLE
            Set-QfeServer -QfeServer c:\hotfix
            
            Description
            -----------
            This example shows setting the QfeServer to a local path
        .EXAMPLE
            Set-QfeServer -QfeServer \\fs\share\hotfix
            
            Description
            -----------
            This example shows setting the QfeServer to a UNC path.
        .NOTES
            FunctionName : Set-QfeServer
            Created by   : jspatton
            Date Coded   : 07/09/2012 13:01:13
        .LINK
            https://code.google.com/p/mod-posh/wiki/QfeLIbrary#Set-QfeServer
    #>
    [CmdletBinding()]
    Param
        (
        [Parameter(Mandatory=$true)]
        $QfeServer
        )
    Begin
    {
        Write-Verbose "Check to make sure that $($QfeServer) exists as a path."
        if ((Test-Path $QfeServer))
        {
            $Global:QfeServer = $QfeServer
            }
        else
        {
            Write-Error "$($QfeServer) is not a valid path, please make sure that $($QfeServer) exists and that you have read/write access to it."
            }
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
            Install a hotfix on the local computer
        .DESCRIPTION
            This function will install a hotfix on the local computer using WUSA.exe. For more
            information on WUSA please see the related links at the bottom of this help file.
            
            Installation is completely handled by WUSA. Regardless of what Test-QfePatch returns
            WUSA has the last say in whether the patch is needed. It's beyond my depth to any more
            than just a simple test to check.
            
            We query the WMI class Win32_QuickFixEngineering to see if the hotfix is already installed
            before we do anything. If it exists in the list, we're done. If not, we install the patch.
            For verification I pass the /log paramter to WUSA so a logfile is generated in the
            same location as the hotfix. If there are any error's reported in the log those are
            returned at the end of the processing.
            
            I think the most common error would be
                Windows update  could not be installed because of error 2149842967
                
            This indicates that the hotfix is not needed for this computer. Most likely the computer
            has already been patched, or has a service pack installed with the included hotfix.
        .PARAMETER QfeFilename
            This is the XML metadata file that gets copied to the local computer when Get-QfeList -Download
            is used. You can install these one at a time, or pass them over the pipeline.
        .EXAMPLE
            Get-ChildItem C:\Hotfixes\ |Install-QfePatch
            
            Description
            -----------
            This example passes in all filese stored in the Hotfixes folder. The function will only
            process an XML file, and we assume the only XML files are the ones we created with the
            New-QfePatch function.
        .EXAMPLE
            Install-QfePatch -QfeFilename C:\Hotfixes\977944-Microsoft-Windows-7-Enterprise-x64.xml
            
            Description
            -----------
            This example shows installing a specific hotfix.
        .NOTES
            FunctionName : Install-QfePatch
            Created by   : jspatton
            Date Coded   : 07/09/2012 14:23:45
        .LINK
            https://code.google.com/p/mod-posh/wiki/QfeLIbrary#Install-QfePatch
        .LINK
            http://support.microsoft.com/kb/934307
    #>
    [CmdletBinding()]
    Param
        (
        [Parameter(ValueFromPipeline=$True)]
        $QfeFilename
        )
    Begin
    {
        Write-Verbose "Checking to see if we have piped files"
        if ($QfeFilename -and $QfeFilename.Count -eq $null)
        {
            Write-Verbose "Singleton file passed in"
            $QfeFilename = Get-Item $QfeFilename
            }
        }
    Process
    {
        foreach ($QfeFile in $QfeFilename)
        {
            Write-Verbose "Only working with XML meta data files."
            if ($QfeFile.extension -eq '.xml')
            {
                Write-Verbose "Read in the metadata before processing."
                $QfeManifest = Import-Clixml $QfeFile
                Write-Verbose "Ask WMI if this hotfix is already applied"
                if((Get-WmiObject -Class Win32_QuickFixEngineering -Filter "HotfixId like '*$($QfeManifest.KB)*'") -eq $null)
                {
                    Write-Verbose "Build the full path to the hotfix executable."
                    $QfeFilename = "$($QfeFile.Directory.FullName)\$($QfeManifest.QfeFilename)"
                    Write-Verbose "Build the logfile based on the QfeId"
                    $QfeLogFilename = "$($QfeFile.Directory.FullName)\$($QfeManifest.QfeId)-Install.evtx"
                    Write-Verbose "Build the command-line to execute the installation"
                    $CmdLine = "C:\Windows\System32\wusa.exe $($QfeFilename) /quiet /norestart /log:$($QfeLogFilename)"
                    Write-Verbose "Pass the command-line to the CMD environment for installation"
                    cmd /c $CmdLine
                    Write-Verbose "Return all error messages from the logfile created"
                    $Message = Get-WinEvent -Oldest -FilterHashtable @{Path=$QfeLogFilename;Level=2} |Select-Object -Property Message
                    if ($Message)
                    {
                        Write-Error "Errors found review $($QfeLogFileName) for more details"
                        $Message
                        }
                    }
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
            Uninstall a hotfix from the local computer
        .DESCRIPTION
            This function will uninstall a hotfix from the local computer using WUSA.exe. For more
            information on WUSA please see the related links at the bottom of this help file.

            We query the WMI class Win32_QuickFixEngineering to see if the hotfix is already installed
            before we do anything. If it exists in the list, we uninstall the patch. For verification 
            I pass the /log paramter to WUSA so a logfile is generated in the same location as the 
            hotfix. If there are any error's reported in the log those are returned at the end of 
            the processing.
        .PARAMETER QfeFilename
            This is the XML metadata file that gets copied to the local computer when Get-QfeList -Download
            is used. You can install these one at a time, or pass them over the pipeline.
        .EXAMPLE
            Get-ChildItem C:\Hotfixes\ |Uninstall-QfePatch
            
            Description
            -----------
            This example passes in all filese stored in the Hotfixes folder. The function will only
            process an XML file, and we assume the only XML files are the ones we created with the
            New-QfePatch function.
        .EXAMPLE
            Uninstall-QfePatch -QfeFilename C:\Hotfixes\977944-Microsoft-Windows-7-Enterprise-x64.xml
            
            Description
            -----------
            This example shows uninstalling a specific hotfix.
        .NOTES
            FunctionName : Uninstall-QfePatch
            Created by   : jspatton
            Date Coded   : 07/09/2012 14:23:58
        .LINK
            https://code.google.com/p/mod-posh/wiki/QfeLIbrary#Uninstall-QfePatch
        .LINK
            http://support.microsoft.com/kb/934307
    #>
    [CmdletBinding()]
    Param
        (
        [Parameter(ValueFromPipeline=$True)]
        $QfeFilename
        )
    Begin
    {
        Write-Verbose "Checking to see if we have piped files"
        if ($QfeFilename -and $QfeFilename.Count -eq $null)
        {
            Write-Verbose "Singleton file passed in"
            $QfeFilename = Get-Item $QfeFilename
            }
        }
    Process
    {
        foreach ($QfeFile in $QfeFilename)
        {
            Write-Verbose "Only working with XML meta data files."
            if ($QfeFile.extension -eq '.xml')
            {
                Write-Verbose "Read in the metadata before processing."
                $QfeManifest = Import-Clixml $QfeFile
                Write-Verbose "Ask WMI if this hotfix is already applied"
                if((Get-WmiObject -Class Win32_QuickFixEngineering -Filter "HotfixId like '*$($QfeManifest.KB)*'"))
                {
                    Write-Verbose "Build the full path to the hotfix executable."
                    $QfeFilename = "$($QfeFile.Directory.FullName)\$($QfeManifest.QfeFilename)"
                    Write-Verbose "Build the logfile based on the QfeId"
                    $QfeLogFilename = "$($QfeFile.Directory.FullName)\$($QfeManifest.QfeId)-Uninstall.evtx"
                    Write-Verbose "Build the command-line to execute the installation"
                    $CmdLine = "C:\Windows\System32\wusa.exe /uninstall $($QfeFilename) /quiet /norestart /log:$($QfeLogFilename)"
                    Write-Verbose "Pass the command-line to the CMD environment for uninstall"                    
                    cmd /c $CmdLine
                    Write-Verbose "Return all error messages from the logfile created"
                    $Message = Get-WinEvent -Oldest -FilterHashtable @{Path=$QfeLogFilename;Level=2} |Select-Object -Property Message
                    if ($Message)
                    {
                        Write-Error "Errors found review $($QfeLogFileName) for more details"
                        $Message
                        }
                    }
                }
            }
        }
    End
    {
        }
    }
Function Get-Qfe
{
    <#
        .SYNOPSIS
            Return information about a specific QFE
        .DESCRIPTION
            This function will return information about a specific QFE and if the -Online
            switch is present will open Internet Explorer to the URL defined in the QFE
            file.
        .PARAMETER QfeId
            This is the generated Id based on the KB, OS and Arch. To get a list of 
            QFE's you can run Get-QfeList.
        .PARAMETER QfeServer
            This is the path to where the QFEs and their metadata should be stored. It can be in 
            the form of a shared folder:
                \\fs\share\hotfixes
            
            or as a local path:
                C:\hotfixes
        .EXAMPLE
            Get-Qfe -QfeId 977944-Microsoft-Windows-7-Enterprise-x64


            Arch        : x64
            Answer      : 20600
            URL         : http://support.microsoft.com/kb/977944
            QfeFilename : Windows6.1-KB977944-x64.msu
            OS          : Microsoft Windows 7 Enterprise
            Test        : (Get-Item -Path C:\Windows\System32\shell32.dll).VersionInfo.FilePrivatePart
            QfeId       : 977944-Microsoft-Windows-7-Enterprise-x64
            KB          : 977944

            Description
            -----------
            This example shows the basic usage of this function.
        .EXAMPLE
            Get-Qfe -QfeId 977944-Microsoft-Windows-7-Enterprise-x64 -Online
            
            Description
            -----------
            This example shows using the function with the online switch
        .NOTES
            FunctionName : Get-Qfe
            Created by   : jspatton
            Date Coded   : 07/10/2012 12:56:33
        .LINK
            https://code.google.com/p/mod-posh/wiki/QfeLIbrary#Get-Qfe
    #>
    [CmdletBinding()]
    Param
        (
        [Parameter(Mandatory=$true)]
        [string]$QfeId,
        [switch]$Online,
        [string]$QfeServer = $Global:QfeServer
        )
    Begin
    {
        Write-Verbose "Check to see if we have the QfeServer variable"
        if ($QfeServer)
        {
            try
            {
                Write-Verbose "Import the meta data file that matches $($QfeId)"
                $Qfe = Import-Clixml -Path (Get-ChildItem -Path $QfeServer -Filter "*$($QfeId)*").Fullname
                }
            catch
            {
                Write-Error $Error[0]
                break
                }
            }
        else
        {
            Write-Error 'Please define your QFE Server by running the Set-QfeServer cmdlet.'
            break
            }        
        }
    Process
    {
        if ($Online)
        {
            Write-Verbose "Go to the URL"
            try
            {
                Write-Verbose "Creating browser object"
                $Browser = New-Object -ComObject InternetExplorer.Application
                Write-Verbose "Navigate to $($Qfe.Url)"
                $Browser.Navigate($Qfe.Url)
                Write-Verbose "Make the browser visible"
                $Browser.Visible = $true
                }
            catch
            {
                Write-Error $Error[0]
                break
                }
            }
        else
        {
            Write-Verbose "Output the metadata"
            $Qfe |Format-List *
            }
        }
    End
    {
        }
    }
Function Clear-QfeLocalStore
{
    <#
        .SYNOPSIS
            Archive the eventlogs and update files
        .DESCRIPTION
            This function will create a zipfile inside the specified folder, and copy
            the eventlogs, update files and QFE metadata into that file. It will then
            remove everything but the zipfile.
            
            If you have previous archives inside the specified folder those are not removed
            only files that are not zip files are removed.
        .PARAMETER LocalPath
            This is the location to where the hotfix files and their metadata will be 
            downloaded to. The default location is C:\HotFixes, if it doesn't exist it
            will be created.
        .EXAMPLE
            Clear-QfeLocalStore -LocalPath C:\Hotfixes
            
            Description
            -----------
            This example shows the basic usage of this function.
        .NOTES
            FunctionName : Clear-QfeLocalStore
            Created by   : jspatton
            Date Coded   : 07/10/2012 15:50:28
        .LINK
            https://code.google.com/p/mod-posh/wiki/QfeLIbrary#Clear-QfeLocalStore
    #>
    [CmdletBinding()]
    Param
        (
        [Parameter(Mandatory=$true)]
        $LocalPath = 'C:\Hotfixes'
        )
    Begin
    {
        $ZipFile = "$($LocalPath)\$(Get-Date -f MMddyyy-HHmm).zip"
        Write-Verbose "Create an empty zip file"
        Set-Content $ZipFile ("PK"+[char]5+[char]6+("$([char]0)"*18))
        Write-Verbose "Connect to $$(ZipFile) so we can copy files to it"
        $ZipFolder = (New-Object -ComObject Shell.Application).Namespace($ZipFile)
        }
    Process
    {
        foreach ($File in (Get-ChildItem $LocalPath -Recurse))
        {
            if (!(($File.Extension -eq '.zip') -or (($File.Extension -eq '.zip'))))
            {
                try
                {
                    Write-Verbose "Copying $($File.FullName) to $($zipfile)"
                    $ZipFolder.CopyHere($File.FullName)
                    Start-sleep -milliseconds 500
                    Write-Verbose "Deleteing $($file.FullName)"
                    Remove-Item $File.FullName
                    }
                catch
                {
                    Write-Error $Error[0]
                    break
                    }
                }
            }
        }
    End
    {
        }
    }

Export-ModuleMember *