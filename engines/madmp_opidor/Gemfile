source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Declare your gem's dependencies in madmp_opidor.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use a debugger
# gem 'byebug', group: [:development, :test]

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
  gem 'rubocop-performance'

  # Automatic Rails code style checking tool. A RuboCop extension focused on enforcing
  # Rails best practices and coding conventions.
  gem 'rubocop-rails'

  # A RuboCop plugin for Rake tasks
  gem 'rubocop-rake'

  # Code style checking for RSpec files. A plugin for the RuboCop code style enforcing
  # & linting tool.
  gem 'rubocop-rspec'

  # Thread-safety checks via static analysis. A plugin for the RuboCop code style
  # enforcing & linting tool.
  gem 'rubocop-thread_safety'
end
