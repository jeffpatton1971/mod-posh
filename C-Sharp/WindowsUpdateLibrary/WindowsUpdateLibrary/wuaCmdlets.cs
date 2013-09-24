using System;
using System.Collections.Generic;
using System.Management;
using System.Management.Automation;
using System.Net;
using WUApiLib;
using Microsoft.UpdateServices.Administration;

namespace WindowsUpdateLibrary
{
    public class Globals
    {
        public static UpdateSession updateSession = new UpdateSession();
        public static IUpdateSearcher updateSearcher = updateSession.CreateUpdateSearcher();
        public static IUpdateServer updateServer;
    }

    public class wuaCmdlets
    {
        //
        // End-User Cmdlets
        //
        [Cmdlet(VerbsCommon.Get, "wuaUpdate")]
        public class Get_wuaUpdate : PSCmdlet
        {
            [Parameter(Mandatory = false,
                HelpMessage = "Please provide a valid search criteria")]
            [ValidateNotNullOrEmpty]
            public string Criteria = "IsInstalled=0 and Type='Software'";

            [Parameter(Mandatory = false,
                HelpMessage = "If present get updates from Microsoft Servers")]
            public SwitchParameter FromMicrosoft;

            public ISearchResult searchResult;

            protected override void BeginProcessing()
            {
                base.BeginProcessing();
            }

            protected override void ProcessRecord()
            {
                base.ProcessRecord();
                if (FromMicrosoft)
                {
                    int ssWindowsUpdate = 2;
                    Globals.updateSearcher.ServerSelection = (ServerSelection)ssWindowsUpdate;
                }
                searchResult = Globals.updateSearcher.Search(Criteria);
            }

            protected override void EndProcessing()
            {
                base.EndProcessing();
                if (MyInvocation.BoundParameters.ContainsKey("Verbose"))
                {
                    foreach (WUApiLib.IUpdate Update in searchResult.Updates)
                    {
                        WriteVerbose("FOUND : " + Update.Title);
                    }
                }
                WriteObject(searchResult.Updates);
            }
        }

        [Cmdlet(VerbsLifecycle.Start, "wuaDownload")]
        public class Start_wuaDownload : PSCmdlet
        {
            [Parameter(Mandatory = true, ValueFromPipeline = true,
                HelpMessage = "The update to download")]
            public WUApiLib.UpdateCollection Update;

            WUApiLib.UpdateCollection updatesToDownload = new WUApiLib.UpdateCollection();
            UpdateDownloader updateDownloader;

            protected override void BeginProcessing()
            {
                base.BeginProcessing();
                updateDownloader = Globals.updateSession.CreateUpdateDownloader();                
            }

            protected override void ProcessRecord()
            {
                base.ProcessRecord();
                foreach (WUApiLib.IUpdate thisUpdate in Update)
                {
                    if ((thisUpdate.EulaAccepted) && !(thisUpdate.InstallationBehavior.CanRequestUserInput))
                    {
                        if (!(thisUpdate.IsDownloaded))
                        {
                            WriteVerbose("DOWNLOAD : " + thisUpdate.Title);
                            updatesToDownload.Add(thisUpdate);
                            updateDownloader.Updates = updatesToDownload;
                            updateDownloader.Download();
                        }
                    }
                }
            }

            protected override void EndProcessing()
            {
                base.EndProcessing();
                WriteObject(updatesToDownload);
            }
        }

        [Cmdlet(VerbsLifecycle.Install, "wuaUpdate")]
        public class Install_wuaUpdate : PSCmdlet
        {
            [Parameter(Mandatory = true, ValueFromPipeline = true,
                HelpMessage = "The update to download")]
            public WUApiLib.UpdateCollection Update;

            WUApiLib.UpdateCollection updatesToInstall = new WUApiLib.UpdateCollection();
            bool RebootRequired = false;

            protected override void BeginProcessing()
            {
                base.BeginProcessing();
            }

            protected override void ProcessRecord()
            {
                base.ProcessRecord();
                foreach (WUApiLib.IUpdate thisUpdate in Update)
                {
                    if (thisUpdate.IsDownloaded)
                    {
                        updatesToInstall.Add(thisUpdate);
                        if (thisUpdate.InstallationBehavior.RebootBehavior > 0)
                        {
                            RebootRequired = true;
                        }
                        IUpdateInstaller updateInstaller = Globals.updateSession.CreateUpdateInstaller();
                        updateInstaller.Updates = updatesToInstall;
                        IInstallationResult installationResult = updateInstaller.Install();
                        WriteVerbose(installationResult.HResult.ToString());
                    }
                }
            }

            protected override void EndProcessing()
            {
                base.EndProcessing();
                if (RebootRequired)
                {
                    WriteObject(RebootRequired);
                }
            }
        }

        [Cmdlet(VerbsCommon.Get, "wuaUpdateHistory")]
        public class Get_wuaUpdateHistory : PSCmdlet
        {
            [Parameter(Mandatory = false,
                HelpMessage = "Please enter a number to start out at (default=0)")]
            public int startIndex = 0;

            [Parameter(Mandatory = false,
                HelpMessage = "Enter the number of updates to return (default=10)")]
            public int Count = 10;

            public IUpdateHistoryEntryCollection updateHistory;

            protected override void BeginProcessing()
            {
                base.BeginProcessing();
                if (Count > Globals.updateSearcher.GetTotalHistoryCount())
                {
                    Count = Globals.updateSearcher.GetTotalHistoryCount();
                }

                if (startIndex < 0)
                {
                    startIndex = 0;
                }
            }

            protected override void ProcessRecord()
            {
                base.ProcessRecord();
                updateHistory = Globals.updateSearcher.QueryHistory(startIndex, Count);
            }

            protected override void EndProcessing()
            {
                base.EndProcessing();
                foreach (IUpdateHistoryEntry historyEntry in updateHistory)
                {
                    WriteObject(historyEntry);
                }
            }
        }

        [Cmdlet(VerbsCommon.Set, "wuaEULA")]
        public class Set_wuaEULA : PSCmdlet
        {
            [Parameter(Mandatory = true, ValueFromPipeline = true,
                HelpMessage = "The update to download")]
            public WUApiLib.UpdateCollection Update;

            [Parameter(Mandatory = false,
                HelpMessage = "True or false to approve or not approve an update (default=true)")]
            public bool AcceptEula = true;

            protected override void BeginProcessing()
            {
                base.BeginProcessing();
            }

            protected override void ProcessRecord()
            {
                base.ProcessRecord();
                foreach (WUApiLib.IUpdate thisUpdate in Update)
                {
                    if (!(thisUpdate.EulaAccepted))
                    {
                        if (AcceptEula)
                        {
                            thisUpdate.AcceptEula();
                        }
                    }
                }
            }

            protected override void EndProcessing()
            {
                base.EndProcessing();
            }
        }
    }
}