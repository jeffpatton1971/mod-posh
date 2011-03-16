Function New-Sharepoint3Site
	{
		<#
			.SYNOPSIS
				Creates a new WSS 3.0 site inside a new SQL database
			.DESCRIPTION
				This function creats a new WSS 3.0 site inside a newly created
				database. 
			.PARAMETER sitetemplate
				This parameter has a default setting of STS#0 which is the basic 
				team template. You can specify previously installed themes or
				additional pre-built themes on the site. 
				Here is the list of built-in themes:
					http://technet.microsoft.com/en-us/library/cc262594(office.12).aspx
			.PARAMETER url
				This is the FQDN of your sharepoint installation.
			.PARAMETER databasename
				This parameter is the name of the database you wish to hold the
				new site. If you have a database name policy you should follow
				that here.
			.PARAMETER ownerlogin
				This parameter needs the Domain credentials of the user who will
				own this site intially.
			.PARAMETER owneremail
				This is the email address that corresponds to the ownerlogin parameter.
			.PARAMETER title
				This will be the title of the site that will be displayed in
				the browser title bar.
			.EXAMPLE
				new-sharepoint3site https://intranet.company.com/team administrator administrator@company.com "Company Team Site" WSS_CompanyIntranet
			.EXAMPLE
				new-sharepoint3site STS#2 https://intranet.company.com/documents administrator administrator@company.com "Company Dodcument Site" WSS_CompanyDocument
			.NOTES
				You will need to be running this under the Sharepoint Farm administrators context.
				This script will need to run on the server that is hosting the SharePoint admin site.
				The STSADM command needs to be on your path, or run the script from inside the folder
				where STSADM is located.
				You will need to have a managed path setup in advance.
				If the site already exists the script will error out.
			.LINK
				http://scripts.patton-tech.com/wiki/PowerShell/SharePoint
		#>
		
		Param
			(
				[string]$sitetemplate = "STS#0", 
				[Parameter(Mandatory=$true)]
				[string]$url, 
				[Parameter(Mandatory=$true)]
				[string]$ownerlogin, 
				[Parameter(Mandatory=$true)]
				[string]$owneremail, 
				[Parameter(Mandatory=$true)]
				[string]$title,
				[Parameter(Mandatory=$true)]
				[string]$databasename
			)
			
		stsadm -o createsiteinnewdb `
			-url "$url" `
			-owneremail "$owneremail" `
			-ownerlogin "$ownerlogin" `
			-sitetemplate "$sitetemplate" `
			-title "$title" `
			-databasename "$databasename"
			
		iisreset
	}
Function Get-Sharepoint3Sites
	{
	<#
		.SYNOPSIS
			List sites on Sharepoint Server
		.DESCRIPTION
			List the number of existing sites on Windows Sharepoint Services 
			web server.
		.PARAMETER RootURL
			This is the base URL of your Sharepoint installation
		.EXAMPLE
			Get-Sharepoint3Site http://intranet.company.com
		.Example
			$sites = [xml](Get-Sharepoint3Sites)
			$sites.Sites.Site[3].Url
		.NOTES
			The STSADM command needs to be on your path, or run the script from inside the folder
			The information returned is in the form of an XML file, you will
			need to [xml] cast a variable in order to metriculate through it.
		.LINK
			http://scripts.patton-tech.com/wiki/PowerShell/SharePoint
	#>
	
	Param
		(
			[Parameter(Mandatory=$true)]
			[string]$RootURL
		)
		
		stsadm -o enumsites -url $RootURL
	}
Function New-Sharepoint3Path
	{
		<#
			.SYNOPSIS
				Creates a managed path on the Sharepoint Server.
			.DESCRIPTION
				Creates a wild card managed path on the Sharepoint Server.
			.PARAMETER RootURL
				This is the root url of the Windows Sharepoint Services web server
			.PARAMETER SitePath
				This is the path to the new site from the RootURL
			.EXAMPLE
				new-sharepoint3path http://intranet.company.com /documents/team-docs
			.NOTES
				The STSADM command needs to be on your path, or run the script from inside the folder
			.LINK
				http://scripts.patton-tech.com/wiki/PowerShell/SharePoint
		#>
		
		Param
			(
			[Parameter(Mandatory=$true)]
			[string]$RootURL, 
			[Parameter(Mandatory=$true)]
			[string]$SitePath
			)
			
		stsadm -o addpath -url $RootURL + "/" + $SitePath -type wildcardinclusion
	}