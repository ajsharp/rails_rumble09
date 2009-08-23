class Task < ActiveRecord::Base
  include AASM
  include AASM::Persistence
  aasm_column :status
  
  # aasm_initial_state Proc.new { |task| task.assignments.empty? ? :not_started }
  aasm_initial_state :not_started
  aasm_state :not_started
  aasm_state :in_progress
  aasm_state :completed
  
  aasm_event :start_task do
    transitions :to => :in_progress, :from => :not_started
  end
  
  aasm_event :complete_task do
    transitions :to => :completed, :from => :in_progress
  end
  
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
  after_create { |task| task.assignments.create!(:assigner => task.creator, :assignee => task.creator, :status => "accepted") }
  after_create :log_activity
  
  attr_accessor :new_assignee, :assigner_id
  
  def pretty_date(att)
    send(att).strftime("%b %e, %Y")
  end
  
  def current_owner
    assignments.find(:last, :conditions => ["assignments.status = ?", "accepted"]).assignee
  end
  
  def pending_user
    if pass_pending?
      assignments.find(:last, :conditions => ["assignments.status = ?", "pending"]).assignee
    end
  end
  
  def pass_pending?
    !assignments.find(:last, :conditions => ["assignments.status = ?", "pending"]).blank?
  end
    
  def pass!(opts = {})
    assignments.create!(:assigner => opts[:from], :assignee => opts[:to])
    log_pass_activity(opts[:from], opts[:to])
  end
  
  def user_can_pass?(user)
    assignments.find_by_assignee_id(user.id).status == "accepted"
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
    
    def log_activity
      activity = Activity.new
      activity.user = self.creator
      activity.task = self
      activity.description = "#{self.creator.name} created task '#{self.title}'."
      activity.save
    end
    
    def log_pass_activity(from, to)
      activity = Activity.new
      activity.user = from
      activity.task = self
      activity.description = "#{from.name} passed task '#{self.title}' to #{to.name}."
      activity.save
    end
end