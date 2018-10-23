source 'https://rubygems.org'

ruby '>= 2.4.0'

# ------------------------------------------------
# RAILS
# Full-stack web application framework. (http://www.rubyonrails.org)
gem 'rails', '~> 4.2.10'

# Tools for creating, working with, and running Rails applications. (http://www.rubyonrails.org)
gem 'railties'

# GEMS ADDED TO HELP HANDLE RAILS MIGRATION FROM 3.x to 4.2
# THESE GEMS HELP SUPPORT DEPRACATED FUNCTIONALITY AND WILL LOSE SUPPORT IN
# FUTURE VERSIONS WE SHOULD CONSIDER BRINGING THE CODE UP TO DATE INSTEAD

# A set of Rails responders to dry up your application (http://github.com/plataformatec/responders)
gem 'responders', '~> 2.0'

# ------------------------------------------------
#    DATABASE/SERVER

group :mysql do
  # A simple, fast Mysql library for Ruby, binding to libmysql (http://github.com/brianmario/mysql2)
  gem 'mysql2', '~> 0.4.10'
end

group :pgsql do
  # Pg is the Ruby interface to the {PostgreSQL
  # RDBMS}[http://www.postgresql.org/](https://bitbucket.org/ged/ruby-pg)
  gem 'pg', '~> 0.19.0'
end

group :thin do
  # A thin and fast web server (http://code.macournoyer.com/thin/)
  gem 'thin'
end

group :puma do
  # Puma is a simple, fast, threaded, and highly concurrent HTTP 1.1 server for Ruby/Rack applications (http://puma.io)
  gem 'puma', group: :puma
end

# Bit fields for ActiveRecord (https://github.com/pboling/flag_shih_tzu)
gem 'flag_shih_tzu'  # Allows for bitfields in activereccord

# ------------------------------------------------
#    JSON DSL - USED BY API
# Create JSON structures via a Builder-style DSL (https://github.com/rails/jbuilder)
gem 'jbuilder', '~> 2.6.0'

# ------------------------------------------------
#    USERS
# devise for user authentication
# Flexible authentication solution for Rails with Warden (https://github.com/plataformatec/devise)
gem 'devise'

# An invitation strategy for Devise (https://github.com/scambra/devise_invitable)
gem 'devise_invitable'

# A generalized Rack framework for multiple-provider authentication. (https://github.com/omniauth/omniauth)
gem 'omniauth'

# OmniAuth Shibboleth strategies for OmniAuth 1.x
gem 'omniauth-shibboleth'

# ORCID OAuth 2.0 Strategy for OmniAuth 1.0 (https://github.com/datacite/omniauth-orcid)
gem 'omniauth-orcid'

# Pure Ruby implementation of Array#dig and Hash#dig for Ruby < 2.3. (https://github.com/Invoca/ruby_dig)
gem 'ruby_dig'  # for omniauth-orcid

# Gems for repository integration
# OO authorization for Rails (https://github.com/elabs/pundit)
gem 'pundit'

# ------------------------------------------------
# SETTINGS FOR TEMPLATES AND PLANS (FONTS, COLUMN LAYOUTS, ETC)

# Ruby gem to handle settings for ActiveRecord instances by storing them as serialized Hash in a separate database table. Namespaces and defaults included. (https://github.com/ledermann/rails-settings)
gem 'ledermann-rails-settings'

# ------------------------------------------------
# VIEWS

# Gem providing simple Contact Us functionality with a Rails 3+ Engine. (https://github.com/jdutil/contact_us)
gem 'contact_us' # COULD BE EASILY REPLACED WITH OUR OWN CODE

# Helpers for the reCAPTCHA API (http://github.com/ambethia/recaptcha)
gem 'recaptcha'

# Ideal gem for handling attachments in Rails, Sinatra and Rack applications. (http://github.com/markevans/dragonfly)
gem 'dragonfly'

# ------------------------------------------------
# EXPORTING
# Provides binaries for WKHTMLTOPDF project in an easily accessible package.
gem 'wkhtmltopdf-binary'

# PDF generator (from HTML) gem for Ruby on Rails (https://github.com/mileszs/wicked_pdf)
gem 'wicked_pdf'

# This simple gem allows you to create MS Word docx documents from simple html documents. This makes it easy to create dynamic reports and forms that can be downloaded by your users as simple MS Word docx files. (http://github.com/karnov/htmltoword)
gem 'htmltoword'

# A feed fetching and parsing library (http://feedjira.com)
gem 'feedjira'

# ------------------------------------------------
# INTERNATIONALIZATION
# Simple FastGettext Rails integration. (http://github.com/grosser/gettext_i18n_rails)
gem 'gettext_i18n_rails'

# Extends gettext_i18n_rails making your .po files available to client side javascript as JSON (https://github.com/webhippie/gettext_i18n_rails_js)
gem 'gettext_i18n_rails_js'

# Gettext is a pure Ruby libary and tools to localize messages. (http://ruby-gettext.github.com/)
gem 'gettext', require: false, group: :development

# ------------------------------------------------
# PAGINATION
# A pagination engine plugin for Rails 4+ and other modern frameworks (https://github.com/kaminari/kaminari)
gem 'kaminari'

# ------------------------------------------------
# ENVIRONMENT SPECIFIC DEPENDENCIES
group :development, :test do
  # Ruby fast debugger - base + CLI (http://github.com/deivid-rodriguez/byebug)
  gem "byebug"

  # RSpec for Rails (https://github.com/rspec/rspec-rails)
  gem "rspec-rails"

  # factory_bot_rails provides integration between factory_bot and rails 3 or newer (http://github.com/thoughtbot/factory_bot_rails)
  # rspec-collection_matchers-1.1.3 (https://github.com/rspec/rspec-collection_matchers)
  gem "rspec-collection_matchers"

  # factory_bot_rails provides integration between factory_bot and rails 3 or newer (http://github.com/thoughtbot/factory_bot_rails)
  gem "factory_bot_rails"

  # Easily generate fake data (https://github.com/stympy/faker)
  gem "faker"

  # the instafailing RSpec progress bar formatter (https://github.com/thekompanee/fuubar)
  gem "fuubar"

  # Guard keeps an eye on your file modifications (http://guardgem.org)
  gem "guard"

  # Guard gem for RSpec (https://github.com/guard/guard-rspec)
  gem "guard-rspec"
end

group :test do
  # Library for stubbing HTTP requests in Ruby. (http://github.com/bblimke/webmock)
  gem 'webmock'

  # Code coverage for Ruby 1.9+ with a powerful configuration library and automatic merging of coverage across test suites (http://github.com/colszowka/simplecov)
  gem 'simplecov', require: false

  # Strategies for cleaning databases.  Can be used to ensure a clean state for testing. (http://github.com/DatabaseCleaner/database_cleaner)
  gem 'database_cleaner', require: false

  # Making tests easy on the fingers and eyes (https://github.com/thoughtbot/shoulda)
  gem "shoulda", require: false

  # Mocking and stubbing library (http://gofreerange.com/mocha/docs)
  gem "mocha", require: false

  # Rails application preloader (https://github.com/rails/spring)
  gem "spring"

  # rspec command for spring (https://github.com/jonleighton/spring-commands-rspec)
  gem "spring-commands-rspec"

  # Capybara aims to simplify the process of integration testing Rack applications, such as Rails, Sinatra or Merb (https://github.com/teamcapybara/capybara)
  gem "capybara"

  # Automatically create snapshots when Cucumber steps fail with Capybara and Rails (http://github.com/mattheworiordan/capybara-screenshot)
  gem "capybara-screenshot"

  # The next generation developer focused tool for automated testing of webapps (https://github.com/SeleniumHQ/selenium)
  gem "selenium-webdriver", "~> 3.14"

  # Easy installation and use of chromedriver. (https://github.com/flavorjones/chromedriver-helper)
  gem "chromedriver-helper", ">= 1.2.0"
end

group :ci, :development do
  # Security vulnerability scanner for Ruby on Rails. (http://brakemanscanner.org)
  gem "brakeman"

  # Automatic Ruby code style checking tool. (https://github.com/rubocop-hq/rubocop)
  # Rubocop style checks for DMP Roadmap projects. (https://github.com/DMPRoadmap/rubocop-DMP_Roadmap)
  gem "rubocop-dmp_roadmap", ">= 1.1.0"

  # Helper gem to require bundler-audit (http://github.com/stewartmckee/bundle-audit)
  gem "bundle-audit"
end

group :development do

  # Simple Progress Bar for output to a terminal (http://github.com/paul/progress_bar)
  gem "progress_bar", require: false

  # A collection of text algorithms (http://github.com/threedaymonk/text)
  gem "text", require: false

  # Better error page for Rails and other Rack apps (https://github.com/charliesome/better_errors)
  gem "better_errors"

  # Retrieve the binding of a method's caller. Can also retrieve bindings even further up the stack. (http://github.com/banister/binding_of_caller)
  gem "binding_of_caller"

  # A debugging tool for your Ruby on Rails applications. (https://github.com/rails/web-console)
  gem 'web-console'

  # Profiles loading speed for rack applications. (http://miniprofiler.com)
  gem 'rack-mini-profiler'

  # Annotates Rails Models, routes, fixtures, and others based on the database schema. (http://github.com/ctran/annotate_models)
  gem "annotate"

  # Add comments to your Gemfile with each dependency's description. (https://github.com/ivantsepp/annotate_gem)
  gem "annotate_gem"

  # help to kill N+1 queries and unused eager loading. (https://github.com/flyerhzm/bullet)
  gem "bullet"

  # Documentation tool for consistent and usable documentation in Ruby. (http://yardoc.org)
  gem "yard"

  # TomDoc for YARD (http://rubyworks.github.com/yard-tomdoc)
  gem "yard-tomdoc"

  gem "dotenv-rails"

end
