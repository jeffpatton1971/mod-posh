if ($Global:principal.IsInRole("Administrators"))  {
    # Get my current profile
    Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/jeffpatton1971/mod-posh/master/powershell/playground/Profile.ps1" -OutFile $PROFILE;
    # Get USB DVD Tool
    Invoke-WebRequest -UseBasicParsing -Uri "https://download.microsoft.com/download/C/4/8/C48F6E20-FE20-41C6-8C1C-408FE7B49A3A/Windows7-USB-DVD-Download-Tool-Installer-en-US.exe" -OutFile .\Windows7-USB-DVD-tool.exe;
    # Get Exchange Web Services
    Invoke-WebRequest -UseBasicParsing -Uri "http://download.microsoft.com/download/5/E/4/5E456B4C-78D4-4E6C-BC84-CA7FE87BB117/WebServicesSDK.msi" -OutFile .\WebServicesSDK.msi;
    # Get WebPI
    Invoke-WebRequest -UseBasicParsing -Uri "https://download.microsoft.com/download/8/4/9/849DBCF2-DFD9-49F5-9A19-9AEE5B29341A/WebPlatformInstaller_x64_en-US.msi" -OutFile .\WebPlatformInstaller_x64_en-US.msi;
    # Get GithubDesktop
    Invoke-WebRequest -UseBasicParsing -Uri "https://desktop.githubusercontent.com/releases/2.4.3-539849ed/GitHubDesktopSetup.exe" -OutFile .\GitHubDesktopSetup.exe;
    # Get VsCode
    Invoke-WebRequest -UseBasicParsing -Uri "https://az764295.vo.msecnd.net/stable/ff915844119ce9485abfe8aa9076ec76b5300ddd/VSCodeUserSetup-x64-1.44.2.exe" -OutFile .\VSCodeUserSetup-x64-1.44.2.exe;
    # Get Posh-Git
    Install-Module -Name posh-git -AllowClobber;
    Write-Host "You will need to install Visual Studio in order to compile CShell"
    # Get C-Shell
    git clone https://github.com/lukebuehler/CShell.git
    # ADO Artifacts Credential Provider
    Invoke-Expression "& { $(Invoke-RestMethod https://aka.ms/install-artifacts-credprovider.ps1) }"
    Invoke-Expression "& { $(Invoke-RestMethod https://aka.ms/install-artifacts-credprovider.ps1) } -AddNetfx"
} else {
    Write-Host "Please launch PowerShell as an Administrator" -ForegroundColor Red;
}