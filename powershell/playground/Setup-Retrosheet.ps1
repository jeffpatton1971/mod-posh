<#
    Setup Retrosheet folder structure and grab chadwick files
    from 
#>
try
    {
    $ChadwickUrl = 'http://softlayer-dal.dl.sourceforge.net/project/chadwick/chadwick-0.6/chadwick-0.6.4/chadwick-0.6.4.zip'
    $7zipPath = 'C:\Program Files\7-Zip\7z.exe'

    New-Item C:\Retrosheet -ItemType Directory
    New-Item C:\Retrosheet\Common -ItemType Directory
    New-Item C:\Retrosheet\Common\PowerShell -ItemType Directory
    New-Item C:\Retrosheet\Common\Programs -ItemType Directory
    New-Item C:\Retrosheet\Common\Reports -ItemType Directory
    New-Item C:\Retrosheet\Common\SQL -ItemType Directory
    New-Item C:\Retrosheet\Common\Utilities -ItemType Directory
    New-Item C:\Retrosheet\Data -ItemType Directory
    New-Item C:\Retrosheet\Data\Parsed -ItemType Directory
    New-Item C:\Retrosheet\Data\Parsed\Games -ItemType Directory
    New-Item C:\Retrosheet\Data\Parsed\Subs -ItemType Directory
    New-Item C:\Retrosheet\Data\Parsed\Events -ItemType Directory
    New-Item C:\Retrosheet\Data\UnZipped -ItemType Directory
    New-Item C:\Retrosheet\Data\Zipped -ItemType Directory
    New-Item C:\Retrosheet\DBMS -ItemType Directory
    New-Item C:\Retrosheet\DBMS\Azure -ItemType Directory

    Invoke-WebRequest -Uri $ChadwickUrl -OutFile C:\Retrosheet\Common\Programs\chadwick.zip
    Invoke-Expression -Command "& '$($7zipPath)' e C:\Retrosheet\Common\Programs\chadwick.zip -y -oC:\Retrosheet\Common\Programs";
    Invoke-WebRequest -Uri https://raw.githubusercontent.com/jeffpatton1971/mod-posh/master/powershell/production/includes/RsModule.psm1 -OutFile C:\Retrosheet\Common\PowerShell\RsModule.psm1
    Invoke-WebRequest -Uri https://raw.githubusercontent.com/jeffpatton1971/mod-posh/master/powershell/playground/Start-RSDataProcessing.ps1 -OutFile C:\Retrosheet\Common\PowerShell\Start-RSDataProcessing.ps1
    Invoke-WebRequest -Uri https://gist.githubusercontent.com/jeffpatton1971/ee2ed12189506ccae173/raw/d84e3d016f4327a80326c15839e7825d99b23362/retrosheet_zip_files.TXT -OutFile C:\Retrosheet\Data\Zipped\retrosheet_zip_files.TXT

    $Global:RSPath = 'C:\Retrosheet';
    $Global:RSDataPath = "$($Global:RSPath)\Data";
    Write-Host "Launch C:\Retrosheet\Common\PowerShell\Start-RSDataProcessing.ps1 to begin setting up RetroSheet datafiles."
    }
catch
{
    throw $Error[0]
    }