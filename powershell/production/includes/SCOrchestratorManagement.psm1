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
            https://code.google.com/p/mod-posh/wiki/SCOrchestratorManagement#Get-scoWebFeed
    #>
    [CmdletBinding()]
    Param
        (
        [parameter(Mandatory = $true)]
        [string]$scoUri = $null,
        [string]$Filter,
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
        if ($WebFeeds.feed.entry.count -lt 50)
        {
            Return $WebFeeds.feed.entry;
            }
        else
        {
            Write-Verbose "Paginate to see if there are more than 50 runbooks";
            $Entries = @();
            $Entries += $WebFeeds.feed.entry;
            Write-Verbose "Add first 50 runbooks to return collection";
            # ?`$skip=50&`$top=50"
            $Skip = 50;
            do
            {
                Write-Verbose "Get the next 50 runbooks";
                $Paginate = "?`$skip=$($Skip)&`$top=50";
                [byte[]]$WebResponse = $WebClient.DownloadData("$($scoUri)/$($Paginate)");
                [System.Xml.XmlDocument]$WebFeeds = [System.Text.Encoding]::ASCII.GetString($WebResponse);
                $Entries += $WebFeeds.feed.entry;
                $Skip += 50;
                }
            until ($WebFeeds.feed.entry.count -lt 50)
            Return $Entries
            }
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
            https://code.google.com/p/mod-posh/wiki/SCOrchestratorManagement#Get-scoRunbook
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
        $Runbooks = Get-scoWebFeed -scoUri $WebServiceUrl -Credential $Credential;
        }
    End
    {
        if ($Title)
        {
            Write-Verbose "Filter out result based on the Title, and return the entry element";
            Return $Runbooks |Where-Object {$_.title.InnerText -like "*$($Title)"};
            }
        else
        {
            Write-Verbose "Return the entry element";
            Return $Runbooks;
            }
        }
    }
Function Get-scoJob
{
    <#
        .SYNOPSIS
            Get one or more Jobs from Orchestrator
        .DESCRIPTION
            This function will return one or more Jobs from the Orchestrator server. To
            return a specific Job from the server use the Id parameter to pass in the
            Id of the job.
        .PARAMETER ManagementServer
            This is the name of the Orchestrator Management server. This server has the 
            web service installed and is where the processing takes place.
        .PARAMETER Title
            If you know the title or portion of the title of a Runbook, you can
            enter it here to filter the list of Runbooks returned.
        .PARAMETER Credential
            A credential object if we need to authenticate against the Orchestrator server
        .EXAMPLE
            Get-scoJob -ManagementServer orch.company.com

            Description
            -----------
            This example would return all the Jobs available from the Orchestrator server
        .EXAMPLE
            Get-scoJob -ManagementServer orch.company.com -Id "4112bd1f-1700-4a44-b487-bcf3fc85f1a7"

            Description
            -----------
            This example would return the Job that had '4112bd1f-1700-4a44-b487-bcf3fc85f1a7' as
            the Id.
        .NOTES
            FunctionName : Get-scoJob
            Created by   : jspatton
            Date Coded   : 06/05/2014 08:52:03
        .LINK
            https://code.google.com/p/mod-posh/wiki/SCOrchestratorManagement#Get-scoJob
    #>
    [CmdletBinding()]
    Param
        (
        [parameter(Mandatory = $true)]
        [string]$ManagementServer = $null,
        [string]$Id = $null,
        [ValidateSet("Canceled", "Completed", "Running", "Pending")]
        [string]$Status,
        [pscredential]$Credential = $null
        )
    Begin
    {
        }
    Process
    {
        Write-Verbose "Build the url string to pass to Get-scoWebfeed";
        [string]$WebServiceUrl = "http://$($ManagementServer):81/Orchestrator2012/Orchestrator.svc/Jobs";
        Write-Debug "Store the response for processing";
        $Filter = "`$filter=Status eq '$($Status)'"
        $Jobs = Get-scoWebFeed -scoUri "$($WebServiceUrl)/?$($Filter)" -Credential $Credential;
        }
    End
    {
        if ($Id)
        {
            Write-Verbose "Filter out result based on the Id, and return the entry element";
            $Jobs |Where-Object {$_.id -like "*$($Id)*"};
            }
        else
        {
            Write-Verbose "Return the entry element";
            $Jobs;
            }
        }
    }
Function Get-scoFolder
{
    <#
        .SYNOPSIS
            Get one or more Folders from Orchestrator
        .DESCRIPTION
            This function will return one or more Folders from the Orchestrator server.
        .PARAMETER ManagementServer
            This is the name of the Orchestrator Management server. This server has the 
            web service installed and is where the processing takes place.
        .PARAMETER Credential
            A credential object if we need to authenticate against the Orchestrator server
        .EXAMPLE
            Get-scoFolder -ManagementServer orch.company.com

            Description
            -----------
            This example would return all the Folders available from the Orchestrator server
        .NOTES
            FunctionName : Get-scoFolder
            Created by   : jspatton
            Date Coded   : 06/05/2014 08:52:03
        .LINK
            https://code.google.com/p/mod-posh/wiki/SCOrchestratorManagement#Get-scoFolder
    #>
    [CmdletBinding()]
    Param
        (
        [parameter(Mandatory = $true)]
        [string]$ManagementServer = $null,
        [pscredential]$Credential = $null
        )
    Begin
    {
        }
    Process
    {
        Write-Verbose "Build the url string to pass to Get-scoWebfeed";
        [string]$WebServiceUrl = "http://$($ManagementServer):81/Orchestrator2012/Orchestrator.svc/Folders";
        Write-Debug "Store the response for processing";
        $Folders = Get-scoWebFeed -scoUri $WebServiceUrl -Credential $Credential;
        }
    End
    {
        Write-Verbose "Return the entry element";
        Return $Folders;
        }
    }
Function Get-scoActivity
{
    <#
        .SYNOPSIS
            Get Activites from Orchestrator
        .DESCRIPTION
            This function will return the Activities from the Orchestrator server.
        .PARAMETER ManagementServer
            This is the name of the Orchestrator Management server. This server has the 
            web service installed and is where the processing takes place.
        .PARAMETER Credential
            A credential object if we need to authenticate against the Orchestrator server
        .EXAMPLE
            Get-scoActivity -ManagementServer orch.company.com

            Description
            -----------
            This example would return all the Activities available from the Orchestrator server
        .NOTES
            FunctionName : Get-scoActivity
            Created by   : jspatton
            Date Coded   : 06/05/2014 08:52:03
        .LINK
            https://code.google.com/p/mod-posh/wiki/SCOrchestratorManagement#Get-scoActivity
    #>
    [CmdletBinding()]
    Param
        (
        [parameter(Mandatory = $true)]
        [string]$ManagementServer = $null,
        [pscredential]$Credential = $null
        )
    Begin
    {
        }
    Process
    {
        Write-Verbose "Build the url string to pass to Get-scoWebfeed";
        [string]$WebServiceUrl = "http://$($ManagementServer):81/Orchestrator2012/Orchestrator.svc/Activities";
        Write-Debug "Store the response for processing";
        $Activities = Get-scoWebFeed -scoUri $WebServiceUrl -Credential $Credential;
        }
    End
    {
        Write-Verbose "Return the entry element";
        Return $Activities;
        }
    }
Function Get-scoStatistics
{
    <#
        .SYNOPSIS
            Get Statistics from Orchestrator
        .DESCRIPTION
            This function will return the Statistics from the Orchestrator server.
        .PARAMETER ManagementServer
            This is the name of the Orchestrator Management server. This server has the 
            web service installed and is where the processing takes place.
        .PARAMETER Credential
            A credential object if we need to authenticate against the Orchestrator server
        .EXAMPLE
            Get-scoStatistics -ManagementServer orch.company.com

            Description
            -----------
            This example would return all the Statistics from the Orchestrator server
        .NOTES
            FunctionName : Get-scoStatistics
            Created by   : jspatton
            Date Coded   : 06/05/2014 08:52:03
        .LINK
            https://code.google.com/p/mod-posh/wiki/SCOrchestratorManagement#Get-scoStatistics
    #>
    [CmdletBinding()]
    Param
        (
        [parameter(Mandatory = $true)]
        [string]$ManagementServer = $null,
        [pscredential]$Credential = $null
        )
    Begin
    {
        }
    Process
    {
        Write-Verbose "Build the url string to pass to Get-scoWebfeed";
        [string]$WebServiceUrl = "http://$($ManagementServer):81/Orchestrator2012/Orchestrator.svc/Statistics";
        Write-Debug "Store the response for processing";
        $Statistics = Get-scoWebFeed -scoUri $WebServiceUrl -Credential $Credential;
        }
    End
    {
        Write-Verbose "Return the entry element";
        Return $Statistics;
        }
    }
Function Get-scoParameter
{
    <#
        .SYNOPSIS
            Get all the Parameters for a given Runbook
        .DESCRIPTION
            This function will return all the Parameters that are required
            for a given Runbook to work properly. This would typically be
            used with the Get-scoRunbook function.
        .PARAMETER RunbookId
            This is the Id, as a URL from the Runbook
        .PARAMETER Credential
            A credential object if we need to authenticate against the Orchestrator server
        .EXAMPLE
            $Parameters = Get-scoParameter -RunbookId ((Get-scoRunbook -ManagementServer orch.company.com -Title 'Provision New User') `
                          |Select-Object -Property Id)
            
            Description
            -----------
            This example shows the most common use of this function, use Get-scoRunbook to return a specific Runbook
            and Select-Object to pull just the Id and pass that into the function.
        .NOTES
            FunctionName : Get-scoParameter
            Created by   : jspatton
            Date Coded   : 06/05/2014 08:52:03
        .LINK
            https://code.google.com/p/mod-posh/wiki/SCOrchestratorManagement#Get-scoParameter
    #>
    [CmdletBinding()]
    Param
        (
        [parameter(Mandatory = $true)]
        [string]$RunbookId = $null,
        [pscredential]$Credential = $null
        )
    Begin
    {
        }
    Process
    {
        Write-Debug "Store the response for processing";
        $Parameters = Get-scoWebFeed -scoUri "$($RunbookId)/Parameters" -Credential $Credential;
        }
    End
    {
        Write-Verbose "Return the entry element";
        Return $Parameters;
        }
    }
Function Start-scoRunbook
{
    <#
        .SYNOPSIS
            This function will start a Runbook
        .DESCRIPTION
            This function starts a runbook on the management server. It requires a runbook object
            to work with. In the context of this module that is an xmlelemnt.
        .PARAMETER Runbook
            An XmlElement that is returned from Get-scoRunbook
        .PARAMETER Value
            A hash that contains the proper key field to be passed to the runbook. So if the Runbook
            has two parameters Fname and Lname you need to pass in a hash like this:

                @{"Fname"="John";"Lname"="Smith"}
        .PARAMETER Credential
            A credential object if we need to authenticate against the Orchestrator server
        .EXAMPLE
            Start-Runbook -Runbook (Get-scoRunbook -ManagementServer orch.company.com -Title 'Provision new user') -Value @{"Fname"="John";"Lname"="Smith"}

            Description
            -----------
            This would be the most common use of this function. Get-scoRunbook returns a single runbook from the server
            titled 'Provision new user' and we pass in values that the Runbook needs to work properly.
        .NOTES
            FunctionName : Start-scoRunbook
            Created by   : jspatton
            Date Coded   : 06/05/2014 10:27:15
        .LINK
            https://code.google.com/p/mod-posh/wiki/SCOrchestratorManagement#Start-scoRunbook
    #>
    [CmdletBinding()]
    param
        (
        [parameter(Mandatory = $true)]
        [System.Xml.XmlElement]$Runbook,
        [hashtable]$Value = @{},
        [pscredential]$Credential = $null
        )
    Begin
    {
        if ($Runbook.id.Contains('guid'))
        {
            Write-Debug "The GUID is embedded inside the Id url property of the runbook";
            Write-Debug "Split the id property on a single tick mark, and return the second element";
            Write-Verbose "Get the GUID inside the id property";
            $rbid = $Runbook.id.Split("'")[1]
            }
        else
        {
            Write-Error "Invalid or missing GUID in Runbook";
            break;
            }
        Write-Debug "Get a list of parameters for the Runbook";
        $Parameters = Get-scoParameter -RunbookId $Runbook.id;
        Write-Debug "Did we get an array object back, or a single item back";
        #
        # This should be skipped for runbooks without parameters
        #
        $TypeName = $Parameters.GetType().name;
        switch ($TypeName)
        {
            "Object[]"
            {
                Write-Verbose "There is more than one Parameter for this Runbook";
                if ($Parameters.Count -eq $Value.Count)
                {
                    foreach ($Parameter in $Parameters)
                    {
                        Write-Debug "The GUID is embedded inside the Id url property of the parameter";
                        Write-Debug "Split the id property on a single tick mark, and return the second element";
                        Write-Verbose "Get the GUID inside the id property";
                        $ParamId = $Parameter.id.Split("'")[1];
                        foreach ($v in $Value.GetEnumerator())
                        {
                            Write-Debug "Build a hash table with Parameter Id and Value";
                            if ($Parameter.title.'#text' -eq $v.Key)
                            {
                                $rbParameters += @{$ParamId = $v.Value};
                                }
                            }
                        }
                    }
                else
                {
                    Write-Error "Number of Parameters ($($Parameters.count)) do not match the number of Values ($($Value.Count))";
                    break;
                    }
                }
            "XmlElement"
            {
                Write-Debug "We only have one Parameter, make sure we only have one Value";
                if ($Value.Count -eq 1)
                {
                    Write-Debug "The GUID is embedded inside the Id url property of the parameter";
                    Write-Debug "Split the id property on a single tick mark, and return the second element";
                    Write-Verbose "Get the GUID inside the id property";
                    $ParamId = $Parameters.id.Split("'")[1];
                    $rbParameters = @{$ParamId = ($Value.GetEnumerator()| Select-Object -ExpandProperty Value)};
                    }
                else
                {
                    Write-Error "Number of Parameters ($($Parameters.count)) do not match the number of Values ($($Value.Count))";
                    break;
                    }
                }
            }
        }
    Process
    {
        Write-Debug "Build a System.Uri object from the Runnbook Id";
        [System.Uri]$webUri = New-Object System.Uri($Runbook.id);
        Write-Debug "Use the System.Uri object to build the Orchestrator url";
        Write-Debug "Store the response in a System.Net.HttpWebRequest object";
        $request = [System.Net.HttpWebRequest]::Create($webUri.Scheme + "://" + $webUri.Host + ":" + $webUri.Port + "/Orchestrator2012/Orchestrator.svc/Jobs");
        if ($Credential -eq $null)
        {
            Write-Verbose "Using default credentials";
            $request.UseDefaultCredentials = $true
            }
        else
        {
            Write-Verbose "Use specific credentials to authenticate";
            $request.Credentials = $Credential
            }
        Write-Verbose "Build all the headers";
        Write-Debug "Method = POST";
        $request.Method = "POST";
        Write-Debug "UserAgent = Powershell Host Name";
        $request.UserAgent = $Host.Name;
        Write-Debug "Accept = application/atom+xml,application/xml";
        $request.Accept = "application/atom+xml,application/xml";
        Write-Debug "Contenttype = application/atom+xml";
        $request.ContentType = "application/atom+xml";
        Write-Debug "KeepAlive = true";
        $request.KeepAlive = $true;
        Write-Debug "Accept-Encoding = identity";
        $request.Headers.Add("Accept-Encoding","identity");
        Write-Debug "Accept-Language = en-us";
        $request.Headers.Add("Accept-Language","en-US");
        Write-Debug "DataServiceVersion = 1.0;Netfx";
        $request.Headers.Add("DataServiceVersion","1.0;NetFx");
        Write-Debug "MaxDataServiceVersion = 2.0;NetFx";
        $request.Headers.Add("MaxDataServiceVersion","2.0;NetFx");
        Write-Debug "Pragma = no-cache";
        $request.Headers.Add("Pragma","no-cache");
        Write-Debug "Build the parameter string";
        #
        # This should be skipped for runbooks without parameters
        #
        $rbParamString = "";
        if ($rbParameters -ne $null)
        {
            Write-Verbose "Create the parameters";
            Write-Debug "Begin the opening xml for the parameters";
            $rbParamString = "<d:Parameters><![CDATA[<Data>";
            foreach ($p in $rbParameters.GetEnumerator())
            {
                Write-Debug "For each entry in the hashtable, add the key (ID) and value (DATA)";
                $rbParamString = -join ($rbParamString,"<Parameter><ID>{",$p.key,"}</ID><Value>",$p.value,"</Value></Parameter>");
                }
            Write-Debug "Close the parameter xml";
            $rbParamString += "</Data>]]></d:Parameters>";
            }
        Write-Verbose "Build the request body";
        Write-Debug "The request body has to have certain items inside, as well as be ordered in a specific way";
        $requestBody = "<?xml version=`"1.0`" encoding=`"utf-8`" standalone=`"yes`"?>";
        $requestBody += "<entry xmlns:d=`"http://schemas.microsoft.com/ado/2007/08/dataservices`" xmlns:m=`"http://schemas.microsoft.com/ado/2007/08/dataservices/metadata`" xmlns=`"http://www.w3.org/2005/Atom`">";
        $requestBody += "<content type=`"application/xml`">";
        $requestBody += "<m:properties>";
        $requestBody += "<d:RunbookId m:type=`"Edm.Guid`">$($rbid)</d:RunbookId>";
        #
        # This should be skipped for runbooks without parameters
        #
        $requestBody += $rbparamstring;
        $requestBody += "</m:properties>";
        $requestBody += "</content>";
        $requestBody += "</entry>";
        Write-Debug "Create a System.IO.StreamWriter object to receive the stream from the server";
        $requestStream = new-object System.IO.StreamWriter $Request.GetRequestStream();
        Write-Debug "Upload the xml to the server";
        Write-Verbose "Sending data to server";
        $requestStream.Write($RequestBody);
        Write-Debug "Flush the stream";
        $requestStream.Flush();
        Write-Debug "Close the stream";
        $requestStream.Close();
        Write-Debug "Get the response code from the server";
        $response = $Request.GetResponse();
        Write-Debug "Get the response stream";
        $responseStream = $Response.GetResponseStream();
        Write-Debug "Build a System.IO.StreamReader object to read in the stream";
        $readStream = new-object System.IO.StreamReader $responseStream;
        Write-Debug "Read the stream returned from the server";
        Write-Verbose "Get data from the server";
        $responseString = $readStream.ReadToEnd();
        Write-Debug "Close the StreamReader";
        $readStream.Close();
        Write-Debug "Close the response stream";
        $responseStream.Close()
        }
    End
    {
        if ($response.StatusCode -eq 'Created')
        {
            Write-Debug "Convert the xml string to an XML object";
            $xmlDoc = [xml]$responseString;
            Write-Debug "Get the Job ID from the running job";
            $jobId = $xmlDoc.entry.content.properties.Id.InnerText;
            Write-Host "Successfully started runbook. Job ID: " $jobId;
            Write-Verbose "Return the entry element";
            return $xmlDoc.entry;
            }
        else
        {
            Write-Host "Could not start runbook. Status: " $response.StatusCode;
            }
        }
    }