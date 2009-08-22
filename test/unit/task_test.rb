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
    
    should "only be able to be assigned to one user at a time" do
      # pending
    end
    
    should_validate_presence_of :title, :creator_id  
    should_belong_to :creator
  end # end of a valid Task  
end
