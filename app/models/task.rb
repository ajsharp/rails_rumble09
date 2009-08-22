class Task < ActiveRecord::Base
  validates_presence_of :title, :on => :create, :message => "can't be blank"
  validates_presence_of :creator_id, :on => :create, :message => "can't be blank"
  
  belongs_to :creator, :class_name => "User", :foreign_key => "creator_id"
  has_many :assignments
  has_many :users, :through => :assignments
  has_many :comments
  
  before_save :check_for_new_assignee, :if => lambda { |m| m.new_assignee_id }
  
  attr_accessor :new_assignee_id
  
  
  protected
    def check_for_new_assignee
      users << User.find(new_assignee_id) if new_assignee_id
    end
  
    def validate
      if (self.action_by > self.due_date)
        errors.add_to_base("Action By Date cannot be after Due Date!")
      end
    end
end