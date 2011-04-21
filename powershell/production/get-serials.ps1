<#
    .SYNOPSIS
        Get the BIOS serial numbers from computers in the domain.
    .DESCRIPTION
        Return a list of computers with their serial numbers. For Dell computers the Win32_BIOS.SerialNumber property
        is the service tag of the computer. This identifies the computer on the Dell support site, and with it you can
        get the proper drivers/manuals and warranty information.
    .PARAMETER ADSPath
        The location within Active Directory to find computers.
    .EXAMPLE
        .\get-serials.ps1 -ADSPath "LDAP://OU=workstations,DC=company,DC=com"

        ComputerName                                                ServiceTag
        ------------                                                ----------
        Desktop-pc01                                                a1b2c3d
        Desktop-pc02                                                b2c3d4e
        Desktop-pc03                                                The RPC server is unavailable. (Exception from H ...
        Desktop-pc04                                                f4g5h6i

        Description
        -----------
        This example shows the output of the command.
    .EXAMPLE
        .\get-serials.ps1 -ADSPath "LDAP://OU=workstations,DC=company,DC=com" `
        | Export-Csv .\sample.csv -NoTypeInformation
        
        Description
        -----------
        This example shows piping the output to a csv file.
    .NOTES
    .LINK
#>

Param
    (
        [Parameter(Mandatory=$true)]
        $ADSPath
    )
    
$ScriptName = $MyInvocation.MyCommand.ToString()
$LogName = "Application"
$ScriptPath = $MyInvocation.MyCommand.Path
$Username = $env:USERDOMAIN + "\" + $env:USERNAME

	New-EventLog -Source $ScriptName -LogName $LogName -ErrorAction SilentlyContinue
	
	$Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nStarted: " + (Get-Date).toString()
	Write-EventLog -LogName $LogName -Source $ScriptName -EventID "100" -EntryType "Information" -Message $Message 

	#	Dotsource in the AD functions I need
	. .\includes\ActiveDirectoryManagement.ps1

	$Workstations = Get-ADObjects -ADSPath $ADSPath
    
    $Jobs = @()
	foreach ($Workstation in $Workstations)
		{
            [string]$ThisWorkstation = $Workstation.Properties.name
            $ThisJob = New-Object PSobject
			if ($Workstation -eq $null){}
			else
				{
                    Try
                        {
                            $ErrorActionPreference = "Stop"
                            $Serial = Get-WmiObject -query "select SerialNumber from win32_bios" `
                                    -computername $ThisWorkstation
                            $Return = $serial.serialnumber
                        }
                    Catch
                        {
                            [string]$ThisError = $Error[0].Exception
                            $ThisError = $ThisError.Substring($ThisError.IndexOf(":"))
                            $ThisError = $ThisError.Substring(1,$ThisError.IndexOf("`r"))
                            $return = $ThisError.Trim()
                        }
                    
                    Add-Member -InputObject $ThisJob -MemberType NoteProperty -Name "ComputerName" `
                        -Value $ThisWorkstation
                    Add-Member -InputObject $ThisJob -MemberType NoteProperty -Name "ServiceTag" -Value $Return
				}
            $Jobs += $ThisJob
            $ThisJob
		}

    $Message = [system.string]::Join("`n",($Jobs))
    Write-EventLog -LogName $LogName -Source $ScriptName -EventId "101" -EntryType "Information" -Message $Message
        
	$Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
	Write-EventLog -LogName $LogName -Source $ScriptName -EventID "100" -EntryType "Information" -Message $Message
