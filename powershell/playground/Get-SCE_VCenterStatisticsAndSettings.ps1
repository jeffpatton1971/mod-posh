<# 	   .SYNOPSIS
        Collects statistics and settings for Hosts, Datastores, and Virtual Machines
		from multiple VCenters.
	   .DESCRIPTION
		Creates Excel spreadsheet report with separate worksheets for Hosts, Datastores, and 
		Virtual Machines by VCenter.
       .PARAMETER
		none
       .INPUTS
	   .OUTPUTS
	   .NOTES
        Name: Get-SCE_VCenterStatisticsAndSettings.ps1
        Author: Steve Jarvi
        DateCreated: 10 Jan 2013
	   .EXAMPLE
    #>




#Load PowerCLI snap-ins
Add-PSSnapin Vmware.VIMAutomation.Core

Write-Host "Getting first and last days of previous months..."
#Get the first and last days for the previous months.
$startdate = (($currentdate = get-date).addmonths(-1) | % {$_.AddDays(-($_.day -1))}).ToString("d")
$enddate = (($currentdate = get-date) | % {$_.adddays(-($_.day))}).ToString("d")

Write-Host "Start date is $startdate."
Write-Host "End date is $enddate."

#VCenters list:
$VCenters = "vmclst-vc.home.ku.edu"


#New Excel ComObject, add workbook:
$excel = New-Object -ComObject Excel.Application
$excel.Visible = $true
$workbook = $excel.Workbooks.Add()


	#Loop through VCenters.
	foreach ($VC in $VCenters){
	#Connect to VCenter.
	connect-viserver $VC
	#Add worksheet named Guest by VCenter.
	$currentsheet = $workbook.worksheets.add()
	$currentsheet.name = "Guest - " + "$VC"
	
	#Get virtual machines in current VCenter.
	$VMs = Get-VM | ?{$_.powerstate -eq "PoweredOn"}
	#Create multidimensional array sized by number of VMs, plus 1 for header, and number of columns:
	$MDArray = New-Object 'object[,]' ($vms.count+1),14
	
	$row = 1
	$col = 0
	#Enter column names for first row:
	$MDArray[0,0] = "VM Name"
	$MDArray[0,1] = "Resource Pool"
	$MDArray[0,2] = "Allocated CPU"
	$MDArray[0,3] = "Avg. CPU (MHz)"
	$MDArray[0,4] = "Allocated Mem (MB)"
	$MDArray[0,5] = "Avg. Mem Usage (%)"
	$MDArray[0,6] = "Mem Usage (MB)"
	$MDArray[0,7] = "VMDK(s) / Capacity / Type"
	$MDArray[0,8] = "VMDK Avg. (KBps)"
	$MDArray[0,9] = "Nic Type"
	$MDArray[0,10] = "Network Avg. (KBps)"
	$MDArray[0,11] = "Hrdwr Ver."
	$MDArray[0,12] = "VMTools Ver."
	$MDArray[0,13] = "VM Operating System"
	
	$vmnumber = 1
	$vmcount = $vms.count
		
		#Loop through VMs in current VCenter:
		foreach ($vm in $VMs){
		
		#Progress update:
		Write-Host "Currently building $vm's statistics into table."
		Write-Host "Working $vmnumber of $vmcount VMs."
		
		$vmnumber++
		#Use PowerCLI's "Get-Stat" to pull VM statistics for the previous month.
		$vmstats = Get-Stat -Entity $vm.name -Start $startdate -Finish $enddate -EA SilentlyContinue
		#Set variables for statistics by type used:
		$cpuuse = $vmstats | ?{$_.metricid -eq "cpu.usagemhz.average"}
		$memuse = $vmstats | ?{$_.metricid -eq "mem.usage.average"}
		$dskuse = $vmstats | ?{$_.metricid -eq "disk.usage.average"}
		$netuse = $vmstats | ?{$_.metricid -eq "net.usage.average"}
		#Build table of VMs' statistics and settings into multidimensional array:
		$MDArray[$row,$col] = [string]($vm.name)
		$col++
		$MDArray[$row,$col] = [string]($vm.resourcepool.name)
		$col++
		$MDArray[$row,$col] = [string]($vm.NumCpu)
		$col++
		$MDArray[$row,$col] = [string]([Math]::Round((($cpuuse | Measure-Object Value -Average).Average),2))
		$col++
		$MDArray[$row,$col] = [string]$vm.MemoryMB
		$col++
		$MDArray[$row,$col] = [string]([Math]::Round((($memuse | Measure-Object Value -Average).Average),2))
		$col++
		$MDArray[$row,$col] = [string]$([math]::round((([Math]::Round((($memuse | Measure-Object Value -Average).Average),2))/100*($vm.memoryMB)),2))
		$col++
		
			$HDDSize = Get-HardDisk $vm.name | Sort Name
		
			$HDDList = $null
		
				foreach ($HD in $HDDSize) { 
					$DiskType = $HD.StorageFormat
					$DiskName = $HD.Name
					$DiskSize = $HD.CapacityKB / 1048576
					$DiskSize = "{0:N2}" -f $DiskSize
					$HDDList += "$DiskName"+"/ "+ "$DiskSize" + "/ " + "$DiskType`r`n"
				}
		
		$MDArray[$row,$col] = [string]$HDDList
		$col++
	
		$MDArray[$row,$col] = [string]([Math]::Round((($dskuse | Measure-Object Value -Average).Average),2))
		$col++
		$MDArray[$row,$col] = [string]$vm.NetworkAdapters.type
		$col++
		$MDArray[$row,$col] = [string]([Math]::Round((($netuse | Measure-Object Value -Average).Average),2))
		$col++
		$MDArray[$row,$col] = [string]$vm.version
		$col++
			
			Try {
				$MDArray[$row,$col] = ($vm.ExtensionData.guest.ToolsVersion.tostring())
			}
			Catch {
				$MDArray[$row,$col] = "Not Installed"
			}
			
		$col++
		$MDArray[$row,$col] = [string]$vm.ExtensionData.guest.GuestFullName
				
		$col = 0
		$row++
		}
	
	#Create Excel interop object for aligning cell content:
	[reflection.assembly]::loadWithPartialname("Microsoft.Office.Interop.Excel") | out-Null
	$xlConstants = "microsoft.office.interop.excel.Constants" -as [type]
	
	#Create range of Excel cells to match multidimensional array
	#and add array to sheet:
	$cells = "A1:N" + ($vms.count+1)
	$sheetname = "Guest - " + "$VC"
	$worksheet = $workbook.Worksheets.Item("$sheetname")
	$range = $worksheet.Range("$cells")
	$range.Value2 = $MDArray
	#Align and autofit cells:
	$range.HorizontalAlignment = $xlConstants::xlCenter
	$range.VerticalAlignment = $xlConstants::xlCenter
	$range.Rows.AutoFit() | Out-Null
	$range.Columns.AutoFit() | Out-Null
	
	#Get Hosts for current VCenter:
	$VMHosts = Get-VMHost
	#New worksheet for Hosts at current VCenter:
	$currentsheet = $workbook.worksheets.add()
	$currentsheet.name = "Host - " + "$VC"
	#Create multidimensional array sized by number of Hosts, plus 1 for header, and number of columns:
	$MDArray = New-Object 'object[,]' ($vms.count+1),7
	
	$row = 1
	$col = 0
	$MDArray[0,0] = "Host Name"
	$MDArray[0,1] = "CPU (MHz)"
	$MDArray[0,2] = "CPU Used (MHz)"
	$MDArray[0,3] = "% CPU Used"
	$MDArray[0,4] = "Mem (GB)"
	$MDArray[0,5] = "Host Memory(GB)"
	$MDArray[0,6] = "% Mem Used"
	
	$vmhostnum = $vmhosts.count
	$count = 1
		#Loop through Hosts at current VCenter:
		
		foreach ($vmhost in $vmhosts){
			$name = $vmhost.name.split(".")[0]
			#Progress update:
			Write-Host "Currently building $name's statistics into table."
			Write-Host "Working $count of $vmhostnum Hosts."
			
		
			$hoststats = Get-Stat -Entity $vmhost -Start $startdate -Finish $enddate -EA SilentlyContinue
			$cpuuse = $hoststats | ?{$_.metricid -eq "cpu.usagemhz.average"}
			$cpupcnt = $hoststats | ?{$_.metricid -eq "cpu.usage.average"}
			$memuse = $hoststats | ?{$_.metricid -eq "mem.usage.average"}
			
			$MDArray[$row,$col] = [string]$vmhost.name.split(".")[0]
			$col++
			$MDArray[$row,$col] = [string]$vmhost.cputotalmhz
			$col++
			$MDArray[$row,$col] = [string]$vmhost.cpuusagemhz
			$col++
			$MDArray[$row,$col] = [string]([Math]::Round((($cpuuse | Measure-Object Value -Average).Average),2))
			$col++
			$MDArray[$row,$col] = [string]([math]::Round((($vmhost.MemoryUsageMB)/1024),2))
			$col++
			$MDArray[$row,$col] = [string]([math]::Round((($vmhost.MemoryTotalMB)/1024),2))
			$col++
			$MDArray[$row,$col] = [string]([Math]::Round((($memuse | Measure-Object Value -Average).Average),2))
			
			$col = 0
			$row++			
			
			$count++
		}
		
		[reflection.assembly]::loadWithPartialname("Microsoft.Office.Interop.Excel") | out-Null
		$xlConstants = "microsoft.office.interop.excel.Constants" -as [type]
		
		$cells = "A1:G" + ($vmhosts.count+1)
		$sheetname = "Host - " + "$VC"
		$worksheet = $workbook.Worksheets.Item("$sheetname")
		$range = $worksheet.Range("$cells")
		$range.Value2 = $MDArray
		$range.HorizontalAlignment = $xlConstants::xlCenter
		$range.VerticalAlignment = $xlConstants::xlCenter
		$range.Rows.AutoFit() | Out-Null
		$range.Columns.AutoFit() | Out-Null	
		
		
		
		$datastores = get-datastore
		
		$currentsheet = $workbook.worksheets.add()
		$currentsheet.name = "Datastores - " + "$VC"
	
		$MDArray = New-Object 'object[,]' ($datastores.count+1),4
		$row = 1
		$col = 0
		$MDArray[0,0] = "Datastore"
		$MDArray[0,1] = "Total Space (GB)"
		$MDArray[0,2] = "Free Space (GB)"
		$MDArray[0,3] = "% Free"
		
			
			foreach ($DS in $datastores){
			$MDArray[$row,$col] = [string]$DS.name
			$col++
			$MDArray[$row,$col] = [string]([math]::round((($DS.capacitymb)/1024),2))
			$col++
			$MDArray[$row,$col] = [string]([math]::round((($DS.freespacemb)/1024),2))
			$col++
			$MDArray[$row,$col] = [string]([math]::round(($DS.freespacemb/$DS.capacitymb),2)*100) + " %"
			
			$col = 0
			$row++			
			}
		
		[reflection.assembly]::loadWithPartialname("Microsoft.Office.Interop.Excel") | out-Null
		$xlConstants = "microsoft.office.interop.excel.Constants" -as [type]
				
		$cells = "A1:D" + ($datastores.count+1)
		$sheetname = "Datastores - " + "$VC"
		$worksheet = $workbook.Worksheets.Item("$sheetname")
		$range = $worksheet.Range("$cells")
		$range.Value2 = $MDArray
		$range.HorizontalAlignment = $xlConstants::xlCenter
		$range.VerticalAlignment = $xlConstants::xlCenter
		$range.Rows.AutoFit() | Out-Null
		$range.Columns.AutoFit() | Out-Null
		
		
	
	
	Disconnect-VIServer $VC -Confirm:$false

		 		 
	}