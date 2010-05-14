CREATE TABLE `places2` (
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
