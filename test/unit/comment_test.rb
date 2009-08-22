require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  context "a valid Comment" do
    should_belong_to :user
    should_belong_to :task
    
    should_validate_presence_of :user_id, :task_id, :message
  end # end of a valid Comment
  
end
