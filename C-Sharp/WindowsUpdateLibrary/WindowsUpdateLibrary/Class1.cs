using System;
using System.Collections.Generic;
using System.Management;
using System.Management.Automation;
using System.Net;
using Microsoft.UpdateServices.Administration;
using WUApiLib;

namespace WindowsUpdateLibrary
{
    public class wuCmdlets
    {
        //
        // Administrative Cmdlets
        //
        [Cmdlet(VerbsCommunications.Connect, "wuServer")]
        public class Connect_wuServer : Cmdlet
        {
            [Parameter(Mandatory = false,
                HelpMessage = "Provide the name of your update server, if non-standard port servername:portnumber")]
            [ValidateNotNullOrEmpty]
            public string ServerName = Dns.GetHostName();

            [Parameter(Mandatory = false,
                HelpMessage = "If present use a secure connection to the server")]
            [ValidateNotNullOrEmpty]
            public bool UseSecureConnection = false;

            bool isLocal = false;
            int portNumber;
            string wuaServer;
            AdminProxy adminProxy = new AdminProxy();
            IUpdateServer updateServer;

            protected override void BeginProcessing()
            {
                base.BeginProcessing();
                try
                {
                    string localHost = Dns.GetHostName();
                    if (ServerName.Contains(localHost))
                    {
                        isLocal = true;
                    }

                    if (ServerName.Contains(":"))
                    {
                        portNumber = Convert.ToInt16(ServerName.Substring(ServerName.IndexOf(":"), ServerName.Length - ServerName.IndexOf(":")).Replace(":", ""));
                        wuaServer = ServerName.Substring(0, ServerName.IndexOf(":"));
                    }
                    else
                    {
                        portNumber = 8530;
                        wuaServer = ServerName;
                    }
                }
                catch
                {
                }
            }

            protected override void ProcessRecord()
            {
                base.ProcessRecord();
                try
                {
                    if (isLocal)
                    {
                        updateServer = adminProxy.GetUpdateServerInstance();
                    }
                    else
                    {
                        updateServer = adminProxy.GetRemoteUpdateServerInstance(wuaServer, UseSecureConnection, portNumber);
                    }
                }
                catch
                {
                }
            }

            protected override void EndProcessing()
            {
                base.EndProcessing();
                WriteObject(updateServer);
            }
        }
        //
        // End-User Cmdlets
        //
        [Cmdlet(VerbsCommon.Get, "wuUpdate")]
        public class Get_wuUpdate : Cmdlet
        {
            [Parameter(Mandatory = false,
                HelpMessage = "Please provide a valid search criteria")]
            [ValidateNotNullOrEmpty]
            public string Criteria = "IsInstalled=0 and Type='Software'";

            [Parameter(Mandatory = false,
                HelpMessage = "If present get updates from Microsoft Servers")]
            public SwitchParameter FromMicrosoft;

            ISearchResult searchResult;

            protected override void BeginProcessing()
            {
                base.BeginProcessing();
            }

            protected override void ProcessRecord()
            {
                base.ProcessRecord();
                UpdateSession updateSession = new UpdateSession();
                IUpdateSearcher updateSearcher = updateSession.CreateUpdateSearcher();
                if (FromMicrosoft)
                {
                    int ssWindowsUpdate = 2;
                    updateSearcher.ServerSelection = (ServerSelection)ssWindowsUpdate;
                }
                searchResult = updateSearcher.Search(Criteria);
            }

            protected override void EndProcessing()
            {
                base.EndProcessing();
                WriteObject(searchResult.Updates);
            }
        }

        [Cmdlet(VerbsLifecycle.Start, "wuDownload")]
        public class Start_wuDownload : Cmdlet
        {
            [Parameter(Mandatory = true, ValueFromPipeline = true,
                HelpMessage = "The update to download")]
            public WUApiLib.IUpdate Update;

            WUApiLib.UpdateCollection updatesToDownload;
            UpdateSession updateSession = new UpdateSession();
            UpdateDownloader updateDownloader;

            protected override void BeginProcessing()
            {
                base.BeginProcessing();
                updateDownloader = updateSession.CreateUpdateDownloader();
            }

            protected override void ProcessRecord()
            {
                base.ProcessRecord();
                if ((Update.EulaAccepted) && !(Update.InstallationBehavior.CanRequestUserInput))
                {
                    updatesToDownload.Add(Update);
                    updateDownloader.Updates = updatesToDownload;
                    updateDownloader.Download();
                }
            }

            protected override void EndProcessing()
            {
                base.EndProcessing();
                WriteObject(updatesToDownload);
            }
        }
    }
}
