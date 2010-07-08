class TripsController < ApplicationController
  # GET /trips
  # GET /trips.xml
 before_filter :authenticate
 
  def index
    @user= current_user
    @trips = Trip.all
    @owntrips = @user.own_trips 
    @participations=@user.participations

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @trips }
    end
  end

  # GET /trips/1
  # GET /trips/1.xml

  def show
    @trip = Trip.find(params[:id],:include => :participants)
    @participations=@trip.participations
    profile_list= @participations.collect { |p| p.profile_id }    
    (@tags,@points,@tagpoints)=Tag.forProfiles(profile_list) # find interests
   # @res= Place.supportsTagsLoc(@tags,45,-120,300, @trip.departureDate )
    begin
       @suggestions=Trip.clusterLocations(@tags,@trip) # find interesting places around cities
    rescue Exception => err
       @suggestions = []
       flash[:error] = "Can't get suggestions: #{err.to_s}"
    end
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @trip }
    end
  end

  # GET /trips/new
  # GET /trips/new.xml

  def new
    @user = current_user()
    @trip = @user.own_trips.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @trip }
    end
  end

  # GET /trips/1/edit


  def edit
    @user = current_user()
    begin
      @trip = @user.own_trips.find(params[:id])
      @tags= Tag.find(:all,  :conditions => ['parent_id is null'] );
    rescue ActiveRecord::RecordNotFound
      flash[:notice] =("Please edit only the trips you initiated")
      @trip=nil
    end
 end

  # POST /trips
  # POST /trips.xml


  def create
    @user = current_user()
    @trip = @user.own_trips.new(params[:trip])

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


  def update
    @trip = Trip.find(params[:id])
    #params[:trip][:participations] ||=[]
    respond_to do |format|
      if @trip.owner_id == current_user.id && @trip.update_attributes(params[:trip])
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

  def destroy
    @trip = Trip.find(params[:id])
    @trip.destroy if @trip.owner_id == current_user.id
    respond_to do |format|
      format.html { redirect_to(trips_url) }
      format.xml  { head :ok }
    end
  end
end
