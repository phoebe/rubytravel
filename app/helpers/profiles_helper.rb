module ProfilesHelper

  def profile_contains( tag)
    if @profile 
      @profile.tags.include?(tag)
    else
      false
    end
  end
end
