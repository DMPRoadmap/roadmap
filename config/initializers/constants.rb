TABLE_FILTER_MIN_ROWS = 10
MAX_NUMBER_LINKS_FUNDER = 5
MAX_NUMBER_LINKS_SAMPLE_PLAN = 5
MAX_NUMBER_THEMES_PER_COLUMN = 5

if Rails.env.test?
  LANGUAGES = []
  MANY_LANGUAGES = false
else
  LANGUAGES = (ActiveRecord::Base.connection.table_exists? 'languages') ? Language.sorted_by_abbreviation : []
  MANY_LANGUAGES = LANGUAGES.length > 1
end
