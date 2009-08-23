require 'digest/sha1'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  include Authorization::AasmRoles
  is_gravtastic!

  # Validations
  validates_format_of :name, :with => RE_NAME_OK, :message => MSG_NAME_BAD, :allow_nil => true
  validates_length_of :name, :maximum => 100
  validates_presence_of :email, :if => :not_using_openid?
  validates_length_of :email, :within => 6..100, :if => :not_using_openid?
  validates_uniqueness_of :email, :case_sensitive => false, :if => :not_using_openid?
  validates_format_of :email, :with => RE_EMAIL_OK, :message => MSG_EMAIL_BAD, :if => :not_using_openid?
  validates_uniqueness_of :identity_url, :unless => :not_using_openid?
  validate :normalize_identity_url
  
  # Relationships
  has_and_belongs_to_many :roles
  has_many :tasks, :foreign_key => "creator_id"
  has_many :assignments_assigned, :class_name => "Assignment", :foreign_key => "assigner_id"
  has_many :assignments, :class_name => "Assignment", :foreign_key => "assignee_id"
  has_many :assigned_tasks, :through => :assignments, :source => :task # tasks assigned to me
  has_many :tasks_assigned, :through => :assignments_assigned, :source => :task # tasks assigned to other people
  has_many :comments
  
  has_many :connections
  has_many :friends, :through => :connections, :conditions => ["connections.status = ?" , "accepted"]
  has_many :inverse_friendships, :class_name => "Connection", :foreign_key => "friend_id"
  has_many :inverse_friends, :through => :inverse_friendships, :source => :user, :conditions => ["connections.status = ?" , "accepted"]
  
  has_many :activities

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :name, :password, :password_confirmation, :identity_url
  
  def friend_list
    friends + inverse_friends
  end
  
  def self.find_or_create_new_user(params)
    @user = User.find_by_email(params[:email])
    if @user.nil?
      temp_password = PhonemicPassword.generate(8)
      activate_code = Digest::SHA1.hexdigest(Time.now.to_s)
      @user = User.new(:email => params[:email], 
                      :password => temp_password, 
                      :password_confirmation => temp_password, 
                      :name => params[:name])
      # required to do things this way because of the way plugin works
      @user.state = 'pending'
      @user.activation_code = activate_code
      @user.generated = true
      @user.save
      if params[:friend_request]
        return [@user, temp_password] # total hack
      else
        UserMailer.deliver_generated_signup_notification(@user, temp_password)
      end
    end
    
    @user
  end
  
  def request_friendship_with!(user)
    connections.create!(:friend => user)
  end

  # Authenticates a user by their email and unencrypted password.  Returns the user or nil.
  def self.authenticate(email, password)
    u = find_in_state :first, :active, :conditions => { :email => email } # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end
  
  # Check if a user has a role.
  def has_role?(role)
    list ||= self.roles.map(&:name)
    list.include?(role.to_s) || list.include?('admin')
  end
  
  # Not using open id
  def not_using_openid?
    identity_url.blank?
  end
  
  # Overwrite password_required for open id
  def password_required?
    new_record? ? not_using_openid? && (crypted_password.blank? || !password.blank?) : !password.blank?
  end
  
  def get_recent_activities
    # get the user's activites
    user_activities = self.activities.all(:order => 'created_at DESC', :limit => 15)
    
    # get the activities for tasks assigned to the user
    my_tasks = self.tasks_assigned.map(&:id)
    mytask_activities = []
    mytask_activities = Activity.find(:all, :conditions => ["task_id IN (?)", my_tasks], :order => 'created_at DESC', :limit => 15) unless my_tasks.blank?
    
    # get the activities for tasks assigned by the user
    other_peoples_tasks = self.assigned_tasks.map(&:id)
    theirtask_activites = []
    theirtask_activites = Activity.find(:all, :conditions => ["task_id IN (?)", other_peoples_tasks], :order => 'created_at DESC', :limit => 15) unless other_peoples_tasks.blank?
    
    combined = (user_activities + mytask_activities + theirtask_activites).uniq # combine and only get unique objects
    combined = combined.sort_by { |activity| activity.created_at } # sort all activities by created_at date
    return combined[0..14] # only return most recent 15 activites
  end

  protected
    
  def make_activation_code
    self.deleted_at = nil
    self.activation_code = self.class.make_token
  end
  
  def normalize_identity_url
    self.identity_url = OpenIdAuthentication.normalize_url(identity_url) unless not_using_openid?
  rescue URI::InvalidURIError
    errors.add_to_base("Invalid OpenID URL")
  end
end
