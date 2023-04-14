# frozen_string_literal: true

require 'faker'

# Keep this as :en. Faker doesn't have :en-GB
LOCALE = 'en-US'

Faker::Config.locale = LOCALE

RSpec.configure do |config|
  config.before do

puts "FAKER CONFIG BEFORE"

    I18n.locale = LOCALE
    I18n.default_locale = LOCALE
  end

  config.after do

puts "FAKER CONFIG AFTER"

    Faker::Name.unique.clear
    Faker::UniqueGenerator.clear
  end
end
