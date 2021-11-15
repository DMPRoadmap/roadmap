# frozen_string_literal: true

require 'uc3-ssm'

# set vars for DMPTool-UI submodule https://github.com/cdlib/dmptool-ui
set :scm,              :git
set :git_strategy,     Capistrano::Git::SubmoduleStrategy
set :default_env,      { path: '$PATH' }

# set vars from ENV
set :deploy_to,        ENV['DEPLOY_TO']       || '/dmp/apps/dmptool'
set :rails_env,        ENV['RAILS_ENV']       || 'production'
set :repo_url,         ENV['REPO_URL']        || 'https://github.com/cdluc3/dmptool.git'
set :branch,           ENV['BRANCH']          || 'master'

# Gets the current Git tag and revision
set :version_number, `git describe --tags`
# Default environments to skip
set :bundle_without, %w[pgsql thin rollbar test].join(' ')

# Default value for linked_dirs is []
append :linked_dirs,
       'log',
       'tmp/pids',
       'tmp/cache',
       'tmp/sockets',
       'public'

# Default value for keep_releases is 5
set :keep_releases, 5

namespace :deploy do
  before :compile_assets, 'deploy:retrieve_credentials'
  before :compile_assets, 'deploy:build_ui_assets'

  after :deploy, 'hackery:copy_tinymce_skins'
  after :deploy, 'hackery:copy_ui_assets'
  after :deploy, 'git:version'
  after :deploy, 'cleanup:remove_example_configs'

  desc 'Retrieve encrypted crendtials file from SSM ParameterStore'
  task :retrieve_credentials do
    on roles(:app), wait: 1 do
      ssm = Uc3Ssm::ConfigResolver.new
      credentials_yml_enc = ssm.parameter_for_key('credentials_yml_enc')
      File.write("#{release_path}/config/credentials.yml.enc", credentials_yml_enc.chomp)
    end
  end

  # rubocop:disable Layout/LineLength
  desc 'Build the DMPTool-UI repo submodule and copy assets to app/assets pre-compile'
  task :build_ui_assets do
    on roles(:app), wait: 1 do
      execute "cd #{release_path}/dmptool-ui && npm install && npm run build"
      execute "cp #{release_path}/dmptool-ui/dist/ui-assets/application.css #{release_path}/app/assets/stylesheets/vendor/dmptool-ui.css"
      execute "cp #{release_path}/dmptool-ui/dist/ui-assets/application.js #{release_path}/app/javascript/vendor/dmptoolUi.js"
      execute "cp #{release_path}/dmptool-ui/dist/ui-assets/*.wof* #{release_path}/app/assets/fonts"
    end
  end
  # rubocop:enable Layout/LineLength
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

namespace :hackery do
  # Webpacker and TinyMCE do not play nicely with one another. Webpacker/Rails stores its copiled CSS and JS
  # in minified application.[ext] files that are fingerprinted but TinyMCE expects them elsewhere
  desc 'Move TinyMCE skin files to public dir'
  task :copy_tinymce_skins do
    on roles(:app), wait: 1 do
      execute "mkdir -p #{release_path}/public/tinymce/skins/"
      execute "cp -r #{release_path}/node_modules/tinymce/skins/lightgray/ #{release_path}/public/tinymce/skins/"
      execute "cp #{release_path}/app/assets/stylesheets/tinymce.css #{release_path}/public/tinymce/tinymce.css"
    end
  end

  desc "Build the DMPTool-UI assets and move the fonts to the app/assets dir for Rails"
  task :build_ui_assets do
    on roles(:app), wait: 1 do
      dmptool_ui_path = Rails.root.join('dmptool-ui')
      assets_path = Rails.root.join('dmptool-ui', 'dist', 'ui-assets', '*.*')
      execute "cd #{install_path}/dmptool-ui/ && git pull origin main && npm install && npm run build"
      execut "cd #{install_path}/ cp dmptool-ui/dist/ui-assets/*.woff #{release_path}/app/assets/fonts"
      execut "cd #{install_path}/ cp dmptool-ui/dist/ui-assets/*.woff2 #{release_path}/app/assets/fonts"
    end
  end

  desc "Copy over DMPTool-UI repo's images to the public/dmptool-ui-raw-images dir"
  task :copy_ui_assets do
    on roles(:app), wait: 1 do
      execute "cp dmptool-ui/dist/ui-assets #{release_path}/public"

      # TODO: We can probably remove these lines later on, just need to update our Shib
      #       metadata to use the new URL for the logo
      execute "mkdir -p #{release_path}/public/dmptool-ui-raw-images/"
      execute "cp #{release_path}/dmptool-ui/dist/ui-assets/*.ico #{release_path}/public/dmptool-ui-raw-images/"
      execute "cp #{release_path}/dmptool-ui/dist/ui-assets/*.jpg #{release_path}/public/dmptool-ui-raw-images/"
      execute "cp #{release_path}/dmptool-ui/dist/ui-assets/*.png #{release_path}/public/dmptool-ui-raw-images/"
      execute "cp #{release_path}/dmptool-ui/dist/ui-assets/*.svg #{release_path}/public/dmptool-ui-raw-images/"
    end
  end
end
