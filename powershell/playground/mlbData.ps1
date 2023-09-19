param (
$Date= (Get-Date).AddDays(-1),
$Database = 'masterscoreboard',
$ServerName = 'gd2mlb',
$Username = 'jspatton',
$Password = 'Natalie1N^msjc4d'
)
$Year = (Get-Date($Date) -Format yyy);
$Month = (Get-Date($Date) -Format MM);
$Day = (Get-Date($Date) -Format dd);
$ServerInstance = "$($ServerName).database.windows.net"

$url = "http://gd2.mlb.com/components/game/mlb/year_$($Year)/month_$($Month)/day_$($Day)/master_scoreboard.json";
$Data = Invoke-WebRequest -Uri $url |Select-Object -ExpandProperty Content |ConvertFrom-Json;
#
# Add games to season
#
$ColumnNames = $Data.data.games.game[0] |Get-Member -Type NoteProperty |Select-Object -Property Name |ForEach-Object {$Property = $_.Name;if ($Data.data.games.game[0].$Property.GetType().Name -ne 'PSCustomObject'){$_.Name}};
foreach ($Game in $Data.data.games.game) {
  $TableData = "INSERT INTO mlb_$($Year)_masterScoreboard (";
  foreach ($ColumnName in ($ColumnNames |Sort-Object)){$TableData += "f_$($ColumnName),"};
  $TableData += "f_away_team_runs,f_home_team_runs,f_away_team_hits,f_home_team_hits,f_away_team_errors,f_home_team_errors,f_away_team_sb,f_home_team_sb,f_away_team_so,f_home_team_so)";
  $TableData += " VALUES (";
  foreach ($ColumnName in ($ColumnNames |Sort-Object)){$TableData += "`'$($game.$ColumnName)`',"};
  $TableData += "`'$($game.linescore.r.away)`',`'$($game.linescore.r.home)`',`'$($game.linescore.h.away)`',`'$($game.linescore.h.home)`',`'$($game.linescore.e.away)`',`'$($game.linescore.e.home)`',`'$($game.linescore.sb.away)`',`'$($game.linescore.sb.home)`',`'$($game.linescore.so.away)`',`'$($game.linescore.so.home)`')";
Invoke-Sqlcmd -Database $Database -ServerInstance $ServerInstance -Username $Username -Password $Password -OutputSqlErrors $True -Query $TableData;

  foreach ($Inning in $game.linescore.inning) {
    $TableData = "INSERT INTO mlb_$($Year)_innings (";
    $TableData +="f_id, f_away, f_home)"
    $TableData += " VALUES ("
    $TableData += "`'$($game.id)`',`'$($Inning.away)`',`'$($Inning.home)`')"

    Invoke-Sqlcmd -Database $Database -ServerInstance $ServerInstance -Username $Username -Password $Password -OutputSqlErrors $True -Query $TableData;
  }
}