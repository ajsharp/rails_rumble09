class Activity < ActiveRecord::Base
  belongs_to :user
  belongs_to :task
  
  validates_presence_of :user_id, :task_id, :description
end
