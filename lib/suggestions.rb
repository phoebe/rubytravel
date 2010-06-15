require "kmeans"
require "enumerator"

# This definitions should have been addressed in kmclass.i
class Suggestions 
  RAD_PER_DEG = 0.017453293  #  PI/180
  
  # the great circle distance d will be in whatever units R is in
  GCDR={}
  GCDR['miles'] = 3956.0           # radius of the great circle in miles
  GCDR['km'] = 6371.0              # radius in kilometers...some algorithms use 6367
  GCDR['feet'] = GCDR['miles'] * 5282   # radius in feet
  GCDR['meters'] = GCDR['km'] * 1000    # radius in meters
    
  def initialize(points)
    @mypoints= points
    numpoints=points.size 
    @numCenters = findSpread(10)
		# num of centers determined by spread or loc/radius
    @numCenters = 4 if @numCenters < 4
    @numCenters = 10 if @numCenters > 10
    puts "clustering #{numpoints} points"

    @kmc = Kmeans::KMCluster.new(@numCenters , 2, numpoints , 100) 
    readPoints(points)
    puts "read points"

    @kmc.runCluster(Kmeans::KMCluster::HYBRID) if numpoints>10; # hybrid
    #puts "clustered points, start GB collect"
    #GC.start   # don't know why, but it seems to stop mem errors in swig/ruby
    puts "GB collected"
  end
  
  # find bounding box of the cluster
  def findSpread(clustersz)
	begin
		maxp=[-180,-180]
		minp=[180,180]
		@mypoints.each { |p|
		  maxp[0]= p.latitude if  maxp[0] < p.latitude
		  minp[0]= p.latitude if  minp[0] > p.latitude
		  maxp[1]= p.longitude if  maxp[1] < p.longitude
		  minp[1]= p.longitude if  minp[1] > p.longitude
		}
		lng= (maxp[1]-minp[1])/clustersz;
		lat=(maxp[0]-minp[0])/clustersz;
		return Integer( (lat> lng)? lat:lng );
	rescue => details
		puts "got an exception #{details.inspect}"
	end
  end
  

  # find distance between 2 geopoint
  def self.haversine_distance(p1, p2, unit='miles')
    
    #default 4 sig figs reflects typical 0.3% accuracy of spherical model
    precision = 4;  
    r = GCDR[unit]# Indicates how wide spread the cluster is 6371; # km
    dLat = (p2[0] - p1[0])* RAD_PER_DEG;
    dLon = (p2[1] - p1[1])* RAD_PER_DEG;

    a = Math.sin(dLat/2) * Math.sin(dLat/2) +
    Math.cos(p1[0] * RAD_PER_DEG ) * Math.cos(p2[0] * RAD_PER_DEG ) * 
    Math.sin(dLon/2) * Math.sin(dLon/2);
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
    d = r * c;
    return d
  end
 
  #read the points of place list into a 2D array
  def readPointsV()
    darray= Kmeans::FloatVector.new();
    #darray=Array.new
    @mypoints.each { |p|
      darray << p.latitude
      darray << p.longitude
    }
    @kmc.readPtVector(darray); 
  end

  def readPoints(points)
	  begin
	  i=0;
	  points.each { |p|
		  @kmc.readdataPt(i, p.latitude,p.longitude);
		  i=i+1;
	  }
	  @kmc.setNpts(i);
	 rescue => details
		puts "got an exception in readPoints #{details.inspect}"
	  end
  end
  
  # gets a list of the centers returned by clustering
  def getCenters()
	begin
		pts = @kmc.getcenterPoints();
		darray=Array.new
		pts.each_slice(2) { |p|
		  darray << p
		}
		return darray;
	 rescue => details
		puts "got an exception in getCenter #{details.inspect}"
	 	return nil;
	 end
  end

	  
  # gets a list of the assignments and distance of each place from the centers
  def addAssignmentSqDist(duration)
  begin
    #sd= @kmc.getsqDist;
    #assgn= @kmc.getassignments()
    i=0;
    @mypoints.each { |p|
      #p['cluster']=assgn[i]
      #p['sqdist']=sd[i]
      #p.cluster = assgn[i] 
      #p.sqdist =sd[i]
	  p.sqdist=  @kmc.getsqDistd(i)
	  p.cluster= @kmc.getAssignmentd(i)
      i=i+1;
    }    
    # this needs better mapping, assume willing to drive 50 mi for a day trip
    #  1~=50mi, 4 ~= 126 mi, 15 ~= 200 mi
    @mypoints.reject! {  |p| 
      p.sqdist > duration;  
      #p['sqdist'] > duration;   
    }
    return @mypoints;
	rescue  => details
		puts "got an exception in addAssignment #{details.inspect}"
	end
  end

end
