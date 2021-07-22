# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationService do

  describe "#application_name" do
    it "returns the application name defined in the dmproadmap.rb initializer" do
      Rails.configuration.x.application.name = "foo"
      expect(described_class.application_name).to eql("foo")
    end
    it "returns the Rails application name if no dmproadmap.rb initializer entry" do
      Rails.configuration.x.application.delete(:name)
      expected = Rails.application.class.name.split("::").first.downcase
      expect(described_class.application_name).to eql(expected)
    end
  end

end
