require 'rubygems'
require 'mechanize'
require 'active_support'
require 'nokogiri'
require 'open-uri'
require 'geocoder'
require 'importer'
require 'yellowpages'
require 'scraper'


class MIwines < Scraper
  def initialize
    @info = { "country_code" => "US", "feature_code" => "WINE", "source" => "MIW", "state"=>"MI" }
    @url='http://www.michiganwines.com/page.php?menu_id=106'
    super
  end

  def parsePage(doc, info ) 
    wineries=Hash.new   # to clean out dups
    h = info.dup
    doc.css('div.content').each { |c|   # less info
      doc.css('h1').each { |l|   # label
        h['name']=l.text
      }
      doc.css('p').each { |l|   # each line item
        l.css('a[target="_blank"]').each { |a|
          h['url']=a.search("./@href").text
          next;
        }
        lls = l.search('.//br/preceding-sibling::b|.//br/following-sibling::b|.//br/preceding-sibling::text()|.//br/following-sibling::text()')   # examine parts of line item
        lls.each { |lll|
          entry=  cleanString(lll.text)
          if ( entry =~ /^hours:/i )
            hh= cleanString(l.text)
            if (hh=~/hours:/i)
              h['hours']= $'.strip;
            end
            break;
          elsif ( entry =~ /^directions:/i )
            break;
          elsif entry =~ /(\d{3}.\d{3}.[\w\d]{4})/
            h['phone']=  entry
            break;
          elsif ( entry =~ /^(\w.+)\s+Michigan\s+(\d{5})$/ )
            h['city']=  $1 
            h['postal_code']= $2.strip
          elsif ( entry =~ /^(\w.+)\s+MI\s+(\d{5})$/ )
            h['city']=  $1 
            h['postal_code']= $2.strip
          elsif ( entry =~ /^(\w.+)\s+(\d{5})$/ )
            h['city']=  $1 
            h['postal_code']= $2.strip
          else
            if h['street_address'].blank?
              h['street_address']= entry
            else
              h['street_address']= h['street_address'] +" "+ entry
            end
          end
          wineries[ h['name'] ] = h
        }
      }
    }
    puts h.inspect
    enterIntoDB(h,{"type"=>"wineries","soft"=>true})
  end

  def parseIndex(doc, clickpage, info={})
    begin
    doc.css('a').each { | link|
      nextlink= (link / './@href').text().strip;
      next unless (  nextlink =~/page.php\?page_id=/i )
      unless clickpage.nil?
        @agent.transact do
          nextpage = @agent.click(clickpage.link_with(:href => nextlink ))
          puts parsePage(nextpage.noko, @info ) # the city page get temperatures
          sleep(1)    # be kind 
        end
      end
    }
    rescue => e # regular rescue only deals with stderr
    end
  end

  def testParse()
      file='page.php';
      puts file
      parseDoc('2lads.html',@info)
      #doc = docHandle('Miwines.html')
      #parseIndex(doc, nil ,@info)
  end
end

aaw= MIwines.new
#aaw.testParse();
aaw.crawlAll();


