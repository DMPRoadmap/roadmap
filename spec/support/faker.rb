# frozen_string_literal: true

require 'faker'

RSpec.configure do |config|
  config.before(:each) do
    I18n.locale = I18n.default_locale
    Faker::Config.locale = I18n.default_locale
  end

  config.after(:each) do
    Faker::Name.unique.clear
    Faker::UniqueGenerator.clear
  end
end
