require 'test_helper'

class ConnectionTest < ActiveSupport::TestCase
  context "a valid Connection" do
    should "have a valid Factory" do
      assert Factory.build(:connection).valid?
      assert Factory(:connection).save
    end
    
    should "start in the :pending state" do
      assert_equal Factory(:connection).status, "pending"
    end
    
    should_validate_presence_of :friend_id, :user_id
    
    should_belong_to :user
    should_belong_to :friend
    should_have_db_columns :user_id, :friend_id, :status, :accepted_at
  end # end of a valid Connection
  
  context "a user requests a new friend" do
    setup do
      @user       = Factory(:user)
      @friend     = Factory(:user)
      @connection = Factory(:connection)
    end
    
    should "be a pending connection" do
      assert_equal @connection.status, "pending"
    end
    
    context "the friend accepts the connection request" do
      should "change the status to 'accepted'" do
        @connection.accept_friendship!
        assert_equal @connection.status, "accepted"
      end
    end # end of the friend accepts the connection request
    
    context "the friend rejects the connection request" do
      should "change the status to 'rejected'" do
        @connection.reject_friendship!
        assert_equal @connection.status, "rejected"
      end
    end # end of the friend accepts the connection request
    
  end # end of a user requests a new friend
  
  
  
end
