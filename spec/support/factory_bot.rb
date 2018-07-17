RSpec.configure do |config|
  config.before(:suite) do
    FactoryBot.lint
  end
end
