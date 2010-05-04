class PlacesController < ApplicationController
  # GET /places
  # GET /places.xml
  def index
    #@places = Place.all
    @places =  
    if params[:use_code].blank? && params[:name].blank?
      Place.paginate  :page => params[:page], :order => 'name ASC', :per_page => 20 
    else
=begin # ar extension doesn't work?
      conditions={}
      conditions[:use_code_like]= '%'+params[:use_code]+'%' unless params[:use_code].blank?
      conditions[:name_like]= '%'+params[:name]+'%' unless params[:name].blank?
=end
      clist=[]
      conditions=['blank']
      unless params[:use_code].blank?
        clist <<  'use_code like ?'
        conditions << '%'+params[:use_code]+'%'
      end
      unless params[:name].blank?
        clist <<  'name like ?'
        conditions << '%'+params[:name]+'%'
      end
      conditions[0]= clist.join(' and '); 
      puts conditions.inspect
      Place.find( :all, :conditions => conditions).paginate  :page => params[:page], :order => 'name ASC', :per_page => 20 
    end
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
