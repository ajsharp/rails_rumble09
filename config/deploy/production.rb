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

set :user, "troberts"
set :domain, "passthemonkey.r09.railsrumble.com"
server domain, :app, :web
role :db, domain, :primary => true

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
