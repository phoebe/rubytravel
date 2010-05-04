require 'rubygems'
require 'mechanize'
require 'active_support'
require 'nokogiri'
require 'open-uri'
require 'geocoder'
require 'importer'
require 'yellowpages'
require 'scraper'

@USstates={
'Alabama'=>'AL',
'Alaska'=>'AK',
'Arizona'=>'AZ',
'Arkansas'=>'AR',
'California'=>'CA',
'Colorado'=>'CO',
'Connecticut'=>'CT',
'Delaware'=>'DE',
'Florida'=>'FL',
'Georgia'=>'GA',
'Hawaii'=>'HI',
'Idaho'=>'ID',
'Illinois'=>'IL',
'Indiana'=>'IN',
'Iowa'=>'IA',
'Kansas'=>'KS',
'Kentucky'=>'KY',
'Louisiana'=>'LA',
'Maine'=>'ME',
'Maryland'=>'MD',
'Massachusetts'=>'MA',
'Michigan'=>'MI',
'Minnesota'=>'MN',
'Mississippi'=>'MS',
'Missouri'=>'MO',
'Montana'=>'MT',
'Nebraska'=>'NE',
'Nevada'=>'NV',
'New Hampshire'=>'NH',
'New Jersey'=>'NJ',
'New Mexico'=>'NM',
'New York'=>'NY',
'North Carolina'=>'NC',
'North Dakota'=>'ND',
'Ohio'=>'OH',
'Oklahoma'=>'OK',
'Oregon'=>'OR',
'Pennsylvania'=>'PA',
'Rhode Island'=>'RI',
'South Carolina'=>'SC',
'South Dakota'=>'SD',
'Tennessee'=>'TN',
'Texas'=>'TX',
'Utah'=>'UT',
'Vermont'=>'VT',
'Virginia'=>'VA',
'Washington'=>'WA',
'Washington dc'=>'DC',
'West Virginia'=>'WV',
'Wisconsin'=>'WI',
'Wyoming'=>'WY'}

@USterritory={
'American Samoa'=>'AS',
'District of Columbia'=>'DC',
'Federated States of Micronesia'=>'FM',
'Guam'=>'GU',
'Marshall Islands'=>'MH',
'Northern Mariana Islands'=>'MP',
'Palau'=>'PW',
'Puerto Rico'=>'PR',
'Virgin Islands'=>'VI'};

 

class Museums < Scraper
  def initialize
    @info = { "country_code" => "US", "feature_code" => "MUS", "source" => "MUS" }
    @url='http://www.museumstuff.com/go.php' # kicks ass!
	@url='http://www.museumstuff.com/museums/'
    @options= {"type"=>"museums","soft"=>true,'overload'=>true}
    super
  end

  # return mapping
  def topic_map(words)
	return keys
  end

  def parsePage(doc, page , info, options={} ) 
    h = info.dup
	#<div class="breadrec"><a href="http://www.museumstuff.com">MuseumStuff.com</a> | <a href="http://www.museumstuff.com/museums/">museums</a> | American Sport Art Museum and Archives</div>
	doc.css('div.breadrec').each { |l|
		puts "cat="+l.text
		category=l.text
		nn=l.css('b');  h['name']= cleanString(nn.text) unless nn.nil?  
		ff= l.parent.search('./br/preceding-sibling::b|./br/following-sibling::b|./br/preceding-sibling::text()|./br/following-sibling::text()')   # examine parts of line item
      ff.each { |p|
        puts "BR= #{ p.inspect }"
        entry=  cleanString(p.text)
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
		ff= l.parent.search('./p/preceding-sibling::node|./p/following-sibling::node|./p/preceding-sibling::    text()|./p/following-sibling::text()|./b/preceding-sibling::node|./b/following-sibling::node')
	 ff.each { |p| 
        puts "P= #{ p.inspect } -- #{ p.next_sibling.text }"
        entry=  cleanString(p.next_sibling.text)
        if ( entry =~ /^URL/ )
          h['url']= cleanString( entry )
        elsif ( entry =~ /^hours/i )
          h['hours']= cleanString( $')
        elsif ( entry =~ /^collections/i )
        elsif ( entry =~ /^topics/i )
          h['topics']= cleanString( $')
        elsif ( entry =~ /^overview/i )
		end
      }
    }
    puts h.inspect
    #@importer.InsertorUpdatePlaceInDB(h, @options)
  end

  def parseMenu(doc, clickpage, info, options={})
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
      file='mus2.php';
      #
      #puts file
      #parseDoc( file ,@info)
      doc = docHandle(file)
      #parseIndex(doc, nil ,@info)
      parsePage(doc , nil , @info, @options)
      #doc.search('a[href]').each { | link |
  end
end

aaw= Museums.new
aaw.testParse();
#aaw.crawlAll();

