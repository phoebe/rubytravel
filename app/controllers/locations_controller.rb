class LocationsController < ApplicationController
  # GET /locations
  # GET /locations.xml
  def index
    conditions={}
       params[:country]='US' if params[:country].blank?
       # match(use_code) against params[:use_code] as score
       conditions[:country_code]= params[:country] unless params[:country].blank?
       #conditions[:feature_code_like]= params[:feature] unless params[:feature].blank?
       conditions[:name_like]= params[:name] unless params[:name].blank?
       conditions[:admin1_code_like]= params[:admin1] unless params[:admin1].blank?
    @locations =  
       Location.find( :all, :conditions => conditions, :order => 'name ASC').paginate  :page => params[:page], :per_page => 20 
      #Location.paginate  :page => params[:page], :order => 'name ASC', :per_page => 20 
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @location }
    end
  end

  # GET /locations/1
  # GET /locations/1.xml
  def show
    @location = Location.find(:first, :conditions => [ "geonameid = ?", params[:id] ] )
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @location }
    end
  end

  # GET /locations/new
  # GET /locations/new.xml
  def new
    @location = Location.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @location }
    end
  end

  # GET /locations/1/edit
  def edit
    @location = Location.find(params[:id])
  end

  # POST /locations
  # POST /locations.xml
  def create
    @location = Location.new(params[:location])

    respond_to do |format|
      if @location.save
        flash[:notice] = 'Location was successfully created.'
        format.html { redirect_to(@location) }
        format.xml  { render :xml => @location, :status => :created, :location => @location }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @location.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /locations/1
  # PUT /locations/1.xml
  def update
    @location = Location.find(params[:id])

    respond_to do |format|
      if @location.update_attributes(params[:location])
        flash[:notice] = 'Location was successfully updated.'
        format.html { redirect_to(@location) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @location.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /locations/1
  # DELETE /locations/1.xml
  def destroy
    @location = Location.find(params[:id])
    @location.destroy

    respond_to do |format|
      format.html { redirect_to(locations_url) }
      format.xml  { head :ok }
    end
  end
end
