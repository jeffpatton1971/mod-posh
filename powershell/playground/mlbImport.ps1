param (
  $Date = (Get-Date)
)

$Today = (Get-Date)

$startofmonth = Get-Date $Date -day 1 -hour 0 -minute 0 -second 0
$endofmonth = (($startofmonth).AddMonths(1).AddSeconds(-1))

if ($Today.Month -eq (Get-Date $Date).Month) {
  for ($i = 1; $i -le ($Today.Day - 1); $i++) {
    .\mlbData.ps1 -Date "$($startofmonth.Month)-$($i)-$($startofmonth.Year)"
  }  
}
else {
  for ($i = 1; $i -le $endofmonth.Day; $i++) {
    .\mlbData.ps1 -Date "$($startofmonth.Month)-$($i)-$($startofmonth.Year)"
  }
}