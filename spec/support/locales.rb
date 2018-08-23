require 'shoulda/matchers'

RSpec.configure do |config|
  config.before(:each, type: :feature, js: true) do
    Rails.application.config.i18n.available_locales = ['en']
  end
end
