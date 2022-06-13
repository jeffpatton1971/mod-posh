<#
.SYNOPSIS
    Sync Obsidian Notebooks using Git.
.DESCRIPTION
    This script will sync Obsidian notebooks using a git repository. You will need
    to setup and configure the repo in advance, please see the note section for a 
    useful articles.
.PARAMETER Path
    A string to the Obsidian Vault's location.
.NOTES
    ScriptName : Sync-Obsidian.ps1
    Created By : jspatton
    Date Coded : 06/13/2022 11:41:27
.LINK
    [Setting up Git](https://medium.com/analytics-vidhya/how-i-put-my-mind-under-version-control-24caea37b8a5)
    [Link to Original bash](https://gist.github.com/tallguyjenks/ca3339b8b5353159f631836268e3f791#file-zk_sync-sh)
    [Schedule Task](https://techgenix.com/how-to-schedule-powershell-scripts/)
    [Microsoft Task WIki](https://social.technet.microsoft.com/wiki/contents/articles/53833.run-powershell-script-with-windows-task-scheduler.aspx)
#>
param (
    [string]$Path
)

try  {
    $ErrorActionPreference = 'Stop';
    $Error.Clear();

    Set-Location $Path;
    #
    # Change Directory to your vault's location
    #
    (& git pull);
    #
    # If any changes occurred remotely or on another machine
    # your local machine knows to pull those changes down instead of
    # having to wait for a local change to run the script
    #
    $Changes = (& git status --porcelain |Measure-Object -line).Lines;
    #
    # We are assigning a value to the variable `CHANGES`, the value is the output
    # of `git add --porcelain` which outputs a simple list of just the
    # changed files and then the output is piped into the `Measure-Object` cmdlet
    # which is "word count" but with the `-l` flag it will count lines.
    # basically, it says how many total files have been modified.
    # if there are no changes the output is 0
    #
    if ($Changes -ne 0) {
        (& git pull);
        #
        # git pull: this will look at your repo and say "any changes?"
        # if there are they will be brought down and applied to your local machine
        # In the context of a team environment, a more robust approach is needed
        # as this workflow doesnt factor in branches, merge conflicts, etc
        # but if you leave your home machine, do work on the work machine,
        # push to the remote repo before you return to the home machine, then
        # you can just get the latest changes applied to the home machine and
        # continue on like normal
        #
        (& git add .);
        #
        # git add. = add all current changes in the repo no
        # matter the level of nested folders/files
        #
        (& git commit -q -m "Last Sync: $(Get-Date -Format 'yyyy/MM/dd HH:mm:ss')");
        #
        # git commit -q -m: this says we are committing changes to
        # our repo, -q says BE QUIET no output prints to terminal
        # if ran manually, -m defines a message for the commit log
        # the -m message is "Last Sync: $(Get-Date -Format 'yyyy/MM/dd HH:mm:ss')" this
        # runs the command date with the formatting arguments for a
        # date in YYYY/MM/DD HH:MM:SS format as your commit message
        #
        (& git push -q);
        #
        # git push -q: push the changes to github and
        # BE QUIET about it The semicolons between commands are
        # just saying run each command and then run the subsequent
        # command, they're just separators
        #
    }
} catch {
    throw $_;
}