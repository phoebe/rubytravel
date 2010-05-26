require 'GeonameDB'
class Location < GeonameDB
  #set_table_name 'allCountries'
  set_table_name 'cities'
  set_primary_key :geonameid
  #attr_reader :geonameid
  
=begin
def id 
  return self.attributes['geonameid'].to_s 
end

  def geonameid 
    return self.attributes['geonameid'].to_s 
  end
=end
  def self.ClosestCity( lat, lon)
           
      begin 
      miles = 50;
      offset = miles/(Math.cos((lat*Math::PI/180.0))*69.1).abs;
      lon1= lon- offset;
      lon2= lon+ offset;
      lat1= lat- (miles/69.1);
      lat2= lat+ (miles/69.1);
      monthcond=
      nearest= [' 3956 * 2 * ASIN(SQRT(POWER(SIN((latitude - ',
      lat,') * pi()/180/2),2) + COS(latitude * pi()/180) * COS(', lat ,
      ' * pi()/180) * POWER(SIN((longitude -', lon,') * pi()/180/2),2) )) ',
      ' as distance '].join()+','
      
      conditions=[ ' longitude between ',lon1,' and ',lon2,' and ',
      ' latitude between ', lat1 ,' and ', lat2 ,
      ' having distance < ', miles, ' ORDER by distance asc ' ].join()
      rescue
           nearest=""; conditions="";
      end
      #@places= self.find_by_sql ["SELECT *, MATCH (use_code) AGAINST (?) as geonameid FROM places WHERE MATCH (use_code) AGAINST (?) limit 100", intr, intr]
      
      @places= self.find_by_sql ["SELECT *,"+nearest+" FROM cities WHERE " + mcond + conditions+ " limit 1 ", intr, intr]
    end
end
