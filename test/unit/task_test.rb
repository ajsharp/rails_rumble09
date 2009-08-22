require 'test_helper'

class TaskTest < ActiveSupport::TestCase
  should_validate_presence_of :title, :creator_id
  
  should_belong_to :creator
end
