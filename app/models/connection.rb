class Connection < ActiveRecord::Base
  include AASM
  include AASM::Persistence
  aasm_column :status
  
  aasm_initial_state :pending
  aasm_state :pending
  aasm_state :accepted
  aasm_state :rejected
  
  aasm_event :accept_friendship do
    transitions :to => :accepted, :from => :pending
  end
  
  aasm_event :reject_friendship do
    transitions :to => :rejected, :from => :pending
  end
  
  belongs_to :user
  belongs_to :friend, :class_name => "User", :foreign_key => "friend_id"
  
  validates_presence_of :friend_id, :user_id
  
  named_scope :approved, :conditions => ["status = ?", 'accepted']
  named_scope :waiting_approval, :conditions => ["status = ?", 'pending']
  
  after_create :send_request
  
  protected
  def send_request
    UserMailer.deliver_friend_request(self.user, self.friend)
  end
end
