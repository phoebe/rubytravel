class TripsController < ApplicationController
  # GET /trips
  # GET /trips.xml
<<<<<<< HEAD:app/controllers/trips_controller.rb
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
    #@trips = Trip.all
=======
  def index
    @trips = Trip.all
>>>>>>> 10da8583e5392072805cd13988d0b0c5c92442bd:app/controllers/trips_controller.rb

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @trips }
    end
  end

  # GET /trips/1
  # GET /trips/1.xml
<<<<<<< HEAD:app/controllers/trips_controller.rb
  before_filter :authenticate
  def show
    @trip = Trip.find(params[:id],:include => :users)
@participations=@trip.participations
=======
  def show
    @trip = Trip.find(params[:id])

>>>>>>> 10da8583e5392072805cd13988d0b0c5c92442bd:app/controllers/trips_controller.rb
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @trip }
    end
  end

  # GET /trips/new
  # GET /trips/new.xml
<<<<<<< HEAD:app/controllers/trips_controller.rb
  before_filter :authenticate
  def new
    @user = current_user()
    #@trip = Trip.new
    @trip = @user.trips.build
=======
  def new
    @trip = Trip.new
>>>>>>> 10da8583e5392072805cd13988d0b0c5c92442bd:app/controllers/trips_controller.rb

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @trip }
    end
  end

  # GET /trips/1/edit
<<<<<<< HEAD:app/controllers/trips_controller.rb
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
=======
  def edit
    @trip = Trip.find(params[:id])
>>>>>>> 10da8583e5392072805cd13988d0b0c5c92442bd:app/controllers/trips_controller.rb
  end

  # POST /trips
  # POST /trips.xml
<<<<<<< HEAD:app/controllers/trips_controller.rb
  before_filter :authenticate
  def create
    @user = current_user()
    @trip = @user.trips.new(params[:trip])
=======
  def create
    @trip = Trip.new(params[:trip])
>>>>>>> 10da8583e5392072805cd13988d0b0c5c92442bd:app/controllers/trips_controller.rb

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
<<<<<<< HEAD:app/controllers/trips_controller.rb
  before_filter :authenticate
  def update
    @trip = Trip.find(params[:id])
    params[:trip][:participations] ||=[]
    respond_to do |format|
      if @trip.user_id == current_user.id && @trip.update_attributes(params[:trip])
=======
  def update
    @trip = Trip.find(params[:id])

    respond_to do |format|
      if @trip.update_attributes(params[:trip])
>>>>>>> 10da8583e5392072805cd13988d0b0c5c92442bd:app/controllers/trips_controller.rb
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
  # DELETE /trips/1.xml
<<<<<<< HEAD:app/controllers/trips_controller.rb
  before_filter :authenticate
  def destroy
    @trip = Trip.find(params[:id])
    @trip.destroy if @trip.user_id == current_user.id
=======
  def destroy
    @trip = Trip.find(params[:id])
    @trip.destroy

>>>>>>> 10da8583e5392072805cd13988d0b0c5c92442bd:app/controllers/trips_controller.rb
    respond_to do |format|
      format.html { redirect_to(trips_url) }
      format.xml  { head :ok }
    end
  end
end
