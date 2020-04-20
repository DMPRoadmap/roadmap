# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationService do

  describe "#default_language" do
    it "returns the default language abbreviation defined in languages table" do
      lang = create(:language, default_language: true)
      expect(described_class.default_language).to eql(lang.abbreviation)
    end
    it "returns `en` if no default language is defined" do
      Language.destroy_all
      expect(described_class.default_language).to eql("en")
    end
  end

  describe "#application_name" do
    it "returns the application name defined in the config/branding.yml" do
      Rails.application.config.branding[:application][:name] = "foo"
      expect(described_class.application_name).to eql("foo")
    end
    it "returns the Rails application name if no config/branding.yml entry" do
      Rails.application.config.branding[:application].delete(:name)
      expected = Rails.application.class.name.split('::').first.downcase
      expect(described_class.application_name).to eql(expected)
    end
  end

end
