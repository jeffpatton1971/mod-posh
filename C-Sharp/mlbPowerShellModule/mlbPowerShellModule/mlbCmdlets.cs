using System;
using System.Net;
using System.IO;
using System.Xml;
using System.Management.Automation;

namespace mlbPowerShellModule
{
    [Cmdlet(VerbsCommon.Get, "mlbGamedayUrl")]
    public class Get_mlbGamedayUrl : Cmdlet
    {
        [Parameter(Mandatory = true, ValueFromPipeline = true,
            HelpMessage = "Enter a valid date")]
        public string Date;

        protected override void BeginProcessing()
        {
            base.BeginProcessing();
        }

        protected override void ProcessRecord()
        {
            base.ProcessRecord();
            DateTime currentDate = DateTime.Parse(Date);
            WriteVerbose(currentDate.ToLongDateString());
            string Month = currentDate.ToString("MM");
            string Year = currentDate.ToString("yyy");
            string Day = currentDate.ToString("dd");

            Uri gamedayURL = new Uri("http://gd2.mlb.com/components/game/mlb/year_" + Year + "/month_" + Month+ "/day_" + Day + "/");
            WriteVerbose(gamedayURL.OriginalString);
            WebRequest webRequest = WebRequest.Create(gamedayURL);
            webRequest.Method = "GET";
            StreamReader streamReader = new StreamReader(webRequest.GetResponse().GetResponseStream());

            string strLine = "";
            do
            {
                strLine = streamReader.ReadLine();
                WriteDebug(strLine);
                if (!(strLine == null))
                {
                    if (strLine.ToLower().StartsWith("<li>"))
                    {
                        if (strLine.ToLower().Contains("gid"))
                        {
                            Uri currentGamedayURL = new Uri(gamedayURL.OriginalString + strLine.Substring(strLine.IndexOf("gid"), strLine.IndexOf("/") - strLine.IndexOf("gid") + 1));
                            WriteDebug(currentGamedayURL.OriginalString);
                            WriteObject(currentGamedayURL);
                        }
                    }
                }
            }
            while(!(streamReader.EndOfStream));
            streamReader.Close();
        }

        protected override void EndProcessing()
        {
            base.EndProcessing();
        }
    }

    [Cmdlet(VerbsCommon.Get, "mlbGamedayItem")]
    public class Get_mlbGameDayItem : Cmdlet
    {
        [Parameter(Mandatory = true,
            HelpMessage = "A valid url object")]
        public Uri Url;

        [Parameter(Mandatory = true,
            HelpMessage = "Provide a proper item")]
        [ValidateSet("Events", "Boxscore", "Roster", "Umpires", "Game", "Bench","Innings","Plays")]
        public string Item;

        public string ItemFile = "";
        public static string xPath = "";

        protected override void BeginProcessing()
        {
            base.BeginProcessing();
            switch (Item.ToLower())
            {
                case "events":
                    ItemFile = "game_events.xml";
                    xPath = "game";
                    break;
                case "boxscore":
                    ItemFile = "rawboxscore.xml";
                    xPath = "boxscore";
                    break;
                case "roster":
                    ItemFile = "players.xml";
                    xPath = "game/team";
                    break;
                case "umpires":
                    ItemFile = "players.xml";
                    xPath = "game/umpires";
                    break;
                case "bench":
                    ItemFile = "bench.xml";
                    xPath = "bench";
                    break;
                case "game":
                    ItemFile = "game.xml";
                    xPath = "game";
                    break;
                case "innings":
                    ItemFile = "inning/inning_all.xml";
                    xPath = "game";
                    break;
                case "plays":
                    ItemFile = "plays.xml";
                    xPath = "game";
                    break;
            }
        }

        protected override void ProcessRecord()
        {
            base.ProcessRecord();
            Uri ItemUrl = new Uri(Url.OriginalString + ItemFile);
            WebClient webClient = new WebClient();
            XmlDocument Items = new XmlDocument();
            Items.LoadXml(webClient.DownloadString(ItemUrl));

            WriteObject(Items.SelectNodes(Get_mlbGameDayItem.xPath));
        }

        protected override void EndProcessing()
        {
            base.EndProcessing();
        }
    }

    [Cmdlet(VerbsCommon.Get, "mlbGamedayPlayer")]
    public class Get_mlbGamedayPlayer : Cmdlet
    {
        [Parameter(Mandatory = true,
            HelpMessage = "A valid url object")]
        public Uri Url;

        [Parameter(Mandatory = false,
            HelpMessage = "A valid player id")]
        public string PlayerID;

        [Parameter(Mandatory=false,
            HelpMessage="Show pitchers")]
        public SwitchParameter Pitchers;

        protected override void BeginProcessing()
        {
            base.BeginProcessing();
        }

        protected override void ProcessRecord()
        {
            base.ProcessRecord();

            string thisUrl = "";

            if (Pitchers == true)
            {
                thisUrl = Url.OriginalString + "pitchers/";
                WriteVerbose(thisUrl);
            }
            else
            {
                thisUrl = Url.OriginalString + "batters/";
                WriteVerbose(thisUrl);
            }

            WebRequest webRequest = WebRequest.Create(thisUrl);
            webRequest.Method = "GET";
            StreamReader streamReader = new StreamReader(webRequest.GetResponse().GetResponseStream());
            string strLine = null;
            do
            {
                strLine = streamReader.ReadLine();
                if (!(strLine == null))
                {
                    if (strLine.ToLower().StartsWith("<li>"))
                    {
                        if (strLine.ToLower().Contains(".xml"))
                        {
                            WriteDebug(strLine);
                            int selectionStart = (strLine.IndexOf("=") + 2);
                            int selectionEnd = (strLine.IndexOf(".") - strLine.IndexOf("=") + 2);
                            Uri playerUrl = new Uri(thisUrl + (strLine.Substring(selectionStart,selectionEnd)));
                            if (PlayerID != null)
                            {
                                if (playerUrl.OriginalString.Contains(PlayerID))
                                {
                                    WriteVerbose(PlayerID);
                                    WebClient webClient = new WebClient();
                                    XmlDocument Player = new XmlDocument();
                                    Player.LoadXml(webClient.DownloadString(playerUrl));
                                    WriteObject(Player.SelectNodes("Player"));
                                }
                            }
                            else
                            {
                                WebClient webClient = new WebClient();
                                XmlDocument Players = new XmlDocument();
                                Players.LoadXml(webClient.DownloadString(playerUrl));
                                WriteObject(Players.SelectNodes("Player"));
                            }
                        }
                    }
                }
            }
            while (streamReader.EndOfStream == false);
            streamReader.Close();
        }

        protected override void EndProcessing()
        {
            base.EndProcessing();
        }
    }
}
