try
{
    $eaPref = $ErrorActionPreference;
    $ErrorActionPreference = "Stop";
    $Error.Clear();
    $Global:WebClient = New-Object System.Net.WebClient;
    $ErrorActionPreference = $eaPref;
    }
catch
{
    Write-Error $Error[0];
    }
Function Get-WebFile
{
    <#
        .SYNOPSIS
            Something similar to wget
        .DESCRIPTION
            This function allows you to retrieve a file from a website
        .PARAMETER Address
        .PARAMETER FileName
        .PARAMETER Force
        .EXAMPLE
        .NOTES
            FunctionName : Get-WebFile
            Created by   : jspatton
            Date Coded   : 02/27/2015 09:05:03
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/WebClient#Get-WebFile
    #>
    [CmdletBinding()]
    Param
        (
        [Parameter(Mandatory=$true,ValueFromPipeline=$True,Position=1)]
        [string]$Address,
        [string]$FileName,
        [switch]$Force
        )
    Begin
    {
        try
        {
            $ErrorActionPreference = "Stop";
            $Error.Clear();
            Write-Verbose "Getting the local path";
            $FilePath = Get-Item -Path .\;
            Write-Verbose "Creating a URI object from $($Address)";
            [System.Uri]$Uri = New-Object System.Uri $Address;
            if (!($FileName))
            {
                Write-Verbose "Get filename from the url";
                $FileName = $Uri.Segments[$Uri.Segments.Count -1];
                }
            Write-Verbose "Filename : $($FileName)";
            $DownloadFile = "$($FilePath.FullName)\$($FileName)";
            }
        catch
        {
            $Error[0];
            break;
            }
        }
    Process
    {
        try
        {
            $ErrorActionPreference = "Stop";
            $Error.Clear();
            Write-Verbose "Using the webclient to download file : $($FileName)";
            if ($Force)
            {
                $Global:WebClient.DownloadFile($Uri, $DownloadFile);
                }
            else
            {
                if ((Test-Path $DownloadFile))
                {
                    throw "File exists";
                    }
                }
            }
        catch
        {
            $Error[0];
            break;
            }
        }
    End
    {
        Get-Item $DownloadFile;
        }
    }

Export-ModuleMember -Function Get-WebFile