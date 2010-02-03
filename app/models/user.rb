class User < ActiveRecord::Base
  has_many :tags, :foreign_key => :creator_id
  has_many :trips
		
end
