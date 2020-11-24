# frozen_string_literal: true

# Default branch is :master
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp unless ENV["BRANCH"]
set :branch, ENV["BRANCH"] if ENV["BRANCH"]

set :default_env, { path: "/dmp/local/bin:$PATH" }

# Gets the current Git tag and revision
set :version_number, `git describe --tags`

# Default environments to skip
set :bundle_without, %w[puma pgsql thin rollbar test].join(" ")

# Define the location of the private configuration repo
set :config_repo, "git@github.com:cdlib/dmptool_config.git"

# Default value for :linked_files is []
append :linked_files, 'config/credentials.yml.enc',
                      'config/database.yml',
                      'config/master.key',
                      'config/initializers/_dmproadmap.rb',
                      'config/initializers/dmptool_version.rb',
                      'config/initializers/dragonfly.rb',
                      'config/initializers/wicked_pdf.rb',
                      'config/initializers/external_apis/open_aire.rb',
                      'config/initializers/external_apis/dmphub.rb',
                      'public/tinymce/tinymce.css'

# Default value for linked_dirs is []
append :linked_dirs,
       "log",
       "tmp/pids",
       "tmp/cache",
       "tmp/sockets",
       "public"

# Default value for keep_releases is 5
set :keep_releases, 5

namespace :deploy do
  before :deploy, "config:install_shared_dir"
  after :deploy, "git:version"
  after :deploy, "cleanup:remove_example_configs"
  after :deploy, "cleanup:restart_passenger"
end

# rubocop:disable Layout/LineLength
namespace :config do
  desc "Setup up the config repo as the shared directory"
  task :install_shared_dir do
    on roles(:app), wait: 1 do
      execute "if [ ! -d '#{deploy_path}/shared/' ]; then cd #{deploy_path}/ && git clone #{fetch :config_repo} shared; fi"
      execute "cd #{deploy_path}/shared/ && git checkout #{fetch :config_branch} && git pull origin #{fetch :config_branch}"
    end
  end
end
# rubocop:enable Layout/LineLength

namespace :git do
  desc "Add the version file so that we can display the git version in the footer"
  task :version do
    on roles(:app), wait: 1 do
      execute "touch #{release_path}/.version"
      execute "echo '#{fetch :version_number}' >> #{release_path}/.version"
    end
  end
end

namespace :cleanup do
  desc "Remove all of the example config files"
  task :remove_example_configs do
    on roles(:app), wait: 1 do
      execute "rm -f #{release_path}/config/*.yml.sample"
      execute "rm -f #{release_path}/config/initializers/*.rb.example"
    end
  end

  desc "Restart Phusion Passenger"
  task :restart_passenger do
    on roles(:app), wait: 5 do
      execute "cd /apps/dmp/init.d && ./passenger stop"
      execute "cd /apps/dmp/init.d && ./passenger start"
    end
  end

  after :restart_passenger, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
    end
  end
end
