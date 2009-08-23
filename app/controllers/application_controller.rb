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
  
  def rescue_action_in_public(ex) 
    if ex.is_a? ActiveRecord::RecordNotFound or ex.is_a? ActionController::UnknownAction or ex.is_a? ActionController::RoutingError
	    render :template => "site/404", :status => 404
	  else 
	    super 
	  end 
	end
end

