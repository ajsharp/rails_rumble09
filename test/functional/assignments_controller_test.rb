require 'test_helper'

class AssignmentsControllerTest < ActionController::TestCase
  context "given a boss, employee and task" do
    setup do
      @boss     = Factory(:user)
      @task     = Factory(:task, :creator => @boss)
      @employee = Factory(:user)
    end
    
    context "when the boss makes an error when trying to pass a task" do
      setup do
        login_as @boss
        @task = Factory(:task, :creator => @boss)
        post :create, :assignment => { :task_id => @task.id }
      end
      
      should_redirect_to("task page") { task_url(@task) }
    end
    
    
    context "when the boss passes a task" do
      setup do
        login_as @boss
        assert_difference "Assignment.count", 1 do
          post :create, :assignment => { :assignee_id => @employee.id, :task_id => @task.id }
        end
      end
      
      should "the boss is the creator" do
        assert_equal @boss, Assignment.last.assigner
      end

      should_route :post, "/assignments", :controller => :assignments, :action => :create
    end

    context "an existing user who has a pending task request can accept an assignment" do
      setup do
        login_as @employee
        @task.pass! :from => @boss, :to => @employee
        @assignment = @employee.last_assignment_for_task(@task)
        
        put :update, :id => @assignment.id, :assignment => { :action => "accept_assignment" }
      end
      
      should "show show the status for the employee's task as 'accepted'" do      
        assert_equal "accepted", @employee.last_assignment_for_task(@task).status
      end
      
      should_route :put, "/assignments/1", :controller => :assignments, :action => :update, :id => 1
    end
    
    context "an existing user who has a pending task request can reject an assignment" do
      setup do
        login_as @employee
        @task.pass! :from => @boss, :to => @employee
        @assignment = @employee.last_assignment_for_task(@task)
        
        put :update, :id => @assignment.id, :assignment => { :action => "decline_assignment" }
      end
      
      should "show show the status for the employee's task as 'rejected'" do
        assert_equal "declined", @employee.last_assignment_for_task(@task).status
      end
      
      should_route :put, "/assignments/1", :controller => :assignments, :action => :update, :id => 1
    end
    
    context "an existing user who has a pending task request can complete an assignment" do
      setup do
        login_as @employee
        @task.pass! :from => @boss, :to => @employee
        @employee.last_assignment_for_task(@task).accept_assignment!
        @assignment = @employee.last_assignment_for_task(@task)
        
        put :update, :id => @assignment.id, :assignment => { :action => "complete_assignment" }
      end
      
      should "show show the status for the employee's task as 'completed'" do
        assert_equal "completed", @employee.last_assignment_for_task(@task).status
      end
      
      should_route :put, "/assignments/1", :controller => :assignments, :action => :update, :id => 1
    end
  end
  
  context "an unlogged in user" do
    setup do
      assert_no_difference "Assignment.count" do
        post :create, :assignment => { }
      end
    end
    
    should_respond_with :redirect
    should_redirect_to("login page") { new_session_url }
  end
  
  
end
