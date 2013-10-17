using System;
using System.Collections.Generic;
using System.Runtime.Serialization;

namespace mlbPowerShellModule
{
    class mlbBio_Pitching_Summary
    {
        [DataContract]
        public class Row
        {
            [DataMember]
            public string hr { get; set; }
            [DataMember]
            public string gidp { get; set; }
            [DataMember]
            public string irs { get; set; }
            [DataMember]
            public string np { get; set; }
            [DataMember]
            public string era { get; set; }
            [DataMember]
            public string sho { get; set; }
            [DataMember]
            public string bk { get; set; }
            [DataMember]
            public string league_display_full { get; set; }
            [DataMember]
            public string team_display_abbrev { get; set; }
            [DataMember]
            public string sv { get; set; }
            [DataMember]
            public string avg { get; set; }
            [DataMember]
            public string whip { get; set; }
            [DataMember]
            public string bb { get; set; }
            [DataMember]
            public string team_display_full { get; set; }
            [DataMember]
            public string ir { get; set; }
            [DataMember]
            public string g { get; set; }
            [DataMember]
            public string so { get; set; }
            [DataMember]
            public string tbf { get; set; }
            [DataMember]
            public string league_display_abbrev { get; set; }
            [DataMember]
            public string league_display_short { get; set; }
            [DataMember]
            public string team_display_short { get; set; }
            [DataMember]
            public string wp { get; set; }
            [DataMember]
            public string league_id { get; set; }
            [DataMember]
            public string l { get; set; }
            [DataMember]
            public string team_seq { get; set; }
            [DataMember]
            public string hb { get; set; }
            [DataMember]
            public string svo { get; set; }
            [DataMember]
            public string h { get; set; }
            [DataMember]
            public string ip { get; set; }
            [DataMember]
            public string w { get; set; }
            [DataMember]
            public string s { get; set; }
            [DataMember]
            public string ao { get; set; }
            [DataMember]
            public string season { get; set; }
            [DataMember]
            public string r { get; set; }
            [DataMember]
            public string go_ao { get; set; }
            [DataMember]
            public string player_id { get; set; }
            [DataMember]
            public string cg { get; set; }
            [DataMember]
            public string ab { get; set; }
            [DataMember]
            public string ibb { get; set; }
            [DataMember]
            public string gs { get; set; }
            [DataMember]
            public string team_id { get; set; }
            [DataMember]
            public string er { get; set; }
            [DataMember]
            public string go { get; set; }
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
        public class MlbIndividualPitchingSeason
        {
            [DataMember]
            public QueryResults queryResults { get; set; }
        }

        [DataContract]
        public class Row2
        {
            [DataMember]
            public string hr { get; set; }
            [DataMember]
            public string gidp { get; set; }
            [DataMember]
            public string irs { get; set; }
            [DataMember]
            public string np { get; set; }
            [DataMember]
            public string era { get; set; }
            [DataMember]
            public string sho { get; set; }
            [DataMember]
            public string bk { get; set; }
            [DataMember]
            public string sv { get; set; }
            [DataMember]
            public string avg { get; set; }
            [DataMember]
            public string bb { get; set; }
            [DataMember]
            public string whip { get; set; }
            [DataMember]
            public string ir { get; set; }
            [DataMember]
            public string g { get; set; }
            [DataMember]
            public string so { get; set; }
            [DataMember]
            public string tbf { get; set; }
            [DataMember]
            public string wp { get; set; }
            [DataMember]
            public string l { get; set; }
            [DataMember]
            public string svo { get; set; }
            [DataMember]
            public string hb { get; set; }
            [DataMember]
            public string h { get; set; }
            [DataMember]
            public string ip { get; set; }
            [DataMember]
            public string w { get; set; }
            [DataMember]
            public string s { get; set; }
            [DataMember]
            public string ao { get; set; }
            [DataMember]
            public string r { get; set; }
            [DataMember]
            public string go_ao { get; set; }
            [DataMember]
            public string cg { get; set; }
            [DataMember]
            public string player_id { get; set; }
            [DataMember]
            public string ab { get; set; }
            [DataMember]
            public string gs { get; set; }
            [DataMember]
            public string ibb { get; set; }
            [DataMember]
            public string er { get; set; }
            [DataMember]
            public string go { get; set; }
        }

        [DataContract]
        public class QueryResults2
        {
            [DataMember]
            public string created { get; set; }
            [DataMember]
            public string totalSize { get; set; }
            [DataMember]
            public Row2 row { get; set; }
        }

        [DataContract]
        public class MlbIndividualPitchingCareer
        {
            [DataMember]
            public QueryResults2 queryResults { get; set; }
        }

        [DataContract]
        public class Row3
        {
            [DataMember]
            public string hr { get; set; }
            [DataMember]
            public string gidp { get; set; }
            [DataMember]
            public string irs { get; set; }
            [DataMember]
            public string sac { get; set; }
            [DataMember]
            public string np { get; set; }
            [DataMember]
            public string team_count { get; set; }
            [DataMember]
            public string wpct { get; set; }
            [DataMember]
            public string name_display_first_last { get; set; }
            [DataMember]
            public string era { get; set; }
            [DataMember]
            public string gf { get; set; }
            [DataMember]
            public string sho { get; set; }
            [DataMember]
            public string bk { get; set; }
            [DataMember]
            public string sv { get; set; }
            [DataMember]
            public string name_display_last_init { get; set; }
            [DataMember]
            public string avg { get; set; }
            [DataMember]
            public string whip { get; set; }
            [DataMember]
            public string bb { get; set; }
            [DataMember]
            public string hld { get; set; }
            [DataMember]
            public string ir { get; set; }
            [DataMember]
            public string g { get; set; }
            [DataMember]
            public string so { get; set; }
            [DataMember]
            public string tbf { get; set; }
            [DataMember]
            public string wp { get; set; }
            [DataMember]
            public string sf { get; set; }
            [DataMember]
            public string l { get; set; }
            [DataMember]
            public string svo { get; set; }
            [DataMember]
            public string hb { get; set; }
            [DataMember]
            public string name_display_last_first { get; set; }
            [DataMember]
            public string h { get; set; }
            [DataMember]
            public string ip { get; set; }
            [DataMember]
            public string obp { get; set; }
            [DataMember]
            public string w { get; set; }
            [DataMember]
            public string s { get; set; }
            [DataMember]
            public string ao { get; set; }
            [DataMember]
            public string season { get; set; }
            [DataMember]
            public string r { get; set; }
            [DataMember]
            public string go_ao { get; set; }
            [DataMember]
            public string player_id { get; set; }
            [DataMember]
            public string cg { get; set; }
            [DataMember]
            public string ab { get; set; }
            [DataMember]
            public string gs { get; set; }
            [DataMember]
            public string ibb { get; set; }
            [DataMember]
            public string name_last { get; set; }
            [DataMember]
            public string active_sw { get; set; }
            [DataMember]
            public string er { get; set; }
            [DataMember]
            public string go { get; set; }
        }

        [DataContract]
        public class QueryResults3
        {
            [DataMember]
            public string created { get; set; }
            [DataMember]
            public string totalSize { get; set; }
            [DataMember]
            public List<Row3> row { get; set; }
        }

        [DataContract]
        public class MlbIndividualPitchingSeasonTotal
        {
            [DataMember]
            public QueryResults3 queryResults { get; set; }
        }

        [DataContract]
        public class MlbBioPitchingSummary
        {
            [DataMember]
            public string copyRight { get; set; }
            [DataMember]
            public MlbIndividualPitchingSeason mlb_individual_pitching_season { get; set; }
            [DataMember]
            public MlbIndividualPitchingCareer mlb_individual_pitching_career { get; set; }
            [DataMember]
            public MlbIndividualPitchingSeasonTotal mlb_individual_pitching_season_total { get; set; }
        }

        [DataContract]
        public class RootObject
        {
            [DataMember]
            public MlbBioPitchingSummary mlb_bio_pitching_summary { get; set; }
        }
    }
}