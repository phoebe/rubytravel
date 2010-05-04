require 'rubygems'
require 'mechanize'
require 'active_support'
require 'nokogiri'
require 'open-uri'
require 'geocoder'
require 'importer'
require 'yellowpages'
require 'scraper'


class MOwines < Scraper
  def initialize
    @info = { "country_code" => "US", "feature_code" => "WINE", "source" => "MOW","state"=>"MO" }
    @url='http://www.missouriwine.org/wineries/default.htm'
    @options= {"type"=>"wineries","soft"=>true,"skip"=>"oovvda"}
    super
  end

  def parsePage(doc, info ) 
    wineries=Hash.new   # to clean out dups
    h = info.dup
    doc.css('div[id="content"]').each { |c|   # less info
      c.css('p').each { |p|   # each line item
        c.css('h3 strong').each { |l|   # label
          h['name']= cleanString(l.text)
        }
        p.css('span.contentsubheader').each { |l|   # label
          h['name']= cleanString(l.text)
        }
        p.css('a').each { |a|
          url= a.search("./@href").text
          h['url']= url if ( url=~/^http:/ || !url =~/^mailto:/ )
        }
        lls = p.search('.//br/preceding-sibling::b|.//br/following-sibling::b|.//br/preceding-sibling::text()|.//br/following-sibling::text()')   # examine parts of line item
        next unless (lls.length > 2)
        lls.each { |lll|
          entry=  cleanString(lll.text)
          if entry =~ /(\d{3}.\d{3}.[\w\d]{4})/
            h['phone']=  entry
            break;
          elsif ( entry =~ /^(\w.+)\s+Michigan\s+(\d{5})$/ )
            h['city']=  $1 
            h['postal_code']= $2.strip
          elsif ( entry =~ /^(\w.+),?\s+MO\s+(\d{5})$/ )
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
          wineries[ h['name'] ] = h
        }
      }
    }
    puts h.inspect
    enterIntoDB(h,@options)
  end

  def parseIndex(doc, clickpage, info, options={})
    #begin
    skip= Regexp.new(@options['skip'],Regexp::IGNORECASE) unless (@options['skip'].blank?)  # skip records 
    doc.css('table.content').each { | tablelist|
    tablelist.css('a').each { | link|
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
          puts " #{h.inspect} #{nextlink} "
=begin
           if (@importer.recordExists?(h))
             puts " #{h['name']} already inserted"
           else
=end
            puts "NEW #{h.inspect}"
            nextpage = @agent.click(clickpage.link_with(:href => nextlink ))
            puts parsePage(nextpage.noko, h ) # the city page get temperatures
            sleep(1)    # be kind 
=begin
          end
=end
        end
      end
    }
    }
=begin
    rescue => e # regular rescue only deals with stderr
      puts "Error: #{$0} parseIndex"
    end
=end
  end

  def testParse()
      file='mountpleasant.htm';
      puts file
      parseDoc( file ,@info)
      doc = docHandle(file)
      #parseIndex(doc, nil ,@info)
  end
end

aaw= MOwines.new
#aaw.testParse();
aaw.crawlAll();

