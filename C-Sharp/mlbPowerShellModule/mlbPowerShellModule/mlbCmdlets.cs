using System;
using System.Text;
using System.Net;
using System.IO;
using System.Xml;
using System.Xml.Linq;
using System.Collections.Generic;
using System.Management.Automation;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Json;
using System.Web.Script.Serialization;

namespace mlbPowerShellModule
{
    [DataContract]
    public class Pitcher
    {
        [DataMember]
        public object loss_id { get; set; }
        [DataMember]
        public object win_id { get; set; }
        [DataMember]
        public object win { get; set; }
        [DataMember]
        public object loss_stat { get; set; }
        [DataMember]
        public object win_stat { get; set; }
        [DataMember]
        public object save { get; set; }
        [DataMember]
        public object save_stat { get; set; }
        [DataMember]
        public object loss { get; set; }
        [DataMember]
        public object save_id { get; set; }
    }

    [DataContract]
    public class Home
    {
        [DataMember]
        public string file_code { get; set; }
        [DataMember]
        public string probable_stat { get; set; }
        [DataMember]
        public string tv { get; set; }
        [DataMember]
        public string id { get; set; }
        [DataMember]
        public bool split { get; set; }
        [DataMember]
        public string probable_name_display_first_last { get; set; }
        [DataMember]
        public string probable_report { get; set; }
        [DataMember]
        public object recap { get; set; }
        [DataMember]
        public string full { get; set; }
        [DataMember]
        public string radio { get; set; }
        [DataMember]
        public object tickets { get; set; }
        [DataMember]
        public string game_time_offset { get; set; }
        [DataMember]
        public string display_code { get; set; }
        [DataMember]
        public object wrapup { get; set; }
        [DataMember]
        public string audio_uri { get; set; }
        [DataMember]
        public string probable { get; set; }
        [DataMember]
        public string probable_era { get; set; }
        [DataMember]
        public string league { get; set; }
        [DataMember]
        public string probable_id { get; set; }
        [DataMember]
        public object result { get; set; }
    }

    [DataContract]
    public class Away
    {
        [DataMember]
        public string file_code { get; set; }
        [DataMember]
        public string probable_stat { get; set; }
        [DataMember]
        public string tv { get; set; }
        [DataMember]
        public string id { get; set; }
        [DataMember]
        public bool split { get; set; }
        [DataMember]
        public string probable_name_display_first_last { get; set; }
        [DataMember]
        public string probable_report { get; set; }
        [DataMember]
        public object recap { get; set; }
        [DataMember]
        public string full { get; set; }
        [DataMember]
        public string radio { get; set; }
        [DataMember]
        public object tickets { get; set; }
        [DataMember]
        public string game_time_offset { get; set; }
        [DataMember]
        public string display_code { get; set; }
        [DataMember]
        public object wrapup { get; set; }
        [DataMember]
        public string audio_uri { get; set; }
        [DataMember]
        public string probable { get; set; }
        [DataMember]
        public string probable_era { get; set; }
        [DataMember]
        public string league { get; set; }
        [DataMember]
        public string probable_id { get; set; }
        [DataMember]
        public object result { get; set; }
    }

    [DataContract]
    public class RootObject
    {
        [DataMember]
        public string game_id { get; set; }
        [DataMember]
        public string game_pk { get; set; }
        [DataMember]
        public bool game_time_is_tbd { get; set; }
        [DataMember]
        public string game_venue { get; set; }
        [DataMember]
        public string game_time { get; set; }
        [DataMember]
        public string game_time_offset_eastern { get; set; }
        [DataMember]
        public Pitcher pitcher { get; set; }
        [DataMember]
        public string game_location { get; set; }
        [DataMember]
        public Home home { get; set; }
        [DataMember]
        public object division_id { get; set; }
        [DataMember]
        public string game_time_offset_local { get; set; }
        [DataMember]
        public object scheduledTime { get; set; }
        [DataMember]
        public string game_status { get; set; }
        [DataMember]
        public bool mlbtv { get; set; }
        [DataMember]
        public bool is_suspension_resumption { get; set; }
        [DataMember]
        public string video_uri { get; set; }
        [DataMember]
        public string sport_code { get; set; }
        [DataMember]
        public string venue_id { get; set; }
        [DataMember]
        public object wrapup { get; set; }
        [DataMember]
        public string preview { get; set; }
        [DataMember]
        public string game_type { get; set; }
        [DataMember]
        public object resumptionTime { get; set; }
        [DataMember]
        public Away away { get; set; }
        [DataMember]
        public object game_dh { get; set; }
        [DataMember]
        public string game_num { get; set; }
    }

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
            //DataContractJsonSerializer jsonSerializer = new DataContractJsonSerializer(typeof(RootObject));
            //RootObject gameSchedule = (RootObject)jsonSerializer.ReadObject(webRequest.GetResponse().GetResponseStream());
            //WriteObject(gameSchedule);
            JavaScriptSerializer jserial = new JavaScriptSerializer();
            StreamReader streamReader = new StreamReader(webRequest.GetResponse().GetResponseStream());
            WriteObject(jserial.Deserialize<List<RootObject>>(streamReader.ReadToEnd().ToString()));
        }

        protected override void EndProcessing()
        {
            base.EndProcessing();
        }
    }
}
