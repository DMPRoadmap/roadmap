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
gem 'pg'
gem 'mysql2', '~> 0.3.18'

# ------------------------------------------------
#    JS <-> RUBY BRIDGE
gem 'libv8'
gem 'therubyracer', '>=0.11.4', platforms: :ruby

# ------------------------------------------------
#    JSON DSL - USED BY API
gem 'jbuilder'

# ------------------------------------------------
#    CLONE ACTIVERECORD MODELS AND ASSOCIATIONS
gem 'amoeba'

# ------------------------------------------------
#    SLUGS/PERMALINKS
gem 'friendly_id'

# ------------------------------------------------
#    BIT FIELDS
gem 'flag_shih_tzu'

# ------------------------------------------------
#    SUPER ADMIN SECTION
gem 'activeadmin', github: 'activeadmin'

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
gem 'twitter-bootstrap-rails', '2.2.8'
gem 'tinymce-rails'                     # WYSIWYG EDITOR
gem 'contact_us', '>= 1.2.0' # COULD BE EASILY REPLACED WITH OUR OWN CODE
gem 'recaptcha'
gem 'dragonfly'                         # LOGO UPLOAD

# ------------------------------------------------
#     EXPORTING
gem 'wkhtmltopdf-binary'
gem 'thin'
gem 'wicked_pdf'
gem 'htmltoword'
gem 'feedjira'
gem 'caracal'                           # WORD DOC EXPORTING
gem 'caracal-rails'
gem 'yaml_db', :git => 'https://github.com/vyruss/yaml_db.git'

# ------------------------------------------------
#     INTERNATIONALIZATION
gem "i18n-js", ">= 3.0.0.rc11"          #damodar added TODO: explain

# ------------------------------------------------
#     API
gem 'swagger-docs'

# ------------------------------------------------
#    CODE DOCUMENTATION
gem 'yard'
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

