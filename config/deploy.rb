require 'capistrano/passenger'

namespace :deploy
  desc 'Start Phusion Passenger'
  task :start do
    # Start Passenger
  end
  
  desc 'Stop Phusion Passenger'
  task :stop do
    # Stop Passenger
  end
  
  desc 'Restart Phusion Passenger'
  task :restart do
#    on roles(fetch(:passenger_roles)), 
#             in: fetch(:passenger_restart_runner), 
#             limit: fetch(:passenger_restart_limit), 
#             wait: fetch(:passenger_restart_wait) do
#      with fetch(:passenger_environment_variables) do
        # Restart Passenger
#      end
#    end
  end
end