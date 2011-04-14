Function Open-FileInExcel
    {
        <#
            .SYNOPSIS
                Opens a file in Excel
            .DESCRIPTION
                This function opens a file in Excel.
            .PARAMETER FileName
                The full path and filename of the file to open
            .EXAMPLE
                Open-FileInExcel -FileName C:\TEMP\filestats.csv
        #>
        
        Param
            (
                [Parameter(Mandatory=$true)]
                [string]$FileName
            )

        Try
            {
                $Excel = New-Object -ComObject Excel.Application
                $Excel.Workbooks.Open($FileName)
                $Excel.Visible = $true
            }
        Catch
            {
                Write-Host "Error opening Excel"
            }
    }

Function Get-JustFiles
    {
        <#
            .SYNOPSIS
                Get a list of files from a directory.
            .DESCRIPTION
                This function returns a list of files from the specified directory and stores them in a csv.
            .PARAMETER FileName
                The full path and filename of the csv 
            .PARAMETER Target
                The full path to the directory to search
            .EXAMPLE
                Get-JustFiles -Target C:\TEMP -FileName C:\TEMP\temp.csv
        #>
        
        Param
            (
                [Parameter(Mandatory=$true)]
                [string]$Target,
                [Parameter(Mandatory=$true)]
                [string]$FileName
            )

        Return Get-ChildItem -Path $Target |Where-Object {!$_.PSIsContainer} `
            |Select-Object -Property Name, Length, LastWriteTime `
            |Export-Csv -Path $Filename -NoTypeInformation -UseCulture
    }

Function New-FileReport
    {
        <#
            .SYNOPSIS
                Open the filereport in Excel
            .DESCRIPTION
                This function uses Get-JustFiles and Open-FileInExcel to get the Name, Length and LastWriteTime of a
                collection of files from the specified directory.
            .PARAMETER FileName
                The name of the csv file to create, this is passed to Open-FileInExcel and Get-JustFiles
            .PARAMETER Target
                The name of the folder to search, this is passed to Get-JustFiles
            .EXAMPLE
                New-FileReport -Target C:\TEMP -FileName C:\TEMP\temp.csv
            .NOTES
                You are concerned with the shrinking amount of free disk space on your computer. After some preliminary 
                work, you have narrowed down the problem to one particular folder. You decide to obtain a listing of all
                the files in the folder, and write the information from the directory listing to a comma-separated value
                (CSV) file so that you can open the CSV file in a Microsoft Excel spreadsheet for further analysis.
            .LINK
                https://2011sg.poshcode.org/1160
        #>
        
        Param
            (
                [Parameter(Mandatory=$true)]
                [string]$Target,
                [Parameter(Mandatory=$true)]
                [string]$FileName
            )

        Get-JustFiles -Target $Target -FileName $FileName
        Open-FileInExcel -FileName (Get-ChildItem $FileName).FullName
    }