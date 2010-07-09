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
    @participation = current_user.participations.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @participation }
    end
  end

  # GET /participations/new
  # GET /participations/new.xml
  def new
    @user = current_user()
    @trip=Trip.find(params[:trip_id])
    @participation = @user.participations.build
    @participation.trip_id=@trip.id
    @participation.travel_date=@trip.departure_date
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @participation }
    end
  end

  # GET /participations/1/edit
  def edit
    @user = current_user()
    @participation = @user.participations.find(params[:id])
    @trip=@participation.trip
  end

  # POST /participations
  # POST /participations.xml
  def create
    @user = current_user()
    @participation = @user.participations.find_by_trip_id(params[:participation][:trip_id])
    if @participation
      params[:id] = @participation.id
      return update()
    else
      @participation = @user.participations.new(params[:participation])
    end
    is_OK=true
    @trip=@participation.trip
    if @trip.nil?
      flash[:notice] = 'No such trip'
      is_OK=false
    end
    if @participation.profile.nil?
      profile = @user.profiles.build(:name => "Default profile")
      profile.save!
      @participation.profile = profile
    end
    respond_to do |format|
      if is_OK && @participation.save
        flash[:notice] = 'Participation was successfully created.'
        format.html { redirect_to(@trip) }
        format.xml  { render :xml => @trip, :status => :created, :location => @trip }
      else
        format.html { render :action => "new"}
        format.xml  { render :xml => @participation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /participations/1
  # PUT /participations/1.xml
  def update
    @participation = current_user.participations.find(params[:id])
    
    respond_to do |format|
      if @participation.update_attributes(params[:participation])
        flash[:notice] = 'Participation was successfully updated.'
        format.html { redirect_to(trip_path(@participation.trip)) }
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
    @participation = current_user.participations.find(params[:id])
    @participation.destroy

    respond_to do |format|
      format.html { redirect_to(trips_path) }
      format.xml  { head :ok }
    end
  end
end
