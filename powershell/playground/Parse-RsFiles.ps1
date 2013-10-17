$RawEvents = Get-Content C:\Users\jspatton\Downloads\2012eve\2012KCA.EVA
$Counter = 0
foreach ($Line in $RawEvents)
{
    #
    # Find the GAME ID
    #
    $Counter ++
    $LineArray = $Line.Split(',')
    if ($LineArray[0] -eq "id")
    {
        #
        # Are we on a new record, if so send to sql
        #
        $SqlServer = ""
        $SqlDatabase = ""
        $SqlUser = ""
        $SqlPass = ""
        $SqlConn = New-Object System.Data.SqlClient.SqlConnection("Server=$($SqlServer);Database=$($SqlDatabase);Uid=$($SqlUser);Pwd=$($SqlPass);Trusted_Connection=False;Encrypt=True;Connection Timeout=30;")
        $SqlConn.Open()
        $Sqlcmd = $SqlConn.CreateCommand()
        if ($Info)
        {
            $FieldNames = $null
            foreach ($Field in $Info.Keys){ $FieldNames += "[$($Field)]," }
            $FieldNames = $FieldNames.Remove($FieldNames.Length -1,1)
            $Values = $null
            foreach ($Value in $Info.Values){ $Values += "'$($Value)'," }
            $Values = $Values.Remove($Values.Length -1,1)
            $sqlQuery = "INSERT INTO [dbo].[info] ($($FieldNames), [gameid]) VALUES ($($Values),'$($GameID)')"
            $Sqlcmd.CommandText = $sqlQuery
            $Sqlcmd.ExecuteNonQuery() |Out-Null
            }
        if ($Start)
        {
            foreach ($Player in $Start)
            {
                $sqlQuery = "INSERT INTO [dbo].[start] ([gameid],[playerid],[playername],[hometeam],[batting],[position]) `
                             VALUES ('$($Player.GameID)','$($Player.PlayerID)','$($Player.PlayerName)','$($Player.HomeTeam)','$($Player.Batting)','$($Player.Position)')"
                $Sqlcmd.CommandText = $sqlQuery
                $Sqlcmd.ExecuteNonQuery() |Out-Null
               }
            }
        if ($Play)
        {
            foreach ($atBat in $Play)
            {
                $sqlQuery = "INSERT INTO [dbo].[play] ([inning],[hometeam],[playerid],[count],[pitches],[play],[gameid]) `
                             VALUES ('$($atBat.Inning)','$($atBat.HomeTeam)','$($atBat.PlayerID)','$($atBat.PitchCount)','$($atBat.Pitches)','$($atBat.Play)','$($atBat.GameID)')"
                $Sqlcmd.CommandText = $sqlQuery
                $Sqlcmd.ExecuteNonQuery() |Out-Null
                }
            }
        if ($Data)
        {
            foreach ($item in $Data)
            {
                $sqlQuery = "INSERT INTO [dbo].[data] ([type],[playerid],[runs],[gameid]) `
                             VALUES ('$($item.Type)','$($item.PlayerID)','$($item.Runs)','$($item.GameID)')"
                $Sqlcmd.CommandText = $sqlQuery
                $Sqlcmd.ExecuteNonQuery() |Out-Null
                }
            }
        $SqlConn.Close()

        $Info = @()
        $Start = @()
        $Play = @()
        $Data = @()
        }
    switch ($LineArray[0])
    {
        "id"
        {
            $GameID = $LineArray[1]
            }
        "version"
        {
            $VersionId = $LineArray[1]
            }
        "info"
        {
            
            $Info += Get-rsInfo -Line $LineArray -GameID $GameID
            }
        "start"
        {
            $Start += Get-rsStart -Line $LineArray -GameId $GameID
            }
        "play"
        {
            $Play += Get-rsPlay -Line $LineArray -GameId $GameID
            }
        "com"
        {
            }
        "sub"
        {
            }
        "data"
        {
            $Data += Get-rsData -Line $LineArray -GameId $GameID
            }
        }
    }