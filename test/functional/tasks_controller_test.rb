require 'test_helper'

class TasksControllerTest < ActionController::TestCase
  context "given a user who is updating a task" do
    setup do
      @task = Factory(:task, :title => "Task Title")
      put :update, :task => { :title => "New Task Title" }, :task_id => @task.id
    end
    
    should_respond_with :redirect
    should_route  :put, "/tasks/1", :action => :update, :id => 1
  end # end of given a user who is editing a task
  
end
