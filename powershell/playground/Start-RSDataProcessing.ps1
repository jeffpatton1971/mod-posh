<#
http://www.techgraphs.com/building-a-retrosheet-database-part-1/
http://www.techgraphs.com/building-a-retrosheet-database-part-2/

#>
[CmdletBinding()]
Param
(
)
Begin
{
    Import-Module C:\retrosheet\common\powershell\RsModule.psm1;
    Get-RSDataFiles;
    }
Process
{
    $DataFiles = Get-ChildItem C:\retrosheet\data\unzipped -Filter "*.ev*";
    Set-Location C:\retrosheet\data\unzipped;
    foreach ($DataFile in $DataFiles |ForEach-Object {$_.Name.Substring(0,4)} |Sort-Object -Unique)
    {
        $Year = $DataFile;
        $FileFilter = "$($DataFile)*.ev*";
        Get-RSEvent -Year $Year -File $FileFilter -Verbose |Out-File "C:\Retrosheet\data\parsed\events\$($Year).csv";
        Get-RSGame -Year $Year -File $FileFilter -Verbose |Out-File "C:\Retrosheet\data\parsed\games\$($Year).csv";
        Get-RSSub -Year $Year -File $FileFilter -Verbose |Out-File "C:\Retrosheet\data\parsed\subs\$($Year).csv";
        }
    }
End
{
    }