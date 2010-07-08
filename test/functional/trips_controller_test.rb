require 'test_helper'

class TripsControllerTest < ActionController::TestCase
  def setup
     @request.cookies['remember_token'] = CGI::Cookie.new('remember_token', users(:phoebe).remember_token)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:trips)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create trip" do
    assert_difference('Trip.count') do
      post :create, :trip => 
        {:name => 'Functional test trip', :departureDate => "3/17/2011"}
    end

    assert_redirected_to trip_path(assigns(:trip))
  end

  test "should show trip" do
    get :show, :id => trips(:family).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => trips(:family).to_param
    assert_response :success
  end

  test "should update trip" do
    put :update, :id => trips(:family).to_param, :trip => { }
    assert_redirected_to trip_path(assigns(:trip))
  end

  test "should destroy trip" do
    assert_difference('Trip.count', -1) do
      delete :destroy, :id => trips(:family).to_param
    end

    assert_redirected_to trips_path
  end
end
