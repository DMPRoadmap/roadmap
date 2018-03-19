source 'https://rubygems.org'

ruby '>= 2.2.2'

# ------------------------------------------------
#    RAILS
gem 'rails', '4.2.7'
gem 'railties', '~> 4.2'

#    GEMS ADDED TO HELP HANDLE RAILS MIGRATION FROM 3.x to 4.2
#    THESE GEMS HELP SUPPORT DEPRACATED FUNCTIONALITY AND WILL LOSE SUPPORT IN FUTURE VERSIONS
#    WE SHOULD CONSIDER BRINGING THE CODE UP TO DATE INSTEAD
gem 'protected_attributes', '~> 1.1.3'  # Provides attr_accessor functions
gem 'responders', '~> 2.0'  # Allows use of respond_with and respond_to in controllers

# ------------------------------------------------
#    DATABASE/SERVER
gem 'mysql2', '~> 0.3.18'
gem 'pg', '~> 0.19.0'
gem 'flag_shih_tzu', '~> 0.3'  # Allows for bitfields in activereccord

# ------------------------------------------------
#    JS <-> RUBY BRIDGE
gem 'libv8', '~> 3.16'
gem 'therubyracer', '>=0.11.4', platforms: :ruby

# ------------------------------------------------
#    JSON DSL - USED BY API
gem 'jbuilder', '~> 2.6.0'

# ------------------------------------------------
#    SLUGS/PERMALINKS
gem 'friendly_id', '~> 5.1.0'

# ------------------------------------------------
#    SUPER ADMIN SECTION
gem "administrate", :github => 'thoughtbot/administrate', :branch =>'v0.7.0'

# ------------------------------------------------
#    USERS
# devise for user authentication
gem 'devise', '~> 4.2.0'
gem 'devise_invitable', '~> 1.7.0'
gem 'omniauth', '~> 1.3.2'
gem 'omniauth-shibboleth', '~> 1.2.1'
gem 'omniauth-orcid', '~> 2.0'
gem 'ruby_dig'  # for omniauth-orcid

#rolify for roles
gem 'rolify', '~> 5.1.0'
# Gems for repository integration
gem 'pundit', '~> 1.1.0'

# ------------------------------------------------
#    SETTINGS FOR TEMPLATES AND PLANS (FONTS, COLUMN LAYOUTS, ETC)
gem 'ledermann-rails-settings', '~> 2.4.2'

# ------------------------------------------------
#    VIEWS
gem 'contact_us', '~> 1.2.0' # COULD BE EASILY REPLACED WITH OUR OWN CODE
gem 'recaptcha', '~> 4.1.0'
gem 'dragonfly', '~> 1.0.12'                         # LOGO UPLOAD
gem 'formtastic', '~> 3.1.4'

# ------------------------------------------------
#     EXPORTING
gem 'wkhtmltopdf-binary', '~> 0.12.3'
gem 'thin', '~> 1.7'
gem 'wicked_pdf', '~> 1.1.0'
gem 'htmltoword', '~> 0.5.1'
gem 'feedjira', '~> 2.0.0'
gem 'yaml_db', :git => 'https://github.com/vyruss/yaml_db.git'

# ------------------------------------------------
#     INTERNATIONALIZATION
gem 'gettext_i18n_rails', '~> 1.8'
gem "gettext_i18n_rails_js", "~> 1.2.0"
gem 'gettext', '>=3.0.2', :require => false, :group => :development

# ------------------------------------------------
#     API
gem 'swagger-docs', '>= 0.2.9 '

# ------------------------------------------------
#    CODE DOCUMENTATION
gem 'yard', '>= 0.9.5'
gem 'redcarpet', '>= 3.3.4'

# ------------------------------------------------
#     PAGINATION
gem 'kaminari', '>= 1.0'
# ------------------------------------------------
#     ENVIRONMENT SPECIFIC DEPENDENCIES

group :development, :test do
  gem "byebug", '~> 9.0'
end

group :test do
  gem 'minitest-rails-capybara', '~> 2.1.2'
  gem 'minitest-reporters', '~> 1.1.11'
  gem 'rack-test', '~> 0.6.3'
  gem 'webmock', '~> 2.1.0'
  gem 'sqlite3', '~> 1.3.12'
  gem 'simplecov', '~> 0.12', require: false
end

group :development do
  gem "better_errors", '~> 2.1.1'
  gem "binding_of_caller", '~> 0.7.2'
  gem 'web-console', '~> 2.3.0'
  gem 'rack-mini-profiler', '~> 0.10.1'
  #gem 'flamegraph'
end

# ------------------------------------------------
#    GEMS THAT ARE NO LONGER IN USE
#
# gem 'rails-observers'            # UNUSED OBSERVERS FOR ACTIVERECORD ... PHASED OUT IN RAILS 5.0
# gem 'actionpack-page_caching'    # UNUSED BUT LOOKS PROMISING FOR STATIC PAGES
# gem 'actionpack-action_caching'  # UNUSED BUT LOOKS PROMISING FOR FAIRLY STATIC PAGES BEHIND AUTH
# gem 'exception_notification'     # UNUSED BUT COULD BE USEFUL FOR ERROR MSG BEING SENT TO ADMINS FROM PROD SYS
# gem 'email_validator'            # UNUSED ACTIVERECORD VALIDATOR
# gem 'validate_url'               # UNUSED ACTIVERECORD VALIDATOR
# gem 'turbolinks'                 # IS NOW A CORE PART OF RAILS >= 4.0

