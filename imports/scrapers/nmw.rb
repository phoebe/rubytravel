require 'rubygems'
require 'mechanize'
require 'active_support'
require 'nokogiri'
require 'open-uri'
require 'geocoder'
require 'importer'
require 'yellowpages'
require 'scraper'


class NMwines < Scraper
  def initialize
    @info = { "country_code" => "US", "feature_code" => "WINE", "source" => "NMW","state"=>"NM" }
    @url='http://www.nmwine.com/'
    @options= {"type"=>"wineries","soft"=>true}
    super
  end

  def parsePage(doc, info ) 
    h = info.dup
    doc.css('div[class="itemView"]').each { |item|   # less info
      item.css('a.website').each { |a|
        url= a.search("./@href").text
        h['url']= url if ( url=~/^http:/ || !url =~/^mailto:/ )
      }
      item.css('[class="itemTitle"]').each { |p|
         h['name']= cleanString( p.text) if h['name'].blank?
      }
      item.css('div.itemExtraFields').each { |l|   # less info
        l.css('li.address').each { |p|
          entry=cleanString(p.text)
          if ( entry =~ /^(\w.+)\s+New Mexico\s+(\d{5})$/i )
            h['city']=  $1 
            h['postal_code']= $2.strip
          elsif ( entry =~ /^(\w.+),?\s+\w{2}\s+(\d{5})$/i )
            h['city']=  $1 
            h['postal_code']= $2.strip
          elsif ( entry =~ /^(\w.+),?\s+(\d{5})$/ )
            h['city']=  $1 
            h['postal_code']= $2.strip
          else
            if h['street_address'].blank?
                h['street_address']= entry
            else
              h['street_address']= h['street_address'] +" "+ entry
            end
          end
        }
        l.css('li.hours').each { |p|
          entry=  cleanString(p.text)
          if entry =~ /hours of operation:/
            h['hours']=  $'
          end
        }
        l.css('li.itemInfo').each { |p|
          entry=  cleanString(p.text)
          if entry =~ /(\d{3}.\d{3}.[\w\d]{4})/
            h['phone']=  entry
          end
        }
        #lls = p.search('.//br/preceding-sibling::b|.//br/following-sibling::b|.//br/preceding-sibling::text()|.//br/following-sibling::text()')   # examine parts of line item
      }
    }
    puts h.inspect
    enterIntoDB(h,@options)
  end

  def parseIndex(doc, clickpage, info, options={})
    #begin
    skip= Regexp.new(@options['skip'],Regexp::IGNORECASE) unless (@options['skip'].blank?)  # skip records 
    doc.css('a.moduleItemTitle').each { | link|
      nextlink= (link / './@href').text().strip;
      h= @info.dup
      h['name']= link.text().strip;
      next unless (  nextlink =~/\w+.htm/i )
      unless clickpage.nil?
        @agent.transact do
          if ( !skip.blank?)
            if ( skip.match(h['name']))
              puts "SKIP"
              skip=nil
            end
            next;
          end
=begin
          puts " #{h.inspect} #{nextlink} "
           if (@importer.recordExists?(h))
             puts " #{h['name']} already inserted"
           else
            puts "NEW #{h.inspect}"
=end
            nextpage = @agent.click(clickpage.link_with(:href => nextlink ))
            puts parsePage(nextpage.noko, h ) # the city page get temperatures
            sleep(1)    # be kind 
=begin
          end
=end
        end
      end
    }
=begin
    rescue => e # regular rescue only deals with stderr
      puts "Error: #{$0} parseIndex"
    end
=end
  end

  def testParse()
      %w(14-milagro-vineyards.html 23-amaro-winery.html 24-la-viña-winery.html).each { |file|
        puts file
        #parseDoc( file ,@info )
        doc = docHandle(file)
        parsePage(doc, @info)
        #parseIndex(doc, nil ,@info)
      }
      url='http://www.nmwine.com/component/k2/item/37-acequia-vineyards-winery.html'
      parseUrl( url ,@info )
  end
end

aaw= NMwines.new
#aaw.testParse();
aaw.crawlAll();

