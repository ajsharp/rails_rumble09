require 'test_helper'

class AssignmentTest < ActiveSupport::TestCase
  context "a valid Assignment" do
    should "have a valid Factory" do
      assert Factory.build(:assignment).valid?
      assert Factory(:assignment)
    end
    
    should_belong_to :assigner
    should_belong_to :assignee
    should_belong_to :task
    
    should_validate_presence_of :assigner_id, :assignee_id, :task_id
  end # end of a valid Assignment
  
  context "an assignment with a state of pending transitions to accepted" do
    setup do
      @assignment = Factory(:assignment)
    end 
    
    should "change the status to 'accepted'" do
      @assignment.accept_assignment!
      assert_equal @assignment.status, "accepted"
      
      @assignment.complete_assignment!
      assert_equal @assignment.status, "completed"
      
      @assignment.pass_task!
      assert_equal @assignment.status, "passed"
    end
    
    should "change the status to 'accepted'" do
      @assignment.decline_assignment!
      assert_equal @assignment.status, "declined"
    end
  end
  
  context "a boss who creates a task" do
    setup do
      @boss = Factory(:user, :name => "Boss Man")
      @task = Factory(:task, :creator => @boss)
    end
    
    context "and attempts to pass it on to an employee" do
      setup do
        @employee = Factory(:user, :name => "Employee")
        @task.pass! :from => @boss, :to => @employee
      end
      
      context "and employee rejects the task" do
        setup { @employee.last_assignment_for_task(@task).decline_assignment! }
        
        should "change the employee's status for the assignment to 'rejected'" do
          assert_equal "declined", @employee.last_assignment_for_task(@task).status
        end
        
        should "keep the boss' status for the assignment as 'accepted'" do
          assert_equal "accepted", @boss.last_assignment_for_task(@task).status
        end
      end
      
      
      context "and employee accepts the task" do
        setup { @employee.last_assignment_for_task(@task).accept_assignment! }
        
        should "change the boss' status on the assignment to 'passed'" do
          assert_equal "passed", @boss.assignments.last.status
        end

        should "change the employee's status on the assignment to 'accepted" do
          assert_equal "accepted", @employee.assignments.last.status
        end

        context "and when the employee completes the task" do
          setup do
            @employee.assignments.last.complete_assignment!
          end

          should "the employee's assignment status should be 'completed" do
            assert_equal "completed", @employee.assignments.last.status
          end

          should "the boss' assignment status should change back to 'accepted'" do
            assert_equal "accepted", @boss.assignments.last.status
          end

          should "the boss should be the current owner" do
            assert_equal @boss, @task.current_owner
          end
        end
      end
    end
  end
  
  context "given a user who wants to update an assignment via an HTTP request" do
    setup do
      @boss = Factory(:user, :name => "Boss Man")
      @task = Factory(:task, :creator => @boss)
      @employee = Factory(:user)
      @task.pass! :from => @boss, :to => @employee
      @assignment = @task.assignments.last
    end
    
    should "allow the user to accept an assignment" do
      @assignment.perform_action_from_form_params!("accept_assignment")
      assert_equal "accepted", @employee.last_assignment_for_task(@task).status
    end
    
    should "allow the user to decline an assignment" do
      @assignment.perform_action_from_form_params!("decline_assignment")
      assert_equal "declined", @employee.last_assignment_for_task(@task).status
    end
    
    should "allow the user to complete an assignment" do
      @assignment.perform_action_from_form_params!("accept_assignment")
      @assignment.perform_action_from_form_params!("complete_assignment")
      assert_equal "completed", @employee.last_assignment_for_task(@task).status
    end
    
    should "throw an error if the requested action is not approved" do
      assert_raise(Assignment::InvalidActionFromFormParams) { @assignment.perform_action_from_form_params!("MALICIOUS INTENTIONS!!!") }
    end
  end
  
  
end
