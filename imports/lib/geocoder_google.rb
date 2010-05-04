require 'rubygems'
require 'mechanize'
require 'nokogiri'
require 'open-uri'
require 'active_support'
require 'cgi'

class Geocoder 
  @badconn=0;
  @@urlreverse = "http://maps.google.com/maps/api/geocode/xml?sensor=false&latlng=";
  @@urlpre = "http://maps.google.com/maps/api/geocode/xml?sensor=false&address=";
  def initialize(appid=[])
    unless (appid.nil?)
      @application_id= appid;
    end
    @badconn=0;
  end

  #google only, not yahoo
  def glookup(address)
    return nil if (address.nil? || address.empty? )
	url = @@urlpre+CGI.escape(address)   #address.gsub(' ','+')
	puts url
       begin
        doc = Nokogiri.parse(open(url))
        result = doc.css('result')
        result.each do |geo|
          lat = geo / 'geometry/location/lat'
          lon = geo / 'geometry/location/lng'
          coord=Hash["lat"=>lat.text.to_f ,"lon"=>lon.text.to_f ];
		  addrs = geo.css('address_component')
		  addr.each { |a| 
			  type=a.css('type').text
			  if type == 'country'
				  coord['country_code']=a.css('shortname')
			  elsif type == 'administrative_area_level_1' 
				  coord['admin1_code']=a.css('shortname')
			  elsif type == 'administrative_area_level_2' 
				  # coord['admin2_code']=a.css('shortname')
			  end
	 	  }
          @badconn=0;
          return coord; 
        end
       rescue
         puts "BAD Connection #{@badconn.to_s} ";
         @badconn=@badconn+1;
       end
       if ( @badconn < 2 ) 
         sleep(5);     # wait 5 seconds, try again
         return  glookup(address)
       else
         puts "Give up Google GeoLookup";
         return nil;
	   end
  end

  def lookup(address,city,state,zip,country)
      url = @@urlpre
      unless (address.nil? || address.empty? )
        url = url +CGI.escape(address)   #address.gsub(' ','+')
      end
      unless (city.nil? || city.empty? )
        url= url+','+CGI.escape(city)  #city.gsub(' ','+');
      end;
      unless (state.nil? || state.empty? )
        url= url+','+CGI.escape(state)  #state.gsub(' ','+');
      end;
      unless (zip.nil? || zip.empty? )
        url= url+'+'+zip 
      end;
      unless (country.nil? || country.empty? )
        url= url+','+country;
      end;
       begin
        doc = Nokogiri.parse(open(url))
        result = doc.css('result')
        result.each do |geo|
          lat = geo / 'geometry/location/lat'
          lon = geo / 'geometry/location/lng'
          coord=Hash["lat"=>lat.text.to_f ,"lon"=>lon.text.to_f ];
          @badconn=0;
          return coord; 
        end
       rescue
         puts "BAD Connection #{@badconn.to_s} ";
         @badconn=@badconn+1;
       end
       if ( @badconn < 2 ) 
         sleep(1);     # wait 5 seconds, try again
         return  lookup(address,city,state,zip,country)
       else
         puts "Give up GeoLookup";
          return nil;
       end
  end

  def self::greverselookup(lat,lon,h)
  	url= @@urlreverse+lat.to_s+','+lon.to_s;
	puts url;
	doc = Nokogiri.parse(open(url))
	result = doc.css('result')
	result.each { |geo|
		type= geo.search('./type').text 
		#print "TYPE="+type+":"
		if type == 'postal_code' || type == 'street_address' || type='rooftop'
		geo.css('address_component').each { |addr|
			addr.css('type').each { |t|
			type=t.text
			#puts type+" => "+ addr.css('short_name').text
			if type=='country'
				h['country_code']= addr.css('short_name').text
			elsif type=='street_number'
				h['street_number']= addr.css('short_name').text
			elsif type=='route'
				h['street']= addr.css('short_name').text
			elsif type=='administrative_area_level_1'
				h['state']= addr.css('short_name').text
			elsif type=='postal_code'
				h['postal_code']= addr.css('short_name').text
			elsif type=='locality'
				h['city']= addr.css('short_name').text
			end
			}
		}
		break;	# this is the best resolution
		elsif type == 'sublocality' || type == 'locality' 
			geo.css('address_component').each { |addr|
				addr.css('type').each { |t|
				type=t.text
				if type=='country'
					h['country_code']= addr.css('short_name').text
				elsif type=='administrative_area_level_1'
					h['state']= addr.css('short_name').text
				elsif type=='locality'
					h['city']= addr.css('short_name').text
				end
				}
			}
		else
			geo.css('address_component').each { |addr|
				addr.css('type').each { |t|
				type=t.text
				if type=='country'
					h['country_code']= addr.css('short_name').text
				end
				}
			}
		#break;	# goes from near to far - I think
		end
	}
	if (!h['street_number'].blank? && !h['street'].blank? ) 
		h['street_address']=h['street_number']+' '+h['street'];
	end
	h
  end

  def self::glookupLong(address)
    return nil if (address.nil? || address.empty? )
	url = @@urlpre+CGI.escape(address)   #address.gsub(' ','+')
	puts url
	order=0;
	results={}
       #begin
        doc = Nokogiri.parse(open(url))
        result = doc.css('result')
        result.each { |geo|
          lat = geo / 'geometry/location/lat'
          lon = geo / 'geometry/location/lng'
          coord=Hash["latitude"=>lat.text.to_f ,"longitude"=>lon.text.to_f ];
		  #type= geo.css('type:first-child')
		  type= geo.css('type') # take all of them
		  coord['type']=type.text
		  coord['street_address']=geo.css('formatted_address').text
		  addr = geo.css('address_component')
		  addr.each { |a| 
			  a.css('type').each { |type|
				  type=type.text
				  #puts "TYPE="+type+" => "+ a.css('short_name').text+" => "+ coord.inspect
				  if type == 'postal_code'
					  coord['postal_code']=a.css('short_name').text
				  elsif type == 'country'
					  coord['country_code']=a.css('short_name').text
				  elsif type == 'administrative_area_level_1' 
					  coord['admin1_code']=a.css('short_name').text	# needs translation if not US.text
				  elsif type == 'administrative_area_level_3' 
					  coord['admin3']=a.css('short_name').text
				  elsif type == 'locality' 
					  coord['city']=a.css('short_name').text
				  elsif type == 'administrative_area_level_2' 
					  coord['admin2']=a.css('shortname').text
				  elsif type =~ /establishment|route|point_of_interest|park/
					  coord['name']=a.css('short_name').text;
				  end
			  }
	 	  }
		  coord['city'] =  coord['admin3'] if ( coord['city'].nil? && !coord['admin3'].blank? ) 
		  unless ( coord['street_address'].nil? || coord['city'].nil? ) 
			  i= coord['street_address'].index(', '+coord['city'])
			  #puts coord['street_address']; puts coord['city']+ " at "+i.to_s
			  coord['street_address'].slice!(i..coord['street_address'].length) unless i.nil?	# skip the city
		  end
		  results[order]= coord;
		  order=order+1;
          @badconn=0;
		}
	   return results; 
=begin
       rescue
         puts "BAD Connection #{@badconn.to_s} ";
         @badconn=@badconn+1;
       end
       if ( @badconn < 2 ) 
         sleep(5);     # wait 5 seconds, try again
         return  glookup(address)
       else
         puts "Give up Google GeoLookup";
         return nil;
	   end
=end
  end
end


def test 
  coder= Geocoder.new()
  #ans= coder.lookup('5330 Silverado Trl','Napa','CA','94558','USA');
  #puts ans['lat']
  #puts ans['lon']
  #ans= coder.glookupLong('Appalachian Trail,USA');
=begin
  ans= Geocoder::glookupLong("Devil's Postpile National Monument,CA,USA");
  puts ans.inspect
  ans= Geocoder::glookupLong("Boston Children's Museum,MA,USA");
  puts ans.inspect
  #ans= Geocoder::glookupLong "New Bedford Whaling National Historical Park";
  ans= Geocoder::glookupLong "Essex National Heritage Area,MA,US"
=end
  ans=Hash.new
  ans= Geocoder::greverselookup -39.237359,175.556961,ans
  puts ans.inspect
  ans= Geocoder::greverselookup -36.4683210,174.6133790,ans
  puts ans.inspect
end


#test
