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
        {:trip_id => trips(:family).id, :traveldate => "7/4/2010"}
      puts Participation.all.inspect
      puts "flash is " + flash.inspect
    end
    assert_redirected_to participation_path(assigns(:participation))
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
    put :update, :id => participations(:part1).to_param, :participation => { }
    assert_redirected_to participation_path(assigns(:participation))
  end

  test "should destroy participation" do
    assert_difference('Participation.count', -1) do
      delete :destroy, :id => participations(:part1).to_param
    end

    assert_redirected_to participations_path
  end
end
