require 'rubygems'
require 'ken'


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


def findwineries()
wineries=Ken.session.mqlread( [{
  :estimate-count => nil,
  :type =>   "/wine/wine_producer",
  :id => nil,
  :name =>  [],
  :"/business/company/headquarters" => [{
    :street_address =>  [],
    :citytown => nil,
    :postal_code => nil,
    :state_province_region => nil,
    :"/location/location/geolocation" => {
        :latitude => nil,
        :longitude => nil,
        :elevation => nil
    },
    :"/location/location/usbg_name" =>  nil,
    :"/location/location/gns_ufi" =>  nil,
  }],
  :"/business/open_times/hour_start" => []
}] );

puts wineries.inspect
wineries.each { |winery|
  winery.name
  loc= winery["/business/company/headquarters"]
  loc["state_province_region"]
}
end

#example('/en/ravenswood_winery');
findall;
#doview('/en/silverado_vineyards_winery');
#example('/en/ravenswood_winery');
