class Task < ActiveRecord::Base
  validates_presence_of :title, :on => :create, :message => "can't be blank"
  validates_presence_of :creator_id, :on => :create, :message => "can't be blank"
  
  belongs_to :creator, :class_name => "User", :foreign_key => "creator_id"
  has_many :assignments
  has_many :assigners, :through => :assignments
  has_many :assignees, :through => :assignments
  accepts_nested_attributes_for :assignments
  
  has_many :comments
  has_many :activities
  
  before_save :check_for_new_assignee, :if => lambda { |m| m.new_assignee }
  
  attr_accessor :new_assignee, :assigner_id
  
  def pretty_date(att)
    send(att).strftime("%b %e, %Y")
  end
  
  protected
    def check_for_new_assignee
      assignments.create!({ :assigner_id => assigner_id, :assignee_id => User.find_or_create_new_user(new_assignee).id })
    end
  
    def validate
      if (!self.action_by.blank? and !self.due_date.blank?) and (self.action_by > self.due_date)
        errors.add_to_base("Action By Date cannot be after Due Date!")
      end
    end
end