class CommentsController < ApplicationController
  before_filter :login_required, :get_task
  
  def index
    @comments = @task.comments.all

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def show
    @comment = @task.comments.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  def new
    @comment = @task.comments.new
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def edit
    @comment = @task.comments.find(params[:id])
  end

  def create
    @comment = @task.comments.new(params[:comment])
    @comment.user = current_user
    respond_to do |format|
      if @comment.save
        flash[:notice] = '@task.comments was successfully created.'
        format.html { redirect_to(@comment.task) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def update
    @comment = @task.comments.find(params[:id])
    respond_to do |format|
      if @comment.update_attributes(params[:comment])
        flash[:notice] = '@task.comments was successfully updated.'
        format.html { redirect_to(@comment) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @comment = @task.comments.find(params[:id])
    @comment.destroy
    respond_to do |format|
      format.html { redirect_to(comments_url) }
    end
  end
  
  protected
  def get_task
    @task = Task.find(params[:task_id])
  end
end
