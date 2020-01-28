source 'https://rubygems.org'

ruby '>= 2.4.0'

# ------------------------------------------------
# RAILS
# Full-stack web application framework. (http://www.rubyonrails.org)
# Full-stack web application framework. (http://rubyonrails.org)
gem 'rails', '~> 4.2.11.1'

# TODO: See if pegging gems is still necessary after migrating to Rails 5
gem 'sprockets', '~> 3.2'

# Rake is a Make-like program implemented in Ruby (https://github.com/ruby/rake)
gem "rake"

# Tools for creating, working with, and running Rails applications. (http://www.rubyonrails.org)
# Tools for creating, working with, and running Rails applications. (http://rubyonrails.org)
gem 'railties'

# GEMS ADDED TO HELP HANDLE RAILS MIGRATION FROM 3.x to 4.2
# THESE GEMS HELP SUPPORT DEPRACATED FUNCTIONALITY AND WILL LOSE SUPPORT IN
# FUTURE VERSIONS WE SHOULD CONSIDER BRINGING THE CODE UP TO DATE INSTEAD

# A set of Rails responders to dry up your application (http://github.com/plataformatec/responders)
gem 'responders', '~> 2.0'

group :rollbar, optional: true do
  gem 'rollbar'
end

# ------------------------------------------------
#    DATABASE/SERVER

group :mysql do
  # A simple, fast Mysql library for Ruby, binding to libmysql (http://github.com/brianmario/mysql2)
  # A simple, fast Mysql library for Ruby, binding to libmysql (https://github.com/brianmario/mysql2)
  gem 'mysql2', '~> 0.4.10'
end

group :pgsql do
  # Pg is the Ruby interface to the {PostgreSQL
  # RDBMS}[http://www.postgresql.org/](https://bitbucket.org/ged/ruby-pg)
  # Pg is the Ruby interface to the {PostgreSQL RDBMS}[http://www.postgresql.org/] (https://bitbucket.org/ged/ruby-pg)
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
gem 'flag_shih_tzu', '~> 0.3.23' # Allows for bitfields in activereccord
# Pinned here because we're using a private method in Role.rb
# if this gets updated, check this method still exists

# ------------------------------------------------
#    JSON DSL - USED BY API
# Create JSON structures via a Builder-style DSL (https://github.com/rails/jbuilder)
gem 'jbuilder', '~> 2.6.0'

# ------------------------------------------------
#    USERS
# devise for user authentication
# Flexible authentication solution for Rails with Warden (https://github.com/plataformatec/devise)
gem 'devise', ">= 4.7.1"

# An invitation strategy for Devise (https://github.com/scambra/devise_invitable)
gem 'devise_invitable'

# A generalized Rack framework for multiple-provider authentication. (https://github.com/omniauth/omniauth)
gem 'omniauth'

# OmniAuth Shibboleth strategies for OmniAuth 1.x
gem 'omniauth-shibboleth'

# ORCID OAuth 2.0 Strategy for OmniAuth 1.0 (https://github.com/datacite/omniauth-orcid)
gem 'omniauth-orcid'

# This gem provides a mitigation against CVE-2015-9284 (Cross-Site Request Forgery on the request phase
# when using OmniAuth gem with a Ruby on Rails application) by implementing a CSRF token verifier that
# directly uses ActionController::RequestForgeryProtection code from Rails.
#   https://nvd.nist.gov/vuln/detail/CVE-2015-9284
gem "omniauth-rails_csrf_protection"

# Pure Ruby implementation of Array#dig and Hash#dig for Ruby < 2.3. (https://github.com/Invoca/ruby_dig)
gem 'ruby_dig'  # for omniauth-orcid

# Gems for repository integration
# OO authorization for Rails (https://github.com/elabs/pundit)
# OO authorization for Rails (https://github.com/varvet/pundit)
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

group :aws, optional: true do

  gem 'dragonfly-s3_data_store'

end


# bootstrap-sass is a Sass-powered version of Bootstrap 3, ready to drop right into your Sass powered applications. (https://github.com/twbs/bootstrap-sass)
gem 'bootstrap-sass', '~> 3.4.1'

# This is required for Font-Awesome, but not used as the main sass compiler

# Sass adapter for the Rails asset pipeline. (https://github.com/rails/sass-rails)
gem "sass-rails", require: false

# Integrate SassC-Ruby into Rails. (https://github.com/sass/sassc-rails)
gem "sassc-rails"

# Font-Awesome SASS (https://github.com/FortAwesome/font-awesome-sass)
gem 'font-awesome-sass', '~> 4.2.0'

# Use webpack to manage app-like JavaScript modules in Rails (https://github.com/rails/webpacker)
gem 'webpacker', '~> 3.5'

# Parse CSS and add vendor prefixes to CSS rules using values from the Can I Use website. (https://github.com/ai/autoprefixer-rails)
gem "autoprefixer-rails"

# Minimal embedded v8 for Ruby (https://github.com/discourse/mini_racer)
gem 'mini_racer'

# ------------------------------------------------
# EXPORTING
# Provides binaries for WKHTMLTOPDF project in an easily accessible package.
gem 'wkhtmltopdf-binary'

# PDF generator (from HTML) gem for Ruby on Rails (https://github.com/mileszs/wicked_pdf)
gem 'wicked_pdf', '~> 1.1.0'

# This simple gem allows you to create MS Word docx documents from simple html documents. This makes it easy to create dynamic reports and forms that can be downloaded by your users as simple MS Word docx files. (http://github.com/karnov/htmltoword)
gem 'htmltoword', '1.1.0'

# A feed fetching and parsing library (http://feedjira.com)
gem 'feedjira'

# Filename sanitization for Ruby. This is useful when you generate filenames for downloads from user input
gem 'zaru'

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

gem 'api-pagination'

# Following best practices from http://12factor.net run a maintainable, clean, and scalable app on Rails (https://github.com/heroku/rails_12factor)
gem "rails_12factor", group: [:production]

# Autoload dotenv in Rails. (https://github.com/bkeepers/dotenv)
gem "dotenv-rails"

gem 'activerecord-session_store'


# ------------------------------------------------
# ENVIRONMENT SPECIFIC DEPENDENCIES
group :development, :test do
  # Ruby fast debugger - base + CLI (http://github.com/deivid-rodriguez/byebug)
  gem "byebug"

  # RSpec for Rails (https://github.com/rspec/rspec-rails)
  gem "rspec-rails"

  # factory_bot_rails provides integration between factory_bot and rails 3 or newer (http://github.com/thoughtbot/factory_bot_rails)
  # factory_bot_rails provides integration between factory_bot and rails 3 or newer (https://github.com/thoughtbot/factory_bot_rails)
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

  gem 'webdrivers', '~> 3.0'

  gem "rspec-collection_matchers"

  # A set of RSpec matchers for testing Pundit authorisation policies.
  gem 'pundit-matchers'
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
  # Better error page for Rails and other Rack apps (https://github.com/BetterErrors/better_errors)
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

end
