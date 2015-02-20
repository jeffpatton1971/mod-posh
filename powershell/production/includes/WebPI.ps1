try
{
    $ErrorActionPreference = "Stop";
    $Error.Clear();
    Write-Verbose "Loading Microsoft.Web.Platforminstaller assembly";
    [reflection.assembly]::LoadWithPartialName("Microsoft.Web.PlatformInstaller") |Out-Null;
    Write-Verbose "Creating a global ProductManager object";
    $Global:WebPIProductManager = New-Object Microsoft.Web.PlatformInstaller.ProductManager;
    Write-Verbose "Loading the ProductManager, this may take a few secongs";
    $Global:WebPIProductManager.Load();
    }
catch
{
    Write-Error $Error[0];
    Write-Error "Please install WebPI from here : http://www.microsoft.com/web/downloads/platform.aspx";
    break;
    }
Function Get-WebPiProduct
{
    <#
        .SYNOPSIS
            Get one or more products from WebPI
        .DESCRIPTION
            This function will return one or more or all products that are avaialble through
            WebPI. If the All switch is present the function will return everything, otherwise
            the function will attempt to get the product requested or find matches via
            wildcard. The function tries to match the product entered against the title property.
        .PARAMETER Product
            The name of the produdct you are interested in
        .EXAMPLE
            Get-WebPiProduct -All


            AllDependencies       : {}
            Author                : Microsoft / Trustwave Spiderlabs
            AuthorUri             : https://github.com/SpiderLabs/ModSecurity
            FeedId                : http://www.microsoft.com/web/webpi/4.2/WebProductList.xml
            Summary               : Open source web application firewall.
            External              : False
            ExternalWarningShown  : False
            IconUrl               : http://www.modsecurity.org/g/webpi_icon.png
            ...

            Description
            -----------
            This will return all products that are available from WebPI. This can be filtered with a where
            clause if needed.            
        .EXAMPLE
            Get-WebPiProduct -Product "Windows Azure"


            AllDependencies       : {http://www.microsoft.com/web/webpi/4.2/WebProductList.xml,
                                    http://www.microsoft.com/web/webpi/4.2/WebProductList.xml,
                                    http://www.microsoft.com/web/webpi/4.2/WebProductList.xml,
                                    http://www.microsoft.com/web/webpi/4.2/WebProductList.xml...}
            Author                : Microsoft Corporation
            AuthorUri             : http://www.microsoft.com/
            FeedId                : http://www.microsoft.com/web/webpi/4.2/WebProductList.xml
            Summary               : The Windows Azure Pack - Admin Site provides management services for administrators and
                                    tenants.
            External              : False
            ExternalWarningShown  : False
            IconUrl               : http://go.microsoft.com/?linkid=9851985
            ...

            Description
            -----------            
            This will return any product that matches "Windows Azure" unless there is a single product called that.
        .EXAMPLE
            Get-WebPiProduct -Product "Windows Azure Storage"


            AllDependencies       : {}
            Author                : Microsoft Developer & Platform Evangelism
            AuthorUri             : http://www.microsoft.com/
            FeedId                : http://www.microsoft.com/web/webpi/4.2/WebProductList.xml
            Summary               :
                                          This presentation covers the Windows Azure storage services.  Blobs, tables, queues,
                                    drives, and the CDN are discussed in this presentation.

            External              : False
            ExternalWarningShown  : False
            IconUrl               : http://dpetrainingkits.blob.core.windows.net/shared/watk-logo.png
            Incompatibilities     : {}
            IncompatibleProcesses : {}
            IsApplication         : False
            IsIisComponent        : False
            IsUpdate              : False
            Keywords              : {}
            LongDescription       :
                                          This presentation covers the Windows Azure storage services.  Blobs, tables, queues,
                                    drives, and the CDN are discussed in this presentation.

            Link                  : https://github.com/windowsazure-trainingkit/presentation-windowsazurestorage
            ProductId             : watk-PRESENTATION-WindowsAzureStorage
            Published             : 3/23/2014 12:00:00 AM
            RelatedProducts       : {}
            SelectedInstaller     :
            Terms                 : {}
            Title                 : Windows Azure Storage
            Updates               : {}
            FeedLocation          : https://go.microsoft.com/?linkid=9842185
            Version               : 1.0.4
            Installers            : {Microsoft.Web.PlatformInstaller.Installer}
            DependencySets        : {}
            ExternalPackages      : {}

            Description
            -----------
            This returns a single matching product
        .NOTES
            FunctionName : Get-WebPiProducts
            Created by   : Jeffrey
            Date Coded   : 02/20/2015 08:55:09

            This function requires WebPI to be installed
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/WebPI#Get-WebPiProducts
    #>
    [CmdletBinding()]
    Param
        (
        [string]$Product,
        [switch]$All
        )
    Begin
    {
        }
    Process
    {
        if ($All)
        {
            Write-Verbose "Return all the products available";
            $Global:WebPIProductManager.Products;
            }
        else
        {
            Write-Verbose "Get the product $($Product)";
            $ProductId = $Global:WebPIProductManager.Products |Where-Object -Property Title -eq $Product |Select-Object -ExpandProperty ProductID;
            if (!($ProductId))
            {
                Write-Verbose "$($Product) not found, try wildcard";
                $ProductId = $Global:WebPIProductManager.Products |Where-Object -Property Title -like "*$($Product)*" |Select-Object -ExpandProperty ProductID;
                }
            if ($ProductId.GetType().BaseType.Name -eq "Array")
            {
                Write-Verbose "Multiple products found";
                foreach ($ID in $ProductId)
                {
                    Write-Verbose "Return Product object";
                    $Global:WebPIProductManager.GetProduct($ID);
                    }
                }
            else
            {
                Write-Verbose "Return Product object";
                return $Global:WebPIProductManager.GetProduct($ProductId);
                }
            }
        }
    End
    {
        }
    }