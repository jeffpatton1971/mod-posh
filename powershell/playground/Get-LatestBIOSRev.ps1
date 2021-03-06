$ComputerName = "node1"
. .\DellWebsiteFunctions.ps1

$BiosRev = Get-WmiObject -Class Win32_BIOS -ComputerName $ComputerName -Credential $Credentials

If ($BiosRev.Manufacturer -match "Dell")
{
    $DellPage = (New-Object -TypeName net.webclient).DownloadString((Get-DellDownloadURL -ServiceTag $BiosRev.SerialNumber -DellCategory BIOS).URL)
    
    $DellCurrentBios = Get-DellCurrentBIOSRev -ServiceTag $BiosRev.SerialNumber
    If ($BiosRev.SMBIOSBIOSVersion -eq $DellCurrentBios.BIOS -eq $false)
    {
        $marker = $DellPage.Substring($DellPage.IndexOf("http://ftp"),($DellPage.Length)-($DellPage.IndexOf("http://ftp")))
        $BIOSDownloadURL = $marker.Substring(0,$marker.IndexOf("`'"))
        
        $BIOSFile = $BIOSDownloadURL.Substring(($BIOSDownloadURL.Length)-12,12)

        If ((Test-Path "C:\Dell\") -eq $false)
        {
            New-Item -Path "C:\" -Name "Dell" -ItemType Directory
        }
        If ((Test-Path "C:\Dell\$($ComputerName)") -eq $false)
        {
            New-Item -Path "C:\Dell" -Name $ComputerName -ItemType Directory
        }

        (New-Object -TypeName System.Net.WebClient).DownloadFile($BIOSDownloadURL,"C:\Dell\$($ComputerName)\$($BIOSFile)")

        Write-Host "Latest BIOS for $($ComputerName) downloaded to C:\Dell\$($ComputerName)\$($BIOSFile)"
    }
    $BIOSInfo = New-Object PSobject -Property @{
        ComputerName = $ComputerName
        ServiceTag = $($BiosRev.SerialNumber)
        CurrentBIOSRev = $($BiosRev.SMBIOSBIOSVersion)
        LatestBIOSrev = $DellCurrentBios.BIOS
        BIOSURL = $BIOSDownloadURL
    }
}