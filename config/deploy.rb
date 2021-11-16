# frozen_string_literal: true

require 'uc3-ssm'

# set vars from ENV
set :deploy_to,        ENV['DEPLOY_TO']       || '/dmp/apps/dmptool'
set :rails_env,        ENV['RAILS_ENV']       || 'production'
set :repo_url,         ENV['REPO_URL']        || 'https://github.com/cdluc3/dmptool.git'
set :branch,           ENV['BRANCH']          || 'master'

# set vars for the dmptool-ui GitHub repository
set :dmptool_ui_branch,       'rails-fixes'
set :dmptool_ui_path,         '/dmp/install/dmptool-ui'
set :dmptool_ui_assets_path,  '/dmp/install/dmptool-ui/dist/ui-assets/'

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
  before :compile_assets, 'dmptool_assets:build_ui_assets'

  after :deploy, 'dmptool_assets:copy_ui_assets'
  after :deploy, 'dmptool_assets:copy_tinymce_skins'

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
  # PRE ASSET COMPILATION
  # ---------------------
  desc "Build the DMPTool-UI assets and move the fonts to the app/assets dir for Rails"
  task :build_ui_assets do
    on roles(:app), wait: 1 do
      # Clone the dmptool-ui repo if it does not exist
      unless Dir.exist?("#{fetch :dmptool_ui_path}")
        execute "cd /dmp/install && git clone https://github.com/cdlib/dmptool-ui.git"
      end

      # Pull down the latest for the specified branch
      execute "cd #{fetch :dmptool_ui_path} && git pull origin #{fetch :dmptool_ui_branch}"

      # If the Fontawesome auth key is not present, fetch it from SSM
      unless File.exist?("#{fetch :dmptool_ui_path}/.npmrc")
        ssm = Uc3Ssm::ConfigResolver.new
        fontawesome_key = ssm.parameter_for_key('fontawesome_key')
        file_contents = '@fortawesome:registry=https://npm.fontawesome.com/'
        file_contents += "\n//npm.fontawesome.com/:_authToken=#{fontawesome_key}"
        File.write("#{fetch :dmptool_ui_path}/.npmrc", file_contents)
      end

      # Now run install, build the assets and move the fonts to the Rails assets dir
      execute "cd #{fetch :dmptool_ui_path} && npm install"
      execute "cd #{fetch :dmptool_ui_path} && npm run build"

      execut "cp #{fetch :dmptool_ui_assets_path}*.woff #{release_path}/app/assets/fonts"
      execut "cp #{fetch :dmptool_ui_assets_path}*.woff2 #{release_path}/app/assets/fonts"
    end
  end

  # POST ASSET COMPILATION
  # ----------------------
  desc "Copy over DMPTool-UI repo's images to the public/dmptool-ui-raw-images dir"
  task :copy_ui_assets do
    on roles(:app), wait: 1 do
      execute "cp #{fetch :dmptool_ui_assets_path}*.* #{release_path}/public"

      # TODO: We can probably remove these lines later on, just need to update our Shib
      #       metadata to use the new URL for the logo
      execute "mkdir -p #{release_path}/public/dmptool-ui-raw-images/"
      execute "cp #{fetch :dmptool_ui_assets_path}*.ico #{release_path}/public/dmptool-ui-raw-images/"
      execute "cp #{fetch :dmptool_ui_assets_path}*.jpg #{release_path}/public/dmptool-ui-raw-images/"
      execute "cp #{fetch :dmptool_ui_assets_path}*.png #{release_path}/public/dmptool-ui-raw-images/"
      execute "cp #{fetch :dmptool_ui_assets_path}*.svg #{release_path}/public/dmptool-ui-raw-images/"
    end
  end

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
end
