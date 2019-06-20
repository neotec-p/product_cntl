require 'test_helper'

class ProcessPricesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:process_prices)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create process_price" do
    assert_difference('ProcessPrice.count') do
      post :create, :process_price => { }
    end

    assert_redirected_to process_price_path(assigns(:process_price))
  end

  test "should show process_price" do
    get :show, :id => process_prices(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => process_prices(:one).to_param
    assert_response :success
  end

  test "should update process_price" do
    put :update, :id => process_prices(:one).to_param, :process_price => { }
    assert_redirected_to process_price_path(assigns(:process_price))
  end

  test "should destroy process_price" do
    assert_difference('ProcessPrice.count', -1) do
      delete :destroy, :id => process_prices(:one).to_param
    end

    assert_redirected_to process_prices_path
  end
end
