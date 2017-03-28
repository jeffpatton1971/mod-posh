<#
.SYNOPSIS
    This script will generate a proper XML helpfile
.DESCRIPTION
    This script will build output to the screen a properly formatted
    XML help file. I based this on one of the installed helpfiles
    in System32.
.PARAMETER Commands
    You can pass in the output from Get-Command cmdletname or you 
    can pass in Get-Command -Module moduleName
.EXAMPLE
    New-HelpFile -Commands (Get-Command Get-Help) |out-File .\gethelp.psm1-help.xml
.EXAMPLE
    New-HelpFile -Commands (Get-Command -Module PowerShellAccessControl) |out-File .\PowerShellAccessControl.psm1-help.xml
.NOTES
    ScriptName : New-HelpFile
    Created By : jspatton
    Date Coded : 03/04/2015 17:19:27
.LINK
    https://gist.github.com/jeffpatton1971/029e58a3304cf5761f2e
#>
[CmdletBinding()]
Param
(
$Commands
)
Process
{
    Write-Output '<?xml version = "1.0" encoding = "utf-8" ?>'
    Write-Output ''
    Write-Output '<helpItems schema="maml">'
    Write-Output '  <command:command xmlns:maml="http://schemas.microsoft.com/maml/2004/10"'
    Write-Output '                   xmlns:command="http://schemas.microsoft.com/maml/dev/command/2004/10"'
    Write-Output '                   xmlns:dev="http://schemas.microsoft.com/maml/dev/2004/10"'
    Write-Output '                   xmlns:MSHelp="http://msdn.microsoft.com/mshelp">'
    foreach ($Cmdlet in $Commands)
    {
        $CmdletHelp = Get-Help -Name $Cmdlet.Name -Full;
        Write-Output '      <command:details>'
        Write-Output "          <command:name>$($CmdletHelp.Name)</command:name>"
        Write-Output '          <maml:description>'
        Write-Output "              <maml:para>$([System.Net.WebUtility]::HtmlEncode($CmdletHelp.Synopsis))</maml:para>"
        Write-Output '          </maml:description>'
        Write-Output '          <maml:copyright>'
        Write-Output '              <maml:para />'
        Write-Output '          </maml:copyright>'
        Write-Output "          <command:verb>$($Cmdlet.Verb)</command:verb>"
        Write-Output "          <command:noun>$($Cmdlet.Noun)</command:noun>"
        Write-Output '          <dev:version />'
        Write-Output '      </command:details>'
        Write-Output '      <maml:description>'
        $Desc = $CmdletHelp.Description.Text
        if ($Desc -eq $null)
        {
            $Desc = ""
            }
        if (($Desc).IndexOfAny("`r`n"))
        {
            $Description = ($Desc).Split("`r`n")
            foreach ($DescriptionText in $Description)
            {
                Write-Output "          <maml:para>"
                Write-Output "          $([System.Net.WebUtility]::HtmlEncode($DescriptionText))"
                Write-Output "          </maml:para>"
                }
            }
        else
        {
            $DescriptionText = ($Desc)
            Write-Output "          <maml:para>"
            Write-Output "          $([System.Net.WebUtility]::HtmlEncode($DescriptionText))"
            Write-Output "          </maml:para>"
            }
        Write-Output '      </maml:description>'
        Write-Output '      <command:syntax>'
        $Syntax = $CmdletHelp.syntax
        foreach ($SyntaxItem in $Syntax.SyntaxItem)
        {

            Write-Output '          <command:syntaxItem>'
            Write-Output "              <maml:name>$($CmdletHelp.Name)</maml:name>"
            foreach ($siParam in $SyntaxItem.Parameter)
            {
                Write-Output "              <command:parameter required=`"$($siParam.required)`" variableLength=`"$($siParam.variableLength)`" globbing=`"$($siParam.globbing)`" pipelineInput=`"$($siParam.pipelineInput)`" position=`"$($siParam.position)`" aliases=`"$($siParam.aliases)`">"
                Write-Output "                  <maml:name>$([System.Net.WebUtility]::HtmlEncode($siParam.name))</maml:name>"
                Write-Output '                      <maml:description>'
                $Desc = $siParam.Description.Text
                if ($Desc -eq $null)
                {
                    $Desc = ""
                    }
                if (($Desc).IndexOfAny("`r`n"))
                {
                    $Description = ($Desc).Split("`r`n")
                    foreach ($DescriptionText in $Description)
                    {
                        Write-Output "                          <maml:para>"
                        Write-Output "                          $([System.Net.WebUtility]::HtmlEncode($DescriptionText))"
                        Write-Output "                          </maml:para>"
                        }
                    }
                else
                {
                    $DescriptionText = ($Desc)
                    Write-Output "                          <maml:para>"
                    Write-Output "                          $([System.Net.WebUtility]::HtmlEncode($DescriptionText))"
                    Write-Output "                          </maml:para>"
                    }
                Write-Output '                      </maml:description>'
                Write-Output "                  <command:parameterValue required=`"true`" variableLength=`"true`">$($siParam.parameterValue)</command:parameterValue>"
                Write-Output '              </command:parameter>'
                }
            Write-Output '          </command:syntaxItem>'
            }
        Write-Output '      </command:syntax>'
        Write-Output '      <command:parameters>'
        foreach ($cParam in $CmdletHelp.parameters.parameter)
        {
            Write-Output "          <command:parameter required=`"$($cParam.required)`" variableLength=`"$($cParam.variableLength)`" globbing=`"$($cParam.globbing)`" pipelineInput=`"$($cParam.pipelineInput)`" position=`"$($cParam.position)`" aliases=`"$($cParam.aliases)`">"
            Write-Output "              <maml:name>$($cParam.name)</maml:name>"
            Write-Output '                  <maml:description>'
            $Desc = $cParam.description.text
            if ($Desc -eq $null)
            {
                $Desc = ""
                }
            if (($Desc).IndexOfAny("`r`n"))
            {
                $Description = ($Desc).Split("`r`n")
                foreach ($DescriptionText in $Description)
                {
                    Write-Output "                      <maml:para>"
                    Write-Output "                      $([System.Net.WebUtility]::HtmlEncode($DescriptionText))"
                    Write-Output "                      </maml:para>"
                    }
                }
            else
            {
                $DescriptionText = ($cParam.description.text)
                Write-Output "                      <maml:para>"
                Write-Output "                      $([System.Net.WebUtility]::HtmlEncode($DescriptionText))"
                Write-Output "                      </maml:para>"
                }
            Write-Output '                  </maml:description>'
            Write-Output "                  <command:parameterValue required=`"$($cParam.parameterValue.required)`" variableLength=`"$($cParam.parameterValue.variableLength)`">$($cParam.parameterValue)</command:parameterValue>"
            Write-Output '                  <dev:type>'
            Write-Output "                      <maml:name>$($cParam.type.name)</maml:name>"
            Write-Output "                      <maml:uri>$($cParam.type.uri)</maml:uri>"
            Write-Output '                  </dev:type>'
            Write-Output "                  <dev:defaultValue>$($cParam.defaultValue)</dev:defaultValue>"
            Write-Output '          </command:parameter>'
            }
        Write-Output '      </command:parameters>'
        Write-Output '    <command:inputTypes></command:inputTypes>'
        Write-Output '    <command:returnValues></command:returnValues>'
        Write-Output '    <maml:alertSet>'
        foreach ($AlertSet in $CmdletHelp.alertSet)
        {
            Write-Output "      <maml:title>$($AlertSet.Title)</maml:title>"
            foreach ($aSet in $AlertSet.alert)
            {
                Write-Output '      <maml:alert>'
                Write-Output "        <maml:para>"
                Write-Output "$([System.Net.WebUtility]::HtmlEncode($aSet.Text))"
                Write-Output "        </maml:para>"
                Write-Output '      </maml:alert>'
                }
            }
        Write-Output '    </maml:alertSet>'
        Write-Output '    <command:terminatingErrors /><command:nonTerminatingErrors />'
        Write-Output '    <command:examples>'
        foreach ($cExample in $CmdletHelp.examples.example)
        {
            Write-Output '        <command:example>'
            Write-Output "            <maml:title>$($cExample.title)</maml:title>"
            Write-Output '            <maml:introduction>'
            Write-Output "                <maml:para>$([System.Net.WebUtility]::HtmlEncode($cExample.introduction.Text))</maml:para>"
            Write-Output '            </maml:introduction>'
            Write-Output '            <dev:code>'
            Write-Output "$($cExample.code)"
            Write-Output '            </dev:code>'
            Write-Output '            <dev:remarks>'
            Write-Output "                <maml:para>$([System.Net.WebUtility]::HtmlEncode($cExample.remarks.Text))</maml:para>"
            Write-Output '            </dev:remarks>'
            Write-Output '            <command:commandLines>'
            foreach ($cmdLine in $cExample.commandLines)
            {
                Write-Output '                <command:commandLine>'
                Write-Output "                    <command:commandText>$($cmdLine.commandLine.commandText)</command:commandText>"
                Write-Output '                </command:commandLine>'
                }
            Write-Output '            </command:commandLines>'
            Write-Output '        </command:example>'
            }
        Write-Output '    </command:examples>'
        Write-Output '    <maml:relatedLinks>'
        foreach ($navigationLink in $CmdletHelp.relatedLinks.navigationLink)
        {
            Write-Output '        <maml:navigationLink>'
            Write-Output "            <maml:linkText>$($navigationLink.linkText)</maml:linkText>"
            Write-Output "            <maml:uri>$($navigationLink.uri)</maml:uri>"
            Write-Output '        </maml:navigationLink>'
            }
        Write-Output '    </maml:relatedLinks>'
        }
    Write-Output "  </command:command>"
    Write-Output "</helpItems>"
    }