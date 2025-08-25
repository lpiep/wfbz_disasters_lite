# Wildfire Disasters Lite Summary Report


Sample Data:

| wildfire_id | wildfire_year | wildfire_states | wildfire_area | wildfire_complex | wildfire_complex_names | wildfire_total_fatalities | wildfire_max_civil_fatalities | wildfire_civil_fatalities | wildfire_civil_injuries | wildfire_total_injuries | wildfire_civil_evacuation | wildfire_total_evacuation | wildfire_struct_destroyed | wildfire_struct_threatened | wildfire_cost | wildfire_community_intersect | wildfire_max_pop_den | wildfire_buffered_avg_pop_den | wildfire_wui | wildfire_fema_dec | wildfire_disaster_criteria_met | wildfire_ignition_date | wildfire_containment_date | wildfire_ignition_date_max | wildfire_containment_date_max | wildfire_fema_dec_date | wildfire_poo_lat | wildfire_poo_lon | geometry_src | redbook_id | ics_id | fired_id | mtbs_id | fema_id |
|---:|---:|:---|---:|:---|:---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|:---|---:|---:|:---|:---|:---|:---|:---|:---|:---|:---|---:|---:|:---|:---|:---|:---|:---|:---|
| 1 | 2018 | CA | 146.200893 | FALSE | DONNELL | NA | NA | NA | 0 | 6 | NA | NA | 135 | NA | NA | TRUE | 0.0000000 | 0.0754363 | NA | FALSE | structures_destroyed | 2018-08-01 | 2018-10-31 | 2018-08-01 | 2018-10-31 | NA | 38.34877 | -119.92940 | MTBS | 801 | 2018_001702_DONNELL | NA | CA3834911992920180801 | NA |
| 2 | 2024 | OK | 19.105698 | FALSE | 57 | NA | NA | NA | 0 | 2 | NA | NA | 1 | 1720 | NA | TRUE | 145.3104898 | 4.6977595 | NA | FALSE | structures_destroyed | 2024-04-06 | NA | 2024-04-06 | NA | NA | 36.19250 | -99.50333 | MTBS | NA | 2024_240450_57 | NA | OK3619309950320240406 | NA |
| 3 | 2017 | FL | 2.921101 | FALSE | GARFIELD RD | NA | NA | NA | NA | NA | NA | NA | 19 | NA | NA | TRUE | 447.2384187 | 6.2317018 | intermix | FALSE | structures_destroyed | 2017-03-22 | NA | 2017-03-22 | NA | NA | 30.42750 | -82.02333 | MTBS | NA | 2017_070202_GARFIELD ROAD | NA | FL3042808202320170322 | NA |
| 4 | 2014 | AK | 6.714350 | FALSE | TYONEK | NA | NA | NA | NA | NA | NA | NA | 5 | 0 | 4.00e+06 | TRUE | 0.8108078 | 0.1005603 | NA | FALSE | structures_destroyed | 2014-05-19 | NA | 2014-05-19 | NA | NA | 61.09932 | -151.12863 | MTBS | NA | 2014_401138_TYONEK | NA | AK6109915112920140519 | NA |
| 5 | 2017 | FL | 26.204585 | FALSE | 30TH AVE | NA | NA | NA | 1 | 1 | 7000 | 7000 | 4 | 0 | 0.00e+00 | TRUE | 342.0671155 | 133.7621080 | intermix | FALSE | structures_destroyed | 2017-04-20 | NA | 2017-04-20 | NA | NA | 44.39167 | -115.51306 | MTBS | NA | 2017_170178_30TH AVE | NA | FL2618808154420170420 | NA |
| 6 | 2019 | CO | 9.151442 | FALSE | G18 | NA | NA | NA | NA | NA | 50 | 50 | 4 | NA | NA | TRUE | 49.3926869 | 2.9893104 | intermix | FALSE | structures_destroyed | 2019-10-27 | NA | 2019-10-27 | NA | NA | 37.08167 | -105.94222 | MTBS | NA | 2019_1713_G18 | NA | CO3708210594220191027 | NA |
| 7 | 2016 | CA | 11.433032 | FALSE | WILLARD | NA | NA | NA | NA | NA | NA | NA | 7 | NA | NA | TRUE | 0.0000000 | 9.3121092 | NA | FALSE | structures_destroyed | 2016-09-11 | 2016-10-12 | 2016-09-11 | 2016-10-12 | NA | 40.41444 | -120.73667 | MTBS | 568 | 2016_004695_WILLARD | NA | CA4036812080220160911 | NA |
| 8 | 2015 | AZ | 6.250412 | FALSE | KEARNY RIV | NA | NA | NA | NA | NA | NA | NA | 3 | 50 | NA | TRUE | 1586.0535982 | 1.6825622 | interface\|intermix | FALSE | structures_destroyed | 2015-06-17 | NA | 2015-06-17 | NA | NA | 33.05300 | -110.91400 | MTBS | NA | 2015_003786_KEARNY RIVER | NA | AZ3305311091420150617 | NA |
| 9 | 2017 | MT | 6.634805 | FALSE | TURTLE | NA | NA | NA | NA | NA | NA | NA | 2 | 0 | NA | TRUE | 97.2763118 | 0.5510853 | intermix | FALSE | structures_destroyed | 2017-07-16 | NA | 2017-07-16 | NA | NA | 45.57056 | -106.33139 | MTBS | NA | 2017_017-35_TURTLE | NA | MT4557110633120170716 | NA |
| 10 | 2020 | NV | 75.963891 | FALSE | NUMBERS | NA | NA | NA | 0 | 2 | 50 | 50 | 40 | NA | NA | TRUE | 477.7535304 | 3.3973013 | intermix | FALSE | structures_destroyed | 2020-07-06 | NA | 2020-07-07 | NA | NA | 38.84333 | -119.63861 | MTBS | NA | 2020_030406_NUMBERS | NA | NV3884311963920200707 | NA |
| 11 | 2020 | CA | 183.863534 | FALSE | LOYALTON | NA | NA | NA | NA | NA | 0 | 0 | 29 | NA | NA | TRUE | 438.5409660 | 27.4943497 | intermix | FALSE | structures_destroyed | 2020-08-14 | 2020-08-30 | 2020-08-14 | 2020-08-30 | NA | 39.68143 | -120.17130 | MTBS | 960 | 2020_001600_LOYALTON | NA | CA3968112017120200814 | NA |
| 12 | 2014 | AK | 779.853002 | FALSE | FUNNY RIV | NA | NA | NA | 0 | 4 | NA | NA | 4 | 0 | 1.30e+07 | TRUE | 2.0880729 | 3.5004375 | NA | FALSE | structures_destroyed | 2014-05-19 | NA | 2014-05-20 | NA | NA | 60.43945 | -150.96188 | MTBS | NA | 2014_403140_FUNNY RIVER | NA | AK6043915096220140520 | NA |
| 13 | 2017 | CA | 118.405687 | FALSE | ALAMO | 0 | 0 | 0 | NA | NA | NA | NA | 14 | 0 | 2.00e+07 | TRUE | 92.8909245 | 45.8357658 | intermix | FALSE | structures_destroyed | 2017-07-06 | 2017-07-18 | 2017-07-06 | 2017-07-18 | NA | 30.57444 | -82.32333 | MTBS | 632 | 2017_007624_ALAMO | NA | CA3502012029920170706 | NA |
| 14 | 2016 | CA | 27.726980 | FALSE | MINERAL | NA | NA | NA | NA | NA | NA | NA | 1 | NA | NA | TRUE | 45.1990412 | 4.7924940 | NA | FALSE | structures_destroyed | 2016-08-09 | NA | 2016-08-09 | NA | NA | 36.08889 | -120.52167 | MTBS | NA | 2016_011358_MINERAL | NA | CA3608912052220160809 | NA |
| 15 | 2022 | TX | 13.360132 | FALSE | 3 OAKS | NA | NA | NA | NA | NA | NA | NA | 3 | NA | NA | TRUE | 13.6034449 | 1.6627375 | NA | FALSE | structures_destroyed | 2022-03-14 | NA | 2022-03-14 | NA | NA | 31.38765 | -98.36158 | MTBS | NA | 2022_221627_3 OAKS | NA | TX3138809836220220314 | NA |
| 16 | 2022 | CA | 78.495953 | FALSE | OAK | NA | NA | NA | NA | NA | NA | NA | 127 | NA | NA | TRUE | 410.0247780 | 4.7914543 | intermix | TRUE | structures_destroyed\|fema_fmag_declaration | 2022-07-22 | 2022-08-03 | 2022-07-22 | 2022-08-03 | 2022-07-23 | 37.54871 | -119.92077 | MTBS | 1073 | 2022_016149_OAK | NA | CA3754911992120220722 | FM-5445-CA |
| 17 | 2022 | TX | 152.386230 | FALSE | CANADIAN RIV BTM | NA | NA | NA | NA | NA | NA | NA | 20 | 127 | 0.00e+00 | TRUE | 105.8241872 | 1.0139963 | intermix | FALSE | structures_destroyed | 2022-03-29 | NA | 2022-03-29 | NA | NA | 35.74500 | -100.54300 | MTBS | NA | 2022_222207_CANADIAN RIVER BOTTOM | NA | TX3574610054320220329 | NA |
| 18 | 2020 | AZ | 54.115531 | FALSE | SEARS | NA | NA | NA | NA | NA | 50 | 50 | 9 | NA | 2.00e+06 | TRUE | 5.4596871 | 14.8573558 | NA | FALSE | structures_destroyed | 2020-09-25 | NA | 2020-09-25 | NA | NA | 33.88522 | -111.81590 | MTBS | NA | 2020_002852_SEARS | NA | AZ3388511181620200925 | NA |
| 19 | 2022 | OK | 12.053531 | FALSE | KERNS RNCH | NA | NA | NA | 1 | 1 | NA | NA | 10 | 3 | NA | TRUE | 0.0000000 | 0.9514520 | NA | FALSE | structures_destroyed | 2022-09-26 | NA | 2022-09-26 | NA | NA | 34.32833 | -95.15111 | MTBS | NA | 2022_221181_KERNS RANCH FIRE | NA | OK3432809515120220926 | NA |
| 20 | 2020 | CA\|NV | 339.579780 | FALSE | W-5 COLD SPGS | NA | NA | NA | 0 | 2 | NA | NA | 1 | 0 | 1.15e+07 | TRUE | 2.5255481 | 0.0431859 | intermix | FALSE | structures_destroyed | 2020-08-18 | NA | 2020-08-18 | NA | NA | 41.02865 | -120.28133 | MTBS | NA | 2020_004727_W-5 COLD SPRINGS | NA | CA4102912028120200818 | NA |
| 21 | 2021 | OR | 93.276191 | FALSE | ELBOW CRK | NA | NA | NA | 0 | 8 | 30 | 30 | 4 | 0 | NA | TRUE | 6.7779192 | 0.0499020 | NA | FALSE | structures_destroyed | 2021-07-15 | NA | 2021-07-15 | NA | NA | 45.86778 | -117.63028 | MTBS | NA | 2021_745_ELBOW CREEK | NA | OR4586811763020210715 | NA |
| 22 | 2021 | OR | 1670.562733 | FALSE | BOOTLEG | NA | NA | NA | 0 | 20 | 236 | 236 | 247 | 0 | 1.10e+08 | TRUE | 298.8067553 | 0.2008148 | intermix | FALSE | structures_destroyed | 2021-07-06 | NA | 2021-07-06 | NA | NA | 42.61591 | -121.42090 | MTBS | NA | 2021_210321_BOOTLEG | NA | OR4261612142120210706 | NA |
| 23 | 2020 | CA | 8.256832 | FALSE | POND | NA | NA | NA | NA | NA | 411 | 411 | 13 | 200 | 8.00e+06 | TRUE | 98.9085260 | 7.4428909 | intermix | FALSE | structures_destroyed | 2020-08-01 | 2020-08-09 | 2020-08-01 | 2020-08-09 | NA | 35.41634 | -120.45571 | MTBS | 909 | 2020_009866_POND | NA | CA3541612045620200801 | NA |
| 24 | 2017 | OR | 787.395247 | FALSE | CHETCO BAR | NA | NA | NA | 0 | 5 | 5122 | 5122 | 24 | 0 | 7.20e+07 | TRUE | 137.5136069 | 3.6594131 | intermix | FALSE | structures_destroyed | 2017-07-12 | NA | 2017-07-12 | NA | NA | 42.29667 | -123.95361 | MTBS | NA | 2017_000326_CHETCO BAR | NA | OR4229712395420170712 | NA |
| 25 | 2024 | CA | 64.079217 | FALSE | POST | NA | NA | NA | 1 | 1 | 1200 | 1200 | 2 | 10 | 2.00e+07 | TRUE | 77.2113425 | 2.1814613 | intermix | FALSE | structures_destroyed | 2024-06-15 | NA | 2024-06-15 | NA | NA | 34.80285 | -118.87760 | MTBS | NA | 2024_205253_POST | NA | CA3480311887820240615 | NA |

*Last run: 2025-08-25*

Output File Details:

wfbz.geojson

- File Size: 359M
- File Checksum (md5): 9df78de0d1f9a27f4dc7daebd08b9b6c

| Cleaned Data Set   | N Obs. |
|:-------------------|-------:|
| FEMA               |   1731 |
| ICS209 Minimal     |  35961 |
| Redbooks           |   1375 |
| Harmonized Events  |   7556 |
| FIRED              | 219383 |
| MTBS               |  14321 |
| NIFC               |  60803 |
| Harmonized Spatial |   8001 |

Burn Perimeter Join Types

| geometry_method              | N Events |
|:-----------------------------|---------:|
| FIRED by Place/Time          |     1349 |
| ICS by Point of Origin, Size |     4304 |
| MTBS by ID                   |      462 |
| MTBS by Name/Place/Time      |     1201 |
| NIFC by ID                   |       86 |
| NIFC by Name/Place/Time      |      599 |

## Documentation

See detailed documentation for the input and output data sets here:
<https://lpiep.github.io/wildfire_disasters_lite/>
