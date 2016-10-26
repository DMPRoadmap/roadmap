namespace :migrate do
  desc "TODO"
  task permissions: :environment do
    User.update_user_permissions
  end

end
