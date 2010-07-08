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
  
  # Generate appropriate links for either joining, leaving, or modifying participation in this trip
  def trip_part_change_links(trip)
    if current_user.part_trip?(trip)
      part_change_links(trip.participations.find_by_trip_id(trip.id))
    else
      link_to 'Join', join_trip_path(trip) 
    end
  end
  
end
