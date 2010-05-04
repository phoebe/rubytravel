require "GeonameDB"
class Country < GeonameDB
  set_table_name 'countryInfo'
  attr_reader :iso

end
