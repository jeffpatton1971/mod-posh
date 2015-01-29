<#
.SYNOPSIS
    Use this script to download the Bing background image.
.DESCRIPTION
    This script can be used to download Bing background images for use
    as your wallpaper or to save. It uses a specially crafted URL that I
    found while searching for a way to download them.

    It appears that the URL will let you go back 18 days, or the last 8
    images. When you set Index to 18 and NumberOfImages to 8 a total of
    19 images will be downloaded.
.PARAMETER DownloadPath
    This is the path to download the files to
.PARAMETER Market
    Which of the eight markets Bing is available for you would like images 
    from. The valid values are: en-US, zh-CN, ja-JP, en-AU, en-UK, de-DE, 
    en-NZ, en-CA.
.PARAMETER Index
    Where you want to start from. 0 would start at the current day, 1 the 
    previous day, 2 the day after that.
.PARAMETER NumberOfImages
    How many images to return. n = 1 would return only one, n = 2 would 
    return two, and so on.
.PARAMETER Resolution
    You will need to know the proper resolution and it needs to be in this format
        1366x768
        1920x1080
    If it's wrong it will most likely fail.
.EXAMPLE
    .\Get-BingImage.ps1 -DownloadPath C:\TEMP\BingImages -Market en-US -Index 0 -NumberOfImages 1


    startdate     : 20150102
    fullstartdate : 201501020000
    enddate       : 20150103
    url           : /az/hprichbg/rb/PiscataquaRiver_EN-US4164763935_1366x768.jpg
    urlBase       : /az/hprichbg/rb/PiscataquaRiver_EN-US4164763935
    copyright     : Piscataqua River, Portsmouth, New Hampshire (Â© Denis Tangney Jr./Getty Images)
    copyrightlink : http://www.bing.com/search?q=Piscataqua+River&form=hpcapt&filters=HpDate:%2220150102_0800%22
    drk           : 1
    top           : 1
    bot           : 1
    hotspots      : hotspots
    messages      : 

    Description
    -----------
    Get today's Bing Background image and download it to C:\TEMP\Bingimages
.EXAMPLE
    .\Get-BingImage.ps1 -Market en-US -Index 18 -NumberOfImages 8 -Resolution 1920x1080

    startdate     : 20150111
    fullstartdate : 201501110000
    enddate       : 20150112
    url           : /az/hprichbg/rb/SmooCave_EN-US10358472670_1366x768.jpg
    urlBase       : /az/hprichbg/rb/SmooCave_EN-US10358472670
    copyright     : Smoo Cave in Durness, Scotland (© GS/Gallery Stock)
    copyrightlink : http://www.bing.com/search?q=Smoo+Cave&form=hpcapt&filters=HpDate:%2220150111_0800%22
    drk           : 1
    top           : 1
    bot           : 1
    hotspots      : hotspots
    messages      : 

    Description
    -----------
    This sample shows how to get a higher resolution image using the Resolution param.
.NOTES
    ScriptName : Get-BingImage.ps1
    Created By : Jeffrey
    Date Coded : 01/02/2015 11:48:12

    If you would like to set those images as wallpapers via PowerShell I've
    included a link 
.LINK
    https://gist.github.com/jeffpatton1971/437b8487ae7e69ba4d27
.LINK
    http://www.codeproject.com/Articles/151937/Bing-Image-Download
.LINK
    https://gist.github.com/jeffpatton1971/bb3ea6fb3d5042286d5b
#>
[CmdletBinding()]
Param
(
    [ValidateScript({Test-Path $_ -PathType 'Container'})]
    [string]$DownloadPath = "C:\TEMP\BingImages",
    [ValidateSet("en-US","zh-CN","ja-JP","en-AU","en-UK","de-DE","en-NZ","en-CA")]
    [string]$Market,
    [ValidateRange(0,18)]
    [int]$Index,
    [ValidateRange(1,8)]
    [int]$NumberOfImages,
    [string]$Resolution
)
Begin
{
    try
    {
        [string]$BingUrl = "http://www.bing.com"
        Write-Debug "Setting Bing URL to : $($BingUrl)";
        [string]$QueryString = "&idx=$($Index)&n=$($NumberOfImages)&mkt=$($Market)";
        Write-Debug "Setting QueryString to : $($QueryString)";
        [string]$ImageUrl = "$($BingUrl)/HPImageArchive.aspx?format=xml$($QueryString)";
        Write-Debug "Setting ImageUrl to : $($ImageUrl)";
        }
    catch
    {
        Write-Error $Error[0].Exception
        break
        }
    }
Process
{
    try
    {
        $Request = Invoke-WebRequest -Uri $ImageUrl;
        Write-Verbose "Executing : Invoke-WebRequest -Uri $($ImageUrl)"
        [xml]$ResponseContent = $Request.Content;
        Write-Verbose "Accessing content";
        Write-Debug $Request.Content;
        foreach ($ImageData in $ResponseContent.images.image)
        {
            if ($Resolution)
            {
                [System.Uri]$DownloadUri = New-Object System.Uri "$($BingUrl)$($ImageData.urlBase)_$($Resolution).jpg";
                }
            else
            {
                [System.Uri]$DownloadUri = New-Object System.Uri "$($BingUrl)$($ImageData.url)";
                }
            $ImageFileName = $DownloadUri.Segments[$DownloadUri.Segments.Count -1];
            $ImageFileName = "$($ImageFileName.Split("_")[0])_$($ImageData.startdate)_$($Market)_$($ImageFileName.Split("_")[$ImageFileName.Split("_").Count -1])";
            Invoke-WebRequest -Uri $DownloadUri -OutFile "$($DownloadPath)\$($ImageFileName)";
            Write-Verbose (Get-Item "$($DownloadPath)\$($ImageFileName)");
            $ImageData
            }
        }
    catch
    {
        Write-Error $Error[0].Exception
        break
        }
    }
End
{
    }