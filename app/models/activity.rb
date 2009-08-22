class Activity < ActiveRecord::Base
  belongs_to :user
  belongs_to :task
  
  validates_presence_of :user_id, :if => Proc.new{|o| !o.task_id.blank?}
  validates_presence_of :task_id, :if => Proc.new{|o| !o.user_id.blank?}
  validates_presence_of :description
end
