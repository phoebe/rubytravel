class Tag < ActiveRecord::Base
  acts_as_tree :counter_cache => :children_count
  belongs_to :creator, :class_name=> "User" #, :foreign_key => :creator_id
  belongs_to :parent, :class_name=>"Tag"
  has_many :children, :class_name => "Tag", :foreign_key=>:parent_id
  has_many :profile_tags
  has_many :profiles, :through => :profiles_tags

  validates_uniqueness_of :name
  validates_uniqueness_of :uri
  
  def Tag.getRoots
    return Tag.find_all_by_parent_id(nil)
  end
  
  def getChildren
    return Tag.find_all_by_parent_id(self.id)
  end

end
