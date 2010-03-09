class Profile < ActiveRecord::Base
  belongs_to :user
  has_many :tags, :through => :profiles_tags

end
