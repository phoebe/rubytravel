require 'rubygems'
require 'mechanize'
require 'nokogiri'
require 'open-uri'
require 'active_support'
require 'cgi'

class Geocoder 
  @badconn=0;
  @@urlpre = "http://maps.google.com/maps/api/geocode/xml?sensor=false&address=";
  def initialize(appid)
    unless (appid.nil?)
      @application_id= appid;
    end
    @badconn=0;
  end

  #google only, not yahoo
  def glookup(address)
    return nil if (address.nil? || address.empty? )
	url = @@urlpre+CGI.escape(address)   #address.gsub(' ','+')
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
         sleep(5);     # wait 5 seconds, try again
         return  lookup(address)
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
       if ( @badconn < 3 ) 
         sleep(5);     # wait 5 seconds, try again
         return  lookup(address,city,state,zip,country)
       else
         puts "Give up GeoLookup";
          return nil;
       end
  end

end


def test 
  coder= Geocoder.new("6.s3T.nV34E7G_DUQbuiiTN9Ca7waeaW0E9apk5eM5rTb13FxwVJM9bYTa5ePqvvbFM-");
  ans= coder.lookup('5330 Silverado Trl','Napa','CA','94558','USA');
  puts ans['lat']
  puts ans['lon']
end


#test
