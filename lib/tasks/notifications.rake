namespace :notifications do
  desc "Create some notifications types"
  task create_types: :environment do
    NotificationType.create(name: 'global')
  end

end
