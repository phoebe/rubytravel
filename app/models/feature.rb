require 'GeonameDB'

class Feature < GeonameDB
  set_table_name 'features'
  
def indxkey
  if  ( self.code.nil? ) 
      return ("what!");
  else
    return self.code.sub('.','_');
  end
end

end
