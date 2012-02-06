param($serverName,$portNumber,$pollIntervalSeconds,$watcherNodes,$displayName,$targetMp)

function GetPortMonitoringTemplate
{
	$criteria = "Name = 'Microsoft.SystemCenter.SyntheticTransactions.TCPPortCheck.Template'";
	$templateCriteria    = new-object Microsoft.EnterpriseManagement.Configuration.MonitoringTemplateCriteria($criteria);
	$template = (Get-ManagementGroupConnection).ManagementGroup.GetMonitoringTemplates($templateCriteria)[0];
	$template;
}

function GetManagementPack([string]$mpDisplayName)
{
	$criteria = [string]::Format("DisplayName = '{0}'", $mpDisplayName);
	$mpCriteria = new-object Microsoft.EnterpriseManagement.Configuration.ManagementPackCriteria($criteria);
	$mg = (Get-ManagementGroupConnection).ManagementGroup;
	$mp = $mg.GetManagementPacks($mpCriteria)[0];
	$mp;
}

function AddChildElement([System.Xml.XmlElement]$parentElement,[string]$newElementName,[string]$value)
{
	$document = $parentElement.get_OwnerDocument();
	$newElement = $document.CreateElement($newElementName);
	$newElement.set_InnerText($value);
	$parentElement.AppendChild($newElement);
}

function CreateWatcherComputerList($watcherNodes)
{
	if($watcherNodes.Count -eq $null)
	{
		$watcherNodesList = $watcherNodes;
	}
	else
	{
		$watcherNodesString = ""
		
		for($i = 0; $i -le $watcherNodes.Count; $i++)
		{
			$watcherNodesList += $watcherNodes[$i];
			
			if($i -le ($watcherNodes.Count - 2))
			{
				$watcherNodesList += " | "
			}
		}
		$watcherNodesList = [string]::Format("({0})",$watcherNodesList);
	}
	$watcherNodesList
}


function AddWatcherNodesIds([system.Xml.XmlElement]$rootNode,$watcherNodes)
{
	$nodeIdsAdded = $true;
	$doc = $rootNode.get_OwnerDocument();

	$includeListElement = $doc.CreateElement("IncludeList");
	$rootNode.AppendChild($includeListElement)

	if($watcherNodes.Count -eq $null)
	{
		$computerMonitoringObject = GetComputerMonitoringObject $watcherNodes;		
		$computerMonitoringObject;

		if($computerMonitoringObject -eq $null)
		{
			$watcherNodes + " not found";
			$nodeIdsAdded = $false;
		}
		else
		{
			AddChildElement $includeListElement "MonitoringObjectId" $computerMonitoringObject.Id.ToString()
		}	
	}
	else
	{
		foreach($watcherNode in $watcherNodes)
		{
			$computerMonitoringObject = GetComputerMonitoringObject $watcherNode		

			if($computerMonitoringObject -eq $null)
			{
				$watcherNodes + " not found";
				$nodeIdsAdded = $false;
			}
			else
			{
				AddChildElement $includeListElement "MonitoringObjectId" $computerMonitoringObject.Id.ToString()
			}	
		}
	}
}

function GetComputerMonitoringObject($computerFQDN)
{
	$mg = (Get-ManagementGroupConnection).ManagementGroup;	
	$windowsComputerClass = Get-MonitoringClass -Name:"Microsoft.Windows.Computer"
	$criteriaFormatString = "[Microsoft.Windows.Computer].[PrincipalName]='{0}'"
	$criteriaString = [string]::Format($criteriaFormatString,$computerFQDN)				           
	$criteria = new-object Microsoft.EnterpriseManagement.Monitoring.MonitoringObjectCriteria($criteriaString,$windowsComputerClass);
	$monitoringObjects = $mg.GetMonitoringObjects($criteria);
	$monitoringObjects[0];
}

$configDoc = new-object System.Xml.XmlDocument;

$rootNode = $configDoc.CreateElement("Configuration");

$configDoc.AppendChild($rootNode);

$typeId = [string]::Format("PortMonitoring_{0}", [System.Guid]::NewGuid().ToString("N"))

AddChildElement $rootNode "TypeId" $typeId
AddChildElement $rootNode "Name" $displayName
AddChildElement $rootNode "Description" ""
AddChildElement $rootNode "LocaleId" "ENU"
AddChildElement $rootNode "ServerName" $serverName
AddChildElement $rootNode "Port" $portNumber
AddChildElement $rootNode "PollIntervalInSeconds" $pollIntervalSeconds
AddWatcherNodesIds $rootNode $watcherNodes

$watcherNodesList = CreateWatcherComputerList $watcherNodes

AddChildElement $rootNode "WatcherComputersList" $watcherNodesList

$uniqueKey = [System.Guid]::NewGuid().ToString();

AddChildElement $rootNode "UniquenessKey" $uniqueKey

$template = GetPortMonitoringTemplate

$mp = GetManagementPack $targetMp

$configDoc.get_InnerXml()

$mp.ProcessMonitoringTemplate($template,$configDoc.get_InnerXml(),"PortMon" + [System.Guid]::NewGuid().ToString("N"),$displayName,"")
