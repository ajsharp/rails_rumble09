class Assignment < ActiveRecord::Base
  FORM_PARAMS_ALLOWED_ACTIONS = ["accept_assignment", "decline_assignment", "complete_assignment"]
  
  class InvalidActionFromFormParams < StandardError
  end
  
  include AASM
  include AASM::Persistence
  aasm_column :status
  
  aasm_initial_state :pending
  aasm_state :pending
  aasm_state :accepted, :enter => :assume_responsibility
  aasm_state :declined
  aasm_state :passed
  aasm_state :completed, :enter => :finish_task
  
  aasm_event :accept_assignment do
    transitions :to => :accepted, :from => [:pending, :passed]
  end
  
  aasm_event :decline_assignment do
    transitions :to => :declined, :from => :pending
  end
  
  aasm_event :complete_assignment do
    transitions :to => :completed, :from => :accepted
  end
  
  aasm_event :pass_task do
    transitions :to => [:passed], :from => [:accepted]
  end
    
  belongs_to :assigner, :class_name => "User", :foreign_key => "assigner_id"
  belongs_to :assignee, :class_name => "User", :foreign_key => "assignee_id"
  belongs_to :task
  
  validates_presence_of :assigner_id, :on => :create, :message => "can't be blank"
  validates_presence_of :assignee_id, :on => :create, :message => "can't be blank"
  validates_presence_of :task_id, :on => :create, :message => "can't be blank"
    
  attr_accessor :new_assignee

  def perform_action_from_form_params!(action)
    FORM_PARAMS_ALLOWED_ACTIONS.detect { |event| event == action } ? send("#{action}!".to_sym) : raise(Assignment::InvalidActionFromFormParams, "#{action} is not an approved action.")
  end

  protected
    
    def assume_responsibility
      task.current_owner.assignments.find(:last, :conditions => {:task_id => task_id}).pass_task!
    end
    
    def finish_task
      assigner.last_assignment_for_task(task).accept_assignment! unless assigner == assignee
    end
  
    # def validate
    #   if task.current_owner != transferer
    #     errors.add_to_base("You're not the current owner of this task, so you can't transfer it.")
    #   end
    # end
end