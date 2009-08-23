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
end
