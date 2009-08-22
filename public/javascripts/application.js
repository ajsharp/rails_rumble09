// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(document).ready(function() {
  ////
  // ui.datepicker fields
  $("#task_action_by").datepicker();
  $("#task_due_date").datepicker();
  
  $("#assign_to_friend").change(function(){
    if("#assign_to_friend:checked"){
      $("#assign_email").hide();
      $("#assign_email #task_new_assignee_email").attr("name", "email");
      $("#assign_name").hide();
      $("#assign_email #task_new_assignee_name").attr("name", "name");
      $("#assign_friend #task_new_assignee_email").attr("name", "task[new_assignee][email]");
      $("#assign_friend").show();
    }
  })
  $("#assign_to_email").change(function(){
    if("#assign_to_friend:checked"){
      $("#assign_friend").hide();
      $("#assign_friend #task_new_assignee_name").attr("name", "name");
      $("#assign_email #task_new_assignee_email").attr("name", "task[new_assignee][email]");
      $("#assign_name #task_new_assignee_name").attr("name", "task[new_assignee][name]");
      $("#assign_email").show();
      $("#assign_name").show();
    }
  })
})