require 'test_helper'

class UserTest < ActiveSupport::TestCase
  context "a valid User" do
    should "have a valid Factory" do
      assert Factory.build(:user).valid?
      assert Factory(:user).save
    end
    
    should "not require the login field" do
      assert Factory(:user, :login => nil).valid?
    end
    
    should_validate_presence_of :email
    should_have_many :tasks, :assignments, :comments
    should_have_many :connections
    # should_have_many :friends, :through => :connections
  end # end of a valid User
  
  context "given a user who has friends" do
    setup do
      @user   = Factory(:user)
      @friend = Factory(:user)
      @friendship = Factory(:connection, :user => @user, :friend => @friend, :status => "accepted")
      assert_equal "accepted", @friendship.status
    end
    
    should "only include connection requests that have been approved" do
      assert_same_elements(@user.friend_list, [@friend])
      
      assert_same_elements([@user], @friend.friend_list)
    end
  end # end of a User's friends
  
  context "we need to find or create a new user" do
    setup do
      @existing_user = Factory(:user)
    end
    
    should "return the User instance if passed in user email address exists" do
      assert_equal @existing_user, User.find_or_create_new_user({ :email => @existing_user.email })
    end
    
    should "create a new User instance if user does not exist" do
      assert_difference "User.count", 1 do
        new_user = Factory.build(:user)
        assert_instance_of User, User.find_or_create_new_user({ :name => "User Name", :email => new_user.email })
      end
    end
  end # end of we need to find or create a new user
  
  context "given a user" do
    setup do 
      @user             = Factory(:user)
      @potential_friend = Factory(:user)
    end
    context "when user requests a friendship from another user" do
      setup do
        @user.request_friendship_with!(@potential_friend)
      end
      
      should_change "@user.connections.count", :by => 1
      should_not_change "@user.friends.count"
      
      should "have a status of pending" do
        assert_equal "pending", @user.connections.last.status
      end
    end # end of when user requests a friendship from another user
    
  end # end of given a user
  
  context "given a user who has a task" do
    setup do
      @boss       = Factory(:user)
      @employee   = Factory(:user)
      @task       = Factory(:task, :creator => @boss)
      @assignment = @task.assignments.last
    end
    
    should "be able to get the user's assignment for a given task" do
      assert_equal @assignment, @boss.last_assignment_for_task(@task)
      
      @task.pass! :from => @boss, :to => @employee
      @employee.assignments.last.accept_assignment!
      
      assert_equal @assignment, @boss.last_assignment_for_task(@task)
    end
  end
  
  context "given a user who has completed some tasks" do
    setup do
      @user  = Factory(:user)
      @task1 = Factory(:task, :creator => @user)
      @task2 = Factory(:task, :creator => @user)
      @task3 = Factory(:task, :creator => @user)

      @user.last_assignment_for_task(@task1).complete_assignment!
      @user.last_assignment_for_task(@task2).complete_assignment!
      
      @completed_tasks = @user.tasks_completed
    end
    
    should "be able to get a list of completed tasks" do
      assert_same_elements([@task1, @task2], @user.tasks_completed)
      assert_equal 2, @user.tasks_completed.size
    end
  end
  
  
  
  # context "given a user who has many friends" do
  #   setup do
  #     @user   = Factory(:user)
  #     @friend = Factory(:user)
  #     @user.connections << @friend
  #     @friend.accept_friendship!
  #   end
  #   
  #   should "be able to see a list of his friends" do
  #     assert_same_elements(@user.friends, [@friend])
  #   end
  # end # end of given a user who has many friends
  
  
end
