require 'GeonameDB'

class Location < GeonameDB
  #set_table_name 'allCountries'
  set_table_name 'cities'
  set_primary_key :geonameid
  #attr_reader :geonameid
    
  def self.closestCities(list)
    arr=[]
    begin
      list.each { |p|
        ff = closestCity(p[0], p[1])
        miles = 50;
        while (ff.blank?)
          miles = miles+10;
          ff = closestCity(p[0], p[1], miles )
        end  
        arr << ff[0] unless ff.blank?
      }
      return arr;
    rescue
    end
    return arr;
  end
  
  # return closest biggest city within 50 miles
  def self.closestCity( lat, lon, miles=50)           
      begin 
      #miles = 50;
      offset = miles/(Math.cos((lat*Math::PI/180.0))*69.1).abs;
      lon1= lon- offset;
      lon2= lon+ offset;
      lat1= lat- (miles/69.1);
      lat2= lat+ (miles/69.1);
      monthcond=
      nearest= [' 3956 * 2 * ASIN(SQRT(POWER(SIN((latitude - ',
      lat,') * pi()/180/2),2) + COS(latitude * pi()/180) * COS(', lat ,
      ' * pi()/180) * POWER(SIN((longitude -', lon,') * pi()/180/2),2) )) ',
      ' as distance '].join()
      
      conditions=[ ' longitude between ',lon1,' and ',lon2,' and ',
      ' latitude between ', lat1 ,' and ', lat2 ,
      ' having distance < ', miles, ' ORDER by population desc, distance asc ' ].join()
      rescue
           nearest=""; conditions="";
      end
      #@places= self.find_by_sql ["SELECT *, MATCH (use_code) AGAINST (?) as geonameid FROM places WHERE MATCH (use_code) AGAINST (?) limit 100", intr, intr]
      
      @location= self.find_by_sql ["SELECT *,"+nearest+" FROM cities WHERE " + conditions+ " limit 1 "]
    end
end
