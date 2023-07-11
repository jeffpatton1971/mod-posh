#
# Jira Issue Classes
#
class JiraId {
 [string] $id = ''
 JiraId () {}
 JiraId ([string]$Id) {
  $this.Id = $id;
 }
}
class JiraValue {
 [string] $value = ''
 JiraValue () {}
 JiraValue ([string]$Value) {
  $this.Value = $Value;
 }
}
class JiraContent {
 [ValidateSet('text')]
 [string] $type = 'text'
 [string] $text = ''
 JiraContent () {}
 JiraContent ([string]$Text) {
  $this.Text = $Text;
 }
}
class JiraDocumentContent {
 [ValidateSet('paragraph')]
 [string]$type = 'paragraph'
 [JiraContent[]] $content
 JiraDocumentContent () {
  $this.Content = New-Object JiraContent;
 }
 JiraDocumentContent ([string]$Text) {
  $this.Text = $Text;
  $this.Content.Add((New-Object JiraContent $Text));
 }
}
class JiraTimeTracking {
 [string] $originalEstimate = '5'
 JiraTimeTracking () {}
 JiraTimeTracking ([int]$OriginalEstimate) {
  $this.OriginalEstimate = $OriginalEstimate;
 }
}
class JiraDocument {
 [JiraDocumentContent[]] $content
 [string] $type = 'doc'
 [int] $version = 1
 JiraDocument () {
  $this.Content = New-Object JiraDocumentContent;
 }
}
class JiraFields {
 [JiraId] $assignee
 [JiraId[]] $components
 [string] $customfield_10001
 [int] $customfield_10000
 [JiraDocument] $description
 [JiraId] $issuetype
 [JiraId] $priority
 [JiraId] $project
 [JiraId] $reporter
 [string] $summary = ''
 [JiraTimeTracking] $timetracking
 JiraFields () {
  $this.Assignee = New-Object JiraId;
  $this.Description = New-Object JiraDocument;
  $this.Components = New-Object JiraId;
  $this.IssueType = New-Object JiraId;
  $this.Priority = New-Object JiraId;
  $this.Project = New-Object JiraId;
  $this.Reporter = New-Object JiraId;
  $this.TimeTracking = New-Object JiraTimeTracking;
 }
}
class JiraKey {
 [string] $key = ''
 JiraKey () {}
 JiraKey ([string]$Key) {
  $this.Key = $Key;
 }
}
class JiraType {
 [ValidateSet('Relates')]
 [string] $name = 'Relates'
 JiraType () {}
 JiraType ([string]$Name) {
  $this.Name = $Name;
 }
}
class JiraLinkType {
 [JiraKey] $outwardIssue
 [JiraType] $type
 JiraLinkType () {
  $this.Outwardissue = New-Object JiraKey;
  $this.Type = New-Object JiraType;
 }
 JiraLinkType ([string]$Outwardissue) {
  $this.Outwardissue = New-Object JiraKey $Outwardissue;
  $this.Type = New-Object JiraType;
 }
}
class JiraIssueLink {
 [JiraLinkType] $add
 JiraIssueLink () {
  $this.Add = New-Object JiraLinkType;
 }
}
class JiraUpdate {
 [JiraIssueLink[]] $issuelinks
 JiraUpdate () {
  $this.IssueLinks = New-Object JiraIssueLink;
 }
}
class JiraIssue {
 [JiraFields] $fields
 [JiraUpdate] $update
 JiraIssue () {
  $this.Fields = New-Object JiraFields;
  $this.Update = New-Object JiraUpdate;
 }
 [object]ToString() {
  return $this | ConvertTo-Json -Depth 20 -Compress;
 }
}
#
# Jira Functions
#
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
  [switch]$ThisWeek,
  [switch]$LastWeek,
  [switch]$CurrentWork
 )

 if ($LastWeek) {
  $StartOfWeek = Get-FirstDateOfWeek -Year ((Get-Date).AddDays(-7).Year);
  $EndOfWeek = $StartOfWeek.AddDays(4);
  $StartOfWeekShort = (Get-Date ($StartOfWeek) -Format yyyy-MM-dd);
  $EndOfWeekShort = (Get-Date ($EndOfWeek) -Format yyyy-MM-dd);

  return 'project = MPCSUPENG AND worklogAuthor in (currentUser()) and worklogDate >= "' + $StartOfWeekShort + '" AND worklogDate <= "' + $EndOfWeekShort + '"'
 }

 if ($Today) {
  $StartOfWeek = Get-Date;
  $EndOfWeek = Get-Date;
  $StartOfWeekShort = (Get-Date ($StartOfWeek) -Format yyyy-MM-dd);
  $EndOfWeekShort = (Get-Date ($EndOfWeek) -Format yyyy-MM-dd);

  return 'project = MPCSUPENG AND worklogAuthor in (currentUser()) and worklogDate >= "' + $StartOfWeekShort + '" AND worklogDate <= "' + $EndOfWeekShort + '"'
 }

 if ($ThisWeek) {
  $StartOfWeek = (Get-Date).AddDays( - ( [int](Get-Date).DayOfWeek - 1));
  $EndOfWeek = $StartOfWeek.AddDays(4);
  $StartOfWeekShort = (Get-Date ($StartOfWeek) -Format yyyy-MM-dd);
  $EndOfWeekShort = (Get-Date ($EndOfWeek) -Format yyyy-MM-dd);

  return 'project = MPCSUPENG AND worklogAuthor in (currentUser()) and worklogDate >= "' + $StartOfWeekShort + '" AND worklogDate <= "' + $EndOfWeekShort + '"'
 }

 if ($CurrentWork) {
  return 'project=MPCSUPENG AND (status="New" OR status="In Progress" Or status="Waiting")AND assignee=currentuser()'
 }
}
function New-Task {
 [CmdletBinding()]
 param(
  [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
  [string]$User,
  [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
  [string]$ProjectName,
  [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
  [string]$Priority,
  [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
  [int]$OriginalEstimate,
  [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
  [string]$IssueType,
  [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
  [string]$ComponentName,
  [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
  [string]$SprintName,
  [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
  [string]$EpicName,
  [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
  [string]$ParentIssue,
  [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
  [string]$Summary,
  [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
  [string]$Description,
  [string]$SearchUri = $JiraUris.SearchUri,
  [string]$IssueUri = $JiraUris.IssueUri,
  [string]$SprintUri = $JiraUris.SprintUri,
  [object]$Headers = $Headers,
  [object]$jiraCred = $jiraCred
  )
 begin {
 }
 process {
  $ErrorActionPreference = 'Stop';
  $Error.Clear();
  try {
   $Issue = New-Object JiraIssue;
   $jiraUser = Invoke-JiraMethod -URI "$($SearchUri)$($User)";
   $jiraProject = Get-JiraProject -Project $ProjectName;
   $jiraPriority = Get-JiraPriority | Where-Object -Property Name -eq $Priority;
   $jiraIssue = Get-JiraIssueType -IssueType $IssueType;
   $jiraComponent = Get-JiraComponent -Project $jiraProject.ID | Where-Object -Property Name -eq $ComponentName;
   $ActiveSprint = (Invoke-JiraMethod -URI ($SprintUri) -Method Get -Headers $Headers -Credential $jiraCred).Values[0]
   $Issue.Fields.Assignee = New-Object JiraId $jiraUser.accountId;
   $Issue.fields.description.Content[0].content[0].text = $Description;
   $Issue.Fields.Components = New-Object JiraId $jiraComponent.ID;
   $Issue.Fields.TimeTracking.OriginalEstimate = $OriginalEstimate;
   $Issue.Fields.customfield_10000 = $ActiveSprint.id;
   $Issue.Fields.customfield_10001 = $EpicName;
   $Issue.Fields.IssueType = New-Object JiraId $jiraIssue.ID;
   $Issue.Fields.Priority = New-Object JiraId $jiraPriority.ID;
   $Issue.Fields.Project = New-Object JiraId $jiraProject.ID;
   $Issue.Fields.Reporter = New-Object JiraId $jiraUser.accountId;
   $Issue.Fields.Summary = $Summary;
   $Issue.Update.IssueLinks[0].Add[0].Outwardissue = $ParentIssue;
   Write-Verbose $Issue.ToString();
   return Invoke-JiraMethod -URI $IssueUri -Method Post -Body ($Issue.ToString()) -Headers $Headers -Credential $jiraCred -Verbose:$VerbosePreference;
  }
  catch {
   throw $_;
  }
 }
 end {
 }
}