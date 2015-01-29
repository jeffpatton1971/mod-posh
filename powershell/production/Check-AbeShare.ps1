<#
.SYNOPSIS
    This script will check if there are any pitfalls to ABE on a given share
.DESCRIPTION
    Run this script to get a CSV file that lists the UNC paths of folders 
    which have Read rights denied for a user or group and that have a child 
    folder down its tree that has read rights allowed and inheritance broken. 
    Access errors are also listed in a CSV file.
.PARAMETER CsvFile
    A csv with one sharename per line
.EXAMPLE
    .\Check-AbeShare.ps1 -CsvFile .\shares.csv -OutPath C:\Temp
.NOTES
    ScriptName : Check-AbeShare.ps1
    Created By : jspatton
    Date Coded : 01/27/2015 14:35:04

    This script was originally written by Kris Dover
.LINK
    https://gist.github.com/jeffpatton1971/4eb9a9c9dccdec390bfc
#>
[CmdletBinding()]
Param
(
[string]$CsvFile,
[string]$OutPath
)
Begin
{
    Function Recurse-Path
    {
        [CmdletBinding()]
        Param
        (
        [string]$Path
        )
        begin
        {
            try
            {
                Write-Verbose "Get the Access Control List for $($Path)"
                $Acl = Get-Acl -Path $Path
                Write-Verbose "Check if Deny Read or Deny Full is set"
                $DenyFull = $Acl.Access |Where-Object {
                                         (($_.AccessControlType -eq "Deny") -and 
                                         ($_.FileSystemRights -like '*Read*'-or '*full*'))}
                }
            catch
            {
                }
            }
        process
        {
            try
            {
                Write-Verbose "Get a list of files inside $($Path)"
                $Files = Get-ChildItem -Path $Path
                foreach ($File in $Files)
                {
                    $Type = $File.GetType().FullName
                    switch ($Type)
                    {
                        'System.IO.DirectoryInfo'
                        {
                            Write-Verbose $File.FullName
                            Write-Verbose "Get the Access Control List for $($File.FullName)"
                            $Acl = Get-Acl -Path $File.FullName
                            if ($DenyFull)
                            {
                                Write-Verbose "Deny Read and Deny Full exist"
                                Write-Verbose "Check if isinherited is false, access is allow and rights are read or full"
                                $IsInherited = $Acl.Access |Where-Object {
                                                            ($_.IsInherited -eq $false) -and 
                                                            (($_.AccessControlType -eq "Allow") -and 
                                                            ($_.FileSystemRights -like '*Read*'-or '*full*'))}
                                if ($IsInherited)
                                {
                                    Write-Verbose "This path could break ABE"
                                    #
                                    # Silly test, but it appears sometimes we kick out files depending on ErrorActionPrefernce
                                    #
                                    if ($File.GetType().FullName -eq 'System.IO.DirectoryInfo')
                                    {
                                        $File
                                        }
                                    }
                                }
                            Write-Verbose "Walk the tree"
                            Recurse-Path -Path $File.FullName
                            }
                        }
                    }
                }
            catch
            {
                }
            }
        end
        {
            }
        }
    }
Process
{
    $Shares = Import-Csv -Path $csvFile -Header "SharePath"
    foreach ($Share in $Shares)
    {
        $TestUnc = $Share.SharePath.Substring(0,2)
        if (!($TestUnc -eq "\\"))
        {
            $SharePath = "\\$($Share.SharePath)"
            }
        else
        {
            $SharePath = $Share.SharePath
            }
        New-PSDrive -Name "Y" -PSProvider FileSystem -Root $SharePath
        $Directories = Recurse-Path -Path Y: -ErrorAction SilentlyContinue -ErrorVariable InvalidEntries
        $csvFileName = $SharePath.Replace("\","").Replace(".","_") + ".csv"
        $Directories |Select-Object -Property FullName |Out-File "$($OutPath)\$($csvFileName)"
        $errFileName = ($SharePath.Replace("\","").Replace(".","_")) + ".ERROR"
        foreach ($InvalidEntry in $InvalidEntries)
        {
            $CategoryInfo = $InvalidEntry.CategoryInfo
            if ($CategoryInfo.Activity -eq "Get-Acl")
            {
                $CategoryInfo = New-Object -TypeName psobject -Property @{
                    Category = $InvalidEntry.FullyQualifiedErrorId
                    Activity = $InvalidEntry.CategoryInfo.Activity
                    Reason = $InvalidEntry.CategoryInfo.Reason
                    TargetName = $InvalidEntry.CategoryInfo.TargetName
                    TargetType = $InvalidEntry.Exception.Message
                    }
                }
            $CategoryInfo |Select-Object -Property Category, Activity, Reason, TargetName, TargetType |Out-File "$($OutPath)\$($errFileName)" -Append
            }
        Remove-PSDrive -Name "Y"
        }
    }
End
{
    }