Function Get-scoWebFeed
{
    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER
        .EXAMPLE
        .NOTES
            FunctionName : Get-scoWebFeed
            Created by   : jspatton
            Date Coded   : 06/05/2014 09:00:48
        .LINK
            https://code.google.com/p/mod-posh/wiki/Untitled7#Get-scoWebFeed
    #>
    [CmdletBinding()]
    Param
        (
        [string]$scoUri = $null,
        [pscredential]$Credential = $null
        )
    Begin
    {
        }
    Process
    {
        [System.Net.WebClient]$WebClient = New-Object System.Net.WebClient;

        if ($Credential -eq $null)
        {
            $WebClient.UseDefaultCredentials = $true;
            }
        else
        {
            $WebClient.Credentials = $Credential;
            }

        [byte[]]$WebResponse = $WebClient.DownloadData($scoUri);
        [System.Xml.XmlDocument]$WebFeeds = [System.Text.Encoding]::ASCII.GetString($WebResponse);
        
        Return $WebFeeds.feed;
        }
    End
    {
        }
    }
Function Get-scoRunbook
{
    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER
        .EXAMPLE
        .NOTES
            FunctionName : Get-scoRunbook
            Created by   : jspatton
            Date Coded   : 06/05/2014 08:52:03
        .LINK
            https://code.google.com/p/mod-posh/wiki/Untitled7#Get-scoRunbook
    #>
    [CmdletBinding()]
    Param
        (
        [string]$ManagementServer = $null,
        [string]$Filter = $null,
        [pscredential]$Credential = $null
        )
    Begin
    {
        }
    Process
    {
        [string]$WebServiceUrl = "http://$($ManagementServer):81/Orchestrator2012/Orchestrator.svc/Runbooks";
        $Runbooks = Get-scoWebFeed -scoUri $WebServiceUrl -Credential $Credential
        }
    End
    {
        if ($Filter)
        {
            Return $Runbooks.entry |Where-Object {$_.title.InnerText -like $Filter}
            }
        else
        {
            Return $Runbooks.entry
            }
        }
    }
Function Get-scoJob
{
    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER
        .EXAMPLE
        .NOTES
            FunctionName : Get-scoRunbook
            Created by   : jspatton
            Date Coded   : 06/05/2014 08:52:03
        .LINK
            https://code.google.com/p/mod-posh/wiki/Untitled7#Get-scoRunbook
    #>
    [CmdletBinding()]
    Param
        (
        [string]$ManagementServer = "orms-csf-01.home.ku.edu",
        [pscredential]$Credential = $null
        )
    Begin
    {
        }
    Process
    {
        [string]$WebServiceUrl = "http://$($ManagementServer):81/Orchestrator2012/Orchestrator.svc/Jobs";
        Get-scoWebFeed -scoUri $WebServiceUrl -Credential $Credential
        }
    End
    {
        }
    }
Function Get-scoFolder
{
    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER
        .EXAMPLE
        .NOTES
            FunctionName : Get-scoRunbook
            Created by   : jspatton
            Date Coded   : 06/05/2014 08:52:03
        .LINK
            https://code.google.com/p/mod-posh/wiki/Untitled7#Get-scoRunbook
    #>
    [CmdletBinding()]
    Param
        (
        [string]$ManagementServer = "orms-csf-01.home.ku.edu",
        [pscredential]$Credential = $null
        )
    Begin
    {
        }
    Process
    {
        [string]$WebServiceUrl = "http://$($ManagementServer):81/Orchestrator2012/Orchestrator.svc/Folders";
        Get-scoWebFeed -scoUri $WebServiceUrl -Credential $Credential
        }
    End
    {
        }
    }
Function Get-scoActivity
{
    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER
        .EXAMPLE
        .NOTES
            FunctionName : Get-scoRunbook
            Created by   : jspatton
            Date Coded   : 06/05/2014 08:52:03
        .LINK
            https://code.google.com/p/mod-posh/wiki/Untitled7#Get-scoRunbook
    #>
    [CmdletBinding()]
    Param
        (
        [string]$ManagementServer = "orms-csf-01.home.ku.edu",
        [pscredential]$Credential = $null
        )
    Begin
    {
        }
    Process
    {
        [string]$WebServiceUrl = "http://$($ManagementServer):81/Orchestrator2012/Orchestrator.svc/Activities";
        Get-scoWebFeed -scoUri $WebServiceUrl -Credential $Credential
        }
    End
    {
        }
    }
Function Get-scoStatistics
{
    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER
        .EXAMPLE
        .NOTES
            FunctionName : Get-scoRunbook
            Created by   : jspatton
            Date Coded   : 06/05/2014 08:52:03
        .LINK
            https://code.google.com/p/mod-posh/wiki/Untitled7#Get-scoRunbook
    #>
    [CmdletBinding()]
    Param
        (
        [string]$ManagementServer = "orms-csf-01.home.ku.edu",
        [pscredential]$Credential = $null
        )
    Begin
    {
        }
    Process
    {
        [string]$WebServiceUrl = "http://$($ManagementServer):81/Orchestrator2012/Orchestrator.svc/Statistics";
        Get-scoWebFeed -scoUri $WebServiceUrl -Credential $Credential
        }
    End
    {
        }
    }
Function Get-scoParameter
{
    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER
        .EXAMPLE
        .NOTES
            FunctionName : Get-scoRunbook
            Created by   : jspatton
            Date Coded   : 06/05/2014 08:52:03
        .LINK
            https://code.google.com/p/mod-posh/wiki/Untitled7#Get-scoRunbook
    #>
    [CmdletBinding()]
    Param
        (
        [string]$RunbookId = $null,
        [pscredential]$Credential = $null
        )
    Begin
    {
        }
    Process
    {
        Get-scoWebFeed -scoUri "$($RunbookId)/Parameters" -Credential $Credential
        }
    End
    {
        }
    }
Function Start-scoRunbook
{
    <#
        .SYNOPSIS
        .DESCRIPTION
        .PARAMETER
        .EXAMPLE
        .NOTES
            FunctionName : Start-scoRunbook
            Created by   : jspatton
            Date Coded   : 06/05/2014 10:27:15
        .LINK
            https://code.google.com/p/mod-posh/wiki/Untitled7#Start-scoRunbook
    #>
    [CmdletBinding()]
    param
        (
        [System.Xml.XmlElement]$Runbook,
        [string[]]$Value = $null,
        [pscredential]$Credential = $null
        )
    Begin
    {
        if ($Runbook.id.Contains('guid'))
        {
            $rbid = $Runbook.id.Split("'")[1]
            }
        else
        {
            Write-Error "Invalid or missing GUID in Runbook";
            break;
            }
        $Parameters = Get-scoParameter -RunbookId $Runbook.id
        $TypeName = $Parameters.GetType().name
        switch ($TypeName)
        {
            "Object[]"
            {
                if ($Parameters.entry.Count -eq $Value.Count)
                {
                    foreach ($Parameter in $Parameters.entry)
                    {
                        $ParamId = $Parameter.entry.id.Split("'")[1];
                        foreach ($v in $Value)
                        {
                            $rbParameters += @{$ParamId = $v};
                            }
                        }
                    }
                else
                {
                    Write-Error "Number of Parameters ($($Parameters.entry.count)) do not match the number of Values ($($Value.Count))";
                    break;
                    }
                }
            "XmlElement"
            {
                if ($Value.Count -eq 1)
                {
                    $ParamId = $Parameters.entry.id.Split("'")[1]
                    $rbParameters = @{$ParamId = $Value[0]}
                    }
                else
                {
                    Write-Error "Number of Parameters ($($Parameters.entry.count)) do not match the number of Values ($($Value.Count))";
                    break;
                    }
                }
            }
        }
    Process
    {
        [System.Uri]$webUri = New-Object System.Uri($Runbook.id);
        $request = [System.Net.HttpWebRequest]::Create($webUri.Scheme + "://" + $webUri.Host + ":" + $webUri.Port + "/Orchestrator2012/Orchestrator.svc/Jobs")

        if ($Credential -eq $null)
        {
            $request.UseDefaultCredentials = $true
            }
        else
        {
            $request.Credentials = $Credential
            }

        $request.Method = "POST"
        $request.UserAgent = "Microsoft ADO.NET Data Services"
        $request.Accept = "application/atom+xml,application/xml"
        $request.ContentType = "application/atom+xml"
        $request.KeepAlive = $true
        $request.Headers.Add("Accept-Encoding","identity")
        $request.Headers.Add("Accept-Language","en-US")
        $request.Headers.Add("DataServiceVersion","1.0;NetFx")
        $request.Headers.Add("MaxDataServiceVersion","2.0;NetFx")
        $request.Headers.Add("Pragma","no-cache")

        $rbParamString = ""
        if ($rbParameters -ne $null)
        {
            $rbParamString = "<d:Parameters><![CDATA[<Data>"
            foreach ($p in $rbParameters.GetEnumerator())
            {
                $rbParamString = -join ($rbParamString,"<Parameter><ID>{",$p.key,"}</ID><Value>",$p.value,"</Value></Parameter>")
                }
            $rbParamString += "</Data>]]></d:Parameters>"
            }

        # Build the request body
        $requestBody = "<?xml version=`"1.0`" encoding=`"utf-8`" standalone=`"yes`"?>"
        $requestBody += "<entry xmlns:d=`"http://schemas.microsoft.com/ado/2007/08/dataservices`" xmlns:m=`"http://schemas.microsoft.com/ado/2007/08/dataservices/metadata`" xmlns=`"http://www.w3.org/2005/Atom`">"
        $requestBody += "<content type=`"application/xml`">"
        $requestBody += "<m:properties>"
        $requestBody += "<d:RunbookId m:type=`"Edm.Guid`">$($rbid)</d:RunbookId>"
        $requestBody += $rbparamstring
        $requestBody += "</m:properties>"
        $requestBody += "</content>"
        $requestBody += "</entry>"

        $requestStream = new-object System.IO.StreamWriter $Request.GetRequestStream()
        $requestStream.Write($RequestBody)
        $requestStream.Flush()
        $requestStream.Close()

        $response = $Request.GetResponse()

        $responseStream = $Response.GetResponseStream()
        $readStream = new-object System.IO.StreamReader $responseStream
        $responseString = $readStream.ReadToEnd()

        $readStream.Close()
        $responseStream.Close()
        }
    End
    {
        if ($response.StatusCode -eq 'Created')
        {
            $xmlDoc = [xml]$responseString
            $jobId = $xmlDoc.entry.content.properties.Id.InnerText
            Write-Host "Successfully started runbook. Job ID: " $jobId
            return $xmlDoc.entry;
            }
        else
        {
            Write-Host "Could not start runbook. Status: " $response.StatusCode
            }
        }
    }

