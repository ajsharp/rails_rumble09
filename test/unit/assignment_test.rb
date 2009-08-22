require 'test_helper'

class AssignmentTest < ActiveSupport::TestCase
  context "a valid Assignment" do
    should "have a valid Factory" do
      assert Factory.build(:assignment).valid?
      assert Factory(:assignment)
    end
    
    should_belong_to :user
    should_belong_to :task
  end # end of a valid Assignment
  
end
