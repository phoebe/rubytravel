class ParticipationsController < ApplicationController
  # GET /participations
  # GET /participations.xml
  before_filter :authenticate
  def index
    @participations = Participation.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @participations }
    end
  end

  # GET /participations/1
  # GET /participations/1.xml
  def show
    @participation = Participation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @participation }
    end
  end

  # GET /participations/new
  # GET /participations/new.xml
  def join
    @user = current_user()
    @profiles=  @user.profiles
    @trip=Trip.find(params[:trip_id])
    @participation = @user.participations.build(params[:trip])
    @participation.trip_id=@trip.id
    @participation.traveldate=@trip.departureDate
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @participation }
    end
  end

  # GET /participations/1/edit
  def edit
    @user = current_user()
    @profiles=  @user.profiles 
    @participation = Participation.find(params[:id])
    @trip=Trip.find(@participation.trip_id) unless @participation.trip_id.nil?
  end

  # POST /participations
  # POST /participations.xml
  def create
    @user = current_user()
    @participation = @user.participations.new(params[:participation])
    @trip=Trip.find(@participation.trip_id)
    is_OK=true;
    if @trip.nil?
      flash[:notice] = 'No such trip'
      is_OK=false
    end
    if @participation.user_id !=@user.id
      flash[:notice] = 'You are adding someone other than yourself'
      is_OK=false
    end
    respond_to do |format|
      if is_OK && @participation.save
        flash[:notice] = 'Participation was successfully created.'
        format.html { redirect_to(@trip) }
        format.xml  { render :xml => @trip, :status => :created, :location => @trip }
      else
        format.html { render :action => "join" }
        format.xml  { render :xml => @participation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /participations/1
  # PUT /participations/1.xml
  def update
    @participation = Participation.find(params[:id])
    
    respond_to do |format|
      if @participation.update_attributes(params[:participation])
        flash[:notice] = 'Participation was successfully updated.'
        format.html { redirect_to(trips_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @participation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /participations/1
  # DELETE /participations/1.xml
  def destroy
    @participation = Participation.find(params[:id])
    @participation.destroy

    respond_to do |format|
      format.html { redirect_to(trips_path) }
      format.xml  { head :ok }
    end
  end
end
