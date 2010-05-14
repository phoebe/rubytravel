require 'test_helper'

class ParticipationsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:participations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create participation" do
    assert_difference('Participation.count') do
      post :create, :participation => { }
    end

    assert_redirected_to participation_path(assigns(:participation))
  end

  test "should show participation" do
    get :show, :id => participations(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => participations(:one).to_param
    assert_response :success
  end

  test "should update participation" do
    put :update, :id => participations(:one).to_param, :participation => { }
    assert_redirected_to participation_path(assigns(:participation))
  end

  test "should destroy participation" do
    assert_difference('Participation.count', -1) do
      delete :destroy, :id => participations(:one).to_param
    end

    assert_redirected_to participations_path
  end
end
