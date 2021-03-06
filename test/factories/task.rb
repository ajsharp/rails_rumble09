Factory.define :task do |f|
  f.title       "Task Title"
  f.description "Task Description..."
  f.action_by   DateTime.now
  f.due_date    DateTime.now+1.day
  
  f.creator { |a| a.association(:user) }
  
  f.assignments { |a| [] }
end