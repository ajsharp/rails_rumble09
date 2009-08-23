class UsersController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => :create
  before_filter :login_required, :only => [:dashboard, :edit, :update]
  
  def new
    @user = User.new
  end
 
  def create
    logout_keeping_session!
    create_new_user(params[:user])
  end
  
  def edit
    @user = current_user
  end
  
  def update
    @user = current_user
    if @user.update_attributes(params[:user])
      flash[:success] = 'User account updated!'
      redirect_to dashboard_path
    else
      flash.now[:error] = 'There was an error updating your account.'
      render :action => 'edit'
    end
  end
  
  def activate
    logout_keeping_session!
    user = User.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    case
    when (!params[:activation_code].blank?) && user && !user.active?
      user.activate!
      if user.generated
        flash[:success] = "You're account has been activated! Sign in to see your tasks."
      else
        flash[:success] = "Signup complete! Please sign in to continue."
      end
      redirect_to login_path
    when params[:activation_code].blank?
      flash[:error] = "The activation code was missing.  Please follow the URL from your email."
      redirect_back_or_default(root_path)
    else 
      flash[:error]  = "We couldn't find a user with that activation code -- check your email? Or maybe you've already activated -- try signing in."
      redirect_back_or_default(root_path)
    end
  end
  
  def dashboard
    @user = current_user
    # get recent activites for user, friends, and tasks
    @recent_activities = @user.get_recent_activities
    @friends = @user.friend_list
    @due_tasks = @user.accepted_tasks
    @expected_tasks = @user.expected_tasks
    @new_task = Task.new
  end
  
  protected
  
  def create_new_user(attributes)
    @user = User.new(attributes)
    if @user && @user.valid?
      if @user.not_using_openid?
        @user.register!
      else
        @user.register_openid!
      end
    end
    
    if @user.errors.empty?
      successful_creation(@user)
    else
      failed_creation
    end
  end
  
  def successful_creation(user)
    redirect_back_or_default(root_path)
    flash[:notice] = "Thanks for signing up!"
    flash[:notice] << " We're sending you an email with your activation code." if @user.not_using_openid?
    flash[:notice] << " You can now login with your OpenID." unless @user.not_using_openid?
  end
  
  def failed_creation(message = 'Sorry, there was an error creating your account')
    flash.now[:error] = message
    render :action => :new
  end
end
