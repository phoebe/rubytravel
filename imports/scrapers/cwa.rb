require 'rubygems'
require 'mechanize'
require 'active_support'
require 'nokogiri'
require 'open-uri'
require 'scraper'


class CWAwines < Scraper
  def initialize
    @info = { "country_code" => "US", "feature_code" => "WINE", "source" => "CWA","state"=>"CA" }
    @url='http://www.californiawineryadvisor.com/'
    @url1='http://www.californiawineryadvisor.com/regions/view/Mendocino_County'
    @options= {"type"=>"wineries","soft"=>true,'overload'=>true}
    @links={
      #'/regions/view/Mendocino_County'=>'Mendocino County Wineries ',
      #'/regions/view/Monterey_-_San_Benito_Counties'=>'Monterey - San Benito Counties Wineries ',
      #'/regions/view/Napa_Valley'=>'Napa Valley Wineries ',
      '/regions/view/Paso_Robles'=>'Paso Robles Wineries ',
      '/regions/view/Santa_Barbara'=>'Santa Barbara Wineries ',
      '/regions/view/Santa_Clara_Valley'=>'Santa Clara Valley Wineries ',
      '/regions/view/Santa_Cruz_County'=>'Santa Cruz County Wineries ',
      '/regions/view/San_Luis_Obispo'=>'San Luis Obispo Wineries ',
      '/regions/view/Sierra_Foothills'=>'Sierra Foothills Wineries ',
      '/regions/view/Sonoma_County'=>'Sonoma County Wineries ',
      '/regions/view/Temecula'=>'Temecula Wineries ',
      '/regions/view/Lodi'=>'Lodi Wineries ',
      '/regions/view/Livermore'=>'Livermore Wineries ',
      '/regions/view/Lake_County'=>'Lake County Wineries ',
      '/regions/view/Ventura,_Ojai_and_Malibu'=>'Ventura, Ojai & Malibu Wineries '}
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
    @importer.InsertorUpdatePlaceInDB(h, @options)
  end

  def parseMenu(doc, clickpage, info, options={})
    links= Hash.new
    doc.css('td.resulttext a').each { | link |
      nextlink= (link / './@href').text.strip.to_s
      links[nextlink]=nextlink if ( !nextlink.blank? && nextlink=~/^\/wineries\/view/i )  # to ensure uniqueness
    }
    links.each { |k,v|
      puts k
    @agent.transact do
      nextpage = @agent.click(clickpage.link_with(:href => k ))
      sleep(1)    # be kind 
      parsePage(nextpage.noko, info, options)
    end
    }
  end

  def parseMenu2(doc, info, options={})
    pages= Hash.new
        # w3 rec a[href|="<prefix>"] doesn't work
    doc.css('a[href]').each { | link |
      href=link[:href]  
      if ( href =~ /page=\d+/)
        pages[href]= href unless href.nil?  # to ensure uniqueness
      end
    }
    return pages
  end

  def parseIndex(doc, clickpage, info, options={})
      #<td align="right"><-Previous <em>1</em> | <a href="/wineries/browse/Santa_Barbara/?page=2" >2</a> | <a href="/wineries/browse/Santa_Barbara/?page=3" >3</a> | <a href="/wineries/browse/Santa_Barbara/?page=4" >4</a> <a href="/wineries/browse/Santa_Barbara/?page=2" >Next-></a></td>
    #begin
    skip= Regexp.new(@options['skip'],Regexp::IGNORECASE) unless (@options['skip'].blank?)  # skip records 
    @links= Hash.new
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
      @links[nextlink]= h['name'] unless nextlink.nil?  # to ensure uniqueness
    }
  end

  #overload
  def crawlAll()
    links=Hash.new
    @links.each { |k,v|
      puts @url+k
      doc = urlHandle(@url+k)
      links.merge!(parseMenu2( doc , @info, @options))
    }
    puts links.inspect
    links.each {|k,v|
      @agent.get(@url+k) { |page|
        parseMenu(page.noko , page , @info, @options)
      }
    }
  end

  def testParse()
      file='Blackstone_Winery.htm';
      file='Baywood_Cellars.htm';
      file='www.californiawineryadvisor.com.htm';
      file='Mendocino_County.htm';
      file='Paso_Robles.htm';
      file='page5.htm';
      #
      #puts file
      #parseDoc( file ,@info)
      doc = docHandle(file)
      #parseIndex(doc, nil ,@info)
      parseMenu(doc , nil , @info, @options)
      #doc.search('a[href]').each { | link |
  end
end

aaw= CWAwines.new
#aaw.testParse();
aaw.crawlAll();

