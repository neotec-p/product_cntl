require 'test_helper'

class ItemsWashersControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:items_washers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create items_washer" do
    assert_difference('ItemsWasher.count') do
      post :create, :items_washer => { }
    end

    assert_redirected_to items_washer_path(assigns(:items_washer))
  end

  test "should show items_washer" do
    get :show, :id => items_washers(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => items_washers(:one).to_param
    assert_response :success
  end

  test "should update items_washer" do
    put :update, :id => items_washers(:one).to_param, :items_washer => { }
    assert_redirected_to items_washer_path(assigns(:items_washer))
  end

  test "should destroy items_washer" do
    assert_difference('ItemsWasher.count', -1) do
      delete :destroy, :id => items_washers(:one).to_param
    end

    assert_redirected_to items_washers_path
  end
end
