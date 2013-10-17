using System;
using System.Net;
using System.IO;
using System.Xml;
using System.Collections.Generic;
using System.Management.Automation;
using System.Runtime.Serialization;
using System.Web.Script.Serialization;

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

            WriteObject(Items.SelectNodes(Get_mlbGameDayItem.xPath)[0]);
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
                                    WriteObject(Player.SelectNodes("Player")[0]);
                                }
                            }
                            else
                            {
                                WebClient webClient = new WebClient();
                                XmlDocument Players = new XmlDocument();
                                Players.LoadXml(webClient.DownloadString(playerUrl));
                                WriteObject(Players.SelectNodes("Player")[0]);
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

    [Cmdlet(VerbsCommon.Get, "mlbGamedaySchedule")]
    public class Get_mlbGamedaySchedule : Cmdlet
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

            string gamedayURL = "http://mlb.mlb.com/components/schedule/schedule_" + Year  + Month + Day +".json";
            WebRequest webRequest = WebRequest.Create(gamedayURL);
            WebResponse webResponse = webRequest.GetResponse();
            JavaScriptSerializer jserial = new JavaScriptSerializer();
            jserial.MaxJsonLength = int.MaxValue;
            StreamReader streamReader = new StreamReader(webRequest.GetResponse().GetResponseStream());
            WriteObject(jserial.Deserialize<List<mlbGamedaySchedule.RootObject>>(streamReader.ReadToEnd().ToString()));
        }

        protected override void EndProcessing()
        {
            base.EndProcessing();
        }
    }

    [Cmdlet(VerbsCommon.Get, "mlbTeamData")]
    public class Get_mlbTeamData : Cmdlet
    {
        [Parameter(Mandatory = false,
            HelpMessage = "Enter a valid sport_code")]
        [ValidateSet("mlb", "aaa","aax","afa","afx","asx","rok","win","min","ind","nlb","kor","jml","hpl","int","nat","nae","nav","nas","nan","naf","nal","naw","oly","bbc","fps","hsb")]
        public string Code;

        protected override void BeginProcessing()
        {
            base.BeginProcessing();
        }

        protected override void ProcessRecord()
        {
            base.ProcessRecord();
            string gamedayURL = "http://mlb.mlb.com/lookup/json/named.search_autocomp.bam";
            WebRequest webRequest = WebRequest.Create(gamedayURL);
            WebResponse webResponse = webRequest.GetResponse();
            JavaScriptSerializer jSerial = new JavaScriptSerializer();
            jSerial.MaxJsonLength = int.MaxValue;
            StreamReader streamReader = new StreamReader(webRequest.GetResponse().GetResponseStream());
            mlbSearch_Autocomp.RootObject allTeams = (mlbSearch_Autocomp.RootObject)(jSerial.Deserialize(streamReader.ReadToEnd().ToString(), typeof(mlbSearch_Autocomp.RootObject)));
            if (Code == null)
            {
                WriteObject(allTeams.search_autocomp.team_all.queryResults.row);
            }
            else
            {
                foreach (mlbSearch_Autocomp.Row2 team in allTeams.search_autocomp.team_all.queryResults.row)
                {
                    if (team.sport_code.ToLower() == Code.ToLower())
                    {
                        WriteObject(team);
                    }
                }
            }
        }

        protected override void EndProcessing()
        {
            base.EndProcessing();
        }
    }

    [Cmdlet(VerbsCommon.Find, "mlbPlayerData")]
    public class Find_mlbPlayerData : Cmdlet
    {
        [Parameter(Mandatory = true, Position = 0, ValueFromPipeline = true,
            HelpMessage = "Enter the last name of the player to find")]
        [ValidateNotNullOrEmpty]
        public string Name;

        [Parameter(Mandatory = false, Position = 1,
            HelpMessage = "Player is active")]
        [ValidateSet("yes","no")]
        public string Active = "yes";

        [Parameter(Mandatory = false, Position = 2,
            HelpMessage = "Enter a valid sport_code")]
        [ValidateSet("mlb", "aaa", "aax", "afa", "afx", "asx", "rok", "win", "min", "ind", "nlb", "kor", "jml", "hpl", "int", "nat", "nae", "nav", "nas", "nan", "naf", "nal", "naw", "oly", "bbc", "fps", "hsb")]
        public string Code = "mlb";

        protected override void BeginProcessing()
        {
            base.BeginProcessing();
        }

        protected override void ProcessRecord()
        {
            base.ProcessRecord();
            if (Active == "yes")
            {
                Active = "Y";
            }
            else
            {
                Active = "N";
            }
            string playerUrl = "http://mlb.mlb.com/lookup/json/named.search_player_all.bam?sport_code='" + Code + "'&name_part='" + Name.ToUpper() + "%25%25'&active_sw='" + Active + "'";
            WebRequest webRequest = WebRequest.Create(playerUrl);
            WebResponse webResponse = webRequest.GetResponse();
            JavaScriptSerializer jSerial = new JavaScriptSerializer();
            jSerial.MaxJsonLength = int.MaxValue;
            StreamReader streamReader = new StreamReader(webRequest.GetResponse().GetResponseStream());
            mlbNamedSearch_Player.RootObject allPlayers = (mlbNamedSearch_Player.RootObject)(jSerial.Deserialize(streamReader.ReadToEnd().ToString(), typeof(mlbNamedSearch_Player.RootObject)));
            WriteObject(allPlayers.search_player_all.queryResults.row);
        }

        protected override void EndProcessing()
        {
            base.EndProcessing();
        }
    }

    [Cmdlet(VerbsCommon.Get, "mlbPitcherData")]
    public class Get_mlbPitcherData : Cmdlet
    {
        [Parameter(Mandatory = true, Position = 0,
            HelpMessage = "Enter the year for the pitcher")]
        public string Season;

        [Parameter(Mandatory = false, Position = 1,
            HelpMessage = "Enter the PlayerID for the pitcher")]
        public string PlayerID;

        [Parameter(Mandatory = false, Position = 2,
            HelpMessage = "Enter the game type")]
        [ValidateSet("a","d","l","r","s","w")]
        public string GameType;

        protected override void BeginProcessing()
        {
            base.BeginProcessing();
        }

        protected override void ProcessRecord()
        {
            base.ProcessRecord();
            string pitcherURL = "http://mlb.mlb.com/lookup/json/named.mlb_bio_pitching_summary.bam?mlb_individual_pitching_season_sportcode.season=" + Season + "&player_id=" + PlayerID + "&game_type=%27" + GameType.ToUpper() + "%27&sort_by=%27season_asc%27";
            WebRequest webRequest = WebRequest.Create(pitcherURL);
            WebResponse webResponse = webRequest.GetResponse();
            JavaScriptSerializer jSerial = new JavaScriptSerializer();
            jSerial.MaxJsonLength = int.MaxValue;
            StreamReader streamReader = new StreamReader(webRequest.GetResponse().GetResponseStream());
            mlbBio_Pitching_Summary.RootObject allPitchers = (mlbBio_Pitching_Summary.RootObject)(jSerial.Deserialize(streamReader.ReadToEnd().ToString(), typeof(mlbBio_Pitching_Summary.RootObject)));
            WriteObject(allPitchers.mlb_bio_pitching_summary.mlb_individual_pitching_season.queryResults.row);
        }

        protected override void EndProcessing()
        {
            base.EndProcessing();
        }
    }
}
