class ProfilesController < ApplicationController

  before_filter :authenticate
  
  # GET /profiles
  # GET /profiles.xml

  def index
    if ( signed_in? ) 
      @user = User.find( current_user().id);
    else
      print( "Must sign in first" )
    end
    if (@user)
      @profiles = @user.profiles

    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @profiles }
    end
  end

  # GET /profiles/1
  # GET /profiles/1.xml

  def show
    @profile = Profile.find(params[:id],:include => :tags)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @profile }
    end
  end

  # GET /users/1/profiles/new.xml

  def new
    @user = current_user()
    @profile = @user.profiles.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @profile }
    end
  end

  # GET /profiles/1/edit

  def edit
    @user = current_user()
    begin 
      @profile = @user.profiles.find(params[:id], :include => :tags)
    rescue ActiveRecord::RecordNotFound
      flash[:notice] =("Please edit only the profiles in your list")
      @profile=nil
   end
  end

  # POST /profiles
  # POST /profiles.xml

  def create
    @user = current_user()
    @profile = @user.profiles.new(params[:profile])

    respond_to do |format|
      if @profile.save
        flash[:notice] = 'Profile was successfully created.'
        format.html { redirect_to(@profile) }
        format.xml  { render :xml => @profile, :status => :created, :location => @profile }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @profile.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /profiles/1
  # PUT /profiles/1.xml

  def update
    @profile = Profile.find(params[:id])
    params[:profile][:tag_ids] ||=[]
    respond_to do |format|
      if @profile.user_id == current_user.id && @profile.update_attributes(params[:profile])
        flash[:notice] = 'Profile was successfully updated.'
        format.html { redirect_to(@profile) }
        format.xml  { head :ok }
      else
        flash.now[:error] = @profile.errors
        format.html { render :action => "edit" }
        format.xml  { render :xml => @profile.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /profiles/1
  # DELETE /profiles/1.xml

  def destroy
    @profile = Profile.find(params[:id])
    if @profile.user_id == current_user.id
      @profile.destroy
    end
    respond_to do |format|
      format.html { redirect_to(profiles_url) }
      format.xml  { head :ok }
    end
  end
end
