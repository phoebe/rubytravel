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


end
