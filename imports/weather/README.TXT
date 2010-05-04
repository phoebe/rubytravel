NAME OF THE NUMERIC DATA PACKAGE

United States Historical Climatology Network (HCN) Serial Temperature and
Precipitation Data


NOTE:  This data package is currently updated through 2000.  However, please note
       that the 2000 Census figures have not been included in the urbanization 
       adjustment routine.  Year 2000 city populations reflect the year 1990 values.
       At such time as the recently released figures can be incorporated, some minor
       changes in the urban adjusted temperatures during the most recent years may
       occur.

CONTRIBUTORS

Thomas R. Karl, David R. Easterling,
Pamela Y. Hughes, Elaine H. Mason,
and Jay Lawrimore
National Oceanic and Atmospheric Administration
National Climatic Data Center
151 Patton Avenue, Room 120
Asheville, North Carolina 28801-5001


SCOPE

The purpose of this file is to provide a description of and the format for the
following USHCN data files:

     hcn_doe_max_data.Z      Areal Edited, Time of Observation, and Filnet Adjusted
                             Maximum Monthly Temperature
     hcn_calc_mean_data.Z    Time of Observation and Filnet Adjusted Mean Monthly
                             Temperature (Calculated from hcn_doe_max_data.Z and hcn_doe_min_data.Z)
     hcn_doe_mean_data.Z     Areal Edited, Time of Observation, and Filnet Adjusted
                             Mean Monthly Temperature
     hcn_doe_min_data.Z      Areal Edited, Time of Observation, and Filnet Adjusted
                             Minimum Monthly Temperature
     hcn_doe_pcp_data.Z      Areal Edited, Time of Observation, and Filnet Adjusted
                             Monthly Precipitation
     station.history.Z       Station History
     station.inventory.Z     Station Inventory
     station.landuse.Z       Station Area Land Use and Land Cover
     urban_max_fahr.Z        Urban Heat Adjusted Maximum Monthly Temperature
     urban_calc_mean_fahr.Z  Urban Heat Adjusted Mean Monthly Temperature
                             (Calculated from urban.max.Z and urban.min.Z)
     urban_mean_fahr.Z       Urban Heat Adjusted Mean Monthly Temperature
     urban_min_fahr.Z        Urban Heat Adjusted Minimum Monthly Temperature

The Areal Edited data is the original (or raw) data that have been screened to flag
monthly data that are suspect/outliers (over 3 standard deviations from period of
record mean of the element).

The Time of Observation data is the Areal Edited data that have been adjusted to
remove the time of observation bias so that the data will be consistent with a
midnight-to-midnight observation schedule.

The Filnet data is the Time of Observation data that have been adjusted for the
Maximum/Minimum Temperature System (MMTS) bias, station moves/changes bias, and
contains estimated values for missing/outlier data.

The Urban Adjusted data is the Filnet data that have been adjusted for bias due to
urbanization effects.

For additional information, see the USHCN homepage at:

URL:  http://www.ncdc.noaa.gov/ol/climate/research/ushcn/ushcn.html

OBTAINING FILES

These files have been compressed using the UNIX compression utility compress.
If this utility is not available, leave off the .Z extension and the files
will uncompress on the fly through ftp.

TEMPERATURE DATA

Areal Edited, Time of Observation, and Filnet Adjusted Data

Record Size:  144 characters/record

The USHCN data base contains monthly maximum, minimum, and mean temperature data
(in hundredths of degrees fahrenheit) for the 1221 USHCN stations.  There is also
a time of observation and filnet mean data set (mean.calc.data.Z) that is the mean
monthly temperature calculated from the time of observation and filnet adjusted
maximum temperature (hcn_doe_max_data.Z) and the time of observation and filnet adjusted
minimum (hcn_doe_min_data.Z) data sets.  The format of the files is as follows:

Position     Data Field

 01 - 06     STATION ID
   01-02       State Code
   03-06       Coop Station Number
 08 - 11     YEAR OF DATA
 13          DATA ELEMENT
             (1 = maximum temperature;
              2 = minimum temperature;
              3 = mean temperature)
 14          DATA TYPE
             (" " = Areal Edited Value;
              "+" = Time of Observation Value;
              "A" = Filnet Value;
              "C" = Confidence Factor Value)

 15 - 144    MONTHLY DATA VALUES AND FLAGS
             [13 data values (12 months and 1 annual) with flags] as follows:

   15 - 20     January Data Value
   21 - 24     Flags for January Data Value

   25 - 30     February Data Value
   31 - 34     Flags for February Data Value
............................................

  125 - 130    December Data Value
  131 - 134    Flags for December Data Value

  135 - 140    Annual Data Value
  141 - 144    Flags for Annual Data Value

Each monthly flag has 4 positions:

Areal Edited, Time of Observation, and Filnet Data

  (1) the first position is the code for the number of daily values not available in
      computing the monthly value ("A" = 1, "B" = 2, "C" = 3,..."H" = 8); or the
      code "I" for interpolated or "." for estimated.
      [NOTE:  for values from digital sources (e.g., second flag position = "0" or
      "1"), the days missing code will be an "I" to indicate between 1 to 9 days were
      missing from the monthly value; whereas, for non-digital sources, a days
      missing code of "I" means 9 days missing.]

Confidence Record

  (1) the first position is blank;

Areal Edited, Time of Observation, and Filnet Data

  (2) the second position is the code for the data source:

      0 =  NCDC Tape Deck 3200, Summary of the Day Element Digital File
      1 =  NCDC Tape Deck 3220, Summary of the Month Element Digital File
      2 =  Means Book - Smithsonian Institute, C.A. Schott (1876, 1881 thru 1931)
      3 =  Manuscript - Original Records, National Climatic Data Center 
      4 =  Climatological Data (CD), monthly NCDC publication 
      5 =  Climate Record Book, as described in History of Climatological Record
           Books, U.S. Department of Commerce, Weather Bureau, USGPO (1960)
      6 =  Bulletin W - Summary of the Climatological Data for the United States (by
           section), F.H. Bigelow, U.S. Weather Bureau (1912); and, Bulletin W -
           Summary of the Climatological Data for the United States, 2nd Ed.
      7 =  Local Climatological Data (LCD), monthly NCDC publication
      8 =  State Climatologists, various sources
      B =  Professor Raymond Bradley - Refer to Climatic Fluctuations of the Western
           United States During the Period of Instrumental Records, Bradley, et. al.,
           Contribution No. 42, Dept. of Geography and Geology, University of
           Massachusetts (1982)
      D =  Dr. Henry Diaz, a compilation of data from Bulletin W, LCD, and NCDC Tape
           Deck 3220 (1983)
      G =  Professor John Griffiths - primarily from Climatological Data
  Blank = computed value from two of three temperature elements

Confidence Record

  (2) the second position is the code representing the number of the move, counting
      back from 1994:
      0 = no move;
      1 = first move;
      2 = second move;
      ................

      9 = ninth move;
      A = tenth move;
      B = eleventh move;
      ..................

Areal Edited Data

  (3) the third position is blank;

Time of Observation Data

  (3) the third position is the code for the quality of the available observation
      times for a given station:

      F = information concerning the observation times for the station during that
          year was suspect or "flaky";
      G = information concerning the observation times for the station during that
          year was "good" and the information was judged to be accurate;
  Blank = information concerning the observation times was not available for the
          station during that year and the data are represented as missing.

Filnet Data

  (3) the third position is the code for the temperature indicator for the Time of
      Observation bias correction:

      O = corrected;
  Blank = no observation time correction (treated as a station move).

Confidence Record

  (3) the third position is the code for representing the significance level at which
      the initial adjustment was made:

      1 = sigma of 1.0 and confidence interval of 16% to 84%;
      2 = sigma of 2.0 and confidence interval of 5% to 95%;
      3 = sigma of 2.57 and confidence interval of 1% to 99%;
      5 = sigma of 3.75 and confidence interval of 0.01% to 99.99%;
      C = closed station value; the station has missing values at the end of the 
          period of record for at least one calendar year;
      U = the algorithm was unable to adjust the entire series due to the station
          density of the network, but an estimate for the missing data is given by
          using neighboring stations;
      X = the algorithm was unable to adjust the data.

Areal Edited and Time of Observation Data

  (4) and the fourth position is the code that indicates whether the monthly value is
      an "outlier";
      S = between 3 to 5 standard deviations.
      X = greater than 5 standard deviations from period of record mean of the
          element;

Filnet Data

  (4) and the fourth position is the code that indicates outliers, closed station
      values, and missing data estimates:

      C = station has closed; the station has missing values at the end of the
          period of record for at least one calendar year;
      E = original data available are available, but data were estimated using
          nearest neighbors because:
          (1) the data were between 3.5 and 5.0 standard deviations from their mean
              offset and 1 or more days in the month were missing, or
          (2) adjustments of original data were inappropriate (< 5 years between
              potential inhomogeneities) so nearest neighbors were used to estimate
              the data consistent with its 1994 location or most recent location
              with at least 5 years without potential station discontinuities.
      M = no original data are available, but an estimate is provided that is
          consistent with the data adjusted by using nearest neighboring stations;
          or, the data were in excess of 5.0 standard deviations from their mean
          offset with respect to the station's nearest neighbors;
      S = between 3 to 5 standard deviations.

Confidence Record

  (4) the fourth position is blank;

Each annual flag has 4 positions:

Areal Edited Data

  (1) the first position is the code for the days missing:
      I = indicates "incomplete", if any monthly values had days missing.

Time of Observation, Filnet Data, and Confidence Record

  (1) the first position is blank;

Areal Edited Data

  (2) the second position is the code for the data source (same as monthly flag);

Time of Observation, Filnet Data, and Confidence Record

  (2) the second position is blank;

Areal Edited Data, Time of Observation, Filnet Data, and Confidence Record

  (3) the third position is blank;

Areal Edited Data, Time of Observation, Filnet Data, and Confidence Record

  (4) the fourth position is blank.

Urban Heat Adjusted Data

Record Size:  130 characters/record

The USHCN data base contains urban adjusted monthly maximum (urban_max_fahr.Z),
minimum (urban_min_fahr.Z), and mean (urban_mean_fahr.Z) temperature data (in hundredths of
degrees fahrenheit) for the 1221 USHCN stations.  There is also an urban mean data
set (urban_calc_mean_fahr.Z) that is the mean monthly temperature calculated from the
urban adjusted maximum temperature (urban_max_fahr.Z) and the urban adjusted minimum
(urban_min_fahr.Z) data sets.  The format of the files is as follows:

Position      Data Field

 01 -  06     STATION ID
   01 -  02     State ID
   03 -  06     Coop ID
 08 -  11     YEAR OF DATA
 13 -  18     JANUARY MONTHLY VALUE
 20 -  25     FEBRUARY MONTHLY VALUE
....................................

 90 -  95     DECEMBER MONTHLY VALUE
 97 - 102     WINTER SEASONAL VALUE (December of Prior Year,
              January and February of Current Year)
104 - 109     SPRING SEASONAL VALUE (March, April, and May of Current Year)
111 - 116     SUMMER SEASONAL VALUE (June, July, and August of Current Year)
118 - 123     FALL SEASONAL VALUE (September, October, and November of Current Year)
125 - 130     ANNUAL VALUE (January - December of Current Year)


PRECIPITATION DATA

Record Size:  144 characters/record

The USHCN data base contains total monthly precipitation (hcn_doe_pcp_data.Z) data (in
hundredths of inches) for the 1221 USHCN stations.  The data is in the same format
as the temperature data, with the following flag code differences:

Monthly Flag Codes

Areal Edited and Time of Observation Data

  (3) the third position is the code for indicating trace amounts of precipitation:
      T = trace amount of precipitation; data value = 0.00.

Filnet Adjusted Data

  (3) the third position is blank;

Confidence Record

  (3) the third position is for representing how the data was adjusted:
      A = annual values were used to adjust the data;
      S = seasonal values were used to adjust the data;
      U = the algorithm was unable to adjust the entire series due to the station
          density of the network, but an estimate for the missing data is given by
          using neighboring stations;
      X = the algorithm was unable to adjust the data.

Annual Flag Codes

Areal Edited and Time of Observation Data

  (3) the third position is the code for indicating trace amounts of precipitation:
      T = trace amount of precipitation during at least one month of the year; all
          monthly and annual data values = 0.00.

Filnet Adjusted Data

  (3) the third position is blank;

STATION HISTORY DATA

Record Size:  236 characters/record

The USHCN station history file (station.history.Z) contains station histories for the
1221 USHCN stations.  The format of the file is as follows:

HEADER RECORD:

 RECORD   # OF
POSITION  CHAR CONFIGURATION            DEFINITIONS & REMARKS

01-06       6  NUMERIC                  STATE & STATION NUMBER
                                        [First two positions indicate the state
                                        code (see Appendix A); last four indicate
                                        the NCDC Cooperative substation ID number]

08-09       2  ALPHA                    STATE ABBREVIATION
                                        (see Appendix A)
10          1  ALPHA                    " " (blank) indicates station currently open
                                        "*" Indicates station currently closed or Inactive
11-12       2  NUMERIC                  DIVISION NUMBER

14-43      30  ALPHA-NUMERIC            MOST CURRENT STATION NAME
                                        [condensed form of the station name and
                                        qualifier (see Positions 84-122 of Data
                                        Record)]

45-60      16  ALPHA                    COUNTY NAME
                                        [if a prior county location was known, the
                                        earlier name and date of change is given in
                                        the X-REFERENCE (Positions 62-86 of the
                                        Header Record)]

62-86      25  ALPHA-NUMERIC            X-REFERENCE
                                        [Station number for another location to/from
                                        which the current station has moved or gives
                                        change in county name (e.g. "To 2337";
                                        "From 2335"; "Cty = Buncombe, 9/1897") or
                                        Blank, if not applicable]

87-236    150                           BLANK


DATA RECORD:

01-06       6  NUMERIC                  STATE & STATION NUMBER
                                        [First two positions indicate the state
                                        code (see Appendix A); last four indicate
                                        the NCDC Cooperative substation ID number]

08-17      10  NUMERIC (mm dd yyyy)     BEGIN DATE
08-09       2                           comprised of:  Month (mm = 01-12, 99)
11-12       2                                          Day   (dd = 01-31, 99)
14-17       4                                          Year  (yyyy = 1738-1994, 9999)

NOTE:  Values are separated by blanks.  "99" or "9999" are used for unknown
       component(s) of the date.

19-28      10  NUMERIC (mm dd yyyy)     END DATE
19-20       2                           comprised of:  Month (mm = 01-12, 99)
22-23       2                                          Day   (dd = 01-31, 99)
25-28       4                                          Year  (yyyy = 1738-1994, 9999)

NOTE:  Values are separated by blanks.  "99" or "9999" are used for unknown
       components of the date.  An end date of "99 99 9999" indicates the station
       is still presently active. 

30-44      15  NUMERIC (0,1)            SUSPECT FIELDS
                                        Positions equal to "1" indicate the data
                                        field(s) flagged by pre-key editor as
                                        suspect

               POSITION       DATA FIELD

30                1           Latitude
31                2           Longitude
32                3           Distance from Previous Location
33                4           Elevation
34                5           Distance from Post Office Location
35                6           Station Name
36                7           Qualifier
37                8           Instruments
38                9           Observation Times
39               10           Instrument Heights
40               11           Publications
41               12           Begin Date
42               13           End Date
43               14           Observer
44               15           Other Observers

46-51     6    NUMERIC                  LATITUDE (DEGREES/MINUTES)
46-48     3    S00-S90                  Degrees, where "S" denotes sign:
                                        S= " " indicates North;
                                        S= "-" indicates South
50-51     2     00-59                   Minutes

53-59     7    NUMERIC                  LONGITUDE (DEGREES/MINUTES)
53-56     4    S000-S180                Degrees, where "S" denotes sign:
                                        S= " " indicates West;
                                        S= "-" indicates East
58-59     2     00-59                   Minutes

NOTE:  In the context of the USHCN, the location of temperature instrument defines
       official station location.

61-63     3    NUMERIC                  DISTANCE FROM PREVIOUS
                                        LOCATION (DPL)
                                        units in tenths of miles unless Position
                                        64 = "B"; then the units are in "Blocks";
                                        "999" = unknown distance

(NOTE:  Distances > 80 miles are flagged as suspect [refer to Position 32 of Data
        Record]; "9xx" codes indicate distance value is exclusively for the
        temperature instrument; "8xx" codes indicate distance value exclusively for
        precipitation.)

64        1    ALPHA (" ",B)            UNITS INDICATOR FOR DPL
                                        "B" for Blocks; " " for tenths of miles

65-67     3    ALPHA-NUMERIC            DIRECTION FOR DPL
                                        codes for the 16-points are used:
                                        N, NNE, NE, ENE, E, ESE, SE, SSE, S, SSW,
                                        SW, WSW, W, WNW, NW, NNW;
                                        "999" indicates direction unknown;
                                        "000" indicates no change in direction
                                        except for some instances of precipitation
                                        only moves [see "8xx 000" example below]

               Examples of DPL Codes:

               CODE      DEFINITION

               999 999   Distance & direction unknown (the DPL is always missing in
                         the first record for a new station)
               015 NW    Station moved 1.5 miles NW of previous location
               000 000   No change in either station or instrument location
               902 ESE   Temperature instrument moved 0.2 miles ESE and
                         precipitation instrument did not move; or the
                         precipitation instrument move was not equal to that of the
                         temperature instrument
               800 000   Precipitation instrument moved, but temperature instrument
                         did not move (in more recent history entries the direction
                         may be given rather than encoded as zeroes)
               000 ESE   Station moved < 0.1 mi ESE of previous location
               999 NW    Moved an unknown distance to a location NW of the previous
                         location

69-73     5    NUMERIC                  ELEVATION
                                        (of ground at temperature site) given in
                                        whole feet above or below mean sea level

75-78     4    NUMERIC                  DISTANCE FROM POST OFFICE (DPO)
                                        units are in tenths of miles unless Position
                                        79 = "B"; then units are given in "Blocks";
                                        "9999" = unknown distance

79        1    ALPHA (" ",B)            UNITS INDICATOR FOR DPO
                                        "B" for Blocks; " " for tenths of miles

80-82     3    ALPHA-NUMERIC            DIRECTION FOR DPO
                                        codes for the 16-points are used:
                                        N, NNE, NE, ENE, E, ESE, SE, SSE, S, SSW,
                                        SW, WSW, W, WNW, NW, NNW;
                                        "999" indicates direction unknown;
                                        "000" indicates a location at the PO

               Examples of DPO Codes:

               CODE      DEFINITION

               9999 999  Distance & direction unknown
               0015 NW   Station 1.5 Miles NW of PO
               0000 NW   Station < 0.1 Mile NW of PO
               0000 999  Station < 0.1 Mile from PO; direction unknown
               9999 NW   Station located an unknown distance to the NW of the PO
               0000 000  Station located at PO

84-111    28   ALPHA                    STATION NAME
                                        (may include previous state/station number
                                        contained in parentheses, e.g., 4 to 6
                                        characters)

113-122   10   ALPHA-NUMERIC            QUALIFIER
                                        description added to primary station name;
                                        e.g., ASHEVILLE 2N

124-159   36   NUMERIC (0,1)            INSTRUMENT INDICATOR
                                        Positions set equal to "1" indicate which
                                        instruments are on-site; otherwise "0"

     Position  Instrument                                 Mnemonic

124         1  Additional Instruments (wind, pressure,      AI
               psychrometer, etc.) (see position 158)
125         2  Cotton Region Shelter (official)             CRS
126         3  Dry-Bulb Thermometer                         DT
127         4  Class 'A' Evaporation Station                EVA
128         5  Fischer-Porter Gage                          FP
129         6  Hygrothermograph                             HYTHG
130         7  Minimum Thermometer                          MN
131         8  Maximum Thermometer                          MX
132         9  Non-Recording River Gage                     NRIG
133        10  Non-Standard Rain Gage                       NSRG
134        11  Non-Standard Shelter                         NSS
135        12  Recording River Gage                         RRIG
136        13  Recording Rain Gage                          RRNG
137        14  Snow Density Gage                            SDE
138        15  Storage Gage                                 SG
139        16  Standard Rain Gage                           SRG
140        17  Standard Shelter (official)                  SS
141        18  Thermograph                                  TG
142        19  Digital Thermometer                          DGT
143        20  Tipping Bucket Gage                          TB
144        21  Other than Class 'A' Evaporation station     EVO
145        22  Maximum/Minimum Temperature System           MMTS
146        23  Telemetry System                             TELSY
147        24  Hygrothermometer (type unknown)              HYGRO
148        25  Hygrothermometer - H06x series               HY6
149        26  Hygrothermometer - H08x series               HY8
150        27  Shielded Fischer-Porter Gage                 SFP
151        28  Shielded Recording Rain Gage                 SRRNG
152        29  Shielded Storage Gage                        SSG
153        30  Shielded Standard Rain Gage                  SSRG
154        31  Shielded Tipping Bucket                      STB
155        32  Automated Meteorological Observing System    AMOS
156        33  Automated Observing Station                  AUTOB
157        34  Psychrometer (official, AK only)             PSY
158-159 35-36  Not assigned at present time

(NOTE: Mnemonics are not included in the metadata; however, these abbreviations are
       commonly used in USHCN printed products.)

161-164   4    ALPHA-NUMERIC            OBSERVATION TIMES (OT)
161-162   2                             Precipitation OT
163-164   2                             Temperature OT

               The observation times are encoded to the nearest whole hour where
               known; in some instances, the observation may have been taken at a
               variable hour (e.g., sunrise or sunset) or according to a rotating
               seasonal schedule based upon agricultural needs.

               Examples:
               01-24,99  Nearest Whole Hour; "99" for unknown
               SR        Sunrise
               SS        Sunset
               RS        Rotating Schedule (in general, evening observations were
                         taken during the winter months [Oct/Nov thru Apr/May] and
                         morning observations taken during summer months or
                         "crop season".)

                         In "RS" instances, often two observations were taken during
                         the summer; usually between 5-7 AM and again between 5-7
                         PM.  In such 2 obs/day instances, it's unclear whether both
                         elements are read twice, but recorded for a single hour; or
                         (a more likely practice), the precipitation is recorded in
                         the morning and temperature in the evening.

               At some sites (usually airports) a uniform schedule was in use, but
               the particular hour at which a particular element was observed was
               not specified.  In these instances, the number of hours per day for
               which observations were taken is given.  (NOTE:  the number of hours
               must not be confused with synoptic observing schedules such as
               3-hourly, 6-hourly, etc. ones at which observations are taken at
               intervals of every 3 hours, 6 hours, etc.)
 
               xxHR      where xx indicates the number of hours for which the site
                         took observations;

               An early practice regarding the observation times of temperature
               involved taking three readings (morning, afternoon, and evening or
               "tri-daily").  These readings were usually made at 7 AM, 2 PM, and
               9 PM.  A weighted average was computed in which the 9 PM observation
               was summed twice and the total sum divided by 4 [e.g.,
               (7 AM + 2 PM + 9 PM + 9 PM )/ 4  ].  Note, in these instances, no
               precipitation observation time has been encoded.

               TRID      indicates "tri-daily" temperature average

               The early editions of the Weather Bureau's reporting forms allowed
               space only for a single observing time to be entered.  Later on,
               revised forms specifically identified whether the observation time
               was for temperature or precipitation.  In the instances where the
               forms were ambiguous with regard to the observing times of these
               elements, the OT is encoded as follows:

               9xx9      where xx indicates the hour as listed for the observations;
                         whether it's accurate for both temperature and precipitation
                         is unknown

               Examples of OT codes:

               SRSS      Precipitation reading made at sunrise; temperature read at
                         sunset

               SS99      Precipitation read at sunset; temperature read at an
                         unknown hour or there is no temperature data available for
                         that period of record

               0718      Precipitation read at 0700 (i.e., 7 AM); temperature read
                         at 1800 (i.e., 6 PM)

               9079      Ambiguous form:  0700 was the only listed hour of
                         observation; unknown whether for both temperature and
                         precipitation

               06HR      Station observed 6 hours/day; whether the average of these
                         6 observations is what was recorded or only a single hour
                         was used is unclear

               RSSS      Precipitation readings made on a rotating schedule;
                         temperatures read at sunset

               TRID      "Tri-daily" readings of temperature; no OT encoded for
                         precipitation

               9918      Precipitation readings made at an unknown hour or there is
                         no precipitation data available for that period of record;
                         temperature read at 1800

166-167        2    ALPHA-NUMERIC       HEIGHT OF PRECIPITATION INSTRUMENT ABOVE
                    (00-99, RF)         GROUND
                                        given in whole feet;
                                        "99" indicates missing;
                                        "98" indicates heights of 98 feet or greater;
                                        "RF" indicates a roof-top exposure

168-169        2    ALPHA-NUMERIC       HEIGHT OF TEMPERATURE INSTRUMENT ABOVE
                    (00-99, RF)         GROUND
                                        given in whole feet;
                                        "99" indicates missing;
                                        "98" indicates heights of 98 feet or greater;
                                        "RF" indicates a roof-top exposure

               Examples of Instrument Height Codes:

               0305      For a standard rain gage, the opening at top of the gage
                         is mounted at 3 feet above the ground; and the thermometer
                         (inside the shelter) is located at 5 feet above the ground

               RF99      Precipitation gage is located on roof; thermometer height
                         is unknown or there is no temperature data available for
                         that period of record

               9805      Precipitation gage is at least 98 feet above the ground;
                         thermometer is mounted 5 feet above the ground

171-186        16   NUMERIC (0,1)       PUBLICATION INDICATOR
                                        Positions equal to "1" indicate where
                                        station's data are published (see below)
                                        except when a "1" occurs in position 178 to
                                        indicate the data are unpublished; else is
                                        "0"

               Position  Publication                                    Mnemonic

171                  1   Bulletin W                                       BW
172                  2   Combined Bulletin                                CB
173                  3   Climatological Data                              CD
174                  4   Daily River Stages                               DRS
175                  5   Hydrologic Bulletin                              HB
176                  6   Hourly Precipitation Data                        HPD
177                  7   Snow Bulletin                                    SB
178                  8   NOT PUBLISHED                                    NP
179                  9   Report to the Chief of US Weather Bureau         CWB
180                 10   Monthly Weather Review                           MWR
181                 11   State Publication                                SP
182                 12   Local Climatological Data                        LCD
183                 13   Bulletin Q (1870-1903)                           BQ
184                 14   Storage Gage Precipitation Data (Western US)     SGPD
185                 15   Weekly Weather Review                            WWR
186                 16   US Meteorological Yearbook                       MYB

(NOTE: Mnemonics are not included in the metadata; however, these abbreviations are
       commonly used in the USHCN printed products.)

188-233   46   ALPHA                    OBSERVERS NAME(S)

235-236    2   NUMERIC                  NUMBER OF OBSERVERS
                                        this number gives either the number of
                                        observers used as observers by the listed
                                        agency or "corporate" observer (that is, "US
                                        Forest Service" may have actually been 5
                                        different observers during the particular
                                        period of record) or the number of additional
                                        known observers where to individually list
                                        multiple names would exceed the allotted
                                        space


                           APPENDIX A


     DISTANCE CONVERSIONS (1 CITY BLOCK = 0.1 MILE)

        FEET   = MILE        FEET   = MILE   FRACTION = DECIMAL
         < 264   0.0      2376-2903   0.5      1/8        0.1
       265-791   0.1      2904-3431   0.6      1/4        0.3
      792-1319   0.2      3432-3959   0.7      3/8        0.4
     1320-1847   0.3      3960-4487   0.8      1/2        0.5
     1848-2375   0.4      4488-5015   0.9      3/4        0.8


                       STATE CODE/ABBREVIATION

   01 AL Alabama       17 ME Maine           33 OH Ohio
   02 AZ Arizona       18 MD Maryland        34 OK Oklahoma
   03 AR Arkansas      19 MA Massachusetts   35 OR Oregon
   04 CA California    20 MI Michigan        36 PA Pennsylvania
   05 CO Colorado      21 MN Minnesota       37 RI Rhode Island
   06 CT Connecticut   22 MS Mississippi     38 SC South Carolina
   07 DE Delaware      23 MO Missouri        39 SD South Dakota
   08 FL Florida       24 MT Montana         40 TN Tennessee
   09 GA Georgia       25 NE Nebraska        41 TX Texas
   10 ID Idaho         26 NV Nevada          42 UT Utah
   11 IL Illinois      27 NH New Hampshire   43 VT Vermont
   12 IN Indiana       28 NJ New Jersey      44 VA Virginia
   13 IA Iowa          29 NM New Mexico      45 WA Washington
   14 KS Kansas        30 NY New York        46 WV West Virginia
   15 KY Kentucky      31 NC North Carolina  47 WI Wisconsin
   16 LA Louisiana     32 ND North Dakota    48 WY Wyoming

   Planned additions to the USHCN:           49    Not Used
                                             50 AK Alaska
                                             51 HI Hawaii
                                             66 PR Puerto Rico
                                             67 VI Virgin Islands
                                             91    Pacific Islands


STATION HISTORY INVENTORY FILE

Record Size:  64 characters/record

The USHCN station inventory file (station.inventory.Z) contains the station ID,
latitude, longitude, elevation, and station name for the 1221 USHCN stations.  The
format of the file is as follows:

Position    Data Field

01 - 09     STATION ID
  01 - 02     State ID
  03 - 06     Coop ID
  07          "-"
  08 - 09     State Division ID
11 - 16     LATITUDE (Decimal Degrees)
18 - 24     LONGITUDE (Decimal Degrees)
26 - 30     ELEVATION (Feet)
32 - 33     STATE ABBREVIATION
35 - 64     STATION NAME AND QUALIFIER


STATION AREA LAND USE/LAND COVER FILE

NOAA's National  Climatic  Data  Center (NCDC) implemented a Global
Baseline  Data  Project in 1990.  The purpose of the  international
project was to gather long-term Climatological data for research in
global climate change.

Some 1300  1st order stations, airports  (city/rural),  cooperative
weather observation stations and all stations of the United  States
Historical Climatological Network (HCN) a special group of stations
with long-term records of climate data, were included.

Each station was requested to enter a code 0-9 (codes listed below)
which best describe  todays  predominant  land use  within a circle
around their station  at each  radius  (100 meters, 1 kilometer, 10
kilometers).   More  than  one  code  may be  used if  necessary to
describe  several  predominant  characteristics within each circle.
The importance  here was to code  the predominant land use, not all
land use.

The project, coordinated by NCDC's Lewis France, Anne Lazar, Elaine
Mason, Alvin McGahee and Ken Weathers, is now available on diskette
and will soon be included as part of an  On-Line Relational station
history data base at NCDC.

Codes:

O    UNKNOWN
1    NON-VEGETATED (barren, desert)
2    COASTAL OR ISLAND
3    FOREST
4    OPEN FARMLAND, GRASSLAND OR TUNDRA
5    SMALL TOWN, LESS THAN 1000 POPULATION
6    TOWN 1000 TO 10,000 POPULATION
7    CITY AREA WITH BUILDINGS LESS THAN 10 METERS*
8    CITY AREA WITH BUILDINGS GREATER THAN 10 METERS*
9    AIRPORT

  *30 feet or 3 stories tall


Position	Data Field

01-02		STATE 
04-32		STATION NAME         
34-35		STATE NUMBER
37-40		STATION NUMBER
48-57		LAND USE: 100 MTR RADIUS AROUND STATION
59-69		LAND USE: 1 KMTR RADIUS AROUND STATION
71-80           LAND USE: 10 KMTR RADIUS AROUND STATION


