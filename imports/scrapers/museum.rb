require 'rubygems'
require 'mechanize'
require 'active_support'
require 'nokogiri'
require 'open-uri'
require 'geocoder'
require 'importer'
require 'yellowpages'
require 'scraper'
require 'USstates'


class Museums < Scraper
  def initialize
    @info = { "country_code" => "US", "feature_code" => "MUS", "source" => "MUS" }
	@url='http://www.museumstuff.com/'
	@murl='http://www.museumstuff.com/museums/'
    @options= {"type"=>"museums","soft"=>true,'overload'=>true}
    @citylinks=Hash.new
	@nextpages=Hash.new
    super
  end


  def parsePage(doc, info, options={} ) 
    h = info.dup
	doc.css('div.breadrec').each { |l|
	  category=l.text
	  nn=l.css('b');  h['name']= cleanString(nn.text) unless nn.nil?  
	  ff= l.parent.css('br')   # examine parts of line item
	  name=ff[0].previous_sibling.text
      ff.each { |p|
        #entry=  cleanString(p.next_sibling.text)
        entry=  cleanString(p.previous_sibling.text)
        #puts "BR= #{ p.inspect } --  #{p.previous_sibling} -- #{ p.next_sibling} "
        if entry =~ /(\(?\d{3}\)?.\d{3}.[\w\d]{4})/
          h['phone']=  entry
          break;
        elsif ( entry =~ /^(\w.+),?\s+(\w{2})\s*,?\s+(\d{5})$/ )
          h['city']=  $1.chomp(',')
          h['state']=  $2 
          h['postal_code']= $3.strip
        elsif ( entry =~ /^(\w.+),?\s+(\w{2})\s+(\d{5})$/ )
          h['city']=  $1.chomp(',')
          h['state']=  $2 
          h['postal_code']= $3.strip
		elsif h['name'].blank?
            h['name']= entry
		else
          if h['street_address'].blank?
            h['street_address']= entry
          else
            h['street_address']= h['street_address'] +" "+ entry
          end
	    end
	  }
	  h['street_address'].chomp!(',')
		ll= l.parent.search('.//a[@href]')
		h['url']= ll[2].text if !ll[2].nil? &&  ll[2][:href] == ll[2].text
		  #$puts "A= #{ p.inspect } --  #{p.previous_sibling } -- #{ p.next_sibling } "
		 ff= l.parent.css('p')
	 ff.each { |p| 
        #puts "P= #{ p.inspect } --  #{p.previous_sibling.text } -- #{ p.next_sibling.text } "
        entry=  cleanString(p.text)
        if ( entry =~ /^URL/ )
          h['url']= cleanString( entry )
        elsif ( entry =~ /^hours\s*:?/i )
			str= cleanString( $')
			if ( str =~ /\(subject to change\)\s*:?/i )
			  h['hours']= cleanString( $')
			else
			  h['hours']= cleanString( str )
			end
        elsif ( entry =~ /^collections/i )
        elsif ( entry =~ /^topics\s*:?/i )
          h['use_code']= cleanString( $')
        elsif ( entry =~ /^overview\s*:?/i )
          h['note']= cleanString( $')	# Just to get a topic if missing
		end
      }
    }
    puts h.inspect
    @importer.InsertorUpdatePlaceInDB(h, @options)
  end

  def parseMenu(doc, clickpage, info, options={})
    doc.css('div.boxlist ul li a[href]').each { | link |
      nextlink= (link / './@href').text.strip.to_s
      @citylinks[nextlink]=nextlink if ( !nextlink.blank? && nextlink=~/\/go\.php\?city/i )  # to ensure uniqueness
    }
  end

  def parseNext(doc, clickpage, info, options={})
    doc.css('div.divbar').each { | link |
		eee= link.next_sibling.text.strip 
		if ( eee =~ /^pages/im ) 
		(link.parent.search('./a/@href')).each { |fff|
			fff = fff.to_s.strip
			@nextpages[ fff ]=true
		}
		end
	}
	@nextpages.delete( clickpage ) unless clickpage.nil?
	return @nextpages;
  end

  def followNextMenu( nextpages , info, options={})
	@nextpages.each { |k,v|
	begin
		puts "follow #{k}"
		  doc = urlHandle(k)
		rescue
			puts "Error in followNextMenu  #{k}";
			sleep rand(5)
			begin
			  doc = urlHandle(k)
			rescue
				puts "Error in followNextMenu  #{k}";
				sleep rand(5)
			end
		end
		crawlItems(doc, info, options) unless doc.nil?
	 }
  end

  def crawlItems(doc, info, options={})
    pages= Hash.new
    doc.css('div.listitems a[href]').each { | link |
      href=link[:href]  
	  pages[href]= href unless href.nil?  # to ensure uniqueness
    }
	pages.each { |k,v|
		begin
		  doc = urlHandle(k)
		  parsePage(doc,info,options);
		  sleep rand(5);
		rescue
		  puts "Error in crawlitems";
		  sleep (3 + rand(6))
		end
	}
  end

  def crawlAll()
    skip= Regexp.new(@options['skip'],Regexp::IGNORECASE) unless (@options['skip'].blank?)  # skip records 
    @links= Hash.new
	USstates::names().each { |s,a|
      nextlink= @murl + s.downcase.gsub(' ','-') + '.php'
      h= @info.dup
      h['state']= a
      if ( !skip.blank?)
        if ( skip.match( h['state'] ))
            puts "SKIP #{  h['state']  }"
            skip=nil
        end
        next;
      end
      @links[nextlink]= a unless nextlink.nil?  # to ensure uniqueness
	  puts nextlink
	  @nextpages.clear
	  begin
      doc = urlHandle(nextlink)
	  rescue
		  sleep 5
		  begin
			  doc = urlHandle(nextlink)
		  rescue
		  end
	  end
	  unless doc.nil?
		  parseNext(doc, nextlink, h, @options) 	# gets @nextpages
		  crawlItems(doc,h, @options);
	  end
	  followNextMenu(@nextpages, h, @options)
    }
  end


  def testParse()
      file='california.php';
      #
      doc = urlHandle('http://www.museumstuff.com/museums/california-2.php')
      #doc = docHandle(file)
      #parseNext(doc , 'http://www.museumstuff.com/museums/california.php' , @info, @options)
	  #puts @nextpages.inspect
	  %w(zoo1.php mus1.php mus2.php mus3.php mus4.php).each { |file|
		  parseDoc(file, @info )
	  }
      #doc.search('a[href]').each { | link |
  end
end

aaw= Museums.new
#aaw.testParse();
aaw.crawlAll();

