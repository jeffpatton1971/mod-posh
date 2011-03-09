#
#	Sharepoint Site Creation Script
#	
#	March 8, 2011: Jeff Patton
#	
#	This script works against WSS 3.0 and creates a new site
#	in a new content database. It's really rather simple at
#	the moment, but it gets the job done.
#

$sitetemplate = "STS#0"

$url = Read-Host "Please enter desired URL"
$databasename = Read-Host "Please enter DB Name" 
$ownerlogin = Read-Host "Please enter the username of the site owner"
$owneremail = $ownerlogin + "@ku.edu"
$title = Read-Host "Please enter the title of the site"

stsadm -o createsiteinnewdb `
	-url "$url" `
	-owneremail "$owneremail" `
	-ownerlogin "$ownerlogin" `
	-sitetemplate "$sitetemplate" `
	-title "$title" `
	-databasename "$databasename"
	
iisreset