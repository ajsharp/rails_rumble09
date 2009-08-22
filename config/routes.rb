ActionController::Routing::Routes.draw do |map|
  map.resources :comments

  map.resources :activities
 
  # Restful Authentication Rewrites
  map.with_options :controller => 'sessions' do |m|
    m.logout '/logout', :action => 'destroy'
    m.login '/login', :action => 'new'
  end
  
  map.with_options :controller => 'users' do |m|
    m.register '/register', :action => 'create'
    m.signup '/signup', :action => 'new'
    m.activate '/activate/:activation_code', :action => 'activate', :activation_code => nil
    m.dashboard '/dashboard', :action => 'dashboard'
  end
  
  map.with_options :controller => 'passwords' do |m|
    m.forgot_password '/forgot_password', :action => 'new'
    m.change_password '/change_password/:reset_code', :action => 'reset'
  end
  
  
  # Restful Authentication Resources
  map.resources :connections, :collection => {:request_membership => [:get, :post]}
  map.resources :users
  map.resources :tasks do |task|
    task.resources :comments
  end
  map.resources :activities
  map.resources :passwords
  map.resource :session
  
  # Home Page
  map.root :controller => 'site'

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
