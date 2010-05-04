require 'rubygems'
require 'mechanize'
require 'active_support'
require 'nokogiri'
require 'open-uri'
require 'geocoder'
require 'importer'
require 'yellowpages'
require 'scraper'


class CWAwines < Scraper
  def initialize
    @info = { "country_code" => "US", "feature_code" => "WINE", "source" => "CWA","state"=>"CA" }
    @url='http://www.californiawineryadvisor.com/'
    @url='http://www.californiawineryadvisor.com/regions/view/Mendocino_County'
    @options= {"type"=>"wineries","soft"=>true,"skip"=>"Napa Valley Wineries"}
    super
  end

  def parsePage(doc, info, options={} ) 
    wineries=Hash.new   # to clean out dups
    h = info.dup
    doc.css('h1.winerytitle').each { |l|   # less info
      h['name']= cleanString(l.text)
      ff= l.parent.search('.//br/preceding-sibling::a|.//br/following-sibling::a|.//br/preceding-sibling::text()|.//br/following-sibling::text()')   # examine parts of line item
      ff.each { |p|
        #puts p.inspect
        entry=  cleanString(p.text)
        if entry =~ /(\(?\d{3}\)?.\d{3}.[\w\d]{4})/
          h['phone']=  entry
          break;
        elsif ( entry =~ /^(\w.+)\s+California\s+(\d{5})$/ )
          h['city']=  $1 
          h['postal_code']= $2.strip
        elsif ( entry =~ /^(\w.+),?\s+CA\s+(\d{5})$/ )
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
          #wineries[ h['name'] ] = h
      }
      l.parent.css('tr').each { |p|   # each line item
        #puts p.text 
        if p.text =~ /Tasting:/i
          h['hours']= cleanString(p.text)
        end
        }
    }
    puts h.inspect
    @importer.InsertorUpdatePlaceInDB(h, {'overload'=>true,'soft'=>true})
  end

  def checkRecord( h, options={})
    if @importer.recordExists(h)
      fields = @importer.comparePlaceInDB(h)
      unless fields.size = 0 
        fields.each
        # updateInDB(h)
      end
    end
  end

  def parseMenu(doc, clickpage, info, options={})
    links= Hash.new
    doc.css('td.resulttext a').each { | link |
      nextlink= (link / './@href').text.strip
      links[nextlink]=nextlink unless nextlink.nil? || ! nextlink=~/^\/wineries\/view\//  # to ensure uniqueness
    }
    links.each { |k,v|
      h= info.dup
      puts k
    @agent.transact do
      nextpage = @agent.click(clickpage.link_with(:href => k ))
      sleep(1)    # be kind 
      parsePage(nextpage.noko, info, options)
    end
    }
  end

  def parseMenu2(k, info, options={})
    url= 'http://www.californiawineryadvisor.com'+k
    puts "#{url}  "
    @agent.get(url) { |page|
       parseMenu(page.noko, page ,info,options);
    }
  end

  def parseIndex(doc, clickpage, info, options={})
    #begin
    skip= Regexp.new(@options['skip'],Regexp::IGNORECASE) unless (@options['skip'].blank?)  # skip records 
    links= Hash.new
    doc.css('td.bluemenu a').each { | link |
      nextlink= (link / './@href').text().strip;
      h= @info.dup
      h['name']= link.text().strip;
      next unless nextlink=~ /regions\/view\//;
      puts "#{nextlink} #{h['name']} "
      if ( !skip.blank?)
        if ( skip.match( h['name'] ))
            puts "SKIP #{  h['name']  }"
            skip=nil
        end
        next;
      end
      links[nextlink]= h['name'] unless nextlink.nil?  # to ensure uniqueness
    }
    return links
    links.each { |k,v|
      unless clickpage.nil?
        #@agent.transact do
          nextlink= 'http://www.californiawineryadvisor.com'+k
          #nextpage = @agent.click( clickpage.link_with(:href => k ))
          #parseMenu(nextpage.noko , nextpage , info, options)
          #parseMenu2(nextlink , info, options)
        #end
      end
    }
  end

  def crawlAll()
    doc = Nokogiri::parse( open(@url))
    links = parseIndex( doc, nil, @info ,@options)
    links.each { |k,v|
      parseMenu2(k, @info, @options)
    }
  end

  def testParse()
      file='Blackstone_Winery.htm';
      file='Baywood_Cellars.htm';
      file='www.californiawineryadvisor.com.htm';
      file='Mendocino_County.htm';
      #puts file
      #parseDoc( file ,@info)
      url='
      parseUrl( url ,@info)
      doc = docHandle(file)
      #parseIndex(doc, nil ,@info)
      #parseMenu(doc , nil , @info, @options)
  end
end

aaw= CWAwines.new
#aaw.testParse();
aaw.crawlAll();

