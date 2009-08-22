class ActivitiesController < ApplicationController
  # GET /activities
  # GET /activities.xml
  def index
    if(params[:user_id] && params[:task_id])
      @activities = Activity.find(:first, :conditions => ["user_id = ? and task_id = ?", params[:user_id], params[:task_id]])
    elsif(params[:user_id])
      @activities = Activity.find_by_user_id(params[:user_id])
    elsif(params[:task_id])
      @activities = Activity.find_by_user_id(params[:task_id])
    else
      @activities = Activity.all
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @activities }
    end
  end
end
