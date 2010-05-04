require 'rubygems'
require 'date'
require 'ken'
require 'sparql-client'
require 'importer'

# good stuff
#  select distinct ?a ?c ?d ?e ?f where {?a ?b <http://dbpedia.org/resource/Category:Wineries_by_country> .  ?c ?d ?a . ?e ?f ?c}

class Skiresort < Scraper
	def initialize()
	   sparql = SPARQL::Client.new("http://dbpedia.org/sparql")
	end

	# ASK WHERE { ?s ?p ?o }
	def yesno
		result = sparql.ask.whether([:s, :p, :o]).true?
		puts result.inspect   #=> true or false
	end

	# SELECT * WHERE { ?s ?p ?o } OFFSET 100 LIMIT 10
	def query(s,p,o)
		query = sparql.select.where([s, p, o]).offset(100).limit(10)
		query.each_solution do |solution|
		   puts solution.inspect
		end
	end

	# CONSTRUCT { ?s ?p ?o } WHERE { ?s ?p ?o } LIMIT 10
	def graph(s,p,o)
		query = sparql.construct([:s, :p, :o]).where([:s, :p, :o]).limit(10)
		query.each_statement do |statement|
		   puts statement.inspect
		end
	end
	
	def query1(s,p,o)
		result = sparql.query("ASK WHERE { ?s ?p ?o }")
		puts result.inspect   #=> true or false
	end

end

sr= Skiresort.new
s = sr.query("<http://dbpedia.org/resource/Alpine_Meadows%2C_California>","a","?o");
puts s;
