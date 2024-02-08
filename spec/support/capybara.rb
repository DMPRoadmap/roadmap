# frozen_string_literal: true

# Use Puma as the webserver for feature tests
Capybara.server = :puma, { Silent: true }

# Use the fast rack_test driver for non-feature tests by default
Capybara.default_driver = :rack_test

# Create a custom driver based on Capybara's :selenium_chrome_headless driver
# This resolves a ElementClickInterceptedError when executing `click_button 'Sign in'` with DMP Assistant
Capybara.register_driver :selenium_chrome_headless_add_window_size do |app|
  # Get a copy of the default options for Capybara's :selenium_chrome_headless driver
  options = Capybara.drivers[:selenium_chrome_headless].call.options[:options].dup
  options.add_argument('--window-size=1920,1080') # default window-size is only (800x600)
  # Create a new Selenium driver with the customised options
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

RSpec.configure do |config|
  config.before(:each, type: :feature, js: false) do
    Capybara.use_default_driver
  end

  # Use the Selenium headless Chrome driver for feature tests
  config.before(:each, type: :feature, js: true) do
    Capybara.current_driver = :selenium_chrome_headless_add_window_size
  end
end
