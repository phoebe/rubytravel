-- This is based on geonames table allCountries
-- drop table places;


CREATE TABLE `places` (
	  `id` int(11) NOT NULL AUTO_INCREMENT,
	  `name` varchar(200) DEFAULT NULL,
	  `geonameid` int(11) DEFAULT NULL, -- closest city in geonames database
	  `asciiname` varchar(200) DEFAULT NULL,-- name of geographical point in plain ascii characters, varchar(200)
	  `alternatenames` varchar(5000) DEFAULT NULL, -- alternatenames, comma separated varchar(5000)
	  `latitude` double DEFAULT NULL, -- latitude in decimal degrees (wgs84)
	  `longitude` double DEFAULT NULL,
	  `elevation` int(11) DEFAULT NULL, -- in meters, integer
	  `maxelevation` int(11) DEFAULT NULL, -- in meters
	  `feature_class` char(1) DEFAULT NULL,
	  `feature_code` varchar(10) DEFAULT NULL, -- see http://www.geonames.org/export/codes.html, varchar(10)
	  `use_code` varchar(500) DEFAULT NULL, -- comma delimited text
	  `country_code` char(2) DEFAULT NULL, -- ISO-3166 2-letter country code, 2 characters
	  `street_address` varchar(300) DEFAULT NULL,
	  `city` varchar(100) DEFAULT NULL, 	-- text - should be in geonames.allCountries tbl
	  `state` varchar(100) DEFAULT NULL,	 --  matches admin1Codes.txt; deref
	  `postal_code` varchar(20) DEFAULT NULL,
	  `phone` varchar(30) DEFAULT NULL,
	  `email` varchar(80) DEFAULT NULL,
	  `url` varchar(256) DEFAULT NULL,
	  `source` char(3) DEFAULT NULL, -- the import file from whence phoebe loaded 
	  `source_id` varchar(100) DEFAULT NULL, -- format depends on source - maps to source for updates
	  `season_1` char(1) DEFAULT NULL,		 -- H,M,L,O - high,medium,low,off season, S= superhigh, C = closed
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
	  `open_days` char(7) DEFAULT NULL, -- as MTWTFSS - O=open,C=close,A - appointment, blank= don't know
	  `hours` varchar(200) DEFAULT NULL, -- free text - use to seed structure
	  `geopoint` point DEFAULT NULL,
	  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	  `created_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
	  `admin1_code` varchar(20) DEFAULT NULL,
	  `transportation` varchar(200) DEFAULT NULL, -- car,train,plane,walk,bus from nearest town/city (csv)
	  `transportation_note` varchar(500) DEFAULT NULL,
	  `difficulty` float DEFAULT NULL, -- 1-10 , 1 - trivial, 10- hardest
	  `distance` float DEFAULT NULL, -- in m  for trails 
	  `area` float DEFAULT NULL, -- sq m
	  `howaccessible` int(11) DEFAULT NULL, -- 1-10  , 0:inaccessible, 1:no road, 2:trails, 3:remote, 4:private vehicle, 5-7:pub transp, 8,9:handicap (hotels for deaf/ blind)
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
	  KEY `lplongitude_index` (`longitude`), -- merge lat,long into 1 index?
	  KEY `lplatitude_index` (`latitude`),
	  KEY `lpsource_index` (`source`) USING HASH
);

create fulltext index use_code_findex on places(use_code);
create fulltext index places_name_usecode_findex on places(name,use_code);

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

CREATE TABLE `attractions` (
	  `id` int(11) NOT NULL AUTO_INCREMENT,
	  `name` varchar(200) DEFAULT NULL,
	  `geonameid` int(11) DEFAULT NULL, -- closest city in geonames database
	  `asciiname` varchar(200) DEFAULT NULL,-- name of geographical point in plain ascii characters, varchar(200)
	  `alternatenames` varchar(5000) DEFAULT NULL, -- alternatenames, comma separated varchar(5000)
	  `latitude` double DEFAULT NULL, -- latitude in decimal degrees (wgs84)
	  `longitude` double DEFAULT NULL,
	  `elevation` int(11) DEFAULT NULL, -- in meters, integer
	  `maxelevation` int(11) DEFAULT NULL, -- in meters
	  `feature_class` char(1) DEFAULT NULL,
	  `feature_code` varchar(10) DEFAULT NULL, -- see http://www.geonames.org/export/codes.html, varchar(10)
	  `use_code` varchar(500) DEFAULT NULL, -- comma delimited text
	  `country_code` char(2) DEFAULT NULL, -- ISO-3166 2-letter country code, 2 characters
	  `street_address` varchar(300) DEFAULT NULL,
	  `city` varchar(100) DEFAULT NULL, 	-- text - should be in geonames.allCountries tbl
	  `state` varchar(100) DEFAULT NULL,	 --  matches admin1Codes.txt; deref
	  `postal_code` varchar(20) DEFAULT NULL,
	  `phone` varchar(30) DEFAULT NULL,
	  `email` varchar(80) DEFAULT NULL,
	  `url` varchar(256) DEFAULT NULL,
	  `source` char(3) DEFAULT NULL, -- the import file from whence phoebe loaded 
	  `source_id` varchar(100) DEFAULT NULL, -- format depends on source - maps to source for updates
	  `season_1` char(1) DEFAULT NULL,		 -- H,M,L,O - high,medium,low,off season, S= superhigh, C = closed
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
	  `open_days` char(7) DEFAULT NULL, -- as MTWTFSS - O=open,C=close,A - appointment, blank= don't know
	  `hours` varchar(200) DEFAULT NULL, -- free text - use to seed structure
	  `geopoint` point DEFAULT NULL,
	  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	  `created_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
	  `admin1_code` varchar(20) DEFAULT NULL,
	  `transportation` varchar(200) DEFAULT NULL, -- car,train,plane,walk,bus from nearest town/city (csv)
	  `transportation_note` varchar(500) DEFAULT NULL,
	  `difficulty` float DEFAULT NULL, -- 1-10 , 1 - trivial, 10- hardest
	  `distance` float DEFAULT NULL, -- in m  for trails 
	  `area` float DEFAULT NULL, -- sq m
	  `howaccessible` int(11) DEFAULT NULL, -- 1-10  , 0:inaccessible, 1:no road, 2:trails, 3:remote, 4:private vehicle, 5-7:pub transp, 8,9:handicap (hotels for deaf/ blind)
	  `parent` int(11) DEFAULT NULL,
	  `nextsibling` int(11) DEFAULT NULL,
	  `note` varchar(2000) DEFAULT NULL,
	  `rating` int(11) DEFAULT NULL,
	  `thumbnail_link` varchar(256) DEFAULT NULL,
	  `place_class` varchar(200) DEFAULT NULL,
	  `place_code` varchar(500) DEFAULT NULL,
	  `use_class` varchar(500) DEFAULT NULL,
	  PRIMARY KEY (`id`),
	UNIQUE KEY `lplace_name_city` (`name`,`city`),
	  KEY `lpfeature_class_index` (`feature_class`),
	  KEY `lpfeature_code_index` (`feature_code`),
	  KEY `lpname_index` (`name`) USING BTREE,
	  KEY `lplongitude_index` (`longitude`), -- merge lat,long into 1 index?
	  KEY `lplatitude_index` (`latitude`),
	  KEY `lpsource_index` (`source`) USING HASH
);
create fulltext index attr_use_code_findex on attractions(use_class,use_code);
create fulltext index attr_place_code_findex on attractions(place_class,place_code);
create fulltext index attr_name_code_findex on attractions(name);

create table plcategory (
	code varchar(6) primary key,
	parent varchar(6),
	descr varchar(80)
);

insert into plcategory(code,descr) values ('OUT','Outdoors');
insert into plcategory(code,descr) values ('ACCOM','Accommodations');
insert into plcategory(code,descr) values ('MUSEUM','Museum');
insert into plcategory(code,descr) values ('FOOD','Food producers or restaurants');
insert into plcategory(code,descr) values ('ENTER','Entertainments');
insert into plcategory(code,descr) values ('SHOP','Shopping');
insert into plcategory(code,descr) values ('SERV','Services such as Salon,Spa or Massage');
insert into plcategory(code,descr) values ('CONF','Conference space');
insert into plcategory(code,descr) values ('RESORT','Resorts');
insert into plcategory(code,descr) values ('HOSP','Hospital or clinic');

insert into plcategory(code,parent,descr) values ('PARK','OUT','National ,State or Local Park or Reservations');
insert into plcategory(code,parent,descr) values ('GARDEN','OUT','Botanical,Public gardens or Zoo');
insert into plcategory(code,parent,descr) values ('AMUSE','OUT','Amusement park, Water Park, Miniature golf, Paintball etc ');
insert into plcategory(code,parent,descr) values ('WILD','OUT','Wilderness or BLM land');
insert into plcategory(code,parent,descr) values ('BEACH','OUT','Beach or water front');
insert into plcategory(code,parent,descr) values ('WATER','OUT','River, Lake, Coast, etc');

insert into plcategory(code,parent,descr) values ('HOTEL','ACCOM','Hotel,Motel or B&B');
insert into plcategory(code,parent,descr) values ('CAMP','ACCOM','Cabin,Tent,Rv park');
insert into plcategory(code,parent,descr) values ('ART','MUSEUM','Art museum');
insert into plcategory(code,parent,descr) values ('SCI','MUSEUM','Science,Natural History or Geology Museum');
insert into plcategory(code,parent,descr) values ('CULT','MUSEUM','History or religious museum');
insert into plcategory(code,parent,descr) values ('REST','FOOD','Restaurant, Cafe,or just serves food');
insert into plcategory(code,parent,descr) values ('DRINK','FOOD','Brewery,Bar,Winery etc');
insert into plcategory(code,parent,descr) values ('CASINO','ENTER','Casino');
insert into plcategory(code,parent,descr) values ('FEST','ENTER','Festivals');
insert into plcategory(code,parent,descr) values ('CLUB','ENTER','Bar, dance club or places with live music');
insert into plcategory(code,parent,descr) values ('SPORT','ENTER','Sports stadiums or facility');
insert into plcategory(code,parent,descr) values ('SHOW','ENTER','Opera,theatre,Concert hall,Ballet,Playhouse or other performance spaces');
insert into plcategory(code,parent,descr) values ('MALL','SHOP','Mall');
insert into plcategory(code,parent,descr) values ('OUTLET','SHOP','Outlets');
insert into plcategory(code,parent,descr) values ('SPA','SERV','Spa');
insert into plcategory(code,parent,descr) values ('CRUISE','RESORT','Cruise');

create table usecategory (
	code varchar(6) primary key,
	parent varchar(6),
	descr varchar(30)
);

insert into usecategory (code,descr) values('ACT','active');
insert into usecategory (code,descr) values('KIDS','suitable for kids under 18');
insert into usecategory (code,descr) values('NIGHT','night time entertainment');
insert into usecategory (code,descr) values('CULT','cultural interests');
insert into usecategory (code,descr) values('ROM','romantic');
insert into usecategory (code,descr) values('ADV','adventurous');
insert into usecategory (code,descr) values('SCENE','scenic');
insert into usecategory (code,descr) values('RELAX','relaxing');
insert into usecategory (code,descr) values('HEALTH','health care, holistic,etc');
insert into usecategory (code,descr) values('EAT','food and drink');

insert into usecategory (code,parent,descr) values('SWIM','ACT','swim');
insert into usecategory (code,parent,descr) values('DIVE','ACT','snorkeling or scuba diving');
insert into usecategory (code,parent,descr) values('HUNT','ACT','Hunting');
insert into usecategory (code,parent,descr) values('FISH','ACT','Fishing');
insert into usecategory (code,parent,descr) values('HIKE','ACT','Hiking or walking');
insert into usecategory (code,parent,descr) values('BIKE','ACT','Biking');
insert into usecategory (code,parent,descr) values('CLIMB','ACT','Rock or Ice climbing');

insert into usecategory (code,parent,descr) values('ARCHIT','CULT','architecture');
insert into usecategory (code,parent,descr) values('ARCHAE','CULT','archaelogy');
insert into usecategory (code,parent,descr) values('HIST','CULT','history');
insert into usecategory (code,parent,descr) values('SKI','ACT','ski,snowboard');
insert into usecategory (code,parent,descr) values('BOAT','ACT','kayak,canoe,whitewater,surf,sail');
insert into usecategory (code,parent,descr) values('ART','CULT','visual or performance art');
insert into usecategory (code,parent,descr) values('SCI','CULT','science');
insert into usecategory (code,parent,descr) values('RELIG','CULT','religion');
insert into usecategory (code,parent,descr) values('MUSIC','CULT','music');
insert into usecategory (code,parent,descr) values('MARTIAL','CULT','martial arts');
