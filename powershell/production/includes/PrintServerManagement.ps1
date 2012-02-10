Function Get-Printers
{
    <#
    .SYNOPSIS
        Get a list of printers from the specified print server
    .DESCRIPTION
        This function returns the Name of each printer installed
        on the specified print server.
    .PARAMETER ComputerName
        Name of the print server
    .EXAMPLE
        Get-Printers -ComputerName ps
    .LINK
        https://code.google.com/p/mod-posh/wiki/PrintServerManagement#Get-Printers
    #>
    [CmdletBinding()]
    Param
        (
        [String]$ComputerName
        )
    Begin
    {
        $Host.Runspace.ThreadOptions = "ReuseThread"
        if ((Get-WmiObject -Class Win32_OperatingSystem).OSArchitecture -eq '64-bit')
        {
            $SystemPrinting = Get-ChildItem "$($env:systemroot)\assembly\GAC_64\System.Printing"
            $SystemPrintingFile = Get-ChildItem -Name "*system.printing*" -Recurse -Path $SystemPrinting.FullName
            $SystemPrintingFile = "$($SystemPrinting.FullName)\$($SystemPrintingFile)"
            }
        else
        {
            $SystemPrinting = Get-ChildItem "$($env:systemroot)\assembly\GAC_32\System.Printing"
            $SystemPrintingFile = Get-ChildItem -Name "*system.printing*" -Recurse -Path $SystemPrinting.FullName
            $SystemPrintingFile = "$($SystemPrinting.FullName)\$($SystemPrintingFile)"
            }
        $ErrorActionPreference = "Stop"
        Try
        {
            Add-Type -Path $SystemPrintingFile
            $PrintServer = New-Object System.Printing.PrintServer("\\$($ComputerName)")
            $PrintQueues = $PrintServer.GetPrintQueues()
            }
        Catch
        {
            Write-Error $Error[0].Exception
            Break
            }
        $Printers = @()
        }
    Process
    {
        Foreach ($PrintQueue in $PrintQueues)
        {
            $ThisPrinter = New-Object -TypeName PSObject -Property @{
                Name = $PrintQueue.Name
                }
            $Printers += $ThisPrinter
            }
        }
    End
    {
        Return $Printers
        }
    }
Function Get-PrintQueue
{
    <#
    .SYNOPSIS
        Return the print queue for a given printer
    .DESCRIPTION
        This function returns the print queue for a specific printer 
        from the print server.
    .PARAMETER ComputerName
        Name of the print server
    .PARAMETER Name
        Name of the print queue
    .EXAMPLE
        Get-PrintQueue -ComputerName ps -Name HPCLJ5500
    .LINK
        https://code.google.com/p/mod-posh/wiki/PrintServertManagement#Get-PrintQueue
    #>
    [CmdletBinding()]
    Param
        (
        $ComputerName,
        $Name
        )
    Begin
    {
        $Host.Runspace.ThreadOptions = "ReuseThread"
        if ((Get-WmiObject -Class Win32_OperatingSystem).OSArchitecture -eq '64-bit')
        {
            $SystemPrinting = Get-ChildItem "$($env:systemroot)\assembly\GAC_64\System.Printing"
            $SystemPrintingFile = Get-ChildItem -Name "*system.printing*" -Recurse -Path $SystemPrinting.FullName
            $SystemPrintingFile = "$($SystemPrinting.FullName)\$($SystemPrintingFile)"
            }
        else
        {
            $SystemPrinting = Get-ChildItem "$($env:systemroot)\assembly\GAC_32\System.Printing"
            $SystemPrintingFile = Get-ChildItem -Name "*system.printing*" -Recurse -Path $SystemPrinting.FullName
            $SystemPrintingFile = "$($SystemPrinting.FullName)\$($SystemPrintingFile)"
            }
        }
    Process
    {
        $ErrorActionPreference = "Stop"
        Try
        {
            Add-Type -Path $SystemPrintingFile
            $PrintServer = New-Object System.Printing.PrintServer("\\$($ComputerName)")
            $PrintQueue = $PrintServer.GetPrintQueue($Name)
            }
        Catch
        {
            Write-Error $Error[0].Exception
            Break
            }
        }
    End
    {
        Return $PrintQueue
        }
    }
Function Get-PrintJobs
{
    <#
    .SYNOPSIS
        Return the list of jobs on the current printer
    .DESCRIPTION
        This function returns a list of pending jobs on the specified print server for a given queue
    .PARAMETER ComputerName
        Name of the print sever
    .PARAMETER Name
        Name of the print queue
    .EXAMPLE
        Get-PrintJobs -ComputerName ps -Name HPLJ5000
    .LINK
        https://code.google.com/p/mod-posh/wiki/PrintServerManagement#Get-PrintJobs
    #>
    [CmdletBinding()]
    Param
        (
        $ComputerName,
        $Name
        )
    Begin
    {
        $Host.Runspace.ThreadOptions = "ReuseThread"
        if ((Get-WmiObject -Class Win32_OperatingSystem).OSArchitecture -eq '64-bit')
        {
            $SystemPrinting = Get-ChildItem "$($env:systemroot)\assembly\GAC_64\System.Printing"
            $SystemPrintingFile = Get-ChildItem -Name "*system.printing*" -Recurse -Path $SystemPrinting.FullName
            $SystemPrintingFile = "$($SystemPrinting.FullName)\$($SystemPrintingFile)"
            }
        else
        {
            $SystemPrinting = Get-ChildItem "$($env:systemroot)\assembly\GAC_32\System.Printing"
            $SystemPrintingFile = Get-ChildItem -Name "*system.printing*" -Recurse -Path $SystemPrinting.FullName
            $SystemPrintingFile = "$($SystemPrinting.FullName)\$($SystemPrintingFile)"
            }
        }
    Process
    {
        $ErrorActionPreference = "Stop"
        Try
        {
            Add-Type -Path $SystemPrintingFile
            $PrintServer = New-Object System.Printing.PrintServer("\\$($ComputerName)")
            $PrintQueue = $PrintServer.GetPrintQueue($Name)
            $PrintJobs = $PrintQueue.GetPrintJobInfoCollection()
            }
        Catch
        {
            Write-Error $Error[0].Exception
            Break
            }
        }
    End
    {
        Return $PrintJobs
        }
    }