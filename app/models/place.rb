require 'GeonameDB'
require 'date'
class Place < GeonameDB
  set_table_name 'places'
  set_primary_key :id
 
  #has_many :tags
  #has_many :children, :class_name => "Place", :foreign_key=>:parent_id
  #belongs_to :parent, :class_name=>"Place"
  #def id 
    #return self.attributes['id'].to_s 
  #end
  def season_options
    ["C","L","M", "H"]
  end
   
  # return a list of places supporting tags within miles of lat long, open on ddate
  def self.supportsTagsLoc(tags, lat, lon, miles , ddate)
    tlist = tags.collect { |t| t.name }
    intr = tlist.join(' ')    
    begin
      puts ddate
      month=Date.parse(ddate.to_s).mon
      #depdate = Date.strptime('2010-07-10')

      month= 10; #depdate.mon()
      mcond= ' and (season_'+month.to_s+' is null or season_'+month.to_s+' <> "C" )'
    rescue
      mcond=""
    end
    
    begin 
    offset = miles/(Math.cos((lat*Math::PI/180.0))*69.1).abs;
    lon1= lon- offset;
    lon2= lon+ offset;
    lat1= lat- (miles/69.1);
    lat2= lat+ (miles/69.1);
    nearest= [' 3956 * 2 * ASIN(SQRT(POWER(SIN((latitude - ',
    lat,') * pi()/180/2),2) + COS(latitude * pi()/180) * COS(', lat ,
    ' * pi()/180) * POWER(SIN((longitude -', lon,') * pi()/180/2),2) )) ',
    ' as distance '].join()+','
    
    conditions=[ ' and longitude between ',lon1,' and ',lon2,' and ',
    ' latitude between ', lat1 ,' and ', lat2 ,
    ' group by feature_code,use_code',
    ' having distance < ', miles,
    ' and geonameid > 0 ',
    ' ORDER by geonameid desc, distance asc' ].join()
    rescue
         nearest=""; conditions="";
    end
    #@places= self.find_by_sql ["SELECT *, MATCH (use_code) AGAINST (?) as geonameid FROM places WHERE MATCH (use_code) AGAINST (?) limit 100", intr, intr]
    @places= self.find_by_sql ["SELECT *,0 as cluster,0 as sqdist,"+nearest+" MATCH (name,use_code) AGAINST (?) as geonameid FROM places WHERE MATCH (name,use_code) AGAINST (?) " + mcond + conditions+ " limit 300 ", intr, intr]
  end

  # return a list of places supporting tags anywhere, open on ddate
  def self.supportsTags(tags, ddate)
    tlist = tags.collect { |t| t.name }
    intr = tlist.join(' ')    
    begin
      puts ddate
      month=Date.parse(ddate.to_s).mon
      #depdate = Date.strptime('2010-07-10')

      month= 10; #depdate.mon()
      mcond= ' and (season_'+month.to_s+' is null or season_'+month.to_s+' <> "C" )'
    rescue
      mcond=""
    end
    conditions= ' group by feature_code,use_code ORDER by geonameid desc'
    @places= self.find_by_sql ["SELECT *,0 as cluster,0 as sqdist,count(*) as distance,MATCH (name,use_code) AGAINST (?) as geonameid FROM places WHERE MATCH (name,use_code) AGAINST (?) " + mcond + conditions+" limit 300", intr, intr]
  end
end
