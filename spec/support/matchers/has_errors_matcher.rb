# frozen_string_literal: true

require "rspec/expectations"

RSpec::Matchers.define :have_errors do |_expected|

  match do
    actual.body.match(/Error:/)
  end

  failure_message do |_actual|
    "expected would have errors on the page."
  end

  failure_message_when_negated do |_actual|
    "expected would not have errors on the page."
  end

end
