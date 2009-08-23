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
    
    context "and attempts to pass it on to an employee, who accepts the task" do
      setup do
        @employee = Factory(:user, :name => "Employee")
        @task.pass! :from => @boss, :to => @employee
        @employee.assignments.last.accept_assignment!
      end
      
      should "change the boss' status on the assignment to 'passed'" do
        assert_equal "passed", @boss.assignments.last.status
      end
      
      should "change the employee's status on the assignment to 'accepted" do
        assert_equal "accepted", @employee.assignments.last.status
      end
    end
  end
  
end
