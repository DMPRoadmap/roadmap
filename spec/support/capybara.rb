# frozen_string_literal: true

# Use Puma as the webserver for feature tests
Capybara.server = :puma, { Silent: true }

# Create a custom driver based on Capybara's :selenium_chrome_headless driver
Capybara.register_driver :selenium_chrome_headless_custom do |app|
  # Get a copy of the default options for Capybara's :selenium_chrome_headless driver
  options = Capybara.drivers[:selenium_chrome_headless].call.options[:options].dup
  # Increasing window size resolves ElementClickInterceptedError (default window-size is only (800x600))
  options.add_argument('--window-size=1920,1080')
  # Create a new Selenium driver with the customised options
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

# Use the fast rack_test driver for non-feature tests by default
Capybara.default_driver = :rack_test

Capybara.javascript_driver = :selenium_chrome_headless_custom

# Configure Capybara to wait longer for elements to appear
Capybara.default_max_wait_time = 10

RSpec.configure do |config|
  config.before(:each, type: :feature, js: false) do
    Capybara.use_default_driver
  end

  # Use the Selenium headless Chrome driver for feature tests
  config.before(:each, type: :feature, js: true) do
    Capybara.current_driver = :selenium_chrome_headless_custom
    add_invalid_element_error
  end
end

# Mitigate the following error by having Capybara retry an action when it occurs:
# - Selenium::WebDriver::Error::UnknownError:
# - unknown error: unhandled inspector error:
# - {"code":-32000,"message":"Node with given id does not belong to the document"}
# Source: https://github.com/teamcapybara/capybara/issues/2800#issuecomment-2728801284
def add_invalid_element_error
  return unless page.driver.respond_to?(:invalid_element_errors)

  page.driver.invalid_element_errors.tap do |errors|
    errors << Selenium::WebDriver::Error::UnknownError unless errors.include?(Selenium::WebDriver::Error::UnknownError)
  end
end
