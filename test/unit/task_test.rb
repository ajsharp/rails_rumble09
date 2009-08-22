require 'test_helper'

class TaskTest < ActiveSupport::TestCase
  context "a valid Task" do
    setup do
      @task = Factory.build(:task)
    end
    
    should "have a valid Factory" do
      assert Factory.build(:task).valid?
      assert Factory(:task)
    end
    
    should "be invalid if action_by date is after due date" do
      @task = Factory.build(:task, :action_by => (DateTime.now + 1.day), :due_date => DateTime.now)
      assert !@task.valid?
    end
    
    should "only validate action_by against due_date if both are filled in" do
      task = Factory.build(:task, :action_by => nil, :due_date => DateTime.now)
      assert_nil(@task.errors.on(:base))
      
      task = Factory.build(:task, :action_by => DateTime.now, :due_date => nil)
      assert_nil(@task.errors.on(:base))
    end
    
    should_validate_presence_of :title, :creator_id
    should_belong_to :creator
  end # end of a valid Task
  
  context "given a Task" do
    setup do
      @task = Factory(:task)
    end
    
    context "when new_assignee attribute is assigned" do
      setup do
        @new_assignee = Factory(:user)
      end
      
      context "and the new assignee is an existing user" do
        should "create a new Assignment instance connecting the new assignee and the task" do
          assert_difference "Assignment.count", 1 do
            @task.new_assignee = { :email => @new_assignee.email }
            @task.save
          end
        end
      end # end of and the new assignee is an existing user
      
      context "and the new assignee is a new user" do
        should "create a new Assignment instance connecting the new assignee and the task" do
          assert_difference "Assignment.count", 1 do
            @task.new_assignee = { :email => "new_user@example.com", :name => "New User" }
            @task.save
          end
        end
      end # end of and the new assignee is a new user
    end # end of when new_assignee_id attribute is assigned
  end # end of a Task can be assigned to a new user
  
  
end
