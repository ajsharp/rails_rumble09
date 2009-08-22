class ConnectionsController < ApplicationController
  before_filter :login_required, :get_current_user
  
  def index
    @current_friends = @user.friends.paginate(:all, :page => params[:page], :per_page => 15)
    @pending_friends = @user.connections.waiting_approval.paginate(:all, :page => params[:page], :per_page => 15)
    @friend_requests = Connection.all(:conditions => ["status = ? AND friend_id = ?", 'pending', @user.id])
  end
  
  def new
    @connection = @user.connections.new
  end
  
  def create
    friend_user = User.find_by_email(params[:query]) # try to find by email
    friend_user ||= User.find_by_name(params[:query]) # try to find by name
    if friend_user.nil?
      flash[:notice] = 'Could not find specified user.'
      redirect_to request_membership_connections_path and return
    end
    @connection = @user.connections.new(:friend_id => friend_user.id)
    if @connection.save
      UserMailer.deliver_friend_request(@user, friend)
      flash[:success] = "A connection request has been sent to the user."
      redirect_to connections_path
    else
      flash.now[:error] = "There was an error with the friend request."
      render :action => 'new'
    end
  end
  
  def request_membership
    if request.post?
      user_array = User.find_or_create_new_user(params)
      new_user = user_array[0]
      temp_password = user_array[1]
      @connection = @user.connections.new(:friend_id => new_user.id)
      UserMailer.deliver_generated_friend_request(@user, new_user, temp_password)
      if @connection.save
        flash[:success] = "A connection request has been sent to the user."
        redirect_to connections_path
      else
        flash.now[:error] = "There was an error with the friend request."
      end
    end
  end
  
  def update
    @connection = Connection.find(params[:id])
    respond_to do |format|
      if @connection.update_attribute(:status, params[:response])
        format.html { redirect_to connections_path }
      else
        format.html {
          flash[:error] = "An error occured."
          redirect_to connections_path
        }
      end
    end
  end
  
  def destroy
    @connection = Connection.find(params[:id])
    respond_to do |format|
      if @connection.destroy
        format.html {
          flash[:notice] = 'Friend connection has been removed.'
          redirect_to connections_path
        }
        format.js {
          render :update do |page|
            page.remove dom_id(connection)
          end
        }
      else
        format.html {
          flash[:error] = 'Friend connection could not be removed.'
          redirect_to connections_path
        }
        format.js {
          render :update do |page|
            page.alert "The friend connection could not be removed."
          end
        }
      end
    end
  end
  
  protected
  def get_current_user
    @user = current_user
  end
end
