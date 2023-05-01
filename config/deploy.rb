# frozen_string_literal: true

require 'uc3-ssm'

# set vars from ENV
set :deploy_to,        ENV.fetch('DEPLOY_TO', nil)       || '/dmp/apps/dmptool'
set :rails_env,        ENV.fetch('RAILS_ENV', nil)       || 'production'
set :repo_url,         ENV.fetch('REPO_URL', nil)        || 'https://github.com/cdluc3/dmptool.git'
set :branch,           ENV.fetch('BRANCH', nil)          || 'master'

# Gets the current Git tag and revision
set :version_number, `git describe --tags`
# Default environments to skip
set :bundle_without, %w[pgsql thin rollbar development test].join(':')
# We only need to keep 3 releases
set :keep_releases, 2

# Default value for linked_dirs is []
append :linked_dirs,
       '.bundle',
       'log',
       'tmp/pids',
       'tmp/cache',
       'tmp/sockets',
       'public'

# Default value for keep_releases is 5
set :keep_releases, 5

namespace :bundler do
  before :install, 'lock_x86'

  desc 'Add x86_64-linux to Gemfile platforms'
  task :lock_x86 do
    on roles(:app), wait: 1 do
      execute "cd #{release_path} bundle lock --add-platform x86_64-linux"
    end
  end
end

namespace :deploy do
  before :compile_assets, 'deploy:retrieve_credentials'
  before :compile_assets, 'deploy:clobber_assets'

  after :deploy, 'dmptool_assets:copy_ui_assets'
  after :deploy, 'dmptool_assets:copy_robots'

  after :deploy, 'git:version'
  after :deploy, 'cleanup:remove_example_configs'

  desc 'Delete all the old assets prior to precompilation for JS and CSS Bundling'
  task :clobber_assets do
    on release_roles(fetch(:assets_roles)) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, 'assets:clobber'
        end
      end
    end
  end

  desc 'Retrieve encrypted crendtials file from SSM ParameterStore'
  task :retrieve_credentials do
    on roles(:app), wait: 1 do
      ssm = Uc3Ssm::ConfigResolver.new
      credentials_yml_enc = ssm.parameter_for_key('credentials_yml_enc')
      File.write("#{release_path}/config/credentials.yml.enc", credentials_yml_enc.chomp)
    end
  end
end
namespace :git do
  desc 'Add the version file so that we can display the git version in the footer'
  task :version do
    on roles(:app), wait: 1 do
      execute "touch #{release_path}/.version"
      execute "echo '#{fetch :version_number}' >> #{release_path}/.version"
    end
  end
end

namespace :cleanup do
  desc 'Remove all of the example config files'
  task :remove_example_configs do
    on roles(:app), wait: 1 do
      execute "rm -f #{release_path}/config/*.yml.sample"
      execute "rm -f #{release_path}/config/initializers/*.rb.example"
    end
  end
end

namespace :dmptool_assets do
  # POST ASSET COMPILATION
  # ----------------------
  desc "Copy over DMPTool-UI repo's images to the public/dmptool-ui-raw-images dir"
  task :copy_ui_assets do
    on roles(:app), wait: 1 do
      execute "mkdir -p #{release_path}/public/dmptool-ui"
      execute "cp /dmp/install/dmptool/public/dmptool-ui/*.* #{release_path}/public/dmptool-ui"

      # TODO: We can probably remove these lines later on, just need to update our Shib
      #       metadata to use the new URL for the logo
      execute "mkdir -p #{release_path}/public/dmptool-ui-raw-images/"
      execute "cp /dmp/install/dmptool/public/dmptool-ui/*.ico #{release_path}/public/dmptool-ui-raw-images/"
      execute "cp /dmp/install/dmptool/public/dmptool-ui/*.jpg #{release_path}/public/dmptool-ui-raw-images/"
      execute "cp /dmp/install/dmptool/public/dmptool-ui/*.png #{release_path}/public/dmptool-ui-raw-images/"
      execute "cp /dmp/install/dmptool/public/dmptool-ui/*.svg #{release_path}/public/dmptool-ui-raw-images/"
    end
  end

  desc 'Copy over the robots.txt file'
  task :copy_robots do
    on roles(:app), wait: 1 do
      execute "cp -r #{release_path}/config/robots.txt #{release_path}/public/robots.txt"
    end
  end
end
