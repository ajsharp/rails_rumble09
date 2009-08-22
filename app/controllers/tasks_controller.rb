class TasksController < ApplicationController
  before_filter :login_required
  
  def index
    @tasks = Task.find()
  end
  
  def new
    @task = current_user.tasks.new
  end
  
  def create
    @task = current_user.tasks.new(params[:task])
    @task.save
  end
end
