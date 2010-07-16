class Profile < ActiveRecord::Base
  belongs_to :user
  has_many :profiles_tags
  has_many :tags, :through => :profiles_tags
  has_many :participations, :dependent => :destroy
  
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :user_id
  
end
