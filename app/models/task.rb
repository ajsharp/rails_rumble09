class Task < ActiveRecord::Base
  validates_presence_of :title, :on => :create, :message => "can't be blank"
  validates_presence_of :creator_id, :on => :create, :message => "can't be blank"
  
  belongs_to :creator, :class_name => "User", :foreign_key => "creator_id"
  has_many :assignments
  has_many :users, :through => :assignments
  has_many :comments
  
  before_save :check_for_new_assignee, :if => lambda { |m| m.new_assignee }
  
  attr_accessor :new_assignee
  
  
  protected
    def check_for_new_assignee
      users << User.find_or_create_new_user(new_assignee) if new_assignee
    end
  
    def validate
      if (self.action_by > self.due_date)
        errors.add_to_base("Action By Date cannot be after Due Date!")
      end
    end
end