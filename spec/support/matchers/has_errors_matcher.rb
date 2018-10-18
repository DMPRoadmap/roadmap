require 'rspec/expectations'

RSpec::Matchers.define :have_errors do |expected|

  match do
    actual.body.match(/Error\:/)
  end

  failure_message do |actual|
    "expected would have errors on the page."
  end

  failure_message_when_negated do |actual|
    "expected would not have errors on the page."
  end

end
