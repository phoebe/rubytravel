class TagsController < ApplicationController
  # GET /tags
  # GET /tags.xml
  def index
    @tags = Tag.find(:all, :conditions => ['parent_id is null'] )
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tags }
    end
  end

  # GET /tags/1
  # GET /tags/1.xml
  def show
    @tag = Tag.find(params[:id])
    @children= @tag.children
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @tag }
    end
  end

  def showplaces
    @tag = Tag.find(params[:id])
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
  def new
    @tag = Tag.new
    if ! params[:tag_id].nil?
      @tag.parent = Tag.find(params[:tag_id])
    end
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @tag }
    end
  end

  # GET /tags/1/edit
  before_filter :authenticate
  def edit
    @tag = Tag.find(params[:id])
  end

  # POST /tags
  # POST /tags.xml
  before_filter :authenticate
  def create

    if ( params[:tag][:uri].nil? || params[:tag][:uri].empty?)
      params[:tag][:uri] = URIPREFIX+params[:tag][:name].gsub(' ','_')
    end    
    params[:tag][:name] = params[:tag][:name].downcase
    @tag = Tag.new(params[:tag])
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
    @tag = Tag.find(params[:id])

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
  def destroy
    @tag = Tag.find(params[:id])
    @tag.destroy

    respond_to do |format|
      format.html { redirect_to(tags_url) }
      format.xml  { head :ok }
    end
  end
end
