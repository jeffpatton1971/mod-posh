$Global:RSEventHeaders = @('GAME_ID', 'AWAY_TEAM_ID', 'INN_CT', 'BAT_HOME_ID', 'OUTS_CT', 'BALLS_CT', 'STRIKES_CT', 'PITCH_SEQ_TX',
 'AWAY_SCORE_CT', 'HOME_SCORE_CT', 'BAT_ID', 'BAT_HAND_CD', 'RESP_BAT_ID', 'RESP_BAT_HAND_CD', 'PIT_ID', 'PIT_HAND_CD',
 'RES_PIT_ID', 'RES_PIT_HAND_CD', 'POS2_FLD_ID', 'POS3_FLD_ID', 'POS4_FLD_ID', 'POS5_FLD_ID', 'POS6_FLD_ID', 'POS7_FLD_ID',
 'POS8_FLD_ID', 'POS9_FLD_ID', 'BASE1_RUN_ID', 'BASE2_RUN_ID', 'BASE3_RUN_ID', 'EVENT_TX', 'LEADOFF_FL', 'PH_FL', 'BAT_FLD_CD',
 'BAT_LINEUP_ID', 'EVENT_CD', 'BAT_EVENT_FL', 'AB_FL', 'H_CD', 'SH_FL', 'SF_FL', 'EVENT_OUTS_CT', 'DP_FL', 'TP_FL', 'RBI_CT',
 'WP_FL', 'PB_FL', 'FLD_CD', 'BATTEDBALL_CD', 'BUNT_FL', 'FOUL_FL', 'BATTEDBALL_LOC_TX', 'ERR_CT', 'ERR1_FLD_CD', 'ERR1_CD',
 'ERR2_FLD_CD', 'ERR2_CD', 'ERR3_FLD_CD', 'ERR3_CD', 'BAT_DEST_ID', 'RUN1_DEST_ID', 'RUN2_DEST_ID', 'RUN3_DEST_ID', 'BAT_PLAY_TX',
 'RUN1_PLAY_TX', 'RUN2_PLAY_TX', 'RUN3_PLAY_TX', 'RUN1_SB_FL', 'RUN2_SB_FL', 'RUN3_SB_FL', 'RUN1_CS_FL', 'RUN2_CS_FL', 'RUN3_CS_FL',
 'RUN1_PK_FL', 'RUN2_PK_FL', 'RUN3_PK_FL', 'RUN1_RESP_PIT_ID', 'RUN2_RESP_PIT_ID', 'RUN3_RESP_PIT_ID', 'GAME_NEW_FL', 'GAME_END_FL',
 'PR_RUN1_FL', 'PR_RUN2_FL', 'PR_RUN3_FL', 'REMOVED_FOR_PR_RUN1_ID', 'REMOVED_FOR_PR_RUN2_ID', 'REMOVED_FOR_PR_RUN3_ID',
 'REMOVED_FOR_PH_BAT_ID', 'REMOVED_FOR_PH_BAT_FLD_CD', 'PO1_FLD_CD', 'PO2_FLD_CD', 'PO3_FLD_CD', 'ASS1_FLD_CD', 'ASS2_FLD_CD',
 'ASS3_FLD_CD', 'ASS4_FLD_CD', 'ASS5_FLD_CD', 'EVENT_ID', 'HOME_TEAM_ID', 'BAT_TEAM_ID', 'FLD_TEAM_ID', 'BAT_LAST_ID', 'INN_NEW_FL',
 'INN_END_FL', 'START_BAT_SCORE_CT', 'START_FLD_SCORE_CT', 'INN_RUNS_CT', 'GAME_PA_CT', 'INN_PA_CT', 'PA_NEW_FL', 'PA_TRUNC_FL',
 'START_BASES_CD', 'END_BASES_CD', 'BAT_START_FL', 'PIT_START_FL', 'RUN1_FLD_CD', 'RUN1_LINEUP_ID', 'RUN1_ORIGIN_EVENT_ID',
 'RUN2_FLD_CD', 'RUN2_LINEUP_ID', 'RUN2_ORIGIN_EVENT_ID', 'RUN3_FLD_CD', 'RUN3_LINEUP_ID', 'RUN3_ORIGIN_EVENT_ID', 'PA_BALL_CT',
 'PA_INTENT_BALL_CT', 'PA_PITCHOUT_BALL_CT', 'PA_OTHER_BALL_CT', 'PA_STRIKE_CT', 'PA_CALLED_STRIKE_CT', 'PA_SWINGMISS_STRIKE_CT',
 'PA_FOUL_STRIKE_CT', 'PA_OTHER_STRIKE_CT', 'EVENT_RUNS_CT', 'FLD_ID', 'BASE2_FORCE_FL', 'BASE3_FORCE_FL', 'BASE4_FORCE_FL',
 'BAT_SAFE_ERR_FL', 'BAT_FATE_ID', 'RUN1_FATE_ID', 'RUN2_FATE_ID', 'RUN3_FATE_ID', 'FATE_RUNS_CT', 'ASS6_FLD_CD', 'ASS7_FLD_CD',
 'ASS8_FLD_CD', 'ASS9_FLD_CD', 'ASS10_FLD_CD', 'UNKNOWN_OUT_EXC_FL', 'UNCERTAIN_PLAY_EXC_FL')
$Global:RSGameHeaders = @('GAME_ID', 'GAME_DT', 'GAME_CT', 'GAME_DY', 'START_GAME_TM', 'DH_FL', 'DAYNIGHT_PARK_CD', 'AWAY_TEAM_ID',
 'HOME_TEAM_ID', 'PARK_ID', 'AWAY_START_PIT_ID', 'HOME_START_PIT_ID', 'BASE4_UMP_ID', 'BASE1_UMP_ID', 'BASE2_UMP_ID',
 'BASE3_UMP_ID', 'LF_UMP_ID', 'RF_UMP_ID', 'ATTEND_PARK_CT', 'SCORER_RECORD_ID', 'TRANSLATOR_RECORD_ID', 'INPUTTER_RECORD_ID',
 'INPUT_RECORD_TS', 'EDIT_RECORD_TS', 'METHOD_RECORD_CD', 'PITCHES_RECORD_CD', 'TEMP_PARK_CT', 'WIND_DIRECTION_PARK_CD',
 'WIND_SPEED_PARK_CT', 'FIELD_PARK_CD', 'PRECIP_PARK_CD', 'SKY_PARK_CD', 'MINUTES_GAME_CT', 'INN_CT', 'AWAY_SCORE_CT',
 'HOME_SCORE_CT', 'AWAY_HITS_CT', 'HOME_HITS_CT', 'AWAY_ERR_CT', 'HOME_ERR_CT', 'AWAY_LOB_CT', 'HOME_LOB_CT', 'WIN_PIT_ID',
 'LOSE_PIT_ID', 'SAVE_PIT_ID', 'GWRBI_BAT_ID', 'AWAY_LINEUP1_BAT_ID', 'AWAY_LINEUP1_FLD_CD', 'AWAY_LINEUP2_BAT_ID',
 'AWAY_LINEUP2_FLD_CD', 'AWAY_LINEUP3_BAT_ID', 'AWAY_LINEUP3_FLD_CD', 'AWAY_LINEUP4_BAT_ID', 'AWAY_LINEUP4_FLD_CD',
 'AWAY_LINEUP5_BAT_ID', 'AWAY_LINEUP5_FLD_CD', 'AWAY_LINEUP6_BAT_ID', 'AWAY_LINEUP6_FLD_CD', 'AWAY_LINEUP7_BAT_ID',
 'AWAY_LINEUP7_FLD_CD', 'AWAY_LINEUP8_BAT_ID', 'AWAY_LINEUP8_FLD_CD', 'AWAY_LINEUP9_BAT_ID', 'AWAY_LINEUP9_FLD_CD',
 'HOME_LINEUP1_BAT_ID', 'HOME_LINEUP1_FLD_CD', 'HOME_LINEUP2_BAT_ID', 'HOME_LINEUP2_FLD_CD', 'HOME_LINEUP3_BAT_ID',
 'HOME_LINEUP3_FLD_CD', 'HOME_LINEUP4_BAT_ID', 'HOME_LINEUP4_FLD_CD', 'HOME_LINEUP5_BAT_ID', 'HOME_LINEUP5_FLD_CD',
 'HOME_LINEUP6_BAT_ID', 'HOME_LINEUP6_FLD_CD', 'HOME_LINEUP7_BAT_ID', 'HOME_LINEUP7_FLD_CD', 'HOME_LINEUP8_BAT_ID',
 'HOME_LINEUP8_FLD_CD', 'HOME_LINEUP9_BAT_ID', 'HOME_LINEUP9_FLD_CD', 'AWAY_FINISH_PIT_ID', 'HOME_FINISH_PIT_ID')
Function Get-RSDataFiles {
 Param
 (
  [string]$DownloadFile = 'C:\retrosheet\data\zipped\retrosheet_zip_files.txt',
  [string]$7zipPath = 'C:\Program Files\7-Zip\7z.exe',
  [string]$DownloadPath = 'C:\retrosheet\data\zipped',
  [string]$UnzipPath = 'C:\Retrosheet\data\unzipped'
 )
 Begin {
  if (Test-Path $DownloadFile) {
   Set-Location $DownloadPath;
   foreach ($FileUri in (Get-Content $DownloadFile)) {
    [System.Uri]$Uri = New-Object System.Uri $FileUri;
    Write-Verbose "Downloading $($FileUri)"
    Invoke-WebRequest -Uri $Uri -OutFile $Uri.Segments[$Uri.Segments.Count - 1]
   }
  }
  else {
   throw "File not found";
   break;
  }
 }
 Process {
  if (Test-Path $7zipPath) {
   Set-Location $DownloadPath;
   $Command = "& '$($7zipPath)' e *.zip -y -o$($UnzipPath)";
   Write-Verbose "Unzipping files"
   Invoke-Expression -Command $Command;
  }
  else {
   throw "7zip not found";
  }
 }
}
Function Get-RSEvent {
 <#
 C:\Retrosheet\common\programs\cwevent -f 0-96 -x 0-60 -y 2014 2014*.ev* > C:\Retrosheet\data\parsed\all2014.csv
 #>
 [CmdletBinding()]
 Param
 (
  [string]$Fields = "0-96",
  [string]$ExtendedFields = "0-60",
  [string]$Year,
  [string]$File
 )
 Begin {
  Invoke-RSChadwick -Fields $Fields -ExtendedFields $ExtendedFields -Year $Year -File $File -CWEVENT;
 }
}
Function Get-RSGame {
 <#
 C:\Retrosheet\common\programs\cwgame -f 0-83 -y 2014 2014*.ev* > C:\Retrosheet\data\parsed\games2014.csv
 #>
 [CmdletBinding()]
 Param
 (
  [string]$Fields = "0-83",
  [string]$Year,
  [string]$File
 )
 Begin {
  Invoke-RSChadwick -Fields $Fields -Year $Year -File $File -CWGAME;
 }
}
Function Get-RSSub {
 <#
 C:\Retrosheet\common\programs\cwsub -f 0-9 -y 2014 2014*.ev* > C:\Retrosheet\data\parsed\sub2014.csv
 #>
 [CmdletBinding()]
 Param
 (
  [string]$Fields = "0-9",
  [string]$Year,
  [string]$File
 )
 Begin {
  Invoke-RSChadwick -Fields $Fields -Year $Year -File $File -CWSUB;
 }
}
Function Get-RSData {
 [CmdletBinding()]
 Param
 (
  [ValidateSet('events', 'games', 'sub')]
  [string]$Type,
  [string]$RetroSheet = "C:\retrosheet\data\parsed"
 )
 Begin {
  switch ($Type) {
   'events' {
    $Headers = $Global:RSEventHeaders
    foreach ($EventFile in Get-ChildItem $RetroSheet -Filter "all*.csv") {
     Import-Csv -Delimiter ',' -Path $EventFile.FullName -Header $Headers
    }
   }
   'games' {
    $Headers = $Global:RSGameHeaders
    foreach ($EventFile in Get-ChildItem $RetroSheet -Filter "games*.csv") {
     Import-Csv -Delimiter ',' -Path $EventFile.FullName -Header $Headers
    }
   }
  }
 }
 Process {
 }
}
Function Invoke-RSChadwick {
 <#
 C:\Retrosheet\common\programs\cwevent -f 0-96 -x 0-60 -y 2014 2014*.ev* > C:\Retrosheet\data\parsed\all2014.csv
 #>
 <#
 C:\Retrosheet\common\programs\cwgame -f 0-83 -y 2014 2014*.ev* > C:\Retrosheet\data\parsed\games2014.csv
 #>
 <#
 C:\Retrosheet\common\programs\cwsub -f 0-9 -y 2014 2014*.ev* > C:\Retrosheet\data\parsed\sub2014.csv
 #>
 [CmdletBinding()]
 Param
 (
  [Parameter(ParameterSetName = 'cwevent')]
  [Parameter(ParameterSetName = 'cwgame')]
  [Parameter(ParameterSetName = 'cwsub')]
  [string]$Fields = "0-96",
  [Parameter(ParameterSetName = 'cwevent')]
  [string]$ExtendedFields = "0-60",
  [Parameter(ParameterSetName = 'cwevent')]
  [Parameter(ParameterSetName = 'cwgame')]
  [Parameter(ParameterSetName = 'cwsub')]
  [string]$Year,
  [Parameter(ParameterSetName = 'cwevent')]
  [Parameter(ParameterSetName = 'cwgame')]
  [Parameter(ParameterSetName = 'cwsub')]
  [string]$File,
  [Parameter(ParameterSetName = 'cwevent')]
  [switch]$CWEVENT,
  [Parameter(ParameterSetName = 'cwgame')]
  [switch]$CWGAME,
  [Parameter(ParameterSetName = 'cwsub')]
  [switch]$CWSUB
 )
 Begin {
  if ($CWEVENT) {
   $Command = "C:\Retrosheet\common\programs\cwevent -f $($Fields) -x $($ExtendedFields) -y $($Year) $($File)";
  }
  if ($CWGAME) {
   $Command = "C:\Retrosheet\common\programs\cwgame -f $($Fields) -y $($Year) $($File)";
  }
  if ($CWSUB) {
   $Command = "C:\Retrosheet\common\programs\cwsub -f $($Fields) -y $($Year) $($File)";
  }
  Write-Verbose $Command
  Invoke-Expression -Command $Command;
 }
}