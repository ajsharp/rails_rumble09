require 'test_helper'

class ConnectionsControllerTest < ActionController::TestCase
  context "given a user requesting a connection with another user" do
    setup do
      @user             = Factory(:user)
      login_as @user
      @potential_friend = Factory(:user)
      post :create, { :query => @potential_friend.email }
    end
    
    should_respond_with :redirect
    should_redirect_to("connections page") { connections_path }
  end # end of given a user requesting a connection with another user
  
end
