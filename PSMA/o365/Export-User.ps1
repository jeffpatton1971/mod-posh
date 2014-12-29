<#
    .SYNOPSIS
        User export script
    .DESCRIPTION
        This script is run during an export and does the provisioning of the object 
        in Office 365. For more details on what Export scripts should do see the 
        links below.
    .PARAMETER Username
        The tenant admin username
    .PARAMETER Password
        The tenant admin password
    .NOTES
        ScriptName : Export-User.ps1
        Created By : Jeffrey
        Date Coded : 12/29/2014 13:27:31

        This script is run on the export run profile
    .LINK
        https://github.com/jeffpatton1971/mod-posh/wiki/Production/Export-User.ps1
    .LINK
        http://blog.goverco.com/p/powershell-management-agent.html
    .LINK
        http://blog.goverco.com/p/psmaexport.html
 #>
[CmdletBinding()]
Param
(
    [string]$Username,
    [string]$Password
)
Begin
{
    try
    {
        $ErrorActionPreference = "Stop"

        Import-Module C:\Scripts\LogFiles.psm1
        Import-Module MSOnline -Force

        $SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force
        $Creds = New-Object System.Management.Automation.PSCredential $Username, $SecurePassword

        $LogName = "PMA-Office365-Export"
        $Source = "Export"
        $EntryType = "Information"
        $o365Tenant = ($Creds.GetNetworkCredential().UserName).Split("@")[1]
        $DisabledPlans = ""

        Connect-MsolService -Credential $Creds
        Write-LogFile -LogName $LogName -Source $Source -EventID 100 -EntryType $EntryType -Message "Connected to Office 365"

        $AccountSku = Get-MsolAccounSku |Where-Object -Property AccountSkuId -eq "$($o365Tenant):STANDARDWOFFPACK_STUDENT"
        $o365Sku = New-MsolLicenseOptions -AccountSkuid $AccountSku.AccountSkuid -DisabledPlans $DisabledPlans
        }
    catch
    {
        Write-Error $Error[0]
        break
        }
    }
Process
{
    try
    {
        $ErrorActionPreference = "Stop"
        $User = $_.DN
        Write-LogFile -LogName $LogName -Source $Source -EventID 101 -EntryType $EntryType -Message "Processing user : $($User)"

        $Action = $_.ObjectModificationType
        Write-LogFile -LogName $LogName -Source $Source -EventID 101 -EntryType $EntryType -Message "Action : $($Action)"

        [bool]$Enable = $_.AttributeChanges |Where-Object {$_.Name -eq "msds-cloudextensionattribute1"} |ForEach-Object {if ($_.ValueChanges[0].Value -ieq "enable"){$true}}
        Write-LogFile -LogName $LogName -Source $Source -EventID 101 -EntryType $EntryType -Message "Enable value : $($Enable)"

        switch ($Action.ToLower())
        {
            "add"
            {
                if ($Enable)
                {
                    $oUser = Get-MsolUser -UserPrincipalName $User
                    if (!($oUser.IsLicensed -eq $true))
                    {
                        Set-MsolUser -UserPrincipalName $User -UsageLocation "US"
                        Set-MsolUserLicense -UserPrincipalName $User -AddLicenses $AccountSku.AccountSkuId
                        Set-MsolUserLicense -UserPrincipalName $User -LicenseOptions $o365Sku
                        Write-LogFile -LogName $LogName -Source $Source -EventID 101 -EntryType $EntryType -Message "Assigning licenses to user"

                        $oUser = Get-MsolUser -UserPrincipalName $User
                        Write-LogFile -LogName $LogName -Source $Source -EventID 101 -EntryType $EntryType -Message "$($oUser.UserPrincipalName) licensed $($oUser.isLicensed)"
                        }
                    else
                    {
                        Write-LogFile -LogName $LogName -Source $Source -EventID 102 -EntryType "Warning" -Message "$($oUser.UserPrincipalName) already licensed"
                        }
                    }
                }
            default
            {
                Write-LogFile -LogName $LogName -Source $Source -EventID 102 -EntryType "Warning" -Message "Action : $($Action)"
                }
            }
        }
    catch
    {
        Write-LogFile -LogName $LogName -Source $Source -EventID 102 -EntryType "Error" -Message $Error[0].Exception
        }
    }
End
{
    }