require 'yellowpages'
require 'geocoder_google'
require 'mysql'
require 'logger'
require 'active_support'
require 'net/http'
require 'uri'

#  API to inserting data into Mysql - geonames and rubytravel db
class Importer
  def initialize(preset)
    @places_textfields=%w(name asciiname alternatenames feature_class feature_code feature2_code country_code  street_address city state postal_code phone email  url source open_days hours admin1_code transportation transportation_note note use_code )
    @places_numericfields=%w( geonameid latitude longitude elevation maxelevation hour_start hour_end difficulty distance area howaccessible parent)
    $log = Logger.new("log.#{$0}.txt",'daily') if $log.nil?
    unless (preset.empty? || preset=='N')
      @noclobber=true
    else
      @noclobber=false
    end
    @coder= Geocoder.new("6.s3T.nV34E7G_DUQbuiiTN9Ca7waeaW0E9apk5eM5rTb13FxwVJM9bYTa5ePqvvbFM-");
    @yp=Yellowpages.new();
    begin
      ##### CLIENT_MULTI_RESULTS flag for stored precedures - to support INOUT vars ###
      @dbh = Mysql.real_connect("127.0.0.1", "phoebe", "", "geonames",3306,nil,Mysql::CLIENT_MULTI_RESULTS)
      # otherwise calling a stored procedure gets a "procedure foo() can't return a result set in the given context error", because the CLIENT_MULTI_RESULTS flag is not set by default when the connection is created. 
      puts "Server version: " + @dbh.get_server_info
    rescue Mysql::Error => e
      puts "Error code: #{e.errno}"
      puts "Error message: #{e.error}"
      puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
    ensure
    end
  end

  # Check to see if an URL is valid
  def UrlAvailable?(urlStr)
    if ( urlStr.nil? || urlStr.empty? ) then return false; end
    urlStr =  urlStr.to_s
    if urlStr =~ /(^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5})/
      urlStr = "http://"+urlStr;
    end
    return false unless urlStr =~ /^(http|https):\/\/([a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}|(25[0-5]|2[0-4]\d|[0-1]?\d?\d)(\.(25[0-5]|2[0-4]\d|[0-1]?\d?\d)){3}|localhost)(:[0-9]{1,5})?(\/.*)?$/ix

    begin
      url=URI.parse(urlStr.to_s)
      url.path='/' if url.path.empty?
      nethttp = Net::HTTP.new( url.host, url.port )
      nethttp.open_timeout = 3
      nethttp.read_timeout = 3
      res = nethttp.start() {|http|
        http.head(url.path)
      }
      case res
      when Net::HTTPSuccess, Net::HTTPRedirection
        return true;
      else
        return false;
      end
      #res = Net::HTTP.get_response(URI.parse(urlStr.to_s))
      #return (res.code =~ /2|3\d{2}/ );
    rescue URI::InvalidURIError => e
      puts "UrlAvailable: InvalidURIError #{e.inspect}  - #{urlStr}"
    rescue Timeout::Error    # regular rescue only deals with stderr
      puts "UrlAvailable: Timeout 404 - #{urlStr}"
      return false; #assume the worse
    rescue SystemCallError
      puts "UrlAvailable:System Error - #{urlStr}"
      return false; #assume the worse
    rescue OpenURI::HTTPError
      puts "UrlAvailable:Cannot open [#{url}]"
      return false; #assume the worse
    rescue Exception => e
      puts "UrlAvailable:Error open [#{url}]"
      return false; #assume the worse
    end
  end

  # disconnect from server
  def close
    @dbh.close if @dbh
  end

  def findWeather(par={})
    return nil if ( par.nil?)
    code = findAddress(par) if par['geonameid'].nil?
    #puts " Found #{code} in findWeather/address "
    return nil if ( code.nil?) 
    return nil if ( par['geonameid'].nil?) 
    wid=nil;
    q = 'select * from weatherInfo where id = '+par['geonameid']
    begin
      res=@dbh.query(q);
      if (res.num_rows > 0)
        res.each_hash { |row| 
          wid=row['id']
          par['id']= row['id']
        }
      end
    rescue Mysql::Error => e # regular rescue only deals with stderr
      puts "Error message: findWeather ( #{e.errno} ) #{e.error}"
    end
    res.free unless res.nil?
    return wid
  end

  # clim is a hash of months and maxc,minc,rain in mm
  def insertWeather( clim, par)
    id= findWeather(par)
    unless id.nil? #  already inserted
      puts " already inserted "+par.inspect 
      return
    end
    fields=""; values=""
    total_m = 0 # missing months - can you believe it?
    total_min=0; 
    total_max=0;
    incomplete = false;
    (1..12).each { |m|
      unless (clim[m].nil?)
        fields = fields+ ',avg_'+m.to_s+'_min_temp, avg_'+m.to_s+'_max_temp, avg_' +m.to_s+'_rainfall_mm' 
        values = values+ ','+ clim[m]['minc'].to_s + ',' + clim[m]['maxc'].to_s + ','+ (clim[m]['rain'].to_s)
        unless (clim[m]['rday'].nil?)
          fields = fields+ ',avg_'+m.to_s+'_raindays' 
          values = values+ ','+ clim[m]['rday'].to_s 
        end
        total_min= total_min + (clim[m]['minc']).to_f
        total_max= total_max + (clim[m]['maxc']).to_f
        total_m= total_m+1
      else
        incomplete = true;
      end
    }
    if (par['geonameid'].blank?)  then code=" ### " else code = par['geonameid'].to_s end
    q= 'insert into weatherInfo ( id,average_max_temp,average_min_temp'+ fields+') values (' + code+','+ (total_max/total_m).to_s+','+(total_min/total_m).to_s+values+')';
    unless par['geonameid'].blank? || incomplete
      insertIntoDB(q)
      puts "insert #{code} OK"
    else
      puts 'incomplete' if incomplete 
      $log.error( code +"### can't find "+ par.inspect );
      puts q;
      $log.error(q);
    end
  end

  def findAdminCode(par,level)
    return nil if ( par['state'].nil? || par['state'].empty? )  # nothing to look up
    code=''
    level=level.to_s  # so that both int and string are supported
    #puts "findadmin="+par.inspect
    if ( !par['country'].blank? && par['country_code'].blank? )
      par['country_code'] = findCountry(par['country'])
    end
    q="select * from admin"+level+' where name = "'+ par['state'] +'"'
    q=q+' and code like "'+par['country_code']+'.%"' unless (par['country_code'].blank? )
    name=par['state'];
    begin
      res=@dbh.query(q);
      if (res.num_rows == 1)
        res.each_hash { |row| 
          printf "%s)  %s %s %s\n", row['code'], row['name'], row['asciname'], row['geonameid'] 
          code = par['admin'+level+'_code']= row['code'].split('.')[1]
        }
      end
    rescue Mysql::Error => e # regular rescue only deals with stderr
      puts "Error message: findAdminCode ( #{e.errno} ) #{e.error}"
    end
    res.free unless res.nil?
    return code
  end

  # runs a query with no resultset
  def insertIntoDB(q)
    begin
      res = @dbh.query(q);
    rescue Mysql::Error => e
      $log.error("Error message: ( #{e.errno} ) #{e.error} ")
      puts "Error message: ( #{e.errno} ) #{e.error} "
      puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
      return false;
    end
    return true;
  end

  def findClosestCity( lat, lon)
    query="call geonames.fieldswithinRadiuswithConds('geonameid,name,admin1_code,admin2_code,latitude,longitude','feature_code','PPL'," + lat.to_s + ',' + lon.to_s + ',5.0);'
    query="call geonames.fieldswithinRadius('geonameid,name,admin1_code,admin2_code,latitude,longitude'," + lat.to_s + ',' + lon.to_s + ',5);'
    query="call geonames.withinRadius(" + lat.to_s + ',' + lon.to_s + ',1);'
    puts query
	rs=[]
	no_more_results=false
    @dbh.query_with_result=false
    @dbh.query(query);
	until no_more_results
		begin
			res= @dbh.use_result
		rescue 
			no_more_results=true
			@dbh.query_with_result=true
		ensure
		end
		if !no_more_results
			rs= rs+res
          res.each { |row|
            puts row.inspect
          }
		#res.free
        end
    end
	return rs
  end

  # finds a country code from geonames db
  def findCountry(name)
    code=nil
    name=name.to_s.strip
    begin
      q = 'select * from countryInfo where country like "'+name.to_s+'" ' 
	  puts q
      res = @dbh.query(q);
      if (res.num_rows == 1)
        res.each_hash { |row|
          code= row['iso']
        }
      else
        q = 'select * from allCountries where alternatenames="'+name+'" or alternatenames like "'+ name+',%" or alternatenames like "%,'+ name +',%" or alternatenames like "%,'+ name +'" and feature_code like "PCL%" '
	  puts q
        res = @dbh.query(q);
        if (res.num_rows >= 1)
          res.each_hash { |row|
            code= row['country_code']
          }
        else
          q = 'select * from allCountries where alternatenames="'+name+'" or alternatenames like "'+ name+',%" or alternatenames like "%,'+ name +',%" or alternatenames like "%,'+ name +'" and feature_code like "ISL%" '
	  puts q
          res = @dbh.query(q);
          if (res.num_rows == 1)
            res.each_hash { |row|
              code= row['country_code']
            }
          end
        end
      end
    rescue Mysql::Error => e
      puts "Error message: findCountry(#{q}) ( #{e.errno} ) #{e.error} "
    rescue 
      puts "Error in ( findCountry(#{name.inspect}) "
    end
    return code
  end

  # Fills in the details in par when found
  def findCity(par,options={})
    #puts("findCity: "+ par.inspect)
    if ( !par['country'].blank? && par['country_code'].blank? )
      puts("findCity: Lookup country code ")
      par['country_code'] = findCountry(par['country'])
    end
    if par['country_code'].blank?
      puts("findCity: Missing country code ")
      $log.error("findCity: Missing country code")
      return nil
    end
    if par['city'].blank?
      puts("findCity: Missing city name ")
      $log.error("findCity: Missing city name ")
      return nil
    end
    q='select country_code,admin1_code,admin2_code,feature_code,asciiname,geonameid from allCountries where '
    if ( options['alt'].blank? )
      q=q+' name = "'+ par['city']+'" '
    else    # check alternate names
      q = q +' ( alternatenames="'+par['city']+'" or alternatenames like "'+par['city']+',%" or alternatenames like "%,'+par['city']+',%" or alternatenames like "%,'+par['city']+'" ) '
    end
    q=q+' and feature_code like "PPL%" '
    q=q+" and country_code='"+par['country_code']+"'" unless ( par['country_code'].blank?)
    q=q+" and admin1_code='"+par['admin1_code']+"'" unless ( par['admin1_code'].blank? )
    q=q+" order by feature_code, population desc "
    code=nil;
    begin
      res = @dbh.query(q);
      h= Hash.new
      res.each_hash { |row| 
        if (res.num_rows == 1)    # found it - done
          par['admin1_code']= row['admin1_code']
          par['admin2_code']= row['admin2_code']
          par['geonameid']= row['geonameid']
          code=par['geonameid']
        else
          if (h[ row['feature_code'] ].blank? )   # Take the first of each feature code
            h[ row['feature_code'] ] = row
          end
        end
      }
      if ( code.blank? ) # more than 1
        %w(PPLC PPLA PPL PPLX).each { |f|   # in order of preference
          if ( !h[f].blank?) 
            par['admin1_code']= h[f]['admin1_code']
            par['admin2_code']= h[f]['admin2_code']
            par['geonameid']= h[f]['geonameid']
            code = par['geonameid']
            break;
          end
        }
      end
    rescue Mysql::Error => e
      puts "Error message: findCity(#{q}) ( #{e.errno} ) #{e.error} "
      $log.error( "Error message: findCity(#{q}) ( #{e.errno} ) #{e.error} ")
    rescue 
      puts "Error in ( findCountry(#{name.inspect}) "
    end
    res.free unless res.nil?
    return code 
  end

  def findAddress(par, options={})
    h=Hash.new
    arr = Array.new
    code="";
    if ( !par['country'].blank?  && par['country_code'].blank? )
      par['country_code'] = findCountry(par['country'])
    end
    unless par['state'].blank?
      code= findAdminCode( par,1) # find admin1 code
    end
    unless ( par['latitude'].blank? && par['longitude'].blank? )
      #puts findClosestCity( par['latitude'] , par['longitude'] )
    end
    unless ( code.nil? &&  !par['city'].blank? )
      code = findCity( par)    # larger city more likely
      h['alt']=par['city'];    # us alternate names
      code = findCity( par, h) if code.nil?    # go fishing for anything
      #puts "City Code= #{code}"
    end
    return code;
  end

  def resetAddress(h,level)
    if (level=='country' || level =='city' || level=='state')
      h.delete('geonameid')
      h.delete('id')
      h.delete('city')
    end
    if (level=='state' || level =='country')
      h.delete('admin1_code')
      h.delete('admin2_code')
      h.delete('state')
    end
    if (level=='country')
      h.delete('country')
      h.delete('country_code')
    end
  end

  # unique index on name-city
  def recordExists?(par)
    return findRecord(par)!= 0 
  end

  def fetchRecord(par)
    if (( par['name'].blank? && par['city'].blank? ) && par['id'].blank? )
      puts "fetchRecord id or ( name and city ) is missing"
      # throw exception
      return nil
    end
    begin
      str=""
      %w(name city).each { |f|
        str= str + " and "+f+'="'+ @dbh.escape_string(par[f])+'"' if (!par[f].blank? )
      }
      str= str + ' and id ='+ par['id'].to_s if (!par['id'].blank? )
      q= 'select * from places where '+ str[4,1000]
      puts q
      res= @dbh.query(q)
      # res.each_hash { |k,v| puts " #{k} #{v} " }
      return res.fetch_hash;
    rescue Mysql::Error => e
      puts "Error message: ( #{e.errno} ) #{e.error}"
      puts "Error in checking for existance of #{ par['name'] }"
      res.free unless res.nil?
      return nil; #assume the worse
    end
    return nil; #assume the worse
  end

  def fixAddress
	#some addresses are bad from museum imports
	q='select street_address,city, state,postal_code, country_code,id from places where  street_address like "%http://%"';
	res= selectquery(q)
	res.each { |d|
		if d[0] =~ /(\S.*\S)\s*(http:\S+)/
			q= "update places set street_address='#{  @dbh.escape_string($1) }' where id=#{d[5]};"
			insertIntoDB(q)
			aa="#{$1},#{d[1]},#{d[2]} #{d[3]},#{d[4]}";
			puts aa
			ans= @coder.glookup(aa)
			q2='update places set latitude='+ ans['lat'].to_s+', longitude='+ ans['lon'].to_s+' where id ='+ d[5];
			puts q2
			insertIntoDB(q2)
			sleep 1
		end
	}
  end

  def fixCoord
	q="select street_address, city, state,postal_code, country_code, id,name from places where longitude is null and street_address is not null ";
	res= selectquery(q)
	res.each { |d|
		puts d.inspect
		ans= @coder.lookup(d[0],d[1],d[2],d[3],d[4]);
		q2='update places set latitude='+ ans['lat'].to_s+', longitude='+ ans['lon'].to_s+' where id ='+ d[5];
		puts q2
		insertIntoDB(q2)
		sleep 1
	}
  end

  def selectquery(q)
    begin
      res= @dbh.query(q)
      return res; #.fetch_hash;
    rescue Mysql::Error => e
      puts "Error message: ( #{e.errno} ) #{e.error}"
      puts "Error in checking for existance of #{ par['name'] }"
      res.free unless res.nil?
      return nil; #assume the worse
    end
    return nil; #assume the worse
  end

  def findRecord(par)
    #puts "fetch  #{par.inspect}"
    str=""
    if ( par['name'].blank? || par['city'].blank? )
      puts "findRecord name or city is missing"
      # throw exception
      return 0
    end
    begin
      q= 'select id from places where name= "'+par['name']+'" and city= "'+par['city']+ '"'
      puts "FindRecord: #{q}"
      res= @dbh.query(q)
      res.each_hash { |row| 
        return row['id']
        #puts "ROW= #{row.inspect}"
      }
    rescue Mysql::Error => e
      puts "Error message: ( #{e.errno} ) #{e.error}"
      puts "Error in checking for existance of #{ par['name'] }"
      res.free unless res.nil?
      return 0; #assume the worse
    end
    return 0; #assume the worse
  end

  # US only
  def locationExists?(h)
    str=""
    %w(name country_code ).each { |f|
      str= str + f+' = "'+@dbh.escape_string(h[f])+ '" and ' unless h[f].blank?
    }
    f=state
    str= str+' admin1_code = "'+@dbh.escape_string(h[f])+ '" and ' unless h[f].blank?
    q='select * from allCountries where ' + str +' feature_code like "PPL%"'
    begin
      res= @dbh.query(q)
      unless res.nil?
        return res.fetch_hash;
      end
    rescue Mysql::Error => e
      puts "Error message: ( #{e.errno} ) #{e.error}"
      puts "Error in checking for existance of #{ par['name'] }"
      res.free unless res.nil?
      return 0; #assume the worse
    end
    #q='select * from allCountries where alternatename like "%'+ @dbh.escape_string(name)+'%" and feature_code like "PPL%"'
    #res= @dbh.query(q)
    return nil
  end

  def nameExists?(name)
    begin
      res= @dbh.query( 'select id from places where name="'+name+'"')
      return (res.num_rows == 1)
    rescue Mysql::Error => e
      puts "Error message: ( #{e.errno} ) #{e.error}"
      puts "Error in checking for existance of #{name}"
      return false; #assume the worse
    end
  end
=begin
  print "Number of rows: %d\n", res.num_rows
 printf "Number of columns: %d\n", res.num_fields
res.fetch_fields.each_with_index do |info, i|
printf "--- Column %d (%s) ---\n", i, info.name
printf "table:            %s\n", info.table
printf "def:              %s\n", info.def
printf "type:             %s\n", info.type
printf "length:           %s\n", info.length
printf "max_length:       %s\n", info.max_length
printf "flags:            %s\n", info.flags
printf "decimals:         %s\n", info.decimals
end
res.free
=end

  def yplookup(par, options={})
    return nil if ( !par['country_code'].blank? && par['country_code'] != 'US' ) # only in US
    # Do the actual lookup by name,city,state
    if ( !par['name'].blank? &&  !par['city'].blank? && !par['state'].blank? ) # must have state or city
      arr= @yp.lookup( par['name'], par['city'], par['state'] , options);
    elsif ( !par['name'].blank? &&  !par['state'].blank? ) # must have state and name
      arr= @yp.lookup( par['name'], "", par['state'], options );
    else
      $log.error( "yplookup: needs name, state and city")
      puts "Need name, state and city";
      return nil
    end

    if (par['source'].nil?) then source='YPS' else source=par['source'] end
    url= par['url']
    if ( arr.nil? ) 
      puts "YP results for #{par['name']}"
      return nil;
    elsif ( arr.length == 0 || arr.length > 2 ) 
      puts "YP No real results (#{arr.length.to_s}) for lookup #{par['name']}"
      return nil;
    else
      puts " #{arr.length.to_s} results "
    end
    urlok= false;
    arr.each { |h|  
      unless ( url.blank? )
        if ( h['url'].blank? )
          h['url']= url
        elsif ( h['url'].casecmp( url )!=0 )
          puts "URL mismatch #{url} != #{h['url']} "
          if (UrlAvailable?(h['url']))
            urlok=true;
          elsif (UrlAvailable?(url))
            h['url']=url;
            urlok=true;
          else
            h['url']=nil;
          end 
        end
      end
      if ( !urlok && !h['url'].nil? && !UrlAvailable?(h['url']))
        puts "#{h['url']} does not return 200 ";
        h['url']=nil;
      end      
      if (h['state'].nil? && par['state'].nil? )
        puts "WHAT THE F!!! State missing!"
        puts "H= #{h.inspect} = PARAMS= #{par.inspect}"
        return nil
      end
      # fill in all the blanks from the input hash
      @places_textfields.each { |k|  h[k]=par[k] if  ( h[k].blank?  &&   !par[k].blank? )      }
      @places_numericfields.each { |k| h[k]=par[k] if  ( h[k].blank?  &&   !par[k].blank? ) }
      h['feature_class']='S'  # all buildings
      h['source']=source
      h['state'].upcase!
      h['country_code']='US'
      puts  "YP found #{h['name']} #{ h['city']}"
      return h unless ( h['name'].empty? )  # Takes the first one on the list
      #end
    }
  end

  def fillCoord(h)
    coord= @coder.lookup( h['street_address'], h['city'], h['state'], h['postal_code'],h['country_code']);
    unless coord.blank?
      h['latitude'] = coord['lat'].to_s;
      h['longitude'] = coord['lon'].to_s;
      return true
    end
    return false
  end

  def insertPlaceIntoDB(h)
    return false if ( h.blank? ||  h['name'].blank? )  # no name
    # no address or URL
    return false if ( h['city'].blank? &&  h['state'].blank? && h['url'].blank? )
    if  ( h['street_address'].blank? )
      puts "InsertintoDB: #{h['name'] } has no street address "
    end
    fieldlist=" created_at"
    valuelist= ') values ( current_timestamp()'
    unless ( h['country_code'] !='US' &&  h['state'].blank? ) # nonUS needs a lookup
      fieldlist=fieldlist+",admin1_code"
      valuelist=valuelist+',"'+h['country_code']+"."+h['state'].upcase+'"'
    end
    ['latitude','longitude'].each { |f|
      unless h[f].blank? 
        fieldlist=fieldlist+','+f;
        valuelist=valuelist+ ','+ @dbh.escape_string( h[f] )
      end
    }
    #  ['name','street_address','city','email','state','postal_code','hours','phone','url','source','feature_class','feature_code','country_code'].each { |f|
    @places_textfields.each{ |f|
      unless h[f].blank?
        fieldlist=fieldlist+','+f;
        valuelist=valuelist+ ',"'+ @dbh.escape_string( h[f] ) + '"'
      end
    }
    begin
      puts 'insert into places ('+fieldlist+valuelist+')'
      @dbh.query( 'insert into places ('+fieldlist+valuelist+')' )
    rescue Mysql::Error => e
      puts "Error message: ( #{e.errno} ) #{e.error}"
      puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
      return false;
    end
    return true;
  end

  def enterIntoDB( h, options={}) 
    if recordExists?(h)
      puts "Record already exists for #{h['name']} #{ h['city']} ";
    else
      reallyEnterIntoDB( h, options) 
    end
  end

  def reallyEnterIntoDB( h, options={}) 
    #begin
      soft=false
      unless options.blank?
        soft= !options['soft'].blank?
      end
      return if h['name'].blank? || h['city'].blank?
      puts "LOADING= #{h['name']} #{ h['city']} "
      add=h
      unless UrlAvailable?(h['url'])
        h.delete('url')
      end
      if (!add.blank? )
        fillCoord(add)  # found the coords
        sleep(1) if insertPlaceIntoDB(add)
      elsif ( !h['url'].blank? && !h['city'].blank? && !h['name'].blank? && soft )
        puts  " name/city/url is good enough #{h['name']} #{ h['city']} #{h['url']} "
        if (!h['street_address'].blank? && !h['city'].blank? && !h['state'].blank? ) # has address
          unless ( fillCoord(h)==nil   )  # if address is bad, don't insert
            sleep(1) if insertPlaceIntoDB(h)
          end
        else  # missing street address, but has city and valid url 
          sleep(1) if insertPlaceIntoDB(h)
        end
      else
        "Fail to insert #{h['name']} #{ h['city']}"
      end
    #rescue => e
      #puts "Error: importer::enterIntoDB #{h['name']} "
    #end
  end

  # compare 2 hashes return the diff
  def compareHashes(h,rec, options={} )
    diff = Hash.new
    mode=0    # default, any additional details
    if !options.blank? 
      mode=0 if options['mode']=='add'    # in h, but not in rec, ignore null
      mode=1 if options['mode']=='sub'    # in rec, but not in h, ignore null
      mode=2 if options['mode']=='diff'   # diff btw h and rec incl nulls
    end
    if mode == 1          # use only when empty in rec and different
      rec.each { |k,v|
        diff[k]=h[k] unless v.blank? || (!h[k].blank? && v.to_s.casecmp( h[k].to_s )) == 0
      }
    elsif mode == 2       # use data in h if different in rec
      rec.each { |k,v|
        diff[k]=h[k] unless  h[k] == v || (!h[k].blank? && !v.blank? && v.to_s.casecmp( h[k].to_s ) == 0) 
      }
    else                  # use data in h when different or missing in rec
      rec.each { |k,v|
        #puts " compare #{k} #{h[k]} to #{v} "
        diff[k]=h[k] unless h[k].blank? || (!v.blank? && h[k].to_s.casecmp( v.to_s ) ==0 )
      }
    end
    return diff
  end

  def comparePlaceInDB(h, options={} )
    rec= fetchRecord(h)  # find old record
    diff = compareHashes(h, rec, options)  # is it changed?
    # address changed
    overload= !options.blank? && !options['overload'].blank?   # do we write over with lookup
    #puts " DIFF= #{diff.inspect}"
    unless diff['street_address'].blank? &&  diff['city'].blank? &&  diff['state'].blank? # new address ? 
      h2=h.dup
      if !overload 
        add= yplookup(h2, options)   # do a lookup in yellow pages to check address
        unless add.blank?     # new address looked up ? 
          diff = compareHashes(h2, rec, options) # compare again
          #puts " DIFF2= #{diff.inspect}"
          unless diff['street_address'].blank? &&  diff['city'].blank? &&  diff['state'].blank? #still different
            fillCoord(h2) 
          end
        end
      else
        fillCoord(h2) 
        %w(longitude latitude).each { |f|       diff[f]=h2[f] unless h2[f].blank}
      end
    end

    diff['id']=rec['id']  # need key to proceed
    return diff
  end

  # check first - add new fields only when not null, preserve old data
  def InsertorUpdatePlaceInDB(h, options={})
    return if h.blank?
    h.each{|k,v|
      v.chomp!(',') #  hate those trailing commas
    }
    known= false;
    puts h.inspect
    if recordExists?(h) # found right away
      known=true
      add=h
    else          #  do a look up
      h2= h.dup
      add= yplookup(h2, options)   # do a lookup in yellow pages to check address
      if ( add.blank? )
        if h2['city'].blank?
          h2.delete("city")
          sleep 1;
          add= yplookup(h2, options)   # bad address?
        end
      end
      if add.blank?   # try again without city
        add=h
      else
        known= recordExists?(add)  #  new address already entered
      end
    end
    if known
      fields = comparePlaceInDB(add) # returns id and all fields that are different
      unless fields.size == 1   #only the key
        updatePlaceInDB(  fields ,options)
      end
    else
      reallyEnterIntoDB( add, options ) 
    end
  end

  # replaces what's in the db with only the fields in h, do not blank out missing fields
  def updatePlaceInDB(h,options)
    return false if ( h.blank? ||  h['id'].blank? )  # no id

    if h['id'].blank?
      id= findRecord(h) 
    else
      id = h['id']
    end
    str="set"
    @places_textfields.each{ |f|
      str= str + " "+f+'="'+ @dbh.escape_string( h[f] )+'",' unless ( h[f].blank? )
    }
    @places_numericfields.each{ |f|
      str= str + " "+f+'='+ @dbh.escape_string( h[f].to_s )+',' unless ( h[f].blank? )
    }
    str.chomp!(',')
    begin
      q= 'update places '+str+' where id ='+id
      puts q
      @dbh.query( q)
    rescue Mysql::Error => e
      puts "Error message: ( #{e.errno} ) #{e.error}"
      puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
      return false;
    end
    return true;
  end

  def setSeason( code, months, criteria)
    mlist=" set "
    months.each { |m|
      mlist= mlist+' season_'+m.to_s+'= "'+code.to_s+'",'
    }
    mlist= mlist.chop;
    begin
      q='select count(*) from  places where '+criteria 
      res=@dbh.query(q);
      res.each_hash { |row| 
        puts "ROW= #{row.inspect}"
      }
      q='update places'+mlist+' where '+criteria 
      puts q
      @dbh.query( q);
    rescue Mysql::Error => e
      puts "Error message: ( #{e.errno} ) #{e.error}"
      puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
      return false;
    end
  end

end

def test
  p= Importer.new('')
  #p.test
  puts p.nameExists?('Piece of  Crap')
  puts p.nameExists?('Loxton Cellars')
  url='http://www.loxtoncellarss.scom'
  if  ( p.UrlAvailable?(url))
    puts 'OK'
  end
end

def testinsert
  h= Hash[ 'name'=>'Altiero',
  'street_address'=>'Via San Cresci, 58',
  'city'=>'Greve in Chianti',
  'state'=>'Tuscany',
  'source' => 'CDV',
  'feature_code' => 'WINE',
  'phone'=>'+39 055 85 37 28',
  'elevation'=> 400,
  'country_code'=>'IT']
  york= {"city"=>"Yorkville,", "name"=>"Yorkville Cellars", "country_code"=>"US", "postal_code"=>"95494", "feature_code"=>"WINE", "street_address"=>"25701 Highway 128", "phone"=>"(707) 894-9177", "hours"=>"Tasting: Open daily 11 to 6 pm, winter 11 to 5pm Complimentary Tasting 5% off 6-11 bottles, 10% off case", "source"=>"CWA", "state"=>"CA"}
  hadley={"city"=>"Philo,", "name"=>"Handley Cellars", "country_code"=>"US", "postal_code"=>"95466", "feature_code"=>"WINE", "street_address"=>"3151 Highway 128", "phone"=>"800.733.3151", "hours"=>"VIP Tasting: Yes", "source"=>"CWA", "state"=>"CA"}
  schaf={"city"=>"Philo,", "name"=>"Scharffenberger Cellars", "country_code"=>"US", "postal_code"=>"95466", "feature_code"=>"WINE", "street_address"=>"8501 Highway 128", "phone"=>"(800) 824-7754", "hours"=>"Tasting: Open 11 to 5 pm daily Tasting fee $3 credited with purchase 5% off 6-11 bottles, 10% off case", "source"=>"CWA", "state"=>"CA"}
  rtv= {"city"=>"Carmel Valley", "name"=>"Robert Talbott Vineyards", "country_code"=>"US", "postal_code"=>"93924", "feature_code"=>"WINE", "street_address"=>"53 West Carmel Valley", "phone"=>"(831) 659-3500", "hours"=>"Tasting: Open 11-5 pm daily Tasting fee $8.50 10% case discount", "source"=>"CWA", "state"=>"CA"}

  zd= {"city"=>"Napa,", "name"=>"ZD Wines", "country_code"=>"US", "postal_code"=>"94558", "feature_code"=>"WINE", "street_address"=>"8383 Silverado Trail", "phone"=>"(707) 963-5188", "hours"=>"Tasting: Daily 10:30-4:30 pm $10 and $15 plus VIP tasting programs 15% case discount", "source"=>"CWA", "state"=>"CA"}
  august= {"city"=>"Calistoga,", "name"=>"August Briggs", "country_code"=>"US", "postal_code"=>"94515", "feature_code"=>"WINE", "street_address"=>"333 Silverado Trail", "phone"=>"(707) 942-4912", "hours"=>"Tasting: Open daily 10 to 4:30 pm Complimentary Tasting 10% case discount", "source"=>"CWA", "state"=>"CA"}

  h= Hash[ 'name'=>'Fiasco Winery',
  'street_address'=>'8035 Hwy 238',
  'city'=>'Jacksonville',
  'state'=>'OR',
  'source' => 'ORW',
  'feature_code' => 'WINE',
  'hours'=> 'Daily 11-5 pm',
  'phone'=>'(541) 899.9645',
  'country_code'=>'US']
  p= Importer.new('')
  p.InsertorUpdatePlaceInDB(rtv, {'overload'=>true,'soft'=>true})
  p.InsertorUpdatePlaceInDB(zd, {'overload'=>true,'soft'=>true})
  p.InsertorUpdatePlaceInDB(hadley, {'overload'=>true,'soft'=>true})
  p.InsertorUpdatePlaceInDB(august, {'overload'=>true,'soft'=>true})
end

def test1
  h= Hash[ 'name'=>'NOT there Airlie Winery',
  'street_address'=>'15305 Dunn Forest Rd.',
  'city'=>'Monmouth',
  'state'=>'OR',
  'source' => 'ORW',
  'feature_code' => 'WINE',
  'country_code'=>'US']
  p= Importer.new('')
  rec= p.fetchRecord(h)
  if rec.nil?
    puts " no such record #{h['name']} "
    return
  end
  rec.each { |k,v|
    puts "[ #{k} =  #{v}  or  = #{ h[k] } ]"
  }
  arr = p.comparePlaceInDB(h)
  str= " add "
  arr.each { |k| str=str+" #{k} ," }
  puts str
  arr = p.comparePlaceInDB(h, {"mode"=>"sub"})
  str= " sub "
  puts str
  arr.each { |k| str=str+" #{k} ," }
  arr = p.comparePlaceInDB(h, {"mode"=>"diff"})
  str= " dif "
  arr.each { |k| str=str+" #{k} ," }
  puts str
  p.updatePlaceInDB(h)
=begin
  add= p.yplookup(h)
  p.fillCoord(add)
  puts add.inspect
  puts "OK" if p.insertintoDB(add)

h={"city"=>"Honolulu", "country_code"=>"US", "admin1_code"=>"HI", "country"=>"United States of America", "state"=>"Hawaii"}
cc = p.findCity(h)
puts "findCity #{cc} #{h.inspect}"
h={"city"=>"Allentown", "country_code"=>"US", "admin1_code"=>"PA", "country"=>"United States of America", "state"=>"Pennsylvania"}
puts "findCity #{cc} #{h.inspect}"
h={"city"=>"gangneung", "country_code"=>"KR"}
options={'alt'=>true}
cc=p.findCity(h,options)
=end
end


def test_url
  p= Importer.new('')
  # one.dom
  %w( http://www.amwellvalleyvineyard.com/  http://www.plumcreekwinery.com http://www.chiff.com/wine/winery.htm  http://www.target.com/gp/detail.html/602-4045909-4263801?ASIN=B000NPCK3W&AFID=Froogle&LNM=B000NPCK3W|Lexmark_AllInOne_Printer_with_Scanner_and_Copier__X1240&ci_src=14110944&ci_sku=B000NPCK3W&ref=tgt_adv_XSG10001 http://www.domain.com one.dom ).each { |url|
    puts url
    puts 'OK' if (p.UrlAvailable?(url))
  }
end

def fixbaddata
  p= Importer.new('')
  #p.fixAddress
  p.fixCoord
end
#test_url
#testinsert
#test1
=begin
p= Importer.new('')
h= Hash['city'=>"Milan",'country'=>'Italy']
puts p.findAddress(h)
dd= p.findClosestCity( h['latitude'] , h['longitude'] ) if ! h['latitude'].nil?
dd.each { |r| puts r.inspect } unless dd.nil?
=end
