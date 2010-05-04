require "time";
require "active_rdf";

pool = ConnectionPool.add_data_source :type => :sparql,
    :url => "http://dbpedia.org/sparql",
      :results => :sparql_xml

Namespace.register(:dbpedia, 'http://dbpedia.org/')

references = Query.new.distinct(:reference).
  where(RDFS::Resource.new("http://dbpedia.org/resource/#{resource_name}"), 
RDFS::Resource.new('http://dbpedia.org/property/reference'), 
:reference).
execute
# It translates to this SPARQL query:
# SELECT ?re 
# WHERE { 
#  <http://dbpedia.org/resource/The_Beatles> <http://dbpedia.org/property/reference> ?object .
#  }
#
