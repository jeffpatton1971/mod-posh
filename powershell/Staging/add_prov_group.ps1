Get-QADUser -DontUseDefaultIncludedProperties -SizeLimit 10000 -homeDirectory '*' -ObjectAttributes @{extensionattribute15='1'} |
add-QADGroupMember -identity 'CN=Provision-DL-Test2,OU=Filers,OU=Information Technology,DC=home,DC=ku,DC=edu'|
Select-Object name, 'msDS-ReplAttributeMetaData',homeDirectory,extensionattribute15 | export-csv C:\_Scripts\Reports\add_group.csv