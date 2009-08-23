class AssignmentsController < ApplicationController
  before_filter :login_required
  
  def create
    @assignment = Assignment.new(params[:assignment])
    @assignment.assigner = current_user
    
    if @assignment.save
      redirect_back_or_default(tasks_path)
    else
      redirect_to task_url(params[:assignment][:task_id])
      flash[:error] = "An error ocurred when trying to pass the task."
    end
  end
  
  def update
    @assignment = Assignment.find(params[:id])
    @assignment.perform_action_from_form_params!(params[:assignment][:action])

    @assignment.save
    
    redirect_back_or_default dashboard_url
  end
end
