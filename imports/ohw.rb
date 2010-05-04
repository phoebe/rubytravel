require 'rubygems'
require 'mechanize'
require 'active_support'
require 'nokogiri'
require 'open-uri'
require 'geocoder'
require 'importer'
require 'yellowpages'
require 'scraper'


class OHwines < Scraper
  def initialize
    @info = { "country_code" => "US", "feature_code" => "WINE", "source" => "OHW", "state"=>"OH" }
    @url='http://www.ohiowines.org/cgi-bin/winery.pl';
    @options={'type'=>'wineries','soft'=>true}
    super
  end

  def parsePage(doc, info ) 
    wineries=Hash.new   # to clean out dups
    h = info.dup
    doc.search('.//hr').each { |bound|
      lll=bound.next_sibling();
      h =info.dup
      h['name']  =  cleanString(lll.text)
      lll=lll.next_sibling();
      while ( !lll.nil? &&  lll.name != 'hr' )
        entry=cleanString(lll.text)
          if entry =~ /Telephone:\s*/i
            h['phone']=  cleanString( $' )
          elsif entry =~ /^Hours[^:]+:\s*(.*)$/i
            if ( h['hours'].blank? )
              h['hours']=  cleanString($1)
            else
              h['hours']=  h['hours']+ cleanString($1)
            end
          elsif entry =~ /Website:/i
            a=lll.next_sibling();
            h['url'] = a['href'] unless lll.blank? &&  lll['href'].blank?
          elsif ( entry =~ /^([^,]+)\s*,\s*(\w+[^,]+),(\([^)]+\))?\s+(\w{2}|Ohio)\s*(\d{5})$/i )
            h['street_address']= $1
            h['city']=  $2 
            h['postal_code']= $5.strip
          elsif ( entry =~ /^(.+) -- (\w+[^,]+)\s*,\s+(\w{2}|Ohio)\s*(\d{5})$/i )
            h['street_address']= $1
            h['city']=  $2 
            #['state']= $3
            h['postal_code']= $4.strip
          elsif ( entry =~ /^([^,]+)\s+(\w+[^,]+),?\s+(\w{2}|Ohio)\s*(\d{5})$/i )
            h['street_address']= $1
            h['city']=  $2 
            h['postal_code']= $4.strip
          elsif ( entry =~ /^([^,]+),?([^,]*),\s+(\w{2}|Ohio)\s*(\d{5})$/ )
            h['street_address']= $1
            h['city']=  $2 
            h['postal_code']= $4.strip
          else
      #puts "N '#{ lll.name }' K '#{ lll.keys }' V '#{ lll.values }' #{ lll.text} "
          end
          lll=lll.next_sibling();
    end
    puts "#{ h.inspect } "
    enterIntoDB(h,@options) unless h['postal_code'].blank?
  }
  end

  def parseIndex(doc, clickpage, info={})
      parseUrl(@url,@info)

  end

  def testParse()
      file='winery.pl'
      puts file
      parseDoc(file,@info)
  end
end

aaw= OHwines.new
aaw.testParse();
#aaw.crawlAll();


