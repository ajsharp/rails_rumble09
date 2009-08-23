require 'test_helper'

class TaskTest < ActiveSupport::TestCase
  context "a valid Task" do
    should "have a valid Factory" do
      assert Factory.build(:task).valid?
      assert Factory(:task)
    end
    
    should "be invalid if action_by date is after due date" do
      task = Factory.build(:task, :action_by => (DateTime.now + 1.day), :due_date => DateTime.now)
      assert !task.valid?
    end
    
    should "only validate action_by against due_date if both are filled in" do
      task = Factory.build(:task, :action_by => nil, :due_date => DateTime.now)
      assert_nil(task.errors.on(:base))
      
      task = Factory.build(:task, :action_by => DateTime.now, :due_date => nil)
      assert_nil(task.errors.on(:base))
    end
    
    should "accept nested attributes" do
      task = Factory(:task)
      employee = Factory(:user)
      
      task.assigner_id = 1
      assignments_params = {'0'=> {'assignee_id' => employee.id } }
      task.assignments_attributes = assignments_params
      assert_equal 2, task.assignments.size
    end
    
    should_validate_presence_of :title, :creator_id
    should_belong_to :creator
    should_have_db_columns :status
  end # end of a valid Task
  
  context "given a Task" do
    context "when new_assignee attribute is assigned" do
      setup do
        @assigner = Factory(:user)
        @assignee = Factory(:user)
      end
      
      context "and the new assignee is an existing user" do
        should "create a new Assignment instance connecting the new assignee and the task" do
          task = Factory(:task)
          assert_difference "Assignment.count", 1 do
            task.assignments_attributes = { '0'=> 
              { 'assignee_id' => @assignee.id, 'assigner_id' => @assigner.id } }
            task.save
          end
        end
      end # end of and the new assignee is an existing user
      
      context "and the new assignee is a new user" do
        should "create a new Assignment instance connecting the new assignee and the task" do
          task = Factory(:task)
          assert_difference "Assignment.count", 1 do
            task.assigner_id = 1
            task.new_assignee = { :email => "does_not_exist@example.com", :name => "New User" }
            task.save
          end
        end
      end # end of and the new assignee is a new user
    end # end of when new_assignee_id attribute is assigned
  end # end of a Task can be assigned to a new user
  
  context "a user wants to view a pretty date" do
    setup do
      @today    = DateTime.now.utc
      @tomorrow = DateTime.now.utc
      @task     = Factory(:task, :action_by => @today, :due_date => @tomorrow)
    end
    
    should "display the action_by like Jan 12, 2009" do
      assert_equal @today.strftime("%b %e, %Y"), @task.pretty_date(:action_by)
    end
    
    should "display the due date like Jan 12, 2009" do
      assert_equal @tomorrow.strftime("%b %e, %Y"), @task.pretty_date(:due_date)
    end
  end # end of a user wants to view a pretty data
  
  context "a user should be able to pass in an assigner_id" do
    setup { @task = Factory(:task) }
    
    should "return assigner_id" do
      @task.assigner_id = 1
      assert_equal 1, @task.assigner_id
    end
  end # end of a user should be able to pass in an assigner_id  
  
  context "a newly created Task has state" do
    setup { @task = Factory(:task) }
    
    should "have an initial state of 'not_started'" do
      assert_equal "not_started", @task.status
    end
    
    should "have a state of 'in_progress' after starting the task" do
      @task.start_task!
      assert_equal "in_progress", @task.status
    end
    
    should "have a 'completed' state after completing the task" do
      @task.start_task!
      @task.complete_task!
      assert_equal "completed", @task.status
    end
  end # end of a Task starts with a status of 'not started'
  
  context "given a boss who creates a task" do
    setup do
      @boss = Factory(:user, :name => "Boss Man")
      @task = Factory(:task, :creator => @boss)
    end
    
    should "the task is automatically accepted by the creator" do
      assert_equal @task.current_owner, @boss
    end
    
    context "when the boss attempts to pass the task to an employee" do
      setup do
        @employee = Factory(:user, :name => "Employee")
        @task.pass!(:from => @boss, :to => @employee)
      end
      
      should "the boss should still be the owner until the employee accepts it" do
        assert_equal @boss, @task.current_owner
        assert_equal "accepted", @boss.assignments.last.status
      end
      
      context "the employee accepts the task" do
        setup { @employee.assignments.last.accept_assignment! }
        
        should "the employee should be the current owner" do
          assert_equal @employee, @task.current_owner
          assert_equal "passed", @boss.assignments.last.status
        end
        
        context "if the employee passes it on" do
          setup do
            @intern = Factory(:user, :name => "Intern Bitch")
          end
          
          should "the employee should still be the owner until the intern accepts it" do
            @task.pass! :from => @employee, :to => @intern
            assert_equal @employee, @task.current_owner
          end
          
        end
      end
      
    end # end of 
  end # end of a Task should have an active assignment
  
  
end
