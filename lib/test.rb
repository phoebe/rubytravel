require 'active_rdf'

# we add an existing SPARQL database as datasource
 ConnectionPool.add_data_source(:type => :sparql, :results => :sparql_xml,
  :url => "http://m3pe.org:8080/repositories/test-people") 
#
#  # we register a short-hand notation for the namespace used in this test data 
  Namespace.register :test, 'http://activerdf.org/test/'
#
#  # now we can access all RDF properties of a person as Ruby attributes:
  eyal = RDFS::Resource.new 'http://activerdf.org/test/eyal'
  puts eyal.test::age
  puts eyal.test::eye
  puts eyal.rdf::type
#
#  # now we construct Ruby classes for the currently existing RDFS classes
  ObjectManager.construct_classes
#
#  # and we can use these classes
  armin = TEST::Person.new 'http://armin-haller.com/#me'
#
#
