#
#	Sharepoint Site Creation Script
#	
#	March 8, 2011: Jeff Patton
#	
#	This script works against WSS 3.0 and creates a new site
#	in a new content database. It checks if the site to be
#	created exists before creating the new site.
#
$ScriptName = $MyInvocation.MyCommand.ToString()
$LogName = "Application"
$ScriptPath = $MyInvocation.MyCommand.Path
$Username = $env:USERDOMAIN + "\" + $env:USERNAME

	New-EventLog -Source $ScriptName -LogName $LogName -ErrorAction SilentlyContinue
	
	$Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nStarted: " + (Get-Date).toString()
	Write-EventLog -LogName $LogName -Source $ScriptName -EventID "100" -EntryType "Information" -Message $Message 

	#	Dotsource in the AD functions I need
	. .\includes\SharePointManagement.ps1
	
	#	Ask for new site URL
	$RootUrl = Read-Host "Please enter the FQDN of the Sharepoint server:"
	$SitePath = Read-Host "Please enter the path to the site you wish to create:"
	
	#	Check if that site already exists
	$SP3Sites = [xml](Get-Sharepoint3Sites $RootURL)
	if (($SP3sites.Sites.Site | where-object{$_.Url -eq $RootUrl +"/"+ $SitePath-}) -eq $null)
		{
			#	Create new site
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

	$Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
	Write-EventLog -LogName $LogName -Source $ScriptName -EventID "100" -EntryType "Information" -Message $Message	