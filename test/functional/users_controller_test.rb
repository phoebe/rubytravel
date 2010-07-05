require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  def setup
  	@request.cookies['remember_token'] = CGI::Cookie.new('remember_token', users(:phoebe).remember_token)
  end

=begin
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end

  test "should get new" do
    get :new
    assert_response :success
  end
=end

  # test "should create user" - moved to test/functional/clearance/users_controller_test.rb
  
  test "should show user" do
    get :show, :id => users(:phoebe).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => users(:phoebe).to_param
    assert_response :success
  end

  test "should update user" do
    put :update, :id => users(:phoebe).to_param, :user => {:first_name=>"Phoebe",:last_name=>"Miller"}
    assert_redirected_to user_path(assigns(:user))
  end

=begin
  test "should destroy user" do
    assert_difference('User.count', -1) do
      delete :destroy, :id => users(:phoebe).to_param
    end
    assert_redirected_to users_path
  end
=end
end
