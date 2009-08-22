class TasksController < ApplicationController
  before_filter :login_required
  
  def index
    @created_tasks = Task.find_all_by_creator_id(current_user.id)
    @assigned_tasks = current_user.assigned_tasks
    @tasks_assigned = current_user.tasks_assigned
  end
  
  def new
    @task = Task.new
  end
  
  def create
    @task = Task.new(params[:task])
    @task.creator = current_user
    if @task.save
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end

  def edit
    @task = Task.find(params[:id])
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
