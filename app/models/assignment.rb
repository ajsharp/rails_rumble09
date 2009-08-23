class Assignment < ActiveRecord::Base
  include AASM
  include AASM::Persistence
  aasm_column :status
  
  aasm_initial_state :pending
  aasm_state :pending
  aasm_state :accepted, :enter => :assume_responsibility
  aasm_state :declined
  aasm_state :passed
  aasm_state :completed
  
  aasm_event :accept_assignment do
    transitions :to => :accepted, :from => :pending
  end
  
  aasm_event :decline_assignment do
    transitions :to => :declined, :from => :pending
  end
  
  aasm_event :complete_assignment do
    transitions :to => :completed, :from => :accepted
  end
  
  aasm_event :pass_task do
    transitions :to => :passed, :from => :accepted
  end
    
  belongs_to :assigner, :class_name => "User", :foreign_key => "assigner_id"
  belongs_to :assignee, :class_name => "User", :foreign_key => "assignee_id"
  belongs_to :task
  
  validates_presence_of :assigner_id, :on => :create, :message => "can't be blank"
  validates_presence_of :assignee_id, :on => :create, :message => "can't be blank"
  validates_presence_of :task_id, :on => :create, :message => "can't be blank"

  protected
    def assume_responsibility
      task.current_owner.assignments.find(:last, :conditions => {:task_id => task_id}).pass_task!
    end
  
    # def validate
    #   if task.current_owner != transferer
    #     errors.add_to_base("You're not the current owner of this task, so you can't transfer it.")
    #   end
    # end
end