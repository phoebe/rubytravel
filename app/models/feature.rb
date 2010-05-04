require 'GeonameDB'

class Feature < GeonameDB
  set_table_name 'features'
  cattr_reader :per_page
    @@per_page = 20

def indxkey
  if  ( self.code.nil? ) 
      return ("what!");
  else
    return self.code.sub('.','_');
  end
end

  def fcode
    return self.code.slice(2..10);
  end
 
end
