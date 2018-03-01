source 'https://rubygems.org'

ruby '>= 2.2.2'

# ------------------------------------------------
#    RAILS
gem 'rails', '4.2.7'
gem 'railties'

#    GEMS ADDED TO HELP HANDLE RAILS MIGRATION FROM 3.x to 4.2
#    THESE GEMS HELP SUPPORT DEPRACATED FUNCTIONALITY AND WILL LOSE SUPPORT IN FUTURE VERSIONS
#    WE SHOULD CONSIDER BRINGING THE CODE UP TO DATE INSTEAD
gem 'protected_attributes'  # Provides attr_accessor functions
gem 'responders', '~> 2.0'  # Allows use of respond_with and respond_to in controllers

# ------------------------------------------------
#    DATABASE/SERVER
gem 'mysql2', '~> 0.3.18'
gem 'pg'
gem 'flag_shih_tzu'  # Allows for bitfields in activereccord

# ------------------------------------------------
#    JS <-> RUBY BRIDGE
gem 'libv8'
gem 'therubyracer', '>=0.11.4', platforms: :ruby

# ------------------------------------------------
#    JSON DSL - USED BY API
gem 'jbuilder'

# ------------------------------------------------
#    SLUGS/PERMALINKS
gem 'friendly_id'

# ------------------------------------------------
#    SUPER ADMIN SECTION
gem "administrate", :github => 'thoughtbot/administrate', :branch =>'v0.7.0'

# ------------------------------------------------
#    USERS
# devise for user authentication
gem 'devise'
gem 'devise_invitable'
gem 'omniauth'
gem 'omniauth-shibboleth'
gem 'omniauth-orcid'

#rolify for roles
gem 'rolify'
# Gems for repository integration
gem 'pundit'

# ------------------------------------------------
#    SETTINGS FOR TEMPLATES AND PLANS (FONTS, COLUMN LAYOUTS, ETC)
gem 'ledermann-rails-settings'

# ------------------------------------------------
#    VIEWS
gem 'sass-rails'
gem 'less-rails'                        # WE SHOULD PROBABLY USE SASS OR LESS NOT BOTH
gem 'jquery-rails'
gem 'font-awesome-rails'
gem 'twitter-bootstrap-rails', '2.2.8'
gem 'tinymce-rails'                     # WYSIWYG EDITOR
gem 'contact_us', '>= 1.2.0' # COULD BE EASILY REPLACED WITH OUR OWN CODE
gem 'recaptcha', '>= 4.0'
gem 'dragonfly'                         # LOGO UPLOAD
gem 'formtastic'

# ------------------------------------------------
#     EXPORTING
gem 'wkhtmltopdf-binary'
gem 'thin'
gem 'wicked_pdf'
gem 'htmltoword', '>= 0.7'
gem 'feedjira'
gem 'yaml_db', :git => 'https://github.com/vyruss/yaml_db.git'

# ------------------------------------------------
#     INTERNATIONALIZATION
gem "i18n-js", ">= 3.0.0.rc11"          #damodar added TODO: explain
gem 'gettext_i18n_rails', '~> 1.8'
gem "gettext_i18n_rails_js", "~> 1.2.0"
gem 'gettext', '>=3.0.2', :require => false, :group => :development

# ------------------------------------------------
#     API
gem 'swagger-docs'

# ------------------------------------------------
#    CODE DOCUMENTATION
gem 'yard', '>= 0.9.11'
gem 'redcarpet'


# ------------------------------------------------
#     ENVIRONMENT SPECIFIC DEPENDENCIES

group :development, :test do
  gem "byebug"
end

group :test do
  gem 'minitest-rails-capybara'
  gem 'minitest-reporters'
  gem 'rack-test'
  gem 'webmock'
  gem 'sqlite3'
  gem 'simplecov', require: false
end

group :development do
  gem "better_errors"
  gem "binding_of_caller"
  gem 'web-console', '~>2.0'
  gem 'rack-mini-profiler'
  #gem 'flamegraph'
end

group :production do
  gem 'uglifier'    # JS minifier
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

