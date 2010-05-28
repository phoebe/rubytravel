require "geocoder_google"
class PlacesController < ApplicationController
  layout "application", :except => [:ajax_method, :more_ajax, :another_ajax]
 
  # GET /places
  # GET /places.xml
  def index
    conditions={}
    # match(use_code) against params[:use_code] as score
    conditions[:use_code_like]= params[:use_code] unless params[:use_code].blank?
    conditions[:feature_code_like]= params[:feature] unless params[:feature].blank?
    conditions[:name_like]= params[:name] unless params[:name].blank?
    @places =  
      Place.find( :all, :conditions => conditions, :order => 'name ASC').paginate  :page => params[:page], :per_page => 20 
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @places }
    end
  end

  # GET /places/1
  # GET /places/1.xml
  def show
    @place = Place.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @place }
    end
  end

  # GET /places/new
  # GET /places/new.xml
before_filter :authenticate
  def new
    @place = Place.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @place }
    end
  end

  # GET /places/1/edit
before_filter :authenticate
  def edit
    @place = Place.find(params[:id])
  end

  # POST /places
  # POST /places.xml
before_filter :authenticate
  def create
    @place = Place.new(params[:place])

    respond_to do |format|
      if @place.save
        flash[:notice] = 'Place was successfully created.'
        format.html { redirect_to(@place) }
        format.xml  { render :xml => @place, :status => :created, :location => @place }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @place.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /places/1
  # PUT /places/1.xml
before_filter :authenticate
  def update
    @place = Place.find(params[:id])

    respond_to do |format|
      if @place.update_attributes(params[:place])
        flash[:notice] = 'Place was successfully updated.'
        format.html { redirect_to(@place) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @place.errors, :status => :unprocessable_entity }
      end
    end
  end

  def lookup
    #puts params.inspect 
    p=  params
    address="#{p[:street_address]} #{ p[:city] }, #{p[:state]} #{p[:postal_code]}, #{p[:country_code]}";      
    #puts "address= #{address}"
   #address||=params[:address]   
    if address.length > 5
          @coords=Geocoder.glookup(address)
    else puts "address is bad" 
    end
    #@coords=Geocoder::lookup(params[:place])
    render :layout => false,  :partial=>'latlng',  :object => @coords.nil? ? nil : @coords
  end

  # DELETE /places/1
  # DELETE /places/1.xml
before_filter :authenticate
  def destroy
    @place = Place.find(params[:id])
    @place.destroy
    @places =  
            Place.paginate  :page => params[:page], :order => 'name ASC', :per_page => 20 
       respond_to do |format|
         #format.html # index.html.erb 
         format.html { redirect_to(places_url) }
         format.xml  { render :xml => @places }
       end
       
  end
end
