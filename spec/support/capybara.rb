# frozen_string_literal: true

# Use Puma as the webserver for feature tests
Capybara.server = :puma, { Silent: true }

# Use the fast rack_test driver for non-feature tests by default
Capybara.default_driver = :rack_test

RSpec.configure do |config|
  config.before(:each, type: :feature, js: false) do
    Capybara.use_default_driver
  end

  # Use the Selenium headless Chrome driver for feature tests
  config.before(:each, type: :feature, js: true) do
    Capybara.current_driver = :selenium_chrome_headless
  end
end
