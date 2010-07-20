require 'test_helper'

class ParticipationsControllerTest < ActionController::TestCase
  def setup
     @request.cookies['remember_token'] = CGI::Cookie.new('remember_token', users(:phoebe).remember_token)
  end
  
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:participations)
  end

  test "should get new" do
    get :new, :trip_id => trips(:geek).id
    assert_response :success
  end

  test "should create participation" do
    assert_difference('Participation.count', 1) do
      post :create, :participation => 
        {:trip_id => trips(:active).id, :travel_date => "7/4/2010"}
    end
    assert_redirected_to trip_path(trips(:active))
  end

  test "should show participation" do
    get :show, :id => participations(:part1).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => participations(:part1).to_param
    assert_response :success
  end

  test "should update participation" do
    put :update, :id => participations(:part1).to_param, :participation => {:travel_date => "8/9/2011" }
    assert_redirected_to trip_path(assigns(:participation).trip)
  end

  test "should destroy participation" do
    assert_difference('Participation.count', -1) do
      delete :destroy, :id => participations(:part1).to_param
    end

    assert_redirected_to trips_path
  end
end
