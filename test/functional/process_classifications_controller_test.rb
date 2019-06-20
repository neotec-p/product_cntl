require 'test_helper'

class ProcessClassificationsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:process_classifications)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create process_classification" do
    assert_difference('ProcessClassification.count') do
      post :create, :process_classification => { }
    end

    assert_redirected_to process_classification_path(assigns(:process_classification))
  end

  test "should show process_classification" do
    get :show, :id => process_classifications(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => process_classifications(:one).to_param
    assert_response :success
  end

  test "should update process_classification" do
    put :update, :id => process_classifications(:one).to_param, :process_classification => { }
    assert_redirected_to process_classification_path(assigns(:process_classification))
  end

  test "should destroy process_classification" do
    assert_difference('ProcessClassification.count', -1) do
      delete :destroy, :id => process_classifications(:one).to_param
    end

    assert_redirected_to process_classifications_path
  end
end
