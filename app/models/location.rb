require 'GeonameDB'
class Location < GeonameDB
  #set_table_name 'allCountries'
  set_table_name 'allCountries'
  set_primary_key :geonameid
  #attr_reader :geonameid
  
=begin
def id 
  return self.attributes['geonameid'].to_s 
end

  def geonameid 
    return self.attributes['geonameid'].to_s 
  end
=end

end
