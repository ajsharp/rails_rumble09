// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(document).ready(function() {
  ////
  // ui.datepicker fields
  $("#task_action_by").datepicker();
  $("#task_due_date").datepicker();
  
  // hijack remote delete requests to be ajax
  $('a.remote-delete').click(function() {
    // we just need to add the key/value pair for the DELETE method
    // as the second argument to the JQuery $.post() call
    $.post(this.href, { _method: 'delete' }, null, "script");
    return false;
  });
  
  // make tabs work the way we need
  $("a.tabs").click(function() {
    // hide all divs in the tabs div
    $("#tabs div").hide();
    // show the correct div
    $("#" + this.rel).show();
    
    // take off active classes on subnav
    $("#subnav li").removeClass('active');
    // set active class on correct li
    $("li." + this.rel).addClass('active');
    
    return false;
  });
  
  // assignment picker
  $(".pick_choice").click(function() {
    $("#friend").hide();
    $("#email").hide();
    if(div == 'email') {
      $('#assignment_assignee_id').val('');
    } else {
      $("#new_assignee_name").val('');
      $("#_new_assignee_email").val('');
    }
    var div = $('input:radio:checked').val();
    $("#" + div).show();
  })
})