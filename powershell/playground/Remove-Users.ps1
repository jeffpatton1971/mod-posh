<#
    .SYNOPSIS
         a script that will pull user names from an excel sheet
    .DESCRIPTION
         a script that will pull user names from an excel sheet, 
         find them in active directory, and delete the user account 
         and the associated user's folders.
    .PARAMETER FilePath
        The full path and filename of the excel spreadsheet
    .EXAMPLE
        .\Remove-Users -FilePath C:\Temp\Users.xlsx
    .NOTES
        ScriptName : Remove-Users.ps1
        Created By : jspatton
        Date Coded : 05/01/2012 13:33:04
        ScriptName is used to register events for this script
 
        ErrorCodes
            100 = Success
            101 = Error
            102 = Warning
            104 = Information
        
        You must have the rights to actually delete user objects
    .LINK
        https://code.google.com/p/mod-posh/wiki/Production/Remove-Users.ps1
 #>
[CmdletBinding()]
Param
    (
    $FilePath = "C:\TEMP\users.xlsx"
    )
Begin
    {
        $ScriptName = $MyInvocation.MyCommand.ToString()
        $ScriptPath = $MyInvocation.MyCommand.Path
        $Username = $env:USERDOMAIN + "\" + $env:USERNAME
 
        New-EventLog -Source $ScriptName -LogName $LogName -ErrorAction SilentlyContinue
 
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nStarted: " + (Get-Date).toString()
        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message
 
        #	Dotsource in the functions you need.
        try
        {
            Write-Verbose "Creating Excel object"
            $Excel = New-Object -ComObject Excel.Application
            Write-Verbose "Open the file located at $($FilePath)"
            $Workbook = $Excel.Workbooks.Open($FilePath)
            Write-Verbose "Set the active sheet to the first sheet"
            $Worksheet = $Workbook.Worksheets.Item(1)
            }
        catch
        {
            $Message = $Error[0].Exception
            Write-Verbose $Message
            Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "101" -EntryType "Error" -Message $Message
            }
        }
Process
    {
        Write-Verbose "Start importing users at row 2"
        $Row = 2
        $Column = 1
        Write-Verbose "Read in the ADSPath from the first cell in the sheet"
        $AdsPath = $Worksheet.Cells.item(1,1).Value()
        
        Write-Verbose "Create a DirectoryEntry object for $($AdsPath)"
        $DirectoryEntry = New-Object System.DirectoryServices.DirectoryEntry($ADSPath)
        Write-Verbose "Create a new DirectorySearcher object to find the user"
        $DirectorySearcher = New-Object System.DirectoryServices.DirectorySearcher


        while ($Worksheet.Cells.item($Row,$Column).Value() -ne $null)
        {
            Write-Verbose "Look for users until we find a blank cell"
            $UserName = $Worksheet.Cells.Item($Row,$Column).Value()
            Write-Verbose "Found $($Username)"
            
            Write-Verbose "Create a searchfilter"
            $SearchFilter = "(&(objectClass=user)(sAMAccountName= $UserName))"
            Write-Verbose "SearchFilter = $($SearchFilter)"
            Write-Verbose "Set the root to the DirectoryEntry object"
            $DirectorySearcher.SearchRoot = $DirectoryEntry
            Write-Verbose "Set the pagesize, this isn't really needed since we're doing FindOne()"
            $DirectorySearcher.PageSize = 1000
            Write-Verbose "Add the homeDirectory property"
            [void]$DirectorySearcher.PropertiesToLoad.Add('homeDirectory')
            Write-Verbose "Assign the searchfilter to the DirectorySearcher"
            $DirectorySearcher.Filter = $SearchFilter
            Write-Verbose "Walk the path to find objects"
            $DirectorySearcher.SearchScope = "Subtree"
            
            Write-Verbose "Do the search"
            $Account = $DirectorySearcher.FindOne()
            $Account
            Write-Verbose "Create the user object"
            $User = [adsi]"$($Account.Properties.adspath)"
            Write-Verbose "Call the DeleteTree() method of the user object"
            $User
            $User.DeleteTree()
            Write-Verbose "$($UserName) deleted"
            Write-Verbose "Deleteing homeDirectory $($Account.Properties.homedirectory)"
            Remove-Item -Path $Account.Properties.homedirectory -Recurse -Force
            $Row ++
            }
        }
End
    {
        $Excel.Quit()
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Excel)
        return $User
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message	
        }