#class UsersController < ApplicationController
class UsersController <  Clearance::UsersController

  before_filter :authenticate, :except => [:new, :create]

  # GET /users
  # GET /users.xml

  def show
    @user = current_user()
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end
  
  def edit
    @user = current_user()
    respond_to do |format|
      format.html # edit.html.erb
      format.xml  { render :xml => @user }
    end
  end

  def update
    @user = User.find(params[:id])
    respond_to do |format|
      if @user.id == current_user.id && @user.update_attributes(params[:user])
        flash[:notice] = 'User information was successfully updated.'
        format.html { redirect_to(@user) }
        format.xml  { head :ok }
      else
        flash.now[:error] = @user.errors
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

end
