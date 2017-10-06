# This initilializer should not be removed unless all internationalisation is handled by gettext_rails
DMPRoadmap::Application.config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
module I18n
    class Config
        def locale
            FastGettext.locale
        end
        def locale=(new_locale)
            FastGettext.locale = (new_locale)
        end
        def default_locale
            FastGettext.default_locale
        end
        def default_locale=(new_default_locale)
            FastGettext.default_locale = (new_default_locale)
        end
        def available_locales
            FastGettext.default_available_locales
        end
        def available_locales=(new_available_locales)
            FastGettext.default_available_locales = (new_available_locales)
        end
    end
end