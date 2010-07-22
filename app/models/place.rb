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

  def self.matchtag(level,name,weight)
    if (weight != 1)
      return " MATCH(use_code#{level},loc_code#{level}) against (\"#{name}\" in boolean mode) * #{weight} "
    else
      return " MATCH(use_code#{level},loc_code#{level}) against (\"#{name}\" in boolean mode) "
    end
  end
  # return a list of places supporting tags anywhere, open on ddate
  def self.supportsTags(tags, ddate)
   # tlist = tags.collect { |t| t.name }
    #intr = tlist.join(' ')
    #terms=[]
    sterms=[];
    (0..2).each { |i| sterms[i]={}; }
    # orders=[]
    order=''
    relterms=''
    wterms=[]; wterms1=[];wterms2=[];cond='';
    wcond=[];
    xterms=[]
    begin
      if tags.empty?
        @places = []
        return
      end
      tags.each { |t|
        if (t.parent_id.nil?)
          sterms[1][t.points]=t.name+' '+(sterms[1][t.points]||'')
        #  terms << matchtag(1,t.name,t.points) +" as rel#{t.name}"
          wterms1 << t.name
        else
          sterms[2][t.points]=t.name+' '+(sterms[2][t.points]||'')
        #  terms << matchtag(2,t.name,t.points)+" as rel#{t.name}"
          wterms2 << t.name
        end
        #orders  <<"rel#{t.name}"
      }
     ss=[]
      sterms.each_index{ |i|   # for each level
          sterms[i].each {|p,v|  # for each weight
            reltext = v.delete(' ')[0..8]
            xterms << matchtag(i,v,p)+ " as #{reltext}"
            ss << reltext   # each fulltext match
      }}

      #puts orders.inspect
      #puts "terms: #{xterms.inspect}"
      #puts "ss: #{ss.inspect}"
      #order = "("+orders.join(" + ")+") desc " unless tags.empty?
      order = "("+ss.join(" + ")+") desc " unless ss.empty?
      relterms = xterms.join(", ")+", " unless xterms.empty?
      wcond << matchtag(1,wterms1.join(' '),1) unless  wterms1.empty?
      wcond << matchtag(2,wterms2.join(' '),1) unless  wterms2.empty?
      cond= "(#{wcond.join(' or ')})"
      #puts "relterms #{relterms.inspect}"
      #puts "wcond:#{wcond.inspect}"
	  ddate= Date.today if ddate.blank?
      month=Date.parse(ddate.to_s).mon
      #puts "ddate #{ddate}"
      #depdate = Date.strptime('2010-07-10')
      mcond= ' and (season_'+month.to_s+' is null or season_'+month.to_s+' <> "C" )'

      conditions= ' group by feature_code,use_code ORDER by '+ order
      #puts "QUERY: SELECT *,#{relterms} 0 as cluster,0 as sqdist,count(*) as distance FROM places WHERE #{cond} " + mcond + conditions+" limit 300"

    #conditions= ' group by feature_code,use_code ORDER by geonameid desc'
      @places= self.find_by_sql ["SELECT *,#{relterms} 0 as cluster,0 as sqdist,count(*) as distance FROM places WHERE #{cond} " + mcond + conditions+" limit 300"]
    # @places= self.find_by_sql ["SELECT *,0 as cluster,0 as sqdist,count(*) as distance,MATCH (name,use_code) AGAINST (?) as geonameid FROM places WHERE MATCH (name,use_code) AGAINST (?) " + mcond + conditions+" limit 300", intr, intr]
  rescue
    mcond=""
    puts "Error in function"
    puts tags.inspect
    puts relterms.inspect
  end

end
end
