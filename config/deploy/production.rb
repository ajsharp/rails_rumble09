#############################################################
#	Application
#############################################################

set :application, "passthemonkey"
set :deploy_to, "/var/www/apps/#{application}"

#############################################################
#	Settings
#############################################################

default_run_options[:pty] = true
ssh_options[:forward_agent] = true
set :use_sudo, true
set :scm_verbose, true
set :rails_env, "production" 

#############################################################
#	Servers
#############################################################

set :user, "travisr"
set :domain, "passthemonkey.r09.railsrumble.com"
role :web, domain
role :app, domain
role :db,  domain, :primary => true
role :scm, domain
set :runner, user
set :admin_runner, user

#############################################################
#	Git
#############################################################

set :scm, :git
set :branch, "master"
set :repository, "git@github.com:railsrumble/rr09-team-220.git"
set :deploy_via, :remote_cache

#############################################################
#	Passenger
#############################################################

set :app_server, :passenger

namespace :deploy do
  desc "Symlink the database yaml file"
  task :symlink_db do
    run "ln -nfs #{shared_path}/system/database.yml #{release_path}/config/database.yml"
  end
    
  # Restart passenger on deploy
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end
  
  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end
  
end

after 'deploy:update_code', 'deploy:symlink_db'
