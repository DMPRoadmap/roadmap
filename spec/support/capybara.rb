# frozen_string_literal: true

require_relative "helpers/capybara_helper"
require_relative "helpers/sessions_helper"
require_relative "helpers/tiny_mce_helper"

SCREEN_SIZE = [2400, 1350]
DIMENSION   = Selenium::WebDriver::Dimension.new(*SCREEN_SIZE)

Capybara.default_driver = :rack_test

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
end
