using System;
using System.Collections.Generic;
using System.Runtime.Serialization;

namespace mlbPowerShellModule
{
    class mlbGamedaySchedule
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

    }
}
