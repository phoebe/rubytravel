module TripsHelper
  def getTags 
    #@participations=@trip.participations
    unless @participations.nil?
    profile_list= @participations.profile_id.collect
    @tags= Profile_Tags.find(
      :all,
      :conditions =>{ :profile_id_in => profile_list }
    )
    end
  end
end
