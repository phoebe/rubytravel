class Tag < ActiveRecord::Base
  acts_as_tree :counter_cache => :children_count,:foreign_key => :parent_id
  belongs_to :creator, :class_name=> "User" #, :foreign_key => :creator_id
  belongs_to :parent, :class_name=>"Tag"
  has_many :children, :class_name => "Tag", :foreign_key=>:parent_id
  has_many :profiles_tags
  has_many :profiles, :through => :profiles_tags

  validates_uniqueness_of :name
  #validates_uniqueness_of :uri
  
  #def Tag.getRoots
    #return Tag.find_all_by_parent_id(nil)
  #end
=begin 
# Not sure how to write this
  named_scope :for_profiles, lambda {
     :select => "tags.*",
     :joins => 'inner join profiles_tags.profile_id = profiles.id and inner join profiles_tags.tag_id=tags.id ',
     :conditions => "profiles_tags.profile_id in (#{profile_ids.join(',')})"
    }
  end
=end
  def self.forProfiles(profile_list)
    points={}
    ptags= ProfilesTag.find(:all,:conditions =>{ :profile_id => profile_list })
    tags_list = ptags.collect { |p|
      points[p.tag_id]= points[p.tag_id].nil? ? 1 : points[p.tag_id]+1;
      p.tag_id
    }
    tags= Tag.find(:all, :conditions => { :id=> tags_list } )
    return tags,points
  end

  def getChildren
    return Tag.find_all_by_parent_id(self.id)
  end

end
