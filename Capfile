# Load DSL and set up stages
require "capistrano/setup"

# Include default deployment tasks
require "capistrano/deploy"

# Load the SCM plugin appropriate to your project:
require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git

require 'capistrano/bundler'

# TODO: Uncomment this for deployments to dmp-dev or roadmap-stg and permenantly once we have
#       merged the latest changes into dmptool stage and prod
require "capistrano/rails/assets"

require 'capistrano/rails/migrations'

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }
