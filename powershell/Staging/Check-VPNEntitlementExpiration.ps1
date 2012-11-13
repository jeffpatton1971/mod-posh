#Check-VPNEntitlementExpiration
#Saved at: C:\_Scripts\Check-VPNEntitlementExpiration.ps1
#Version 1.000
#Last Modified 2012-April-10

#Version Tracking
#1.000 Initial Release

# ExtensionAttribute2 contains the VPN group entitlement for users.
# ExtensionAttribute3 contains the expiration date for the entitlement in the form yyyy-mm-dd.HH:mm:ss

#Find everyone with an entitlement group set
Get-QADUser -SizeLimit 0 -DontUseDefaultIncludedProperties -IncludedProperties extensionAttribute2,extensionAttribute3 -LdapFilter "(&(objectClass=User)(extensionAttribute2=*))" | ForEach-Object { 
#Check to see if an expiration date exists. All valid entitlements must have an expiration date
	if ($_.extensionAttribute3) {
		$expire = $_.extensionAttribute3
		if ((get-date -Date $expire) -lt (get-date)) { 
			Set-QADUser -Identity $_ -ObjectAttributes @{extensionAttribute2=''}
		}
	}
#Remove invalid entitlements that do not have an expiration date.
	else {
		Set-QADUser -Identity $_ -ObjectAttributes @{extensionAttribute2=''}
	}
}