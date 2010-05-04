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

class TXwines < Scraper
  def initialize
    @info = { "country" => "US", "feature_code" => "WINE", "source" => "TXW", "state"=>"TX" }
    @options={'type'=>'wineries','soft'=>true}
    @url='http://www.gotexanwine.org/findwinesandwineries'
    super
  end

  def parsePage(doc, info ) 
    wineries=Hash.new   # to clean out dups
    doc.css('table').each { |t|
      h=info.dup  # new winery
      t.css('tr').each { |r|
        r.css('td').each { |l|   # less info
          l.css('span.visitors').each{ |ll|
            nt= cleanString(ll.text)
            if (nt=~/Visitors Welcome:/)
              h['hours']= cleanString( $`+$')
              #puts "SPAN ="+ h['hours']
            else
              h['hours']= cleanString(nt);
            end
          }
          l.css('a[target="_blank"]').each { |ll|   # less info
            h['url']= ll.search("./@href").text().strip
          }
          l.css('p.southeastwineryname').each{ |ll|
            h['name']= cleanString(ll.text)
            h['name']=$' if (h['name']=~ /^\*/)
          }
          l.css('p.centralwineryname').each{ |ll|
            h['name']= cleanString(ll.text)
            h['name']=$' if (h['name']=~ /^\*/)
          }
          l.css('p.westernwineryname').each{ |ll|
            h['name']= cleanString(ll.text)
            h['name']=$' if (h['name']=~ /^\*/)
          }

          l.css('p.northernwineryname').each{ |ll|
            h['name']= cleanString(ll.text)
            h['name']=$' if (h['name']=~ /^\*/)
          }
          l.css('p.address').each{ |ll|
            lls = ll.search('.//br/preceding-sibling::a|.//br/following-sibling::a|.//br/preceding-sibling::text()|.//br/following-sibling::text()')
          if ( lls.length  > 2) 
            lls.each { |lll|
            if cleanString(lll.text) =~ /(\(\d{3}\).\d{3}.\d{4})/
              h['phone']= $1
            end
            if ( cleanString(lll.text) =~ /(.*),\s*(\w+[^,]+),?\s+(\w\w)\s*(\d{5})/ )
              h['street_address']= cleanString($1)
              h['city']=  $2 
              h['state']= $3
              h['postal_code']= $4.strip
            end
            wineries[ h['name'] ] = h
            }
          end
          }
        }
      }
    }
    wineries.each { |name, h|
      puts "LOADING="+name
=begin
=end
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
      unless ( add.blank? )
        @importer.fillCoord(add)
        #puts "end="+add.inspect
        puts  " found "+ add.inspect
        sleep(1) if enterIntoDB( add, @options) 
      else
        puts  " can't find "+h.inspect
      end
    }
  end

  def parseIndex(doc, clickpage, info={})
    info = { "country" => "US", "feature_code" => "WINE", "source" => "TXW", "state"=>"TX" }
    %w(northern.html western.html southeast.html central.html).each {|file|
        url='http://www.gotexanwine.org/findwinesandwineries/findawinery/'+file
        parseUrl(url,info)
        sleep 1;
    }
  end

  def testParse()
    h = { "country" => "US", "feature_code" => "WINE", "source" => "TXW", "state"=>"TX" }
    %w(northern.html western.html southeast.html central.html).each {|file|
      puts file
      parseDoc(file,h)
    }
  end
end

aaw= TXwines.new
aaw.parseIndex(nil,nil,@info)
#aaw.testParse();
#aaw.crawlAll('http://www.allamericanwineries.com/AAWMain/locate.htm');


