require 'test_helper'

class TaskTest < ActiveSupport::TestCase
  context "a valid Task" do
    should "have a valid Factory" do
      assert Factory.build(:task).valid?
      assert Factory(:task).save
    end
    
    should_validate_presence_of :title, :creator_id  
    should_belong_to :creator
  end # end of a valid Task  
end
