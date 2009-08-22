class Assignment < ActiveRecord::Base
  include AASM
  include AASM::Persistence
  aasm_column :status
  
  aasm_initial_state :unaccepted
  aasm_state :unaccepted
  aasm_state :accepted
  aasm_state :declined
  aasm_state :completed
  
  aasm_event :accept_assignment do
    transitions :to => :accepted, :from => :unaccepted
  end
  
  aasm_event :decline_assignment do
    transitions :to => :declined, :from => :unaccepted
  end
  
  aasm_event :complete_assignment do
    transitions :to => :completed, :from => :accepted
  end
  
  belongs_to :assigner, :class_name => "User", :foreign_key => "assigner_id"
  belongs_to :assignee, :class_name => "User", :foreign_key => "assignee_id"
  belongs_to :task
  
  validates_presence_of :assigner_id, :on => :create, :message => "can't be blank"
  validates_presence_of :assignee_id, :on => :create, :message => "can't be blank"
  validates_presence_of :task_id, :on => :create, :message => "can't be blank"
end
