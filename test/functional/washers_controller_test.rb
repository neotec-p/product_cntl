require 'test_helper'

class WashersControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:washers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create washer" do
    assert_difference('Washer.count') do
      post :create, :washer => { }
    end

    assert_redirected_to washer_path(assigns(:washer))
  end

  test "should show washer" do
    get :show, :id => washers(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => washers(:one).to_param
    assert_response :success
  end

  test "should update washer" do
    put :update, :id => washers(:one).to_param, :washer => { }
    assert_redirected_to washer_path(assigns(:washer))
  end

  test "should destroy washer" do
    assert_difference('Washer.count', -1) do
      delete :destroy, :id => washers(:one).to_param
    end

    assert_redirected_to washers_path
  end
end
