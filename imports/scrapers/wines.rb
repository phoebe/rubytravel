require 'rubygems'
require 'mechanize'
require 'active_support'
require 'nokogiri'
require 'open-uri'
require 'geocoder'
require 'importer'
require 'yellowpages'
require 'scraper'

#require 'stringex' # adds String#to_ascii method
# Will crawl sites for wine info

class CAWines
  def initialize()
    @importer= Importer.new('');
  end

  def parseUrl(url)
    doc = Nokogiri.parse(open(url));
    parseDoc(doc);
  end

  def parseFile(file)
    doc = Nokogiri.parse(File.open(file));
    parseDoc(doc);
  end

  def parseDoc(doc)
    arr=[];
    lasttag='';
    url='';
    lname='';
    xpath='//a|//a/following-sibling::text()' # link or what follows immediately
    doc.search(xpath).each { |a|
      name = a / 'text()';   # anchor of a link
      if ( a.text =~ /\((.*)\)/ ) 
        town = $1.downcase
        if (lasttag=='url')  # last element was link
          #puts "URL = #{url}  = #{lname} = #{town} " 
          h=Hash[ 'url'=>url,'name'=>lname,'city'=>town]
          arr<< h
        end
      end
      unless name.empty?    # if it has anchor then check link
        link = a / './@href';
        link=link.text.downcase
        if ( link =~ /url=(http:.*$)/ )  # it's the correct format
          url=$1
          lname= name.text.strip.gsub(/[\r\n\t\s]+/,' ').downcase
          #puts "URL = #{url}  = #{lname} " 
          lasttag='url';      # now wait for the element to follow
          next;
        end
      end
      lasttag='';
    }
    puts " GOT "+ arr.length.to_s+ " results "
    return arr;
  end

  def ProcessUrl(f)
    parseUrl(f).each { |h|  # pause between each successful insert and lookup from yellowpages
      # h has name, city and maybe url filled in
      h['state']='CA';
      h['source']='CAW'; # ack http://www.oregonwines.com/
      h['country_code']='US';
      h['feature_code']='WINE';
      next if ( @importer.recordExists?(h))
      add= @importer.yplookup(h)
      unless ( add.nil? )
        @importer.fillCoord(add)
        puts add.inspect
        sleep(1) if @importer.insertPlaceIntoDB(add)
      else
        unless ( h['name'].empty? && h['city'].empty? )
          @importer.fillCoord(h)
          puts h
          @importer.insertPlaceIntoDB(h)
        end
      end
    }
  end
end

def CaliforniaWines
  p= Importer.new('');
  caw=CAWines.new
  caw.ProcessUrl('http://cawinemall.com/r-s.shtml')
  #caw.ProcessUrl('http://cawinemall.com/a-c.shtml')
  @CA= [ 'http://cawinemall.com/a-c.shtml','http://cawinemall.com/d-g.shtml','http://cawinemall.com/h-l.shtml','http://cawinemall.com/m-q.shtml','http://cawinemall.com/r-s.shtml','http://cawinemall.com/t-z.shtml'];
  @CA.each { |a|
    puts a
    #caw.ProcessUrl(a);
  }
  @CA= [ 'http://cawinemall.com/a-c.shtml','http://cawinemall.com/d-g.shtml','http://cawinemall.com/h-l.shtml','http://cawinemall.com/m-q.shtml','http://cawinemall.com/r-s.shtml','http://cawinemall.com/t-z.shtml'];
  @CA.each
=begin # uncomment to patch missing gaps
  f='r-s.shtml'
  caw.parseFile(f).each { |a|       
      sleep(1) if p.from_yp(a['name'], a['city'],'CA','USA','S','WINE','CAW',a['url']);
      puts " #{a['name']}, #{a['city']},'CA','USA','S','WINE','CAW',#{a['url']}";
  }
=end
end

class NokoParser < Mechanize::Page
  attr_reader :noko
  def initialize(uri = nil, response = nil, body = nil, code = nil)
    @noko =  Nokogiri.parse(body)
    super(uri, response, body, code)
    follow_meta_refresh = true
  end
end

class ORWines
  def initialize()
    @agent = Mechanize.new 
    @agent.pluggable_parser.html = NokoParser
    @importer =  Importer.new('')
  end

  def parse(page) 
    nextstart=90
    hasMore=true
    @agent.get(page) { |nextpage|
      while ( hasMore )
        hasMore= oregonwine2(nextpage);
        next30 = nextpage.form_with(:action => '/winerysearch.php', :method => 'POST' )
        next30.tastingroom="1"
        next30.browsetype  = "tastingroom"
        nextstart = nextstart + 30 # next30.nextlimit.to_i
        next30.start = nextstart.to_s

        next30.fields.each { |f| puts " #{f.name} #{f.value} " }
        #puts "YAY" if (next30.start=='30')
        puts "  NEXT PAGE @ "+ next30.start
        if ( hasMore  ) # 
          sleep(2);
          nextpage = next30.submit
        else
          break;
        end
      end
    }
  end

=begin
  next30 = home_page.form_with(:action => '/winerysearch.php', :method => 'POST' ) do |f|
           # f.browsetype  = "tastingroom"
           f.browsetype  = "directory"
           f.searchlabel = ""
           f.VarietalID="0"
           f.wineryname =""
           f.city  = ""
           f.majorcity  = ""
           f.tastingroom="0"
           f.orderby  = "wineryname"
           f.start  = "30"
           f.nextlimit  = 30
           f.action  = "Search"
           f.submit = "Next 30 &gt;";
    end.submit
    oregonwine2(f)
=end

  def oregonwine2(httppage)
    textf = httppage.noko.search('//td/span[@class="subtext"]/*|//td/span[@class="subtext"]/text()');
    max= textf.length()
    i=0;
    h=Hash.new
    while ( i+4 <= max ) do
      if ( textf[i+3].text =~ /Yes/i )
        h.clear;
        name= textf[i] / 'text()';
        h['state']='OR';
        h['source']='ORW'; # ack http://www.oregonwines.com/
        h['country_code']='US';
        h['feature_code']='WINE';
        h['name']= name.text ;
        h['street_address'] = textf[i+1].text;
        h['city'] = textf[i+2].text.split(',')[0];
        add= @importer.yplookup(h)
        unless ( add.nil? )
          @importer.fillCoord(add)
          puts add
          sleep(1) if @importer.insertPlaceIntoDB(add)
        else
          unless ( h['name'].empty? && h['city'].empty? )
            @importer.fillCoord(h)
            puts h
            @importer.insertPlaceIntoDB(h)
          end
        end
      end
      i=i+4
    end
    return (max > 100 )
  end

end

class COwines < Scraper
  def initialize()
    @info= {"country_code"=>"US","source"=>"COW","state"=>"CO", "feature_code"=>"WINE"}
    @url='http://www.coloradowine.com/wineries/wineriesList.cfm'
    @options={"type"=>"wineries"}
    super
  end

  def parsePage(doc,h) 
    doc.css('tr').each { |tr|
      td= tr.search('./td')
      next if td[1].blank? || td[0].blank?
      if ( td[0].text()=~/Location:/i ) 
        ttt= td[1].search("./br/preceding-sibling::text()|./br/following-sibling::text()");
        tts= ttt.map{ |c| c.to_s }
        if ( tts.length > 0 )
          temp = tts * ",".strip
          puts " #{temp} #{tts.length} #{tts.inspect}" unless temp.blank?
        else
          temp=td[1].text.strip
          puts " #{temp}"  unless temp.empty?
        end
        if (temp =~ /^(.+),\n?\s*(\w[^,]+)\s*,\s*CO\s*,?\s*(\d{5})$/im)
          h['street_address']= $1.strip
          h['city']= $2.strip
          h['state']= 'CO'
          h['zip']= $3.strip
        elsif (temp =~ /^(.+)[,\s]+(\w[^,]+)\s*,\s+CO\s*,?\s*(\d{5})$/im)
          h['street_address']= $1.strip
          h['city']= $2.strip
          h['state']= 'CO'
          h['zip']= $3.strip
        elsif (temp =~ /^(.+),?\s*\w{2}\s+(\d{5})$/im)
          h['city']= $1.strip
          h['state']= 'CO'
          h['zip']= $2.strip
        end
      elsif ( td[0].text()=~/email:/i ) 
        h['email']= td[1].text().strip
      elsif ( td[0].text()=~/phone:/i ) 
        h['phone']= td[1].text().strip
      elsif ( td[0].text()=~/Web Site:/i ) 
        h['url']= td[1].text().strip
        h['url']= "http://"+h['url']    unless ( h['url']=~/http:\/\// ) # check for http
        h.delete('url')  unless (@importer.UrlAvailable?(h['url'])) # keep only if good
      elsif ( td[0].text()=~/Tasting room/i ) 
        h['tasting']=td[1].text().strip
      elsif ( td[0].text()=~/Hours/i ) 
        h['hours']=td[1].text().strip
      end
    }
    puts h.inspect
    enterIntoDB(h, @options)
  end

  def crawlAll() 
    h= Hash.new
    @agent.get(@url) { |page|
       #<a href="wineryDetail.cfm?wineryID=16">Garfield Estates Vineyard & Winery</a><br>
        page.noko.css('a').each { |l|
          h.clear
          h['info']= (l / './@href').text().strip;
          if (h['info'] =~ /wineryDetail.cfm/) 
            h['name']= l.text().strip
            if (h['name']=~ /\(tasting room\)/mi )
              h['name']=$`.strip
            end
            h['country_code']='US';
            h['state']='CO';
            h['source']='COW'; # ack 
            #add= @importer.yplookup(h)
            @agent.transact do
              wine_page = @agent.click(page.link_with(:href => h['info']))
              add = parsePage(wine_page.noko, h) 
              sleep(1)
              #sleep (5)
              #sleep(1) if @importer.insertPlaceIntoDB(add)
            end
          end
        }
    }
  end

  def testParse() 
    #parseDoc('wineryDetail.cfm', @info )
    %w(wineryDetail.cfm wineryDetail2.cfm wineryDetail3.cfm wineryDetail4.cfm wineryDetail5.cfm wineryDetail6.cfm).each{ |f|
      doc = Nokogiri::parse(File.open(f))
      h=@info.dup
      parsePage(doc, h) 
    }
  end
end
def coloradoWine
  cowine = COwines.new
  cowine.crawlAll
  #cowine.testParse
end
coloradoWine

class WAwines
  def initialize()
    @agent = Mechanize.new 
    @agent.pluggable_parser.html = NokoParser
    @importer =  Importer.new('')
    @winery='http://www.washingtonwine.org/washington-wine/results.php?type=winery&cat=View%20All';
    @vineyard='http://www.washingtonwine.org/washington-wine/results.php?type=vineyard&cat=View%20All';

  end

  def crawlAll(options={}) 
=begin
    info= {"country_code"=>"US","state"=>"WA","admin1_code"=>"WA","source"=>"WAW", 'feature_code'=>'WINE'}
    @agent.get(@winery) { |page|
         parseAll( page.noko, page, info, options )
    }
=end
    info= {"country_code"=>"US","state"=>"WA","admin1_code"=>"WA","source"=>"WAW", 'feature_code'=>'VIN'}
    @agent.get(@vineyard) { |page|
         parseAll( page.noko, page, info, options )
    }
  end

  def parseAll( doc, page, info, options={}) 
      skip= options['skip']   unless ( options['skip'].blank? )
      doc.css('div[id="mapResultsList"]').each { |win|
        win.css('h2 a').each { |link|
          info['info']= (link / './@href').text().strip;
          info['name']= link.text.strip
          if (!skip.blank?)
            skip=nil if ( info['name']==skip) 
            next
          end
          @agent.transact do  
            h=info.dup
            wine_page = @agent.click(page.link_with(:href => h['info']))
            if ( parseAddress(wine_page.noko, h))
              sleep(1) if @importer.insertPlaceIntoDB(h)
            end
          end
        }
      }
  end

  def parseAddress(doc,h) 
    title = doc.css('h1')
    puts title
    doc.css('div.snapshot').each { |d|
      d.css( "strong").each { |strong|
      if ( strong.text() =~ /Hours of Operation/i )
        tt = strong.search( "./following-sibling::text()")
        h['hours']=tt.text.strip
      end
      if ( strong.text() =~ /Open to the public/i )
        tt = strong.search( "./following-sibling::text()")
        h['open']=tt.text.strip
      end
      }
    }
    doc.css('div.vcard').each { |d|
      d.css('span.tel').each { |f|
        h['phone']= f.text
      }
      d.css('a.url').each{ |f|
        h['url']=f.text
      }
       h['street_address']=""
       h['city']=""
       h['state']=""
       h['postal_code']=""
      d.css('div.adr').each{ |a|
        a.css('div.street-address').each{ |f|
          h['street_address']= h['street_address'] + f.text().strip
        }
        a.css('abbr.region').each{ |f|
          h['state']=f.text().strip
        }
        a.css('span.locality').each{ |f|
          h['city']= h['city']+ f.text().strip
        }
        a.css('span.postal-code').each{ |f|
          ss = f.text().strip
          if (ss =~ /(\d{5})/)
            h['postal_code'] = $1
          end
        }
        break;
      }
    }
    puts h.inspect
    if (h['open']=~/yes/i  && !h['city'].blank? && !h['url'].blank? )
      @importer.fillCoord(h) unless h['street_address'].blank? && h['city'].blank?
      return true;
    end
    return false;
  end

  def test()
    h= { "state" => "WA", "country_code" => "US", "source" => "WAW" , 'feature_code'=>'WINE'}
    #url='http://www.washingtonwine.org/washington-wine/wineries/37-cellars/'
    #doc = Nokogiri.parse(open(url));
    #%w(zefina-winery.htm 37-cellars.htm yvcc-teaching-winery.htm).each { | file|
    %w(chesterkidder.htm agate-field-vineyard.htm).each { | file|
      doc = Nokogiri.parse(File.open(file));
      parseAddress(doc,h) 
    }
=begin
    doc = Nokogiri.parse(File.open('wawines.html'));
    parseAll( doc, nil, info,options )
=end

  end

end

def OregonWines()
  url='http://www.oregonwines.com/winerysearch.php?action=Search&browsetype=tastingroom&start=90&orderby=wineryname&nextlimit=30'
  orwines= ORWines.new()
  orwines.parse(url);
end

def WashingtonWines
  wa = WAwines.new()
  #wa.crawlAll({'skip'=>'Cougar Creek Wine'})
  wa.crawlAll()
#wa.test()
end


#OregonWines()
#CaliforniaWines()

class Allamericanwines < Scraper
  def parseDoc(doc,h) 
    doc.css('table').each { |t|
      t.css('tr').each { |r|
        r.css('td[width="57%"]').each { |list|
          h['name']= list.search('br/preceding-sibling::text()')
          ll= list.search('br/following-sibling');
          if ( ll.length  > 2) 
            h['url']= ll[0].text
            h['street_address']= ll[1].text
            ll[2] =~ /(.*), (\w\w) (\d{5}) \(.*$/
            h['city']= $1
            h['state']= $2
            h['postal_code']= $3
          end
        }
        r.css('td[width="70%"]::text').each { |list|
          if ( list =~ /(.*), (.*)$/)
            h['name']=$1
            h['city']=$2
          end
        }
      }
    }
  end

  def testParse()
    h={"country"=>"US","feature_code"=>"WINE"}
    file="ResultsAZ.htm"
    parseDoc(file,h)
  end
end

#aaw= Allamericanwines.new
#aaw.testParse();

