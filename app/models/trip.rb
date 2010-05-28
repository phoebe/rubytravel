class Trip < ActiveRecord::Base
  belongs_to :user
  has_many :participations
  has_many :users, :through => :participations
  has_many :profiles, :through => :participations
  has_many :suggestions
  
  #create a cluster of attractions around city centers
  def self.clusterLocations( cities, places )
    @suggestions=[]
    i=0
    cities.each { |p|
      @suggestions[i]= {};
      @suggestions[i][:city]=p;     
      i= i+1;
    }
    #puts "@suggestions[#{@suggestions.size}] = #{ @suggestions }"
    #arrange places near closest cities
    places.each { |p|
      if @suggestions[p.cluster][:places].blank?
          @suggestions[p.cluster][:places]=[]
      end
      @suggestions[p.cluster][:places] << p
    }
    # drop suggestions if not too many options
    @suggestions.reject! { |item| item[:places].size < 3 } 
    
    return @suggestions
  end
end
