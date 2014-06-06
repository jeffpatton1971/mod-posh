Function Get-scoWebFeed
{
    <#
        .SYNOPSIS
            Get Orchestrator web feed
        .DESCRIPTION
            This function does the work of getting the requested URL from Orchestrator
        .PARAMETER scoUri
            This is a properly formatted Orchestrator URI, the main functions build
            these and pass them here for processing
        .PARAMETER Credential
            A credential object if we need to authenticate against the Orchestrator server
        .EXAMPLE
            Get-scoWebFeed -scoUri http://orch.company.com:81/Orchestrator2012/Orchestrator.svc/Runbooks

            Description
            -----------
            This isn't really intended to be used directly, but this would return an xml document 
            of all the runbooks on the server
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
        [parameter(Mandatory = $true)]
        [string]$scoUri = $null,
        [pscredential]$Credential = $null
        )
    Begin
    {
        }
    Process
    {
        Write-Debug "Create System.Net.WebClient object";
        [System.Net.WebClient]$WebClient = New-Object System.Net.WebClient;

        if ($Credential -eq $null)
        {
            Write-Verbose "Using default logged in credentials";
            $WebClient.UseDefaultCredentials = $true;
            }
        else
        {
            Write-Verbose "Sending credentials to server";
            $WebClient.Credentials = $Credential;
            }
        Write-Debug "Downloading the byte data from the server";
        [byte[]]$WebResponse = $WebClient.DownloadData($scoUri);
        Write-Debug "Using System.Text.Encoding to get the string and storing it in a System.Xml.XmlDocument";
        [System.Xml.XmlDocument]$WebFeeds = [System.Text.Encoding]::ASCII.GetString($WebResponse);
        Write-Verbose "Return just the feed element from the server";
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
            Get one or more Runbooks from Orchestrator
        .DESCRIPTION
            This function will return one or more Runbooks from the Orchestrator server. To
            return a specific Runbook from the server use the Title parameter to pass in the
            complete title, or a portion of the title.
        .PARAMETER ManagementServer
            This is the name of the Orchestrator Management server. This server has the 
            web service installed and is where the processing takes place.
        .PARAMETER Title
            If you know the title or portion of the title of a Runbook, you can
            enter it here to filter the list of Runbooks returned.
        .PARAMETER Credential
            A credential object if we need to authenticate against the Orchestrator server
        .EXAMPLE
            Get-scoRunbook -ManagementServer orch.company.com

            Description
            -----------
            This example would return all the Runbooks available from the Orchestrator server
        .EXAMPLE
            Get-scoRunbook -ManagementServer orch.company.com -Title "New Computer"

            Description
            -----------
            This example would return one or more Runbooks that have the phrase, 'New Computer'
            in the title.
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
        [parameter(Mandatory = $true)]
        [string]$ManagementServer = $null,
        [string]$Title = $null,
        [pscredential]$Credential = $null
        )
    Begin
    {
        }
    Process
    {
        Write-Verbose "Build the url string to pass to Get-scoWebfeed";
        [string]$WebServiceUrl = "http://$($ManagementServer):81/Orchestrator2012/Orchestrator.svc/Runbooks";
        Write-Debug "Store the response for processing";
        $Runbooks = Get-scoWebFeed -scoUri $WebServiceUrl -Credential $Credential
        }
    End
    {
        if ($Title)
        {
            Write-Verbose "Filter out result based on the Title, and return the entry element";
            Return $Runbooks.entry |Where-Object {$_.title.InnerText -like "*$($Title)"}
            }
        else
        {
            Write-Verbose "Return the entry element";
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
        [string]$ManagementServer = $null,
        [string]$Job = $null,
        [pscredential]$Credential = $null
        )
    Begin
    {
        }
    Process
    {
        [string]$WebServiceUrl = "http://$($ManagementServer):81/Orchestrator2012/Orchestrator.svc/Jobs";
        $Jobs = Get-scoWebFeed -scoUri $WebServiceUrl -Credential $Credential
        }
    End
    {
        if ($Job)
        {
            Return $Jobs.entry |Where-Object {$_.id -like $Job}
            }
        else
        {
            Return $Jobs.entry
            }
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
        [string]$ManagementServer = $null,
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
        [string]$ManagementServer = $null,
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
        [string]$ManagementServer = $null,
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

