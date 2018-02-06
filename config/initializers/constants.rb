LANGUAGES = (ActiveRecord::Base.connection.table_exists? 'languages') ? Language.sorted_by_abbreviation : []
MANY_LANGUAGES = LANGUAGES.length > 1
TABLE_FILTER_MIN_ROWS = 10
MAX_NUMBER_LINKS_ORG = 2
MAX_NUMBER_LINKS_FUNDER = 5
MAX_NUMBER_LINKS_SAMPLE_PLAN = 5
MAX_NUMBER_THEMES_PER_COLUMN = 5