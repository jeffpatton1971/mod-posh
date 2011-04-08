Function New-ComputerReport()
    {
        <#
            .SYNOPSIS
                Create a file listing basic user and computer information
            .DESCRIPTION
                This function creates a text file containing basic information about the local or remote computers. The
				information collected is as follows:
					UserName - Name of currently logged on user
					Computer - Name of the computer to report on
					Domain - Domain name the computer is joined to
					OperatingSystem - Name of the OS on the computer
            .PARAMETER ComputerName
				The NetBIOS name of a remote computer
            .PARAMETER Credentials
				The DOMAIN\USERNAME with rights to remote computer
            .PARAMETER FileName
				The filename of the report to create, the file is created in the directory the script is run in. If you
				provide path information, the path to the destination must exist first.
            .EXAMPLE
				New-ComputerReport -ComputerName dc2 -Credentials $Credentials -FileName .\dcs.txt

				User:     DOMAIN\Administrator
				Computer: DC1
				Domain:   domain.company.com
				OS:       Microsoft? Windows Server? 2008 Standard 
				User information collected on: 4/8/2011

				User:     DOMAIN\Administrator
				Computer: DC2
				Domain:   domain.company.com
				OS:       Microsoft? Windows Server? 2008 Standard 
				User information collected on: 4/8/2011
				
				Description
				-----------
				This example shows using the -ComputerName parameter to pass in a named computer, the subsequent output
				is the contents of the file specified for FileName.

            .EXAMPLE
				Get-Content .\servers.txt | New-ComputerReport -Credentials $Credentials -FileName report.txt

				User:     
				Computer: INTRANET
				Domain:   domain.company.com
				OS:       Microsoft(R) Windows(R) Server 2003, Standard Edition
				User information collected on: 4/8/2011

				User:     
				Computer: VC
				Domain:   domain.company.com
				OS:       Microsoft Windows Server 2008 R2 Enterprise 
				User information collected on: 4/8/2011

				...
				
				Description
				-----------
				This example shows piping input from a file into the function to generate the named report. The input
				file was a single column list of server names.
            .NOTES
				PowerShell may need to be run elevated
				UAC may need to be disabled on the local computer
				
            .LINK
				http://blogs.technet.com/b/heyscriptingguy/archive/2011/04/08/the-2011-scripting-games-beginner-event-5-use-powershell-to-collect-basic-computer-information.aspx
        #>
        
        Param
            (
                [Parameter(ValueFromPipeline=$true)]
                [ValidateNotNullOrEmpty()]
                [System.String[]]
                ${ComputerName} = @(hostname),
                $Credentials,
				[Parameter(Mandatory=$true)]
                [string]$FileName
            )
            
        Process
            {
                If (Test-Connection -ComputerName $ComputerName -Count 1 -ErrorAction SilentlyContinue)
                    {
                        If ($ComputerName -eq (& hostname))
                            {
                                $OperatingSystem = Get-WmiObject Win32_OperatingSystem `
													-ErrorAction SilentlyContinue -ErrorVariable err
                                $UserInfo = Get-WmiObject Win32_ComputerSystem `
													-ErrorAction SilentlyContinue -ErrorVariable err
                            }
                        Else
                            {
                                $OperatingSystem = Get-WmiObject Win32_OperatingSystem -ComputerName $ComputerName `
											-Credential $Credentials  -ErrorAction SilentlyContinue -ErrorVariable err
                                $UserInfo = Get-WmiObject Win32_ComputerSystem -ComputerName $ComputerName `
											-Credential $Credentials -ErrorAction SilentlyContinue -ErrorVariable err
                            }

                                If ($err -ne $null){break}
                                $Date = Get-Date

                                "`nUser:     $($UserInfo.UserName)" |Out-File -Encoding ASCII -FilePath $FileName -Append
                                "`nComputer: $($UserInfo.Name)" |Out-File -Encoding ASCII -FilePath $FileName -Append
                                "`nDomain:   $($UserInfo.Domain)" |Out-File -Encoding ASCII -FilePath $FileName -Append
                                "`nOS:       $($OperatingSystem.Caption)" |Out-File -Encoding ASCII -FilePath $FileName -Append
                                "`nUser information collected on: $($Date.ToShortDateString())`n" |Out-File -Encoding ASCII -FilePath $FileName -Append
                                Remove-Variable -Name err
                    }
            }
    }