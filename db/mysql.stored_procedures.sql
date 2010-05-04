-- To list all procedures
-- SELECT ROUTINE_NAME FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_TYPE="PROCEDURE" AND ROUTINE_SCHEMA="geonames";
-- *** Awesome! use with weatherInfo, places and allCountries
delimiter // ;
drop procedure IF EXISTS geonames.withinRadiuswithConds;//
create procedure geonames.withinRadiuswithConds( IN tbl varchar(80), IN conds varchar(1000),IN lat double,IN lon double, IN MILES int)
BEGIN
declare lon1 double; declare lon2 double;
declare lat1 double; declare lat2 double;
declare cond varchar(1005);
set lon1= lon- MILES/abs(cos(radians(lat))*69.1);
set lon2= lon+ MILES/abs(cos(radians(lat))*69.1);
set lat1= lat- (MILES/69.1);
set lat2= lat+ (MILES/69.1);
	if conds is null  THEN set cond=' ';
	else set cond = concat(conds,' and ');
	end if;

	SET @s = CONCAT('select *, 3956 * 2 * ASIN(SQRT(POWER(SIN((latitude - ',
		lat,') * pi()/180/2),2) + COS(latitude * pi()/180) * COS(', lat ,' * pi()/180) * POWER(SIN((longitude -', lon,') * pi()/180/2),2) )) ',
	' as distance from ', tbl ,
	' where longitude between ',lon1,' and ',lon2,' and ',
	cond,
	' latitude between ', lat1 ,' and ', lat2 ,
	' having distance < ', MILES, ' ORDER by distance;' );

	PREPARE stmt FROM @s;
	EXECUTE stmt;
END
//
delimiter ;

delimiter // ;
drop procedure IF EXISTS geonames.nearCitywithConds;//
create procedure geonames.nearCitywithConds( IN tbl varchar(80), IN conds varchar(1000),IN gid int, IN MILES int)
BEGIN
declare lon double; declare lat double;
declare lon1 double; declare lon2 double;
declare lat1 double; declare lat2 double;
declare cond varchar(1005);
if conds is null or conds=""  THEN set cond='';
else set cond = concat(conds,' and ');
end if; 
select longitude,latitude into lon, lat from allCountries where geonameid=gid;
set lon1= lon- MILES/abs(cos(radians(lat))*69.1);
set lon2= lon+ MILES/abs(cos(radians(lat))*69.1);
set lat1= lat- (MILES/69.1);
set lat2= lat+ (MILES/69.1);

	SET @s = CONCAT('select *, 3956 * 2 * ASIN(SQRT(POWER(SIN((latitude - ',
		lat,') * pi()/180/2),2) + COS(latitude * pi()/180) * COS(', lat ,' * pi()/180) * POWER(SIN((longitude -', lon,') * pi()/180/2),2) )) ',
	' as distance from ', tbl ,
	' where longitude between ',lon1,' and ',lon2,' and ',
	cond,
	' latitude between ', lat1 ,' and ', lat2 ,
	' having distance < ', MILES, ' ORDER by distance;' );

	PREPARE stmt FROM @s;
	EXECUTE stmt;
END
//
delimiter ;

delimiter // ;
drop procedure IF EXISTS geonames.withinRadius;//
create procedure geonames.withinRadius(IN lat double,IN lon double, IN MILES int)
BEGIN
declare lon1 double; declare lon2 double;
declare lat1 double; declare lat2 double;
set lon1= lon- MILES/abs(cos(radians(lat))*69.1);
set lon2= lon+ MILES/abs(cos(radians(lat))*69.1);
set lat1= lat- (MILES/69.1);
set lat2= lat+ (MILES/69.1);

select *, 3956 * 2 * ASIN(SQRT(POWER(SIN((latitude - lat) * pi()/180/2),2) +
	 COS(latitude * pi()/180) * COS(lat * pi()/180) *
	 POWER(SIN((longitude - lon) * pi()/180/2),2) )) as distance
		from allCountries 
	where longitude between lon1 and lon2
	and latitude between lat1 and lat2
	having distance < MILES ORDER by distance;

END
//
delimiter  ;

delimiter // ;
drop procedure IF EXISTS geonames.fieldswithinRadius;//
create procedure geonames.fieldswithinRadius(IN fields varchar(2000), IN lat double,IN lon double, IN MILES int)
BEGIN
declare lon1 double; declare lon2 double;
declare lat1 double; declare lat2 double;
set lon1= lon- MILES/abs(cos(radians(lat))*69.1);
set lon2= lon+ MILES/abs(cos(radians(lat))*69.1);
set lat1= lat- (MILES/69.1);
set lat2= lat+ (MILES/69.1);

	SET @s = CONCAT('select ',fields,', 3956 * 2 * ASIN(SQRT(POWER(SIN((latitude - ',
		lat,') * pi()/180/2),2) + COS(latitude * pi()/180) * COS(', lat ,' * pi()/180) * POWER(SIN((longitude -', lon,') * pi()/180/2),2) )) ',
	' as distance from allCountries ',
	' where longitude between ',lon1,' and ',lon2,' and ',
	' latitude between ', lat1 ,' and ', lat2 ,
	' having distance < ', MILES, ' ORDER by distance;' );


	PREPARE stmt FROM @s;
	EXECUTE stmt;
END
//
delimiter ;

--if cond is not null then else end if;
delimiter // ;
drop procedure IF EXISTS geonames.fieldswithinRadiuswithConds;//
create procedure geonames.fieldswithinRadiuswithConds(IN fields varchar(2000),IN cond varchar(20),IN condval varchar(100),IN lat double,IN lon double, IN MILES int)
BEGIN
declare conds varchar(255);
declare lon1 double; declare lon2 double;
declare lat1 double; declare lat2 double;
set lon1= lon- MILES/abs(cos(radians(lat))*69.1);
set lon2= lon+ MILES/abs(cos(radians(lat))*69.1);
set lat1= lat- (MILES/69.1);
set lat2= lat+ (MILES/69.1);
	SET @s = CONCAT('select ',fields,', 3956 * 2 * ASIN(SQRT(POWER(SIN((latitude - ',
		lat,') * pi()/180/2),2) + COS(latitude * pi()/180) * COS(', lat ,' * pi()/180) * POWER(SIN((longitude -', lon,') * pi()/180/2),2) )) ',
	' as distance from allCountries ',
	' where longitude between ',lon1,' and ',lon2,' and ',
	cond, " = '", condval, "' and ",
	' latitude between ', lat1 ,' and ', lat2 ,
	' having distance < ', MILES, ' ORDER by distance;' );

	PREPARE stmt FROM @s;
	EXECUTE stmt;
END
//
delimiter ;

delimiter // ;
drop function if exists geonames.latlngdistance;//
create function geonames.latlngdistance( lat1 double, lon1 double, lat2 double, lon2 double )
RETURNS double DETERMINISTIC
BEGIN
	RETURN 3956 * 2 * ASIN(SQRT(POWER(SIN((lat1 - lat2) * pi()/180/2),2) +
	 COS(lat1 * pi()/180) * COS(lat2 * pi()/180) *
	 POWER(SIN((lon1 - lon2) * pi()/180/2),2) )) ;
END
//
delimiter ;

delimiter // ;
DROP PROCEDURE IF EXISTS geonames.PlaceswithinRadius; //
CREATE PROCEDURE geonames.PlaceswithinRadius(IN fields VARCHAR(200), IN tbl varchar(64), IN lat DOUBLE, IN lon DOUBLE, IN miles INT)
BEGIN
	declare unit double;
	declare lon1 double; declare lon2 double;
	declare lat1 double; declare lat2 double;
	set unit = miles/69.1;
	set lat1= lat- unit;
	set lat2= lat+ unit;
	set unit = unit/abs(cos(radians(lat)));
	set lon1= lon- unit;
	set lon2= lon+ unit;
	SET @s = CONCAT('select ',fields,
		',SQRT( POW(69.1 * (latitude - ' , lat ,
		'), 2) + POW(69.1 * (longitude - ',lon,
		') * cos(', lat,' / 57.3), 2) ) AS distance from ',tbl,
		' where latitude between ', lat1, ' and ', lat2 ,' and ',
				' longitude between ', lon1 ,' and ', lon2,
				' having distance < ', miles ,' order by distance ' );
	PREPARE stmt FROM @s;
	EXECUTE stmt;
END
//
delimiter ;


delimiter // ;
drop procedure IF EXISTS geonames.withinRadiusLoc;// 
create procedure geonames.withinRadiusLoc( IN gid int, IN MILES int)
BEGIN
	declare lon double; declare lat double;
	declare lon1 double; declare lon2 double;
	declare lat1 double; declare lat2 double;
	select longitude,latitude into lon,lat from allCountries where geonameid= gid;
	set lon1= lon- MILES/abs(cos(radians(lat))*69.1);
	set lon2= lon+ MILES/abs(cos(radians(lat))*69.1);
	set lat1= lat- (MILES/69.1);
	set lat2= lat+ (MILES/69.1);

	select * , 3956 * 2 * ASIN(SQRT(POWER(SIN((orig.latitude - dest.latitude) * pi()/180/2),2) + COS(orig.latitude * pi()/180) * COS(dest.latitude * pi()/180) * POWER(SIN((orig.longitude - dest.longitude) * pi()/180/2),2) )) as distance from allCountries orig, allCountries dest where orig.geonameid= gid and dest.longitude between lon1 and lon2 and dest.latitude between lat1 and lat2 having distance < MILES ORDER by distance;

END
//

delimiter ;

