class Tag < ActiveRecord::Base
  belongs_to :creator, :class_name=> "User" #, :foreign_key => :creator_id
  has_many :children, :class_name => "Tag", :foreign_key=>:parent_id
  belongs_to :parent, :class_name=>"Tag"
end
