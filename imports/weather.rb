require 'rubygems'
require 'mechanize'
require 'date'
require 'nokogiri'
require 'open-uri'
require 'logger'
require 'geocoder'
require 'importer'
require 'yellowpages'

# Will crawl sites for weather info
# # advisories for every state
# http://www.weather.gov/alerts-beta
#
# climate/ weather data
# http://worldweather.wmo.int

def isNumeric(s)
   Float(s) != nil rescue false
end


class NokoParser < Mechanize::Page
  attr_reader :noko
  def initialize(uri = nil, response = nil, body = nil, code = nil)
    @noko =  Nokogiri.parse(body)
    super(uri, response, body, code)
    follow_meta_refresh = true
  end 
end

class WeatherInfo
  def initialize()
    @url='http://worldweather.wmo.int/'
    $log = Logger.new("log.#{$0}.txt",'daily') if $log.nil?
    monthnum = (1..12).collect { |m| [ Date::MONTHNAMES[m].strip.downcase , m ] }.flatten
    tt = (1..12).collect { |m| [ Date::ABBR_MONTHNAMES[m].strip , m ] }.flatten
    @monthnums = Hash[*monthnum]
    @months = Hash[*tt]
    @importer =  Importer.new('')
  end

  def startRobot()
    @agent= Mechanize.new
    @agent.pluggable_parser.html= NokoParser
  end

  def robotParseCountry(url,info={})
    startRobot() if @agent.nil?
    puts url
    begin
    @agent.get(url) { |page|
              # the country page get cities
      parseCountry(page.noko, page,info);
    }
    rescue => e
        $stderr.puts "#{e.class}: #{e.message}"
        $log.error( "#{e.class}: #{e.message}")
    end
  end

  def parseCountry(doc, country_page, info={})
      title=doc.search('//head/title/text()').text;
      if info.empty? 
        h = Hash.new
        #puts "Title=#{ title }"
        title=~/-(.+)/mi
        title=$1
        h['country']=title.strip
        puts "Title=#{ title }"
      else
        h = info.dup
        puts info.inspect
      end
      doc.search('td > a.text15').each { | link|
        @importer.resetAddress(h,'state')  # reset address below country level for next lookup
        puts "link= #{link.inspect}"
        city = link.text()
        if city=~/([^,]+),([\w\s\.]+$)/
          h['state']= $2.strip
          h['city']= $1.strip
        else
          h['city']= city
        end
        #puts "h= #{h.inspect}"
        code = @importer.findWeather(h) # fills in location info as well
        unless code.nil?
          puts " weather already inserted for #{city}";
          $log.error( " weather already inserted for #{city}");
          next;
        end
        #puts "Crawl City= #{ city } #{h['geonameid']} #{h.inspect} "
        puts "Crawl City #{h.inspect} "
        begin
          unless country_page.nil?
            city_page = @agent.click(country_page.link_with(:text => city ))
            puts parseCity(city_page.noko,h) # the city page get temperatures
            sleep(1)    # be kind 
          end
        rescue => e # regular rescue only deals with stderr
          puts "Error message: parseCountry ()"
        end
      }
  end

  def parseFile(file)
    return Nokogiri.parse(File.open(file));
  end

  def parseUrl(url)
    return Nokogiri.parse(open(url));
  end

  def numerize(str)
    if isNumeric(str)
      return str
    else
      return '0.0'
    end
  end

  def parseCity(doc,info={})
    title = doc.search('//head/title/text()').text;
    if title=~/-(.+)/m
      title=$1.strip
      puts "Title="+ title
      if (!info.blank? && info['city'].blank?)
        info['city']=title
      end
    end
    begin
    temp=Array.new
    doc.css('td.month').each { | month|
      mon=month.text()
      #puts @months
      unless ( @months[mon].nil?)
        m=@months[mon]
        temp[m]=Hash.new
        temp[m]['minc'] = numerize( month.parent.css('td')[1].text()) # next-sibling didn't work
        temp[m]['maxc'] = numerize(month.parent.css('td')[2].text())
        temp[m]['rain'] = numerize(month.parent.css('td')[3].text())
        temp[m]['rday'] = numerize(month.parent.css('td')[4].text())
      end
    }
    #puts "parseCity #{title} #{info.inspect} month #{temp.inspect} ";
    @importer.insertWeather( temp, info) unless (info.blank?)
    rescue
      $log.error("parseCity: Bad format "+title);
    end
    return temp.inspect;
  end

  def crawlAllCountries()
    startRobot() if @agent.nil?
    url=@url
    counter=0;
    arr=Array.new
    h=Hash.new()
    @agent.get(url) { |page| # get the country page 
      selection= page.noko.css('select[name="country"]')
      selection.children.css('option').each { |o|
        h.clear
        h['href']= o.values[0].strip
        cc = o.text.strip
        if cc =~ /(\w+)\s+-\s+(.+)$/
          #h['country']=$1.strip
          h['country']=$2.strip   # we don't carry about the admin of the territories
          #code = @importer.findAddress(h)
          #if (code.nil?)
            #h['country']= h['city']
            #h.delete('city')
          #end
        elsif cc =~ /Republic of ([\w\s']+)/
          h['country']=$1
        else
          h['country']= cc
        end
        h['country_code']= @importer.findCountry( h['country'] ) if (h['country_code'].blank?)
        puts "#{counter.to_s} #{h.inspect} = #{ h['country_code'] }"
        unless (h['country_code'].blank?)
          arr << h.clone  # absolutely necessary to clone
          counter=counter+1;
        else
           puts "## can't find #{h.inspect}"
           $log.error("## can't find #{h.inspect}")
           next;
        end
      }
      arr.each { |h|
        begin
          @agent.transact do
            country_page = @agent.click(page.link_with(:href => h['href'] ))
            isCountry = (h['href'] =~ /\/m/) # city =(\/c/)
            if (isCountry)
              parseCountry(country_page.noko, country_page, h)
            else
              puts "transact #{country_page.inspect}"
              parseCity( country_page.noko, h)
            end
          end
        rescue => e
           $stderr.puts "#{e.class}: #{e.message}"
           $log.error( "#{e.class}: #{e.message}")
        end
      }
    }
  end
end

def testFiles
  url='http://worldweather.wmo.int/'
  wi = WeatherInfo.new
  d=wi.parseUrl(uri);
  wi.parseCity(d);

  d=wi.parseFile('cardiff.htm')
  wi.parseCity(d,info) # the city page get temperatures

  d=wi.parseFile('m028.htm')
  wi.parseCountry(d, nil )

uri='http://worldweather.wmo.int/010/c00036.htm' # Cardiff
uri='http://worldweather.wmo.int/028/c00105.htm'  # punta arenas
info=Hash["country_code"=>"GB"]
uri='http://worldweather.wmo.int/010/m010.htm' # UK
wi.robotParseCountry(uri)
info=Hash["country_code"=>"US"]
uri='http://worldweather.wmo.int/093/m093.htm' # US
wi.robotParseCountry(uri)
end

# These are countries that it cann't figure out
def SpecialCases
countries=[
#{"country_code"=>'KP', "href"=>"120/c00230.htm", "country"=>"Korea"},
#{"country_code"=>'KY', "href"=>"024/c00096.htm", "country"=>"British Caribbean Territories"},
#{"country_code"=>'GF', "href"=>"187/c00305.htm", "country"=>"French Guiana"},
#{"country_code"=>'HK', "href"=>"002/c00001.htm", "country"=>"Hong Kong, China"},
#{"country_code"=>'IR', "href"=>"114/m114.htm", "country"=>"Iran, Islamic Republic of"},
#{"country_code"=>'LA', "href"=>"121/m121.htm", "country"=>"Lao People's Democratic Republic"},
#{"country_code"=>'MO', "href"=>"072/c00156.htm", "country"=>"Macao, China"},
#{"country_code"=>'AW', "href"=>"181/c00286.htm", "country"=>"Netherlands Antilles and Aruba"},
{"country_code"=>'KR', "href"=>"095/m095.htm", "country"=>"Korea"},
#{"country_code"=>'SY', "href"=>"099/m099.htm", "country"=>"Syrian Arab Republic"},
#{"country_code"=>'VN', "href"=>"082/m082.htm", "country"=>"Viet Nam, Socialist Republic of"}
]
wi = WeatherInfo.new
countries.each { |c|
  puts c['country_code']
  url='http://worldweather.wmo.int/'+c['href']
  if (c['href']=~/\/c/) 
    d = wi.parseUrl(url)
    wi.parseCity(d,c);
    sleep(1);
  else
    wi.robotParseCountry(url,c)
  end
}

end

def testimport
  #url='http://worldweather.wmo.int/'
  #wi = WeatherInfo.new
  importer=Importer.new('')
  h={"city"=>"Setif", "country_code"=>"DZ", "country"=>"Algeria"}
  code = importer.findAddress(h)
  puts "h="+h.inspect
  code = importer.findWeather(h) # fills in location info as well
  puts "code="+code unless code.nil?

end

def testcrawl
# crawl one city which has a different name than in the db
  info=Hash["country_code"=>"AG","geonameid"=>3576022,"city"=>"Saint John's"]
  uri='http://worldweather.wmo.int/041/c00151.htm' # aruba
  d=wi.parseUrl(uri)
  wi.parseCity(d,info) # the city page get temperatures
# crawl one country
  uri='http://worldweather.wmo.int/122/m122.htm' #algeria
  wi.robotParseCountry(uri)
end
#
def crawlAll
  wi = WeatherInfo.new
  wi.crawlAllCountries()
end

#testimport()
#wi.crawlAllCountries()
SpecialCases()



