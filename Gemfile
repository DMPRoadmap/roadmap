source 'https://rubygems.org'

ruby '>= 2.4.4'

# ------------------------------------------------
#    RAILS
gem 'rails', '~> 4.2.10'
gem 'railties'


#    GEMS ADDED TO HELP HANDLE RAILS MIGRATION FROM 3.x to 4.2
#    THESE GEMS HELP SUPPORT DEPRACATED FUNCTIONALITY AND WILL LOSE SUPPORT IN FUTURE VERSIONS
#    WE SHOULD CONSIDER BRINGING THE CODE UP TO DATE INSTEAD
gem 'protected_attributes', '~> 1.1.3'  # Provides attr_accessor functions
gem 'responders', '~> 2.0'  # Allows use of respond_with and respond_to in controllers

# ------------------------------------------------
#    DATABASE/SERVER
gem 'mysql2', '~> 0.4.10'
gem 'pg', '~> 0.19.0'
gem 'flag_shih_tzu'  # Allows for bitfields in activereccord

# ------------------------------------------------
#    JSON DSL - USED BY API
gem 'jbuilder', '~> 2.6.0'
# ------------------------------------------------

#    USERS
# devise for user authentication
gem 'devise'
gem 'devise_invitable'
gem 'omniauth'
gem 'omniauth-shibboleth'
gem 'omniauth-orcid'
gem 'ruby_dig'  # for omniauth-orcid

# Gems for repository integration
gem 'pundit'

# ------------------------------------------------
#    SETTINGS FOR TEMPLATES AND PLANS (FONTS, COLUMN LAYOUTS, ETC)
gem 'ledermann-rails-settings'

# ------------------------------------------------
#    VIEWS
gem 'contact_us' # COULD BE EASILY REPLACED WITH OUR OWN CODE
gem 'recaptcha'
gem 'dragonfly'              # LOGO UPLOAD
gem 'formtastic'

# ------------------------------------------------
#     EXPORTING
gem 'wkhtmltopdf-binary'
gem 'thin'
gem 'wicked_pdf'
gem 'htmltoword'
gem 'feedjira'

# ------------------------------------------------
#     INTERNATIONALIZATION
gem 'gettext_i18n_rails'
gem 'gettext_i18n_rails_js'
gem 'gettext', :require => false, :group => :development

# ------------------------------------------------
#     PAGINATION
gem 'kaminari'
# ------------------------------------------------

#     ENVIRONMENT SPECIFIC DEPENDENCIES
group :development, :test do
  gem "byebug"
end

group :test do
  gem 'minitest-reporters'
  gem 'rack-test'
  gem 'webmock'
  gem 'sqlite3'
  gem 'simplecov', require: false
end

group :development do
  gem "better_errors"
  gem "binding_of_caller"
  gem 'web-console'
  gem 'rack-mini-profiler'
end
