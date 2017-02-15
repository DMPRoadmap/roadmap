# This initilializer will be removed when all the internationalisation is handled by gettext_rails
DMPRoadmap::Application.config.i18n.enforce_available_locales = false
DMPRoadmap::Application.config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
DMPRoadmap::Application.config.i18n.available_locales = FastGettext.default_available_locales
DMPRoadmap::Application.config.i18n.default_locale = FastGettext.default_locale