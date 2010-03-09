class User < ActiveRecord::Base
  include Clearance::User
  has_many :tags, :foreign_key => :creator_id
  has_many :trips, :dependent => :destroy
  has_many :profiles, :dependent => :destroy
  
end
