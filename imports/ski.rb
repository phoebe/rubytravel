require 'rubygems'
require 'active_support'
require 'sparql/client'
require File.join(File.dirname(__FILE__), './lib', 'USstates' )
require File.join(File.dirname(__FILE__), './lib', 'scraper' )
require File.join(File.dirname(__FILE__), './lib', 'importer' )

class Skiresort < Scraper
def initialize() 
    @info = {  "feature_code" => "SKI", "source" => "DBP" }
    @url='http://dbpedia.org/'
	# avoid yplookup, do not overload existing record
    @options={"yptype"=>"Ski Centers & Resorts","soft"=>true,"nolookup"=>true,"reallysoft"=>true}
	@collect=Array.new
    @prefix='prefix wgs84_pos: <http://www.w3.org/2003/01/geo/wgs84_pos#>  ';
	@resorts= @prefix +" select distinct * where { ?p a dbpedia-owl:SkiArea }";

	@sparql = SPARQL::Client.new("http://dbpedia.org/sparql")
	super
end

def allResorts()
	query= @prefix + ' select distinct ?ski where { ?ski a dbpedia-owl:SkiArea } ORDER by ?ski'
	result = @sparql.query( query);
	@allresorts= result
end

# To find Skiareas with no areaTotal
# { ?s a dbpedia-owl:SkiArea . optional {?s dbpedia-owl:areaTotal ?m }.
# FILTER (!bound(?m )) }
def makequery(uri, *args)
	tries=args[0]
	q= @prefix +
	  ' select distinct * where 
	  { '+ uri+
	  ' rdfs:comment ?comment ; '+
	  ' dbpedia-owl:abstract ?abs ;'+
	  #' wgs84_pos:lat ?lat ;' +
	  #' wgs84_pos:long ?lon ;' +
	  ' <http://www.georss.org/georss/point> ?point;'+
	  ' foaf:name ?name ';
	  if (tries==0) 
		  q=q+';'+
		  ' foaf:homepage ?home ; '+
		  ' dbpedia-owl:location ?loc ; '+
		  ' dbpedia-owl:maximumElevation ?max ; '+
		  ' dbpedia-owl:minimumElevation ?min ; '+
		  ' dbpedia-owl:areaTotal ?area  ' 
	  elsif (tries==1) 					# really want this info
		  q=q+';'+
		  ' dbpedia-owl:maximumElevation ?max ; '+
		  ' dbpedia-owl:minimumElevation ?min ; '+
		  ' dbpedia-owl:location ?loc ; '+
		  ' dbpedia-owl:areaTotal ?area  ' 
	  elsif (tries==2) 					# really want this info
		  q=q+';'+
		  ' dbpedia-owl:maximumElevation ?max ; '+
		  ' dbpedia-owl:minimumElevation ?min  '+
		  ' optional {'+uri+' dbpedia-owl:areaTotal ?area; '+
		  ' dbpedia-owl:location ?loc .} ' +
		  ' . optional {'+uri+' foaf:homepage ?home .} '
	  else			# won't return it even if it's there if its optional
		  q=q+ '.'+
		  ' optional {'+uri+' dbpedia-owl:minimumElevation ?min .} . '+
	      ' optional {'+uri+' dbpedia-owl:maximumElevation ?max .} . '+
		  ' optional {'+uri+' dbpedia-owl:location ?loc .} . ' +
		  ' optional {'+uri+' dbpedia-owl:areaTotal ?area .} . ' + 
		  ' optional {'+uri+' foaf:homepage ?home .} . '+
		  ' optional {'+uri+' dbpedia-owl:thumbnail ?thumbnail .} '
	  end
	     q=q+ '.'+
	  ' optional {'+uri+' dbpedia-owl:nearestCity ?city ; '+
		  ' dbpprop:liftsystem ?lift ; '+ 
		  ' dbpprop:longestRun ?run ; ' +
		  ' dbpprop:areaTotal ?area .} '+
=begin
	  ' optional {'+uri+' dbpedia-owl:nearestCity ?city .} '+
	  ' optional {'+uri+' dbpprop:liftsystem ?lift .} '+ 
	  ' optional {'+uri+' dbpprop:longestRun ?run .} ' +
	  ' optional {'+uri+' dbpprop:areaTotal ?area .} '+
=end
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
	(0..3).each { |tries|
	   query= makequery(uri,tries)
	   puts "#{tries.to_s}: Query #{query}"
	   #$log.debug("Sparql Query #{query}");
	   result = @sparql.query( query);
	   break unless result.empty?
	}
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
				if name == :lift && !done 	# may have one or many:all different formats
					if (ss=~/:|total/)		# means total combined
						info["lift"]=$1.to_i if ss=~ /^(\d+)/
						done=true;		# don't modify this
					elsif (ss =~/,/)
						ss.split(/,/).each { |l|
							total=total+$1 if l=~/^(\d+)/
						}
					elsif (ss =~/^(\d+)/)
						total=total+$1;
					end
						#ignore otherwise
					next;
				end
				if value.has_language?
					next unless value.language== :en;		# only keep the english version
				end
				if h[name].blank?
					h[name]= ss
				else
					h[name]= h[name]+" || "+ss
				end
			end
		elsif  value.uri?   
			h[name]= value.to_s
		end
	}
	break;	# take first one and bail!
	}
	h['source_id']=$1 if (uri=~ /\/([^\/]+)>$/) 
	h["lift"]= total if (h["lift"].blank? and total > 0);
	return h
end

def package(h)
	info=@info.dup
	return h if h.empty?
	if (h[:abs ].nil?)
	  info['note']=h[:comment ]
	else
	  info['note']=h[:abs ]
	end
	info["url"]= h[:home] 
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
	info
end

# A ski area is good if it has good v drop, large area and #runs
# # too hard to get # runs, use area for now
def rating(h)
	return h if h.empty?
	sizepoints=vdroppoints=points=0
	sizepoints =(Math.log( h["area"] )) unless h["area"].nil?
	debugstr= " size point = "+ sizepoints.to_s 
	unless h['elevation'].nil?
		if h['elevation'] > 2000
			points = points+10
		elsif h['elevation'] > 500
			points = points+ (h['elevation']-500)/1500* 10
		end
		debugstr= debugstr+ " ele "+points.to_s
		h['verticaldrop']= h['maxelevation'] - h['elevation'] unless h['maxelevation'].nil?
	end
	unless h['verticaldrop'].nil?
		v = if ( h['verticaldrop'] > 1100) then 1100 else h['verticaldrop'] end 
		vdroppoints =  v/1100.0 * 30 
		debugstr= debugstr+ " vdrop point = "+ vdroppoints.to_s 
	end
	points = sizepoints + vdroppoints+ points;
	debugstr= debugstr+ " rating = "+ points.to_s
	$log.debug(debugstr);
	puts debugstr
	h['rating']=points;
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
		rating(nn);
		$log.debug("Packages and rated Results= #{nn.inspect}");
		@importer.InsertorUpdatePlaceInDB(nn, @options) 
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
sr= Skiresort.new
sr.insertResort(uri);
=begin
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
=end
#puts h.inspect
