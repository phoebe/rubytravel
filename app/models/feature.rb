require 'GeonameDB'

class Feature < GeonameDB
  #set_table_name 'features'
  set_table_name 'plcategory'
  cattr_reader :per_page
    @@per_page = 20

def indxkey
  if  ( self.code.nil? ) 
      return ("what!");
  else
    return self.code.sub('.','_');
  end
end

def name
	self.code
end

def description
	self.descr
end

  def children
     Feature.find(:all, :conditions => [ 'parent_id=?', self.id] )
  end

  def fcode
    return self.code.slice(2..10);
  end
 
end
