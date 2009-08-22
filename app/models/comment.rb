class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :task
  
  validates_presence_of :user_id
  validates_presence_of :task_id
  validates_presence_of :message
  
  has_attached_file :attachment,
                    :url => "/system/:class/:attachment/:id/:style/:basename.:extension",  
                    :path => ":rails_root/public/system/:class/:attachment/:id/:style/:basename.:extension"
end
