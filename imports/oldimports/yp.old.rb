require 'rubygems'
require 'active_support'
require 'mechanize'
require 'nokogiri'
require 'open-uri'
require 'geocoder'

#require 'stringex' # adds String#to_ascii method

class Yellowpages
  @@urlsearch="http://www.yellowpages.com/relevance/Napa-CA/silverado-winery?expansion_factor=1&search_mode=any"
  @@urlroot="http://www.yellowpages.com/"
  @@urlprefix="http://www.yellowpages.com/name/"
  @@fieldmap=Hash[
  'name','name',
  'url','url',
  'postal-code','postal_code',
  'phone','phone',
  'locality','city',
  'region','state',
  'street-address','street_address'
  ];
  def furl(loc,name)
    return "http://www.yellowpages.com/relevance/"+loc+"/"+name+"?expansion_factor=1&search_mode=any"
  end

  ## want
  #<h5>Hours of Operation:</h5>
  #<p>Monday-Friday 8:00am-5:00pm, Saturday Closed, Sunday Closed</p>
  def ypgethours(rec)
    info = rec / 'div[@class="info-more"]/*'
    #puts info
    label = info / 'p/text()'
    #puts label
    # Let's assume if (label =~ /Hours of Operation/) { }
    #label = info / 'p/text()'
    return label.text.strip;
  end

  # Find the name and weblink of org if it exists
  def ypgetlink(hash,rec)
    fn_org = rec / 'span[@class="fn org"]/*'
    if ( fn_org.nil? ) then return; end;
    link = (fn_org / "./a/@href").text
    #puts fn_org
    unless ( link.empty? )
      name = fn_org / './a/text()';
      #puts link.inspect
      hash['name']= name.text.strip.downcase
      link=link.strip;
      if (link =~ /^http:\//) 
        #puts "No match : #{link.inspect}"
      else
        link=@@urlroot+link;
      end
      hash['info']= link.downcase;
    end
    if ( name.nil? )
      name = fn_org / './text()'
      hash['name']= name.text.strip.downcase;
    end
    link = fn_org / "a[@class='main_web_site']/@href"
    #puts "LINK #{link.inspect}"
    #puts  "MAIN: ", link
    unless ( link.empty?) then link = link.text.strip; end
    if ( link =~ /http:/ ) 
      hash['url']= link.downcase;
    else
      link = rec / "a[@class='main_web_site']/@href"
      #puts "LINK2 #{link.inspect}"
      #puts  "MAIN: ", link
      unless ( link.empty?) then link = link.text.strip; end
      if ( link =~ /^http:/ ) 
        hash['url']= link.downcase
      end
    end
  end

  # Parse for address and phone, not quite hcard
  def ypparse2( doc )
    arr= Array.new;
    records = doc.search('//div[@class="description"]')
    puts records.inspect
    # records = doc / '//div[@class="description"]'
    records.each do |rec|
      hash= Hash.new;
      #address = rec / 'div[@class="adr"]/span'
      address = rec.search( 'div[@class="adr"]/span')
      address.each do |addr|
        # map their names to my table field names
        hash[ @@fieldmap[ addr['class'].strip] ]= addr.text.strip.downcase;
      end
      ypgetlink(hash, rec);
      tel = rec / 'li[@class="number"]/text()'
      if (! tel.empty? ) then hash['phone']= tel.text.strip; end;
      unless ( hash['name'].nil? || hash['name'].empty? )
        arr<<hash;
      end
    end
    hours=ypgethours(doc)
    return arr;
  # Parse for address and phone, not quite hcard
  end

  # changed 4/8/2010?
  def ypparse( doc )
    arr= Array.new;
    doc.css('div[id="results"]').each { |sec|
    sec.css('div.result').each { |result|
      hash= Hash.new;
      result.css('div.info').each do |rec|
        hash['name']= rec.css( "h3.org a.url").text
        rec.css( "span.adr/span").each do |addr|
          # map their names to my table field names
          hash[ @@fieldmap[ addr['class'].to_s.strip] ]= addr.text.strip.downcase;
          addr.search( "./span").each do |addr2|
            hash[ @@fieldmap[ addr2['class'].to_s.strip] ]= addr2.text.strip.downcase;
          end
        end
        tel = rec.css("span.phone")
        hash['phone']= tel.text.strip unless ( tel.empty? )
      end
      url = result.css("ul.features li a")
      unless url.blank?
        if url.text =~ /website/i 
          #hash['url']
          puts "got "+ (url / './@href').text
        end
      end
      puts hash.inspect
      unless ( hash['name'].nil? || hash['name'].empty? )
        arr<<hash;
      end
    }
    }
    hours=ypgethours(doc)
    return arr;
  end


  def lookupString(string)
    doc = Nokogiri.parse(string);
    return ypparse( doc )
  end

  def lookupFile(file)
    doc = Nokogiri.parse(File.open(file));
    return ypparse( doc )
  end

  #url= @urlprefix+state+'/'+name.gsub(' ','-');
  def lookup(name,city,state)
    if city.empty?
      loc= state;
    else
      loc=city +' '+ state;
    end
    loc=loc.gsub(/[\W\s]/,'-').squeeze('-').strip
    name=name.gsub(/[\W\s]/,'-').squeeze('-').strip
    #url= furl(loc.gsub(/[\W\s]/,'-'),name.gsub(' ','-'))
    url= @@urlprefix+loc+'/'+name;
    puts url
    begin
      doc = Nokogiri.parse(open(url))
    rescue 
      doc=nil;
      puts "Read Error"
    end

    unless doc.nil?
      if city.empty?
        return ypparse( doc )
      else
        return ypparse2( doc )
      end
    end
    return {}
  end

end

#'feature_code', 'feature_class', 'country_code', 'source'
# NOT used yet
def mechgetpage( name, state )
  a = Mechanize.new { |agent|
    agent.user_agent_alias = 'Mac Safari'
  }
  a.get('http://www.yellowpages.com/') do |page|
    search_result = page.form_with(:action => '/search') do |f|
      f.search_terms= name.gsub(' ','-');
      f.geo_location_terms= state
      #f.section= standard
    end.submit

    records = search_result.search('./body')
    puts records
    puts search_result.inspect
    # return  yplookup(search_result,name,state);
  end
end

#arr= getpage('silverado-winery','CA');
#arr= getpage('clos du val','CA');
#arr= yplookup('','clos du val','CA');
#arr.each { |h| h.each { |k,v| puts "#{k}= #{v}" } }

def lookuptest
  file='Ridge-Vineyards-Winery.html'
  file='clos-du-val.htm'
  file='Chester-Hill-Winery-Inc.htm'
  file='./yp-silverado-winery.htm';
  file='yp-Williams-Selyem-Winery.htm'
  file='ridge-vineyard.html'
  arr = yplookupFile(file,'silverado winery','CA');
  arr.each { |h|
    h.each { |k,v|
      puts "#{k}= #{v}"
    }

  }
end

def goodtest
  coder= Geocoder.new("6.s3T.nV34E7G_DUQbuiiTN9Ca7waeaW0E9apk5eM5rTb13FxwVJM9bYTa5ePqvvbFM-");
  yp= Yellowpages.new();
  arr= yp.lookup('Ravenswood winery','','CA');
  #arr= yp.lookupFile('Volcano-Winery.htm');
  #arr= yp.lookup('Tedeschi Vineyards','','HI');
  arr.each { |h| h.each { |k| puts "#{k.inspect}" }
=begin
    coord= coder.lookup(
    h['street_address'],
    h['city'],
    h['state'],
    h['postal_code'],
    'USA');
    puts coord.inspect
=end
  }
end

def test1
  yp= Yellowpages.new();
  #arr= yp.lookup('abiouness wines', 'st.helena','CA');
  #arr.each { |h| h.each { |k,v| puts "#{k}= #{v}" }
  $arr= yp.lookup('abreu vineyards', 'rutherford','CA');
  arr=yp.lookup( 'alta ridge vineyards', 'santa rose','CA');
  puts arr.inspect;
  #arr=yp.lookup( 'altamura winery', 'napa','CA');
  #arr=yp.lookup( 'amapola creek vineyards winery','glen ellen','CA');
  arr= yp.lookup('alexeli vineyard & winery','molalla','OR');
  puts arr.inspect;
end

#
#goodtest
test1
