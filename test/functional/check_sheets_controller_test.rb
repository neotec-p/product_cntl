require 'test_helper'

class CheckSheetsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:check_sheets)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create check_sheet" do
    assert_difference('CheckSheet.count') do
      post :create, :check_sheet => { }
    end

    assert_redirected_to check_sheet_path(assigns(:check_sheet))
  end

  test "should show check_sheet" do
    get :show, :id => check_sheets(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => check_sheets(:one).to_param
    assert_response :success
  end

  test "should update check_sheet" do
    put :update, :id => check_sheets(:one).to_param, :check_sheet => { }
    assert_redirected_to check_sheet_path(assigns(:check_sheet))
  end

  test "should destroy check_sheet" do
    assert_difference('CheckSheet.count', -1) do
      delete :destroy, :id => check_sheets(:one).to_param
    end

    assert_redirected_to check_sheets_path
  end
end
