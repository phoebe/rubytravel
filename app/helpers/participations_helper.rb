module ParticipationsHelper


 # Generate appropriate links for destroying or modifying participation 
  def part_change_links(part)
    link_to('Change', edit_participation_path(part)) + " | " + 
    link_to('Leave', part, :confirm => 'Are you sure you want to leave this trip?', :method => :delete)
  end

end
