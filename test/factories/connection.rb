Factory.define :connection do |f|
  f.user    { |a| a.association(:user) }
  f.friend  { |a| a.association(:user) }
  f.status  "pending"
end