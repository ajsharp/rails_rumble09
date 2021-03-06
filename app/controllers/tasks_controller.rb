class TasksController < ApplicationController
  before_filter :login_required
  
  def index
    @assigned_tasks = current_user.tasks_needing_action
    @tasks_assigned = current_user.expected_tasks
    @tasks_completed= current_user.tasks_completed
  end
  
  def show
    @task = Task.find(params[:id])
    @comment = @task.comments.new
    @recent_activities = @task.activities(:all, :order => "created_at DESC", :limit => 5)
  end
  
  def new
    @task = Task.new
  end
  
  def create
    @task = Task.new(params[:task])
    @task.creator = current_user
    if @task.save
      redirect_to(@task)
    else
      render :action => 'new'
    end
  end

  def edit
    @task = Task.find(params[:id])
    @assignments = @task.assignments.build
  end
  
  def pass
    @task = Task.find(params[:id])
    @assignments = @task.assignments.build
  end

  def update
    @task = Task.find(params[:id])
    if @task.update_attributes(params[:task])
      redirect_to :action => 'index'
    else
      flash[:error]  = ""
      render :action => 'edit'
    end
  end

  def destroy
    @task = Task.find(params[:id])
    if @task.destroy
      redirect_to :action => 'index'
    else
      render :action => 'index'
    end
  end
end
