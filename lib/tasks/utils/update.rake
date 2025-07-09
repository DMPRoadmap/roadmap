# frozen_string_literal: true

namespace :update do
  desc 'Updates all dependencies'
  task all: :environment do
    Rake::Task['update:gems'].execute
    Rake::Task['update:js'].execute
  end

  desc 'Updates all Gem dependencies'
  task gems: :environment do
    puts 'Updating Gems'
    system('bundle update')
    puts 'Ensuring that the x86_65 platform is enabled for CI'
    system('bundle lock --add-platform x86_64-linux')
  end

  desc 'Updates all JS dependencies'
  task js: :environment do
    puts 'Updating JS'
    system('yarn upgrade')
  end
end
