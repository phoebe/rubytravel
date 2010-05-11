class Trip < ActiveRecord::Base
  belongs_to :user
  has_many :participations
  has_many :users, :through => :participations
  has_many :profiles, :through => :participations
  has_many :suggestions
end
