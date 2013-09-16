using System;
using System.Collections;
using System.Collections.ObjectModel;
using System.Management.Automation;
using CookComputing.XmlRpc;

namespace PapercutManagement
{
    public class Globals
    {
        public static string authToken;
        public static string ComputerName;
        public static int Port;
    }

    [Cmdlet(VerbsCommunications.Connect, "PcutServer")]
    public class Connect_PcutServer : Cmdlet
    {
        [Parameter(Mandatory = true,
            HelpMessage = "Please provide authToken")]
        [ValidateNotNullOrEmpty]
        public string authToken;

        [Parameter(Mandatory = true,
            HelpMessage = "Please enter the name of the papercut server")]
        [ValidateNotNullOrEmpty]
        public string ComputerName;

        [Parameter(Mandatory = false,
            HelpMessage = "Please enter the port number, or leave blank for default (9191)")]
        public int Port = 9191;

        static ServerCommandProxy _serverProxy;

        protected override void ProcessRecord()
        {
            base.ProcessRecord();
            _serverProxy = new ServerCommandProxy(ComputerName, Port, authToken);
            try
            {
                int TotalUsers;
                TotalUsers = _serverProxy.GetTotalUsers();
                if (TotalUsers >= 0)
                {
                    Globals.authToken = authToken;
                    Globals.ComputerName = ComputerName;
                    Globals.Port = Port;

                    WriteObject("Connected to " + Globals.ComputerName + ":" + Globals.Port);
                }
            }
            catch (XmlRpcFaultException fex)
            {
                ErrorRecord errRecord = new ErrorRecord(new Exception(fex.Message, fex.InnerException), fex.FaultString, ErrorCategory.NotSpecified, fex);
                WriteError(errRecord);
            }
        }
    }

    [Cmdlet(VerbsCommunications.Disconnect, "PcutServer")]
    public class Disconnect_PcutServer : Cmdlet
    {
        static ServerCommandProxy _serverProxy;

        protected override void ProcessRecord()
        {
            base.ProcessRecord();
            if (Globals.authToken != null)
            {
                _serverProxy = new ServerCommandProxy(Globals.ComputerName, Globals.Port, Globals.authToken);
                try
                {
                    Globals.ComputerName = null;
                    Globals.authToken = null;
                    Globals.Port = 0;
                    WriteObject("You are disconnected from the server");
                }
                catch (XmlRpcFaultException fex)
                {
                    ErrorRecord errRecord = new ErrorRecord(new Exception(fex.Message, fex.InnerException), fex.FaultString, ErrorCategory.NotSpecified, fex);
                    WriteError(errRecord);
                }
            }
            else
            {
                WriteObject("Please run Connect-PcutServer in order to establish connection.");
            }
        }
    }

    [Cmdlet(VerbsCommon.Get,"PcutTotalUsers")]
    public class Get_PcutTotalUsers : Cmdlet
    {
        static ServerCommandProxy _serverProxy;

        protected override void ProcessRecord()
        {
            base.ProcessRecord();
            if (Globals.authToken != null)
            {
                _serverProxy = new ServerCommandProxy(Globals.ComputerName, Globals.Port, Globals.authToken);
                try
                {
                    int TotalUsers;
                    TotalUsers = _serverProxy.GetTotalUsers();
                    PSObject returnTotalusers = new PSObject();
                    PSNoteProperty propertyTotalUsers = new PSNoteProperty("TotalUsers", TotalUsers);
                    PSNoteProperty propertyComputerName = new PSNoteProperty("Server", Globals.ComputerName);
                    returnTotalusers.Properties.Add(propertyTotalUsers);
                    returnTotalusers.Properties.Add(propertyComputerName);
                    WriteObject(returnTotalusers);
                }
                catch (XmlRpcFaultException fex)
                {
                    ErrorRecord errRecord = new ErrorRecord(new Exception(fex.Message, fex.InnerException), fex.FaultString, ErrorCategory.NotSpecified, fex);
                    WriteError(errRecord);
                }
            }
            else
            {
                WriteObject("Please run Connect-PcutServer in order to establish connection.");
            }
        }
    }

    [Cmdlet(VerbsCommon.Get, "PcutUser")]
    public class Get_PcutUser : Cmdlet
    {
        [Parameter(Mandatory = false,
            HelpMessage = "Please enter a number to start at (default 0)")]
        public int Offset = 0;

        [Parameter(Mandatory = false,
            HelpMessage = "Please enter the total number of users to return (default 1000)")]
        public int Limit = 1000;

        static ServerCommandProxy _serverProxy;

        protected override void ProcessRecord()
        {
            base.ProcessRecord();
            if (Globals.authToken != null)
            {
                _serverProxy = new ServerCommandProxy(Globals.ComputerName, Globals.Port, Globals.authToken);
                string[] pcutUsers;
                try
                {
                    pcutUsers = _serverProxy.ListUserAccounts(Offset, Limit);
                    Collection<PSObject> returnPcutUsers = new Collection<PSObject>();
                    foreach (string pcutUser in pcutUsers)
                    {
                        PSObject thisUser = new PSObject();
                        thisUser.Properties.Add(new PSNoteProperty("Username", pcutUser));
                        returnPcutUsers.Add(thisUser);
                    }
                    WriteObject(returnPcutUsers);
                }
                catch (XmlRpcFaultException fex)
                {
                    ErrorRecord errRecord = new ErrorRecord(new Exception(fex.Message, fex.InnerException), fex.FaultString, ErrorCategory.NotSpecified, fex);
                    WriteError(errRecord);
                }
            }
            else
            {
                WriteObject("Please run Connect-PcutServer in order to establish connection.");
            }
        }
    }

    [Cmdlet(VerbsCommon.Get, "PcutUserAccountBalance")]
    public class Get_PcutUserAccountBalance : Cmdlet
    {
        [Parameter(Mandatory = true,
            HelpMessage = "Please provide the current username")]
        [ValidateNotNullOrEmpty]
        public string UserName;

        static ServerCommandProxy _serverProxy;

        protected override void ProcessRecord()
        {
            base.ProcessRecord();
            if (Globals.authToken != null)
            {
                _serverProxy = new ServerCommandProxy(Globals.ComputerName, Globals.Port, Globals.authToken);
                try
                {
                    double pcutUserAccountBalance = _serverProxy.GetUserAccountBalance(UserName,null);
                    PSObject returnPcutUserAccountBalance = new PSObject();
                    returnPcutUserAccountBalance.Properties.Add(new PSNoteProperty("Username",UserName));
                    returnPcutUserAccountBalance.Properties.Add(new PSNoteProperty("Balance",pcutUserAccountBalance));
                    WriteObject(returnPcutUserAccountBalance);
                }
                catch (XmlRpcFaultException fex)
                {
                    ErrorRecord errRecord = new ErrorRecord(new Exception(fex.Message, fex.InnerException), fex.FaultString, ErrorCategory.NotSpecified, fex);
                    WriteError(errRecord);
                }
            }
            else
            {
                WriteObject("Please run Connect-PcutServer in order to establish connection.");
            }
        }
    }

    [Cmdlet(VerbsCommon.Get, "PcutUserProperties")]
    public class Get_PcutUserProperties : Cmdlet
    {
        [Parameter(Mandatory = true,
            HelpMessage = "Please provide the current username")]
        [ValidateNotNullOrEmpty]
        public string UserName;

        static ServerCommandProxy _serverProxy;

        protected override void ProcessRecord()
        {
            base.ProcessRecord();
            if (Globals.authToken != null)
            {
                _serverProxy = new ServerCommandProxy(Globals.ComputerName, Globals.Port, Globals.authToken);
                try
                {
                    string[] propertyNames = new string[] { "full-name","email","disabled-print","balance","restricted","account-selection.mode","department","office","card-number","card-pin","notes" };
                    string[] pcutUserProperties = _serverProxy.GetUserProperties(UserName,propertyNames);
                    PSObject returnPcutUserProperties = new PSObject();
                    returnPcutUserProperties.Properties.Add(new PSNoteProperty("Username",UserName));
                    int propertyCount = 0;
                    foreach (string propertyName in propertyNames)
                    {
                        returnPcutUserProperties.Properties.Add(new PSNoteProperty(propertyName, pcutUserProperties[propertyCount]));
                        propertyCount += 1;
                    }
                    WriteObject(returnPcutUserProperties);
                }
                catch (XmlRpcFaultException fex)
                {
                    ErrorRecord errRecord = new ErrorRecord(new Exception(fex.Message, fex.InnerException), fex.FaultString, ErrorCategory.NotSpecified, fex);
                    WriteError(errRecord);
                }
            }
            else
            {
                WriteObject("Please run Connect-PcutServer in order to establish connection.");
            }
        }
    }

    [Cmdlet(VerbsCommon.Set, "PcutUserProperty")]
    public class Set_PcutUserProperty : Cmdlet
    {
        [Parameter(Mandatory = true,
            HelpMessage = "Please provide the current username")]
        [ValidateNotNullOrEmpty]
        public string UserName;

        [Parameter(Mandatory = true,
            HelpMessage = "Please enter a valid propertyName Valid options include: card-number, card-pin, department, email, full-name, notes, office,")]
        [ValidateSet(new string[] { "card-number","card-pin","department","email","full-name","notes","office" })]
        public string PropertyName;

        [Parameter(Mandatory = true,
            HelpMessage = "Please provide a propertyValue")]
        [ValidateNotNullOrEmpty]
        public string PropertyValue;

        static ServerCommandProxy _serverProxy;

        protected override void ProcessRecord()
        {
            base.ProcessRecord();
            if (Globals.authToken != null)
            {
                _serverProxy = new ServerCommandProxy(Globals.ComputerName, Globals.Port, Globals.authToken);
                try
                {
                    _serverProxy.SetUserProperty(UserName, PropertyName, PropertyValue);
                    PSObject returnSetUserProperty = new PSObject();
                    returnSetUserProperty.Properties.Add(new PSNoteProperty("Username", UserName));
                    returnSetUserProperty.Properties.Add(new PSNoteProperty("propertyName", PropertyName));
                    returnSetUserProperty.Properties.Add(new PSNoteProperty("propertyValue", PropertyValue));
                    WriteObject(returnSetUserProperty);
                }
                catch (XmlRpcFaultException fex)
                {
                    ErrorRecord errRecord = new ErrorRecord(new Exception(fex.Message, fex.InnerException), fex.FaultString, ErrorCategory.NotSpecified, fex);
                    WriteError(errRecord);
                }
            }
            else
            {
                WriteObject("Please run Connect-PcutServer in order to establish connection.");
            }
        }
    }

    [Cmdlet(VerbsCommon.Get, "PcutUserProperty")]
    public class Get_PcutUserProperty : Cmdlet
    {
        [Parameter(Mandatory = true,
            HelpMessage = "Please provide the current username")]
        [ValidateNotNullOrEmpty]
        public string UserName;

        [Parameter(Mandatory = true,
            HelpMessage = "Please provide a propertyName")]
        [ValidateNotNullOrEmpty]
        public string PropertyName;

        static ServerCommandProxy _serverProxy;

        protected override void ProcessRecord()
        {
            base.ProcessRecord();
            if (Globals.authToken != null)
            {
                _serverProxy = new ServerCommandProxy(Globals.ComputerName, Globals.Port, Globals.authToken);
                try
                {
                    string PropertyValue = _serverProxy.GetUserProperty(UserName, PropertyName);
                    PSObject returnPcutGetUserProperty = new PSObject();
                    returnPcutGetUserProperty.Properties.Add(new PSNoteProperty("Username", UserName));
                    returnPcutGetUserProperty.Properties.Add(new PSNoteProperty("propertyName", PropertyName));
                    returnPcutGetUserProperty.Properties.Add(new PSNoteProperty("propertyValue", PropertyValue));
                    WriteObject(returnPcutGetUserProperty);
                }
                catch (XmlRpcFaultException fex)
                {
                    ErrorRecord errRecord = new ErrorRecord(new Exception(fex.Message, fex.InnerException), fex.FaultString, ErrorCategory.NotSpecified, fex);
                    WriteError(errRecord);
                }
            }
            else
            {
                WriteObject("Please run Connect-PcutServer in order to establish connection.");
            }
        }
    }

    [Cmdlet(VerbsCommon.Set, "PcutUserAccountBalance")]
    public class Set_PcutUserAccountBalance : Cmdlet
    {
        [Parameter(Mandatory = true,
            HelpMessage = "Please provide the current username")]
        [ValidateNotNullOrEmpty]
        public string UserName;

        [Parameter(Mandatory = true,
            HelpMessage = "Enter the new balance")]
        [ValidateNotNullOrEmpty]
        public double Balance;

        [Parameter(Mandatory = false,
            HelpMessage = "Enter an optional comment")]
        public string Comment;

        static ServerCommandProxy _serverProxy;

        protected override void ProcessRecord()
        {
            base.ProcessRecord();
            if (Globals.authToken != null)
            {
                _serverProxy = new ServerCommandProxy(Globals.ComputerName, Globals.Port, Globals.authToken);
                try
                {
                    _serverProxy.SetUserAccountBalance(UserName, Balance, Comment, null);
                    PSObject returnPcutSetUserAccountBalance = new PSObject();
                    returnPcutSetUserAccountBalance.Properties.Add(new PSNoteProperty("Username",UserName));
                    returnPcutSetUserAccountBalance.Properties.Add(new PSNoteProperty("Balance",Balance));
                    returnPcutSetUserAccountBalance.Properties.Add(new PSNoteProperty("Comment", Comment));
                    WriteObject(returnPcutSetUserAccountBalance);
                }
                catch (XmlRpcFaultException fex)
                {
                    ErrorRecord errRecord = new ErrorRecord(new Exception(fex.Message, fex.InnerException), fex.FaultString, ErrorCategory.NotSpecified, fex);
                    WriteError(errRecord);
                }
            }
            else
            {
                WriteObject("Please run Connect-PcutServer in order to establish connection.");
            }
        }
    }

    [Cmdlet(VerbsCommon.Get, "PcutGroup")]
    public class Get_PcutGroup : Cmdlet
    {
        [Parameter(Mandatory = false,
            HelpMessage = "Please enter a number to start at (default 0)")]
        public int Offset = 0;

        [Parameter(Mandatory = false,
            HelpMessage = "Please enter the total number of users to return (default 1000)")]
        public int Limit = 1000;

        static ServerCommandProxy _serverProxy;

        protected override void ProcessRecord()
        {
            base.ProcessRecord();
            if (Globals.authToken != null)
            {
                _serverProxy = new ServerCommandProxy(Globals.ComputerName, Globals.Port, Globals.authToken);
                try
                {
                    string[] pcutGroups = _serverProxy.ListUserGroups(Offset, Limit);
                    Collection<PSObject> returnPcutGroups = new Collection<PSObject>();
                    foreach (string pcutGroup in pcutGroups)
                    {
                        PSObject thisGroup = new PSObject();
                        thisGroup.Properties.Add(new PSNoteProperty("Name",pcutGroup));
                        returnPcutGroups.Add(thisGroup);
                    }
                    WriteObject(returnPcutGroups);
                }
                catch (XmlRpcFaultException fex)
                {
                    ErrorRecord errRecord = new ErrorRecord(new Exception(fex.Message, fex.InnerException), fex.FaultString, ErrorCategory.NotSpecified, fex);
                    WriteError(errRecord);
                }
            }
            else
            {
                WriteObject("Please run Connect-PcutServer in order to establish connection.");
            }
        }
    }

    [Cmdlet(VerbsCommon.Get, "PcutUserGroup")]
    public class Get_PcutUserGroup : Cmdlet
    {
        [Parameter(Mandatory = true,
            HelpMessage = "Please provide the current username")]
        [ValidateNotNullOrEmpty]
        public string UserName;

        static ServerCommandProxy _serverProxy;

        protected override void ProcessRecord()
        {
            base.ProcessRecord();
            if (Globals.authToken != null)
            {
                _serverProxy = new ServerCommandProxy(Globals.ComputerName, Globals.Port, Globals.authToken);
                try
                {
                    string[] pcutUserGroups = _serverProxy.GetUserGroups(UserName);
                    Collection<PSObject> returnPcutUserGroups = new Collection<PSObject>();
                    foreach (string pcutUserGroup in pcutUserGroups)
                    {
                        PSObject thisGroup = new PSObject();
                        thisGroup.Properties.Add(new PSNoteProperty("Name", pcutUserGroup));
                        returnPcutUserGroups.Add(thisGroup);
                    }
                    WriteObject(returnPcutUserGroups);
                }
                catch (XmlRpcFaultException fex)
                {
                    ErrorRecord errRecord = new ErrorRecord(new Exception(fex.Message, fex.InnerException), fex.FaultString, ErrorCategory.NotSpecified, fex);
                    WriteError(errRecord);
                }
            }
            else
            {
                WriteObject("Please run Connect-PcutServer in order to establish connection.");
            }
        }
    }

    [Cmdlet(VerbsData.Update, "PcutUserAccountBalance")]
    public class Update_PcutUserAccountBalance : Cmdlet
    {
        [Parameter(Mandatory = true,
            HelpMessage = "Please provide the current username")]
        [ValidateNotNullOrEmpty]
        public string UserName;

        [Parameter(Mandatory = true,
            HelpMessage = "Enter a positive or negative number to adjust balance by")]
        [ValidateNotNullOrEmpty]
        public double Adjustment;

        [Parameter(Mandatory = false,
            HelpMessage = "Enter an optional comment")]
        public string Comment;

        static ServerCommandProxy _serverProxy;

        protected override void ProcessRecord()
        {
            base.ProcessRecord();
            if (Globals.authToken != null)
            {
                _serverProxy = new ServerCommandProxy(Globals.ComputerName, Globals.Port, Globals.authToken);
                try
                {
                    double pcutUserPreviousBalance = _serverProxy.GetUserAccountBalance(UserName, null);
                    _serverProxy.AdjustUserAccountBalance(UserName, Adjustment, Comment, null);
                    double pcutUserNewBalance = _serverProxy.GetUserAccountBalance(UserName, null);
                    PSObject returnUpdatePcutUserAccountBalance = new PSObject();
                    returnUpdatePcutUserAccountBalance.Properties.Add(new PSNoteProperty("Username", UserName));
                    returnUpdatePcutUserAccountBalance.Properties.Add(new PSNoteProperty("OldBalance", pcutUserPreviousBalance));
                    returnUpdatePcutUserAccountBalance.Properties.Add(new PSNoteProperty("Adjustment", Adjustment));
                    returnUpdatePcutUserAccountBalance.Properties.Add(new PSNoteProperty("Balance", pcutUserNewBalance));
                    WriteObject(returnUpdatePcutUserAccountBalance);
                }
                catch (XmlRpcFaultException fex)
                {
                    ErrorRecord errRecord = new ErrorRecord(new Exception(fex.Message, fex.InnerException), fex.FaultString, ErrorCategory.NotSpecified, fex);
                    WriteError(errRecord);
                }
            }
            else
            {
                WriteObject("Please run Connect-PcutServer in order to establish connection.");
            }
        }
    }

    [Cmdlet(VerbsData.Update, "PcutGroupAccountBalance")]
    public class Update_PcutGroupAccountBalance : Cmdlet
    {
        [Parameter(Mandatory = true,
            HelpMessage = "Please provide the name of the group")]
        [ValidateNotNullOrEmpty]
        public string GroupName;

        [Parameter(Mandatory = true,
            HelpMessage = "Enter a positive or negative number to adjust balance by")]
        [ValidateNotNullOrEmpty]
        public double Adjustment;

        [Parameter(Mandatory = false,
            HelpMessage = "Enter an optional comment")]
        public string Comment;

        static ServerCommandProxy _serverProxy;

        protected override void ProcessRecord()
        {
            base.ProcessRecord();
            if (Globals.authToken != null)
            {
                _serverProxy = new ServerCommandProxy(Globals.ComputerName, Globals.Port, Globals.authToken);
                try
                {
                    _serverProxy.AdjustUserAccountBalanceByGroup(GroupName, Adjustment, Comment, null);
                    PSObject returnUpdatePcutGroupAccountBalance = new PSObject();
                    returnUpdatePcutGroupAccountBalance.Properties.Add(new PSNoteProperty("Name", GroupName));
                    returnUpdatePcutGroupAccountBalance.Properties.Add(new PSNoteProperty("Adjustment", Adjustment));
                    returnUpdatePcutGroupAccountBalance.Properties.Add(new PSNoteProperty("Comment", Comment));
                    WriteObject(returnUpdatePcutGroupAccountBalance);
                }
                catch (XmlRpcFaultException fex)
                {
                    ErrorRecord errRecord = new ErrorRecord(new Exception(fex.Message, fex.InnerException), fex.FaultString, ErrorCategory.NotSpecified, fex);
                    WriteError(errRecord);
                }
            }
            else
            {
                WriteObject("Please run Connect-PcutServer in order to establish connection.");
            }
        }
    }

    [Cmdlet(VerbsCommon.Rename, "PcutUser")]
    public class Rename_PcutUser : Cmdlet
    {
        [Parameter(Mandatory = true,
            HelpMessage = "Please provide the current username")]
        [ValidateNotNullOrEmpty]
        public string currentUserName;

        [Parameter(Mandatory = true,
            HelpMessage = "Please provide a new user name")]
        [ValidateNotNullOrEmpty]
        public string newUserName;

        static ServerCommandProxy _serverProxy;

        protected override void ProcessRecord()
        {
            base.ProcessRecord();
            if (Globals.authToken != null)
            {
                _serverProxy = new ServerCommandProxy(Globals.ComputerName, Globals.Port, Globals.authToken);
                try
                {
                    _serverProxy.RenameUserAccount(currentUserName, newUserName);
                    if (_serverProxy.UserExists(newUserName))
                    {
                        PSObject objNewUser = new PSObject();
                        PSNoteProperty noteProp = new PSNoteProperty("NewUsername", newUserName);
                        objNewUser.Properties.Add(noteProp);
                        WriteObject(objNewUser);
                    }
                }
                catch (XmlRpcFaultException fex)
                {
                    ErrorRecord errRecord = new ErrorRecord(new Exception(fex.Message, fex.InnerException), fex.FaultString, ErrorCategory.NotSpecified, fex);
                    WriteError(errRecord);
                }
            }
            else
            {
                WriteObject("Please run Connect-PcutServer in order to establish connection.");
            }
        }
    }
}
