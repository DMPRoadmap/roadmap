require 'test_helper'
class BrandingTest < ActiveSupport::TestCase

  test "Returns nested value from hash" do
    Rails.configuration.stub(:branding, { test: { value: "foo" }}) do
      assert_equal Branding.fetch(:test, :value), "foo"
    end
  end

  test "It has indifferent access" do
    Rails.configuration.stub(:branding, { test: { value: "foo" }}) do
      assert_equal Branding.fetch(:test, 'value'), "foo"
    end
  end

  test "Returns nil if key is missing" do
    Rails.configuration.stub(:branding, { test: nil }) do
      assert_nil Branding.fetch(:test, 'value')
    end
  end
end
