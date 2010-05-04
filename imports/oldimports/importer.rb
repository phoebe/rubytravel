require 'yellowpages'
require 'geocoder'
require 'mysql'
require 'logger'
require 'active_support'
require 'net/http'
require 'uri'


# # advisories for every state
# http://www.weather.gov/alerts-beta
#
# # climate/ weather data
# http://worldweather.wmo.int/186/c01234.htm
class Importer
  def initialize(preset)
    $log = Logger.new("log.#{$0}.txt",'daily') if $log.nil?
    unless (preset.empty? || preset=='N')
      @noclobber=true
    else
      @noclobber=false
    end
    @coder= Geocoder.new("6.s3T.nV34E7G_DUQbuiiTN9Ca7waeaW0E9apk5eM5rTb13FxwVJM9bYTa5ePqvvbFM-");
    @yp=Yellowpages.new();
    begin
      #@dbh = Mysql.new('localhost', 'phoebe', '', 'geonames')
#####   NOTE THE CLIENT_MULTI_RESULTS for stored precedures - to support INOUT vars ###
      @dbh = Mysql.real_connect("127.0.0.1", "phoebe", "", "geonames",3306,nil,Mysql::CLIENT_MULTI_RESULTS)
      # calling a stored procedure gets a "procedure foo() can't return a result set in the given context error", because the CLIENT_MULTI_RESULTS flag is not set by default when the connection is created. 

      puts "Server version: " + @dbh.get_server_info
    rescue Mysql::Error => e
      puts "Error code: #{e.errno}"
      puts "Error message: #{e.error}"
      puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
    ensure
      # disconnect from server
      #@dbh.close if @dbh
    end
  end

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
          #puts "ROW= #{row.inspect}"
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
    begin
      #@dbh.query_with_result=false
      res = @dbh.query(query);
      puts " Results has #{ res.num_rows.to_s } rows "
    rescue Mysql::Error => e
      puts "Error message: ( #{e.errno} ) #{e.error} "
    ensure
      @dbh.query_with_result=true
    end
      no_more_results=false
    until no_more_results 
      begin
          res= @dbh.use_result
          puts " Results has #{ res.num_rows.to_s } rows "
      rescue Mysql::Error => e 
          no_more_results=true
          #@dbh.query_with_result=true
      ensure
          #@dbh.query_with_result=true
      end 
      if no_more_results
          if (res.num_rows >= 1)
            res.each { |row|
              puts row.inspect
            }
          end
        res.free
      end
    end
  end


  def findCountry(name)
    code=nil
    name=name.to_s.strip
    begin
      q = 'select * from countryInfo where country like "'+name.to_s+'" ' 
      res = @dbh.query(q);
      if (res.num_rows == 1)
        res.each_hash { |row|
          code= row['iso']
        }
      else
        #q = 'select * from allCountries where alternatenames like "%'+name.to_s+'%" and feature_code like "PCL%" ' 
        q = 'select * from allCountries where alternatenames="'+name+'" or alternatenames like "'+ name+',%" or alternatenames like "%,'+ name +',%" or alternatenames like "%,'+ name +'" and feature_code like "PCL%" '
        res = @dbh.query(q);
        if (res.num_rows >= 1)
          res.each_hash { |row|
            code= row['country_code']
          }
        else
          #q = 'select * from allCountries where alternatenames like "%'+name.to_s+'%" and feature_code like "ISL%" ' 
          q = 'select * from allCountries where alternatenames="'+name+'" or alternatenames like "'+ name+',%" or alternatenames like "%,'+ name +',%" or alternatenames like "%,'+ name +'" and feature_code like "ISL%" '
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
  def findCity(par,arr,options={})
      if ( !par['country'].blank? && par['country_code'].blank? )
          par['country_code'] = findCountry(par['country'])
      end
      q= 'select country_code,admin1_code,admin2_code,asciiname,geonameid from allCountries where name like "'+ par['city']+'"'
      if ( !options.empty?  && (!options['largecity'].nil? && options['largecity']))
        q = q +' and feature_code = "PPLC" '
      elsif ( !options.empty?  && !options['feature'].nil?) # such as ISL%
        q = q +' and feature_code like "'+options['feature']+'" '
      elsif ( !options.empty?  && !options['alternatenames'].nil?) # use alternatenames
        #q = q +' and ( alternatenames="'+options['city']+'" or alternatenames like "%'+options['city']+',%" or alternatenames like "%,'+options['city']+'%") '
        q = q +' and ( alternatenames="'+options['city']+'" or alternatenames like "'+options['city']+',%" or alternatenames like "%,'+options['city']+',%" or alternatenames like "%,'+options['city']+'" ) '
      elsif ( !options.empty?  && !options['any'].nil?)
        # take any feature - don't add any constraints
      else
        q = q +' and feature_code like "PPL%" '
      end
      q =q+" and country_code='"+par['country_code']+"'" unless ( par['country_code'].nil? or par['country_code'].empty?)
      q= q+" and admin1_code='"+par['admin1_code']+"'" unless ( par['admin1_code'].nil? or par['admin1_code'].empty?)
      q=q+" order by feature_code, population desc "
      code=nil;
    begin
      puts q
      res = @dbh.query(q);
      if (res.num_rows >= 1)
          res.each_hash { |row| arr << row
            if (res.num_rows == 1)
              code=row['geonameid']
              par['admin1_code']= row['admin1_code']
              par['admin2_code']= row['admin2_code']
              par['geonameid']= code
            #else
            #  printf "%s) %s %s %s %s\n",par['city'], row['country_code'], row['admin1_code'], row['asciiname'], row['admin2_code'] 
            end
          }
      end
    rescue Mysql::Error => e
      puts "Error message: findCity(#{q}) ( #{e.errno} ) #{e.error} "
    rescue 
      puts "Error in ( findCountry(#{name.inspect}) "
    end
    res.free unless res.nil?
    return code 
  end


  # Fills in the details in par when found
  def findCity2(par,options={})
      #puts("findCity2: "+ par.inspect)
      if ( !par['country'].blank? && par['country_code'].blank? )
          puts("findCity2: Lookup country code ")
          par['country_code'] = findCountry(par['country'])
      end
      if par['country_code'].blank?
        puts("findCity2: Missing country code ")
        $log.error("findCity2: Missing country code")
        return nil
      end
      if par['city'].blank?
        puts("findCity2: Missing city name ")
        $log.error("findCity2: Missing city name ")
        return nil
      end
      q='select country_code,admin1_code,admin2_code,feature_code,asciiname,geonameid from allCountries where '
      if ( options['alt'].blank? )
        q=q+' name like "'+ par['city']+'" '
      else
        q = q +' ( alternatenames="'+par['city']+'" or alternatenames like "'+par['city']+',%" or alternatenames like "%,'+par['city']+',%" or alternatenames like "%,'+par['city']+'" ) '
        #q=q+' alternatenames like "%'+ par['city']+'%" '
      end
      q=q+' and feature_code like "PPL%" '
      q=q+" and country_code='"+par['country_code']+"'" unless ( par['country_code'].blank?)
      q=q+" and admin1_code='"+par['admin1_code']+"'" unless ( par['admin1_code'].blank? )
      q=q+" order by feature_code, population desc "
      code=nil;
      #puts q
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
              if (h[ row['feature_code'] ].blank? ) then  # Take the first of each feature code
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
      puts " country=#{ par['country']} country_code=#{par['country_code']}  #{ par['state'] }  " 
      if ( !par['country'].blank?  && par['country_code'].blank? )
        par['country_code'] = findCountry(par['country'])
      end
      unless par['state'].blank?
        #puts "Region: #{ par['state'] }  "
        code= findAdminCode( par,1) # find admin1 code
        #puts "State Code= #{code}"
      end
      unless ( par['latitude'].blank? && par['longitude'].blank? )
        #puts findClosestCity( par['latitude'] , par['longitude'] )
      end
      unless ( code.nil? &&  !par['city'].blank? )
        code = findCity2( par)    # larger city more likely
        h['alt']=par['city'];
        code = findCity2( par, h) if code.nil?    # go fishing for anything
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
    str=""
    if ( par['name'].blank? )
      puts "recordExists? name is missing"
      return false
    end
    #%w(id name geonameid street_address city state country_code postal_code phone url).each { |f|
    %w(id name city state ).each { |f|
        str= str + " and "+f+'="'+ par[f]+'"' if (!par[f].nil? && !par[f].empty? )
    }
    begin
      q= 'select id from places where '+ str[4,500]
      #puts q
      res= @dbh.query(q)
      return (res.num_rows >= 1)
    rescue Mysql::Error => e
      puts "Error message: ( #{e.errno} ) #{e.error}"
      puts "Error in checking for existance of #{ par['name'] }"
      res.free unless res.nil?
      return false; #assume the worse
    end
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
    if ( !par['name'].blank? ||  !par['city'].blank? || !par['state'].blank? ) # must have state or city
      arr= @yp.lookup( par['name'], par['city'], par['state'] , options);
    elsif ( !par['name'].blank? ||   !par['state'].blank? ) # must have state and name
      arr= @yp.lookup( par['name'], "", par['state'], options );
    else
      $log.error( "yplookup: needs name, state and city")
      puts "Need name, state and city";
      return nil
    end
    if (par['source'].nil?) then source='YPS' else source=par['source'] end
    url= par['url']
    if ( arr.length == 0 || arr.length > 2 ) 
      puts "No real results (#{arr.length.to_s}) for yplookup #{par['name']}, #{par['url']} ";
      return nil;
    else
      puts " #{arr.length.to_s} results "
    end
    urlok= false;
    arr.each { |h|
      #puts " #{h['name'] } => #{h['url']} #{url} "
      #if ( arr.length == 1 )
        puts "1 results ";
        if ( !url.nil? && !url.empty? )
          if ( h['url'].nil? )
            h['url']= url
          elsif ( h['url'] != url )
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
        %w(city feature_code source).each { |k|
          if  ( h[k].blank?  &&   !par[k].blank? )
            h[k]=par[k]
          end
        }
        h['city']= par['city'] if  h['city'].blank? 
        if (h['state'].nil? )
          puts "WHAT THE F!!! State missing!"
          puts "H= #{h.inspect} = PARAMS= #{par.inspect}"
          return nil
        end
        h['feature_class']='S'  # all buildings
        h['source']=source
        h['state'].upcase!
        h['country_code']='US'
      return h unless ( h['name'].empty? )  # Takes the first one on the list
      #end
    }
  end

  def fillCoord(h)
    coord= @coder.lookup( h['street_address'], h['city'], h['state'], h['postal_code'],h['country_code']);
    h['latitude'] = coord['lat'].to_s;
    h['longitude'] = coord['lon'].to_s;
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
    ['name','street_address','city','state','postal_code','hours','phone','url','source','feature_class','feature_code','country_code'].each { |f|
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

  def from_yp(name,city,state,country_code,feature_class,feature_code,source,url)
    #puts "from_yp #{name}, #{city}, #{state} #{country_code} #{feature_class} #{feature_code} #{source} #{url} ";
    if !@noclobber && nameExists?(name)
      #puts "Record exists #{name}";
      return false;
    end
    arr= @yp.lookup(name,city,state);
    if ( arr.length == 0 || arr.length > 2 ) 
      puts "No real results (#{arr.length.to_s}) for from_yp #{name}, #{city}, #{state} #{country_code} #{feature_class} #{feature_code} #{source} #{url} ";
      return false;
    else
      puts " #{arr.length.to_s} results "
    end
    urlok= false;
    arr.each { |h|
      puts " #{h['name'] } => #{h['url']} #{url} "
      if ( arr.length == 1 )
        puts "1 results ";
        if ( !url.blank? && !url.blank? )
          if ( h['url'].blank? )
            h['url']= url
          elsif ( h['url'].downcase != url.downcase )
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
      end
      if ( !urlok && !h['url'].nil? && !UrlAvailable?(h['url']))
        puts "#{h['url']} does not return 200 ";
        h['url']=nil;
      end
      unless ( h['name'].empty? )
        fieldlist=" created_at, source, feature_class,feature_code,country_code"
        valuelist= ') values ( current_timestamp(),"'+ source+ '","' +feature_class+ '","' +feature_code+ '","' + country_code+'"'
        unless ( h['state'].nil? || h['state'].empty?)
          fieldlist=fieldlist+",admin1_code"
          valuelist=valuelist+',"'+country_code+"."+h['state'].upcase+'"'
        end
        if  (h['street_address'].nil? || h['street_address'].empty? )
          puts "#{h['name'] } has no address "
          if  (h['city'].nil? || h['city'].empty? )
            h['city']=city
          end
        else
          coord= @coder.lookup( h['street_address'], h['city'], h['state'],
          h['postal_code'],country_code);
          unless (coord.nil? || coord.empty?)
            fieldlist=fieldlist+",latitude,longitude"
            valuelist=valuelist+','+ coord['lat'].to_s + ',' + coord['lon'].to_s 
          end
        end
        ['name','street_address','city','state','postal_code','phone','url'].each { |f|
          unless h[f].nil? || h[f].empty? 
            fieldlist=fieldlist+','+f;
            valuelist=valuelist+ ',"'+ @dbh.escape_string( h[f] ) + '"'
          end
        }
        # Not enough info to enter
        unless (( h['city'].nil? ||  h['city'].empty? )&&
        ( h['state'].nil? ||  h['state'].empty? )&&
        ( h['url'].nil? ||  h['url'].empty? ))
          begin
            puts 'insert into places ('+fieldlist+valuelist+')'
            @dbh.query( 'insert into places ('+fieldlist+valuelist+')' )
          rescue Mysql::Error => e
            puts "Error message: ( #{e.errno} ) #{e.error}"
            puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
            return false;
          end
        else
          puts 'No info for insertion into places ('+fieldlist+valuelist+')'
          return false;
        end
      end
    }
    return true;
  end
  
  def setSeason( code, months, criteria)
    mlist=""
    months.each { |m|
       mlist+' set season_'+m.to_s+'= "'+code.to_s+","
    }
    mlist=mlist.chop;
    begin
        q='select count(*) from  places where '+criteria 
        res=@dbh.query(q);
        res.each_hash { |row| 
          puts "ROW= #{row.inspect}"
        }
        q='update places'+mlist+' where '+criteria 
        puts q
        #@dbh.query( q);
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
  puts "inserted" unless !p.from_yp('Loxton Cellars','glen ellen','CA','USA','S','WINE','CAW','http://www.loxtoncellars.com/')
  puts p.from_yp('Ridge Winery','','CA','USA','S','WINE','YPS',nil);
  puts p.from_yp('Rabbit Ridge','','CA','USA','S','WINE','YPS',nil);
  puts p.from_yp('Ravenswoord Winery','','CA','USA','S','WINE','YPS','');
  url='http://www.loxtoncellarss.scom'
  if  ( p.UrlAvailable?(url))
    puts 'OK'
  end
end

def test1
  h= Hash[ 'name'=>'Airlie Winery',
  'street_address'=>'15305 Dunn Forest Rd.',
  'city'=>'Monmouth',
  'state'=>'OR',
  'source' => 'ORW',
  'feature_code' => 'WINE',
  'country_code'=>'US']
  p= Importer.new('')
  add= p.yplookup(h)
  p.fillCoord(add)
  puts add.inspect
  puts "OK" if p.insertintoDB(add)

h={"city"=>"Honolulu", "country_code"=>"US", "admin1_code"=>"HI", "country"=>"United States of America", "state"=>"Hawaii"}
cc = p.findCity2(h)
puts "findCity2 #{cc} #{h.inspect}"
h={"city"=>"Allentown", "country_code"=>"US", "admin1_code"=>"PA", "country"=>"United States of America", "state"=>"Pennsylvania"}
puts "findCity2 #{cc} #{h.inspect}"
h={"city"=>"gangneung", "country_code"=>"KR"}
options={'alt'=>true}
cc=p.findCity2(h,options)
end

def test_url
p= Importer.new('')
# one.dom
%w( http://www.amwellvalleyvineyard.com/  http://www.plumcreekwinery.com http://www.chiff.com/wine/winery.htm  http://www.target.com/gp/detail.html/602-4045909-4263801?ASIN=B000NPCK3W&AFID=Froogle&LNM=B000NPCK3W|Lexmark_AllInOne_Printer_with_Scanner_and_Copier__X1240&ci_src=14110944&ci_sku=B000NPCK3W&ref=tgt_adv_XSG10001 http://www.domain.com one.dom ).each { |url|
    puts url
    puts 'OK' if (p.UrlAvailable?(url))
}
end

#test_url

=begin
h= Hash[ 'city'=>'Monmouth', 'state'=>'Oregon', 'source' => 'ORW', 'country'=> 'united states', 'latitude'=> 38.752, 'longitude'=>-122.435]
# p.recordExists?(h)
h= Hash['city'=>"Brussels",'country'=>'Belgium']
puts p.findAddress(h)
h= Hash['city'=>"Paris",'country'=>'France']
puts p.findAddress(h)
h= Hash['city'=>"Milan",'country'=>'Italy']
puts p.findAddress(h)
=end
#test1
