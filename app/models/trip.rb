class Trip < ActiveRecord::Base
  belongs_to :owner, :class_name => "User"
  has_many :participations, :dependent => :destroy
  has_many :participants, :through => :participations, :source => :user
  has_many :profiles, :through => :participations
  has_many :suggestions
  
  validates_date :departure_date, :allow_blank => true
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :owner_id
  
  #create a cluster of attractions matching tags around city centers
  def self.clusterLocations( tags,trip) # cities, places )
    return [] if tags.empty?
    places= Place.supportsTags(tags, trip.departure_date )
    findSuggestions =Suggestions.new(places)
    coords=findSuggestions.getCenters(); # city center
    #cities=Location.closestCities(coords,50); # within 50 miles
    cities=Location.nearbyCities(coords,40); # within 40 miles
	  #puts "cities: #{cities.inspect}"
    # longer trips can have bigger clusters - remove outliers
	trip.duration=5 if trip.duration.blank?
    places= findSuggestions.addAssignmentSqDist(trip.duration) 
    
    @suggestions=[]
    i=0
    cities.each { |p|
	  #puts "cities: #{p.inspect}"
      @suggestions[i]= {};
      @suggestions[i][:city]=p;   # biggest city within 50 miles
      @suggestions[i][:latlng]=coords[i]; # real coord
      @suggestions[i][:diff]= Suggestions::haversine_distance(coords[i],[p.latitude,p.longitude])
      @suggestions[i][:places]=[] # init
      i= i+1;
    }
    # longer trips can have bigger clusters - how big?
  
    places.each { |p| 
	  #puts "place: #{p.name} #{p.cluster}"
      p['diff']= Suggestions::haversine_distance(@suggestions[p.cluster][:latlng],[p.latitude,p.longitude])
      @suggestions[p.cluster][:places] << p
    }
    # drop suggestions if not too many options
	@suggestions.reject! { |item|
		item[:places].size < 1
	} 
    
    return @suggestions
  end
end
