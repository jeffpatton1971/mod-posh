param
(
    [string]$AccountName,
    [string]$Source = ".\"
)
if ((New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
    $System32 = "C:\Windows\System32"
    $SysWow64 = "C:\Windows\SysWOW64"
    $mstsc = "mstsc.exe"
    $mstscax = "mstscax.dll"
    $Owner = New-Object System.Security.Principal.NTAccount($AccountName)
    $ACL.SetOwner($Owner)
    $Rule = New-Object System.Security.AccessControl.FileSystemAccessRule($Owner,"FullControl","Allow")
    $ACL.SetAccessRule($Rule)

    Set-Acl -Path "$($System32)\$($mstsc)" -AclObject $ACL
    Set-Acl -Path "$($System32)\$($mstscax)" -AclObject $ACL
    Set-Acl -Path "$($SysWow64)\$($mstsc)" -AclObject $ACL
    Set-Acl -Path "$($SysWow64)\$($mstscax)" -AclObject $ACL

    Rename-Item "$($System32)\$($mstsc)" "$($System32)\$($mstsc).$((Get-Date).ToFileTime().ToString())"
    Rename-Item "$($System32)\$($mstscax)" "$($System32)\$($mstscax).$((Get-Date).ToFileTime().ToString())"
    Rename-Item "$($SysWow64)\$($mstsc)" "$($SysWow64)\$($mstsc).$((Get-Date).ToFileTime().ToString())"
    Rename-Item "$($SysWow64)\$($mstscax)" "$($SysWow64)\$($mstscax).$((Get-Date).ToFileTime().ToString())"

    Copy-Item "$($Source)\System32\*" $System32
    Copy-Item "$($Source)\SysWOW64\*" $SysWow64   
}
else 
{
    Write-Error "Launch Powershell as Administrator";
}