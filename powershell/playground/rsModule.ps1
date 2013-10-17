Function Get-rsInfo
{
    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER
        .EXAMPLE
        .NOTES
            FunctionName : Get-rsInfo
            Created by   : jspatton
            Date Coded   : 10/08/2013 08:44:20
        .LINK
            https://code.google.com/p/mod-posh/wiki/Untitled7#Get-rsInfo
    #>
    [CmdletBinding()]
    Param
        (
        [string[]]$Line,
        [string]$GameID
        )
    Begin
    {
        $LineArray = $Line.Split(",")
        }
    Process
    {
        $Return = New-Object -TypeName psobject -Property @{
            GameID = $GameID
            Table = $LineArray[0]
            Field = $LineArray[1]
            Value = $LineArray[2]
            }
        $Return = @{$LineArray[1] = $LineArray[2]}
        }
    End
    {
        Return $Return
        }
    }
Function Get-rsStart
{
    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER
        .EXAMPLE
        .NOTES
            FunctionName : Get-rsInfo
            Created by   : jspatton
            Date Coded   : 10/08/2013 08:44:20
        .LINK
            https://code.google.com/p/mod-posh/wiki/Untitled7#Get-rsInfo
    #>
    [CmdletBinding()]
    Param
        (
        [string[]]$Line,
        [string]$GameId
        )
    Begin
    {
        $LineArray = $Line.Split(",")
        }
    Process
    {
        if ($LineArray[3] -eq 1)
        {
            $HomeTeam = $true
            }
        else
        {
            $HomeTeam = $false
            }
        if ($LineArray[2].Contains("'"))
        {
            $PlayerName = $LineArray[2].Replace("'","''")
            }
        else
        {
            $PlayerName = $LineArray[2]
            }
        $Return = New-Object -TypeName psobject -Property @{
            GameID = $GameId
            Table = $LineArray[0]
            PlayerID = $LineArray[1]
            PlayerName = $PlayerName
            HomeTeam = $HomeTeam
            Batting = $LineArray[4]
            Position = $LineArray[5]
            }
        }
    End
    {
        Return $Return
        }
    }
Function Get-rsPlay
{
    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER
        .EXAMPLE
        .NOTES
            FunctionName : Get-rsInfo
            Created by   : jspatton
            Date Coded   : 10/08/2013 08:44:20
        .LINK
            https://code.google.com/p/mod-posh/wiki/Untitled7#Get-rsInfo
    #>
    [CmdletBinding()]
    Param
        (
        [string[]]$Line,
        [string]$GameId
        )
    Begin
    {
        $LineArray = $Line.Split(",")
        }
    Process
    {
        if ($LineArray[2] -eq 1)
        {
            $HomeTeam = $true
            }
        else
        {
            $HomeTeam = $false
            }
        $Return = New-Object -TypeName psobject -Property @{
            GameID = $GameId
            Table = $LineArray[0]
            Inning = $LineArray[1]
            HomeTeam = $HomeTeam
            PlayerID = $LineArray[3]
            PitchCount = $LineArray[4]
            Pitches = $LineArray[5]
            Play = $LineArray[6]
            }
        }
    End
    {
        Return $Return
        }
    }
Function Get-rsData
{
    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER
        .EXAMPLE
        .NOTES
            FunctionName : Get-rsInfo
            Created by   : jspatton
            Date Coded   : 10/08/2013 08:44:20
        .LINK
            https://code.google.com/p/mod-posh/wiki/Untitled7#Get-rsInfo
    #>
    [CmdletBinding()]
    Param
        (
        [string[]]$Line,
        [string]$GameId
        )
    Begin
    {
        $LineArray = $Line.Split(",")
        }
    Process
    {
        if ($LineArray[2] -eq 1)
        {
            $HomeTeam = $true
            }
        else
        {
            $HomeTeam = $false
            }
        $Return = New-Object -TypeName psobject -Property @{
            GameID = $GameId
            Table = $LineArray[0]
            Type = $LineArray[1]
            PlayerID = $LineArray[2]
            Runs = $LineArray[3]
            }
        }
    End
    {
        Return $Return
        }
    }