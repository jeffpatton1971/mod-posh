using System;
using System.Collections.Generic;
using System.Runtime.Serialization;

namespace mlbPowerShellModule
{
    class mlbNamedSearch_Player
    {
        [DataContract]
        public class Row
        {
            [DataMember]
            public string position { get; set; }
            [DataMember]
            public string birth_country { get; set; }
            [DataMember]
            public string birth_state { get; set; }
            [DataMember]
            public string weight { get; set; }
            [DataMember]
            public string name_display_first_last { get; set; }
            [DataMember]
            public string college { get; set; }
            [DataMember]
            public string height_inches { get; set; }
            [DataMember]
            public string name_display_roster { get; set; }
            [DataMember]
            public string sport_code { get; set; }
            [DataMember]
            public string bats { get; set; }
            [DataMember]
            public string name_first { get; set; }
            [DataMember]
            public string team_code { get; set; }
            [DataMember]
            public string birth_city { get; set; }
            [DataMember]
            public string height_feet { get; set; }
            [DataMember]
            public string pro_debut_date { get; set; }
            [DataMember]
            public string team_full { get; set; }
            [DataMember]
            public string team_abbrev { get; set; }
            [DataMember]
            public string birth_date { get; set; }
            [DataMember]
            public string throws { get; set; }
            [DataMember]
            public string league { get; set; }
            [DataMember]
            public string name_display_last_first { get; set; }
            [DataMember]
            public string position_id { get; set; }
            [DataMember]
            public string high_school { get; set; }
            [DataMember]
            public string name_use { get; set; }
            [DataMember]
            public string player_id { get; set; }
            [DataMember]
            public string name_last { get; set; }
            [DataMember]
            public string team_id { get; set; }
            [DataMember]
            public string service_years { get; set; }
            [DataMember]
            public string active_sw { get; set; }
        }

        [DataContract]
        public class QueryResults
        {
            [DataMember]
            public string created { get; set; }
            [DataMember]
            public string totalSize { get; set; }
            [DataMember]
            public List<Row> row { get; set; }
        }

        [DataContract]
        public class SearchPlayerAll
        {
            [DataMember]
            public string copyRight { get; set; }
            [DataMember]
            public QueryResults queryResults { get; set; }
        }

        [DataContract]
        public class RootObject
        {
            [DataMember]
            public SearchPlayerAll search_player_all { get; set; }
        }
    }
}