require 'GeonameDB'
class Place < GeonameDB
  set_table_name 'places'
  set_primary_key :id
  #has_many :tags
  #has_many :children, :class_name => "Place", :foreign_key=>:parent_id
  #belongs_to :parent, :class_name=>"Place"
  #def id 
    #return self.attributes['id'].to_s 
  #end
  def supportsTags(tags,points)
    tlist= tags.collect{ |t| t.name }
    qstr= 'SELECT *, MATCH (use_code) AGAINST ("'+tagstr+
       '") from places where MATCH (use_code) AGAINST ("'+tagstr+'");'

  end
end
