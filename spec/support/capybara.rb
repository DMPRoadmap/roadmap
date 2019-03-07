# frozen_string_literal: true

require_relative "helpers/capybara_helper"
require_relative "helpers/sessions_helper"
require_relative "helpers/tiny_mce_helper"
require_relative "helpers/combobox_helper"

SCREEN_SIZE = [2400, 1350]
DIMENSION   = Selenium::WebDriver::Dimension.new(*SCREEN_SIZE)

Capybara.default_driver = :rack_test

# This is a customisation of the default :selenium_chrome_headless config in:
# https://github.com/teamcapybara/capybara/blob/master/lib/capybara.rb
#
# This adds the --no-sandbox flag to fix TravisCI as described here:
# https://docs.travis-ci.com/user/chrome#sandboxing
Capybara.register_driver :selenium_chrome_headless do |app|
  Capybara::Selenium::Driver.load_selenium
  browser_options = ::Selenium::WebDriver::Chrome::Options.new
  browser_options.args << '--headless'
  browser_options.args << '--no-sandbox'
  browser_options.args << '--disable-gpu' if Gem.win_platform?
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options)
end

RSpec.configure do |config|

  config.before(:each, type: :feature, js: false) do
    Capybara.use_default_driver
  end

  config.before(:each, type: :feature, js: true) do
    Capybara.current_driver = :selenium_chrome_headless
    Capybara.page.driver.browser.manage.window.size = DIMENSION
  end

end

Capybara.configure do |config|
  config.default_max_wait_time = 5 # seconds
  config.server                = :webrick
  config.raise_server_errors   = true
end

RSpec.configure do |config|
  config.include(CapybaraHelper, type: :feature)
  config.include(SessionsHelper, type: :feature)
  config.include(TinyMceHelper,  type: :feature)
  config.include(ComboboxHelper, type: :feature)
end
