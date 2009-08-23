class ApplicationController < ActionController::Base
  include ExceptionNotifiable
  include AuthenticatedSystem
  include RoleRequirementSystem

  helper :all # include all helpers, all the time
  filter_parameter_logging :password, :password_confirmation
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  
  before_filter :set_globals
  
  protected
  
  # Automatically respond with 404 for ActiveRecord::RecordNotFound
  def record_not_found
    render :file => File.join(RAILS_ROOT, 'public', '404.html'), :status => 404
  end
  
  def set_globals
    @current_controller = controller_name
    @current_action = action_name
  end
  
end

