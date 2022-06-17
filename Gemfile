# frozen_string_literal: true

source 'https://rubygems.org'

ruby '>= 2.7'

# ===========#
# CORE RAILS #
# ===========#

# Full-stack web application framework. (http://rubyonrails.org)
gem 'rails', '~> 6.1'

# TODO: Remove this once Rails addresses the issue with its dependency on mimemagic. Mimemagic had
#       an MIT license but was using some incompatible GPL license code.
#       Versions of mimemagic that were yanked: https://rubygems.org/gems/mimemagic/versions
#       Analysis of the issue: https://www.theregister.com/2021/03/25/ruby_rails_code/
gem 'mimemagic'

# Use sqlite3 as the database for Active Record
# gem 'sqlite3', '~> 1.4'

# Use Puma as the app server
gem 'puma', group: :puma, require: false

# Use SCSS for stylesheets
# TODO : might need to move to cssbundling-rails
# SEE: https://dev.to/kolide/how-to-migrate-a-rails-6-app-from-sass-rails-to-cssbundling-rails-4l41
gem 'sass-rails'

# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker'

# Turbo gives you the speed of a single-page web application without having to write any JavaScript..
# Read more: https://github.com/hotwired/turbo-rails
#            https://github.com/hotwired/turbo-rails/blob/main/UPGRADING.md
gem 'turbo-rails'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"
# Use Active Model has_secure_password
# gem "bcrypt", "~> 3.1.7"

# Use Active Storage variant
# gem "image_processing", "~> 1.2"

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# GEMS ADDED TO HELP HANDLE RAILS MIGRATION FROM 3.x to 4.2
# THESE GEMS HELP SUPPORT DEPRACATED FUNCTIONALITY AND WILL LOSE SUPPORT IN
# FUTURE VERSIONS WE SHOULD CONSIDER BRINGING THE CODE UP TO DATE INSTEAD

# A set of Rails responders to dry up your application
# (http://github.com/plataformatec/responders)
# gem "responders"

# ============== #
# ERROR HANDLING #
# ============== #

# Rollbar-gem is the SDK for Ruby apps and includes support for apps using
# Rails, Sinatra, Rack, plain Ruby, and other frameworks.
# https://github.com/rollbar/rollbar-gem
gem 'rollbar', group: :rollbar, require: false

# ======== #
# DATABASE #
# ======== #

# A simple, fast Mysql library for Ruby, binding to libmysql
# (http://github.com/brianmario/mysql2)
gem 'mysql2', group: :mysql, require: false

# Pg is the Ruby interface to the {PostgreSQL
# RDBMS}[http://www.postgresql.org/](https://bitbucket.org/ged/ruby-pg)
gem 'pg', group: :pgsql, require: false

# Bit fields for ActiveRecord (https://github.com/pboling/flag_shih_tzu)
gem 'flag_shih_tzu' # , "~> 0.3.23"

# ======== #
# SECURITY #
# ======== #

# Flexible authentication solution for Rails with Warden
# (https://github.com/plataformatec/devise)
gem 'devise'

# An invitation strategy for Devise (https://github.com/scambra/devise_invitable)
gem 'devise_invitable'

# A generalized Rack framework for multiple-provider authentication.
# (https://github.com/omniauth/omniauth)
gem 'omniauth'

# OmniAuth Shibboleth strategies for OmniAuth 1.x
# https://github.com/toyokazu/omniauth-shibboleth
gem 'omniauth-shibboleth'

# ORCID OAuth 2.0 Strategy for OmniAuth 1.0
# (https://github.com/datacite/omniauth-orcid)
gem 'omniauth-orcid'

# This gem provides a mitigation against CVE-2015-9284 (Cross-Site Request
# Forgery on the request phase when using OmniAuth gem with a Ruby on Rails
# application) by implementing a CSRF token verifier that directly uses
# ActionController::RequestForgeryProtection code from Rails.
#   https://nvd.nist.gov/vuln/detail/CVE-2015-9284
gem 'omniauth-rails_csrf_protection'

# A ruby implementation of the RFC 7519 OAuth JSON Web Token (JWT) standard.
gem 'jwt'

# Gems for repository integration
# OO authorization for Rails (https://github.com/elabs/pundit)
gem 'pundit'

# ========== #
# UI / VIEWS #
# ========== #

# Ruby gem to handle settings for ActiveRecord instances by storing them as
# serialized Hash in a separate database table. Namespaces and defaults
# included. (https://github.com/ledermann/rails-settings)
gem 'ledermann-rails-settings'

# Gem providing simple Contact Us functionality with a Rails 3+ Engine.
# (https://github.com/jdutil/contact_us)
gem 'contact_us' # COULD BE EASILY REPLACED WITH OUR OWN CODE

# Helpers for the reCAPTCHA API (http://github.com/ambethia/recaptcha)
gem 'recaptcha'

# Ideal gem for handling attachments in Rails, Sinatra and Rack applications.
# (http://github.com/markevans/dragonfly)
gem 'dragonfly'

group :aws do
  # Amazon AWS S3 data store for use with the Dragonfly gem.
  gem 'dragonfly-s3_data_store'
end

# ========== #
# PAGINATION #
# ========== #

# A pagination engine plugin for Rails 4+ and other modern frameworks
# (https://github.com/kaminari/kaminari)
gem 'kaminari'

# Paginate in your headers, not in your response body. This follows the
# proposed RFC-8288 standard for Web linking.
# https://github.com/davidcelis/api-pagination
gem 'api-pagination'

# =========== #
# STYLESHEETS #
# =========== #

# Integrate SassC-Ruby into Rails. (https://github.com/sass/sassc-rails)
gem 'sassc-rails'

# Font-Awesome SASS (https://github.com/FortAwesome/font-awesome-sass)
gem 'font-awesome-sass', '~> 5'

# Use webpack to manage app-like JavaScript modules in Rails
# (https://github.com/rails/webpacker)
# gem "webpacker"

# Parse CSS and add vendor prefixes to CSS rules using values from the Can
# I Use website. (https://github.com/ai/autoprefixer-rails)
gem 'autoprefixer-rails'

# Minimal embedded v8 for Ruby (https://github.com/discourse/mini_racer)
# gem "mini_racer"

# ========= #
# EXPORTING #
# ========= #

# Provides binaries for WKHTMLTOPDF project in an easily accessible package.
gem 'wkhtmltopdf-binary'

# PDF generator (from HTML) gem for Ruby on Rails
# (https://github.com/mileszs/wicked_pdf)
gem 'wicked_pdf'

# This simple gem allows you to create MS Word docx documents from simple
# html documents. This makes it easy to create dynamic reports and forms
# that can be downloaded by your users as simple MS Word docx files.
# (http://github.com/karnov/htmltoword)
gem 'htmltoword'

# ==================== #
# INTERNATIONALIZATION #
# ==================== #

gem 'translation'

# ========= #
# UTILITIES #
# ========= #

# Run any code in parallel Processes(> use all CPUs) or Threads(> speedup
# blocking operations). Best suited for map-reduce or e.g. parallel downloads/uploads.
# TODO: Replace use of this with ActiveJob where possible
gem 'parallel'

# Makes http fun again! Wrapper to simplify the native Net::HTTP libraries
gem 'httparty'

# Autoload dotenv in Rails. (https://github.com/bkeepers/dotenv)
gem 'dotenv-rails'

gem 'activerecord_json_validator'

# ================================= #
# ENVIRONMENT SPECIFIC DEPENDENCIES #
# ================================= #

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
end

group :test do
  # RSpec for Rails (https://github.com/rspec/rspec-rails)
  gem 'rspec-rails'

  # factory_bot_rails provides integration between factory_bot and rails 3
  # or newer (http://github.com/thoughtbot/factory_bot_rails)
  gem 'factory_bot_rails'

  # Easily generate fake data (https://github.com/stympy/faker)
  gem 'faker'

  # the instafailing RSpec progress bar formatter
  # (https://github.com/thekompanee/fuubar)
  gem 'fuubar'

  # Guard keeps an eye on your file modifications (https://github.com/guard/guard)
  gem 'guard'

  # Guard gem for RSpec (https://github.com/guard/guard-rspec)
  # gem 'guard-rspec'

  # Library for stubbing HTTP requests in Ruby.
  # (http://github.com/bblimke/webmock)
  gem 'webmock'

  # Code coverage for Ruby 1.9+ with a powerful configuration library and
  # automatic merging of coverage across test suites
  # (http://github.com/colszowka/simplecov)
  # gem 'simplecov', require: false

  # Strategies for cleaning databases.  Can be used to ensure a clean state
  # for testing. (http://github.com/DatabaseCleaner/database_cleaner)
  gem 'database_cleaner', require: false

  # Making tests easy on the fingers and eyes
  # (https://github.com/thoughtbot/shoulda)
  gem 'shoulda', require: false

  # Mocking and stubbing library (http://gofreerange.com/mocha/docs)
  gem 'mocha', require: false

  # Adds support for Capybara system testing and selenium driver
  gem 'capybara'
  gem 'selenium-webdriver'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'

  # Automatically create snapshots when Cucumber steps fail with Capybara
  # and Rails (http://github.com/mattheworiordan/capybara-screenshot)
  # gem 'capybara-screenshot'

  # Browser integration tests are expensive. We can mock external requests
  # in our tests, but once a browser is involved, we lose control.
  gem 'capybara-webmock'

  # RSpec::CollectionMatchers lets you express expected outcomes on
  # collections of an object in an example.
  gem 'rspec-collection_matchers'

  # A set of RSpec matchers for testing Pundit authorisation policies.
  gem 'pundit-matchers'

  # This gem brings back assigns to your controller tests as well as assert_template
  # to both controller and integration tests.
  gem 'rails-controller-testing'
end

group :ci, :development do
  # Security vulnerability scanner for Ruby on Rails.
  # (http://brakemanscanner.org)
  gem 'brakeman'

  # Helper gem to require bundler-audit
  # (http://github.com/stewartmckee/bundle-audit)
  gem 'bundle-audit'

  # RuboCop is a Ruby code style checking and code formatting tool. It aims to enforce
  # the community-driven Ruby Style Guide.
  gem 'rubocop'

  # RuboCop rules for detecting and autocorrecting undecorated strings for i18n
  # (gettext and rails-i18n)
  gem 'rubocop-i18n'

  # A collection of RuboCop cops to check for performance optimizations in Ruby code.
  # gem 'rubocop-performance'

  # Automatic Rails code style checking tool. A RuboCop extension focused on enforcing
  # Rails best practices and coding conventions.
  # gem 'rubocop-rails'

  # A RuboCop plugin for Rake tasks
  # gem 'rubocop-rake'

  # Code style checking for RSpec files. A plugin for the RuboCop code style enforcing
  # & linting tool.
  # gem 'rubocop-rspec'

  # Thread-safety checks via static analysis. A plugin for the RuboCop code style
  # enforcing & linting tool.
  # gem 'rubocop-thread_safety'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'listen'
  gem 'web-console'
  # Spring speeds up development by keeping your application running in the background.
  # Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen'

  # Simple Progress Bar for output to a terminal
  # (http://github.com/paul/progress_bar)
  gem 'progress_bar', require: false

  # A collection of text algorithms (http://github.com/threedaymonk/text)
  gem 'text', require: false

  # Better error page for Rails and other Rack apps
  # (https://github.com/charliesome/better_errors)
  gem 'better_errors'

  # Retrieve the binding of a method's caller. Can also retrieve bindings
  # even further up the stack. (http://github.com/banister/binding_of_caller)
  gem 'binding_of_caller'

  # rspec command for spring
  # (https://github.com/jonleighton/spring-commands-rspec)
  gem 'spring-commands-rspec'

  # Profiles loading speed for rack applications. (http://miniprofiler.com)
  gem 'rack-mini-profiler'

  # Annotates Rails Models, routes, fixtures, and others based on the
  # database schema. (http://github.com/ctran/annotate_models)
  gem 'annotate'

  # Add comments to your Gemfile with each dependency's description.
  # (https://github.com/ivantsepp/annotate_gem)
  gem 'annotate_gem'

  # help to kill N+1 queries and unused eager loading.
  # (https://github.com/flyerhzm/bullet)
  gem 'bullet'

  # Documentation tool for consistent and usable documentation in Ruby.
  # (http://yardoc.org)
  gem 'yard'

  # TomDoc for YARD (http://rubyworks.github.com/yard-tomdoc)
  gem 'yard-tomdoc'
end
