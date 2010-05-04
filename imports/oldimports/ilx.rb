require 'rubygems'
require 'mechanize'
require 'active_support'
require 'nokogiri'
require 'open-uri'
require 'geocoder'
require 'importer'
require 'yellowpages'
require 'scraper'


class ILwines < Scraper
  def initialize
    @info = { "country" => "US", "feature_code" => "WINE", "source" => "ILW", "state"=>"IL" }
    @url='http://www.gotexanwine.org/findwinesandwineries'
    super
  end

  def parsePage(doc, info ) 
    wineries=Hash.new   # to clean out dups
    h = info.dup
    doc.css('td').each { |l|   # less info
        lls = l.search('.//br/preceding-sibling::b|.//br/following-sibling::b|.//br/preceding-sibling::text()|.//br/following-sibling::text()')
        if ( lls.length  > 0) 
          lls.each { |lll|
              #puts "GOT '#{ lll.to_s }'"
              lll.css("b").each { |b| # this doesn't catch '<b>Alto Vineyards</b>'
                puts "B '#{ b.inspect }'"
                h =info.dup
                h['name']  =  cleanString(b.text)
              }
            if ( lll.to_s =~ /<b>(.*)<\/b>/ )
              h =info.dup
              h['name']  =  cleanString( lll.text)
            elsif cleanString(lll.text) =~ /(\d{3}.\d{3}.[\w\d]{4})/
              h['phone']=  cleanString(lll.text)
            elsif ( cleanString(lll.text) =~ /(\w+[^,]+),?\s+(\w+)\s*(\d{5})/ )
              h['city']=  $1 
              h['state']= $2
              h['postal_code']= $3.strip
            else
              if h['street_address'].blank?
                h['street_address']= cleanString( lll.text)
              else
                h['street_address']= h['street_address'] +" "+ cleanString( lll.text)
              end
            end
            wineries[ h['name'] ] = h
          }
        end
    }
    enterListIntoDB(wineries,{"type"=>"wineries"})
=begin
    wineries.each { |name, h|
      enterIntoDB(h,{"type"=>"wineries"})
    }
=end
  end

  def parseIndex(doc, clickpage, info={})
      file='ILwine.htm'
      url='http://www.gotexanwine.org/findwinesandwineries/findawinery/'+file
      parseUrl(url,@info)
  end

  def testParse()
      file='ILwine.htm'
      puts file
      parseDoc(file,@info)
  end
end

aaw= ILwines.new
aaw.testParse();
#aaw.crawlAll('http://www.allamericanwineries.com/AAWMain/locate.htm');


