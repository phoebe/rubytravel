#class UsersController < ApplicationController
class UsersController <  Clearance::UsersController
=begin
  before_filter :authenticate, :except => [:new, :create]
  before_filter :can_only_edit_self, :only => [:edit, :update]
=end
 
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
