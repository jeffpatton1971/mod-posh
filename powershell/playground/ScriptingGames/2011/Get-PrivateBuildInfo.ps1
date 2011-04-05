function Get-PrivateBuildInfo()
	{
		<#
			.SYNOPSIS
				Return the PrivateBuild information for a given process.
			.DESCRIPTION
				This function returns the whether the provided process is a PrivateBuild or not. If run without
				parameters it will check the local computer for notepad, if you specify a process it will check 
				for that process. Optionally a remote computer can be specified along with credentials to 
				check the remote machine.
			.PARAMETER Process
				The name of a process as it might appear from the output of Get-Process.
			.PARAMETER Computer
				The NetBIOS name of a computer to check.
			.PARAMETER Credential
				The domain\username of an account with the ability to access process information.
			.EXAMPLE
				Get-PrivateBuildInfo
				
				Process                    Computer                                PrivateBuild
				-------                    --------                                ------------
				notepad                    Localhost                                      False
				
				Description
				-----------
				This example shows the output of the command when no parameters are specified.
			.EXAMPLE
				Get-PrivateBuildInfo -Process explorer -Computer Remote -Credential DOMAIN\Administrator

				Process                    Computer                                PrivateBuild
				-------                    --------                                ------------
				explorer                   Remote                                         False
				
				Description
				-----------
				This example shows the output of the command when providing a named process and computer as
				well as specifying credentials with permission to perform this action.
			.NOTES
				You are the network administrator for a large multinational company with a Premier Services Contract 
				with the Microsoft Corporation. Because of your contract, you have received a private build of a 
				specific application that has a compatibility issue with your custom application. In preparation for 
				your server upgrade to Service Pack 1 for Windows Server 2008 R2, your boss has asked you to identify 
				which servers are running this private build of the application. For the purposes of this scenario, you 
				can use the notepad.exe process. You should report the computer name, the process name (Notepad) and 
				whether or not Notepad is a private build. You must report the actual computer name and not something 
				generic like “localhost” because this will facilitate logging later. 
			.LINK
				http://blogs.technet.com/b/heyscriptingguy/archive/2011/04/04/the-2011-scripting-games-beginner-event-1-use-powershell-to-identify-private-builds-of-software.aspx
		#>
		
		Param
			(
				[string]$Process = "notepad",
				[string]$Computer = (& hostname),
				[string]$Credential			
			)
		If ($Computer -eq (& hostname))
			{		
				$ThisProcess = Get-Process -Name $Process -FileVersionInfo
			}
		Else
			{
				$ThisProcess = Invoke-Command -ComputerName $Computer -ScriptBlock `
								{Get-Process -Name notepad -FileVersionInfo} -Credential $Credential
			}
		$MyProcess = New-Object PSObject
		
		$MyProcess | Add-Member -MemberType NoteProperty -Name "Process" -value $Process
		$MyProcess | Add-Member -MemberType NoteProperty -Name "Computer" -value $Computer
		$MyProcess | Add-Member -MemberType NoteProperty -Name "PrivateBuild" -value $ThisProcess.IsPrivateBuild
		
		Return $MyProcess
	}