require 'rubygems'
require 'mechanize'
require 'nokogiri'
require 'open-uri'
#require 'stringex' # adds String#to_ascii method


# format=urlprefix/statecode/businessname
@urlprefix="http://www.yellowpages.com/name/"
@urlroot="http://www.yellowpages.com/"

# <li class="ypc_listing MDM listing first" tier="">
#<div class="description">
#<span style='float: right'></span>  
# ( some of the records have vcard )
#<span class="fn org">
#<h2><a href="/info-12318758/Silverado-Vineyards?lid=12318758" onmousedown="omniturePaidListingClickFire('1', '2', '', '', '1', '', {&quot;eVar9&quot;:&quot;1&quot;,&quot;eVar21&quot;:&quot;nameres&quot;,&quot;prop22&quot;:&quot;&quot;,&quot;prop38&quot;:&quot;nameres&quot;, jsEvent:getEvent(event)});log_click('iid=83cca3b0-1c46-012d-647e-00237da1957a;tol=2;lt=1',{jsEvent:getEvent(event), element:this});">Silverado Vineyards</a></h2>    </span>
#<div class="adr"><span class='street-address'> 6121 Silverado Trl </span> <br /><span class='locality'>Napa</span>, <span class='region'> CA </span> <span class='postal-code'> 94558 </span><a href="/info-12318758/Silverado-Vineyards/maps?lid=12318758" id="map-link-12318758" onmousedown="omniturePaidListingClickFire('13', '2', '', '', '1', '', {&quot;eVar9&quot;:&quot;1&quot;,&quot;eVar21&quot;:&quot;nameres&quot;,&quot;prop22&quot;:&quot;&quot;,&quot;prop38&quot;:&quot;nameres&quot;, jsEvent:getEvent(event)});log_click('iid=83cca3b0-1c46-012d-647e-00237da1957a;tol=2;lt=13',{jsEvent:getEvent(event), element:this});">Map</a></div>    
#<ul>
#<li class='number'>
#(707) 257-1770
#</li>
#<li><a href="http://WWW.BLUEBERRYWINE.COM" class="main_web_site" 
#

#  format= http://www.yellowpages.com/info-5666442/Ridge-Vineyards-Winery?lid=5666442
#<div class="info-more">
#<h5>Hours of Operation:</h5>
#<p>Monday-Friday 8:00am-5:00pm, Saturday Closed, Sunday Closed</p>
#</div>

def lookUp2(name,state)
  url= @urlprefix+'/'+state+'/'+name;
  doc = Nokogiri.parse(File.open('./yp-silverado-winery.htm'));
  # doc = Nokogiri.parse(open(url))
  records = doc / '//div[@class="description"]'
  records.each do |rec|
    puts records.inspect
  end
end

def lookUp3(name,state)
  url= @urlprefix+'/'+state+'/'+name;
  doc = Nokogiri.parse(File.open('./yp-silverado-winery.htm'));
  # doc = Nokogiri.parse(open(url))
  records = doc / '//div[@class="description"]'
  records.each do |rec|
    address = rec / '//div[@class="adr"]/span'
      address.each do |addr|
        puts addr.inspect
      end
    name = rec / '//span[@class="fn org"]/h2/a/text()'
    puts name.inspect
    tel = rec / '//li[@class="number"]'
    puts tel.inspect
  end
end

def search_for_parent_element(_start_element, _style)
  unless _start_element.nil?
# have we already found what we're looking for?
  if _start_element.name == _style
    return _start_element
  end
# _start_element is a div.block and not the _start_element itself
  if _start_element[:class] == "block" && _start_element[:id] != @start_here[:id]
# begin recursion with last child inside div.block
  from_child = search_for_parent_element(_start_element.children.last, _style)
    if(from_child)
      return from_child
    end
  end
# begin recursion with previous element
  from_child = search_for_parent_element(_start_element.previous, _style) 
    return from_child ? from_child : false
  else
    return false
  end
end
      
## want
#<h5>Hours of Operation:</h5>
#<p>Monday-Friday 8:00am-5:00pm, Saturday Closed, Sunday Closed</p>
def ypgethours(rec)
  info = rec / 'div[@class="info-more"]/*'
  puts info
  label = info / 'p/text()'
  puts label
  # Let's assume if (label =~ /Hours of Operation/) { }
  #label = info / 'p/text()'
  return label.text.strip;
end

def ypgetlink(hash,rec)
  fn_org = rec / 'span[@class="fn org"]/*'
  if ( fn_org.nil? ) then return; end;
  link = (fn_org / "./a/@href").text
    puts fn_org
  unless ( link.empty? )
    name = fn_org / 'a/text()';
     #puts link.inspect
    hash['name']= name.text.strip;
    link=link.strip;
    if (link =~ /^http:\//) 
       puts "No match : #{link.inspect}"
    else
       link=@urlroot+link;
    end
    hash['info']= link;
  end
  if ( name.nil? )
    name = fn_org / './text()'
    hash['name']= name.text.strip;
    #puts  "PLAIN: ", name
  end
  link = fn_org / "a[@class='main_web_site']/@href"
  puts "LINK #{link.inspect}"
    #puts  "MAIN: ", link
  unless ( link.empty?) then link = link.text.strip; end
  if ( link =~ /http:/ ) 
    hash['link']= link;
  else
    link = rec / "a[@class='main_web_site']/@href"
  puts "LINK2 #{link.inspect}"
    #puts  "MAIN: ", link
  unless ( link.empty?) then link = link.text.strip; end
    if ( link =~ /^http:/ ) 
      hash['link']= link
    end
  end
end

def yplookUpFile( file,  name,state)
  arr= Array.new;
  doc = Nokogiri.parse(File.open(file));
  # doc = Nokogiri.parse(open(url))
  records = doc.search('//div[@class="description"]')
  # records = doc / '//div[@class="description"]'
  records.each do |rec|
    hash= Hash.new;
    #address = rec / 'div[@class="adr"]/span'
    address = rec.search( 'div[@class="adr"]/span')
      address.each do |addr|
       hash[addr['class'].strip]= addr.text.strip;
      end
    ypgetlink(hash, rec);
    tel = rec / 'li[@class="number"]/text()'
    if (! tel.empty? ) then hash['phone']= tel.text.strip; end;
    arr<<hash;
  end
   hours=ypgethours(doc)
  return arr;
end


#url= @urlprefix+state+'/'+name.gsub(' ','-');
def yplookUp( doc, name,state)
  url= @urlprefix+state+'/'+name.gsub(' ','-');
  arr= Array.new;
    #doc = Nokogiri.parse(mystring);
    #doc = Nokogiri.parse(File.open(file));
  if (doc.empty?)
    doc = Nokogiri.parse(open(url))
  end
  records = doc.search('//div[@class="description"]')
  # records = doc / '//div[@class="description"]'
  records.each do |rec|
    puts rec.inspect
    hash= Hash.new;
    #address = rec / 'div[@class="adr"]/span'
    address = rec.search( 'div[@class="adr"]/span')
      address.each do |addr|
        puts addr.inspect
       hash[addr['class'].strip]= addr.text.strip;
      end
    ypgetlink(hash, rec);
    tel = rec / 'li[@class="number"]/text()'
    if (! tel.empty? ) then hash['phone']= tel.text.strip; end;
    arr<<hash;
  end
   hours=ypgethours(doc)
  return arr;
end




def getpage( name, state )
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
    # return  yplookUp(search_result,name,state);
  end
end

#arr= getpage('silverado-winery','CA');
#arr= getpage('clos du val','CA');
#arr= yplookUp('','clos du val','CA');
#arr.each { |h| h.each { |k,v| puts "#{k}= #{v}" } }

def lookuptest
  file='Ridge-Vineyards-Winery.html'
  file='clos-du-val.htm'
  file='Chester-Hill-Winery-Inc.htm'
  file='./yp-silverado-winery.htm';
  file='yp-Williams-Selyem-Winery.htm'
  file='ridge-vineyard.html'
arr = yplookUpFile(file,'silverado winery','CA');
arr.each { |h|
  h.each { |k,v|
    puts "#{k}= #{v}"
  }
}
end
lookuptest
