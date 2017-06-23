LANGUAGES = (ActiveRecord::Base.connection.table_exists? 'languages') ? Language.sorted_by_abbreviation : []
MANY_LANGUAGES = LANGUAGES.length > 1
