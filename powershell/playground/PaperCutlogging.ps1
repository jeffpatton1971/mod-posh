#	Read in papercut log file minus line 1
$plog = Get-Content .\papercut-print-log-2011-04-03.csv | Select-Object -Skip 1

#	Create a temp log file to use for import-csv
Set-Content -path 'C:\Users\Jeff Patton\Desktop\temp.csv' -Value $plog

#	Parse the temp log into variable
$plog = Import-Csv .\temp.csv

#	Display top print users
$plog |Group-Object User |Sort-Object Count -Descending

#	Display top printers
$plog |Group-Object Printer |Sort-Object Count -Descending

