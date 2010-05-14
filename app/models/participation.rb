class Participation < ActiveRecord::Base
  belongs_to  :trip
  belongs_to  :user
  belongs_to  :profile
  validates_uniqueness_of :trip_id, :scope => [:user_id, :profile_id]
  validates_presence_of :user, :trip
  validates_date   :traveldate    



end
