require 'test_helper'

class ActivitiesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:activities)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create activities" do
    assert_difference('Activities.count') do
      post :create, :activities => { }
    end

    assert_redirected_to activities_path(assigns(:activities))
  end

  test "should show activities" do
    get :show, :id => activities(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => activities(:one).to_param
    assert_response :success
  end

  test "should update activities" do
    put :update, :id => activities(:one).to_param, :activities => { }
    assert_redirected_to activities_path(assigns(:activities))
  end

  test "should destroy activities" do
    assert_difference('Activities.count', -1) do
      delete :destroy, :id => activities(:one).to_param
    end

    assert_redirected_to activities_path
  end
end
