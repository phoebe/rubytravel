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

  #<h5>Hours of Operation:</h5>
  #<p>Monday-Friday 8:00am-5:00pm, Saturday Closed, Sunday Closed</p>
  def ypgethours(rec)
    info = rec / 'div[@class="info-more"]/*'
    label = info / 'p/text()'
    return label.text.strip;
  end

  def ypparse( doc, options={} )
    arr= Array.new;
      # match the type of business we are searching
    unless options.blank? || options['type'].blank? 
      category= Regexp.new(options['type'],Regexp::IGNORECASE)
    end
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
          hash['url'] = (url / './@href').text
        end
      end
      unless category.blank?   # match the type of business we are searching
        ok=false;
        result.css("div.what-where div.categories li a").each { |a|
          #puts category.to_s + a.text
			hash['type']=a.text
          if category.match(a.text)
              #puts " matches type "+ category.to_s+ " "+ a.text
              ok=true;
          end
        }
      else
        ok=true;
      end
      #puts hash.inspect
      unless ( !ok || hash['name'].nil? || hash['name'].empty? )
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

  def lookupFile(file,options={})
    doc = Nokogiri.parse(File.open(file));
    return ypparse( doc,options )
  end

  #url= @urlprefix+state+'/'+name.gsub(' ','-');
  def lookup(name,city,state,options={})
    return nil if name.blank?
    if city.blank?
      loc= state;
    else
      return nil if state.blank?
      loc=city +' '+ state;
    end

	#this must match what is in yellowpages
	if !options['yptype'].blank?
		refine='?refinements[headingtext]='+CGI.escape(options['yptype'])
	else  refine=''
	end;
    loc=loc.gsub(/[\W\s]/,'-').squeeze('-').strip
    name=name.gsub(/[\W\s]/,'-').squeeze('-').strip
    #url= furl(loc.gsub(/[\W\s]/,'-'),name.gsub(' ','-'))
    url= @@urlprefix+loc+'/'+name+refine;
    puts url
    begin
      doc = Nokogiri.parse(open(url))
    rescue 
      doc=nil;
      puts "Read Error"
    end

    unless doc.nil?
      return ypparse( doc, options )
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
  arr= yp.lookupFile('Volcano-Winery.htm',{'type'=>'wine'});
  arr.each { |h| h.each { |k| puts "#{k.inspect}" } }
  arr= yp.lookup('Ravenswood winery','','CA',{'type'=>'wineries'});
  arr.each { |h| h.each { |k| puts "#{k.inspect}" } }
=begin
    coord= coder.lookup(
    h['street_address'],
    h['city'],
    h['state'],
    h['postal_code'],
    'USA');
    puts coord.inspect
=end
end

def test1
  yp= Yellowpages.new();
  #$arr= yp.lookup('abreu vineyards', 'rutherford','CA');
  arr=yp.lookup( 'alta ridge', 'santa rose','CA',{'yptype'=>'Wineries'});
  puts arr.inspect;
  arr= yp.lookup('Heavenly Ski Resort','','CA',{'type'=>'resort','yptype'=>'Ski Center & Resorts'});
  puts arr.inspect;
end

#
#goodtest
test1
