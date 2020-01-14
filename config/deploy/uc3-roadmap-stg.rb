set :application, 'DMPRoadmap'
set :repo_url, 'https://github.com/DMPRoadmap/roadmap.git'

set :server_host, ENV["SERVER_HOST"] || 'uc3-roadmap-stg.cdlib.org'
server fetch(:server_host), user: 'dmp', roles: %w{web app db}

set :deploy_to, '/dmp/apps/roadmap'
set :share_to, 'dmp/apps/roadmap/shared'

# Define the location of the private configuration repo
set :config_branch, 'uc3-roadmap-stg'

set :rails_env, 'production'

namespace :cleanup do
  desc "Move DMPTool logo into public dir for Shib"
  task :copy_logo do
    on roles(:app), wait: 1 do
      # Forcing the skip of this step since the DMPTool does not exist in Roadmap and
      # we don't need a Shib logo for it
      # execute "if [ ! -d '#{release_path}/public/images/' ]; then cd #{release_path}/ && mkdir public/images && cp app/assets/DMPTool_logo_blue_shades_v1b3b.svg public/images; fi"
    end
  end
end
