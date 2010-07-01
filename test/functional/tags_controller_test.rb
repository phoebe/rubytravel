require 'test_helper'

class TagsControllerTest < ActionController::TestCase
  def setup
     @request.cookies['remember_token'] = CGI::Cookie.new('remember_token', users(:phoebe).remember_token)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tags)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create tag" do
    assert_difference('Tag.count') do
      post :create, :tag => { :name=> 'Base Jumping' , :parent=> Tag.find_by_name('active'), :uri=>'http://kalinda.us/ns/BaseJumping' }
    end

    assert_redirected_to tag_path(assigns(:tag))
  end

  test "should show tag" do
    get :show, :id => tags(:outdoors).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => tags(:outdoors).to_param
    assert_response :success
  end

  test "should update tag" do
    put :update, :id => tags(:outdoors).to_param, :tag => { }
    assert_redirected_to tag_path(assigns(:tag))
  end

  test "should destroy tag" do
    assert_difference('Tag.count', -1) do
      delete :destroy, :id => tags(:outdoors).to_param
    end

    assert_redirected_to tags_path
  end
end
