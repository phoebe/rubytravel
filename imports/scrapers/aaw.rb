require 'rubygems'
require 'mechanize'
require 'active_support'
require 'nokogiri'
require 'open-uri'
require 'geocoder'
require 'importer'
require 'yellowpages'
require 'scraper'


=begin
  class String
      alias_method :old_strip, :strip
  def strip
    self.gsub(/^[\302\240|\s]*|[\302\240|\s]*$/, '')
  end

  def strip!
    before = self.reverse.reverse # TODO there must be a better way to do this. Don't have time. -Mark 2/9/09
    self.gsub!(/^[\302\240|\s]*|[\302\240|\s]*$/, '')
    before == self ? nil : self
  end
end
=end

class Allamericanwines < Scraper
  def initialize
    @info = { "country" => "US", "feature_code" => "WINE", "source" => "AAW" }
    @url='http://www.allamericanwineries.com/AAWMain/locate.htm'
    super
  end

  def parsePage(doc, info, options={} ) 
    wineries=Hash.new   # to clean out dups
    doc.css('table').each { |t|
      t.css('tr').each { |r|
        last_w={}
        r.css('td[width="70%"]').each { |l|   # less info
          if ( cleanString(l.text) =~ /(.*), (.*)$/ )
            h=info.dup
            h['name']=  cleanString($1)
            h['city']= $2
            wineries[ h['name'] ] = h
            last_w=h
          end
        }
        r.css('td[width="57%"]').each { |l|   # more info
          ll = l.search('.//br/preceding-sibling::a|.//br/following-sibling::a|.//br/preceding-sibling::text()|.//br/following-sibling::text()')
          if ( ll.length  > 2) 
            h=info.dup
            last_w=h
            h['name']= cleanString(ll[0].to_s)
            i=1
            temp = cleanString(ll[i].text)
            if (temp=~/\w{2,}\.\w{2}/) # mininum req for address
              h['url'] = temp
              i=i+1
            elsif (temp=~/Website:/) # space
              i=i+1
            end
            h['street_address']= cleanString(ll[i].text)
            i=i+1
            if ( cleanString(ll[i].text) =~ /(.*),\s*(\w\w)\s*(\d{5})/ )
              h['city']=  $1 
              h['state']= $2
              h['postal_code']= $3.strip
            end
            wineries[ h['name'] ] = h
          end
        }
        r.css('td[width="18%"]').each { |l|   
          if cleanString(l.text) =~ /(\d{3}.\d{3}.\d{4})/
            last_w['phone']= $1
          end
        }
      }
    }
    wineries.each { |name, h|
      if !@importer.recordExists?(h)
        add= @importer.yplookup(h)
        if ( add.blank? )
          h2=h.dup
          h2.delete("city")
          add= @importer.yplookup(h2,{"type"=>"wineries"})   # bad address?
        end
        unless @importer.UrlAvailable?(h['url'])
          h.delete('url')
        end
        sleep 1;
        if ( !add.blank? )
          @importer.fillCoord(add)
          #puts "end="+add.inspect
          puts  " found "+ add.inspect
          sleep(1) if @importer.insertPlaceIntoDB(add)
        elsif ( !h['url'].blank? && !h['city'].blank? && !h['name'].blank? )
          puts  " name/city/url is good enough "+ h.inspect
          sleep(1) if @importer.insertPlaceIntoDB(h)
        else
          puts  " can't find "+h.inspect
        end
      else
          puts  " already inserted #{ h['name'] }"
      end
    }
  end

  def parseIndex(doc, clickpage, options={})
    rec = { "country_code" => "US", "feature_code" => "WINE", "source" => "AAW" }
    puts "options="+options.inspect
    skip= options['skip']   unless ( options['skip'].blank? )
    clickpage.links.each do |link|
        if ( link.text =~ /(\w{2})\s+-\s+(.*)$/ )
          h = rec.dup
          h['state']= $1.strip;
          h['admin1_code']= $1.strip;
          puts  $2
          if (!skip.blank?)
            skip=nil if ( h['state']==skip)
            next
          end
          @agent.transact do 
            page = @agent.click(link)
            puts link.inspect
            parsePage( page.noko , h, options)
            sleep 1;
          end
        end
    end
  end

  def testParse()
    h = { "country_code" => "US", "feature_code" => "WINE", "source" => "AAW" }
    file = "ResultsHI.htm"
    file = "ResultsAZ.htm"
    #doc = Nokogiri::parse(File.open(file))
    h['state']='AK';
    file = "ResultsME.htm"
    #parseDoc(file,h)
    #parsePage(doc,h)
    parseUrl('http://www.allamericanwineries.com/AAWMain/ResultsAK.htm',h);
  end
end

aaw= Allamericanwines.new
aaw.testParse();
aaw.crawlAll('http://www.allamericanwineries.com/AAWMain/locate.htm',{"skip"=>"AL"});

