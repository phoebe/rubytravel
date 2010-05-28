class TripsController < ApplicationController
  # GET /trips
  # GET /trips.xml

  before_filter :authenticate
  def index
    if (signed_in?)
      @user= User.find( current_user().id);
    else
      print "Must signed in first";
    end
    @trips = Trip.all
    @mytrips = Trip.find(:all,:conditions=>[ 'user_id=?',current_user().id ] )  if (@user)
    @participations=@user.participations
    @parttrips = @user.trips if (@user)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @trips }
    end
  end

  # GET /trips/1
  # GET /trips/1.xml

  before_filter :authenticate
  def show
    @trip = Trip.find(params[:id],:include => :users)
    @participations=@trip.participations
    profile_list= @participations.collect { |p| p.profile_id }
    
    (@tags,@points,@tagpoints)=Tag.forProfiles(profile_list)
   # @res= Place.supportsTagsLoc(@tags,45,-120,300, @trip.departureDate )
    @res= Place.supportsTags(@tags, @trip.departureDate )
    @cluster=Cluster.new(@res)
    coords=@cluster.getCenters();
    cities=Location.closestCities(coords);
    @res= @cluster.addAssignmentSqDist()
    
    @suggestions=Trip.clusterLocations( cities, @res )
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @trip }
    end
  end

  # GET /trips/new
  # GET /trips/new.xml

  before_filter :authenticate
  def new
    @user = current_user()
    #@trip = Trip.new
    @trip = @user.trips.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @trip }
    end
  end

  # GET /trips/1/edit

  before_filter :authenticate
  def edit
    @user = current_user()
    begin
      @trip = Trip.find(:first,:conditions =>['id =? and user_id=?',params[:id],@user.id])
      #@trip = @user.trips.find(params[:id], :include => :participation)
      #@trip = @user.trips.find(params[:id], :include => :user)
      @tags= Tag.find(:all,  :conditions => ['parent_id is null'] );
    rescue ActiveRecord::RecordNotFound
      flash[:notice] =("Please edit only the trips you initiated")
      @trip=nil
    end
 end

  # POST /trips
  # POST /trips.xml

  before_filter :authenticate
  def create
    @user = current_user()
    @trip = @user.trips.new(params[:trip])

    respond_to do |format|
      if @trip.save
        flash[:notice] = 'Trip was successfully created.'
        format.html { redirect_to(@trip) }
        format.xml  { render :xml => @trip, :status => :created, :location => @trip }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @trip.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /trips/1
  # PUT /trips/1.xml

  before_filter :authenticate
  def update
    @trip = Trip.find(params[:id])
    #params[:trip][:participations] ||=[]
    respond_to do |format|
      if @trip.user_id == current_user.id && @trip.update_attributes(params[:trip])
        flash[:notice] = 'Trip was successfully updated.'
        format.html { redirect_to(@trip) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @trip.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /trips/1
  before_filter :authenticate
  def destroy
    @trip = Trip.find(params[:id])
    @trip.destroy if @trip.user_id == current_user.id
    respond_to do |format|
      format.html { redirect_to(trips_url) }
      format.xml  { head :ok }
    end
  end
end
