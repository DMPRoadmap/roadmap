set :application, 'DMPTool'
set :repo_url, 'https://github.com/CDLUC3/dmptool.git'

set :server_host, ENV["SERVER_HOST"] || 'uc3-dmpx2-prd-2a.cdlib.org'
server fetch(:server_host), user: 'dmp', roles: %w{web app db}

set :deploy_to, '/dmp/apps/dmp'
set :share_to, 'dmp/apps/dmp/shared'

# Define the location of the private configuration repo
set :config_branch, 'uc3-dmpx2-prd'

set :rails_env, 'production'
