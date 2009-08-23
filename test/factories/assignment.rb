Factory.define :assignment do |f|
  f.assigner    { |a| a.association(:user) }
  f.assignee    { |a| a.association(:user) }
  f.task_id     1  
  f.status  "pending"
end