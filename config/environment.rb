# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.3' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Specify gems that this application depends on.
  config.gem "capistrano-ext", :lib => "capistrano"
  config.gem 'rubyist-aasm', :lib => 'aasm', :source => 'http://gems.github.com', :version => '2.0.2'
  config.gem 'mislav-will_paginate', :version => '2.3.6', :lib => 'will_paginate', :source => 'http://gems.github.com'

  # Make Time.zone default to the specified zone, and make Active Record store time values
  # in the database in UTC, and return them converted to the specified local zone.
  config.time_zone = 'UTC'

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random, 
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => '_passthemonkey_session',
    :secret      => 'a3e2a51a371bb964a4250c21f8d083f9ddb224d455171dcba55518e74af43366e52e3f239773f90aed0ab6caf6554f051504ce7232599d066150dbabff0f1654'
  }

  # Activate observers that should always be running
  config.active_record.observers = :user_observer
end
