require 'fileutils'
namespace :assets do

  # Clear out Rails's assets precompile task
  Rake::Task["assets:precompile"].clear

  desc "Pre-compile assets for production. Overwrite the Rails assets:precompile"
  task :precompile do
    FileUtils.cd("lib/assets") do
      webpack_options = []
      # Don't watch asset files for further changes
      webpack_options << "--no-watch"
      # Add the production flag, if env is production
      webpack_options << "-p" if ENV["RAILS_ENV"] == "production"
      # Ensure all dependencies are installed
      system("npm install")
      # Run the webpack command via npm
      system("npm run bundle -- #{webpack_options.join(" ")}") or exit()
    end
  end
end
