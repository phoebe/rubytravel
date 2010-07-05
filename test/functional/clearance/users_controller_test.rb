require 'test_helper'

class Clearance::UsersControllerTest < ActionController::TestCase

  test "should create user" do
    assert_difference('User.count') do
      post :create, :user => { :login=>'josie',:email=>'josie@gmail.com',:password=>'josie', :password_confirmation=>'josie', :email_confirmed => true, :latitude => 42.383, :longitude=>-71.055}
    end

    assert_redirected_to sign_in_path
  end


end
