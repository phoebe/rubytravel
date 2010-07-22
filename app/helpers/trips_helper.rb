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
  def trip_part_change_links(trip,edit=false)
    if current_user.part_trip?(trip)
      links = part_change_links(trip.participations.find_by_trip_id(trip.id))
    else
      links = link_to 'Join', join_trip_path(trip) 
    end
    if current_user.own_trip?(trip)
      if edit
        links += ' | ' + link_to('Edit', edit_trip_path(trip))
      end
      links += " | " + link_to('Delete', trip, :confirm => 'Are you sure you want to delete this trip?', :method => :delete)
    end
    return links
  end
  
end
