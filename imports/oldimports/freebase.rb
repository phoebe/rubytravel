require 'rubygems'
require 'date'
require 'ken'
require 'importer'

# good stuff
#  select distinct ?a ?c ?d ?e ?f where {?a ?b <http://dbpedia.org/resource/Category:Wineries_by_country> .  ?c ?d ?a . ?e ?f ?c}

@options= {:extended=>true,:cursor=>true}
def lookartist()
  artists = Ken.session.mqlread([{
  :type => "/music/artist",
  :id => nil, 
  :"/common/topic/webpage" => [{:uri => nil}], 
  :home_page => [{:uri => nil}], 
  :limit => 2
  }])
  puts artists.inspect;
end

def lookat_types(types)  # concept='/en/new_order';
    types.each do |type| # Inspecting a Type’s properties
        puts "TYPE INSP: ", type.inspect
        puts "TYPE PROP: ", type.properties # => e.g. [ #<Property id="/music/musical_group/member"> ]
    end
end
def lookat_attributes(attributes)  # concept='/en/new_order';
  attributes.each do |att|
    #att.inspect 
    puts "ATT: ", att
    puts "ATT P: ", att.property.name # => e.g. "Albums"
    puts "ATT V: ",att.values
  end 
end

def example(concept)  # concept='/en/new_order';
  resource = Ken.get(concept);
  resource.types.each do |type| # Inspecting a Type’s properties
      puts type.inspect
      puts type.properties # => e.g. [ #<Property id="/music/musical_group/member"> ]
  end
  # Listing all Attributes
  resource.attributes.each do |att|
    puts att.inspect # => #<Attribute property="/music/artist/album"> #puts resource.attribute('/music/artist/album').inspect # => #<Attribute property="/music/artist/album">
    #puts att # => e.g. #<Attribute property="/music/artist/album">
    puts att
    puts att.property.name # => e.g. "Albums"
    puts att.values
    # e.g. => [ #<Resource id="/guid/9202a8c04000641f8000000002fa2556" name="Ceremony">, 
    #<Resource id="/guid/9202a8c04000641f8000000002fa24d5" name="Procession">,
  # e.g. => ["1980"]
  end
  # alternatively you can access them directly
    #puts resource.attribute('/location/location/address').inspect # => #<Attribute property="/music/artist/album"> #puts resource.attribute('/music/artist/album').inspect # => #<Attribute property="/music/artist/album">
end

def doview(concept)  # concept='/en/new_order';
  resource = Ken.get(concept);
    resource.views.each do |view|
      puts view.type
      #  puts view.attributes
      # Listing all Attributes
      view.attributes.each do |att|
        puts att.inspect
        puts att.values
      end
    end
end

def findall()  # concept='/en/new_order';
  resources = Ken.all(:name => nil,
                  :"type" => "/wine/wine_producer",
                  :"/business/company/headquarters" =>[{"citytown" => 'Napa'} ],
                  :"/business/business_location" =>{
                      :address => nil,
                      :hours => nil
                    }
                     );
    resources.each do |resource|
      lookat_types(resource.types);
      lookat_attributes(resource.attributes);
    end
end

def findWeather( city, country )
    q= [{
    :"type"=>"/travel/travel_destination",
    :"name"=> city,
    "/location/location/containedby"=> [{
      "name"=> country,
      "type"=> "/location/country"
    }],
    :"climate"=> [{
      :"month"=>  nil,
      :"average_max_temp_c"=> nil,
      :"average_min_temp_c"=> nil,
      :"average_rainfall_mm"=> nil,
    }] 
    }] 
    return Ken.session.mqlread(q);
=begin
  if (city.empty?)
    return Ken.session.mqlread(q);
  else
    q[0][:limit] = limit,
    q[0][:cursor] = 500
    return Ken.session.mqlread(q, @options )
  end
=end
end

def findwineries( state)
  wineries=Ken.session.mqlread( [{
    :"estimate-count" => nil,
    :type =>   "/wine/wine_producer",
    :id => nil,
    :name => [],
    :"/common/topic/webpage"=> [{
      :optional => true,
      "uri"=> {}}],
    :"/business/company/headquarters" => [{
      :optional => true,
      :street_address =>  [],
      :citytown => [],
      :postal_code => nil,
      :state_province_region => [],
      :"/location/location/geolocation" => {
        :optional => true,
        :latitude => nil,
        :longitude => nil,
        :elevation => nil
      },
    }],
    :"/business/business_location/address" => [{
      :optional => true,
      :street_address =>  [],
      :citytown => [],
      :postal_code => nil,
      :state_province_region => [],
      :"/location/location/geolocation" => {
        :optional => true,
        :latitude => nil,
        :longitude => nil,
        :elevation => nil
    },
  }],
  :"/business/business_location/phone_number" => [{}],
  :"/business/business_location/hours" => [{
      :optional => true,
      :hour_start => nil,
      :hour_end => nil,
      :weekday_start => nil,
      :weekday_end => nil,
   }],
}] );

  return wineries;
  #puts wineries.inspect
end

def getAllTravelDestinations( country )
  travelquery= [{
    :type=>   "/travel/travel_destination",
    :name=>   [],
    :"/location/location/containedby"=> [{
      :name=> country,
      :type=> "/location/country"
    }],
  :limit=>  200,
  #:cursor=> 500,
  :"estimate-count" => nil,
  }]
  traveldest = Ken.session.mqlread( travelquery )  
  arr=Array.new
  imp= Importer.new('')
  count=0;
  h= Hash.new()
=begin
  traveldest = Ken.session.mqlread( travelquery, {:extended=>true,:cursor=>true})  
  #puts traveldest.inspect
  traveldest.each { |d|
    h.clear
    count=count+1;
    h["city"]= d["name"].to_s
    h["country"]= d["/location/location/containedby"][0]["name"].to_s
    puts  h.inspect
    code = imp.findAddress(h)
    arr << h
    #puts "Dest= #{code} #{h["city"]} #{h["admin1_code"]} #{h["country"]} #{h["country_code"]}" 
    puts "Dest #{count} = #{h.inspect}"
  }
  travelquery[0][:cursor] = traveldest[0][:cursor]
  traveldest = Ken.session.mqlread( travelquery, {:extended=>true,:cursor=>true})  
=end
  traveldest.each { |d|
    h.clear
    count=count+1;
    h["city"]= d["name"].to_s
    h["country"]= d["/location/location/containedby"][0]["name"].to_s
    puts  h.inspect
    code = imp.findAddress(h)
    arr << h.dup unless ( code.nil?)
    #puts "Dest= #{code} #{d["city"]} #{d["admin1_code"]} #{d["country"]} #{d["country_code"]}" 
    puts "Dest #{count} = #{h.inspect}"
  }
  return arr

 # traveldest=Ken.session.mqlread( travelquery, {:extended=>true,:cursor=>true})
  #puts traveldest.inspect
end

@weekdays=Array["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday",
                "Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]
def packhours( list, hours )
  if ( hours.nil? || hours.empty? ) then return false; end
  hours=hours[0];
    week='CCCCCCC';
    (0..6).each { |d|
       if (@weekdays[d]== hours['weekday_start'] )
         d.upto(d+7) { |w|
           week[ w.modulo(7) ]='O';
           if (@weekdays[w]== hours['weekday_end'] ) then break; end
         }
         break;
      end
    }
    list['open_days']=week;
    list['hour_start']=hours['hour_start'].to_s
    list['hour_end']=hours['hour_end'].to_s
    return true;
end

def packaddress( list, addresses )
  if ( addresses.nil? || addresses.empty? ) then return false; end
  if ( addresses[0].nil? || addresses[0].empty? ) then return false; end
  addresses.each { |address|
     packpoint(list,address['/location/location/geolocation'])
    if (list['street_address'].nil?) then
      list['street_address']= address['street_address'].to_s
    end
    if (list['city'].nil? ) then
      list['city']= address['citytown'].to_s
    end
    if (list['state'].nil? ) then
      list['state']= address['state_province_region'].to_s
    end
    if (list['postal_code'].nil? ) then
      list['postal_code']= address['postal_code'].to_s
    end
  }
  return true;
end

def packpoint( list, point)
  if ( point.nil? || point.empty? ) then return false; end
  ['elevation','latitude','longitude'].each { |l|
    if ( list[l].nil? )
      list[l] =point[l].to_s
    end
  }
  return true;
    #if ( list['elevation'].nil ) then list['elevation'] =address['elevation']
    #latitude= address['latitude']
    #longitude= address['longitude']
end

def packurl( list, webpage)
  if (webpage.nil? || webpage.empty?  ) then return false; end
  list['url']= webpage[0]['uri']['value'].to_s
  return true;
end


def insertplace( places)
  places.each { |place|
    list=Hash.new;
    list['name']=place['name'];
    list['id']=place['id'];
    place['/business/company/headquarters'].inspect;
    #place['/business/business_location/address'].inspect;
    packaddress(list,place['/business/company/headquarters']);
    packaddress(list,place['/business/business_location/address']);
    place['/business/business_location/hours'].inspect;
    packhours(list,place['/business/business_location/hours']);
    list['phone']= place['/business/business_location/phone_number']
    packurl( list, place['/common/topic/webpage'] );

    puts place.inspect
    puts list.inspect;
  }
end

def insertweather2( places)
  tt = (1..12).collect { |m| [ Date::MONTHNAMES[m].strip.downcase , m ] }.flatten 
  mon = Hash[*tt]
  imp = Importer.new('')

  loc= Hash.new
  places.each { |place|
      puts place.inspect
      l = place['name'][0]
      if ( loc[ l ].nil? ) then loc[l]={} end
      puts "city = #{ l }";
      country = place['/location/location/containedby'][0]['name']
      loc[l][0]= country
      place['climate'].each { |mm|
        m = mm['month'].strip.downcase
        mnum = mon[ m ];
        if ( loc[l][mnum].nil? ) then loc[l][mnum]= Hash.new  end
        loc[l][mnum]['minc'] = mm['average_min_temp_c']
        loc[l][mnum]['maxc'] = mm['average_max_temp_c']
        loc[l][mnum]['rain'] = mm['average_rainfall_mm']
      }
  }
  par=Hash.new
  #puts loc.inspect
  loc.each { |k,clim|
    par.clear
    par['city'] = k.to_s
    par['country']= clim[0]
    puts par.inspect
    imp.insertWeather(clim,par)
  }

end

def insertweather( places)
  tt = (1..12).collect { |m| [ Date::MONTHNAMES[m].strip.downcase , m ] }.flatten 
  mon = Hash[*tt]
  imp = Importer.new('')

  loc= Hash.new
  places.each { |place|
      #puts place.inspect
      l = place['travel_destination'][0]['name']
      #
      if ( loc[ l ].nil? ) then loc[l]={} end
      country = place['travel_destination'][0]['/location/location/containedby'][0]['name']
      loc[l][0]= country
      m = place['month'][0]['name'].strip.downcase
      mnum = mon[ m ];
      if ( loc[l][mnum].nil? ) then loc[l][mnum]= Hash.new  end
      loc[l][mnum]['minc'] = place['average_min_temp_c']
      loc[l][mnum]['maxc'] = place['average_max_temp_c']
      loc[l][mnum]['rain'] = place['average_rainfall_mm']
  }
  par=Hash.new
  #puts loc.inspect
  loc.each { |k,clim|
    par.clear
    par['city'] = k.to_s
    par['country']= clim[0]
    #puts par.inspect
    imp.insertWeather(clim,par)
=begin
    code = imp.findAddress(par)
    fields=""; values=""
    total_m = 0 # missing months - can you believe it?
    total_min=0; 
    total_max=0;
    incomplete = false;
    (1..12).each { |m|
      unless (clim[m].nil?)
      fields = fields+ ',avg_min_'+m.to_s+'_temp, avg_max_'+m.to_s+'_temp, avg_' +m.to_s+'_rainfall_mm' 
      values = values+ ','+min=clim[m]['minc'].to_s + ',' + clim[m]['maxc'].to_s + ','+ (clim[m]['rain'].to_s)
      total_min= total_min + (clim[m]['minc']).to_f
      total_max= total_max + (clim[m]['maxc']).to_f
      total_m= total_m+1
      else
        incomplete = true;
      end
    }
    unless code.nil? && !incomplete
      q= 'insert into weatherInfo values ( id,average_max_temp,average_min_temp'+ fields+') values (' + code+','+ (total_max/total_m).to_s+','+(total_min/total_m).to_s+values+')';
      puts "#found "+ par.inspect 
      puts q;
    else
      code='    ###   '+ incomplete? 'incomplete' : '';
      puts "### can't find "+ par.inspect 
      q= 'insert into weatherInfo values ( id,average_max_temp,average_min_temp,'+ fields+') values (' + code+','+ (total_max/total_m).to_s+','+(total_min/total_m).to_s+','+values+')';
      puts q;
    end
=end
  }

end

#wineries = findwineries('Texas');
#insertplace(wineries);

#climates = findWeather([] , 120)
#climates.inspect
#puts "#######"
#insertweather (climates)

def messy
imp = Importer.new('')
destinations = getAllTravelDestinations('Italy')
arr= Array.new
destinations.each { |d|
    h=d.clone;
    id = imp.findCity(h,arr)
    if ( id.nil? ) # no record of this city, deal with it manually
      puts "Can't find ",h.inspect
      next;
    else
      id = imp.findWeather(h)
      puts "imp.findWeather returns #{id} =  #{h}";
      unless  id.nil?    # already inserted
        puts "Already inserted #{h.city}"
      end
    end
    h['id']= h["geonameid"]
    #h["city"] h["state"] h["country"]
    puts " New location #{ h.inspect }"
    if ( id.nil? )
      climates = findWeather(h['city'] , 12)
      insertweather2 (climates)
    end
}
end
  climates = findWeather([] , 'Italy')
  insertweather2 (climates)


#
#example('/en/ravenswood_winery');
#findall;
#doview('/en/silverado_vineyards_winery');
#example('/en/ravenswood_winery');
