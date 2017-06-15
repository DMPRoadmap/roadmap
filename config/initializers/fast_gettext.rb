def get_available_locales
    languages = LANGUAGES # LANGUAGES is defined in config/initializers/constants.rb
    locales = []
    languages.each do |l|
        locales << l.abbreviation
    end
    return locales.empty? ? ['en_GB'] : locales 
end

def get_default_locale
    language = LANGUAGES.empty? ? nil : Language.default()
    return language.nil? ? 'en_GB' : language.abbreviation
end

FastGettext.add_text_domain 'app', :path => 'config/locale', :type => :po, :ignore_fuzzy => true, :report_warning => false
FastGettext.default_text_domain = 'app'
FastGettext.default_available_locales = get_available_locales()
FastGettext.default_locale = get_default_locale()
