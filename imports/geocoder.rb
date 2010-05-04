require 'rubygems'
require 'mechanize'
require 'nokogiri'
require 'open-uri'
require 'cgi'

class Geocoder 
  @badconn=0;
  @application_id =  "6.s3T.nV34E7G_DUQbuiiTN9Ca7waeaW0E9apk5eM5rTb13FxwVJM9bYTa5ePqvvbFM-";
  @@urlpre = "http://local.yahooapis.com/MapsService/V1/geocode?appid=";
  def initialize(appid)
    unless (appid.nil?)
      @application_id= appid;
    end
    @badconn=0;
  end

  def lookup(address,city,state,zip,country)
      url = @@urlpre+@application_id
      unless (address.nil? || address.empty? )
        url = url +'&street='+CGI.escape(address)   #address.gsub(' ','+')
      end
      unless (city.nil? || city.empty? )
        url= url+'&city='+CGI.escape(city)  #city.gsub(' ','+');
      end;
      unless (state.nil? || state.empty? )
        url= url+'&state='+CGI.escape(state)  #state.gsub(' ','+');
      end;
      unless (country.nil? || country.empty? )
        url= url+'&country='+country;
      end;
      unless (zip.nil? || zip.empty? )
        url= url+'&zip='+zip 
      end;
       begin
        doc = Nokogiri.parse(open(url))
        result = doc.search('//result')
        result.each do |geo|
          lat = geo / 'latitude'
          lon = geo / 'longitude'
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


