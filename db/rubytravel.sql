-- This is based on geonames table allCountries
-- drop table places;

<<<<<<< HEAD:db/rubytravel.sql

CREATE TABLE `places` (
	  `id` int(11) NOT NULL AUTO_INCREMENT,
	  `name` varchar(200) DEFAULT NULL,
	  `geonameid` int(11) DEFAULT NULL,
	  `asciiname` varchar(200) DEFAULT NULL,
	  `alternatenames` varchar(5000) DEFAULT NULL,
	  `latitude` double DEFAULT NULL, -- latitude in decimal degrees (wgs84)
	  `longitude` double DEFAULT NULL,
	  `elevation` int(11) DEFAULT NULL,
	  `feature_class` char(1) DEFAULT NULL,
	  `feature_code` varchar(10) DEFAULT NULL,
	  `use_code` varchar(500) DEFAULT NULL,
	  `country_code` char(2) DEFAULT NULL,
	  `street_address` varchar(300) DEFAULT NULL,
	  `city` varchar(100) DEFAULT NULL,
	  `state` varchar(100) DEFAULT NULL,
	  `postal_code` varchar(20) DEFAULT NULL,
	  `phone` varchar(30) DEFAULT NULL,
	  `email` varchar(80) DEFAULT NULL,
	  `url` varchar(256) DEFAULT NULL,
	  `source` char(3) DEFAULT NULL,
	  `source_id` varchar(100) DEFAULT NULL,
	  `season_1` char(1) DEFAULT NULL,
	  `season_2` char(1) DEFAULT NULL,
	  `season_3` char(1) DEFAULT NULL,
	  `season_4` char(1) DEFAULT NULL,
	  `season_5` char(1) DEFAULT NULL,
	  `season_6` char(1) DEFAULT NULL,
	  `season_7` char(1) DEFAULT NULL,
	  `season_8` char(1) DEFAULT NULL,
	  `season_9` char(1) DEFAULT NULL,
	  `season_10` char(1) DEFAULT NULL,
	  `season_11` char(1) DEFAULT NULL,
	  `season_12` char(1) DEFAULT NULL,
	  `hour_start` int(11) DEFAULT NULL,
	  `hour_end` int(11) DEFAULT NULL,
	  `open_days` char(7) DEFAULT NULL,
	  `hours` varchar(200) DEFAULT NULL,
	  `geopoint` point DEFAULT NULL,
	  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	  `created_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
	  `admin1_code` varchar(20) DEFAULT NULL,
	  `maxelevation` int(11) DEFAULT NULL,
	  `transportation` varchar(200) DEFAULT NULL,
	  `transportation_note` varchar(500) DEFAULT NULL,
	  `difficulty` float DEFAULT NULL,
	  `distance` float DEFAULT NULL,
	  `area` float DEFAULT NULL,
	  `howaccessible` int(11) DEFAULT NULL,
	  `parent` int(11) DEFAULT NULL,
	  `nextsibling` int(11) DEFAULT NULL,
	  `note` varchar(2000) DEFAULT NULL,
	  `rating` int(11) DEFAULT NULL,
	  `thumbnail_link` varchar(256) DEFAULT NULL,
	  PRIMARY KEY (`id`),
	UNIQUE KEY `lplace_name_city` (`name`,`city`),
	  KEY `lpfeature_class_index` (`feature_class`),
	  KEY `lpfeature_code_index` (`feature_code`),
	  KEY `lpname_index` (`name`) USING BTREE,
	  KEY `lplongitude_index` (`longitude`),
	  KEY `lplatitude_index` (`latitude`),
	  KEY `lpsource_index` (`source`) USING HASH
=======
create table IF NOT EXISTS places (
	id	int auto_increment primary key,         -- integer id of record in geonames database
	name   varchar(200),      -- name 
	geonameid	int,         -- closest city in geonames database
	asciiname varchar(200),         -- name of geographical point in plain ascii characters, varchar(200)
	alternatenames varchar(5000),    -- alternatenames, comma separated varchar(5000)
	latitude double,          -- latitude in decimal degrees (wgs84)
	longitude double,     -- longitude in decimal degrees (wgs84)
	elevation  int,       -- in meters, integer
	maxelevation	int,	-- in meters
	transportation  varchar(200),  -- car,train,plane,walk,bus from nearest town/city (csv)
	transportation_note varchar(500),
	difficulty      int,        -- 1-10 , 1 - trivial, 10- hardest
	howaccessible       int,        -- 1-10  , 0:inaccessible, 1:no road, 2:trails, 3:remote, 4:private vehicle, 5-7:pub transp, 8:handicap
	distance        int,    -- in m  for trails 
	area            int,    -- sq m
	feature_class char(1),      -- see http://www.geonames.org/export/codes.html, varchar(10)
	feature_code varchar(10),      -- see http://www.geonames.org/export/codes.html, varchar(10)
	feature2_code varchar(10),      -- see http://www.geonames.org/export/codes.html, varchar(10)
	country_code char(2),      -- ISO-3166 2-letter country code, 2 characters
	street_address varchar(300),      
	city     varchar(100),       -- matches admin2Codes.txt  deref
	state	 varchar(100),       --  matches admin1Codes.txt; deref
	postal_code	varchar(20),
	phone	varchar(20),
	email	varchar(80),
	url		varchar(256),
	source	char(3),	 -- the import file from whence phoebe loaded 
	source_id	varchar(100),		-- format depends on source
	season_1	char(1),	-- H,M,L,O - high,medium,low,off season, S= superhigh, C = closed
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
	hour_start	int,
	hour_end	int,
	open_days	char(7),	-- as MTWTFSS - O=open,C=close,A - appointment, blank= don't know
	hours		varchar(200),
	geopoint  POINT,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	created_at timestamp, -- date of last modification in yyyy-MM-dd format
	admin1_code varchar(20) DEFAULT NULL,
	INDEX lpfeature_class_index (feature_class),
	INDEX lpfeature_code_index (feature_code),
	INDEX lpname_index using btree(name),
	INDEX lplongitude_index (longitude),
	INDEX lplatitude_index (latitude),
	INDEX lpsource_index using HASH(source),
	unique key lplace_name_city (name,city)
>>>>>>> 10da8583e5392072805cd13988d0b0c5c92442bd:db/rubytravel.sql
);

-- insert into locations (name,geonameid, asciiname, alternatenames, latitude,longitude,elevation ,feature_class ,feature_code ,feature2_code ,country_code,street_address, city,state,postal_code,phone,email,url,source,source_id,season_1, season_2,season_3,season_4,season_5,season_6,season_7,season_8 ,season_9,season_10,season_11 ,season_12,hour_start,hour_end ,open_days ,hours,geopoint,updated_at,created_at, admin1_code)  select name,geonameid, asciiname, alternatenames, latitude,longitude,elevation ,feature_class ,feature_code ,feature2_code ,country_code,street_address, city,state,postal_code,phone,email,url,source,source_id,season_1, season_2,season_3,season_4,season_5,season_6,season_7,season_8 ,season_9,season_10,season_11 ,season_12,hour_start,hour_end ,open_days ,hours,geopoint,updated_at,created_at, admin1_code from places;

-- #insert into locations ( id,name,asciiname,alternatenames,latitude,longitude,feature_class,feature_code,country_code,cc2,admin1_code,admin2_code,admin3_code,admin4_code,population,elevation,gtopo30,timezone,modification,source)
-- #select geonameid,name,asciiname,alternatenames,latitude,longitude,feature_class,feature_code,country_code,cc2,admin1_code,admin2_code,admin3_code,admin4_code,population,elevation,gtopo30,timezone,modification,'GEO' as source from allCountries;
-- #UPDATE locations
-- #SET geopoint= PointFromText(CONCAT('POINT(',longitude,' ',latitude,')')); 

drop table  IF EXISTS weatherInfo ;
create table IF NOT EXISTS weatherInfo (
    id  int auto_increment primary key,
	-- id	int primary key,     -- integer id of record in geonames database
	geonameid	int,	-- integer id of record in geonames database
	average_max_temp	float, -- in centigrade
	average_min_temp	float,
	latitude double,          -- latitude in decimal degrees (wgs84)
	longitude double,     -- longitude in decimal degrees (wgs84)
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
	avg_1_raindays	float,
	avg_2_raindays	float,
	avg_3_raindays	float,
	avg_4_raindays	float,
	avg_5_raindays	float,
	avg_6_raindays	float,
	avg_7_raindays	float,
	avg_8_raindays	float,
	avg_9_raindays	float,
	avg_10_raindays	float,
	avg_11_raindays	float,
	avg_12_raindays	float
);

create unique index weather_latlng on weatherInfo(latitude,longitude);
