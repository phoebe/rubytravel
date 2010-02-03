class Place < ActiveRecord::Base
  has_many :tags
  has_many :children, :class_name => "Place", :foreign_key=>:parent_id
  belongs_to :parent, :class_name=>"Place"
end
