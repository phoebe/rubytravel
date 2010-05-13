class Participation < ActiveRecord::Base
  belongs_to  :trip
  belongs_to  :user
  belongs_to  :profile
  validates_uniqueness_of :trip_id, :scope => [:user_id, :profile_id]
  validates_presence_of :user, :trip
  validates_date   :traveldate  

  def validate_on_create # is only run the first time a new object is saved
  end

  def validate_on_update
   # errors.add_to_base("No changes have occurred") if unchanged_attributes?
  end



end
