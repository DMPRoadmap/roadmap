require 'fileutils'
namespace :assets do

  # Clear out Rails's assets precompile task
  Rake::Task["assets:precompile"].clear

  desc "Pre-compile assets for production. Overwrite the Rails assets:precompile"
  task :precompile do
    FileUtils.cd("lib/assets") do
      system("npm install")
      system("npm run bundle --no-watch -- -p")
    end
  end
end
