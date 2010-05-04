require 'rubygems'
require 'htmlentities'
require 'mechanize'
require 'date'
require 'nokogiri'
require 'open-uri'
require 'logger'
#require 'geocoder_google'
#require 'importer'
#require 'yellowpages'
#require 'USstates'
require File.join(File.dirname(__FILE__), './', 'importer' )
require File.join(File.dirname(__FILE__), './', 'yellowpages' )
require File.join(File.dirname(__FILE__), './', 'USstates')

# Abstract class to build a scrapper for places table
#

class String
  def distance(other_str)
    _self_str = self.downcase
    _othr_str = other_str.downcase
 
    # Shortcuts
    return 0 if _self_str == _othr_str    
    return _self_str.length if (0 == _othr_str.length)
    return _othr_str.length if (0 == _self_str.length)
 
    # how to unpack
    unpack_rule = ($KCODE =~ /^U/i) ? 'U*' : 'C*'
 
    #longer, shorter
    _str_1, _str_2 = if _self_str.length > _othr_str.length
      [_self_str, _othr_str]
    else
      [_othr_str, _self_str]
    end
 
    # get different in length as base
    difference_counter = _str_1.length - _str_2.length
 
    # Shorten first string & unpack
    _str_1 = _str_1[0, _str_2.length].unpack(unpack_rule)
    _str_2 = _str_2.unpack(unpack_rule)
 
    _str_1.each_with_index do |char1, idx|
      char2 = _str_2[idx]
      difference_counter += 1 if char1 != char2
    end
 
    return difference_counter
  end
  def isNumeric(s)
	  Float(s) != nil rescue false
	end
end

# legacy
	def isNumeric(s)
	   Float(s) != nil rescue false
	end

	def	ft_to_m(f)
		f.gsub(',','').to_f * 0.3048 rescue 0
	end

	# degree to radians with dirs
	def d_to_r(d,m,dir)
		deg= d.to_f + m.to_f*Math::PI/180
		if dir =~ /s|w/i
			-deg
		else
			deg
		end
	end

	# farenheit to centigrade
	def f_to_c(f)
		f.to_f*9/5+32;
	end

	# inches to mm
	def in_to_mm(inc)
		inc.to_f * 25.4
	end
	#
	# inches to m
	def in_to_mm(inc)
		inc * 25400
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
    @agent= Mechanize.new { |a|
		a.user_agent_alias = 'Mac Safari'
		a.follow_meta_refresh = true
		a.pluggable_parser.html= NokoParser
	}
    @htmlcoder= HTMLEntities.new
  end

  def cleanString(t) 
    return @htmlcoder.decode(t).gsub(/[\n\r\s\302\240]+/,' ').gsub(/\<[^>]+\>/im,'').gsub(/\342\200\223/,'-').gsub(/\226/,'-').gsub(/\342\200\231/,"'").strip
  end

  def enterListIntoDB( listofPlaces, options={}) 
    listofPlaces.each { |name, h|
      enterIntoDB( h, options) 
    }
  end

  def enterIntoDB( h, options={}) 
    @importer.InsertorUpdatePlaceInDB(h, @options)
  end

  def urlAgentHandle(url) 
	  a = @agent.get(url)
	  return a.noko 
  end

  def urlHandle(file) 
	  Nokogiri::parse(open(file)) rescue OpenURI::HTTPError
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
    rescue OpenURI::HTTPError
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



