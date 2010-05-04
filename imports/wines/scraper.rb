require 'rubygems'
require 'htmlentities'
require 'mechanize'
require 'date'
require 'nokogiri'
require 'open-uri'
require 'logger'
require 'importer'

# Abstract class to build a scrapper for places table
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
    @importer.InsertorUpdatePlaceInDB(h, @options)
  end

  def urlHandle(file) 
      Nokogiri::parse(open(file))
  end

  def docHandle(file) 
      Nokogiri::parse(File.open(file))
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

  # Must implement this abstract function
  # go thru the leaf links to get the data for each place
  def parsePage(doc, info, options={} )
    #h = info.dup
    #enterIntoDB(h, options)   # options format => {"type"=>"wineries"}
  end

  # Implement this abstract function
  # go thru the index to find leaf link
  def parseIndex(doc, clickpage, info={})
      if info.empty? 
        h = Hash.new
      else
        h = info.dup
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



