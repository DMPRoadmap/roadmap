def get_available_locales
    languages = Language.sorted_by_abbreviation()
    locales = []
    languages.each do |l|
        locales << l.abbreviation
    end
    puts 'locales: '+locales.inspect
    return locales
end

def get_default_locale
    language = Language.default()
    return language.nil? ? 'en_UK' : language.abbreviation
end

FastGettext.add_text_domain 'app', :path => 'config/locale', :type => :po
FastGettext.default_text_domain = 'app'
FastGettext.default_available_locales = get_available_locales()
FastGettext.default_locale = get_default_locale()
