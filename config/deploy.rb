set :application, 'dmptool'
set :repo_url, 'https://github.com/CDLUC3/roadmap.git'

#set :user, 'dmp'

# Default branch is :master
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp unless ENV['BRANCH']
set :branch, ENV['BRANCH'] if ENV['BRANCH']

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/dmp/apps/roadmap'
set :share_to, 'dmp/apps/roadmap/shared'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: 'log/capistrano.log', color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
append :linked_files, 'config/database.yml', 'config/secrets.yml'

# Default value for linked_dirs is []
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system'

# Default value for default_env is {}
set :default_env, { path: "/dmp/local/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 5

# passenger in gemfile set since we have both passenger and capistrano-passenger in gemfile
set :passenger_in_gemfile, true

# Set whether to restart with touch of touch of tmp/restart.txt.
# There may be difficulties one way or another.  Normal restart may require sudo in some circumstances.
set :passenger_restart_with_touch, false

namespace :deploy do

  desc 'Restart Phusion'
  task :restart do
    on roles(:app), wait: 5 do
      # Your restart mechanism here, for example:
      invoke 'deploy:stop'
      invoke 'deploy:start'
    end
  end
  
  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end
  
  desc 'Start Phusion'
  task :start do
    on roles(:app) do
      within current_path do
        with rails_env: fetch(:rails_env) do
          execute "cd #{deploy_to}/current; bundle install --no-deployment"
          execute "cd #{deploy_to}/current; bundle exec passenger start -d --environment #{fetch(:rails_env)} --pid-file #{fetch(:passenger_pid)} -p #{fetch(:passenger_port)} --log-file #{fetch(:passenger_log)}"
        end
      end
    end
  end
  
  desc 'Stop Phusion'
  task :stop do
    on roles(:app) do
      if test("[ -f #{fetch(:passenger_pid)} ]")
        execute "cd #{deploy_to}/current; bundle exec passenger stop --pid-file #{fetch(:passenger_pid)}"
      end
    end
  end

=begin  
  Rake::Task["cleanup"].clear_actions
  desc "Clean up old releases"
  task :cleanup do
    on release_roles :all do |host|
      releases = capture(:ls, "-xtr", releases_path).split.keep_if{|i| i.match(/^[0-9]+$/) }
      if releases.count >= fetch(:keep_releases)
        info t(:keeping_releases, host: host.to_s, keep_releases: fetch(:keep_releases), releases: releases.count)
        directories = (releases - releases.last(fetch(:keep_releases)))
        if directories.any?
          directories_str = directories.map do |release|
            releases_path.join(release)
          end.join(" ")
          execute :rm, "-rf", directories_str
        else
          info t(:no_old_releases, host: host.to_s, keep_releases: fetch(:keep_releases))
        end
      end
    end
  end
=end
  
end