$shell = New-Object -com "Shell.Application"
$cookies = ($shell.namespace(0x21)).Self.Path
remove-item $cookies\*.* -force
$ie = new-object -com "InternetExplorer.Application"
$ie.fullscreen =$true
$ie.visible = $true