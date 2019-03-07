require 'faker'

# Keep this as :en. Faker doesn't have :en-GB
LOCALE = 'en'

RSpec.configure do |config|
  config.before(:each) do
    I18n.locale = LocaleFormatter.new(LOCALE, format: :i18n).to_s
    Faker::Config.locale = LocaleFormatter.new(LOCALE, format: :i18n).to_s
    FastGettext.default_locale = LocaleFormatter.new(LOCALE, format: :fast_gettext).to_s
  end

  config.after(:each) do
    Faker::Name.unique.clear
    Faker::UniqueGenerator.clear
  end
end
