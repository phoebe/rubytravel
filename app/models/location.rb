require 'GeonameDB'
class Location < GeonameDB
  #set_table_name 'allCountries'
  set_table_name 'allCountries'
  attr_reader :geonameid


  def initialize(id)
    @id = id
  end
  
  def to_param
    @id
  end
  



end
