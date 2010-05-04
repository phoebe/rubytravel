require 'rubygems'
require 'mechanize'
require 'active_support'
require 'nokogiri'
require 'open-uri'
require 'geocoder'
require 'importer'
require 'yellowpages'
require 'scraper'


class NPS < Scraper
  attr_reader :options
  def initialize
    @info = { "country_code" => "US", "feature_code" => "PRK", "source" => "NPS" }
    @url='http://www.nps.gov/'
    @things2do='/planyourvisit/things2do.htm';
    @hours='/planyourvisit/hours.htm';
    @options={"type"=>"PRK","soft"=>true,"nolookup"=>true,"overload"=>true}
    @features=%w(WHS KID PADL WHITE BIRD ARCHEO PALEO HIST MOTOR)# water use features
    @features=%w(WHS KID BIKE CAMP PEDE EQUES BIRD ARCHEO PALEO HIST PICNIC MOTOR SCENIC)# land use features
	@collect=Array.new
	@beenthere={};
	@links={};
    super
  end



  def crawlPark(code, name, info)
	  results=nil
	  return if (name.nil?) 	# holds name of park
	  h= info.dup
	  # some parks are in the wrong place?
	  results = Geocoder::glookupLong( name +','+h['state']+','+h['country_code']); 
	  unless !results.empty? &&  results[0]['type']=~/establishment|park/i
		  results = Geocoder::glookupLong( name +','+h['country_code']);  # if this fails, let it go
	  end
	  if !results.empty? && results[0]['type']=~/establishment|park|route/i 
		  puts results.inspect
		  if (name.distance(results[0]['name']) < 2)	#match the name, google stuffs in junk sometimes
			  puts ">> Lookup OK "+results[0]['name']
			  h.merge!(results[0])
		  else
			  h['name']=name;
			  h['city']='National Park';
		  end
	  end
	  link=@url+code+@things2do;
	  collect=Array.new						# tags for each park
	  #puts link
	  #begin
		  doc = urlAgentHandle(link);
		  crawl4tags(doc, h, collect);
		  getTags( doc, h, collect );
	  #rescue
		  #puts "Bad URL "+link
	  #ensure
		  #sleep 10;
	  #end

	  begin
		  link=@url+code+@hours;
		  doc = urlAgentHandle(link);
		  h['hours']=parseHours(doc,h);
	  rescue
		  puts "Bad hours page"
	  end
	  # puts "collect="+collect.inspect
	  collect.uniq!
												  #print "COLLECTED #{@collect.inspect}"
												  #print "crawled #{@beenthere.inspect}"
	  h['use_code']=collect.join(',') unless collect.nil? ;
	  h['city']= 'National Park' if ( h['city'].nil?)	# some parks are near multiple cities
	  h['url']=@url+code+ '/';
	  @importer.InsertorUpdatePlaceInDB(h, @options) if @beenthere.size >0 # crawled something
	  collect.clear
	  @beenthere.clear
	  if ( !results.empty? && results.length > 1 )
		(1..results.length).each { |i|
			 if (!results[i].nil? && results[i]['type']=='route')
				 h.merge(results[i])
				 h['feature_code']='TRL'
				 # puts h.inspect
			 end
		 }
	  end
  end
=begin

  acadia
  http://www.nps.gov/acad/planyourvisit/trailaccessibility.htm
  http://www.nps.gov/acad/planyourvisit/beachaccessibility.htm
  http://www.nps.gov/acad/planyourvisit/gettingaround.htm
  http://www.nps.gov/acad/planyourvisit/gettingaround.htm
  http://www.nps.gov/acad/planyourvisit/hours.htm
  http://www.nps.gov/acad/planyourvisit/feesandreservations.htm

  http://www.nps.gov/agfo/planyourvisit/hours.htm
  http://www.nps.gov/agfo/planyourvisit/things2do.htm


  http://www.nps.gov/deto/planyourvisit/directions.htm
  http://www.nps.gov/deto/planyourvisit/hours.htm

  pinnacles
  http://www.nps.gov/pinn/planyourvisit/things2do.htm
	http://www.nps.gov/pinn/planyourvisit/trails.htm
	http://www.nps.gov/pinn/planyourvisit/cavestatus.htm
	http://www.nps.gov/pinn/planyourvisit/events.htm
	http://www.nps.gov/pinn/planyourvisit/camp.htm

  grand teton
  http://www.nps.gov/grte/planyourvisit/things2do.htm
	  http://www.nps.gov/grte/planyourvisit/outdooractivities.htm
	  http://www.nps.gov/grte/planyourvisit/concessions.htm
	  http://www.nps.gov/grte/planyourvisit/nearbyattractions.htm
	  http://www.nps.gov/grte/planyourvisit/placestogo.htm
	  	http://www.nps.gov/grte/planyourvisit/campgrounds.htm
		http://www.nps.gov/grte/planyourvisit/visitorcenters.htm

Joshua Tree
	http://www.nps.gov/jotr/planyourvisit/things2do.htm
		http://www.nps.gov/jotr/planyourvisit/activities.htm
		http://www.nps.gov/jotr/planyourvisit/placestogo.htm

	Great Smoky
		http://www.nps.gov/grsm/planyourvisit/things2do.htm
			http://www.nps.gov/grsm/planyourvisit/placestogo.htm
			http://www.nps.gov/grsm/planyourvisit/nearbyattractions.htm
			http://www.nps.gov/grsm/planyourvisit/events.htm
			http://www.nps.gov/grsm/naturescience/snow.htm -> when will it snow

	Grand Canyon
		http://www.nps.gov/grca/planyourvisit/things2do.htm
			http://www.nps.gov/grca/naturescience/wildlife-day.htm -> Wildlife Day - May 1, 2010
			http://www.nps.gov/grca/planyourvisit/religious-services.htm
			http://www.nps.gov/grca/planyourvisit/backcountry.htm -> Backcountry Hiking
	North Rim open  Mid-May to Mid-October
	South Rim: Open All Year 

=end

  def crawl4tags( doc, info,collect )
	  # tags
		@links.clear
		doc.css('table.navcolumn * a[href]').each { |a|   # headings in thing2do page 
			link=a[:href]; anchor=cleanString(a.text);
			anc=""
			unless anchor=~ /opening|nearby|update|places to|closing|schedule/i
				if (anchor=~ /\+outfit\S*|\s+permit\S*|\s+business\S*|\s+provide\S* |\s+information\S*/i)
					anc= $`+' '+ $'
				else
					anc=anchor
				end
				anc='kids' if anchor=~ /For kids/i
				unless anchor=~ /activit|hour/i
					collect << anc if anc.length < 25 # if too long, probably junk
				end
				@links[link]=anc if link =~/planyourvisit/ 
				@beenthere[link]=false if @beenthere[link].nil?; #new link
			end
									#print " T[#{anchor} => #{anc}]"
		}
		@links.each{ |link,anchor|
			# should remove opening closing schedule
			#anchor= @links[link]
			if (anchor=~/activit|outdoor|indoor|wild|backcountry|concession/i)
				unless ( @beenthere[link] )
					@beenthere[link] = true;
					link=@url+link;
					puts " CRAWLING #{link} #{anchor}"
					begin
					doc2 = urlHandle(link);
					crawl4tags(doc2, info, collect);
					getTags( doc2, info, collect ) if anchor=~/activities/ # restrict
					rescue 
						puts "Error CRAWLING #{link}"
					end
					  sleep 10;
				end
			end
		}
  end

  def getTags( doc, info,collect )
    #doc.css('p > strong|p > u|p > b').each { |c|   # headings in thing2do page 
    doc.search('.//p/b|.//p/u|.//p/strong').each { |c|   # headings in thing2do page 
		linktag=cleanString(c.text)
		unless linktag=~ /Did you know/i		# skip
			if linktag=~/museum|histor|archae|motor|auto|tour|ski|paleo|geolog|walk|kids|canoe|kayak|raft|tub|float|fish|hunt|boat|cave|outdoors|beach|swim|horse|scene|photo|trail|hik|summer|snow|wild|backcountry|climb|/i
			#print " GOT {#{linktag}}";
				collect << linktag if linktag.length < 30 # if not too long
			end
		end
	}
  end

  def parseThings2do( doc, info )
	crawl4tags( doc, info ,@collect)
  end

  def parseOutdoorsAct( doc, info )
    doc.css('table.navcolumn * a[href]').each { |c|   # less info
		puts c.text
	}
  end

  def parseHours( doc, info )
	str=""
    doc.css('table.navcolumn * a[href]').each { |c|   # less info
		str=str+ c.text
	}
    doc.css('div.textWrappedAroundImage').each { |c|   # less info
		str=str+ c.text
	}
	return cleanString(str).squeeze(" ")
  end

  def parseTrails(doc, info ) 
    trails=Hash.new   # to clean out dups
    doc.css('div.content').each { |c|   # less info
    }
    puts h.inspect
    @importer.InsertorUpdatePlaceInDB(h,@options)
  end

  def parseStateIndex(st)
	link = @url+'state/'+st
	puts link
	parks={}	# new for each state
	doc = urlHandle(link);
    doc.css('p.resultParkName a[href]').each { |a|
		  parks[$1]=a.text  if a[:href] =~ /\/(\w{4})\//
	}
	puts "##STATE "+st+" ##  "+ parks.inspect 
	info= @info.dup;
	info['state']=st;
	info['admin1_code']=st;
	parks.each{ |a,b|
		crawlPark(a,b, info )
	}
  end

  def crawlAll(options={})
	 @options.merge(options)
	 skip= !options['skip'].nil?;
	 USstates::names.each {|c,a|
	  skip=false  if options['skip']==a
	  next if skip;
	  print a+" "
	  parseStateIndex(a);
	 }
  end

  def testParse()
	  funcptr= Array.new
	  funcptr[0]= self.method( :parseThings2do )
	  funcptr[1]= self.method( :parseOutdoorsAct )
	  funcptr[2]= self.method( :parseHours )
	  data= %w(things2do.htm outdooractivities.htm hours.htm)

	  %w(appa cabr acad noat yell ).each { |p|
		  puts "PARK "+p
		  data.zip(funcptr).each { |d,f|
			file=p+'_'+d;
			# puts f.inspect+" "+file
			if File.exists?(file)
				doc = docHandle(file)
				f.call( doc, @info )
			else
				begin
					print " >CRAWL "+p+'/'+d;
					doc = urlHandle(@url+p+'/planyourvisit/'+d)
					f.call( doc, @info )
				rescue OpenURI::HTTPError
					print "No such url "+p+'/'+d;
				rescue
					print "Generic Error such url "+p+'/'+d;
				end
			end
		  }
		print "COLLECTED #{@collect.inspect}"
		print "crawled #{@beenthere.inspect}"
		@collect.clear
	  }

  end

  def test2Parse()
	  d='things2do.htm';
	  #%w(appa cabr acad noat yell ).each { |p|
	  collect=Array.new
	  %w(pinn ).each { |p|
		  link=@url+p+'/planyourvisit/'+d
		  puts link
		  doc = urlHandle(link)
		  crawl4tags( doc, @info, collect )
		  print "COLLECTED #{collect.inspect}"
		  print "crawled #{@beenthere.inspect}"
		  @links.clear
		  @beenthere.clear
		collect.clear
	  }
  end

  # for some reason- a lot of dups with wrong states
  def findPark(h)
	  q= 'select postal_code from places where name = "'+h['name']+'" and feature_code="PRK" ';
	  res = @importer.selectquery(q)
	  res.each { |r| 
		  if r['postal_code']=null
			  return null
		  else
			  return true
		  end
	  }
	  return null
  end

  def test3Parse(code,name,st)
	info=@info.dup
	info['admin1_code']=info['state']=st;
	#results=Geocoder::glookupLong( @parks[code] +','+info['state']+','+info['country_code']); 
	#unless results.empty?
		#info.merge!(results[0])
		#puts results.inspect
	#end
	crawlPark('laro','Lake Roosevelt National Recreation Area',info);
  end

  def testList()
	  @parks={"laro"=>"Lake Roosevelt National Recreation Area", "ebla"=>"Ebey's Landing National Historical Reserve", "sajh"=>"San Juan Island National Historical Park", "nepe"=>"Nez Perce National Historical Park", "klse"=>"Klondike Gold Rush - Seattle Unit National Historical Park", "fova"=>"Fort Vancouver National Historic Site", "lewi"=>"Lewis and Clark National Historical Park", "whmi"=>"Whitman Mission National Historic Site", "olym"=>"Olympic National Park", "mora"=>"Mount Rainier National Park", "lecl"=>"Lewis & Clark National Historic Trail", "noca"=>"Lake Chelan National Recreation Area"}
	  @waparks={"laro"=>"Lake Roosevelt National Recreation Area", "ebla"=>"Ebey's Landing National Historical Reserve", "sajh"=>"San Juan Island National Historical Park", "nepe"=>"Nez Perce National Historical Park", "klse"=>"Klondike Gold Rush - Seattle Unit National Historical Park", "fova"=>"Fort Vancouver National Historic Site", "lewi"=>"Lewis and Clark National Historical Park", "whmi"=>"Whitman Mission National Historic Site", "olym"=>"Olympic National Park", "mora"=>"Mount Rainier National Park", "lecl"=>"Lewis & Clark National Historic Trail", "noca"=>"Lake Chelan National Recreation Area"}
	  @nyparks={"npnh"=>"Manhattan Sites"}
	  @parks=@nyparks
	info=@info.dup
	info['admin1_code']=info['state']="NY";
	  #@parks.each { |a,b|
		crawlPark("npnh",info);
	  #}
  end

end

nearby='/planyourvisit/nearbyattractions.htm'
parser= NPS.new
#parser.test3Parse('kaho','Kaloko-Honokohau National Historical Park','HI');
#parser.parseStateIndex('NY');
#parser.testList();
parser.crawlAll #({"skip"=>"HI"});

