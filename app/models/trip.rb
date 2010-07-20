class Trip < ActiveRecord::Base
  belongs_to :owner, :class_name => "User"
  has_many :participations, :dependent => :destroy
  has_many :participants, :through => :participations, :source => :user
  has_many :profiles, :through => :participations
  has_many :suggestions
  
  validates_date :departureDate, :allow_blank => true
  validates_presence_of :name
  
  #create a cluster of attractions matching tags around city centers
  def self.clusterLocations( tagpoints,trip) # cities, places )
    places= Place.supportsTags(tagpoints, trip.departureDate )
    findSuggestions =Suggestions.new(places)
    coords=findSuggestions.getCenters(); # city center
    #cities=Location.closestCities(coords,50); # within 50 miles
    cities=Location.nearbyCities(coords,40); # within 40 miles
    # longer trips can have bigger clusters - remove outliers
    places= findSuggestions.addAssignmentSqDist(trip.duration) 
    
    @suggestions=[]
    i=0
    cities.each { |p|
      @suggestions[i]= {};
      @suggestions[i][:city]=p;   # biggest city within 50 miles
      @suggestions[i][:latlng]=coords[i]; # real coord
      @suggestions[i][:diff]= Suggestions::haversine_distance(coords[i],[p.latitude,p.longitude])
      @suggestions[i][:places]=[]
      i= i+1;
    }
    # longer trips can have bigger clusters - how big?
  
    places.each { |p| 
      #@suggestions[p.cluster][:places]=[] if @suggestions[p.cluster][:places].blank?     
      p['diff']= Suggestions::haversine_distance(@suggestions[p.cluster][:latlng],[p.latitude,p.longitude])
      @suggestions[p.cluster][:places] << p
    }
    # drop suggestions if not too many options
    @suggestions.reject! { |item| item[:places].size < 3; } 
    
    return @suggestions
  end
end
