require 'database_cleaner'

# Delete previous database entries before running the next specs
RSpec.configure do |config|

  # If there are any tables you wish to exclude from database cleaner,
  # add them here:
  DATABASE_CLEANER_EXCEPTIONS = %w[]

  options = { pre_count: true, reset_ids: true, except: DATABASE_CLEANER_EXCEPTIONS }

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation, options)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, :js => true) do
    DatabaseCleaner.strategy = :truncation, options
  end

  config.before(:each, :threaded => true) do
    DatabaseCleaner.strategy = :truncation, options
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

end
