require 'rubygems'
require 'active_support'
require 'sparql/client'
require File.join(File.dirname(__FILE__), './lib', 'scraper' )
require File.join(File.dirname(__FILE__), './lib', 'importer' )

class Skiresort < Scraper
def initialize() 
    @info = { "country_code" => "US", "feature_code" => "SKI", "source" => "DBP" }
    @url='http://dbpedia.org/'
    @options={"yptype"=>"Ski Centers & Resorts","soft"=>true,"overload"=>true}
	@collect=Array.new
	@prefixl = ' prefix dbpedia: <http://dbpedia.org/ontology/>
			prefix dbprop: <http://dbpedia.org/property/>
		  prefix wgs84_pos: <http://www.w3.org/2003/01/geo/wgs84_pos#>  ';
    @prefix=' prefix wgs84_pos: <http://www.w3.org/2003/01/geo/wgs84_pos#>  ';
	@resorts= @prefix +" select distinct * where { ?p a dbpedia:SkiArea }";

	@sparql = SPARQL::Client.new("http://dbpedia.org/sparql")
end

def makequery(uri)
	return @prefix +
	  ' select distinct * where 
	  { '+ uri+
	  ' rdfs:comment ?comment ; '+
	  ' dbpprop:liftsystem ?lift ;'+
	  ' dbpprop:longestRun ?run ;'+
	  ' dbpprop:skiableArea ?skiarea ;'+   #in acres?
	  ' dbpprop:snowfall ?snow; ';		# in inches? cm?
	  ' foaf:homepage ?home ; '+
	  ' dbpedia-owl:abstract ?abs ;'+
	  ' dbpedia-owl:thumbnail ?thumb ;'+
	  ' dbpedia-owl:location ?loc ; '+
	  ' dbpedia-owl:maximumElevation ?max ; '+
	  ' dbpedia-owl:minimumElevation ?min ; '+
	  ' dbpedia-owl:nearestCity ?city ; '+
	  ' dbpedia-owl:areaTotal ?area ; ' +
	  ' wgs84_pos:lat ?lat ;' +
	  ' wgs84_pos:long ?lon ;' +
	  ' <http://www.georss.org/georss/point> ?point;'+
	  ' foaf:name ?name  '+ 
	  '}';
end


#query = sparql.select.where(a).limit 10;

def fetch_resort(uri)
	total=0;
	h= Hash.new
	done=false;
	query= makequery(uri)
	result = @sparql.query( query);
		result.each{ |r|
		r.to_hash.each { |name,value|
		#r.each_binding { |name,value|
		#puts name.inspect
		#puts value.inspect
		if ( value.class == RDF::Literal )
			print " IS LITERAL "
			print value.has_datatype?
			ss= value.to_s
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
					next unless ss=~ /@en/;		# only keep the english version
				end
				if h[name].blank?
					h[name]= ss
				else
					h[name]= h[name]+" || "+ss
				end
			end
		elsif  value.uri?   
			uri=value.to_s
			if uri == "<http://dbpedia.org/ontology/nearestCity>"
				print " FOUND "
			end
			print value.qname
			print " => "
			print value.to_s
		end
	}
	}
	h["lift"]= total if (h["lift"].blank? and total > 0);
	return h
end

def package
	info=@info.dup
	if (h[:abs ].nil?)
	  info['note']= h[:comment ]
	else
	  info['note']= h[:abs ]
	end
	  info["url"]= h[:home] 

    if  !h[:loc].blank?
	  if ( cleanString(h[:loc]) =~ /\/([^\/,]+),(\w+)$/ )
		  info['city']=$1
		  info['state']= USStates::abbrev($2)
	  end
	elsif !h[:city].blank?
	  if ( cleanString(h[:loc]) =~ /\/([^\/,]+),(\w+)$/ )
		  info['city']=$1
		  info['state']= USStates::abbrev($2)
	  end
	end
	info["maxelevation"]=h[:max ];
	info["elevation"]= h[:min ];
	info["verticaldrop"]=h[:max ]-h[:min];
	info["size"]= h[:area ];
    if ( !h[:lat ].blank? )
		info['latitude']=h[:lat]
		info['longitude']=h[:long]
	elsif ! h[:point].blank?
		h[:point]=~/([-.\d])+\s([-.\d])/
		info['longitude']=Float($1)
		info['latitude']=Float($2)
	end
	info['name']= h[:name ]
	info['thumbnail']= h[:thumbnail ]
end

# A ski area is good if it has good v drop, large area and #runs
def rating(h)
	if h["lift"]=~/(\d+) lifts/
	end
	if h["lift"].blank? 
		if h["abtract"]=~/(\d+) trails/
		end
		if h["abtract"]=~/(\d+) lifts/
		end
	end
	h["verticaldrop"]
end
	  
#puts  result.inspect
# query.each_solution { |solution| puts solution.inspect }
end




uri='<http://dbpedia.org/resource/Wachusett_Mountain_%28ski_area%29>';
sr= Skiresort.new
h= sr.fetch_resort(uri)
puts "HERE"
puts h.inspect
