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
            Set the variable $POSHEditor to the full path and filename to your editor of choice.
        .LINK
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
                    Return $Error[0].Exception
                    Return "Either no editor is set in POSHEditor or you're running console host."
                    }
                }
            }
    End
        {
            }
    }