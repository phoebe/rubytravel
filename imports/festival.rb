require 'rubygems'
require 'active_support'
require 'sparql/client'
require File.join(File.dirname(__FILE__), './lib', 'USstates' )
require File.join(File.dirname(__FILE__), './lib', 'scraper' )
require File.join(File.dirname(__FILE__), './lib', 'importer' )

class Golfresort < Scraper
def initialize() 
    @info = {  "feature_code" => "FEST", "source" => "DBP", "use_code"=>"" }
    @url='http://dbpedia.org/'
	# avoid yplookup, do not overload existing record
    @options={"yptype"=>"Park","soft"=>true,"reallysoft"=>true}
	@collect=Array.new
    @prefix='prefix wgs84_pos: <http://www.w3.org/2003/01/geo/wgs84_pos#>  ';
	@sparql = SPARQL::Client.new("http://dbpedia.org/sparql")
	@festivals=%w(category:LGBT_events_in_the_United_States category:Arts_festivals_in_the_United_States category:Food_festivals_in_the_United_States category:Cultural_festivals_in_the_United_States category:Dogwood_festivals category:Sports_festivals_in_the_United_States category:Christmas_in_the_United_States category:Fourth_of_July_festivals 	category:Fringe_theatre 
	super
end

def allResorts()
	query= @prefix + 'select distinct ?a where { _:c <http://www.w3.org/2004/02/skos/core#broader>
	category:Cultural_festivals_in_the_United_States
	. ?a ?b _:c} order by ?a limit 500 offset 140'
	result = @sparql.query( query);
	@allresorts= result
end

# To find Skiareas with no areaTotal
# { ?s a dbpedia-owl:SkiArea . optional {?s dbpedia-owl:areaTotal ?m }.
# FILTER (!bound(?m )) }
def makequery(uri, *args)
	q= ' select distinct * where  {'+ uri+
	  ' dbpedia-owl:abstract ?abs; '+
	  ' <http://www.georss.org/georss/point> ?point '+
	  '. {'+ uri+ ' rdfs:label ?name } UNION {'+ uri +' foaf:name ?name } ';
	  #' wgs84_pos:lat ?lat ;' +
	  #' wgs84_pos:long ?lon ;' +
	  q=q+ '.'+
	  ' optional {'+ uri+ ' dbpprop:reference ?ref .} .'+
	  ' optional {'+ uri+ ' rdfs:comment ?comment .} .'+
	  ' optional {'+uri+' foaf:homepage ?home .} . '+
	  ' optional {'+uri+' dbpedia-owl:thumbnail ?thumbnail .} '+
	  ' . FILTER langMatches( lang(?abs), "en" )  '+
	  '}';
	 return q
end


#query = sparql.select.where(a).limit 10;

def fetch_resort(uri)
	total=0;
	index=0;
	h= Hash.new
	done=false;
	result={};
   query= makequery(uri)
   puts "Query #{query}"
   #$log.debug("Sparql Query #{query}");
   result = @sparql.query( query);
	   #break unless result.empty?
	result.each { |r|
		index=index+1
		r.to_hash.each { |name,value|
		if ( value.class == RDF::Literal )
			ss= value.value
			#print value.has_datatype?
			if name==:lat || name==:lon || name==:max || name==:min || name==:area
				if ( ss =~/([-.\d]+)/ )
					h[name]= Float($1)
				end
			else
				if value.has_language?
					next unless value.language== :en;		# only keep the english version
				end
				h[name]= ss
			end
		elsif  value.uri?   
			h[name]= value.to_s
		end
	}
	# break;	# don't take first one and bail!
	}
	h['source_id']=$1 if (uri=~ /\/([^\/]+)>$/) 
	return h
end

def package(h)
	return h if h.empty?
	info=@info.dup
	if (h[:abs ].nil?)
	  info['note']=h[:comment ]
	else
	  info['note']=h[:abs ]
	end
	info["url"]= h[:ref]  unless h[:ref].nil?
	info["url"]= h[:home]  unless h[:home].nil?		# preferred
	info["source_id"]= h["source_id"] 

    if  !h[:loc].blank?	 # preferred
		hh= cleanString( h[:loc] )
	  if ( hh =~ /\/([^\/]+)%2C_(\w+)$/ )
		  info['city']=$1
		  info['state']= USstates::abbrev($2)
	  end # Let reverse geolookup fix it
	elsif !h[:city].blank?
	  if ( cleanString(h[:city]) =~ /\/([^\/,]+)(%2C_)?(\w+)?$/ )
		  info['city']=$1
		  info['state']= USstates::abbrev($3)
	  end
	end
	info["maxelevation"]=h[:max ];
	info["elevation"]= h[:min ];
	info["verticaldrop"]=h[:max ]-h[:min] unless h[:max ].nil? || h[:min ].nil?
	info["area"]= h[:area ];
    if ( !h[:lat ].blank? )
		info['latitude']=h[:lat]
		info['longitude']=h[:long]
	elsif ! h[:point].blank?
		if ( h[:point]=~/([-.\d]+)\s([-.\d]+)/ )
			info['latitude']=Float($1)
			info['longitude']=Float($2)
		end
	end
	info['name']= h[:name ]
	info['thumbnail_link']= h[:thumbnail ]
	return info
end

# A ski area is good if it has good v drop, large area and #runs
# # too hard to get # runs, use area for now
def rating(h)
	return h if h.empty?
	# no info
end

def insertResort( uri )
	$log.debug("Fetch #{uri}");
=begin
	if (uri=~ /\/([^\/]+)>$/) 
		puts uri+" "+$1
		source_id=$1
		q="select elevation,rating from places where source_id='"+source_id+"'";
		res= @importer.selectquery(q);	# already entered
		unless res.nil? 
			res.each { |h|
				puts h.inspect
				return unless h[0].blank?
			}
		end
	end
=end
	 h= fetch_resort(uri)
	$log.debug("Sparql Results= #{h.inspect}");
	unless h.empty? 
		nn= package(h);
		#rating(nn);
		$log.debug("Packages and rated Results= #{nn.inspect}");
		unless nn['latitude'].nil?
			@importer.InsertorUpdatePlaceInDB(nn, @options) 
		end
	end
	sleep 5
end
	  
end


uri='<http://dbpedia.org/resource/Big_Sky_Resort>';
uri='<http://dbpedia.org/resource/Sunday_River_%28ski_resort%29>';
uri='<http://dbpedia.org/resource/Whakapapa_skifield>';
uri='<http://dbpedia.org/resource/Wachusett_Mountain_%28ski_area%29>';
uri='<http://dbpedia.org/resource/Mad_River_Mountain>';
uri='<http://dbpedia.org/resource/Treble_Cone>';

%w(Appalachian_Ski_Mountain Sunlight_Ski_Area Cataloochee_Ski_Area Snowmass_%28ski_area%29 Broken_River_Ski_Area Dollar_mountain Grand_Targhee_Resort Grand_Massif)

uri='dbpedia:Sunlight_Ski_Area';
uri='dbpedia:Kicking_Horse_Resort';
uri='<http://dbpedia.org/resource/Squaw_Valley_Ski_Resort>';
uri='<http://dbpedia.org/resource/Taos_Ski_Valley%2C_New_Mexico>'
uri='dbpedia:Deer_Mountain';
uri='dbpedia:Olympic_Club';
uri='<http://dbpedia.org/resource/Grove_Park_Inn>';
sr= Golfresort.new
=begin
sr.insertResort(uri);
=end
#
i=0;
resorts = sr.allResorts()
resorts.each { |r|
	puts "#{i.to_s}: #{uri} "
	r.to_hash.each { |name,value|
		uri= value.to_s
		sr.insertResort('<'+uri+'>');
	}
	i=i+1
}
#puts h.inspect
