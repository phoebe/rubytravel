
-- create database geonames
-- drop table geoAlternateNames;
-- drop table geoPostal ;
-- drop table timezones ;
-- drop table admin1 ;
-- drop table admin2 ;
-- drop table features ;
-- drop table countryInfo ;

create table IF NOT EXISTS allCountries (
	geonameid	int primary key,         -- integer id of record in geonames database
	name        varchar(200),      -- name of geographical point (utf8) varchar(200)
	asciiname varchar(200),         -- name of geographical point in plain ascii characters, varchar(200)
	alternatenames varchar(5000),    -- alternatenames, comma separated varchar(5000)
	latitude double,          -- latitude in decimal degrees (wgs84)
	longitude double,     -- longitude in decimal degrees (wgs84)
	feature_class char(1),     -- see http://www.geonames.org/export/codes.html, char(1)
	feature_code varchar(10),      -- see http://www.geonames.org/export/codes.html, varchar(10)
	country_code char(2),      -- ISO-3166 2-letter country code, 2 characters
	cc2  varchar(60),             -- alternate country codes, comma separated, ISO-3166 2-letter country code, 60 characters
	admin1_code varchar(20),       -- fipscode (subject to change to iso code), see exceptions below, see file admin1Codes.txt for display names of this code; varchar(20)
	admin2_code varchar(80),       -- code for the second administrative division, a county in the US, see file admin2Codes.txt; varchar(80) 
	admin3_code varchar(20),       -- code for third level administrative division, varchar(20)
	admin4_code  varchar(20),      -- code for fourth level administrative division, varchar(20)
	population  double,      -- bigint (4 byte int) 
	elevation  int,       -- in meters, integer
	gtopo30    int,       -- average elevation of 30'x30' (ca 900mx900m) area in meters, integer
	timezone  varchar(30),     -- the timezone id (see file timeZone.txt)
	modification date, -- date of last modification in yyyy-MM-dd format
	source	varchar(10), -- the import file from whence phoebe loaded 
	INDEX feature_class_index (feature_class),
	INDEX feature_code_index (feature_code),
	INDEX name_index using btree(name),
	INDEX longitude_index (longitude),
	INDEX latitude_index (latitude),
	INDEX source_index using HASH(source),
	INDEX altname_index using btree(alternatenames)
);


create table IF NOT EXISTS geoAlternateNames (
	id int primary key,
	geonameid   int,
	isolanguage	varchar(7),
	alternate_name varchar(200),
	isPreferredName char(1),
	isShortName	char(1)
);

create table IF NOT EXISTS geoPostal (
	country_code  varchar(2),
	postal_code	varchar(10),
	place_name	varchar(200),
	admin1_name varchar(100),
	admin1_code varchar(20),
	admin2_name varchar(100), 
	admin2_code varchar(20), 
	admin3_name varchar(10),
	latitude double,          -- latitude in decimal degrees (wgs84)
	longitude double,     -- longitude in decimal degrees (wgs84)
	accuracy	int
);

create table IF NOT EXISTS timezones (
	timezoneId  varchar(30) primary key,
	gmtoffset   float,
	dstoffset  float
);

create table IF NOT EXISTS admin1 (
	code  varchar(20) primary key,
	name	varchar(100),
	asciname	varchar(100),
	geonameid   int
);

create table IF NOT EXISTS admin2 (
	code  varchar(80),
	name	varchar(100),
	asciname	varchar(100),
	geonameid	int primary key
);

create table IF NOT EXISTS features (
	code  varchar(10) primary key,
	name	varchar(256),
	description	varchar(256)
);

create table IF NOT EXISTS countryInfo (
	iso char(2) primary key,
	iso3 char(3),
	isonumeric int,
	fips char(2),
	country varchar(40),
	capital varchar(100),
	area_km2  int,
	population  int,
	continent varchar(5),
	tld 	varchar(10),
	currencycode varchar(10),
	currencyname varchar(20),
	phone varchar(20),
	postalcode_format varchar(50),
	postalcode_regex varchar(256),
	languages varchar(100),
	geonameid int,
	neighbours	varchar(80),
	equivalentFipsCode varchar(80),
	INDEX countrygeonameid_index (geonameid),
	INDEX countryname_index using btree(country)
);

-- Add  activities
-- Features = land feature , activities = things you can do
create table IF NOT EXISTS attractions (
	code varchar(10) primary key,
	description varchar(200)
);

create table IF NOT EXISTS basicInfo (
	geonameid	int primary key,         -- integer id of record in geonames database
	average_max_temp	float, -- in centigrade
	average_min_temp	float,
	avg_1_max_temp	float,
	avg_2_max_temp	float,
	avg_3_max_temp	float,
	avg_4_max_temp	float,
	avg_5_max_temp	float,
	avg_6_max_temp	float,
	avg_7_max_temp	float,
	avg_8_max_temp	float,
	avg_9_max_temp	float,
	avg_10_max_temp	float,
	avg_11_max_temp	float,
	avg_12_max_temp	float,
	avg_1_min_temp	float,
	avg_2_min_temp	float,
	avg_3_min_temp	float,
	avg_4_min_temp	float,
	avg_5_min_temp	float,
	avg_6_min_temp	float,
	avg_7_min_temp	float,
	avg_8_min_temp	float,
	avg_9_min_temp	float,
	avg_10_min_temp	float,
	avg_11_min_temp	float,
	avg_12_min_temp	float,
	avg_1_rainfall_mm	float,
	avg_2_rainfall_mm	float,
	avg_3_rainfall_mm	float,
	avg_4_rainfall_mm	float,
	avg_5_rainfall_mm	float,
	avg_6_rainfall_mm	float,
	avg_7_rainfall_mm	float,
	avg_8_rainfall_mm	float,
	avg_9_rainfall_mm	float,
	avg_10_rainfall_mm	float,
	avg_11_rainfall_mm	float,
	avg_12_rainfall_mm	float,
	avg_1_raindays_mm	float,
	avg_2_raindays_mm	float,
	avg_3_raindays_mm	float,
	avg_4_raindays_mm	float,
	avg_5_raindays_mm	float,
	avg_6_raindays_mm	float,
	avg_7_raindays_mm	float,
	avg_8_raindays_mm	float,
	avg_9_raindays_mm	float,
	avg_10_raindays_mm	float,
	avg_11_raindays_mm	float,
	avg_12_raindays_mm	float,
	season_1	char(1),	-- H,M,L,O - high,medium,low,off season
	season_2	char(1),	-- H,M,L,O - high,medium,low,off season
	season_3	char(1),	-- H,M,L,O - high,medium,low,off season
	season_4	char(1),	-- H,M,L,O - high,medium,low,off season
	season_5	char(1),	-- H,M,L,O - high,medium,low,off season
	season_6	char(1),	-- H,M,L,O - high,medium,low,off season
	season_7	char(1),	-- H,M,L,O - high,medium,low,off season
	season_8	char(1),	-- H,M,L,O - high,medium,low,off season
	season_9	char(1),	-- H,M,L,O - high,medium,low,off season
	season_10	char(1),	-- H,M,L,O - high,medium,low,off season
	season_11	char(1),	-- H,M,L,O - high,medium,low,off season
	season_12	char(1),	-- H,M,L,O - high,medium,low,off season
	open_hour	int,
	close_hour	int,
	hours		varchar(30),
	open_days	char(7)	-- as MTWTFSS - O=open,C=close,D= don't know
);

create table IF NOT EXISTS basicInfo (
	geonameid	int primary key,         -- integer id of record in geonames database
	average_max_temp	float, -- in centigrade
	average_min_temp	float,
	avg_1_max_temp	float,
	avg_2_max_temp	float,
	avg_3_max_temp	float,
	avg_4_max_temp	float,
	avg_5_max_temp	float,
	avg_6_max_temp	float,
	avg_7_max_temp	float,
	avg_8_max_temp	float,
	avg_9_max_temp	float,
	avg_10_max_temp	float,
	avg_11_max_temp	float,
	avg_12_max_temp	float,
	avg_1_min_temp	float,
	avg_2_min_temp	float,
	avg_3_min_temp	float,
	avg_4_min_temp	float,
	avg_5_min_temp	float,
	avg_6_min_temp	float,
	avg_7_min_temp	float,
	avg_8_min_temp	float,
	avg_9_min_temp	float,
	avg_10_min_temp	float,
	avg_11_min_temp	float,
	avg_12_min_temp	float,
	avg_1_rainfall_mm	float,
	avg_2_rainfall_mm	float,
	avg_3_rainfall_mm	float,
	avg_4_rainfall_mm	float,
	avg_5_rainfall_mm	float,
	avg_6_rainfall_mm	float,
	avg_7_rainfall_mm	float,
	avg_8_rainfall_mm	float,
	avg_9_rainfall_mm	float,
	avg_10_rainfall_mm	float,
	avg_11_rainfall_mm	float,
	avg_12_rainfall_mm	float,
	avg_1_raindays_mm	float,
	avg_2_raindays_mm	float,
	avg_3_raindays_mm	float,
	avg_4_raindays_mm	float,
	avg_5_raindays_mm	float,
	avg_6_raindays_mm	float,
	avg_7_raindays_mm	float,
	avg_8_raindays_mm	float,
	avg_9_raindays_mm	float,
	avg_10_raindays_mm	float,
	avg_11_raindays_mm	float,
	avg_12_raindays_mm	float,
	season_1	char(1),	-- H,M,L,O - high,medium,low,off season
	season_2	char(1),	-- H,M,L,O - high,medium,low,off season
	season_3	char(1),	-- H,M,L,O - high,medium,low,off season
	season_4	char(1),	-- H,M,L,O - high,medium,low,off season
	season_5	char(1),	-- H,M,L,O - high,medium,low,off season
	season_6	char(1),	-- H,M,L,O - high,medium,low,off season
	season_7	char(1),	-- H,M,L,O - high,medium,low,off season
	season_8	char(1),	-- H,M,L,O - high,medium,low,off season
	season_9	char(1),	-- H,M,L,O - high,medium,low,off season
	season_10	char(1),	-- H,M,L,O - high,medium,low,off season
	season_11	char(1),	-- H,M,L,O - high,medium,low,off season
	season_12	char(1),	-- H,M,L,O - high,medium,low,off season
	open_hour	int,
	close_hour	int,
	hours		varchar(30),
	open_days	char(7),	-- as MTWTFSS - O=open,C=close,D= don't know
};

-- where data came from 
-- alter table allCountries add column source varchar(10);
-- SPATIAL support
-- alter table allCountries add column loc point NOT NULL;
--  add SPATIAL KEY loc (loc);
-- create spatial index allCountries_loc_index on allCountries(loc);

-- ADD loc to mytable
-- UPDATE allCountries SET Coord = PointFromText(CONCAT('POINT(',myTable.DLong,' ',myTable.DLat,')'));

-- doesn't work - linestring returns null, index problem?
delimiter //
drop function if exists geonames.distance;//
create function geonames.distance (a POINT, b POINT)
RETURNS double DETERMINISTIC
BEGIN
	RETURN round(glength(linestringfromwkb(linestring(asbinary(a),asbinary(b)))));
END
//
delimiter ;

