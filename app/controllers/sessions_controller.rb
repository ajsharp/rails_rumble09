class SessionsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => :create
  
  def new
  end

  def create
    logout_keeping_session!
    password_authentication
  end

  def destroy
    logout_killing_session!
    flash[:notice] = "You have been logged out."
    redirect_back_or_default(root_path)
  end

  protected
  
  def password_authentication
    user = User.authenticate(params[:email], params[:password])
    if user
      self.current_user = user
      successful_login
    else
      note_failed_signin
      @email = params[:email]
      @remember_me = params[:remember_me]
      render :action => :new
    end
  end
  
  def successful_login
    new_cookie_flag = (params[:remember_me] == "1")
    handle_remember_cookie! new_cookie_flag
    flash[:notice] = "Logged in successfully"
    redirect_back_or_default(dashboard_path)
  end

  def note_failed_signin
    flash.now[:error] = "Couldn't log you in as '#{params[:email]}'"
    logger.warn "Failed login for '#{params[:email]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
end
