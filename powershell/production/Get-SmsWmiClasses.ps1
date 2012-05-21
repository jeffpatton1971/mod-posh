<#
    .SYNOPSIS
        Script to scan SMS WMI Classes
    .DESCRIPTION
        This is a re-write of a script I came across in the Technet libraries
        for enumerating all the classes from the various SMS namespaces to a file.
    .PARAMETER SiteCode
        This is your SCCM SiteCode, it is used as part of the CCM namespace.
    .PARAMETER ComputerName
        The name of your SCCM server, if blank defaults to localhost.
    .PARAMETER LogFolder
        The folder to store the output in, this folder will be created if
        it doesn't exist.
        
        The default is C:\WMIScan
    .PARAMETER LogFile
        This is the output file, and will be created.
        
        The default is WMIScan.txt
    .EXAMPLE
        .\Get-SmsWmiClasses.ps1 -SiteCode 'mysite' -ComputerName 'sccm'
        
        Description
        -----------
        This example shows the default usage of this script.
    .NOTES
        ScriptName : Get-SmsWmiClasses
        Created By : jspatton
        Date Coded : 05/21/2012 13:39:01
        ScriptName is used to register events for this script
 
        ErrorCodes
            100 = Success
            101 = Error
            102 = Warning
            104 = Information
    .LINK
        https://code.google.com/p/mod-posh/wiki/Production/Get-SmsWmiClasses
    .LINK
        http://technet.microsoft.com/en-us/library/cc179784.aspx
#>
[CmdletBinding()]
Param
    (
    $SiteCode = '',
    $ComputerName = "(& hostname)",
    $LogFolder = 'c:\WMIScan',
    $LogFile = 'WMIScan.txt'
    )
Begin
    {
        $ScriptName = $MyInvocation.MyCommand.ToString()
        $ScriptPath = $MyInvocation.MyCommand.Path
        $Username = $env:USERDOMAIN + "\" + $env:USERNAME
 
        New-EventLog -Source $ScriptName -LogName 'Windows Powershell' -ErrorAction SilentlyContinue
 
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nStarted: " + (Get-Date).toString()
        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message
 
        #	Dotsource in the functions you need.
        . .\includes\ComputerManagement.ps1
        
        $FullPath = "$($LogFolder)\$($LogFile)"
        }
Process
    {
        Write-Verbose 'list of SMS namespaces are put into an array.'
        $SMSNamespaces = @("root\ccm","root\ccm\events","root\ccm\vulnerabilityassessment","root\ccm\invagt","root\ccm\softmgmtagent","root\ccm\locationservices","root\ccm\datatransferservice","root\ccm\messaging","root\ccm\policy","root\ccm\softwaremeteringagent","root\ccm\contenttransfermanager","root\ccm\scheduler","root\cimv2\sms","root\smsdm","root\sms","root\sms\inv_schema","root\sms\site_$($SiteCode)")

        Write-Verbose "Does $($LogFolder) Folder exist?  If not, it`'s created"
        if ((Test-Path -Path $LogFolder) -ne $true)
        {
            New-Item $LogFolder -ItemType Directory -Force |Out-Null
            }
        if ((Test-Path -Path $FullPath) -ne $true)
        {
            New-Item $FullPath -ItemType File -Force |Out-Null
            }

        "********************************************" |Out-File -FilePath $FullPath 
        " WMIScan Tool Executed - $(Get-date)" |Out-File -FilePath $FullPath -Append
        "********************************************" |Out-File -FilePath $FullPath -Append
        "--------------------------------------------" |Out-File -FilePath $FullPath -Append

        $Computer = $ComputerName
        if ($ComputerName -eq (& hostname))
        {
            $Computer = 'Local System'
            }
            
        " Scanning WMI Namespaces On $($Computer)" |Out-File -FilePath $FullPath -Append
        "--------------------------------------------" |Out-File -FilePath $FullPath -Append
        Write-Host "Starting WMI scan on $($ComputerName)"
        foreach ($Namespace in $SMSNamespaces)
        {
            " Scanning for Classes in $($NameSpace) ..." |Out-File -FilePath $FullPath -Append
            "" |Out-File -FilePath $FullPath -Append
            "\\$($ComputerName)\$($Namespace)" |Out-File -FilePath $FullPath -Append
            $WbemClasses = Enum-NameSpaces -Namespace $Namespace -ComputerName $ComputerName
            $WbemClasses |Out-File -FilePath $FullPath -Append
            }
        }
End
    {
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message	
        }