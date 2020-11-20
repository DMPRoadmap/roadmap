namespace :factory_bot do
  desc "Verify that all FactoryBot factories are valid"
  task lint: :environment do
    if Rails.env.test?
      # DatabaseCleaner.cleaning do
        FactoryBot.lint
      # end
    else
      system("bundle exec rails factory_bot:lint RAILS_ENV='test'")
      exit $?.exitstatus
    end
  end
end
