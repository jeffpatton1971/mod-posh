$Users = foreach ($Item in (Get-WinEvent -FilterHashtable @{Logname='System';ID=14} )){$Item.Properties[1]} 
$Users |Sort-Object -Property Value -Unique