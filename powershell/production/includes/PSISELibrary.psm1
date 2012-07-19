Function Replace-TabsWithSpace
{
    <#
        .SYNOPSIS
            Replaces a tab character with 4 spaces
        .DESCRIPTION
            This function examines the selected text in the PSIE SelectedText property and every tab
            character that is found is replaced with 4 spaces.
        .PARAMETER SelectedText
            The current contents of the SelectedText property
        .PARAMETER InstallMenu
            Specifies if you want to install this as a PSIE add-on menu
        .EXAMPLE
            Replace-TabsWithSpace -InstallMenu $true
            
            Description
            -----------
            Installs the function as a menu item.
        .NOTES
            This was written specifically for me, I had some code originally created in Notepad++ that
            used actual tabs, later I changed that to spaces, but on occasion I come accross something
            that doesn't tab shift like it should. Since I've been doing some PowerShell ISE stuff lately
            I decided to write a little function that works as an Add-On menu.
        .LINK
            https://code.google.com/p/mod-posh/wiki/PSISELibrary#Replace-TabsWithSpace
    #>
    [CmdletBinding()]
    Param
        (
        $SelectedText = $psISE.CurrentFile.Editor.SelectedText,
        $InstallMenu
        )
    Begin
    {
        if ($InstallMenu)
        {
            Write-Verbose "Try to install the menu item, and error out if there's an issue."
            try
            {
                $psISE.CurrentPowerShellTab.AddOnsMenu.SubMenus.Add("Replace Tabs with Space",{Replace-TabsWithSpace},"Ctrl+Alt+R") | Out-Null
                }
            catch
            {
                Return $Error[0].Exception
                }
            }
        }
    Process
    {
        Write-Verbose "Try and find the tab character in the selected PSISE text, return an error if there's an issue."
        try
        {
            $psISE.CurrentFile.Editor.InsertText($SelectedText.Replace("`t","    "))
            }
        catch
        {
            Return $Error[0].Exception
            }
        }
    End
    {
        }
    }
Function New-CommentBlock
{
    <#
        .SYNOPSIS
            Inserts a full comment block
        .DESCRIPTION
            This function inserts a full comment block that is formatted the
            way I format all my comment blocks.
        .PARAMETER InstallMenu
            Specifies if you want to install this as a PSIE add-on menu
        .EXAMPLE
            New-CommentBlock -InstallMenu $true
            
            Description
            -----------
            Installs the function as a menu item.
        .NOTES
            FunctionName : New-CommentBlock
            Created by   : Jeff Patton
            Date Coded   : 09/13/2011 12:28:10
        .LINK
            https://code.google.com/p/mod-posh/wiki/PSISELibrary#New-CommentBlock
    #>
    [CmdletBinding()]
    Param
        (
        $InstallMenu
        )
    Begin
    {
        $WikiPage = ($psISE.CurrentFile.DisplayName).Substring(0,($psISE.CurrentFile.DisplayName).IndexOf("."))
        $CommentBlock = @(
            "    <#`r`n"
            "       .SYNOPSIS`r`n"
            "       .DESCRIPTION`r`n"
            "       .PARAMETER`r`n"
            "       .EXAMPLE`r`n"
            "       .NOTES`r`n"
            "           FunctionName : `r`n"
            "           Created by   : $($env:username)`r`n"
            "           Date Coded   : $(Get-Date)`r`n"
            "       .LINK`r`n"
            "           https://code.google.com/p/mod-posh/wiki/$($WikiPage)`r`n"
            "    #>`r`n")
        if ($InstallMenu)
        {
            Write-Verbose "Try to install the menu item, and error out if there's an issue."
            try
            {
                $psISE.CurrentPowerShellTab.AddOnsMenu.SubMenus.Add("Insert comment block",{New-CommentBlock},"Ctrl+Alt+C") | Out-Null
                }
            catch
            {
                Return $Error[0].Exception
                }
            }
        }
    Process
    {
        if (!$InstallMenu)
        {
            Write-Verbose "Don't insert a comment if we're installing the menu"
            try
            {
                Write-Verbose "Create a new comment block, return an error if there's an issue."
                $psISE.CurrentFile.Editor.InsertText($CommentBlock)
                }
            catch
            {
                Return $Error[0].Exception
                }
            }
        }
    End
    {
        }
    }
Function New-Script
{
    <#
        .SYNOPSIS
            Create a new blank script
        .DESCRIPTION
            This function creates a new blank script based on my original template.ps1
        .PARAMETER InstallMenu
            Specifies if you want to install this as a PSIE add-on menu
        .PARAMETER ScriptName
            This is the name of the new script.
        .EXAMPLE
            New-Script -ScriptName "New-ImprovedScript"
            
            Description
            -----------
            This example shows calling the function with the ScriptName parameter
        .EXAMPLE
            New-Script -InstallMenu $true
            
            Description
            -----------
            Installs the function as a menu item.
        .NOTES
            FunctionName : New-Script
            Created by   : Jeff Patton
            Date Coded   : 09/13/2011 13:37:24
        .LINK
            https://code.google.com/p/mod-posh/wiki/PSISELibrary#New-Script
    #>
    [CmdletBinding()]
    Param
        (
        $InstallMenu,
        $ScriptName
        )
    Begin
    {
        $TemplateScript = @(
        "<#`r`n"
        "   .SYNOPSIS`r`n"
        "       Template script`r`n"
        "   .DESCRIPTION`r`n"
        "       This script sets up the basic framework that I use for all my scripts.`r`n"
        "   .PARAMETER`r`n"
        "   .EXAMPLE`r`n"
        "   .NOTES`r`n"
        "       ScriptName : $($ScriptName)`r`n"
        "       Created By : $($env:Username)`r`n"
        "       Date Coded : $(Get-Date)`r`n"
        "       ScriptName is used to register events for this script`r`n"
        "`r`n"        
        "       ErrorCodes`r`n"
        "           100 = Success`r`n"
        "           101 = Error`r`n"
        "           102 = Warning`r`n"
        "           104 = Information`r`n"
        "   .LINK`r`n"
        "       https://code.google.com/p/mod-posh/wiki/Production/$($ScriptName)`r`n"
        "#>`r`n"
        "[CmdletBinding()]`r`n"
        "Param`r`n"
        "   (`r`n"
        "`r`n"    
        "   )`r`n"
        "Begin`r`n"
        "   {`r`n"
        "       `$ScriptName = `$MyInvocation.MyCommand.ToString()`r`n"
        "       `$ScriptPath = `$MyInvocation.MyCommand.Path`r`n"
        "       `$Username = `$env:USERDOMAIN + `"\`" + `$env:USERNAME`r`n"
        "`r`n"
        "       New-EventLog -Source `$ScriptName -LogName `'Windows Powershell`' -ErrorAction SilentlyContinue`r`n"
        "`r`n"
        "       `$Message = `"Script: `" + `$ScriptPath + `"``nScript User: `" + `$Username + `"``nStarted: `" + (Get-Date).toString()`n"
        "       Write-EventLog -LogName `'Windows Powershell`' -Source `$ScriptName -EventID `"104`" -EntryType `"Information`" -Message `$Message`r`n"
        "`r`n"
        "       #	Dotsource in the functions you need.`r`n"
        "       }`r`n"
        "Process`r`n"
        "   {`r`n"
        "       }`r`n"
        "End`r`n"
        "   {`r`n"
        "       `$Message = `"Script: `" + `$ScriptPath + `"``nScript User: `" + `$Username + `"``nFinished: `" + (Get-Date).toString()`n"
        "       Write-EventLog -LogName `'Windows Powershell`' -Source `$ScriptName -EventID `"104`" -EntryType `"Information`" -Message `$Message	`r`n"
        "       }`r`n")
        if ($InstallMenu)
        {
            Write-Verbose "Try to install the menu item, and error out if there's an issue."
            try
            {
                $psISE.CurrentPowerShellTab.AddOnsMenu.SubMenus.Add("New blank script",{New-Script},"Ctrl+Alt+S") | Out-Null
                }
            catch
            {
                Return $Error[0].Exception
                }
            }

        }
    Process
    {
        if (!$InstallMenu)
        {
            Write-Verbose "Don't create a script if we're installing the menu"
            try
            {
                Write-Verbose "Create a new empty script, return an error if there's an issue."
                if ($ScriptName.Substring(($ScriptName.Length)-4,4) -ne ".ps1")
                {
                    $ScriptName += ".ps1"
                    }
                New-Item -Path (Get-Location) -Name $ScriptName -ItemType File |Out-Null
                $NewScript = $psISE.CurrentPowerShellTab.Files.Add((Get-ChildItem $ScriptName)) 
                $NewScript.Editor.InsertText($TemplateScript)
                $NewScript.Editor.InsertText(($NewScript.Editor.Select(22,1,22,2) -replace " ",""))
                $NewScript.Editor.InsertText(($NewScript.Editor.Select(23,1,23,2) -replace " ",""))
                $NewScript.Editor.InsertText(($NewScript.Editor.Select(24,1,24,2) -replace " ",""))
                $NewScript.Editor.InsertText(($NewScript.Editor.Select(28,1,28,2) -replace " ",""))
                $NewScript.Editor.InsertText(($NewScript.Editor.Select(42,1,42,2) -replace " ",""))
                $NewScript.Editor.InsertText(($NewScript.Editor.Select(45,1,45,2) -replace " ",""))
                $NewScript.Editor.Select(1,1,1,1)
                $NewScript.SaveAs("$((Get-Location).Path)\$($ScriptName)")
                }
            catch
            {
                Return $Error[0].Exception
                }
            }
        }
    End
    {
        Return $NewScript
        }
    }
Function New-Function
{
    <#
        .SYNOPSIS
            Create a new function
        .DESCRIPTION
            This function creates a new function that wraps the selected text inside
            the Process section of the body of the function.
        .PARAMETER SelectedText
            Currently selected code that will become a function
        .PARAMETER InstallMenu
            Specifies if you want to install this as a PSIE add-on menu
        .PARAMETER FunctionName
            This is the name of the new function.
        .EXAMPLE
            New-Function -FunctionName "New-ImprovedFunction"
            
            Description
            -----------
            This example shows calling the function with the FunctionName parameter
        .EXAMPLE
            New-Function -InstallMenu $true
            
            Description
            -----------
            Installs the function as a menu item.
        .NOTES
            FunctionName : New-Function
            Created by   : Jeff Patton
            Date Coded   : 09/13/2011 13:37:24
        .LINK
            https://code.google.com/p/mod-posh/wiki/PSISELibrary#New-Function
    #>
    [CmdletBinding()]
    Param
        (
        $SelectedText = $psISE.CurrentFile.Editor.SelectedText,
        $InstallMenu,
        $FunctionName
        )
    Begin
    {
        $WikiPage = ($psISE.CurrentFile.DisplayName).Substring(0,($psISE.CurrentFile.DisplayName).IndexOf("."))
        $TemplateFunction = @(
        "Function $FunctionName`r`n"
        "{`r`n"
        "   <#`r`n"
        "       .SYNOPSIS`r`n"
        "       .DESCRIPTION`r`n"
        "       .PARAMETER`r`n"
        "       .EXAMPLE`r`n"
        "       .NOTES`r`n"
        "           FunctionName : $FunctionName`r`n"
        "           Created by   : $($env:username)`r`n"
        "           Date Coded   : $(Get-Date)`r`n"
        "       .LINK`r`n"
        "           https://code.google.com/p/mod-posh/wiki/$($WikiPage)#$($FunctionName)`r`n"
        "   #>`r`n"
        "[CmdletBinding()]`r`n"
        "Param`r`n"
        "    (`r`n"
        "    )`r`n"
        "Begin`r`n"
        "{`r`n"
        "    }`r`n"
        "Process`r`n"
        "{`r`n"
        "$($SelectedText)`r`n"
        "    }`r`n"
        "End`r`n"
        "{`r`n"
        "    }`r`n"
        "}")
        if ($InstallMenu)
        {
            Write-Verbose "Try to install the menu item, and error out if there's an issue."
            try
            {
                $psISE.CurrentPowerShellTab.AddOnsMenu.SubMenus.Add("New function",{New-Function},"Ctrl+Alt+S") | Out-Null
                }
            catch
            {
                Return $Error[0].Exception
                }
            }

        }
    Process
    {
        if (!$InstallMenu)
        {
            Write-Verbose "Don't create a function if we're installing the menu"
            try
            {
                Write-Verbose "Create a new empty function, return an error if there's an issue."
                $psISE.CurrentFile.Editor.InsertText($TemplateFunction)
                }
            catch
            {
                Return $Error[0].Exception
                }
            }
        }
    End
    {
        }
    }
Function Edit-File
{
    <#
        .SYNOPSIS
            Open files in specified editor.
        .DESCRIPTION
            This function will open one or more files, in the specified editor.
        .PARAMETER FileSpec
            The filepath to open
        .EXAMPLE
            Edit-File -FileSpec c:\powershell\*.ps1
        .NOTES
            Set $Global:POSHEditor in your $profile to the path of your favorite
            text editor or to C:\Windows\notepad.exe. If that variable is not set
            we'll try and open the file in the PowerShell ISE otherwise give
            the user a polite message telling them what to do.
        .LINK
            https://code.google.com/p/mod-posh/wiki/PSISELibrary#Edit-File
    #>    
    Param
        (
        [Parameter(ValueFromPipeline=$true)]
        $FileSpec
        )
    Begin
    {
        $FilesToOpen = Get-ChildItem $Filespec
        }
    Process
    {
        Foreach ($File in $FilesToOpen)
        {
            Try
            {
                if ($POSHEditor -ne $null)
                {
                    Invoke-Expression "$POSHEditor $File"
                    }
                else
                {
                    $psISE.CurrentPowerShellTab.Files.Add($File.FullName)
                    }
                }
            Catch
            {
                if ((Get-Host).Name -eq 'Windows PowerShell ISE Host')
                {
                    Return $Error[0].Exception
                    }
                else
                {
                    $Message = "You appear to be running in the console. "
                    $Message += "Please set `$Global:POSHEditor equalto the "
                    $Message += "path of your favorite text editor. Such as "
                    $Message += "`$Global:POSHEditor = c:\windows\notepad.exe `r`n"
                    $Message += "You can access your profile by typing 'notepad `$profile'"
                    Return $Message
                    }
                }
            }
        }
    End
    {
        }
    }
Function Save-All
{
    <#
        .SYNOPSIS
            Save all unsaved files in the editor
        .DESCRIPTION
            This function will save all unsaved files in the editor
        .EXAMPLE
            Save-All
            
            Description
            -----------
            The only syntax for the command.
        .NOTES
            FunctionName : Save-All
            Created by   : jspatton
            Date Coded   : 02/13/2012 15:08:51
            
            Routinely I have a need to have open and be editing several files
            at once. Decided to write a function to save them all since there
            isn't one currently available.
        .LINK
            https://code.google.com/p/mod-posh/wiki/PSISELibrary#Save-All
    #>
    [CmdletBinding()]
    Param
        (
        )
    Begin
    {
        Write-Verbose "Check if we're in ISE"
        if ((Get-Host).Name -ne 'Windows PowerShell ISE Host')
        {
            Write-Verbose "Not in the ISE exiting."
            Return
            }
        }
    Process
    {
        Write-Verbose "Iterate through each tab"
        foreach ($PSFile in $psISE.CurrentPowerShellTab.Files)
        {
            Write-Verbose "Check if $($PSFile.DisplayName) is saved"
            if ($psfile.IsSaved -eq $false)
            {
                Write-Verbose "Saving $($PSFile.DisplayName)" 
                $PSFile.Save()
                }
            
            }
        }
    End
    {
        }
    }
Function Set-SecureString
{
    <#
        .SYNOPSIS
            Create a file with encrypted contents
        .DESCRIPTION
            This function creates an encrypted function to store data, typically
            you would use this store an encrypted password for an administrator
            account.
        .PARAMETER FilePath
            The full path and filename to send the encrypted contents to
        .EXAMPLE
            Set-SecureString -FilePath C:\Users\Auser\AdminCredentials.txt
            
            Description
            -----------
            This is the only syntax for this command.
        .NOTES
            FunctionName : Set-SecureString
            Created by   : jspatton
            Date Coded   : 03/01/2012 13:45:13
        .LINK
            https://code.google.com/p/mod-posh/wiki/PSISELibrary#Set-SecureString
    #>
    [CmdletBinding()]
    Param
        (
        [string]$FilePath
        )
    Begin
    {
        }
    Process
    {
        $SecureString = Read-Host -AsSecureString
        $EncryptedString = ConvertFrom-SecureString $SecureString -Key (1..16)
        $EncryptedString |Out-File -FilePath $FilePath -Force
        }
    End
    {
        }
    }
Function Get-SecureString
 {
    <#
        .SYNOPSIS
            Stores the contents of an encrypted file as a secure string
        .DESCRIPTION
            This function reads the contents of an encrypted file and returns it as
            a secure string object. This is ideally suited to reading in the contents
            of a file that contained an administrators password
        .PARAMETER FilePath
            The full path and filename of the encrypted file
        .EXAMPLE
            Get-SecureString -FilePath C:\Users\Auser\AdminCredentials.txt
        .NOTES
            FunctionName : Get-SecureString
            Created by   : jspatton
            Date Coded   : 03/01/2012 13:51:53
        .LINK
            https://code.google.com/p/mod-posh/wiki/PSISELibrary#Get-SecureString
    #>
    [CmdletBinding()]
    Param
        (
        [string]$FilePath
        )
    Begin
    {
        }
    Process
    {
        $SecureString = ConvertTo-SecureString (Get-Content -Path $FilePath) -Key (1..16)
        }
    End
    {
        Return $SecureString
        }
    }
Function Print-IseFile
{
    <#
        .SYNOPSIS
            Print the current file
        .DESCRIPTION
            This simple script will print the currently opened
            file in the ISE to the default printer.
        .PARAMETER InstallMenu
            If this switch is passed a new menu item will appear 
            under Add-ons
        .EXAMPLE
            Print-IseFile
            
            Description
            -----------
            The default syntax of the command
        .NOTES
            FunctionName : Print-IseFile
            Created by   : jspatton
            Date Coded   : 05/03/2012 09:49:01
            
            This function was inspired by
            http://jdhitsolutions.com/blog/2011/09/friday-fun-add-a-print-menu-to-the-powershell-ise/
            
            My change was not opening the script in Notepad, I don't 
            mind the non-monospaced fonts.
        .LINK
            https://code.google.com/p/mod-posh/wiki/PSISELibrary#Print-IseFile
    #>
    [CmdletBinding()]
    Param
         (
         [switch]$InstallMenu
         )
    Begin
    {
        Write-Verbose "Check if we're in ISE"
        if ((Get-Host).Name -ne 'Windows PowerShell ISE Host')
        {
            Write-Verbose "Not in the ISE exiting."
            Return
            }
        }
    Process
    {
        switch ($InstallMenu)
        {
            $true
            {
                $psISE.CurrentPowerShellTab.AddOnsMenu.submenus.Add("Print Script",{Print-ISEFile},"CTRL+ALT+P") | Out-Null
                }
            default
            {
                Get-Content $psISE.CurrentFile.FullPath |Out-Printer
                }
            }
        }
    End
    {
        }
    }

Function Print-SelectedText
{
    <#
        .SYNOPSIS
            Print text selected in the ISE
        .DESCRIPTION
            This simple function will send whatever text is currently 
            selected in the PowerShell ISE to the printer.
        .PARAMETER InstallMenu
            If this switch is passed a new menu item will appear 
            under Add-ons
        .EXAMPLE
            Print-SelectedText
            
            Description
            -----------
            The default syntax of the command
        .NOTES
            FunctionName : Print-SelectedText
            Created by   : jspatton
            Date Coded   : 05/03/2012 09:55:00
            
            The idea for this came from 
            http://jdhitsolutions.com/blog/2011/09/friday-fun-add-a-print-menu-to-the-powershell-ise/
        .LINK
            https://code.google.com/p/mod-posh/wiki/PSISELibrary#Print-SelectedText
    #>
    [CmdletBinding()]
    Param
         (
         [switch]$InstallMenu
         )
    Begin
    {
        Write-Verbose "Check if we're in ISE"
        if ((Get-Host).Name -ne 'Windows PowerShell ISE Host')
        {
            Write-Verbose "Not in the ISE exiting."
            Return
            }
        }
    Process
    {
        switch ($InstallMenu)
        {
            $true
            {
                $psISE.CurrentPowerShellTab.AddOnsMenu.submenus.Add("Print Selected",{Print-SelectedText},"CTRL+ALT+S") | Out-Null
                }
            default
            {
                $psISE.CurrentFile.Editor.SelectedText |Out-Printer
                }
            }
        }
    End
    {
        }
    }

Export-ModuleMember *