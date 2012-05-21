<#
    .SYNOPSIS
        Update the DPM Volume Sizing spreadsheet with current values
    .DESCRIPTION
        This script updates the DPM Volume Sizing spreadsheet in a given
        location with current values from one or more remote computers. The
        spreadsheet, which is available from the Microsoft website 
        (see RELATED LINKS), allows you to calculate the size of your Replica
        Volume and your Recovery Point Volume based on the amount of used space
        on a given data source.
        
        This script will create a session object and remotely connect to one or
        more computers. It will then execute a scriptblock which uses Get-PSDrive
        to return the Name and Used space of a given volume. Then for each 
        volume it will update the appropriate column in the spreadsheet with 
        the new used space of that disk.
    .PARAMETER ComputerName
        This is an array of one or more computers that are protected by
        your DPM server.
    .PARAMETER SharedDrives
        This is an array of drive letters that host shares that are 
        protected by your DPM server.
    .PARAMETER FileName
        This is the full path and filename to where you have extracted the 
        DPM Volume Sizing tool.
    .PARAMETER WorkSheetName
        As of v3.3 WorkSheetName for file servers is
            DPM File Volume 
    .PARAMETER VolumeIDColumn
        As of v3.3 VolumeIDColumn is Column
            D:D
    .PARAMETER TargetColumn
        As of v3.3 TargetColumn is the Used space in GB
            E
    .EXAMPLE
        .\Update-DPMSpreadSheet.ps1
        
        Description
        -----------
        This is the basic syntax of the command
    .EXAMPLE
        .\Update-DPMSpreadSheet.ps1 -ComputerName 'fs1.company.com','fs2.company.com' -SharedDrives 'G','W','U' -FileName 'c:\dpm\DPMvolumeSizing.xlsx'
        
        Description
        -----------
        This example shows the most common usage of this command. It will connect to fs1 and fs2
        and update the spreadsheet in the C:\DPM folder with the appropriate values.
    .NOTES
        ScriptName : Update-DPMSpreadSheet.ps1
        Created By : jspatton
        Date Coded : 04/10/2012 11:27:08
        ScriptName is used to register events for this script
        LogName is used to determine which classic log to write to
 
        ErrorCodes
            100 = Success
            101 = Error
            102 = Warning
            104 = Information
        
        I make the assumption that you have already downloaded the tool and added the appropriate
        drive letters to the Volume Identification column. If not, you may get some odd results.
        
        Remember there is a max of 5 concurrent sessions via WS-MAN for a given account. If you
        reached that number you will need to update the max. Please see the RELATED LINKS
        for the technet blog article discussing this limit.
    .LINK
        https://code.google.com/p/mod-posh/wiki/Production/Update-DPMSpreadSheet
    .LINK
        http://blogs.technet.com/b/dpm/archive/2010/09/02/new-dpm2010-storage-calculator-links-sep-2010.aspx
    .LINK
        http://blogs.msdn.com/b/powershell/archive/2010/05/03/configuring-wsman-limits.aspx
#>
[CmdletBinding()]
Param
    (
    $ComputerName = @('people.soecs.ku.edu','fs.soecs.ku.edu'),
    $SharedDrives = @('L','P','R','S','W','Y','H','I','J','K','L','M','N','O','Q','T','U','V'),
    $FileName = 'C:\Users\jspatton\SyncStuff\DPMvolumeSizing v3.3\DPMvolumeSizing.xlsx',
    $WorkSheetName = 'DPM File Volume',
    $VolumeIDColumn = 'D:D',
    $TargetColumn = 'E'
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
        Write-Verbose "Does $($FileName) exist?"
        if ((Test-Path -Path $FileName) -ne $true)
        {
            $Message = "The path specified is invalid. $($FileName)"
            Write-Verbose $Message
            Write-EventLog -LogName $LogName -Source $ScriptName -EventID "101" -EntryType "Error" -Message $Message
            break
            }
        }
Process
    {
        $Drives = @()
        try
        {
            foreach ($Computer in $ComputerName)
            {
                Write-Verbose "Get a listing of all local disks from the server"
                $Drives += Get-WmiObject -Class Win32_LogicalDisk -ComputerName $Computer -Credential $Credentials -Filter "DriveType = 3"
                }
            }
        catch
        {
            $Message = $Error[0]
            Write-Verbose $Message
            Write-EventLog -LogName $LogName -Source $ScriptName -EventID "101" -EntryType "Error" -Message $Message
            }
        try
        {
            Write-Verbose "Create an Excel instance"
            $Excel = New-Object -ComObject Excel.Application
            Write-Verbose "Open the $($FileName) spreadsheet"
            $Excel.Workbooks.Open($FileName) |Out-Null
            Write-Verbose "Open the $($WorkSheetName) worksheet"
            $WorkSheet = $Excel.Worksheets.Item($WorkSheetName)
            Write-Verbose "Select column $($VolumeIDColumn), the Volume Identification column"
            $Range = $WorkSheet.Range($VolumeIDColumn)
            
            foreach ($SharedDrive in $SharedDrives)
            {
                Write-Verbose "Find $($SharedDrive) in $($VolumeIDColumn)"
                $Target = $Range.Find($SharedDrive)
                Write-Verbose "Found $($SharedDrive) at $($Target.AddressLocal($true,$true,$true))"
                Write-Verbose "Get the used space for $($SharedDrive)"
                $Used = $Drives |Where-Object {$_.DeviceID -eq "$($SharedDrive):"}
                if ($Used.Count)
                {
                    $Used = $Used[0]
                    }
                $UsedSpace = ($Used.Size - $Used.FreeSapce)
                Write-Verbose "$($SharedDrive): $($UsedSpace/1gb)GB Used"
                $TargetReference = "$($TargetColumn)$($Target.Row)"
                Write-Verbose "Updating $($TargetReference) with value $($UsedSpace/1gb)"
                $WorkSheet.Range($TargetReference).Value2 = $UsedSpace/1gb
                Write-Verbose "Updated"
                }
            $Excel.DisplayAlerts = $false
            Write-Verbose "Saving $($FileName)"
            $Excel.Save()
            Write-Verbose "Closing $($WorkSheetName)"
            $Excel.Workbooks.Close()
            Write-Verbose "Exit Excel"
            $Excel.Application.Quit()
            }
        catch
        {
            $Message = $Error[0]
            Write-Verbose $Message
            Write-EventLog -LogName $LogName -Source $ScriptName -EventID "101" -EntryType "Error" -Message $Message
            break
            }
        }
End
    {
        [void][System.Runtime.Interopservices.Marshal]::FinalReleaseComObject($Target)
        [void][System.Runtime.Interopservices.Marshal]::FinalReleaseComObject($Range)
        [void][System.Runtime.Interopservices.Marshal]::FinalReleaseComObject($Worksheet)
        [void][System.Runtime.Interopservices.Marshal]::FinalReleaseComObject($Excel)
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName $LogName -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message	
        }