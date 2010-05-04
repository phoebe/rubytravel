require 'rubygems'
require 'htmlentities'
require 'mechanize'
require 'date'
require 'nokogiri'
require 'open-uri'
require 'logger'
require 'geocoder'
require 'importer'
require 'yellowpages'

# Abstract class to build a scrapper for places table
#
#

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

class Scraper
  def initialize()
    # Implement the following in the subclass init
    # @info = { "country_code" => "US", "feature_code" => "WINE", "source" => "MIW", "state"=>"MI" }
    # @url="root url"  #Must Implement
    #
    $log = Logger.new("log.#{$0}.txt",'daily') if $log.nil?
    monthnum = (1..12).collect { |m| [ Date::MONTHNAMES[m].strip.downcase , m ] }.flatten
    tt = (1..12).collect { |m| [ Date::ABBR_MONTHNAMES[m].strip , m ] }.flatten
    @monthnums = Hash[*monthnum]
    @months = Hash[*tt]
    @importer =  Importer.new('')
    @agent= Mechanize.new
    @agent.pluggable_parser.html= NokoParser
    @htmlcoder= HTMLEntities.new
  end

  def cleanString(t) 
    return @htmlcoder.decode(t).gsub(/[\n\r\s\302\240]+/,' ').gsub(/\<[^>]+\>/im,'').strip.gsub(/\342\200\223/,'-').gsub(/\226/,'-').gsub(/\342\200\231/,"'")
  end

  def enterListIntoDB( listofPlaces, options={}) 
    listofPlaces.each { |name, h|
      enterIntoDB( h, options) 
    }
  end

  def enterIntoDB( h, options={}) 
    if @importer.recordExists?(h)
      puts "Record already exists for #{h['name']} #{ h['city']} ";
      return;
    end
    begin
      soft=false
      unless options.blank?
        soft= !options['soft'].blank?
      end
      puts "LOADING= #{h['name']} #{ h['city']} "
      add= @importer.yplookup(h)
      if ( add.blank? )
        h2=h.dup
        h2.delete("city")
        sleep 1;
        add= @importer.yplookup(h2, options)   # bad address?
      end
      unless @importer.UrlAvailable?(h['url'])
        h.delete('url')
      end
      if (!add.blank? )
        @importer.fillCoord(add)
        puts  "Found #{h['name']} #{ h['city']}"
        sleep(1) if @importer.insertPlaceIntoDB(add)
      elsif ( !h['url'].blank? && !h['city'].blank? && !h['name'].blank? && soft )
        puts  " name/city/url is good enough #{h['name']} #{ h['city']} #{h['url']} "
        sleep(1) if @importer.insertPlaceIntoDB(h)
      else
        "Fail to insert #{h['name']} #{ h['city']}"
      end
    rescue => e
      puts "Error: Scrapper::enterIntoDB #{h['name']} "
    end
  end

  # eg: h= {"country_code"=>"US","source"=>"AAW", "feature_code"=>"WINE"}
  def docHandle(file) 
      doc = Nokogiri::parse(File.open(file))
  end

  def parseDoc(file,h={}) 
      doc = Nokogiri::parse(File.open(file))
      parsePage(doc,h)  #leaf page
  end

  def parseUrl(url,h={}) 
    begin
    doc = Nokogiri::parse( open(url))
    parsePage(doc,h) #leaf page
    rescue
      puts "error in parseUrl";
    end
  end

  def crawlAll()
    robotParsePage(@url,@info)
  end

  # overload
  def robotParsePage(url,info,options={})
    puts url
    begin
    @agent.get(url) { |page|
              # the country page get cities
      parseIndex(page.noko, page ,info);
    }
    rescue => e
        $stderr.puts "#{e.class}: #{e.message}"
        $log.error( "#{e.class}: #{e.message}")
    end
  end

  # Must implement this
  # go thru the leaf links to get the data for each place
  def parsePage(doc, info, options={} )
    h = info.dup
    title=doc.search('//head/title/text()').text; # xpath or css to get the data
    enterIntoDB(h, options)   # options format => {"type"=>"wineries"}
  end

  # Implement this
  # go thru the index to find leaf link
  def parseIndex(doc, clickpage, info={})
      title=doc.search('//head/title/text()').text;
      if info.empty? 
        h = Hash.new
        title=~/-(.+)/mi
        title=$1
        puts "Title=#{ title }"
      else
        h = info.dup
        puts info.inspect
      end
      doc.css('a').each { | link|
        @importer.resetAddress(h,'state')  # reset address below country level for next lookup
        nextlink= (link / './@href').text().strip;
        begin
          unless clickpage.nil?
            @agent.transact do
              nextpage = @agent.click(clickpage.link_with(:href => nextlink ))
              puts parsePage(nextpage.noko,h) # the city page get temperatures
              sleep(1)    # be kind 
            end
          end
        rescue => e # regular rescue only deals with stderr
          puts "Error message: parseCountry ()"
        end
      }
  end

def testParser
  # get a file and run
    file='sample.html'
    parseDoc( file ,{'country'=>'US'});
end

def testCrawler
end

def test
  testParser
  testCrawler
end


end



