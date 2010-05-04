
require "rubygems"
require 'active_record'
require 'time';
require "open-uri"
require 'active_rdf';
#require 'active_rdf_sparql';


 spend='http://localhost:8890/sparql';
  # vt= new SparqlAdapter(  :url => spend, :engine=> :virtuoso, :results => :xml, :request_method => :get , :timeout => 30)


  # vt.execute_sparql_query(qs, header=nil) {|*clauses| ...}   

#ConnectionPool.set_data_source(:type => :sparql, :results => :sparql_xml, :engine=>:virtuoso,
                               #:url=> 'http://localhost:8890/sparql');

pool = ConnectionPool.add_data_source :type => :sparql,
    :engine=>:virtuoso,
    :url => "http://dbpedia.org/sparql",
      :results => :sparql_xml


Namespace.register :foaf, 'http://xmlns.com/foaf/0.1/'
Namespace.register :dc, 'http://purl.org/dc/elements/1.1/'
Namespace.register :quote, 'http://purl.org/vocab/quotation/schema'

QUOTE::Quotations.find_by_dc::creator('Loren, Sophia').each do | quote |

# print the important stuff from each graph
#
#     # http://purl.org/vocab/quotation/schema#quote has to be manually added as a predicate
#         # the “#” seems to cause problems
  quote.add_predicate(:quote, QUOTE::quote)
  puts quote.quote
  puts quote.subject
  puts quote.rights
  puts quote.isPrimaryTopicOf

end

  edittext='New Zealand';
  resource_name = edittext.gsub(/ /, '_')
  references = Query.new.distinct(:reference).
      where(RDFS::Resource.new("http://dbpedia.org/resource/#{resource_name}"), 
          RDFS::Resource.new('http://dbpedia.org/property/reference'), 
          :reference).
      execute

      if not abstract.nil?
                  puts "<p>#{abstract[0]}</p><br />"
      end


