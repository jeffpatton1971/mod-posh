using System;
using System.Collections.Generic;
using System.Text;
using System.Management;
using System.Management.Automation;
using System.Net;
using Microsoft.UpdateServices.Administration;

namespace WindowsUpdateLibrary
{
    class muaCmdlets
    {
        //
        // Administrative Cmdlets
        //
        [Cmdlet(VerbsCommunications.Connect, "muaServer")]
        public class Connect_muaServer : PSCmdlet
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
                        Globals.updateServer = adminProxy.GetUpdateServerInstance();
                    }
                    else
                    {
                        Globals.updateServer = adminProxy.GetRemoteUpdateServerInstance(wuaServer, UseSecureConnection, portNumber);
                    }
                }
                catch
                {
                }
            }

            protected override void EndProcessing()
            {
                base.EndProcessing();
                WriteObject(Globals.updateServer);
            }
        }
    }
}
