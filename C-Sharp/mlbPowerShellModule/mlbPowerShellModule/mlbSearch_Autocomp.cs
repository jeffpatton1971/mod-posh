using System;
using System.Collections.Generic;
using System.Runtime.Serialization;

namespace mlbPowerShellModule
{
    class mlbSearch_Autocomp
    {
        [DataContract]
        public class Row
        {
            [DataMember]
            public string t { get; set; }
            [DataMember]
            public string p { get; set; }
            [DataMember]
            public string n { get; set; }
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
        public class SearchAutocomplete
        {
            [DataMember]
            public QueryResults queryResults { get; set; }
        }

        [DataContract]
        public class Row2
        {
            [DataMember]
            public string phone_number { get; set; }
            [DataMember]
            public string venue_name { get; set; }
            [DataMember]
            public string franchise_code { get; set; }
            [DataMember]
            public string sport_full { get; set; }
            [DataMember]
            public string all_star_sw { get; set; }
            [DataMember]
            public string sport_code { get; set; }
            [DataMember]
            public string address_city { get; set; }
            [DataMember]
            public string city { get; set; }
            [DataMember]
            public string name_display_full { get; set; }
            [DataMember]
            public string spring_league_abbrev { get; set; }
            [DataMember]
            public string time_zone_alt { get; set; }
            [DataMember]
            public string sport_id { get; set; }
            [DataMember]
            public string venue_id { get; set; }
            [DataMember]
            public string mlb_org_id { get; set; }
            [DataMember]
            public string mlb_org { get; set; }
            [DataMember]
            public string last_year_of_play { get; set; }
            [DataMember]
            public string league_full { get; set; }
            [DataMember]
            public string league_id { get; set; }
            [DataMember]
            public string name_abbrev { get; set; }
            [DataMember]
            public string address_province { get; set; }
            [DataMember]
            public string bis_team_code { get; set; }
            [DataMember]
            public string league { get; set; }
            [DataMember]
            public string spring_league { get; set; }
            [DataMember]
            public string base_url { get; set; }
            [DataMember]
            public string address_zip { get; set; }
            [DataMember]
            public string sport_code_display { get; set; }
            [DataMember]
            public string mlb_org_short { get; set; }
            [DataMember]
            public string time_zone { get; set; }
            [DataMember]
            public string address_line1 { get; set; }
            [DataMember]
            public string mlb_org_brief { get; set; }
            [DataMember]
            public string address_line2 { get; set; }
            [DataMember]
            public string address_line3 { get; set; }
            [DataMember]
            public string division_abbrev { get; set; }
            [DataMember]
            public string sport_abbrev { get; set; }
            [DataMember]
            public string name_display_short { get; set; }
            [DataMember]
            public string team_id { get; set; }
            [DataMember]
            public string active_sw { get; set; }
            [DataMember]
            public string address_intl { get; set; }
            [DataMember]
            public string state { get; set; }
            [DataMember]
            public string address_country { get; set; }
            [DataMember]
            public string mlb_org_abbrev { get; set; }
            [DataMember]
            public string division { get; set; }
            [DataMember]
            public string name { get; set; }
            [DataMember]
            public string team_code { get; set; }
            [DataMember]
            public string sport_code_name { get; set; }
            [DataMember]
            public string website_url { get; set; }
            [DataMember]
            public string first_year_of_play { get; set; }
            [DataMember]
            public string league_abbrev { get; set; }
            [DataMember]
            public string name_display_long { get; set; }
            [DataMember]
            public string store_url { get; set; }
            [DataMember]
            public string name_short { get; set; }
            [DataMember]
            public string address_state { get; set; }
            [DataMember]
            public string division_full { get; set; }
            [DataMember]
            public string spring_league_full { get; set; }
            [DataMember]
            public string address { get; set; }
            [DataMember]
            public string name_display_brief { get; set; }
            [DataMember]
            public string file_code { get; set; }
            [DataMember]
            public string division_id { get; set; }
            [DataMember]
            public string spring_league_id { get; set; }
            [DataMember]
            public string venue_short { get; set; }
        }

        [DataContract]
        public class QueryResults2
        {
            [DataMember]
            public string created { get; set; }
            [DataMember]
            public string totalSize { get; set; }
            [DataMember]
            public List<Row2> row { get; set; }
        }

        [DataContract]
        public class TeamAll
        {
            [DataMember]
            public QueryResults2 queryResults { get; set; }
        }

        [DataContract]
        public class SearchAutocomp
        {
            [DataMember]
            public string copyRight { get; set; }
            [DataMember]
            public SearchAutocomplete search_autocomplete { get; set; }
            [DataMember]
            public TeamAll team_all { get; set; }
        }

        [DataContract]
        public class RootObject
        {
            [DataMember]
            public SearchAutocomp search_autocomp { get; set; }
        }
    }
}
