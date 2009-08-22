require 'digest/sha1'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  include Authorization::AasmRoles

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
  has_many :assigned_tasks, :through => :assignments, :source => :task
  has_many :tasks_assigned, :through => :assignments_assigned, :source => :task
  has_many :comments
  has_many :connections
  has_many :friends, :conditions => ["connections.status = ?", "accepted"], :through => :connections
  

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :name, :password, :password_confirmation, :identity_url
  
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
      UserMailer.deliver_generated_signup_notification(@user, temp_password)
    end
    
    @user
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
