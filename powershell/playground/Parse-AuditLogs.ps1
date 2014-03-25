Set-Location C:\Users\jspatton\Desktop\logs 
$Ids = '4775','4777','4662','5136','5137','5138','5139','5141','4625','4964','4675','5039','4659','4660','4661','4663','4771','4772','6273','6274','6275','6276','4715','4719','4817','4902','4904','4905','4906','4908','4912','4944','4945','4946','4947','4948','4949','4950','4951','4952','4953','4954','4956','4957','4958'

foreach ($file in (Get-ChildItem -Filter *.evtx))
{
    $Seclog = Get-WinEvent -Path $file.FullName
    $oldCount = ($Seclog |Sort-Object -Property Id -Unique).Count
    $file.FullName
    $NewSeclog = @()
    foreach ($Id in $Ids)
    {
        $NewSeclog += $Seclog |Where-Object -Property Id -eq $Id
        }
    $newCount = ($NewSeclog |Sort-Object -Property Id -Unique).Count

    New-Object -TypeName PSobject -Property @{
        LogFile = $File.Name
        IdCount = $oldCount
        AuditedCount = $newCount
        }
    Remove-Variable SecLog
    Remove-Variable NewSecLog
    }