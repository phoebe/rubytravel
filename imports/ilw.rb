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
    @info = { "country_code" => "US", "feature_code" => "WINE", "source" => "ILW", "state"=>"IL" }
    @url='http://www.wine-il.com/'
    @options= {"type"=>"wineries","soft"=>true,'overload'=>true}
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
      parseUrl(@url,@info)
  end

  def setSeason()
    @importer.setSeason('H',[5,6,7,8,9]," state  in ('WA','MI','OR') and feature_code='WINE' ");
  end

  def testImporter()
    wineries=[{"name"=>"Navarro Vineyards", "city"=>'Philo'},
      {"name" => "Barr Estate Winery", "city" => "Paso Robles"},
      {"name" => "Clos du Bois", "city" => "Geyserville"},
      {"name" => "Benziger Family Winery", "city" => "Glenn Ellen"},
       {"id" => 1500}
      ]
      wineries.each { |w|
        puts "exists" if @importer.recordExists?(w)
        #puts @importer.findRecord(w)
        puts @importer.fetchRecord(w).inspect
      }
  end

  def testParse()
      file='ILwine.htm'
      puts file
      parseDoc(file,@info)
  end
end

aaw= ILwines.new
#aaw.testImporter
#aaw.testParse();
aaw.crawlAll();


