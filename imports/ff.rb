require 'rubygems'
require 'active_rdf'
#require 'active_rdf_sparql'

# we add an existing SPARQL database as datasource
ConnectionPool.add_data_source(:type => :sparql, :results => :sparql_xml,
  :url => "http://dbpedia.org/sparql") 
#
#  # we register a short-hand notation for the namespace used in this test data 
  Namespace.register(:atomrdf, 'http://atomowl.org/ontologies/atomrdf#')
  Namespace.register(:common_sense_mapping, 'http://www.loa-cnr.it/ontologies/CommonSenseMapping.owl#')
  Namespace.register(:dbpedia, 'http://dbpedia.org/')
  Namespace.register(:dc, 'http://purl.org/dc/elements/1.1/')
  Namespace.register(:dcterms, 'http://purl.org/dc/terms/')
  Namespace.register(:dolce_lite, 'http://www.loa-cnr.it/ontologies/DOLCE-Lite.owl#')
  Namespace.register(:event, 'http://purl.org/NET/c4dm/event.owl#')
  Namespace.register(:extended_dns, 'http://www.loa-cnr.it/ontologies/ExtendedDnS.owl#')
  Namespace.register(:foaf, 'http://xmlns.com/foaf/0.1/')
  Namespace.register(:gforge_ont, 'http://swc.projects.semwebcentral.org/owl/gforge-ont#')
  Namespace.register(:koala, 'http://protege.stanford.edu/plugins/owl/owl-library/koala.owl#')
  Namespace.register(:mo, 'http://purl.org/ontology/mo/')
  Namespace.register(:northwind, 'http://www.openlinksw.com/schemas/northwind#')
  Namespace.register(:ontology, 'http://purl.org/ontology/')
  Namespace.register(:periodic_table, 'http://www.daml.org/2003/01/periodictable/PeriodicTable#')
  Namespace.register(:pim_contact, 'http://www.w3.org/2000/10/swap/pim/contact#')
  Namespace.register(:relationship, 'http://purl.org/vocab/relationship/')
  Namespace.register(:rss, 'http://purl.org/rss/1.0/modules/content/')
  Namespace.register(:siocex, 'http://activerdf.org/sioc/')
  Namespace.register(:sioc, 'http://rdfs.org/sioc/ns#')
  Namespace.register(:sioc_types, 'http://rdfs.org/sioc/types#')
  Namespace.register(:skos, 'http://www.w3.org/2004/02/skos/core#')
  Namespace.register(:time, 'http://www.w3.org/2006/time#')
  Namespace.register(:timeline, 'http://purl.org/NET/c4dm/timeline.owl#')
  Namespace.register(:vocab_frbr_core, 'http://purl.org/vocab/frbr/core#')
  Namespace.register(:vocab, 'http://purl.org/vocab/')
  Namespace.register(:wgs84_pos, 'http://www.w3.org/2003/01/geo/wgs84_pos#')
  Namespace.register(:wordnet, 'http://xmlns.com/wordnet/1.6/')

  Namespace.register :res, 'http://dbpedia.org/resource/'
  ObjectManager.construct_classes
#

  references = Query.new.distinct(:reference).where(RDFS::Resource.new("http://dbpedia.org/resource/#{resource_name}"), RDFS::Resource.new('http://dbpedia.org/property/reference'),:reference).execute
  puts references

