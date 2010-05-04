-- This is based on geonames table allCountries
drop table locations;
create table IF NOT EXISTS locations (
	id	int auto_increment primary key,         -- integer id of record in geonames database
	name   varchar(200),      -- name 
	geonameid	int,         -- closest city in geonames database
	asciiname varchar(200),         -- name of geographical point in plain ascii characters, varchar(200)
	alternatenames varchar(5000),    -- alternatenames, comma separated varchar(5000)
	latitude double,          -- latitude in decimal degrees (wgs84)
	longitude double,     -- longitude in decimal degrees (wgs84)
	elevation  int,       -- in meters, integer
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
	hour_start	int,
	hour_end	int,
	open_days	char(7),	-- as MTWTFSS - O=open,C=close,D= don't know
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
);
insert into locations (name,geonameid, asciiname, alternatenames, latitude,longitude,elevation ,feature_class ,feature_code ,feature2_code ,country_code,street_address, city,state,postal_code,phone,email,url,source,source_id,season_1, season_2,season_3,season_4,season_5,season_6,season_7,season_8 ,season_9,season_10,season_11 ,season_12,hour_start,hour_end ,open_days ,hours,geopoint,updated_at,created_at, admin1_code)  select name,geonameid, asciiname, alternatenames, latitude,longitude,elevation ,feature_class ,feature_code ,feature2_code ,country_code,street_address, city,state,postal_code,phone,email,url,source,source_id,season_1, season_2,season_3,season_4,season_5,season_6,season_7,season_8 ,season_9,season_10,season_11 ,season_12,hour_start,hour_end ,open_days ,hours,geopoint,updated_at,created_at, admin1_code from places;
