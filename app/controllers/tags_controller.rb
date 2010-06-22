class TagsController < ApplicationController
  # GET /tags
  # GET /tags.xml
  def index
    tags = Usetag.find(:all, :conditions => ['parent_id is null'] )
    t2= Placetag.find(:all, :conditions => ['parent_id is null'] )
	@tags=tags+t2
    #@tags = Usetag.all;
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tags }
    end
  end

  # GET /tags/1
  # GET /tags/1.xml
  def show
	begin
		@tag = Usetag.find(params[:id])
		@children= @tag.children
	rescue
		@tag= Placetag.find(params[:id]) if @tag.blank?
		@children= @tag.children
	end
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @tag }
    end
  end

  def showplaces
    @tag = Usetag.find(params[:id])
    @children= @tag.children
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @tag }
    end
  end

 # def show_children
  #  @tags = Tag.find( params[:id]).children
   #if ( request.xhr? ) # ajax
      #render :layout => false, :action => 'tag_menu', :tags => @tags
      # display the non xmlHttpRequest later
   # end
 # end

  # GET /tags/new
  # GET /tags/new.xml
  before_filter :authenticate
  def new_notallowed
    @tag = Usetag.new
    if ! params[:tag_id].nil?
      @tag.parent = Usetag.find(params[:tag_id])
    end
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @tag }
    end
  end

  # GET /tags/1/edit
  before_filter :authenticate
  def edit
	begin
		@tag = Usetag.find(params[:id])
		@children= @tag.children
	rescue
		@tag= Placetag.find(params[:id]) if @tag.blank?
		@children= @tag.children
	end
  end

  # POST /tags
  # POST /tags.xml
  before_filter :authenticate
  def create_notallowed
    if ( params[:tag][:uri].nil? || params[:tag][:uri].empty?)
      params[:tag][:uri] = URIPREFIX+params[:tag][:name].gsub(' ','_')
    end    
    params[:tag][:name] = params[:tag][:name].downcase
    @tag = Usetag.new(params[:tag])
    respond_to do |format|
      if @tag.save
        flash[:notice] = 'Tag was successfully created.'
        format.html { redirect_to(@tag) }
        format.xml  { render :xml => @tag, :status => :created, :location => @tag }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @tag.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /tags/1
  # PUT /tags/1.xml
  before_filter :authenticate
  def update
	begin
		@tag = Usetag.find(params[:id])
		@children= @tag.children
	rescue
		@tag= Placetag.find(params[:id]) if @tag.blank?
		@children= @tag.children
	end

    respond_to do |format|
      if @tag.update_attributes(params[:tag])
        flash[:notice] = 'Tag was successfully updated.'
        format.html { redirect_to(@tag) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tag.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /tags/1
  # DELETE /tags/1.xml
  before_filter :authenticate
  def destroy_notallowed
    @tag = Usetag.find(params[:id])
    @tag.destroy

    respond_to do |format|
      format.html { redirect_to(tags_url) }
      format.xml  { head :ok }
    end
  end
end
