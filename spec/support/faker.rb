# frozen_string_literal: true

require "faker"

# Keep this as :en. Faker doesn't have :en-GB
LOCALE = "en"

RSpec.configure do |config|
  config.before(:each) do
    I18n.locale = LOCALE
    Faker::Config.locale = LOCALE
    I18n.default_locale = LOCALE
  end

  config.after(:each) do
    Faker::Name.unique.clear
    Faker::UniqueGenerator.clear
  end
end
