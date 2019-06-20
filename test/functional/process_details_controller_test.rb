require 'test_helper'

class ProcessDetailsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:process_details)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create process_detail" do
    assert_difference('ProcessDetail.count') do
      post :create, :process_detail => { }
    end

    assert_redirected_to process_detail_path(assigns(:process_detail))
  end

  test "should show process_detail" do
    get :show, :id => process_details(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => process_details(:one).to_param
    assert_response :success
  end

  test "should update process_detail" do
    put :update, :id => process_details(:one).to_param, :process_detail => { }
    assert_redirected_to process_detail_path(assigns(:process_detail))
  end

  test "should destroy process_detail" do
    assert_difference('ProcessDetail.count', -1) do
      delete :destroy, :id => process_details(:one).to_param
    end

    assert_redirected_to process_details_path
  end
end
