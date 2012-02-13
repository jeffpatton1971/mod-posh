<#
    .SYNOPSIS
        Create a new SharePoint site within a new SQL DB
    .DESCRIPTION
        Created March 8, 2011: Jeff Patton
        This script creates a new SharePoint site within a new SQL DB. It relies on several functions inside the 
        SharePointManagement.ps1 library to work properly. You will need to provide the base URL of your SharePoint 
        installation as well as the path to the new site to be created.
    .PARAMETER RootURL
        This is the base URL of your WSS 3.0 installation
    .PARAMETER SitePath
        This is the path to your new WSS 3.0 site
    .EXAMPLE
        create-site http://intranet.company.com team
    .NOTES
        Run script from Sharepoint server
        Run script as Administrator or disable UAC
        Script needs to be run under a SharePoint Farm Administrator account
    .LINK
        https://code.google.com/p/mod-posh/wiki/create-site
#>
[cmdletBinding()]
Param
    (
    [Parameter(Mandatory=$true)]
    [string]$RootURL,
    [Parameter(Mandatory=$true)]
    [string]$SitePath
    )
Begin
{
    $ScriptName = $MyInvocation.MyCommand.ToString()
    $LogName = "Application"
    $ScriptPath = $MyInvocation.MyCommand.Path
    $Username = $env:USERDOMAIN + "\" + $env:USERNAME

    New-EventLog -Source $ScriptName -LogName $LogName -ErrorAction SilentlyContinue

    $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nStarted: " + (Get-Date).toString()
    Write-EventLog -LogName $LogName -Source $ScriptName -EventID "100" -EntryType "Information" -Message $Message 

    #    Dotsource in the SharePoint functions I need
    . .\includes\SharePointManagement.ps1
    }
Process
{
    #    Check if that site already exists
    $SP3Sites = [xml](Get-Sharepoint3Sites $RootURL)
    if (($SP3sites.Sites.Site | where-object{$_.Url -eq $RootUrl +"/"+ $SitePath-}) -eq $null)
    {
        #    Create new site
        $databasename = Read-Host "Please enter DB Name"
        $ownerlogin = Read-Host "Please enter the username of the site owner"
        $owneremail = Read-Host "Please enter email address of the owner"
        $title = Read-Host "Please enter the title of the site"
        New-Sharepoint3Site $RootUrl +"/"+ $SitePath $ownerlogin $owneremail $title $databasename
        }
    else
    {
        Write-Host "Site " + $RootURL +"/"+ $SitePath + " already exists."
        }
    }
End
{
    $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
    Write-EventLog -LogName $LogName -Source $ScriptName -EventID "100" -EntryType "Information" -Message $Message
    }