class TasksController < ApplicationController
  def index
    @tasks = Task.find()
  end
  
  def new
    @task = Task.new
  end
  
  def create
    @task = Task.new(params[:task])
    @task.creator_id = current_user.id
    @task.save
  end
end
