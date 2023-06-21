<#
New-WorkLogReport -Log (Get-JiraIssue -Query (Get-IssueQuery) |Get-Worklog)

Hours Date
----- ----
 4.00 12-23-2022
 4.00 12-27-2022
10.50 12-28-2022
 2.50 12-29-2022
#>
function Get-Worklog {
 [CmdletBinding()]
 param(
  [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
  [object]$Issue
 )
 begin {
 }
 process {
  $ErrorActionPreference = 'Stop';
  $Error.Clear();
  try {
   $WorkLog = $Issue.worklog.worklogs | Select-Object -Property @{Label = 'Date'; Exp = { (Get-Date $_.Started -Format MM-dd-yyyy) } }, @{Label = 'Seconds'; Exp = { $_.timeSpentSeconds } };
   foreach ($Group in ($WorkLog | Group-Object -Property Date)) {
    $Date = $Group.Name;
    $Seconds = ($Group.Group | Measure-Object -Property Seconds -Sum).Sum;
    New-Object -TypeName psobject -Property @{Date = $Date; Seconds = $Seconds }
   }

  }
  catch {
   throw $_;
  }
 }
 end {
 }
}

function New-WorkLogReport {
 [CmdletBinding()]
 param(
  [Parameter(Mandatory = $true)]
  [object]$Log
 )
 $ErrorActionPreference = 'Stop';
 $Error.Clear();
 try {
  foreach ($Group in ($Log | Group-Object -Property Date)) {
   $Date = $Group.Name;
   $Seconds = ($Group.Group | Measure-Object -Property Seconds -Sum).Sum;
   $Hours = (New-TimeSpan -Seconds $Seconds).TotalHours;
   New-Object -TypeName psobject -Property @{Date = $Date; Hours = $Hours }
  }
 }
 catch {
  throw $_;
 }
}

function Get-WeekOfYear {
 param (
  [DateTime]$Time = (Get-Date).AddDays(-7)
 )
 [System.DayOfWeek]$Day = [System.Globalization.CultureInfo]::InvariantCulture.Calendar.GetDayOfWeek((Get-Date));
 if ($Day -gt [System.DayOfWeek]::Monday -and $Day -lt [System.DayOfWeek]::Wednesday) { $Time = $Time.AddDays(3) };
 return ([System.Globalization.CultureInfo]::InvariantCulture.Calendar.GetWeekOfYear($Time, [System.Globalization.CalendarWeekRule]::FirstFourDayWeek, [System.DayOfWeek]::Monday));
}

function Get-FirstDateOfWeek {
 param (
  [int]$Year,
  [int]$WeekOfYear = (Get-WeekOfYear)
 )
 $jan1 = [DateTime]"$year-01-01"
 $daysOffset = ([DayOfWeek]::Thursday - $jan1.DayOfWeek)

 $firstThursday = $jan1.AddDays($daysOffset)
 $calendar = ([CultureInfo]::CurrentCulture).Calendar;

 $firstWeek = $calendar.GetWeekOfYear($firstThursday, [System.Globalization.CalendarWeekRule]::FirstFourDayWeek, [DayOfWeek]::Monday)

 $weekNum = $weekOfYear

 if ($firstweek -le 1) { $weekNum -= 1 }

 $result = $firstThursday.AddDays($weekNum * 7)
 return $result.AddDays(-3)
}

function Get-IssueQuery {
 param(
  [switch]$Today,
  [switch]$ThisWeek
 )

 $StartOfWeek = Get-FirstDateOfWeek -Year ((Get-Date).AddDays(-7).Year);
 $EndOfWeek = $StartOfWeek.AddDays(4);

 if ($Today) {
  $StartOfWeek = Get-Date;
  $EndOfWeek = Get-Date;
 }

 if ($ThisWeek)
 {
  $StartOfWeek = (Get-Date).AddDays(-( [int](Get-Date).DayOfWeek -1));
  $EndOfWeek = $StartOfWeek.AddDays(4);
  }

 $StartOfWeekShort = (Get-Date ($StartOfWeek) -Format yyyy-MM-dd);
 $EndOfWeekShort = (Get-Date ($EndOfWeek) -Format yyyy-MM-dd);

 return 'project = MPCSUPENG AND worklogAuthor in (currentUser()) and worklogDate >= "' + $StartOfWeekShort + '" AND worklogDate <= "' + $EndOfWeekShort + '"'
}