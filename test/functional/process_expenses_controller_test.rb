require 'test_helper'

class ProcessExpensesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:process_expenses)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create process_expense" do
    assert_difference('ProcessExpense.count') do
      post :create, :process_expense => { }
    end

    assert_redirected_to process_expense_path(assigns(:process_expense))
  end

  test "should show process_expense" do
    get :show, :id => process_expenses(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => process_expenses(:one).to_param
    assert_response :success
  end

  test "should update process_expense" do
    put :update, :id => process_expenses(:one).to_param, :process_expense => { }
    assert_redirected_to process_expense_path(assigns(:process_expense))
  end

  test "should destroy process_expense" do
    assert_difference('ProcessExpense.count', -1) do
      delete :destroy, :id => process_expenses(:one).to_param
    end

    assert_redirected_to process_expenses_path
  end
end
