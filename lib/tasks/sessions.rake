# frozen_string_literal: true

# Neil created this, designed around http://stackoverflow.com/questions/10088619/how-to-clear-rails-sessions-table
# hint: config/initializers/devise.rb sets "remember_for"
namespace :sessions do
  desc 'Clear expired sessions from the database'
  task cleanup: :environment do
    ActiveRecord::SessionStore::Session.delete_all(['updated_at < ?', Devise.remember_for.ago])
  end
end
